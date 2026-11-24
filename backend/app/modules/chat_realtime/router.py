from __future__ import annotations
from fastapi import APIRouter, Depends, HTTPException, Query, WebSocket, WebSocketDisconnect, status
from pydantic import ValidationError
from sqlalchemy.orm import Session

from app.core.exceptions import AppError
from app.core.security import get_current_user, get_user_from_access_token
from app.db.session import SessionLocal, get_db
from app.models.user import User
from app.modules.chat_realtime.schemas import (
    DmInboxResponse,
    DmMessageResponse,
    DmSendRequest,
    DmThreadListResponse,
    LiveChatCreateRequest,
    LiveChatListResponse,
    LiveChatMessageResponse,
)
from app.modules.chat_realtime.service import chat_realtime_service
from app.realtime.connection_manager import realtime_hub

chat_router = APIRouter(prefix="/api/chat", tags=["Live Chat & Barrage"])
dm_router = APIRouter(prefix="/api/dm", tags=["Direct Messages (DMs)"])
ws_router = APIRouter(tags=["WebSockets (Live, PK & DMs)"])


def _extract_ws_token(websocket: WebSocket, token: str | None) -> str | None:
    if token and token.strip():
        return token.strip()
    auth = websocket.headers.get("authorization", "")
    if auth.lower().startswith("bearer "):
        return auth[7:].strip()
    return None


@chat_router.get("/live/{room_id}/messages", response_model=LiveChatListResponse)
def list_live_room_messages(
    room_id: str,
    limit: int = Query(default=50, ge=1, le=200),
    db: Session = Depends(get_db),
) -> LiveChatListResponse:
    """List persisted chat & bullet barrage messages for a live stream room."""
    return chat_realtime_service.list_live_messages(db, room_id, limit=limit)


@chat_router.post(
    "/live/{room_id}/messages",
    response_model=LiveChatMessageResponse,
    status_code=status.HTTP_201_CREATED,
)
def send_live_room_message(
    room_id: str,
    payload: LiveChatCreateRequest,
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db),
) -> LiveChatMessageResponse:
    """Persist a live room chat/barrage message in MySQL and broadcast over WebSocket."""
    return chat_realtime_service.send_live_message(db, room_id, current_user, payload)


@dm_router.get("/conversations", response_model=DmInboxResponse)
def list_dm_conversations(
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db),
) -> DmInboxResponse:
    """List the authenticated user's DM inbox threads ordered by newest message."""
    return chat_realtime_service.list_conversations(db, current_user)


@dm_router.get("/with/{peer_id}/messages", response_model=DmThreadListResponse)
def list_dm_thread(
    peer_id: str,
    page: int = Query(default=1, ge=1),
    page_size: int = Query(default=30, ge=1, le=100),
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db),
) -> DmThreadListResponse:
    """Fetch DM history with a peer user and mark incoming messages read."""
    return chat_realtime_service.list_dm_messages(
        db, current_user, peer_id, page=page, page_size=page_size
    )


@dm_router.post(
    "/with/{peer_id}/messages",
    response_model=DmMessageResponse,
    status_code=status.HTTP_201_CREATED,
)
def send_dm_message(
    peer_id: str,
    payload: DmSendRequest,
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db),
) -> DmMessageResponse:
    """Persist a DM in MySQL, broadcast over WebSocket, and dispatch FCM push notification."""
    return chat_realtime_service.send_dm(db, current_user, peer_id, payload)


@dm_router.post("/conversations/{conversation_id}/read")
def mark_dm_conversation_read(
    conversation_id: str,
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db),
) -> dict[str, int | str]:
    """Explicitly mark a conversation's unread incoming messages as read."""
    return chat_realtime_service.mark_conversation_read(db, current_user, conversation_id)


