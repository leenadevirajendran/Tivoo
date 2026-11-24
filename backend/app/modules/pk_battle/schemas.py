from __future__ import annotations
from datetime import datetime

from pydantic import BaseModel, Field


class PkQueueJoinRequest(BaseModel):
    roomId: str | None = None
    durationSeconds: int | None = Field(default=None, ge=30, le=3600)


class PkChallengeRequest(BaseModel):
    opponentUserId: str = Field(..., min_length=3, max_length=36)
    roomId: str | None = None
    opponentRoomId: str | None = None
    durationSeconds: int | None = Field(default=None, ge=30, le=3600)


class PkAcceptRequest(BaseModel):
    roomId: str | None = None


class PkScoreRequest(BaseModel):
    targetHostId: str = Field(..., min_length=1, max_length=64)
    points: int = Field(default=10, ge=1, le=100000)
    giftName: str = Field(default="Heart", max_length=64)


class PkHostSummary(BaseModel):
    id: str
    name: str
    username: str
    avatarUrl: str = ""
    coverUrl: str = ""
    roomId: str | None = None
    score: int = 0


class PkBattleResponse(BaseModel):
    id: str
    status: str
    durationSeconds: int
    secondsLeft: int
    coverUrl: str = ""
    hostA: PkHostSummary
    hostB: PkHostSummary
    winnerId: str | None = None
    isDraw: bool = False
    startedAt: datetime | None = None
    endsAt: datetime | None = None
    endedAt: datetime | None = None
    createdAt: datetime


class PkQueueMatchResponse(BaseModel):
    matched: bool
    queueStatus: str  # waiting | matched | cancelled
    battle: PkBattleResponse | None = None


class PkBattleListResponse(BaseModel):
    battles: list[PkBattleResponse]
    total: int
    page: int
    pageSize: int
    hasMore: bool
