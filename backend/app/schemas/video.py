from __future__ import annotations
from datetime import datetime

from pydantic import BaseModel, Field


class VideoPostResponse(BaseModel):
    """Unified Reel JSON compatible with Flutter VideoPost.fromJson and adaptive HLS clients."""

    id: str
    authorId: str
    authorName: str
    authorUsername: str
    authorAvatar: str = ""
    authorVerified: bool = False

    videoUrl: str
    hlsUrl: str | None = None
    thumbnailUrl: str | None = None

    caption: str = ""
    category: str = "Entertainment"
    hashtags: list[str] = Field(default_factory=list)
    audience: str = "Public"
    allowComments: bool = True
    allowDownloads: bool = True
    allowShare: bool = True
    location: str | None = None
    musicTitle: str | None = None
    snapLensName: str | None = None

    durationSeconds: float = 0.0
    width: int = 0
    height: int = 0
    fileSizeBytes: int = 0
    storageBackend: str = "local"
    transcodingStatus: str = "pending"
    transcodingError: str | None = None

    likes: int = 0
    views: int = 0
    commentsCount: int = 0
    sharesCount: int = 0
    isLiked: bool = False
    isFollowingAuthor: bool = False
    algorithmScore: float = 0.0
    createdAt: datetime


class FeedListResponse(BaseModel):
    videos: list[VideoPostResponse]
    feedType: str = "for_you"
    page: int = 1
    pageSize: int = 20
    total: int = 0
    hasMore: bool = False


class LikeToggleResponse(BaseModel):
    videoId: str
    isLiked: bool
    likesCount: int


class CommentCreateRequest(BaseModel):
    text: str = Field(..., min_length=1, max_length=1000)
    parentCommentId: str | None = None


class CommentResponse(BaseModel):
    id: str
    videoId: str
    userId: str
    authorName: str
    authorFullName: str = ""
    authorAvatar: str = ""
    text: str
    createdAt: datetime
    likes: int = 0
    isLiked: bool = False
    isMine: bool = False
    parentCommentId: str | None = None


class CommentListResponse(BaseModel):
    comments: list[CommentResponse]
    total: int

