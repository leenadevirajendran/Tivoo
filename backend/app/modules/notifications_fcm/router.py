from __future__ import annotations
from fastapi import APIRouter, Depends, Query
from sqlalchemy.orm import Session

from app.core.security import get_current_user
from app.db.session import get_db
from app.models.user import User
from app.modules.notifications_fcm.schemas import (
    DeviceTokenResponse,
    MarkNotificationsReadResponse,
    NotificationListResponse,
    RegisterDeviceRequest,
    UnregisterDeviceRequest,
)
from app.modules.notifications_fcm.service import notification_service

router = APIRouter(prefix="/api/notifications", tags=["Push Notifications (FCM)"])


@router.post("/devices", response_model=DeviceTokenResponse)
def register_device_token(
    payload: RegisterDeviceRequest,
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db),
) -> DeviceTokenResponse:
    """Register or refresh an FCM device push token for Android, iOS, or Web."""
    return notification_service.register_device(db, current_user, payload)


@router.delete("/devices")
def unregister_device_token(
    payload: UnregisterDeviceRequest,
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db),
) -> dict[str, str]:
    """Deactivate a device push token (e.g. on logout)."""
    return notification_service.unregister_device(db, current_user, payload.fcmToken)


@router.get("", response_model=NotificationListResponse)
def list_my_notifications(
    page: int = Query(default=1, ge=1),
    page_size: int = Query(default=20, ge=1, le=50),
    unread_only: bool = Query(default=False),
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db),
) -> NotificationListResponse:
    """List push notifications persisted for the signed-in user in MySQL."""
    return notification_service.list_notifications(
        db=db,
        user=current_user,
        page=page,
        page_size=page_size,
        unread_only=unread_only,
    )


@router.post("/{notification_id}/read", response_model=MarkNotificationsReadResponse)
def mark_notification_read(
    notification_id: str,
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db),
) -> MarkNotificationsReadResponse:
    """Mark one notification as read."""
    return notification_service.mark_read(db, current_user, notification_id=notification_id)


@router.post("/read-all", response_model=MarkNotificationsReadResponse)
def mark_all_notifications_read(
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db),
) -> MarkNotificationsReadResponse:
    """Mark every unread notification as read."""
    return notification_service.mark_read(db, current_user, notification_id=None)
