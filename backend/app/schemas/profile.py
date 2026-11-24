from __future__ import annotations
from datetime import datetime
from typing import Literal

from pydantic import BaseModel, Field


class UserProfileResponse(BaseModel):
    id: str
    name: str
    username: str
    bio: str = ""
    aboutMe: str = ""
    avatarUrl: str = ""
    coverBackgroundUrl: str = ""
    email: str = ""
    phoneNumber: str = ""
    roles: list[str] = Field(default_factory=list)
    isVerified: bool = False
    isEmailVerified: bool = False
    isPhoneVerified: bool = False
    isPrivate: bool = False
    isOnline: bool = True
    followingCount: int = 0
    followersCount: str = "0"
    followersCountNum: int = 0
    likesCount: str = "0"
    likesCountNum: int = 0
    liveStreamsCount: int = 0
    totalViews: str = "0"
    followStatus: str = "notFollowing"
    createdAt: datetime


class UpdateProfileRequest(BaseModel):
    name: str | None = Field(default=None, min_length=2, max_length=100)
    username: str | None = Field(default=None, min_length=3, max_length=50, pattern=r"^[a-zA-Z0-9._]+$")
    bio: str | None = Field(default=None, max_length=300)
    aboutMe: str | None = Field(default=None, max_length=2000)
    roles: list[str] | None = Field(default=None, max_length=5)
    isPrivate: bool | None = None
    isOnline: bool | None = None


class FollowRelationshipResponse(BaseModel):
    userId: str
    userName: str
    userFullName: str = ""
    userAvatar: str = ""
    status: Literal["notFollowing", "requested", "following", "mutual", "blocked"]
    theyFollowMe: bool = False
    isMutual: bool = False
    followerCount: int = 0
    isCloseFriend: bool = False
    isMuted: bool = False
    requestedAt: datetime | None = None
    followedAt: datetime | None = None


class FollowListResponse(BaseModel):
    items: list[FollowRelationshipResponse]
    total: int

