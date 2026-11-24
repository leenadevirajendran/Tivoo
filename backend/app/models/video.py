from __future__ import annotations
from typing import Optional
import uuid
from datetime import datetime

from sqlalchemy import (
    JSON,
    BigInteger,
    Boolean,
    DateTime,
    Float,
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
from app.models.user import MYSQL_TABLE_ARGS


class Video(Base):
    __tablename__ = "videos"
    __table_args__ = (
        Index("ix_videos_feed_sort", "transcoding_status", "audience", "created_at"),
        MYSQL_TABLE_ARGS,
    )

    id: Mapped[str] = mapped_column(String(36), primary_key=True, default=lambda: str(uuid.uuid4()))
    author_id: Mapped[str] = mapped_column(
        String(36), ForeignKey("users.id", ondelete="CASCADE"), nullable=False, index=True
    )
    caption: Mapped[str] = mapped_column(Text, default="", nullable=False)
    category: Mapped[str] = mapped_column(String(64), default="Entertainment", nullable=False, index=True)
    hashtags: Mapped[list[str]] = mapped_column(JSON, default=list, nullable=False)
    audience: Mapped[str] = mapped_column(String(32), default="Public", nullable=False)

    allow_comments: Mapped[bool] = mapped_column(Boolean, default=True, nullable=False)
    allow_downloads: Mapped[bool] = mapped_column(Boolean, default=True, nullable=False)
    allow_share: Mapped[bool] = mapped_column(Boolean, default=True, nullable=False)
    location: Mapped[Optional[str]] = mapped_column(String(150), nullable=True)
    music_title: Mapped[Optional[str]] = mapped_column(String(150), nullable=True)
    snap_lens_name: Mapped[Optional[str]] = mapped_column(String(100), nullable=True)

    storage_backend: Mapped[str] = mapped_column(String(20), default="local", nullable=False)
    raw_storage_key: Mapped[str] = mapped_column(String(512), default="", nullable=False)
    video_storage_key: Mapped[str] = mapped_column(String(512), default="", nullable=False)
    hls_storage_prefix: Mapped[str] = mapped_column(String(512), default="", nullable=False)
    thumbnail_storage_key: Mapped[str] = mapped_column(String(512), default="", nullable=False)

    video_url: Mapped[str] = mapped_column(String(700), nullable=False)
    hls_url: Mapped[Optional[str]] = mapped_column(String(700), nullable=True)
    thumbnail_url: Mapped[Optional[str]] = mapped_column(String(700), nullable=True)

    duration_seconds: Mapped[float] = mapped_column(Float, default=0.0, nullable=False)
    width: Mapped[int] = mapped_column(Integer, default=0, nullable=False)
    height: Mapped[int] = mapped_column(Integer, default=0, nullable=False)
    file_size_bytes: Mapped[int] = mapped_column(BigInteger, default=0, nullable=False)

    transcoding_status: Mapped[str] = mapped_column(
        String(24), default="pending", nullable=False, index=True
    )  # 'pending' | 'processing' | 'ready' | 'failed'
    transcoding_error: Mapped[Optional[str]] = mapped_column(Text, nullable=True)

    likes_count: Mapped[int] = mapped_column(Integer, default=0, nullable=False)
    comments_count: Mapped[int] = mapped_column(Integer, default=0, nullable=False)
    views_count: Mapped[int] = mapped_column(Integer, default=0, nullable=False)
    shares_count: Mapped[int] = mapped_column(Integer, default=0, nullable=False)

    created_at: Mapped[datetime] = mapped_column(DateTime, default=utc_now, nullable=False, index=True)
    updated_at: Mapped[datetime] = mapped_column(DateTime, default=utc_now, onupdate=utc_now, nullable=False)

    author = relationship("User", back_populates="videos")
    likes = relationship("VideoLike", back_populates="video", cascade="all, delete-orphan")
    comments = relationship("VideoComment", back_populates="video", cascade="all, delete-orphan")


class VideoLike(Base):
    __tablename__ = "video_likes"
    __table_args__ = (
        UniqueConstraint("video_id", "user_id", name="uq_video_like"),
        MYSQL_TABLE_ARGS,
    )

    id: Mapped[str] = mapped_column(String(36), primary_key=True, default=lambda: str(uuid.uuid4()))
    video_id: Mapped[str] = mapped_column(
        String(36), ForeignKey("videos.id", ondelete="CASCADE"), nullable=False, index=True
    )
    user_id: Mapped[str] = mapped_column(
        String(36), ForeignKey("users.id", ondelete="CASCADE"), nullable=False, index=True
    )
    created_at: Mapped[datetime] = mapped_column(DateTime, default=utc_now, nullable=False)

    video = relationship("Video", back_populates="likes")


class VideoComment(Base):
    __tablename__ = "video_comments"
    __table_args__ = (
        Index("ix_video_comments_video_created", "video_id", "created_at"),
        MYSQL_TABLE_ARGS,
    )

    id: Mapped[str] = mapped_column(String(36), primary_key=True, default=lambda: str(uuid.uuid4()))
    video_id: Mapped[str] = mapped_column(
        String(36), ForeignKey("videos.id", ondelete="CASCADE"), nullable=False, index=True
    )
    user_id: Mapped[str] = mapped_column(
        String(36), ForeignKey("users.id", ondelete="CASCADE"), nullable=False, index=True
    )
    parent_comment_id: Mapped[Optional[str]] = mapped_column(
        String(36), ForeignKey("video_comments.id", ondelete="CASCADE"), nullable=True
    )
    text: Mapped[str] = mapped_column(Text, nullable=False)
    likes_count: Mapped[int] = mapped_column(Integer, default=0, nullable=False)
    created_at: Mapped[datetime] = mapped_column(DateTime, default=utc_now, nullable=False)

    video = relationship("Video", back_populates="comments")
    author = relationship("User")


class CommentLike(Base):
    __tablename__ = "comment_likes"
    __table_args__ = (
        UniqueConstraint("comment_id", "user_id", name="uq_comment_like"),
        MYSQL_TABLE_ARGS,
    )

    id: Mapped[str] = mapped_column(String(36), primary_key=True, default=lambda: str(uuid.uuid4()))
    comment_id: Mapped[str] = mapped_column(
        String(36), ForeignKey("video_comments.id", ondelete="CASCADE"), nullable=False, index=True
    )
    user_id: Mapped[str] = mapped_column(
        String(36), ForeignKey("users.id", ondelete="CASCADE"), nullable=False, index=True
    )
    created_at: Mapped[datetime] = mapped_column(DateTime, default=utc_now, nullable=False)

