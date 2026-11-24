from __future__ import annotations
from typing import Literal

from fastapi import APIRouter, Depends, Query, status
from sqlalchemy.orm import Session

from app.core.security import get_current_user, require_admin_user
from app.db.session import get_db
from app.models.user import User
from app.modules.leaderboards_vip.schemas import (
    LeaderboardResponse,
    UserVipStatusResponse,
    VipTierCreateRequest,
    VipTierListResponse,
    VipTierResponse,
)
from app.modules.leaderboards_vip.service import leaderboard_vip_service

router = APIRouter(prefix="/api/leaderboards", tags=["Leaderboards"])
vip_router = APIRouter(prefix="/api/vip", tags=["Gifter Levels & VIP"])


@router.get("/gifters", response_model=LeaderboardResponse)
def get_top_gifters_leaderboard(
    period: Literal["daily", "weekly", "monthly"] = Query(default="daily"),
    limit: int = Query(default=50, ge=1, le=100),
    db: Session = Depends(get_db),
) -> LeaderboardResponse:
    """Rank top gifters by real Coins spent in Daily, Weekly, or Monthly MySQL windows."""
    return leaderboard_vip_service.get_top_gifters(db, period=period, limit=limit)


@router.get("/streamers", response_model=LeaderboardResponse)
def get_top_streamers_leaderboard(
    period: Literal["daily", "weekly", "monthly"] = Query(default="daily"),
    limit: int = Query(default=50, ge=1, le=100),
    db: Session = Depends(get_db),
) -> LeaderboardResponse:
    """Rank top streamers by real Diamonds earned in Daily, Weekly, or Monthly MySQL windows."""
    return leaderboard_vip_service.get_top_streamers(db, period=period, limit=limit)


@vip_router.get("/tiers", response_model=VipTierListResponse)
def list_vip_tiers(db: Session = Depends(get_db)) -> VipTierListResponse:
    """List VIP gifter level tiers configured in MySQL."""
    return leaderboard_vip_service.list_vip_tiers(db)


@vip_router.post("/tiers", response_model=VipTierResponse, status_code=status.HTTP_201_CREATED)
def upsert_vip_tier(
    payload: VipTierCreateRequest,
    _: User = Depends(require_admin_user),
    db: Session = Depends(get_db),
) -> VipTierResponse:
    """Admin endpoint to create or update a VIP tier milestone in MySQL."""
    return leaderboard_vip_service.upsert_vip_tier(db, payload)


@vip_router.get("/me", response_model=UserVipStatusResponse)
def get_my_vip_status(
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db),
) -> UserVipStatusResponse:
    """Compute the authenticated user's VIP gifter level from total Coins spent in MySQL."""
    return leaderboard_vip_service.get_user_vip_status(db, current_user.id)


@vip_router.get("/users/{user_id}", response_model=UserVipStatusResponse)
def get_user_vip_status(
    user_id: str,
    db: Session = Depends(get_db),
) -> UserVipStatusResponse:
    """Compute any creator's VIP gifter level from MySQL ledger totals."""
    return leaderboard_vip_service.get_user_vip_status(db, user_id)
