from __future__ import annotations
from app.modules.wallet_gifts.router import (
    gifts_router,
    router as wallet_router,
    webhooks_router,
)

__all__ = ["wallet_router", "gifts_router", "webhooks_router"]
