from __future__ import annotations
from typing import Literal

from pydantic import BaseModel, EmailStr, Field, model_validator

from app.schemas.profile import UserProfileResponse


class RegisterRequest(BaseModel):
    name: str = Field(..., min_length=2, max_length=100)
    username: str = Field(..., min_length=3, max_length=50, pattern=r"^[a-zA-Z0-9._]+$")
    email: EmailStr | None = None
    phoneNumber: str | None = Field(default=None, max_length=30)
    password: str = Field(..., min_length=8, max_length=72)
    bio: str = Field(default="", max_length=300)
    sendVerificationOtp: bool = False
    deviceInfo: str = Field(default="web", max_length=255)

    @model_validator(mode="before")
    @classmethod
    def normalize_register_fields(cls, data: object) -> object:
        if isinstance(data, dict):
            if not data.get("name"):
                data["name"] = data.get("fullName") or data.get("displayName") or "User"
        return data

    @model_validator(mode="after")
    def require_email_or_phone(self) -> "RegisterRequest":
        if not self.email and not (self.phoneNumber and self.phoneNumber.strip()):
            raise ValueError("Either email or phoneNumber is required")
        return self


class LoginRequest(BaseModel):
    identifier: str = Field(..., min_length=3, max_length=255, description="Email, username, or phone number")
    password: str = Field(..., min_length=1, max_length=72)
    deviceInfo: str = Field(default="web", max_length=255)

    @model_validator(mode="before")
    @classmethod
    def normalize_login_fields(cls, data: object) -> object:
        if isinstance(data, dict):
            if not data.get("identifier"):
                for alias in ("usernameOrEmail", "email", "username", "phone", "phoneNumber"):
                    if data.get(alias):
                        data["identifier"] = data[alias]
                        break
        return data


class EmailOtpSendRequest(BaseModel):
    email: EmailStr
    purpose: Literal["login", "verify_email", "reset_password"] = "login"


class EmailOtpVerifyRequest(BaseModel):
    email: EmailStr
    otp: str = Field(..., min_length=4, max_length=8)
    purpose: Literal["login", "verify_email", "reset_password"] = "login"
    name: str | None = Field(default=None, min_length=2, max_length=100)
    deviceInfo: str = Field(default="web", max_length=255)


class PhoneOtpSendRequest(BaseModel):
    phoneNumber: str = Field(..., min_length=7, max_length=30)
    purpose: Literal["login", "verify_phone", "reset_password"] = "login"


class PhoneOtpVerifyRequest(BaseModel):
    phoneNumber: str = Field(..., min_length=7, max_length=30)
    otp: str = Field(..., min_length=4, max_length=8)
    purpose: Literal["login", "verify_phone", "reset_password"] = "login"
    name: str | None = Field(default=None, min_length=2, max_length=100)
    deviceInfo: str = Field(default="web", max_length=255)


class PasswordResetRequest(BaseModel):
    channel: Literal["email", "phone"]
    target: str = Field(..., min_length=3, max_length=255)
    otp: str = Field(..., min_length=4, max_length=8)
    newPassword: str = Field(..., min_length=8, max_length=72)


class RefreshTokenRequest(BaseModel):
    refreshToken: str = Field(..., min_length=10)


class LogoutRequest(BaseModel):
    refreshToken: str | None = None


class TokenResponse(BaseModel):
    accessToken: str
    refreshToken: str
    tokenType: str = "bearer"
    expiresIn: int
    user: UserProfileResponse


class OtpDispatchResponse(BaseModel):
    message: str
    channel: Literal["email", "phone"]
    target: str
    purpose: str
    expiresInSeconds: int
    debugOtp: str | None = None

