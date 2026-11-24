from __future__ import annotations
from sqlalchemy import and_, func, select, update
from sqlalchemy.orm import Session

from app.core.exceptions import NotFoundError
from app.core.security import utc_now
from app.models.user import Follow, User
from app.modules.notifications_fcm.fcm_client import fcm_client
from app.modules.notifications_fcm.models import DevicePushToken, PushNotification
from app.modules.notifications_fcm.schemas import (
    DeviceTokenResponse,
    MarkNotificationsReadResponse,
    NotificationListResponse,
    NotificationResponse,
    RegisterDeviceRequest,
)
from app.realtime.connection_manager import realtime_hub


class NotificationService:
    """Persistent notification inbox + real Firebase Cloud Messaging HTTP v1 dispatcher."""

    @staticmethod
    def _serialize(row: PushNotification) -> NotificationResponse:
        return NotificationResponse(
            id=row.id,
            userId=row.user_id,
            actorId=row.actor_id,
            notificationType=row.notification_type,
            title=row.title,
            body=row.body,
            data=row.data_payload or {},
            fcmStatus=row.fcm_status,
            fcmError=row.fcm_error,
            isRead=row.is_read,
            readAt=row.read_at,
            createdAt=row.created_at,
        )

    def register_device(
        self,
        db: Session,
        user: User,
        payload: RegisterDeviceRequest,
    ) -> DeviceTokenResponse:
        now = utc_now()
        existing = db.scalar(
            select(DevicePushToken).where(DevicePushToken.fcm_token == payload.fcmToken)
        )
        if existing:
            existing.user_id = user.id
            existing.platform = payload.platform
            existing.device_id = payload.deviceId.strip()
            existing.is_active = True
            existing.last_seen_at = now
            token_row = existing
        else:
            token_row = DevicePushToken(
                user_id=user.id,
                platform=payload.platform,
                fcm_token=payload.fcmToken.strip(),
                device_id=payload.deviceId.strip(),
                is_active=True,
                last_seen_at=now,
            )
            db.add(token_row)

        db.commit()
        db.refresh(token_row)
        return DeviceTokenResponse(
            id=token_row.id,
            userId=token_row.user_id,
            platform=token_row.platform,
            deviceId=token_row.device_id,
            isActive=token_row.is_active,
            lastSeenAt=token_row.last_seen_at,
        )

    def unregister_device(self, db: Session, user: User, fcm_token: str) -> dict[str, str]:
        row = db.scalar(
            select(DevicePushToken).where(
                and_(
                    DevicePushToken.user_id == user.id,
                    DevicePushToken.fcm_token == fcm_token.strip(),
                )
            )
        )
        if row:
            row.is_active = False
            db.commit()
        return {"message": "Device push token removed"}

    def list_notifications(
        self,
        db: Session,
        user: User,
        page: int = 1,
        page_size: int = 20,
        unread_only: bool = False,
    ) -> NotificationListResponse:
        base_filter = [PushNotification.user_id == user.id]
        if unread_only:
            base_filter.append(PushNotification.is_read.is_(False))

        total = int(
            db.scalar(select(func.count()).select_from(PushNotification).where(*base_filter)) or 0
        )
        unread_count = int(
            db.scalar(
                select(func.count())
                .select_from(PushNotification)
                .where(
                    PushNotification.user_id == user.id,
                    PushNotification.is_read.is_(False),
                )
            )
            or 0
        )

        rows = list(
            db.scalars(
                select(PushNotification)
                .where(*base_filter)
                .order_by(PushNotification.created_at.desc())
                .offset((page - 1) * page_size)
                .limit(page_size)
            ).all()
        )
        return NotificationListResponse(
            notifications=[self._serialize(row) for row in rows],
            unreadCount=unread_count,
            total=total,
            page=page,
            pageSize=page_size,
            hasMore=(page * page_size) < total,
        )

    def mark_read(
        self,
        db: Session,
        user: User,
        notification_id: str | None = None,
    ) -> MarkNotificationsReadResponse:
        now = utc_now()
        if notification_id:
            row = db.get(PushNotification, notification_id)
            if not row or row.user_id != user.id:
                raise NotFoundError("Notification not found")
            updated = 0
            if not row.is_read:
                row.is_read = True
                row.read_at = now
                updated = 1
        else:
            result = db.execute(
                update(PushNotification)
                .where(
                    PushNotification.user_id == user.id,
                    PushNotification.is_read.is_(False),
                )
                .values(is_read=True, read_at=now)
            )
            updated = int(result.rowcount or 0)

        db.commit()
        unread_count = int(
            db.scalar(
                select(func.count())
                .select_from(PushNotification)
                .where(
                    PushNotification.user_id == user.id,
                    PushNotification.is_read.is_(False),
                )
            )
            or 0
        )
        return MarkNotificationsReadResponse(updatedCount=updated, unreadCount=unread_count)

    def dispatch_notification(
        self,
        db: Session,
        recipient_id: str,
        notification_type: str,
        title: str,
        body: str,
        data: dict[str, str] | None = None,
        actor_id: str | None = None,
    ) -> NotificationResponse:
        payload_data = {str(k): str(v) for k, v in (data or {}).items()}
        payload_data.setdefault("type", notification_type)

        tokens = list(
            db.scalars(
                select(DevicePushToken.fcm_token).where(
                    and_(
                        DevicePushToken.user_id == recipient_id,
                        DevicePushToken.is_active.is_(True),
                    )
                )
            ).all()
        )

        outcome = fcm_client.send_to_tokens(
            tokens=tokens,
            title=title[:160],
            body=body[:500],
            data=payload_data,
        )
        if outcome.invalid_tokens:
            db.execute(
                update(DevicePushToken)
                .where(DevicePushToken.fcm_token.in_(outcome.invalid_tokens))
                .values(is_active=False)
            )

        record = PushNotification(
            user_id=recipient_id,
            actor_id=actor_id,
            notification_type=notification_type,
            title=title[:160],
            body=body[:500],
            data_payload=payload_data,
            fcm_status=outcome.status,
            fcm_error=outcome.error,
        )
        db.add(record)
        db.commit()
        db.refresh(record)

        serialized = self._serialize(record)
        realtime_hub.send_to_user_sync(
            recipient_id,
            "notification",
            serialized.model_dump(mode="json"),
        )
        return serialized

    def notify_followers_live_started(
        self,
        db: Session,
        host_user: User,
        room_id: str,
        room_title: str,
    ) -> int:
        follower_ids = list(
            db.scalars(
                select(Follow.follower_id).where(
                    and_(Follow.following_id == host_user.id, Follow.status == "following")
                )
            ).all()
        )
        count = 0
        for fid in follower_ids:
            self.dispatch_notification(
                db=db,
                recipient_id=fid,
                notification_type="live_started",
                title=f"{host_user.name} is LIVE now!",
                body=room_title or f"@{host_user.username} started a live stream",
                data={"roomId": room_id, "hostId": host_user.id},
                actor_id=host_user.id,
            )
            count += 1
        return count

    def notify_pk_started(
        self,
        db: Session,
        battle_id: str,
        host_a: User,
        host_b: User,
    ) -> None:
        self.dispatch_notification(
            db=db,
            recipient_id=host_b.id,
            notification_type="pk_started",
            title="PK Battle Started!",
            body=f"Your PK Battle against {host_a.name} (@{host_a.username}) is live now!",
            data={"battleId": battle_id, "opponentId": host_a.id},
            actor_id=host_a.id,
        )
        self.dispatch_notification(
            db=db,
            recipient_id=host_a.id,
            notification_type="pk_started",
            title="PK Battle Matched!",
            body=f"You are battling {host_b.name} (@{host_b.username}) right now!",
            data={"battleId": battle_id, "opponentId": host_b.id},
            actor_id=host_b.id,
        )

    def notify_dm_received(
        self,
        db: Session,
        sender: User,
        recipient_id: str,
        conversation_id: str,
        preview_text: str,
    ) -> None:
        self.dispatch_notification(
            db=db,
            recipient_id=recipient_id,
            notification_type="dm_received",
            title=sender.name,
            body=preview_text[:180] or f"@{sender.username} sent you a message",
            data={
                "conversationId": conversation_id,
                "senderId": sender.id,
                "senderUsername": sender.username,
            },
            actor_id=sender.id,
        )

    def notify_gift_received(
        self,
        db: Session,
        sender: User,
        recipient_id: str,
        gift_name: str,
        quantity: int,
        diamonds_credited: int,
        room_id: str | None = None,
    ) -> None:
        self.dispatch_notification(
            db=db,
            recipient_id=recipient_id,
            notification_type="gift_received",
            title=f"{sender.name} sent {quantity}x {gift_name}",
            body=f"You earned +{diamonds_credited} Diamonds in your creator wallet!",
            data={
                "giftName": gift_name,
                "quantity": str(quantity),
                "diamonds": str(diamonds_credited),
                "roomId": room_id or "",
            },
            actor_id=sender.id,
        )


notification_service = NotificationService()
