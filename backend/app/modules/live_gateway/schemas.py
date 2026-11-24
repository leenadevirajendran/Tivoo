from __future__ import annotations
from datetime import datetime
from typing import Literal

from pydantic import BaseModel, Field


class CreateLiveRoomRequest(BaseModel):
    title: str = Field(..., min_length=2, max_length=180)
    category: str = Field(default="Entertainment", max_length=60)
    coverUrl: str = Field(default="", max_length=512)
    provider: Literal["livekit", "agora", "rtmp"] | None = None
    allowChat: bool = True
    allowGifts: bool = True
    allowPk: bool = True


class LiveRoomResponse(BaseModel):
    id: str
    roomKey: str
    hostId: str
    hostName: str
    hostUsername: str
    hostAvatar: str = ""
    title: str
    category: str
    coverUrl: str = ""
    provider: str
    status: str
    streamKeyMasked: str
    rtmpIngestUrl: str
    playbackHlsUrl: str
    allowChat: bool
    allowGifts: bool
    allowPk: bool
    viewerCount: int
    peakViewers: int
    likesCount: int
    totalGiftsDiamonds: int
    startedAt: datetime | None = None
    endedAt: datetime | None = None
    createdAt: datetime


class LiveRoomCreatedResponse(LiveRoomResponse):
    """Returned on creation or key rotation with one-time raw RTMP stream key."""

    streamKey: str
    rtmpPublishUrl: str


class LiveRoomListResponse(BaseModel):
    rooms: list[LiveRoomResponse]
    total: int
    page: int
    pageSize: int
    hasMore: bool


class RtcTokenResponse(BaseModel):
    provider: str
    roomId: str
    roomKey: str
    identity: str
    role: Literal["host", "cohost", "viewer"]
    token: str | None = None
    serverUrl: str | None = None
    appId: str | None = None
    playbackHlsUrl: str
    expiresAt: datetime | None = None


class RtmpWebhookRequest(BaseModel):
    action: Literal["on_publish", "on_done"]
    roomKey: str = Field(..., min_length=3, max_length=64)
    streamKey: str = Field(..., min_length=8, max_length=128)
