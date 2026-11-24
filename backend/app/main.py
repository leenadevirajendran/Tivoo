from __future__ import annotations
import asyncio
from collections.abc import AsyncIterator
from contextlib import asynccontextmanager
import mimetypes

from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from fastapi.staticfiles import StaticFiles

from app.core.config import BACKEND_ROOT, get_settings
from app.core.exceptions import register_exception_handlers
from app.db.session import init_db
from app.modules.chat_realtime import chat_router, dm_router, ws_router
from app.modules.leaderboards_vip import leaderboard_router, vip_router
from app.modules.live_gateway import router as live_router
from app.modules.notifications_fcm import router as notifications_router
from app.modules.pk_battle import router as pk_router
from app.modules.wallet_gifts import gifts_router, wallet_router, webhooks_router
from app.realtime.connection_manager import realtime_hub
from app.routers import (
    auth_router,
    comments_router,
    feed_router,
    follows_router,
    profiles_router,
    users_router,
    videos_router,
    web_router,
)
from app.services.transcoder_service import transcoder_service


def _register_media_mime_types() -> None:
    """Ensure HLS playlists, MPEG-TS segments, and MP4 assets serve proper MIME headers."""
    mimetypes.add_type("application/vnd.apple.mpegurl", ".m3u8")
    mimetypes.add_type("video/mp2t", ".ts")
    mimetypes.add_type("video/mp4", ".mp4")
    mimetypes.add_type("image/webp", ".webp")


@asynccontextmanager
async def lifespan(_: FastAPI) -> AsyncIterator[None]:
    """Initialize MySQL schema, bind WebSocket event loop, and clean up workers on shutdown."""
    settings = get_settings()
    if settings.storage_backend == "local":
        settings.local_storage_path.mkdir(parents=True, exist_ok=True)
    init_db()
    realtime_hub.set_event_loop(asyncio.get_running_loop())
    try:
        yield
    finally:
        transcoder_service.shutdown()


def create_app() -> FastAPI:
    """Build and configure the FastAPI application instance."""
    settings = get_settings()
    _register_media_mime_types()

    app = FastAPI(
        title=settings.app_name,
        version="2.0.0",
        description=(
            "Tivoo Creator Backend — MySQL (tivoo) Authentication, OTP, Profiles, Reels HLS, "
            "Live Streaming Gateway (LiveKit/Agora/RTMP), PK Battle Engine, ACID Virtual Gift "
            "& Wallet Ledger, Real-Time Chat/Barrage/DM WebSockets, Leaderboards/VIP, and FCM Push."
        ),
        lifespan=lifespan,
    )

    cors_origins = settings.cors_origin_list
    app.add_middleware(
        CORSMiddleware,
        allow_origins=cors_origins,
        allow_credentials=cors_origins != ["*"],
        allow_methods=["*"],
        allow_headers=["*"],
    )

    register_exception_handlers(app)

    static_dir = BACKEND_ROOT / "static"
    static_dir.mkdir(parents=True, exist_ok=True)
    app.mount("/static", StaticFiles(directory=str(static_dir)), name="static")

    if settings.storage_backend == "local":
        settings.local_storage_path.mkdir(parents=True, exist_ok=True)
        app.mount(
            "/media",
            StaticFiles(directory=str(settings.local_storage_path)),
            name="media",
        )

    app.include_router(web_router)
    app.include_router(auth_router)
    app.include_router(profiles_router)
    app.include_router(users_router)
    app.include_router(follows_router)
    app.include_router(videos_router)
    app.include_router(feed_router)
    app.include_router(comments_router)
    app.include_router(live_router)
    app.include_router(pk_router)
    app.include_router(wallet_router)
    app.include_router(gifts_router)
    app.include_router(webhooks_router)
    app.include_router(chat_router)
    app.include_router(dm_router)
    app.include_router(ws_router)
    app.include_router(leaderboard_router)
    app.include_router(vip_router)
    app.include_router(notifications_router)

    return app


app = create_app()

