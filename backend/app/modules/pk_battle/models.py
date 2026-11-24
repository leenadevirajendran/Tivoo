from __future__ import annotations
from typing import Optional
import uuid
from datetime import datetime

from sqlalchemy import BigInteger, Boolean, DateTime, ForeignKey, Index, Integer, String
from sqlalchemy.orm import Mapped, mapped_column, relationship

from app.core.security import utc_now
from app.db.session import Base
from app.models.user import MYSQL_TABLE_ARGS


class PkQueueEntry(Base):
    __tablename__ = "pk_queue_entries"
    __table_args__ = (
        Index("ix_pk_queue_status_created", "status", "created_at"),
        MYSQL_TABLE_ARGS,
    )

    id: Mapped[str] = mapped_column(String(36), primary_key=True, default=lambda: str(uuid.uuid4()))
    host_id: Mapped[str] = mapped_column(
        String(36), ForeignKey("users.id", ondelete="CASCADE"), unique=True, nullable=False
    )
    room_id: Mapped[Optional[str]] = mapped_column(
        String(36), ForeignKey("live_rooms.id", ondelete="SET NULL"), nullable=True
    )
    preferred_duration_seconds: Mapped[int] = mapped_column(Integer, default=300, nullable=False)
    status: Mapped[str] = mapped_column(String(20), default="waiting", nullable=False)  # waiting | matched | cancelled
    matched_battle_id: Mapped[Optional[str]] = mapped_column(String(36), nullable=True)
    updated_at: Mapped[datetime] = mapped_column(DateTime, default=utc_now, onupdate=utc_now, nullable=False)
    created_at: Mapped[datetime] = mapped_column(DateTime, default=utc_now, nullable=False)

    host = relationship("User")


class PkBattle(Base):
    __tablename__ = "pk_battles"
    __table_args__ = (
        Index("ix_pk_battles_status_created", "status", "created_at"),
        Index("ix_pk_battles_hosts", "host_a_id", "host_b_id"),
        MYSQL_TABLE_ARGS,
    )

    id: Mapped[str] = mapped_column(String(36), primary_key=True, default=lambda: str(uuid.uuid4()))
    host_a_id: Mapped[str] = mapped_column(
        String(36), ForeignKey("users.id", ondelete="CASCADE"), nullable=False, index=True
    )
    host_b_id: Mapped[str] = mapped_column(
        String(36), ForeignKey("users.id", ondelete="CASCADE"), nullable=False, index=True
    )
    room_a_id: Mapped[Optional[str]] = mapped_column(
        String(36), ForeignKey("live_rooms.id", ondelete="SET NULL"), nullable=True
    )
    room_b_id: Mapped[Optional[str]] = mapped_column(
        String(36), ForeignKey("live_rooms.id", ondelete="SET NULL"), nullable=True
    )

    status: Mapped[str] = mapped_column(String(20), default="pending", nullable=False)  # pending | active | ended | declined
    duration_seconds: Mapped[int] = mapped_column(Integer, default=300, nullable=False)
    host_a_score: Mapped[int] = mapped_column(BigInteger, default=0, nullable=False)
    host_b_score: Mapped[int] = mapped_column(BigInteger, default=0, nullable=False)

    winner_id: Mapped[Optional[str]] = mapped_column(
        String(36), ForeignKey("users.id", ondelete="SET NULL"), nullable=True
    )
    is_draw: Mapped[bool] = mapped_column(Boolean, default=False, nullable=False)

    started_at: Mapped[Optional[datetime]] = mapped_column(DateTime, nullable=True)
    ends_at: Mapped[Optional[datetime]] = mapped_column(DateTime, nullable=True)
    ended_at: Mapped[Optional[datetime]] = mapped_column(DateTime, nullable=True)
    created_at: Mapped[datetime] = mapped_column(DateTime, default=utc_now, nullable=False)

    host_a = relationship("User", foreign_keys=[host_a_id])
    host_b = relationship("User", foreign_keys=[host_b_id])
    room_a = relationship("LiveRoom", foreign_keys=[room_a_id])
    room_b = relationship("LiveRoom", foreign_keys=[room_b_id])


class PkScoreEvent(Base):
    __tablename__ = "pk_score_events"
    __table_args__ = (
        Index("ix_pk_score_events_battle_created", "battle_id", "created_at"),
        MYSQL_TABLE_ARGS,
    )

    id: Mapped[str] = mapped_column(String(36), primary_key=True, default=lambda: str(uuid.uuid4()))
    battle_id: Mapped[str] = mapped_column(
        String(36), ForeignKey("pk_battles.id", ondelete="CASCADE"), nullable=False, index=True
    )
    target_host_id: Mapped[str] = mapped_column(
        String(36), ForeignKey("users.id", ondelete="CASCADE"), nullable=False
    )
    sender_id: Mapped[str] = mapped_column(
        String(36), ForeignKey("users.id", ondelete="CASCADE"), nullable=False
    )
    gift_transaction_id: Mapped[Optional[str]] = mapped_column(String(36), nullable=True)
    points_added: Mapped[int] = mapped_column(BigInteger, nullable=False)
    host_a_score_after: Mapped[int] = mapped_column(BigInteger, nullable=False)
    host_b_score_after: Mapped[int] = mapped_column(BigInteger, nullable=False)
    created_at: Mapped[datetime] = mapped_column(DateTime, default=utc_now, nullable=False)
