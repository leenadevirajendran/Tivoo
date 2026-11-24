from __future__ import annotations
from typing import Optional
import uuid
from datetime import datetime

from sqlalchemy import (
    JSON,
    BigInteger,
    Boolean,
    DateTime,
    ForeignKey,
    Index,
    Integer,
    String,
    Text,
    UniqueConstraint,
)
from sqlalchemy.orm import Mapped, mapped_column, relationship

from app.core.security import utc_now
from app.db.session import Base

MYSQL_TABLE_ARGS = {
    "mysql_engine": "InnoDB",
    "mysql_charset": "utf8mb4",
    "mysql_collate": "utf8mb4_unicode_ci",
}


class User(Base):
    __tablename__ = "users"
    __table_args__ = (
        Index("ix_users_username_lower", "username"),
        MYSQL_TABLE_ARGS,
    )

    id: Mapped[str] = mapped_column(String(36), primary_key=True, default=lambda: str(uuid.uuid4()))
    name: Mapped[str] = mapped_column(String(100), nullable=False)
    username: Mapped[str] = mapped_column(String(50), unique=True, nullable=False, index=True)
    email: Mapped[Optional[str]] = mapped_column(String(255), unique=True, nullable=True, index=True)
    phone_number: Mapped[Optional[str]] = mapped_column(String(30), unique=True, nullable=True, index=True)
    password_hash: Mapped[Optional[str]] = mapped_column(String(255), nullable=True)

    bio: Mapped[str] = mapped_column(String(300), default="", nullable=False)
    about_me: Mapped[str] = mapped_column(Text, default="", nullable=False)
    avatar_url: Mapped[str] = mapped_column(String(512), default="", nullable=False)
    cover_background_url: Mapped[str] = mapped_column(String(512), default="", nullable=False)
    roles: Mapped[list[str]] = mapped_column(JSON, default=lambda: ["Creator"], nullable=False)

    is_verified: Mapped[bool] = mapped_column(Boolean, default=False, nullable=False)
    is_email_verified: Mapped[bool] = mapped_column(Boolean, default=False, nullable=False)
    is_phone_verified: Mapped[bool] = mapped_column(Boolean, default=False, nullable=False)
    is_private: Mapped[bool] = mapped_column(Boolean, default=False, nullable=False)
    is_online: Mapped[bool] = mapped_column(Boolean, default=True, nullable=False)
    is_active: Mapped[bool] = mapped_column(Boolean, default=True, nullable=False)

    following_count: Mapped[int] = mapped_column(Integer, default=0, nullable=False)
    followers_count: Mapped[int] = mapped_column(Integer, default=0, nullable=False)
    likes_count: Mapped[int] = mapped_column(Integer, default=0, nullable=False)
    live_streams_count: Mapped[int] = mapped_column(Integer, default=0, nullable=False)
    total_views: Mapped[int] = mapped_column(BigInteger, default=0, nullable=False)

    last_login_at: Mapped[Optional[datetime]] = mapped_column(DateTime, nullable=True)
    created_at: Mapped[datetime] = mapped_column(DateTime, default=utc_now, nullable=False)
    updated_at: Mapped[datetime] = mapped_column(DateTime, default=utc_now, onupdate=utc_now, nullable=False)

    videos = relationship("Video", back_populates="author", cascade="all, delete-orphan")


class OTPCode(Base):
    __tablename__ = "otp_codes"
    __table_args__ = (
        Index("ix_otp_target_channel", "target", "channel", "purpose"),
        MYSQL_TABLE_ARGS,
    )

    id: Mapped[str] = mapped_column(String(36), primary_key=True, default=lambda: str(uuid.uuid4()))
    user_id: Mapped[Optional[str]] = mapped_column(
        String(36), ForeignKey("users.id", ondelete="CASCADE"), nullable=True
    )
    channel: Mapped[str] = mapped_column(String(16), nullable=False)  # 'email' | 'phone'
    target: Mapped[str] = mapped_column(String(255), nullable=False, index=True)
    purpose: Mapped[str] = mapped_column(String(32), nullable=False)  # 'login' | 'verify_email' | 'verify_phone' | 'reset_password'
    code_hash: Mapped[str] = mapped_column(String(128), nullable=False)
    attempts: Mapped[int] = mapped_column(Integer, default=0, nullable=False)
    max_attempts: Mapped[int] = mapped_column(Integer, default=5, nullable=False)
    is_used: Mapped[bool] = mapped_column(Boolean, default=False, nullable=False)
    expires_at: Mapped[datetime] = mapped_column(DateTime, nullable=False, index=True)
    created_at: Mapped[datetime] = mapped_column(DateTime, default=utc_now, nullable=False)


class RefreshToken(Base):
    __tablename__ = "refresh_tokens"
    __table_args__ = (MYSQL_TABLE_ARGS,)

    id: Mapped[str] = mapped_column(String(36), primary_key=True)
    user_id: Mapped[str] = mapped_column(
        String(36), ForeignKey("users.id", ondelete="CASCADE"), nullable=False, index=True
    )
    token_hash: Mapped[str] = mapped_column(String(128), unique=True, nullable=False)
    device_info: Mapped[str] = mapped_column(String(255), default="", nullable=False)
    is_revoked: Mapped[bool] = mapped_column(Boolean, default=False, nullable=False)
    expires_at: Mapped[datetime] = mapped_column(DateTime, nullable=False, index=True)
    created_at: Mapped[datetime] = mapped_column(DateTime, default=utc_now, nullable=False)


class Follow(Base):
    __tablename__ = "follows"
    __table_args__ = (
        UniqueConstraint("follower_id", "following_id", name="uq_follow_pair"),
        Index("ix_follows_following_status", "following_id", "status"),
        MYSQL_TABLE_ARGS,
    )

    id: Mapped[str] = mapped_column(String(36), primary_key=True, default=lambda: str(uuid.uuid4()))
    follower_id: Mapped[str] = mapped_column(
        String(36), ForeignKey("users.id", ondelete="CASCADE"), nullable=False, index=True
    )
    following_id: Mapped[str] = mapped_column(
        String(36), ForeignKey("users.id", ondelete="CASCADE"), nullable=False, index=True
    )
    status: Mapped[str] = mapped_column(
        String(20), default="following", nullable=False
    )  # 'requested' | 'following' | 'blocked'
    is_close_friend: Mapped[bool] = mapped_column(Boolean, default=False, nullable=False)
    is_muted: Mapped[bool] = mapped_column(Boolean, default=False, nullable=False)
    requested_at: Mapped[Optional[datetime]] = mapped_column(DateTime, nullable=True)
    followed_at: Mapped[Optional[datetime]] = mapped_column(DateTime, nullable=True)
    created_at: Mapped[datetime] = mapped_column(DateTime, default=utc_now, nullable=False)

