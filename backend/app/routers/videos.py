from __future__ import annotations
from typing import Literal

from fastapi import APIRouter, Depends, File, Form, Query, UploadFile, status
from sqlalchemy import select
from sqlalchemy.orm import Session

from app.core.security import get_current_user, get_optional_current_user
from app.db.session import get_db
from app.models.user import User
from app.schemas.video import (
    CommentCreateRequest,
    CommentListResponse,
    CommentResponse,
    FeedListResponse,
    LikeToggleResponse,
    VideoPostResponse,
)
from app.services.feed_service import feed_service

router = APIRouter(prefix="/api/videos", tags=["Videos & Reels"])
feed_router = APIRouter(prefix="/api/feed", tags=["Algorithmic Feed"])
comments_router = APIRouter(prefix="/api/comments", tags=["Comments"])


@router.get("", response_model=FeedListResponse)
def list_videos(
    feed_type: Literal["for_you", "following"] = Query(default="for_you"),
    page: int = Query(default=1, ge=1),
    page_size: int = Query(default=20, ge=1, le=50),
    category: str | None = Query(default=None, max_length=60),
    q: str | None = Query(default=None, max_length=100),
    author_id: str | None = Query(default=None, max_length=36),
    viewer: User | None = Depends(get_optional_current_user),
    db: Session = Depends(get_db),
) -> FeedListResponse:
    """List public or permitted reels directly from MySQL with algorithmic ranking."""
    return feed_service.get_feed(
        db=db,
        viewer=viewer,
        feed_type=feed_type,
        page=page,
        page_size=page_size,
        category=category,
        query_text=q,
        author_id=author_id,
    )


@router.post("", response_model=VideoPostResponse, status_code=status.HTTP_201_CREATED)
def upload_video(
    video: UploadFile = File(...),
    thumbnail: UploadFile | None = File(default=None),
    caption: str = Form(default="", max_length=2000),
    category: str = Form(default="Entertainment", max_length=60),
    audience: str = Form(default="Public", max_length=20),
    allow_comments: bool = Form(default=True),
    allow_downloads: bool = Form(default=True),
    allow_share: bool = Form(default=True),
    location: str | None = Form(default=None, max_length=120),
    music_title: str | None = Form(default=None, max_length=160),
    snap_lens_name: str | None = Form(default=None, max_length=120),
    author_id: str | None = Form(default=None, max_length=36),
    author_name: str | None = Form(default=None, max_length=100),
    author_username: str | None = Form(default=None, max_length=50),
    author_avatar: str | None = Form(default=None, max_length=512),
    current_user: User | None = Depends(get_optional_current_user),
    db: Session = Depends(get_db),
) -> VideoPostResponse:
    """Upload a recorded reel to configured storage and enqueue FFmpeg H.264/HLS transcoding."""
    author = current_user
    if not author and author_id:
        author = db.get(User, author_id)
    if not author and author_username:
        clean_uname = author_username.strip().replace("@", "")
        author = db.scalars(select(User).where(User.username == clean_uname)).first()
    if not author and author_name:
        author = db.scalars(select(User).where(User.name == author_name.strip())).first()
    if not author:
        import uuid
        clean_uname = author_username.strip().replace("@", "") if author_username else f"user_{uuid.uuid4().hex[:4]}"
        author = User(
            id=author_id or str(uuid.uuid4()),
            name=author_name.strip() if author_name else "Tivoo Creator",
            username=clean_uname,
            email=f"{clean_uname}@tivoo.live",
            avatar_url=author_avatar or "",
        )
        db.add(author)
        db.commit()
        db.refresh(author)
    return feed_service.upload_video(
        db=db,
        author=author,
        video_file=video,
        thumbnail_file=thumbnail,
        caption=caption,
        category=category,
        audience=audience,
        allow_comments=allow_comments,
        allow_downloads=allow_downloads,
        allow_share=allow_share,
        location=location,
        music_title=music_title,
        snap_lens_name=snap_lens_name,
    )


@router.get("/{video_id}", response_model=VideoPostResponse)
def get_video(
    video_id: str,
    viewer: User | None = Depends(get_optional_current_user),
    db: Session = Depends(get_db),
) -> VideoPostResponse:
    """Retrieve a single reel including current H.264/HLS transcoding status."""
    return feed_service.get_video_by_id(db, video_id, viewer)


@router.delete("/{video_id}")
def delete_video(
    video_id: str,
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db),
) -> dict[str, str]:
    """Delete a reel owned by the authenticated user from storage and MySQL."""
    return feed_service.delete_video(db, current_user, video_id)


@router.post("/{video_id}/like", response_model=LikeToggleResponse)
def toggle_video_like(
    video_id: str,
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db),
) -> LikeToggleResponse:
    """Toggle like state for a reel and persist updated counts in MySQL."""
    return feed_service.toggle_like(db, current_user, video_id)


@router.post("/{video_id}/view")
def record_video_view(
    video_id: str,
    db: Session = Depends(get_db),
) -> dict[str, int | str]:
    """Increment reel view counter in MySQL."""
    return feed_service.record_view(db, video_id)


@router.get("/{video_id}/comments", response_model=CommentListResponse)
def list_video_comments(
    video_id: str,
    viewer: User | None = Depends(get_optional_current_user),
    db: Session = Depends(get_db),
) -> CommentListResponse:
    """List persisted comments for a reel ordered newest-first."""
    return feed_service.list_comments(db, video_id, viewer)


@router.post(
    "/{video_id}/comments",
    response_model=CommentResponse,
    status_code=status.HTTP_201_CREATED,
)
def add_video_comment(
    video_id: str,
    payload: CommentCreateRequest,
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db),
) -> CommentResponse:
    """Create a comment or reply on a reel."""
    return feed_service.add_comment(db, current_user, video_id, payload)


@feed_router.get("/for-you", response_model=FeedListResponse)
def get_for_you_feed(
    page: int = Query(default=1, ge=1),
    page_size: int = Query(default=20, ge=1, le=50),
    category: str | None = Query(default=None, max_length=60),
    q: str | None = Query(default=None, max_length=100),
    viewer: User | None = Depends(get_optional_current_user),
    db: Session = Depends(get_db),
) -> FeedListResponse:
    """Algorithmically ranked For You feed scored by engagement, recency, and creator affinity."""
    return feed_service.get_feed(
        db=db,
        viewer=viewer,
        feed_type="for_you",
        page=page,
        page_size=page_size,
        category=category,
        query_text=q,
    )


@feed_router.get("/following", response_model=FeedListResponse)
def get_following_feed(
    page: int = Query(default=1, ge=1),
    page_size: int = Query(default=20, ge=1, le=50),
    category: str | None = Query(default=None, max_length=60),
    q: str | None = Query(default=None, max_length=100),
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db),
) -> FeedListResponse:
    """Chronological feed of reels from creators followed by the authenticated user."""
    return feed_service.get_feed(
        db=db,
        viewer=current_user,
        feed_type="following",
        page=page,
        page_size=page_size,
        category=category,
        query_text=q,
    )


@comments_router.delete("/{comment_id}")
def delete_comment(
    comment_id: str,
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db),
) -> dict[str, str]:
    """Delete a comment authored by the current user or the reel owner."""
    return feed_service.delete_comment(db, current_user, comment_id)


@comments_router.post("/{comment_id}/like")
def toggle_comment_like(
    comment_id: str,
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db),
) -> dict[str, object]:
    """Toggle like state on a comment."""
    return feed_service.toggle_comment_like(db, current_user, comment_id)

