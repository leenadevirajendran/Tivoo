from __future__ import annotations
from pathlib import Path
from typing import Literal
import uuid

from fastapi import APIRouter, Depends, File, Header, Query, UploadFile, status
from sqlalchemy.orm import Session

from app.core.exceptions import BadRequestError
from app.core.security import get_current_user
from app.db.session import get_db
from app.models.user import User
from app.modules.live_gateway.schemas import (
    CreateLiveRoomRequest,
    LiveRoomCreatedResponse,
    LiveRoomListResponse,
    LiveRoomResponse,
    RtcTokenResponse,
    RtmpWebhookRequest,
)
from app.modules.live_gateway.service import live_gateway_service
from app.services.storage_service import storage_service

router = APIRouter(prefix="/api/live", tags=["Live Streaming Gateway"])


@router.get("/rooms", response_model=LiveRoomListResponse)
def list_live_rooms(
    status_filter: Literal["live", "scheduled", "ended", "all"] = Query(default="live"),
    category: str | None = Query(default=None, max_length=60),
    q: str | None = Query(default=None, max_length=100),
    page: int = Query(default=1, ge=1),
    page_size: int = Query(default=20, ge=1, le=50),
    db: Session = Depends(get_db),
) -> LiveRoomListResponse:
    """List real live/scheduled stream rooms from MySQL."""
    return live_gateway_service.list_rooms(
        db=db,
        status_filter=status_filter,
        category=category,
        q=q,
        page=page,
        page_size=page_size,
    )


@router.post("/rooms/cover")
async def upload_live_cover(
    file: UploadFile = File(...),
    current_user: User = Depends(get_current_user),
) -> dict[str, str]:
    """Upload a custom cover image from camera or file picker for a live stream."""
    raw_bytes = await file.read()
    if not raw_bytes:
        raise BadRequestError("Uploaded file is empty")
    ext = Path(file.filename or "cover.jpg").suffix.lower() or ".jpg"
    key = f"live_covers/{uuid.uuid4().hex}{ext}"
    url = storage_service.save_bytes(raw_bytes, key, content_type=file.content_type)
    return {"coverUrl": url}


@router.post("/rooms", response_model=LiveRoomCreatedResponse, status_code=status.HTTP_201_CREATED)
def create_live_room(
    payload: CreateLiveRoomRequest,
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db),
) -> LiveRoomCreatedResponse:
    """Create a live broadcast room and issue a cryptographically random RTMP stream key."""
    return live_gateway_service.create_room(db, current_user, payload)


@router.get("/rooms/{room_id}", response_model=LiveRoomResponse)
def get_live_room(room_id: str, db: Session = Depends(get_db)) -> LiveRoomResponse:
    """Fetch metadata, playback URL, and viewer count for a live room."""
    return live_gateway_service.get_room(db, room_id)


@router.post("/rooms/{room_id}/start", response_model=LiveRoomResponse)
def start_live_room(
    room_id: str,
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db),
) -> LiveRoomResponse:
    """Mark stream room LIVE in MySQL and send push notifications to followers."""
    return live_gateway_service.start_room(db, current_user, room_id)


@router.post("/rooms/{room_id}/end", response_model=LiveRoomResponse)
def end_live_room(
    room_id: str,
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db),
) -> LiveRoomResponse:
    """End an active live broadcast and close participant sessions."""
    return live_gateway_service.end_room(db, current_user, room_id)


@router.post("/rooms/{room_id}/rotate-key", response_model=LiveRoomCreatedResponse)
def rotate_live_stream_key(
    room_id: str,
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db),
) -> LiveRoomCreatedResponse:
    """Regenerate the private RTMP stream key for a room."""
    return live_gateway_service.rotate_stream_key(db, current_user, room_id)


@router.post("/rooms/{room_id}/host-token", response_model=RtcTokenResponse)
def get_host_rtc_token(
    room_id: str,
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db),
) -> RtcTokenResponse:
    """Issue a publisher WebRTC token (LiveKit JWT or Agora 007) for the room host."""
    return live_gateway_service.issue_host_rtc_token(db, current_user, room_id)


@router.post("/rooms/{room_id}/join", response_model=RtcTokenResponse)
def join_live_room(
    room_id: str,
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db),
) -> RtcTokenResponse:
    """Join a live room as a viewer and receive subscriber WebRTC token / HLS playback URL."""
    return live_gateway_service.join_room(db, current_user, room_id)


@router.post("/rooms/{room_id}/leave")
def leave_live_room(
    room_id: str,
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db),
) -> dict[str, int | str]:
    """Leave a live room and decrement real active viewer count."""
    return live_gateway_service.leave_room(db, current_user, room_id)


@router.post("/rooms/{room_id}/like")
def like_live_room(
    room_id: str,
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db),
) -> dict[str, int | str]:
    """Record a real heart tap on the live stream and broadcast via WebSocket."""
    return live_gateway_service.like_room(db, current_user, room_id)


@router.post("/rtmp/webhook", response_model=LiveRoomResponse)
def rtmp_ingest_webhook(
    payload: RtmpWebhookRequest,
    x_rtmp_secret: str = Header(default=""),
    db: Session = Depends(get_db),
) -> LiveRoomResponse:
    """Webhook endpoint for Nginx-RTMP / SRS / MediaMTX on_publish & on_done hooks."""
    return live_gateway_service.handle_rtmp_webhook(
        db=db,
        action=payload.action,
        room_key=payload.roomKey,
        stream_key=payload.streamKey,
        provided_secret=x_rtmp_secret,
    )
