from __future__ import annotations
from typing import Optional
import uuid
from datetime import datetime

from sqlalchemy import (
    Boolean,
    DateTime,
    ForeignKey,
    Index,
    String,
    Text,
    UniqueConstraint,
)
from sqlalchemy.orm import Mapped, mapped_column, relationship

from app.core.security import utc_now
from app.db.session import Base
from app.models.user import MYSQL_TABLE_ARGS


class LiveChatMessage(Base):
    __tablename__ = "live_chat_messages"
    __table_args__ = (
        Index("ix_live_chat_room_created", "room_id", "created_at"),
        MYSQL_TABLE_ARGS,
    )

    id: Mapped[str] = mapped_column(String(36), primary_key=True, default=lambda: str(uuid.uuid4()))
    room_id: Mapped[str] = mapped_column(
        String(36), ForeignKey("live_rooms.id", ondelete="CASCADE"), nullable=False, index=True
    )
    sender_id: Mapped[str] = mapped_column(
        String(36), ForeignKey("users.id", ondelete="CASCADE"), nullable=False, index=True
    )
    message_type: Mapped[str] = mapped_column(
        String(20), default="chat", nullable=False
    )  # chat | barrage | system | heart
    content: Mapped[str] = mapped_column(String(500), nullable=False)
    color_hex: Mapped[str] = mapped_column(String(16), default="#FFFFFF", nullable=False)
    is_pinned: Mapped[bool] = mapped_column(Boolean, default=False, nullable=False)
    created_at: Mapped[datetime] = mapped_column(DateTime, default=utc_now, nullable=False)

    sender = relationship("User")


class DmConversation(Base):
    __tablename__ = "dm_conversations"
    __table_args__ = (
        UniqueConstraint("participant_a_id", "participant_b_id", name="uq_dm_participant_pair"),
        Index("ix_dm_conv_last_msg", "last_message_at"),
        MYSQL_TABLE_ARGS,
    )

    id: Mapped[str] = mapped_column(String(36), primary_key=True, default=lambda: str(uuid.uuid4()))
    participant_a_id: Mapped[str] = mapped_column(
        String(36), ForeignKey("users.id", ondelete="CASCADE"), nullable=False, index=True
    )
    participant_b_id: Mapped[str] = mapped_column(
        String(36), ForeignKey("users.id", ondelete="CASCADE"), nullable=False, index=True
    )
    last_message_text: Mapped[str] = mapped_column(String(300), default="", nullable=False)
    last_message_at: Mapped[datetime] = mapped_column(DateTime, default=utc_now, nullable=False)
    created_at: Mapped[datetime] = mapped_column(DateTime, default=utc_now, nullable=False)

    participant_a = relationship("User", foreign_keys=[participant_a_id])
    participant_b = relationship("User", foreign_keys=[participant_b_id])


class DmMessage(Base):
    __tablename__ = "dm_messages"
    __table_args__ = (
        Index("ix_dm_messages_conv_created", "conversation_id", "created_at"),
        Index("ix_dm_messages_recipient_read", "recipient_id", "is_read"),
        MYSQL_TABLE_ARGS,
    )

    id: Mapped[str] = mapped_column(String(36), primary_key=True, default=lambda: str(uuid.uuid4()))
    conversation_id: Mapped[str] = mapped_column(
        String(36), ForeignKey("dm_conversations.id", ondelete="CASCADE"), nullable=False, index=True
    )
    sender_id: Mapped[str] = mapped_column(
        String(36), ForeignKey("users.id", ondelete="CASCADE"), nullable=False, index=True
    )
    recipient_id: Mapped[str] = mapped_column(
        String(36), ForeignKey("users.id", ondelete="CASCADE"), nullable=False, index=True
    )
    message_type: Mapped[str] = mapped_column(String(16), default="text", nullable=False)  # text | image | heart
    content: Mapped[str] = mapped_column(Text, nullable=False)
    media_url: Mapped[Optional[str]] = mapped_column(String(512), nullable=True)
    is_read: Mapped[bool] = mapped_column(Boolean, default=False, nullable=False)
    read_at: Mapped[Optional[datetime]] = mapped_column(DateTime, nullable=True)
    created_at: Mapped[datetime] = mapped_column(DateTime, default=utc_now, nullable=False)

    sender = relationship("User", foreign_keys=[sender_id])
