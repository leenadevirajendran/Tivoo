from __future__ import annotations
from datetime import datetime
from typing import Literal

from pydantic import BaseModel, Field


class RegisterDeviceRequest(BaseModel):
    fcmToken: str = Field(..., min_length=12, max_length=512)
    platform: Literal["android", "ios", "web"] = "android"
    deviceId: str = Field(default="", max_length=128)


class UnregisterDeviceRequest(BaseModel):
    fcmToken: str = Field(..., min_length=12, max_length=512)


class DeviceTokenResponse(BaseModel):
    id: str
    userId: str
    platform: str
    deviceId: str
    isActive: bool
    lastSeenAt: datetime


class NotificationResponse(BaseModel):
    id: str
    userId: str
    actorId: str | None = None
    notificationType: str
    title: str
    body: str
    data: dict[str, str] = Field(default_factory=dict)
    fcmStatus: str
    fcmError: str | None = None
    isRead: bool
    readAt: datetime | None = None
    createdAt: datetime


class NotificationListResponse(BaseModel):
    notifications: list[NotificationResponse]
    unreadCount: int
    total: int
    page: int
    pageSize: int
    hasMore: bool


class MarkNotificationsReadResponse(BaseModel):
    updatedCount: int
    unreadCount: int
