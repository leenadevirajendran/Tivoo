from __future__ import annotations
from typing import Optional
import uuid
from datetime import datetime

from sqlalchemy import JSON, Boolean, DateTime, ForeignKey, Index, String, Text
from sqlalchemy.orm import Mapped, mapped_column

from app.core.security import utc_now
from app.db.session import Base
from app.models.user import MYSQL_TABLE_ARGS


class DevicePushToken(Base):
    __tablename__ = "device_push_tokens"
    __table_args__ = (
        Index("ix_device_tokens_user_active", "user_id", "is_active"),
        MYSQL_TABLE_ARGS,
    )

    id: Mapped[str] = mapped_column(String(36), primary_key=True, default=lambda: str(uuid.uuid4()))
    user_id: Mapped[str] = mapped_column(
        String(36), ForeignKey("users.id", ondelete="CASCADE"), nullable=False, index=True
    )
    platform: Mapped[str] = mapped_column(String(16), nullable=False)  # android | ios | web
    fcm_token: Mapped[str] = mapped_column(String(512), unique=True, nullable=False)
    device_id: Mapped[str] = mapped_column(String(128), default="", nullable=False)
    is_active: Mapped[bool] = mapped_column(Boolean, default=True, nullable=False)
    last_seen_at: Mapped[datetime] = mapped_column(DateTime, default=utc_now, nullable=False)
    created_at: Mapped[datetime] = mapped_column(DateTime, default=utc_now, nullable=False)


class PushNotification(Base):
    __tablename__ = "push_notifications"
    __table_args__ = (
        Index("ix_push_notifications_user_read_created", "user_id", "is_read", "created_at"),
        MYSQL_TABLE_ARGS,
    )

    id: Mapped[str] = mapped_column(String(36), primary_key=True, default=lambda: str(uuid.uuid4()))
    user_id: Mapped[str] = mapped_column(
        String(36), ForeignKey("users.id", ondelete="CASCADE"), nullable=False, index=True
    )
    actor_id: Mapped[Optional[str]] = mapped_column(
        String(36), ForeignKey("users.id", ondelete="SET NULL"), nullable=True
    )
    notification_type: Mapped[str] = mapped_column(String(40), nullable=False)
    title: Mapped[str] = mapped_column(String(160), nullable=False)
    body: Mapped[str] = mapped_column(String(500), nullable=False)
    data_payload: Mapped[dict[str, str]] = mapped_column(JSON, default=dict, nullable=False)
    fcm_status: Mapped[str] = mapped_column(String(32), default="pending", nullable=False)
    fcm_error: Mapped[Optional[str]] = mapped_column(Text, nullable=True)
    is_read: Mapped[bool] = mapped_column(Boolean, default=False, nullable=False)
    read_at: Mapped[Optional[datetime]] = mapped_column(DateTime, nullable=True)
    created_at: Mapped[datetime] = mapped_column(DateTime, default=utc_now, nullable=False)
