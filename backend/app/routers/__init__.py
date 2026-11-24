from __future__ import annotations
from app.routers.auth import router as auth_router
from app.routers.profiles import follows_router, router as profiles_router, users_router
from app.routers.videos import comments_router, feed_router, router as videos_router
from app.routers.web import router as web_router

__all__ = [
    "auth_router",
    "profiles_router",
    "users_router",
    "follows_router",
    "videos_router",
    "feed_router",
    "comments_router",
    "web_router",
]

