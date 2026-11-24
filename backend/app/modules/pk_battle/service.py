from __future__ import annotations
from datetime import timedelta

from sqlalchemy import and_, func, or_, select
from sqlalchemy.orm import Session, joinedload

from app.core.config import get_settings
from app.core.exceptions import BadRequestError, ConflictError, ForbiddenError, NotFoundError
from app.core.security import utc_now
from app.models.user import User
from app.modules.live_gateway.models import LiveRoom
from app.modules.notifications_fcm.service import notification_service
from app.modules.pk_battle.models import PkBattle, PkQueueEntry, PkScoreEvent
from app.modules.pk_battle.schemas import (
    PkAcceptRequest,
    PkBattleListResponse,
    PkBattleResponse,
    PkChallengeRequest,
    PkHostSummary,
    PkQueueJoinRequest,
    PkQueueMatchResponse,
    PkScoreRequest,
)
from app.realtime.connection_manager import realtime_hub


class PkBattleService:
    """Real-time PK matchmaking queue, challenges, round timers, and victory settlement."""

    @staticmethod
    def _validate_duration(requested: int | None) -> int:
        settings = get_settings()
        duration = requested if requested is not None else settings.pk_default_round_seconds
        if duration < settings.pk_min_round_seconds or duration > settings.pk_max_round_seconds:
            raise BadRequestError(
                f"PK duration must be between {settings.pk_min_round_seconds} and {settings.pk_max_round_seconds} seconds"
            )
        return duration

    @staticmethod
    def _validate_host_room(db: Session, host_id: str, room_id: str | None) -> str | None:
        if not room_id:
            return None
        room = db.get(LiveRoom, room_id)
        if not room or room.host_id != host_id or room.status == "ended":
            raise BadRequestError("Provided live room is invalid, ended, or not owned by host")
        if not room.allow_pk:
            raise ForbiddenError("PK battles are disabled in this live room")
        return room.id

    @staticmethod
    def _remaining_seconds(battle: PkBattle) -> int:
        if battle.status != "active" or not battle.ends_at:
            return 0
        delta = int((battle.ends_at - utc_now()).total_seconds())
        return max(0, delta)

    @classmethod
    def serialize_battle(cls, battle: PkBattle) -> PkBattleResponse:
        host_a = battle.host_a
        host_b = battle.host_b
        cover_a = (battle.room_a.cover_url if (battle.room_a and battle.room_a.cover_url) else "") or (host_a.avatar_url if host_a else "")
        cover_b = (battle.room_b.cover_url if (battle.room_b and battle.room_b.cover_url) else "") or (host_b.avatar_url if host_b else "")
        return PkBattleResponse(
            id=battle.id,
            status=battle.status,
            durationSeconds=battle.duration_seconds,
            secondsLeft=cls._remaining_seconds(battle),
            coverUrl=cover_a or cover_b,
            hostA=PkHostSummary(
                id=battle.host_a_id,
                name=host_a.name if host_a else "Host A",
                username=host_a.username if host_a else "host_a",
                avatarUrl=host_a.avatar_url if host_a else "",
                coverUrl=cover_a,
                roomId=battle.room_a_id,
                score=battle.host_a_score,
            ),
            hostB=PkHostSummary(
                id=battle.host_b_id,
                name=host_b.name if host_b else "Host B",
                username=host_b.username if host_b else "host_b",
                avatarUrl=host_b.avatar_url if host_b else "",
                coverUrl=cover_b,
                roomId=battle.room_b_id,
                score=battle.host_b_score,
            ),
            winnerId=battle.winner_id,
            isDraw=battle.is_draw,
            startedAt=battle.started_at,
            endsAt=battle.ends_at,
            endedAt=battle.ended_at,
            createdAt=battle.created_at,
        )

    @classmethod
    def finalize_battle(cls, db: Session, battle: PkBattle) -> PkBattle:
        """Compute victory/defeat/draw from live MySQL scores and emit WebSocket result."""
        if battle.status == "ended":
            return battle

        battle.status = "ended"
        battle.ended_at = utc_now()
        if battle.host_a_score > battle.host_b_score:
            battle.winner_id = battle.host_a_id
            battle.is_draw = False
        elif battle.host_b_score > battle.host_a_score:
            battle.winner_id = battle.host_b_id
            battle.is_draw = False
        else:
            battle.winner_id = None
            battle.is_draw = True

        db.commit()
        db.refresh(battle)

        payload = cls.serialize_battle(battle).model_dump(mode="json")
        cls._broadcast_battle_event(battle, "pk_ended", payload)
        return battle

    @classmethod
    def auto_finalize_if_expired(cls, db: Session, battle: PkBattle) -> PkBattle:
        if battle.status == "active" and battle.ends_at and utc_now() >= battle.ends_at:
            return cls.finalize_battle(db, battle)
        return battle

    @staticmethod
    def _broadcast_battle_event(battle: PkBattle, event_type: str, data: dict) -> None:
        realtime_hub.broadcast_room_sync(f"pk:{battle.id}", event_type, data)
        if battle.room_a_id:
            realtime_hub.broadcast_room_sync(battle.room_a_id, event_type, data)
        if battle.room_b_id and battle.room_b_id != battle.room_a_id:
            realtime_hub.broadcast_room_sync(battle.room_b_id, event_type, data)

    def _ensure_no_active_battle(self, db: Session, host_id: str) -> None:
        active = db.scalar(
            select(PkBattle).where(
                and_(
                    PkBattle.status == "active",
                    or_(PkBattle.host_a_id == host_id, PkBattle.host_b_id == host_id),
                )
            )
        )
        if active:
            active = self.auto_finalize_if_expired(db, active)
            if active.status == "active":
                raise ConflictError("Host is already participating in an active PK battle")

    def join_matchmaking_queue(
        self,
        db: Session,
        host: User,
        payload: PkQueueJoinRequest,
    ) -> PkQueueMatchResponse:
        duration = self._validate_duration(payload.durationSeconds)
        room_id = self._validate_host_room(db, host.id, payload.roomId)
        self._ensure_no_active_battle(db, host.id)

        opponent_entry = db.scalar(
            select(PkQueueEntry)
            .where(and_(PkQueueEntry.status == "waiting", PkQueueEntry.host_id != host.id))
            .order_by(PkQueueEntry.created_at.asc())
            .with_for_update()
        )

        my_entry = db.scalar(
            select(PkQueueEntry).where(PkQueueEntry.host_id == host.id).with_for_update()
        )

        if opponent_entry:
            now = utc_now()
            effective_duration = min(duration, opponent_entry.preferred_duration_seconds)
            battle = PkBattle(
                host_a_id=opponent_entry.host_id,
                host_b_id=host.id,
                room_a_id=opponent_entry.room_id,
                room_b_id=room_id,
                status="active",
                duration_seconds=effective_duration,
                started_at=now,
                ends_at=now + timedelta(seconds=effective_duration),
            )
            db.add(battle)
            db.flush()

            opponent_entry.status = "matched"
            opponent_entry.matched_battle_id = battle.id
            if my_entry:
                my_entry.room_id = room_id
                my_entry.preferred_duration_seconds = duration
                my_entry.status = "matched"
                my_entry.matched_battle_id = battle.id
            else:
                db.add(
                    PkQueueEntry(
                        host_id=host.id,
                        room_id=room_id,
                        preferred_duration_seconds=duration,
                        status="matched",
                        matched_battle_id=battle.id,
                    )
                )

            db.commit()
            loaded = db.scalar(
                select(PkBattle)
                .options(joinedload(PkBattle.host_a), joinedload(PkBattle.host_b))
                .where(PkBattle.id == battle.id)
            )
            serialized = self.serialize_battle(loaded)
            self._broadcast_battle_event(loaded, "pk_started", serialized.model_dump(mode="json"))
            notification_service.notify_pk_started(
                db=db,
                battle_id=loaded.id,
                host_a=loaded.host_a,
                host_b=loaded.host_b,
            )
            return PkQueueMatchResponse(matched=True, queueStatus="matched", battle=serialized)

        if my_entry:
            my_entry.room_id = room_id
            my_entry.preferred_duration_seconds = duration
            my_entry.status = "waiting"
            my_entry.matched_battle_id = None
        else:
            db.add(
                PkQueueEntry(
                    host_id=host.id,
                    room_id=room_id,
                    preferred_duration_seconds=duration,
                    status="waiting",
                )
            )
        db.commit()
        return PkQueueMatchResponse(matched=False, queueStatus="waiting", battle=None)

    def leave_matchmaking_queue(self, db: Session, host: User) -> PkQueueMatchResponse:
        entry = db.scalar(select(PkQueueEntry).where(PkQueueEntry.host_id == host.id))
        if entry and entry.status == "waiting":
            entry.status = "cancelled"
            db.commit()
        return PkQueueMatchResponse(matched=False, queueStatus="cancelled", battle=None)

    def create_challenge(
        self,
        db: Session,
        host_a: User,
        payload: PkChallengeRequest,
    ) -> PkBattleResponse:
        if payload.opponentUserId == host_a.id:
            raise BadRequestError("You cannot start a PK battle with yourself")
        opponent = db.get(User, payload.opponentUserId)
        if not opponent or not opponent.is_active:
            raise NotFoundError("Opponent creator not found")

        duration = self._validate_duration(payload.durationSeconds)
        room_a_id = self._validate_host_room(db, host_a.id, payload.roomId)
        room_b_id = self._validate_host_room(db, opponent.id, payload.opponentRoomId)
        self._ensure_no_active_battle(db, host_a.id)
        self._ensure_no_active_battle(db, opponent.id)

        battle = PkBattle(
            host_a_id=host_a.id,
            host_b_id=opponent.id,
            room_a_id=room_a_id,
            room_b_id=room_b_id,
            status="pending",
            duration_seconds=duration,
        )
        db.add(battle)
        db.commit()
        loaded = db.scalar(
            select(PkBattle)
            .options(joinedload(PkBattle.host_a), joinedload(PkBattle.host_b))
            .where(PkBattle.id == battle.id)
        )
        serialized = self.serialize_battle(loaded)
        realtime_hub.send_to_user_sync(
            opponent.id,
            "pk_challenge",
            serialized.model_dump(mode="json"),
        )
        return serialized

    def accept_challenge(
        self,
        db: Session,
        host_b: User,
        battle_id: str,
        payload: PkAcceptRequest | None = None,
    ) -> PkBattleResponse:
        battle = db.scalar(
            select(PkBattle)
            .options(joinedload(PkBattle.host_a), joinedload(PkBattle.host_b))
            .where(PkBattle.id == battle_id)
            .with_for_update()
        )
        if not battle:
            raise NotFoundError("PK battle not found")
        if battle.host_b_id != host_b.id:
            raise ForbiddenError("Only the challenged host may accept this PK battle")
        if battle.status != "pending":
            raise BadRequestError(f"Cannot accept PK battle in status '{battle.status}'")

        if payload and payload.roomId:
            battle.room_b_id = self._validate_host_room(db, host_b.id, payload.roomId)

        now = utc_now()
        battle.status = "active"
        battle.started_at = now
        battle.ends_at = now + timedelta(seconds=battle.duration_seconds)
        db.commit()
        db.refresh(battle)

        serialized = self.serialize_battle(battle)
        self._broadcast_battle_event(battle, "pk_started", serialized.model_dump(mode="json"))
        notification_service.notify_pk_started(
            db=db,
            battle_id=battle.id,
            host_a=battle.host_a,
            host_b=battle.host_b,
        )
        return serialized

    def decline_challenge(self, db: Session, host_b: User, battle_id: str) -> PkBattleResponse:
        battle = db.scalar(
            select(PkBattle)
            .options(joinedload(PkBattle.host_a), joinedload(PkBattle.host_b))
            .where(PkBattle.id == battle_id)
        )
        if not battle:
            raise NotFoundError("PK battle not found")
        if battle.host_b_id != host_b.id and battle.host_a_id != host_b.id:
            raise ForbiddenError("Only battle participants may decline or cancel")
        if battle.status != "pending":
            raise BadRequestError(f"Cannot decline PK battle in status '{battle.status}'")
        battle.status = "declined"
        battle.ended_at = utc_now()
        db.commit()
        db.refresh(battle)
        return self.serialize_battle(battle)

    def end_battle(self, db: Session, actor: User, battle_id: str) -> PkBattleResponse:
        battle = db.scalar(
            select(PkBattle)
            .options(joinedload(PkBattle.host_a), joinedload(PkBattle.host_b))
            .where(PkBattle.id == battle_id)
            .with_for_update()
        )
        if not battle:
            raise NotFoundError("PK battle not found")
        if actor.id not in (battle.host_a_id, battle.host_b_id):
            raise ForbiddenError("Only Host A or Host B can manually end a battle early")
        if battle.status == "declined":
            raise BadRequestError("Battle was already declined")
        ended = self.finalize_battle(db, battle)
        return self.serialize_battle(ended)

    def add_score(
        self,
        db: Session,
        current_user: User,
        battle_id: str,
        payload: PkScoreRequest,
    ) -> PkBattleResponse:
        battle = db.scalar(
            select(PkBattle)
            .options(joinedload(PkBattle.host_a), joinedload(PkBattle.host_b))
            .where(PkBattle.id == battle_id)
        )
        if not battle:
            raise NotFoundError("PK battle not found")
        if battle.status != "active":
            raise BadRequestError(f"Cannot score: PK battle is {battle.status}")

        battle = self.auto_finalize_if_expired(db, battle)
        if battle.status == "ended":
            raise BadRequestError("PK battle has already ended")

        target_id = payload.targetHostId
        if target_id not in (battle.host_a_id, battle.host_b_id):
            raise BadRequestError("Target host is not part of this PK battle")

        if target_id == battle.host_a_id:
            battle.host_a_score += payload.points
        else:
            battle.host_b_score += payload.points

        score_event = PkScoreEvent(
            battle_id=battle.id,
            target_host_id=target_id,
            sender_id=current_user.id,
            points_added=payload.points,
            host_a_score_after=battle.host_a_score,
            host_b_score_after=battle.host_b_score,
        )
        db.add(score_event)
        db.commit()
        db.refresh(battle)

        # Broadcast live score update via WebSocket
        data = self.serialize_battle(battle).model_dump(mode="json")
        data["lastGifter"] = {
            "id": current_user.id,
            "name": current_user.name,
            "avatarUrl": current_user.avatar_url or "",
            "giftName": payload.giftName,
            "points": payload.points,
            "targetHostId": target_id,
        }
        realtime_hub.broadcast_room_sync(f"pk:{battle.id}", "pk_score_updated", data)
        if battle.room_a_id:
            realtime_hub.broadcast_room_sync(battle.room_a_id, "pk_score_updated", data)
        if battle.room_b_id:
            realtime_hub.broadcast_room_sync(battle.room_b_id, "pk_score_updated", data)

        return self.serialize_battle(battle)

    def get_battle(self, db: Session, battle_id: str) -> PkBattleResponse:
        battle = db.scalar(
            select(PkBattle)
            .options(
                joinedload(PkBattle.host_a),
                joinedload(PkBattle.host_b),
                joinedload(PkBattle.room_a),
                joinedload(PkBattle.room_b),
            )
            .where(PkBattle.id == battle_id)
        )
        if not battle:
            raise NotFoundError("PK battle not found")
        battle = self.auto_finalize_if_expired(db, battle)
        return self.serialize_battle(battle)

    def list_battles(
        self,
        db: Session,
        status_filter: str = "active",
        page: int = 1,
        page_size: int = 20,
    ) -> PkBattleListResponse:
        conditions = []
        if status_filter != "all":
            conditions.append(PkBattle.status == status_filter)

        total = int(
            db.scalar(select(func.count()).select_from(PkBattle).where(*conditions)) or 0
        )
        rows = list(
            db.scalars(
                select(PkBattle)
                .options(
                    joinedload(PkBattle.host_a),
                    joinedload(PkBattle.host_b),
                    joinedload(PkBattle.room_a),
                    joinedload(PkBattle.room_b),
                )
                .where(*conditions)
                .order_by(PkBattle.created_at.desc())
                .offset((page - 1) * page_size)
                .limit(page_size)
            ).all()
        )
        updated = [self.auto_finalize_if_expired(db, row) for row in rows]
        if status_filter == "active":
            updated = [b for b in updated if b.status == "active"]
            total = len(updated)
        return PkBattleListResponse(
            battles=[self.serialize_battle(b) for b in updated],
            total=total,
            page=page,
            pageSize=page_size,
            hasMore=(page * page_size) < total,
        )


pk_battle_service = PkBattleService()
