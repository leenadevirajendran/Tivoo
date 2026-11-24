from __future__ import annotations
import hmac
import secrets

from sqlalchemy import and_, func, or_, select
from sqlalchemy.orm import Session, joinedload

from app.core.config import get_settings
from app.core.exceptions import BadRequestError, ForbiddenError, NotFoundError, UnauthorizedError
from app.core.security import utc_now, verify_secret_value
from app.models.user import User
from app.modules.live_gateway.media_tokens import (
    build_rtmp_urls,
    generate_stream_key,
    issue_rtc_credentials,
)
from app.modules.live_gateway.models import LiveParticipant, LiveRoom
from app.modules.live_gateway.schemas import (
    CreateLiveRoomRequest,
    LiveRoomCreatedResponse,
    LiveRoomListResponse,
    LiveRoomResponse,
    RtcTokenResponse,
)
from app.modules.notifications_fcm.service import notification_service
from app.realtime.connection_manager import realtime_hub


class LiveGatewayService:
    """Manages live stream rooms, stream keys, RTC tokens, and active viewer counts in MySQL."""

    @staticmethod
    def _serialize_room(room: LiveRoom) -> LiveRoomResponse:
        host = room.host
        return LiveRoomResponse(
            id=room.id,
            roomKey=room.room_key,
            hostId=room.host_id,
            hostName=host.name if host else "Creator",
            hostUsername=host.username if host else "creator",
            hostAvatar=host.avatar_url if host else "",
            title=room.title,
            category=room.category,
            coverUrl=room.cover_url,
            provider=room.provider,
            status=room.status,
            streamKeyMasked=room.stream_key_masked,
            rtmpIngestUrl=room.rtmp_ingest_url,
            playbackHlsUrl=room.playback_hls_url,
            allowChat=room.allow_chat,
            allowGifts=room.allow_gifts,
            allowPk=room.allow_pk,
            viewerCount=room.viewer_count,
            peakViewers=room.peak_viewers,
            likesCount=room.likes_count,
            totalGiftsDiamonds=room.total_gifts_diamonds,
            startedAt=room.started_at,
            endedAt=room.ended_at,
            createdAt=room.created_at,
        )

    def create_room(
        self,
        db: Session,
        host: User,
        payload: CreateLiveRoomRequest,
    ) -> LiveRoomCreatedResponse:
        settings = get_settings()
        provider = payload.provider or settings.live_media_provider
        room_key = f"live_{secrets.token_hex(8)}"
        key_bundle = generate_stream_key()
        rtmp_ingest_url, playback_hls_url, publish_url = build_rtmp_urls(
            room_key, key_bundle.raw_key
        )

        room = LiveRoom(
            host_id=host.id,
            room_key=room_key,
            title=payload.title.strip(),
            category=payload.category.strip() or "Entertainment",
            cover_url=payload.coverUrl.strip(),
            provider=provider,
            status="scheduled",
            stream_key_hash=key_bundle.digest,
            stream_key_masked=key_bundle.masked_key,
            rtmp_ingest_url=rtmp_ingest_url,
            playback_hls_url=playback_hls_url,
            allow_chat=payload.allowChat,
            allow_gifts=payload.allowGifts,
            allow_pk=payload.allowPk,
        )
        db.add(room)
        db.commit()
        db.refresh(room)

        host_participant = LiveParticipant(
            room_id=room.id,
            user_id=host.id,
            role="host",
            is_active=True,
        )
        db.add(host_participant)
        db.commit()

        base = self._serialize_room(room)
        return LiveRoomCreatedResponse(
            **base.model_dump(),
            streamKey=key_bundle.raw_key,
            rtmpPublishUrl=publish_url or f"{rtmp_ingest_url}/{key_bundle.raw_key}",
        )

    def rotate_stream_key(self, db: Session, host: User, room_id: str) -> LiveRoomCreatedResponse:
        room = self._require_host_room(db, host, room_id)
        if room.status == "ended":
            raise BadRequestError("Cannot rotate key for an ended live room")
        key_bundle = generate_stream_key()
        rtmp_ingest_url, playback_hls_url, publish_url = build_rtmp_urls(
            room.room_key, key_bundle.raw_key
        )
        room.stream_key_hash = key_bundle.digest
        room.stream_key_masked = key_bundle.masked_key
        room.rtmp_ingest_url = rtmp_ingest_url
        room.playback_hls_url = playback_hls_url
        db.commit()
        db.refresh(room)

        base = self._serialize_room(room)
        return LiveRoomCreatedResponse(
            **base.model_dump(),
            streamKey=key_bundle.raw_key,
            rtmpPublishUrl=publish_url or f"{rtmp_ingest_url}/{key_bundle.raw_key}",
        )

    def start_room(self, db: Session, host: User, room_id: str) -> LiveRoomResponse:
        room = self._require_host_room(db, host, room_id)
        if room.status == "ended":
            raise BadRequestError("Live room has already ended")
        if room.status != "live":
            room.status = "live"
            room.started_at = utc_now()
            host.live_streams_count += 1
            db.commit()
            db.refresh(room)
            notification_service.notify_followers_live_started(
                db=db,
                host_user=host,
                room_id=room.id,
                room_title=room.title,
            )
            realtime_hub.broadcast_room_sync(
                room.id,
                "room_started",
                {"roomId": room.id, "startedAt": room.started_at.isoformat() if room.started_at else None},
            )
        return self._serialize_room(room)

    def end_room(self, db: Session, host: User, room_id: str) -> LiveRoomResponse:
        room = self._require_host_room(db, host, room_id)
        if room.status != "ended":
            now = utc_now()
            room.status = "ended"
            room.ended_at = now
            room.viewer_count = 0
            active_rows = list(
                db.scalars(
                    select(LiveParticipant).where(
                        and_(LiveParticipant.room_id == room.id, LiveParticipant.is_active.is_(True))
                    )
                ).all()
            )
            for row in active_rows:
                row.is_active = False
                row.left_at = now
            db.commit()
            db.refresh(room)
            realtime_hub.broadcast_room_sync(
                room.id,
                "room_ended",
                {"roomId": room.id, "endedAt": now.isoformat()},
            )
        return self._serialize_room(room)

    def issue_host_rtc_token(self, db: Session, host: User, room_id: str) -> RtcTokenResponse:
        room = self._require_host_room(db, host, room_id)
        if room.status == "ended":
            raise BadRequestError("Cannot issue token for an ended live room")
        creds = issue_rtc_credentials(
            provider=room.provider,
            room_key=room.room_key,
            identity=host.id,
            display_name=host.name,
            can_publish=True,
        )
        return RtcTokenResponse(
            provider=creds.provider,
            roomId=room.id,
            roomKey=room.room_key,
            identity=host.id,
            role="host",
            token=creds.token,
            serverUrl=creds.server_url,
            appId=creds.app_id,
            playbackHlsUrl=room.playback_hls_url,
            expiresAt=creds.expires_at,
        )

    def join_room(self, db: Session, user: User, room_id: str) -> RtcTokenResponse:
        room = db.scalar(select(LiveRoom).where(LiveRoom.id == room_id).with_for_update())
        if not room:
            raise NotFoundError("Live room not found")
        if room.status == "ended":
            raise BadRequestError("This live stream has ended")

        role = "host" if room.host_id == user.id else "viewer"
        existing = db.scalar(
            select(LiveParticipant).where(
                and_(LiveParticipant.room_id == room.id, LiveParticipant.user_id == user.id)
            )
        )
        now = utc_now()
        if existing:
            existing.is_active = True
            existing.role = role
            existing.last_heartbeat_at = now
            existing.left_at = None
        else:
            db.add(
                LiveParticipant(
                    room_id=room.id,
                    user_id=user.id,
                    role=role,
                    is_active=True,
                    last_heartbeat_at=now,
                )
            )

        db.flush()
        active_viewers = int(
            db.scalar(
                select(func.count())
                .select_from(LiveParticipant)
                .where(
                    and_(
                        LiveParticipant.room_id == room.id,
                        LiveParticipant.is_active.is_(True),
                        LiveParticipant.role != "host",
                    )
                )
            )
            or 0
        )
        room.viewer_count = active_viewers
        if active_viewers > room.peak_viewers:
            room.peak_viewers = active_viewers
        db.commit()

        realtime_hub.broadcast_room_sync(
            room.id,
            "viewer_count_updated",
            {"roomId": room.id, "viewerCount": room.viewer_count},
        )

        creds = issue_rtc_credentials(
            provider=room.provider,
            room_key=room.room_key,
            identity=user.id,
            display_name=user.name,
            can_publish=(role == "host"),
        )
        return RtcTokenResponse(
            provider=creds.provider,
            roomId=room.id,
            roomKey=room.room_key,
            identity=user.id,
            role=role,
            token=creds.token,
            serverUrl=creds.server_url,
            appId=creds.app_id,
            playbackHlsUrl=room.playback_hls_url,
            expiresAt=creds.expires_at,
        )

    def leave_room(self, db: Session, user: User, room_id: str) -> dict[str, int | str]:
        room = db.scalar(select(LiveRoom).where(LiveRoom.id == room_id).with_for_update())
        if not room:
            raise NotFoundError("Live room not found")

        participant = db.scalar(
            select(LiveParticipant).where(
                and_(LiveParticipant.room_id == room.id, LiveParticipant.user_id == user.id)
            )
        )
        if participant and participant.is_active:
            participant.is_active = False
            participant.left_at = utc_now()
            db.flush()

        active_viewers = int(
            db.scalar(
                select(func.count())
                .select_from(LiveParticipant)
                .where(
                    and_(
                        LiveParticipant.room_id == room.id,
                        LiveParticipant.is_active.is_(True),
                        LiveParticipant.role != "host",
                    )
                )
            )
            or 0
        )
        room.viewer_count = active_viewers
        db.commit()

        realtime_hub.broadcast_room_sync(
            room.id,
            "viewer_count_updated",
            {"roomId": room.id, "viewerCount": room.viewer_count},
        )
        return {"roomId": room.id, "viewerCount": room.viewer_count}

    def like_room(self, db: Session, user: User, room_id: str) -> dict[str, int | str]:
        room = db.scalar(select(LiveRoom).where(LiveRoom.id == room_id).with_for_update())
        if not room or room.status == "ended":
            raise NotFoundError("Active live room not found")
        room.likes_count += 1
        db.commit()
        realtime_hub.broadcast_room_sync(
            room.id,
            "live_like",
            {"roomId": room.id, "userId": user.id, "likesCount": room.likes_count},
        )
        return {"roomId": room.id, "likesCount": room.likes_count}

    def list_rooms(
        self,
        db: Session,
        status_filter: str = "live",
        category: str | None = None,
        q: str | None = None,
        page: int = 1,
        page_size: int = 20,
    ) -> LiveRoomListResponse:
        conditions = []
        if status_filter != "all":
            conditions.append(LiveRoom.status == status_filter)
        if category and category.strip().lower() != "all":
            conditions.append(LiveRoom.category == category.strip())
        if q and q.strip():
            term = f"%{q.strip()}%"
            conditions.append(or_(LiveRoom.title.ilike(term), LiveRoom.category.ilike(term)))

        total = int(
            db.scalar(select(func.count()).select_from(LiveRoom).where(*conditions)) or 0
        )
        rows = list(
            db.scalars(
                select(LiveRoom)
                .options(joinedload(LiveRoom.host))
                .where(*conditions)
                .order_by(LiveRoom.viewer_count.desc(), LiveRoom.created_at.desc())
                .offset((page - 1) * page_size)
                .limit(page_size)
            ).all()
        )
        return LiveRoomListResponse(
            rooms=[self._serialize_room(r) for r in rows],
            total=total,
            page=page,
            pageSize=page_size,
            hasMore=(page * page_size) < total,
        )

    def get_room(self, db: Session, room_id: str) -> LiveRoomResponse:
        room = db.scalar(
            select(LiveRoom).options(joinedload(LiveRoom.host)).where(LiveRoom.id == room_id)
        )
        if not room:
            raise NotFoundError("Live room not found")
        return self._serialize_room(room)

    def handle_rtmp_webhook(
        self,
        db: Session,
        action: str,
        room_key: str,
        stream_key: str,
        provided_secret: str,
    ) -> LiveRoomResponse:
        settings = get_settings()
        expected_secret = settings.rtmp_webhook_secret.strip()
        if not expected_secret or not hmac.compare_digest(provided_secret, expected_secret):
            raise UnauthorizedError("Invalid RTMP webhook secret")

        room = db.scalar(
            select(LiveRoom).options(joinedload(LiveRoom.host)).where(LiveRoom.room_key == room_key)
        )
        if not room:
            raise NotFoundError("Live room not found")
        if not verify_secret_value(stream_key, room.stream_key_hash):
            raise UnauthorizedError("Invalid stream key")

        if action == "on_publish":
            return self.start_room(db, room.host, room.id)
        return self.end_room(db, room.host, room.id)

    @staticmethod
    def _require_host_room(db: Session, host: User, room_id: str) -> LiveRoom:
        room = db.scalar(
            select(LiveRoom).options(joinedload(LiveRoom.host)).where(LiveRoom.id == room_id)
        )
        if not room:
            raise NotFoundError("Live room not found")
        if room.host_id != host.id:
            raise ForbiddenError("Only the room host may manage this live stream")
        return room


live_gateway_service = LiveGatewayService()
