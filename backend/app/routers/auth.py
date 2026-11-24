from __future__ import annotations
from fastapi import APIRouter, Depends, status
from sqlalchemy.orm import Session

from app.core.security import get_current_user
from app.db.session import get_db
from app.models.user import User
from app.schemas.auth import (
    EmailOtpSendRequest,
    EmailOtpVerifyRequest,
    LoginRequest,
    LogoutRequest,
    OtpDispatchResponse,
    PasswordResetRequest,
    PhoneOtpSendRequest,
    PhoneOtpVerifyRequest,
    RefreshTokenRequest,
    RegisterRequest,
    TokenResponse,
)
from app.schemas.profile import UserProfileResponse
from app.services.auth_service import auth_service
from app.services.profile_service import profile_service

router = APIRouter(prefix="/api/auth", tags=["Authentication"])


@router.post("/register", response_model=TokenResponse, status_code=status.HTTP_201_CREATED)
def register(payload: RegisterRequest, db: Session = Depends(get_db)) -> TokenResponse:
    """Create a new user account in MySQL and optionally dispatch an email verification OTP."""
    return auth_service.register(db, payload)


@router.post("/login", response_model=TokenResponse)
def login(payload: LoginRequest, db: Session = Depends(get_db)) -> TokenResponse:
    """Authenticate by email, username, or phone number and return JWT access + refresh tokens."""
    return auth_service.login_with_password(db, payload)


@router.post("/email/send-otp", response_model=OtpDispatchResponse)
def send_email_otp(payload: EmailOtpSendRequest, db: Session = Depends(get_db)) -> OtpDispatchResponse:
    """Generate and email a real 6-digit OTP via configured SMTP sender."""
    return auth_service.send_email_otp(db, payload)


@router.post("/email/verify-otp", response_model=TokenResponse)
def verify_email_otp(payload: EmailOtpVerifyRequest, db: Session = Depends(get_db)) -> TokenResponse:
    """Verify an email OTP and sign in or verify the user's email address."""
    return auth_service.verify_email_otp(db, payload)


@router.post("/phone/send-otp", response_model=OtpDispatchResponse)
def send_phone_otp(payload: PhoneOtpSendRequest, db: Session = Depends(get_db)) -> OtpDispatchResponse:
    """Generate and dispatch a real SMS OTP when an SMS gateway provider is configured."""
    return auth_service.send_phone_otp(db, payload)


@router.post("/phone/verify-otp", response_model=TokenResponse)
def verify_phone_otp(payload: PhoneOtpVerifyRequest, db: Session = Depends(get_db)) -> TokenResponse:
    """Verify a phone OTP and sign in or verify the user's phone number."""
    return auth_service.verify_phone_otp(db, payload)


@router.post("/reset-password")
def reset_password(payload: PasswordResetRequest, db: Session = Depends(get_db)) -> dict[str, str]:
    """Reset account password using a verified email or phone OTP."""
    return auth_service.reset_password_with_otp(db, payload)


@router.post("/refresh", response_model=TokenResponse)
def refresh_tokens(payload: RefreshTokenRequest, db: Session = Depends(get_db)) -> TokenResponse:
    """Rotate refresh token and issue a fresh JWT access token pair."""
    return auth_service.refresh_session(db, payload.refreshToken)


@router.post("/logout")
def logout(
    payload: LogoutRequest,
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db),
) -> dict[str, str]:
    """Revoke the provided refresh token (or all active tokens for the user)."""
    return auth_service.logout(db, current_user, payload.refreshToken)


@router.get("/me", response_model=UserProfileResponse)
def get_authenticated_user(
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db),
) -> UserProfileResponse:
    """Return the authenticated user's profile including private email/phone fields."""
    return profile_service.serialize_profile(
        db,
        current_user,
        viewer_id=current_user.id,
        include_private_contact=True,
    )

