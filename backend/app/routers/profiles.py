from __future__ import annotations
from fastapi import APIRouter, Depends, File, Query, UploadFile
from pydantic import BaseModel
from sqlalchemy.orm import Session

from app.core.config import get_settings
from app.core.exceptions import BadRequestError
from app.core.security import get_current_user, get_optional_current_user
from app.db.session import get_db
from app.models.user import User
from app.schemas.profile import (
    FollowListResponse,
    FollowRelationshipResponse,
    UpdateProfileRequest,
    UserProfileResponse,
)
from app.services.profile_service import profile_service

router = APIRouter(prefix="/api/profiles", tags=["Profiles"])
users_router = APIRouter(prefix="/api/users", tags=["Users"])
follows_router = APIRouter(prefix="/api/follows", tags=["Follows"])


class ProfileSearchResponse(BaseModel):
    profiles: list[UserProfileResponse]
    total: int


async def _read_image_upload(upload: UploadFile) -> bytes:
    """Read uploaded image bytes and enforce configured upload limit."""
    settings = get_settings()
    max_bytes = settings.max_image_upload_mb * 1024 * 1024
    raw_bytes = await upload.read()
    if not raw_bytes:
        raise BadRequestError("Uploaded image file is empty")
    if len(raw_bytes) > max_bytes:
        raise BadRequestError(
            f"Image exceeds maximum allowed size of {settings.max_image_upload_mb} MB"
        )
    return raw_bytes


@router.get("/me", response_model=UserProfileResponse)
@users_router.get("/me", response_model=UserProfileResponse)
def get_my_profile(
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db),
) -> UserProfileResponse:
    """Return the authenticated user's full profile."""
    return profile_service.serialize_profile(
        db,
        current_user,
        viewer_id=current_user.id,
        include_private_contact=True,
    )


@router.patch("/me", response_model=UserProfileResponse)
def update_my_profile(
    payload: UpdateProfileRequest,
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db),
) -> UserProfileResponse:
    """Update profile name, username, bio, roles, privacy, or online indicator."""
    return profile_service.update_profile(db, current_user, payload)


@router.post("/me/avatar", response_model=UserProfileResponse)
async def upload_avatar(
    file: UploadFile = File(...),
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db),
) -> UserProfileResponse:
    """Upload and process a new avatar image into configured storage."""
    raw_bytes = await _read_image_upload(file)
    return profile_service.update_profile_image(db, current_user, raw_bytes, kind="avatar")


@router.post("/me/cover", response_model=UserProfileResponse)
async def upload_cover(
    file: UploadFile = File(...),
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db),
) -> UserProfileResponse:
    """Upload and process a new cover background image into configured storage."""
    raw_bytes = await _read_image_upload(file)
    return profile_service.update_profile_image(db, current_user, raw_bytes, kind="cover")


@router.get("/search", response_model=ProfileSearchResponse)
def search_profiles(
    q: str = Query(default="", max_length=100),
    limit: int = Query(default=20, ge=1, le=50),
    viewer: User | None = Depends(get_optional_current_user),
    db: Session = Depends(get_db),
) -> ProfileSearchResponse:
    """Search registered creator profiles in MySQL by name or username."""
    items = profile_service.search_profiles(
        db,
        query_text=q,
        viewer_id=viewer.id if viewer else None,
        limit=limit,
    )
    return ProfileSearchResponse(profiles=items, total=len(items))


@router.get("/{identifier}", response_model=UserProfileResponse)
def get_profile(
    identifier: str,
    viewer: User | None = Depends(get_optional_current_user),
    db: Session = Depends(get_db),
) -> UserProfileResponse:
    """Fetch a public profile by user ID or username."""
    target = profile_service.get_profile_by_id_or_username(db, identifier)
    viewer_id = viewer.id if viewer else None
    return profile_service.serialize_profile(
        db,
        target,
        viewer_id=viewer_id,
        include_private_contact=viewer_id == target.id,
    )


@follows_router.get("/requests", response_model=FollowListResponse)
def get_pending_follow_requests(
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db),
) -> FollowListResponse:
    """List pending incoming follow requests for the authenticated private account."""
    return profile_service.list_pending_requests(db, current_user)


@follows_router.post("/{user_id}", response_model=FollowRelationshipResponse)
def follow_user(
    user_id: str,
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db),
) -> FollowRelationshipResponse:
    """Follow a creator or submit a follow request for private profiles."""
    return profile_service.follow_user(db, current_user, user_id)


@follows_router.delete("/{user_id}", response_model=FollowRelationshipResponse)
def unfollow_user(
    user_id: str,
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db),
) -> FollowRelationshipResponse:
    """Unfollow a user or cancel a pending follow request."""
    return profile_service.unfollow_user(db, current_user, user_id)


@follows_router.post("/{requester_id}/accept", response_model=FollowRelationshipResponse)
def accept_follow_request(
    requester_id: str,
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db),
) -> FollowRelationshipResponse:
    """Accept an incoming follow request."""
    return profile_service.accept_follow_request(db, current_user, requester_id)


@follows_router.get("/{user_id}/followers", response_model=FollowListResponse)
def list_followers(
    user_id: str,
    viewer: User | None = Depends(get_optional_current_user),
    db: Session = Depends(get_db),
) -> FollowListResponse:
    """List accepted followers for a given user."""
    return profile_service.list_followers(db, user_id, viewer.id if viewer else None)


@follows_router.get("/{user_id}/following", response_model=FollowListResponse)
def list_following(
    user_id: str,
    viewer: User | None = Depends(get_optional_current_user),
    db: Session = Depends(get_db),
) -> FollowListResponse:
    """List accepted accounts followed by a given user."""
    return profile_service.list_following(db, user_id, viewer.id if viewer else None)

