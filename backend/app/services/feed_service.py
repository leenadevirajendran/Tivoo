from __future__ import annotations
from pathlib import Path
import shutil
import tempfile
import uuid

from fastapi import UploadFile
from sqlalchemy import and_, or_, select
from sqlalchemy.orm import Session, joinedload

from app.core.config import get_settings
from app.core.exceptions import BadRequestError, ForbiddenError, NotFoundError
from app.core.security import utc_now
from app.models.user import Follow, User
from app.models.video import CommentLike, Video, VideoComment, VideoLike
from app.schemas.video import (
    CommentCreateRequest,
    CommentListResponse,
    CommentResponse,
    FeedListResponse,
    LikeToggleResponse,
    VideoPostResponse,
)
from app.services.storage_service import storage_service
from app.services.transcoder_service import transcoder_service
from app.utils.helpers import extract_hashtags, safe_extension

_ALLOWED_VIDEO_EXTS = {".mp4", ".mov", ".m4v", ".webm", ".mkv", ".avi", ".3gp"}


class FeedService:
    """Reels video hosting, algorithmic For You & Following feed, likes, views, and comments."""

    def _compute_algorithm_score(self, video: Video, is_following_author: bool) -> float:
        age_hours = max(0.0, (utc_now() - video.created_at).total_seconds() / 3600.0)
        engagement = (
            (video.likes_count * 3.0)
            + (video.comments_count * 4.5)
            + (video.shares_count * 5.0)
            + (video.views_count * 0.4)
            + 12.0
        )
        decay = (age_hours + 2.0) ** 1.25
        follow_boost = 1.25 if is_following_author else 1.0
        ready_boost = 1.1 if video.transcoding_status == "ready" else 0.9
        return round((engagement / decay) * follow_boost * ready_boost, 4)

    def _serialize_video(
        self,
        video: Video,
        liked_video_ids: set[str],
        followed_author_ids: set[str],
        score: float = 0.0,
    ) -> VideoPostResponse:
        author = video.author
        return VideoPostResponse(
            id=video.id,
            authorId=video.author_id,
            authorName=author.name if author else "Tivoo Creator",
            authorUsername=author.username if author else "creator",
            authorAvatar=author.avatar_url if author else "",
            authorVerified=author.is_verified if author else False,
            videoUrl=video.video_url,
            hlsUrl=video.hls_url,
            thumbnailUrl=video.thumbnail_url,
            caption=video.caption,
            category=video.category,
            hashtags=list(video.hashtags or []),
            audience=video.audience,
            allowComments=video.allow_comments,
            allowDownloads=video.allow_downloads,
            allowShare=video.allow_share,
            location=video.location,
            musicTitle=video.music_title,
            snapLensName=video.snap_lens_name,
            durationSeconds=video.duration_seconds,
            width=video.width,
            height=video.height,
            fileSizeBytes=video.file_size_bytes,
            storageBackend=video.storage_backend,
            transcodingStatus=video.transcoding_status,
            transcodingError=video.transcoding_error,
            likes=video.likes_count,
            views=video.views_count,
            commentsCount=video.comments_count,
            sharesCount=video.shares_count,
            isLiked=video.id in liked_video_ids,
            isFollowingAuthor=video.author_id in followed_author_ids,
            algorithmScore=score,
            createdAt=video.created_at,
        )

    def _load_viewer_context(
        self, db: Session, viewer: User | None, video_ids: list[str]
    ) -> tuple[set[str], set[str]]:
        if not viewer:
            return set(), set()

        liked_ids: set[str] = set()
        if video_ids:
            liked_rows = db.scalars(
                select(VideoLike.video_id).where(
                    and_(VideoLike.user_id == viewer.id, VideoLike.video_id.in_(video_ids))
                )
            ).all()
            liked_ids = set(liked_rows)

        followed_rows = db.scalars(
            select(Follow.following_id).where(
                and_(Follow.follower_id == viewer.id, Follow.status == "following")
            )
        ).all()
        return liked_ids, set(followed_rows)

    def upload_video(
        self,
        db: Session,
        author: User,
        video_file: UploadFile,
        thumbnail_file: UploadFile | None,
        caption: str,
        category: str,
        audience: str,
        allow_comments: bool,
        allow_downloads: bool,
        allow_share: bool,
        location: str | None,
        music_title: str | None,
        snap_lens_name: str | None,
    ) -> VideoPostResponse:
        settings = get_settings()
        ext = safe_extension(video_file.filename, fallback=".mp4")
        if ext not in _ALLOWED_VIDEO_EXTS:
            raise BadRequestError(
                f"Unsupported video format '{ext}'. Allowed formats: {', '.join(sorted(_ALLOWED_VIDEO_EXTS))}"
            )

        video_id = str(uuid.uuid4())
        stage_dir = Path(tempfile.mkdtemp(prefix=f"tivoo_upload_{video_id}_"))
        raw_stage_path = stage_dir / f"raw{ext}"

        total_bytes = 0
        try:
            with raw_stage_path.open("wb") as out_f:
                while chunk := video_file.file.read(1024 * 1024):
                    total_bytes += len(chunk)
                    if total_bytes > settings.max_video_upload_bytes:
                        raise BadRequestError(
                            f"Video exceeds max upload limit of {settings.max_video_upload_mb} MB"
                        )
                    out_f.write(chunk)

            if total_bytes == 0:
                raise BadRequestError("Uploaded video file is empty")

            probe = transcoder_service.probe_video(raw_stage_path)

            raw_key = f"videos/{video_id}/raw{ext}"
            raw_url = storage_service.save_local_file(raw_stage_path, raw_key)

            thumb_key = ""
            thumb_url = None
            if thumbnail_file and thumbnail_file.filename:
                thumb_bytes = thumbnail_file.file.read()
                if thumb_bytes:
                    thumb_ext = safe_extension(thumbnail_file.filename, fallback=".jpg")
                    thumb_key = f"videos/{video_id}/thumb{thumb_ext}"
                    thumb_url = storage_service.save_bytes(
                        thumb_bytes,
                        thumb_key,
                        content_type=thumbnail_file.content_type or "image/jpeg",
                    )

            if not thumb_url:
                extracted_thumb = stage_dir / "thumb.jpg"
                if transcoder_service.extract_thumbnail(raw_stage_path, extracted_thumb):
                    thumb_key = f"videos/{video_id}/thumb.jpg"
                    thumb_url = storage_service.save_local_file(extracted_thumb, thumb_key)

            # Determine transcode staging source: local saved file or stage path kept for background job
            transcode_source = (
                storage_service.resolve_local_path(raw_key)
                if settings.storage_backend == "local"
                else raw_stage_path
            )

            status_value = "pending" if settings.enable_auto_transcode else "ready"
            video = Video(
                id=video_id,
                author_id=author.id,
                caption=caption.strip(),
                category=(category or "Entertainment").strip()[:64],
                hashtags=extract_hashtags(caption),
                audience=audience if audience in ("Public", "Followers Only", "Only Me") else "Public",
                allow_comments=allow_comments,
                allow_downloads=allow_downloads,
                allow_share=allow_share,
                location=location.strip()[:150] if location and location.strip() else None,
                music_title=music_title.strip()[:150] if music_title and music_title.strip() else None,
                snap_lens_name=snap_lens_name.strip()[:100] if snap_lens_name and snap_lens_name.strip() else None,
                storage_backend=settings.storage_backend,
                raw_storage_key=raw_key,
                video_storage_key=raw_key,
                video_url=raw_url,
                thumbnail_storage_key=thumb_key,
                thumbnail_url=thumb_url,
                duration_seconds=probe.duration_seconds,
                width=probe.width,
                height=probe.height,
                file_size_bytes=total_bytes,
                transcoding_status=status_value,
            )
            db.add(video)
            db.commit()
            db.refresh(video)

            if settings.enable_auto_transcode:
                # If cloud storage is used, keep a copy outside temp dir cleaned by worker
                if settings.storage_backend != "local":
                    persistent_tmp = Path(tempfile.gettempdir()) / f"tivoo_job_{video_id}{ext}"
                    shutil.copy2(raw_stage_path, persistent_tmp)
                    transcode_source = persistent_tmp
                transcoder_service.enqueue_transcode(video.id, transcode_source)

            return self._serialize_video(video, liked_video_ids=set(), followed_author_ids=set())
        finally:
            shutil.rmtree(stage_dir, ignore_errors=True)

    def get_video_by_id(self, db: Session, video_id: str, viewer: User | None) -> VideoPostResponse:
        video = db.scalar(
            select(Video).options(joinedload(Video.author)).where(Video.id == video_id)
        )
        if not video:
            raise NotFoundError("Video not found")
        if video.audience == "Only Me" and (not viewer or viewer.id != video.author_id):
            raise ForbiddenError("This video is private")

        liked_ids, followed_ids = self._load_viewer_context(db, viewer, [video.id])
        score = self._compute_algorithm_score(video, video.author_id in followed_ids)
        return self._serialize_video(video, liked_ids, followed_ids, score=score)

    def get_feed(
        self,
        db: Session,
        viewer: User | None,
        feed_type: str = "for_you",
        page: int = 1,
        page_size: int = 20,
        category: str | None = None,
        query_text: str | None = None,
        author_id: str | None = None,
    ) -> FeedListResponse:
        followed_rows: list[str] = []
        if viewer:
            followed_rows = list(
                db.scalars(
                    select(Follow.following_id).where(
                        and_(Follow.follower_id == viewer.id, Follow.status == "following")
                    )
                ).all()
            )
        followed_set = set(followed_rows)

        stmt = select(Video).options(joinedload(Video.author))
        conditions = []

        if author_id:
            conditions.append(Video.author_id == author_id)
            if not viewer or viewer.id != author_id:
                allowed = ["Public"] + (["Followers Only"] if author_id in followed_set else [])
                conditions.append(Video.audience.in_(allowed))
        elif feed_type == "following":
            if not viewer or not followed_set:
                return FeedListResponse(
                    videos=[],
                    feedType="following",
                    page=page,
                    pageSize=page_size,
                    total=0,
                    hasMore=False,
                )
            conditions.append(Video.author_id.in_(followed_set))
            conditions.append(Video.audience.in_(["Public", "Followers Only"]))
        else:
            if viewer and followed_set:
                conditions.append(
                    or_(
                        Video.audience == "Public",
                        Video.author_id == viewer.id,
                        and_(Video.audience == "Followers Only", Video.author_id.in_(followed_set)),
                    )
                )
            elif viewer:
                conditions.append(or_(Video.audience == "Public", Video.author_id == viewer.id))
            else:
                conditions.append(Video.audience == "Public")

        if category and category.strip().lower() not in ("all", "trending"):
            conditions.append(Video.category == category.strip())

        if query_text and query_text.strip():
            term = f"%{query_text.strip()}%"
            conditions.append(
                or_(
                    Video.caption.ilike(term),
                    Video.category.ilike(term),
                )
            )

        if conditions:
            stmt = stmt.where(and_(*conditions))

        candidates = list(db.scalars(stmt.order_by(Video.created_at.desc()).limit(300)).all())

        scored: list[tuple[float, Video]] = []
        for vid in candidates:
            if feed_type == "following":
                score = float(vid.created_at.timestamp())
            else:
                score = self._compute_algorithm_score(vid, vid.author_id in followed_set)
            scored.append((score, vid))

        if feed_type == "for_you":
            scored.sort(key=lambda item: (item[0], item[1].created_at), reverse=True)
        else:
            scored.sort(key=lambda item: item[1].created_at, reverse=True)

        total = len(scored)
        start = (page - 1) * page_size
        end = start + page_size
        page_slice = scored[start:end]

        page_ids = [vid.id for _, vid in page_slice]
        liked_ids, _ = self._load_viewer_context(db, viewer, page_ids)

        serialized = [
            self._serialize_video(vid, liked_ids, followed_set, score=score)
            for score, vid in page_slice
        ]

        return FeedListResponse(
            videos=serialized,
            feedType=feed_type,
            page=page,
            pageSize=page_size,
            total=total,
            hasMore=end < total,
        )

    def toggle_like(self, db: Session, viewer: User, video_id: str) -> LikeToggleResponse:
        video = db.get(Video, video_id)
        if not video:
            raise NotFoundError("Video not found")

        existing = db.scalar(
            select(VideoLike).where(
                and_(VideoLike.video_id == video.id, VideoLike.user_id == viewer.id)
            )
        )
        author = db.get(User, video.author_id)

        if existing:
            db.delete(existing)
            video.likes_count = max(0, video.likes_count - 1)
            if author:
                author.likes_count = max(0, author.likes_count - 1)
            is_liked = False
        else:
            db.add(VideoLike(video_id=video.id, user_id=viewer.id))
            video.likes_count += 1
            if author:
                author.likes_count += 1
            is_liked = True

        db.commit()
        return LikeToggleResponse(videoId=video.id, isLiked=is_liked, likesCount=video.likes_count)

    def record_view(self, db: Session, video_id: str) -> dict[str, int | str]:
        video = db.get(Video, video_id)
        if not video:
            raise NotFoundError("Video not found")
        video.views_count += 1
        author = db.get(User, video.author_id)
        if author:
            author.total_views += 1
        db.commit()
        return {"videoId": video.id, "viewsCount": video.views_count}

    def list_comments(self, db: Session, video_id: str, viewer: User | None) -> CommentListResponse:
        video = db.get(Video, video_id)
        if not video:
            raise NotFoundError("Video not found")

        rows = list(
            db.scalars(
                select(VideoComment)
                .options(joinedload(VideoComment.author))
                .where(VideoComment.video_id == video.id)
                .order_by(VideoComment.created_at.desc())
            ).all()
        )
        liked_comment_ids: set[str] = set()
        if viewer and rows:
            cids = [r.id for r in rows]
            liked_comment_ids = set(
                db.scalars(
                    select(CommentLike.comment_id).where(
                        and_(CommentLike.user_id == viewer.id, CommentLike.comment_id.in_(cids))
                    )
                ).all()
            )

        items = [
            CommentResponse(
                id=c.id,
                videoId=c.video_id,
                userId=c.user_id,
                authorName=c.author.username if c.author else "creator",
                authorFullName=c.author.name if c.author else "Tivoo Creator",
                authorAvatar=c.author.avatar_url if c.author else "",
                text=c.text,
                createdAt=c.created_at,
                likes=c.likes_count,
                isLiked=c.id in liked_comment_ids,
                isMine=bool(viewer and c.user_id == viewer.id),
                parentCommentId=c.parent_comment_id,
            )
            for c in rows
        ]
        return CommentListResponse(comments=items, total=len(items))

    def add_comment(
        self,
        db: Session,
        viewer: User,
        video_id: str,
        payload: CommentCreateRequest,
    ) -> CommentResponse:
        video = db.get(Video, video_id)
        if not video:
            raise NotFoundError("Video not found")
        if not video.allow_comments:
            raise ForbiddenError("Comments are disabled for this video")

        if payload.parentCommentId:
            parent = db.get(VideoComment, payload.parentCommentId)
            if not parent or parent.video_id != video.id:
                raise NotFoundError("Parent comment not found")

        comment = VideoComment(
            video_id=video.id,
            user_id=viewer.id,
            parent_comment_id=payload.parentCommentId,
            text=payload.text.strip(),
        )
        db.add(comment)
        video.comments_count += 1
        db.commit()
        db.refresh(comment)

        return CommentResponse(
            id=comment.id,
            videoId=comment.video_id,
            userId=viewer.id,
            authorName=viewer.username,
            authorFullName=viewer.name,
            authorAvatar=viewer.avatar_url,
            text=comment.text,
            createdAt=comment.created_at,
            likes=0,
            isLiked=False,
            isMine=True,
            parentCommentId=comment.parent_comment_id,
        )

    def delete_comment(self, db: Session, viewer: User, comment_id: str) -> dict[str, str]:
        comment = db.get(VideoComment, comment_id)
        if not comment:
            raise NotFoundError("Comment not found")
        video = db.get(Video, comment.video_id)
        if comment.user_id != viewer.id and (not video or video.author_id != viewer.id):
            raise ForbiddenError("You can only delete your own comments")

        if video:
            video.comments_count = max(0, video.comments_count - 1)
        db.delete(comment)
        db.commit()
        return {"message": "Comment deleted"}

    def toggle_comment_like(self, db: Session, viewer: User, comment_id: str) -> dict[str, object]:
        comment = db.get(VideoComment, comment_id)
        if not comment:
            raise NotFoundError("Comment not found")

        existing = db.scalar(
            select(CommentLike).where(
                and_(CommentLike.comment_id == comment.id, CommentLike.user_id == viewer.id)
            )
        )
        if existing:
            db.delete(existing)
            comment.likes_count = max(0, comment.likes_count - 1)
            is_liked = False
        else:
            db.add(CommentLike(comment_id=comment.id, user_id=viewer.id))
            comment.likes_count += 1
            is_liked = True

        db.commit()
        return {"commentId": comment.id, "isLiked": is_liked, "likesCount": comment.likes_count}

    def delete_video(self, db: Session, viewer: User, video_id: str) -> dict[str, str]:
        video = db.get(Video, video_id)
        if not video:
            raise NotFoundError("Video not found")
        if video.author_id != viewer.id:
            raise ForbiddenError("You can only delete your own videos")

        storage_service.delete_key(video.raw_storage_key)
        storage_service.delete_key(video.video_storage_key)
        storage_service.delete_key(video.thumbnail_storage_key)
        storage_service.delete_prefix(video.hls_storage_prefix)
        storage_service.delete_prefix(f"videos/{video.id}")

        db.delete(video)
        db.commit()
        return {"message": "Video deleted"}


feed_service = FeedService()

