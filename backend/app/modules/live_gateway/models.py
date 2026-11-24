from __future__ import annotations
from typing import Optional
import uuid
from datetime import datetime

from sqlalchemy import Boolean, DateTime, ForeignKey, Index, Integer, String, UniqueConstraint
from sqlalchemy.orm import Mapped, mapped_column, relationship

from app.core.security import utc_now
from app.db.session import Base
from app.models.user import MYSQL_TABLE_ARGS


class LiveRoom(Base):
    __tablename__ = "live_rooms"
    __table_args__ = (
        Index("ix_live_rooms_status_created", "status", "created_at"),
        Index("ix_live_rooms_host_status", "host_id", "status"),
        MYSQL_TABLE_ARGS,
    )

    id: Mapped[str] = mapped_column(String(36), primary_key=True, default=lambda: str(uuid.uuid4()))
    host_id: Mapped[str] = mapped_column(
        String(36), ForeignKey("users.id", ondelete="CASCADE"), nullable=False, index=True
    )
    room_key: Mapped[str] = mapped_column(String(64), unique=True, nullable=False, index=True)
    title: Mapped[str] = mapped_column(String(180), nullable=False)
    category: Mapped[str] = mapped_column(String(60), default="Entertainment", nullable=False)
    cover_url: Mapped[str] = mapped_column(String(512), default="", nullable=False)
    provider: Mapped[str] = mapped_column(String(20), default="livekit", nullable=False)  # livekit | agora | rtmp
    status: Mapped[str] = mapped_column(String(20), default="scheduled", nullable=False)  # scheduled | live | ended

    stream_key_hash: Mapped[str] = mapped_column(String(128), nullable=False)
    stream_key_masked: Mapped[str] = mapped_column(String(32), nullable=False)
    rtmp_ingest_url: Mapped[str] = mapped_column(String(512), nullable=False)
    playback_hls_url: Mapped[str] = mapped_column(String(512), nullable=False)

    allow_chat: Mapped[bool] = mapped_column(Boolean, default=True, nullable=False)
    allow_gifts: Mapped[bool] = mapped_column(Boolean, default=True, nullable=False)
    allow_pk: Mapped[bool] = mapped_column(Boolean, default=True, nullable=False)

    viewer_count: Mapped[int] = mapped_column(Integer, default=0, nullable=False)
    peak_viewers: Mapped[int] = mapped_column(Integer, default=0, nullable=False)
    likes_count: Mapped[int] = mapped_column(Integer, default=0, nullable=False)
    total_gifts_diamonds: Mapped[int] = mapped_column(Integer, default=0, nullable=False)

    started_at: Mapped[Optional[datetime]] = mapped_column(DateTime, nullable=True)
    ended_at: Mapped[Optional[datetime]] = mapped_column(DateTime, nullable=True)
    created_at: Mapped[datetime] = mapped_column(DateTime, default=utc_now, nullable=False)

    host = relationship("User")


class LiveParticipant(Base):
    __tablename__ = "live_participants"
    __table_args__ = (
        UniqueConstraint("room_id", "user_id", name="uq_live_participant"),
        Index("ix_live_participants_room_active", "room_id", "is_active"),
        MYSQL_TABLE_ARGS,
    )

    id: Mapped[str] = mapped_column(String(36), primary_key=True, default=lambda: str(uuid.uuid4()))
    room_id: Mapped[str] = mapped_column(
        String(36), ForeignKey("live_rooms.id", ondelete="CASCADE"), nullable=False, index=True
    )
    user_id: Mapped[str] = mapped_column(
        String(36), ForeignKey("users.id", ondelete="CASCADE"), nullable=False, index=True
    )
    role: Mapped[str] = mapped_column(String(20), default="viewer", nullable=False)  # host | cohost | viewer
    is_active: Mapped[bool] = mapped_column(Boolean, default=True, nullable=False)
    joined_at: Mapped[datetime] = mapped_column(DateTime, default=utc_now, nullable=False)
    last_heartbeat_at: Mapped[datetime] = mapped_column(DateTime, default=utc_now, nullable=False)
    left_at: Mapped[Optional[datetime]] = mapped_column(DateTime, nullable=True)
