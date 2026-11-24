from __future__ import annotations
from datetime import datetime

from pydantic import BaseModel, Field


class LeaderboardEntryResponse(BaseModel):
    rank: int
    userId: str
    name: str
    username: str
    avatarUrl: str = ""
    isVerified: bool = False
    vipLevel: int = 0
    score: int
    giftsCount: int


class LeaderboardResponse(BaseModel):
    boardType: str  # top_gifters | top_streamers
    period: str     # daily | weekly | monthly
    periodStart: datetime
    entries: list[LeaderboardEntryResponse]
    total: int


class VipTierCreateRequest(BaseModel):
    level: int = Field(..., ge=1, le=200)
    name: str = Field(..., min_length=2, max_length=64)
    tierBracket: str = Field(default="bronze", max_length=40)
    minCoinsSpent: int = Field(..., ge=1)
    badgeColorHex: str = Field(default="#FF3B6B", pattern=r"^#[0-9A-Fa-f]{6}$")
    frameUrl: str = Field(default="", max_length=512)
    perks: list[str] = Field(default_factory=list, max_length=20)
    isActive: bool = True


class VipTierResponse(BaseModel):
    level: int
    name: str
    tierBracket: str
    minCoinsSpent: int
    badgeColorHex: str
    frameUrl: str
    perks: list[str] = Field(default_factory=list)
    isActive: bool


class VipTierListResponse(BaseModel):
    tiers: list[VipTierResponse]
    total: int


class UserVipStatusResponse(BaseModel):
    userId: str
    totalCoinsSpent: int
    currentLevel: int
    currentTierName: str
    tierBracket: str
    badgeColorHex: str
    unlockedPerks: list[str] = Field(default_factory=list)
    nextLevel: int | None = None
    nextTierName: str | None = None
    nextLevelMinCoins: int | None = None
    coinsToNextLevel: int = 0
    progressPercent: float = 0.0