@ws_router.websocket("/ws/live/{room_id}")
async def live_room_websocket(
    websocket: WebSocket,
    room_id: str,
    token: str | None = Query(default=None),
) -> None:
    """Real-time WebSocket stream for live chat, bullet barrage, gift animations, and viewer counts."""
    raw_token = _extract_ws_token(websocket, token)
    user_id: str | None = None
    if raw_token:
        db = SessionLocal()
        try:
            user_id = get_user_from_access_token(raw_token, db).id
        except HTTPException:
            await websocket.close(code=4401)
            return
        finally:
            db.close()

    await realtime_hub.connect_room(room_id, websocket)
    try:
        while True:
            frame = await websocket.receive_json()
            msg_type = str(frame.get("type", "chat"))
            if msg_type == "ping":
                await websocket.send_json({"event": "pong", "data": {}})
                continue

            if not user_id:
                await websocket.send_json(
                    {"event": "error", "data": {"message": "Authentication required to send chat"}}
                )
                continue

            db = SessionLocal()
            try:
                user = db.get(User, user_id)
                if not user or not user.is_active:
                    await websocket.close(code=4401)
                    return
                req = LiveChatCreateRequest(
                    messageType=msg_type if msg_type in ("chat", "barrage", "heart") else "chat",
                    content=str(frame.get("content", "")),
                    colorHex=str(frame.get("colorHex", "#FFFFFF")),
                )
                chat_realtime_service.send_live_message(db, room_id, user, req)
            except (ValidationError, AppError) as exc:
                await websocket.send_json({"event": "error", "data": {"message": str(exc)}})
            finally:
                db.close()
    except WebSocketDisconnect:
        pass
    finally:
        realtime_hub.disconnect_room(room_id, websocket)


@ws_router.websocket("/ws/pk/{battle_id}")
async def pk_battle_websocket(
    websocket: WebSocket,
    battle_id: str,
) -> None:
    """Real-time WebSocket stream for live PK battle score bar & countdown updates."""
    channel_key = f"pk:{battle_id}"
    await realtime_hub.connect_room(channel_key, websocket)
    try:
        while True:
            frame = await websocket.receive_json()
            if frame.get("type") == "ping":
                await websocket.send_json({"event": "pong", "data": {}})
    except WebSocketDisconnect:
        pass
    finally:
        realtime_hub.disconnect_room(channel_key, websocket)


@ws_router.websocket("/ws/dm")
async def direct_messages_websocket(
    websocket: WebSocket,
    token: str | None = Query(default=None),
) -> None:
    """Authenticated real-time WebSocket channel for DMs, read receipts, and live notifications."""
    raw_token = _extract_ws_token(websocket, token)
    if not raw_token:
        await websocket.close(code=4401)
        return

    db = SessionLocal()
    try:
        user_id = get_user_from_access_token(raw_token, db).id
    except HTTPException:
        await websocket.close(code=4401)
        return
    finally:
        db.close()

    await realtime_hub.connect_user(user_id, websocket)
    try:
        while True:
            frame = await websocket.receive_json()
            action = str(frame.get("type", "send_dm"))
            if action == "ping":
                await websocket.send_json({"event": "pong", "data": {}})
                continue

            if action == "send_dm":
                db = SessionLocal()
                try:
                    sender = db.get(User, user_id)
                    if not sender or not sender.is_active:
                        await websocket.close(code=4401)
                        return
                    recipient_id = str(frame.get("recipientId", ""))
                    req = DmSendRequest(
                        messageType=str(frame.get("messageType", "text")),  # type: ignore[arg-type]
                        content=str(frame.get("content", "")),
                        mediaUrl=frame.get("mediaUrl"),
                    )
                    chat_realtime_service.send_dm(db, sender, recipient_id, req)
                except (ValidationError, AppError) as exc:
                    await websocket.send_json({"event": "error", "data": {"message": str(exc)}})
                finally:
                    db.close()
    except WebSocketDisconnect:
        pass
    finally:
        realtime_hub.disconnect_user(user_id, websocket)
