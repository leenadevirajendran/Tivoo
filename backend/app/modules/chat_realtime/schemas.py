from __future__ import annotations
from datetime import datetime
from typing import Literal

from pydantic import BaseModel, Field


class LiveChatCreateRequest(BaseModel):
    messageType: Literal["chat", "barrage", "heart"] = "chat"
    content: str = Field(..., min_length=1, max_length=500)
    colorHex: str = Field(default="#FFFFFF", pattern=r"^#[0-9A-Fa-f]{6}$")


class LiveChatMessageResponse(BaseModel):
    id: str
    roomId: str
    senderId: str
    senderName: str
    senderUsername: str
    senderAvatar: str = ""
    messageType: str
    content: str
    colorHex: str
    isPinned: bool = False
    createdAt: datetime


class LiveChatListResponse(BaseModel):
    messages: list[LiveChatMessageResponse]
    total: int


class DmSendRequest(BaseModel):
    messageType: Literal["text", "image", "heart"] = "text"
    content: str = Field(..., min_length=1, max_length=4000)
    mediaUrl: str | None = Field(default=None, max_length=512)


class DmMessageResponse(BaseModel):
    id: str
    conversationId: str
    senderId: str
    recipientId: str
    senderName: str
    senderUsername: str
    senderAvatar: str = ""
    messageType: str
    content: str
    mediaUrl: str | None = None
    isRead: bool
    readAt: datetime | None = None
    createdAt: datetime


class DmConversationResponse(BaseModel):
    id: str
    peerId: str
    peerName: str
    peerUsername: str
    peerAvatar: str = ""
    peerVerified: bool = False
    peerOnline: bool = False
    lastMessage: str
    lastMessageTime: datetime
    unreadCount: int = 0


class DmInboxResponse(BaseModel):
    conversations: list[DmConversationResponse]
    total: int


class DmThreadListResponse(BaseModel):
    conversationId: str
    messages: list[DmMessageResponse]
    total: int
    page: int
    pageSize: int
    hasMore: bool
