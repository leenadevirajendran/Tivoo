from __future__ import annotations
import io
import uuid

from PIL import Image, UnidentifiedImageError
from sqlalchemy import and_, or_, select
from sqlalchemy.orm import Session

from app.core.config import get_settings
from app.core.exceptions import BadRequestError, ConflictError, ForbiddenError, NotFoundError
from app.core.security import utc_now
from app.models.user import Follow, User
from app.schemas.profile import (
    FollowListResponse,
    FollowRelationshipResponse,
    UpdateProfileRequest,
    UserProfileResponse,
)
from app.services.storage_service import storage_service
from app.utils.helpers import format_compact_count, normalize_username


class ProfileService:
    """Profile management, media avatars, and persistent MySQL follow relationships."""

    def resolve_follow_status(self, db: Session, viewer_id: str | None, target_id: str) -> tuple[str, bool, Follow | None]:
        """Return (status_label, they_follow_me, outgoing_follow_row)."""
        if not viewer_id or viewer_id == target_id:
            return "notFollowing", False, None

        outgoing = db.scalar(
            select(Follow).where(
                and_(Follow.follower_id == viewer_id, Follow.following_id == target_id)
            )
        )
        incoming = db.scalar(
            select(Follow).where(
                and_(Follow.follower_id == target_id, Follow.following_id == viewer_id)
            )
        )
        they_follow_me = incoming is not None and incoming.status == "following"

        if not outgoing:
            return "notFollowing", they_follow_me, None
        if outgoing.status == "blocked":
            return "blocked", False, outgoing
        if outgoing.status == "requested":
            return "requested", they_follow_me, outgoing
        if outgoing.status == "following":
            return ("mutual" if they_follow_me else "following"), they_follow_me, outgoing
        return "notFollowing", they_follow_me, outgoing

    def serialize_profile(
        self,
        db: Session,
        user: User,
        viewer_id: str | None = None,
        include_private_contact: bool = False,
    ) -> UserProfileResponse:
        follow_status, _, _ = self.resolve_follow_status(db, viewer_id, user.id)
        is_owner = viewer_id == user.id or include_private_contact
        return UserProfileResponse(
            id=user.id,
            name=user.name,
            username=user.username,
            bio=user.bio,
            aboutMe=user.about_me,
            avatarUrl=user.avatar_url,
            coverBackgroundUrl=user.cover_background_url,
            email=(user.email or "") if is_owner else "",
            phoneNumber=(user.phone_number or "") if is_owner else "",
            roles=list(user.roles or ["Creator"]),
            isVerified=user.is_verified,
            isEmailVerified=user.is_email_verified,
            isPhoneVerified=user.is_phone_verified,
            isPrivate=user.is_private,
            isOnline=user.is_online,
            followingCount=user.following_count,
            followersCount=format_compact_count(user.followers_count),
            followersCountNum=user.followers_count,
            likesCount=format_compact_count(user.likes_count),
            likesCountNum=user.likes_count,
            liveStreamsCount=user.live_streams_count,
            totalViews=format_compact_count(user.total_views),
            followStatus=follow_status,
            createdAt=user.created_at,
        )

    def get_profile_by_id_or_username(self, db: Session, identifier: str) -> User:
        user = db.scalar(
            select(User).where(
                or_(User.id == identifier, User.username == normalize_username(identifier))
            )
        )
        if not user or not user.is_active:
            raise NotFoundError("User profile not found")
        return user

    def update_profile(self, db: Session, user: User, payload: UpdateProfileRequest) -> UserProfileResponse:
        if payload.username is not None:
            normalized = normalize_username(payload.username)
            if len(normalized) < 3:
                raise BadRequestError("Username must be at least 3 valid characters")
            existing = db.scalar(
                select(User).where(and_(User.username == normalized, User.id != user.id))
            )
            if existing:
                raise ConflictError("Username is already taken")
            user.username = normalized

        if payload.name is not None:
            user.name = payload.name.strip()
        if payload.bio is not None:
            user.bio = payload.bio.strip()
        if payload.aboutMe is not None:
            user.about_me = payload.aboutMe.strip()
        if payload.roles is not None:
            user.roles = [r.strip() for r in payload.roles if r.strip()][:5] or ["Creator"]
        if payload.isPrivate is not None:
            user.is_private = payload.isPrivate
        if payload.isOnline is not None:
            user.is_online = payload.isOnline

        db.commit()
        db.refresh(user)
        return self.serialize_profile(db, user, viewer_id=user.id, include_private_contact=True)

    def update_profile_image(
        self,
        db: Session,
        user: User,
        raw_bytes: bytes,
        kind: str,
    ) -> UserProfileResponse:
        """Validate, resize, and upload avatar or cover photo cleanly."""
        settings = get_settings()
        if len(raw_bytes) == 0:
            raise BadRequestError("Uploaded image file is empty")
        if len(raw_bytes) > settings.max_image_upload_bytes:
            raise BadRequestError(f"Image exceeds max size of {settings.max_image_upload_mb} MB")

        try:
            with Image.open(io.BytesIO(raw_bytes)) as img:
                rgb = img.convert("RGB")
                max_side = 512 if kind == "avatar" else 1440
                rgb.thumbnail((max_side, max_side), Image.Resampling.LANCZOS)
                buf = io.BytesIO()
                rgb.save(buf, format="JPEG", quality=88, optimize=True)
                optimized_bytes = buf.getvalue()
        except (UnidentifiedImageError, OSError) as exc:
            raise BadRequestError("Unsupported or corrupted image file") from exc

        key = f"profiles/{user.id}/{kind}_{uuid.uuid4().hex[:12]}.jpg"
        public_url = storage_service.save_bytes(optimized_bytes, key, content_type="image/jpeg")

        if kind == "avatar":
            user.avatar_url = public_url
        else:
            user.cover_background_url = public_url

        db.commit()
        db.refresh(user)
        return self.serialize_profile(db, user, viewer_id=user.id, include_private_contact=True)

    def search_profiles(self, db: Session, query_text: str, viewer_id: str | None, limit: int = 20) -> list[UserProfileResponse]:
        term = f"%{query_text.strip()}%"
        rows = db.scalars(
            select(User)
            .where(
                and_(
                    User.is_active.is_(True),
                    or_(User.username.ilike(term), User.name.ilike(term)),
                )
            )
            .order_by(User.followers_count.desc())
            .limit(limit)
        ).all()
        return [self.serialize_profile(db, u, viewer_id=viewer_id) for u in rows]

    def follow_user(self, db: Session, current_user: User, target_user_id: str) -> FollowRelationshipResponse:
        if current_user.id == target_user_id:
            raise BadRequestError("You cannot follow yourself")

        target = db.get(User, target_user_id)
        if not target or not target.is_active:
            raise NotFoundError("Target user not found")

        blocked_by_target = db.scalar(
            select(Follow).where(
                and_(
                    Follow.follower_id == target.id,
                    Follow.following_id == current_user.id,
                    Follow.status == "blocked",
                )
            )
        )
        if blocked_by_target:
            raise ForbiddenError("Unable to follow this user")

        row = db.scalar(
            select(Follow).where(
                and_(Follow.follower_id == current_user.id, Follow.following_id == target.id)
            )
        )

        now = utc_now()
        if row:
            if row.status == "following":
                return self._build_relationship_response(db, current_user.id, target)
            if row.status == "requested":
                return self._build_relationship_response(db, current_user.id, target)

        new_status = "requested" if target.is_private else "following"
        if row is None:
            row = Follow(
                follower_id=current_user.id,
                following_id=target.id,
                status=new_status,
                requested_at=now if new_status == "requested" else None,
                followed_at=now if new_status == "following" else None,
            )
            db.add(row)
        else:
            row.status = new_status
            row.requested_at = now if new_status == "requested" else None
            row.followed_at = now if new_status == "following" else None

        if new_status == "following":
            current_user.following_count += 1
            target.followers_count += 1

        db.commit()
        db.refresh(target)
        return self._build_relationship_response(db, current_user.id, target)

    def unfollow_user(self, db: Session, current_user: User, target_user_id: str) -> FollowRelationshipResponse:
        target = db.get(User, target_user_id)
        if not target or not target.is_active:
            raise NotFoundError("Target user not found")

        row = db.scalar(
            select(Follow).where(
                and_(Follow.follower_id == current_user.id, Follow.following_id == target.id)
            )
        )
        if row:
            if row.status == "following":
                current_user.following_count = max(0, current_user.following_count - 1)
                target.followers_count = max(0, target.followers_count - 1)
            db.delete(row)
            db.commit()
            db.refresh(target)

        return self._build_relationship_response(db, current_user.id, target)

    def accept_follow_request(self, db: Session, current_user: User, requester_id: str) -> FollowRelationshipResponse:
        requester = db.get(User, requester_id)
        if not requester or not requester.is_active:
            raise NotFoundError("Requester user not found")

        row = db.scalar(
            select(Follow).where(
                and_(
                    Follow.follower_id == requester.id,
                    Follow.following_id == current_user.id,
                    Follow.status == "requested",
                )
            )
        )
        if not row:
            raise NotFoundError("No pending follow request from this user")

        row.status = "following"
        row.followed_at = utc_now()
        requester.following_count += 1
        current_user.followers_count += 1
        db.commit()
        return self._build_relationship_response(db, current_user.id, requester)

    def list_followers(self, db: Session, target_user_id: str, viewer_id: str | None) -> FollowListResponse:
        target = db.get(User, target_user_id)
        if not target or not target.is_active:
            raise NotFoundError("User not found")

        rows = db.scalars(
            select(Follow)
            .where(and_(Follow.following_id == target.id, Follow.status == "following"))
            .order_by(Follow.followed_at.desc())
        ).all()
        user_ids = [r.follower_id for r in rows]
        users_by_id = self._load_users_map(db, user_ids)
        items = [
            self._build_relationship_response(db, viewer_id, users_by_id[uid])
            for uid in user_ids
            if uid in users_by_id
        ]
        return FollowListResponse(items=items, total=len(items))

    def list_following(self, db: Session, target_user_id: str, viewer_id: str | None) -> FollowListResponse:
        target = db.get(User, target_user_id)
        if not target or not target.is_active:
            raise NotFoundError("User not found")

        rows = db.scalars(
            select(Follow)
            .where(and_(Follow.follower_id == target.id, Follow.status == "following"))
            .order_by(Follow.followed_at.desc())
        ).all()
        user_ids = [r.following_id for r in rows]
        users_by_id = self._load_users_map(db, user_ids)
        items = [
            self._build_relationship_response(db, viewer_id, users_by_id[uid])
            for uid in user_ids
            if uid in users_by_id
        ]
        return FollowListResponse(items=items, total=len(items))

    def list_pending_requests(self, db: Session, current_user: User) -> FollowListResponse:
        rows = db.scalars(
            select(Follow)
            .where(and_(Follow.following_id == current_user.id, Follow.status == "requested"))
            .order_by(Follow.requested_at.desc())
        ).all()
        user_ids = [r.follower_id for r in rows]
        users_by_id = self._load_users_map(db, user_ids)
        items = [
            FollowRelationshipResponse(
                userId=users_by_id[uid].id,
                userName=users_by_id[uid].username,
                userFullName=users_by_id[uid].name,
                userAvatar=users_by_id[uid].avatar_url,
                status="requested",
                theyFollowMe=False,
                isMutual=False,
                followerCount=users_by_id[uid].followers_count,
                requestedAt=next((r.requested_at for r in rows if r.follower_id == uid), None),
            )
            for uid in user_ids
            if uid in users_by_id
        ]
        return FollowListResponse(items=items, total=len(items))

    def _load_users_map(self, db: Session, user_ids: list[str]) -> dict[str, User]:
        if not user_ids:
            return {}
        users = db.scalars(select(User).where(User.id.in_(user_ids))).all()
        return {u.id: u for u in users}

    def _build_relationship_response(
        self,
        db: Session,
        viewer_id: str | None,
        target: User,
    ) -> FollowRelationshipResponse:
        status_str, they_follow_me, outgoing = self.resolve_follow_status(db, viewer_id, target.id)
        return FollowRelationshipResponse(
            userId=target.id,
            userName=target.username,
            userFullName=target.name,
            userAvatar=target.avatar_url,
            status=status_str,  # type: ignore[arg-type]
            theyFollowMe=they_follow_me,
            isMutual=status_str == "mutual",
            followerCount=target.followers_count,
            isCloseFriend=outgoing.is_close_friend if outgoing else False,
            isMuted=outgoing.is_muted if outgoing else False,
            requestedAt=outgoing.requested_at if outgoing else None,
            followedAt=outgoing.followed_at if outgoing else None,
        )


profile_service = ProfileService()

