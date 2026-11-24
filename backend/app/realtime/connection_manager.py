from __future__ import annotations
import asyncio
from collections import defaultdict
from datetime import datetime, timezone
import threading
from typing import Any

from fastapi import WebSocket


class RealtimeConnectionManager:
    """Thread-safe async WebSocket connection hub for Live Rooms, PK Battles, and DMs."""

    def __init__(self) -> None:
        self._lock = threading.Lock()
        self._loop: asyncio.AbstractEventLoop | None = None
        self._rooms: dict[str, set[WebSocket]] = defaultdict(set)
        self._users: dict[str, set[WebSocket]] = defaultdict(set)

    def set_event_loop(self, loop: asyncio.AbstractEventLoop) -> None:
        """Bind the running ASGI event loop during FastAPI lifespan startup."""
        with self._lock:
            self._loop = loop

    async def connect_room(self, room_id: str, websocket: WebSocket) -> None:
        await websocket.accept()
        with self._lock:
            self._rooms[room_id].add(websocket)

    def disconnect_room(self, room_id: str, websocket: WebSocket) -> None:
        with self._lock:
            clients = self._rooms.get(room_id)
            if not clients:
                return
            clients.discard(websocket)
            if not clients:
                self._rooms.pop(room_id, None)

    async def connect_user(self, user_id: str, websocket: WebSocket) -> None:
        await websocket.accept()
        with self._lock:
            self._users[user_id].add(websocket)

    def disconnect_user(self, user_id: str, websocket: WebSocket) -> None:
        with self._lock:
            clients = self._users.get(user_id)
            if not clients:
                return
            clients.discard(websocket)
            if not clients:
                self._users.pop(user_id, None)

    @staticmethod
    def _build_envelope(event_type: str, data: dict[str, Any]) -> dict[str, Any]:
        return {
            "event": event_type,
            "data": data,
            "timestamp": datetime.now(timezone.utc).isoformat(),
        }

    async def broadcast_room(self, room_id: str, event_type: str, data: dict[str, Any]) -> None:
        with self._lock:
            targets = list(self._rooms.get(room_id, ()))
        if not targets:
            return
        payload = self._build_envelope(event_type, data)
        stale: list[WebSocket] = []
        for ws in targets:
            try:
                await ws.send_json(payload)
            except Exception:
                stale.append(ws)
        for ws in stale:
            self.disconnect_room(room_id, ws)

    async def send_to_user(self, user_id: str, event_type: str, data: dict[str, Any]) -> None:
        with self._lock:
            targets = list(self._users.get(user_id, ()))
        if not targets:
            return
        payload = self._build_envelope(event_type, data)
        stale: list[WebSocket] = []
        for ws in targets:
            try:
                await ws.send_json(payload)
            except Exception:
                stale.append(ws)
        for ws in stale:
            self.disconnect_user(user_id, ws)

    def _schedule(self, coro) -> None:
        with self._lock:
            loop = self._loop
        if loop and loop.is_running():
            try:
                asyncio.run_coroutine_threadsafe(coro, loop)
                return
            except RuntimeError:
                pass
        coro.close()

    def broadcast_room_sync(self, room_id: str, event_type: str, data: dict[str, Any]) -> None:
        """Broadcast from synchronous FastAPI worker threads onto the main ASGI loop."""
        with self._lock:
            has_targets = bool(self._rooms.get(room_id))
        if has_targets:
            self._schedule(self.broadcast_room(room_id, event_type, data))

    def send_to_user_sync(self, user_id: str, event_type: str, data: dict[str, Any]) -> None:
        """Push a user-scoped realtime event from synchronous service methods."""
        with self._lock:
            has_targets = bool(self._users.get(user_id))
        if has_targets:
            self._schedule(self.send_to_user(user_id, event_type, data))


realtime_hub = RealtimeConnectionManager()
