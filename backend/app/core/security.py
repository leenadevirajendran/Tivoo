from __future__ import annotations
import hashlib
import hmac
import secrets
from datetime import datetime, timedelta, timezone
from typing import Any
import uuid

import bcrypt
import jwt
from fastapi import Depends, HTTPException, status
from fastapi.security import HTTPAuthorizationCredentials, HTTPBearer
from sqlalchemy.orm import Session

from app.core.config import get_settings
from app.db.session import get_db

bearer_scheme = HTTPBearer(auto_error=False)


def utc_now() -> datetime:
    """Return timezone-naive UTC datetime compatible with MySQL DATETIME columns."""
    return datetime.now(timezone.utc).replace(tzinfo=None)


def hash_password(password: str) -> str:
    """Hash a plain-text password with bcrypt."""
    salt = bcrypt.gensalt(rounds=12)
    return bcrypt.hashpw(password.encode("utf-8"), salt).decode("utf-8")


def verify_password(plain_password: str, password_hash: str | None) -> bool:
    """Verify a plain-text password against a stored bcrypt hash."""
    if not password_hash or not plain_password:
        return False
    try:
        return bcrypt.checkpw(plain_password.encode("utf-8"), password_hash.encode("utf-8"))
    except ValueError:
        return False


def generate_otp_code(length: int | None = None) -> str:
    """Generate a cryptographically random numeric OTP of configured length."""
    settings = get_settings()
    digits = length or settings.otp_length
    upper = 10**digits
    code = secrets.randbelow(upper)
    return f"{code:0{digits}d}"


def hash_secret_value(value: str) -> str:
    """Produce a keyed HMAC-SHA256 hex digest for OTPs and refresh tokens."""
    settings = get_settings()
    return hmac.new(
        settings.jwt_secret_key.encode("utf-8"),
        value.encode("utf-8"),
        hashlib.sha256,
    ).hexdigest()


def verify_secret_value(raw_value: str, expected_digest: str) -> bool:
    """Constant-time verification of a hashed OTP or refresh token."""
    computed = hash_secret_value(raw_value)
    return hmac.compare_digest(computed, expected_digest)


def create_access_token(user_id: str, extra_claims: dict[str, Any] | None = None) -> tuple[str, int]:
    """Create a signed JWT access token and return (token, expires_in_seconds)."""
    settings = get_settings()
    now = datetime.now(timezone.utc)
    expires_delta = timedelta(minutes=settings.access_token_expire_minutes)
    exp = now + expires_delta

    payload: dict[str, Any] = {
        "sub": user_id,
        "type": "access",
        "jti": uuid.uuid4().hex,
        "iat": int(now.timestamp()),
        "exp": int(exp.timestamp()),
    }
    if extra_claims:
        payload.update(extra_claims)

    token = jwt.encode(payload, settings.jwt_secret_key, algorithm=settings.jwt_algorithm)
    return token, int(expires_delta.total_seconds())


def create_refresh_token(user_id: str) -> tuple[str, str, datetime]:
    """Create a signed JWT refresh token and return (token, jti, naive_utc_expires_at)."""
    settings = get_settings()
    now = datetime.now(timezone.utc)
    expires_delta = timedelta(days=settings.refresh_token_expire_days)
    exp = now + expires_delta
    jti = uuid.uuid4().hex

    payload: dict[str, Any] = {
        "sub": user_id,
        "type": "refresh",
        "jti": jti,
        "iat": int(now.timestamp()),
        "exp": int(exp.timestamp()),
    }
    token = jwt.encode(payload, settings.jwt_secret_key, algorithm=settings.jwt_algorithm)
    return token, jti, exp.replace(tzinfo=None)


def decode_jwt_token(token: str, expected_type: str = "access") -> dict[str, Any]:
    """Decode and validate a JWT token, raising HTTP 401 if invalid or expired."""
    settings = get_settings()
    try:
        payload = jwt.decode(
            token,
            settings.jwt_secret_key,
            algorithms=[settings.jwt_algorithm],
        )
    except jwt.ExpiredSignatureError as exc:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Token has expired",
        ) from exc
    except jwt.InvalidTokenError as exc:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Invalid authentication token",
        ) from exc

    if payload.get("type") != expected_type or not payload.get("sub"):
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail=f"Invalid {expected_type} token payload",
        )
    return payload


def get_user_from_access_token(token: str, db: Session):
    """Validate a raw Bearer JWT string (for REST or WebSocket auth) and return active User."""
    from app.models.user import User

    payload = decode_jwt_token(token, expected_type="access")
    user = db.get(User, payload["sub"])
    if not user or not user.is_active:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="User account not found or inactive",
        )
    return user


def get_current_user(
    credentials: HTTPAuthorizationCredentials | None = Depends(bearer_scheme),
    db: Session = Depends(get_db),
):
    """Require a valid Bearer JWT and return the active User row from MySQL."""
    if not credentials or not credentials.credentials:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Authentication required",
        )
    return get_user_from_access_token(credentials.credentials, db)


def get_optional_current_user(
    credentials: HTTPAuthorizationCredentials | None = Depends(bearer_scheme),
    db: Session = Depends(get_db),
):
    """Return the authenticated User if a Bearer token is sent, otherwise None."""
    if not credentials or not credentials.credentials:
        return None
    return get_current_user(credentials=credentials, db=db)


def is_admin_user(user: Any) -> bool:
    """Return True if user carries an Admin role or matches configured ADMIN_EMAILS."""
    settings = get_settings()
    roles = {str(r).strip().lower() for r in (getattr(user, "roles", None) or [])}
    email = (getattr(user, "email", None) or "").strip().lower()
    return "admin" in roles or (bool(email) and email in settings.admin_email_set)


def require_admin_user(
    current_user=Depends(get_current_user),
):
    """Require Admin privileges (Admin role or configured ADMIN_EMAILS)."""
    if not is_admin_user(current_user):
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN,
            detail="Admin privileges are required for this action",
        )
    return current_user

