from __future__ import annotations
import base64
from dataclasses import dataclass
from datetime import datetime, timedelta, timezone
import hashlib
import hmac
import secrets
import struct
import time
import zlib

import jwt

from app.core.config import get_settings
from app.core.exceptions import ServiceUnavailableError
from app.core.security import hash_secret_value


@dataclass
class GeneratedStreamKey:
    raw_key: str
    masked_key: str
    digest: str


@dataclass
class IssuedRtcCredentials:
    provider: str
    token: str | None
    server_url: str | None
    app_id: str | None
    expires_at: datetime | None


def generate_stream_key() -> GeneratedStreamKey:
    """Create a cryptographically random RTMP stream key and store only its HMAC digest."""
    raw = f"tk_{secrets.token_urlsafe(24)}"
    masked = f"{raw[:6]}...{raw[-4:]}"
    return GeneratedStreamKey(
        raw_key=raw,
        masked_key=masked,
        digest=hash_secret_value(raw),
    )


def build_rtmp_urls(room_key: str, raw_stream_key: str | None = None) -> tuple[str, str, str | None]:
    settings = get_settings()
    ingest_base = settings.rtmp_ingest_base_url.strip().rstrip("/")
    playback_hls_url = f"{settings.effective_hls_live_base_url}/{room_key}.m3u8"
    publish_url = f"{ingest_base}/{raw_stream_key}" if raw_stream_key else None
    return ingest_base, playback_hls_url, publish_url


def _pack_uint16(val: int) -> bytes:
    return struct.pack("<H", val)


def _pack_uint32(val: int) -> bytes:
    return struct.pack("<I", val)


def _pack_bytes(raw: bytes) -> bytes:
    return _pack_uint16(len(raw)) + raw


def _pack_string(text: str) -> bytes:
    return _pack_bytes(text.encode("utf-8"))


def _pack_map_uint32(mapping: dict[int, int]) -> bytes:
    encoded = b"".join(
        _pack_uint16(k) + _pack_uint32(v) for k, v in sorted(mapping.items())
    )
    return _pack_uint16(len(mapping)) + encoded


def issue_livekit_token(
    room_key: str,
    identity: str,
    display_name: str,
    can_publish: bool,
) -> IssuedRtcCredentials:
    """Sign a real LiveKit AccessToken JWT using LIVEKIT_API_KEY and LIVEKIT_API_SECRET."""
    settings = get_settings()
    api_key = settings.livekit_api_key.strip()
    api_secret = settings.livekit_api_secret.strip()
    server_url = settings.livekit_url.strip()

    if not api_key or not api_secret or not server_url:
        raise ServiceUnavailableError(
            "LiveKit is selected but LIVEKIT_URL, LIVEKIT_API_KEY, and LIVEKIT_API_SECRET are not configured in .env"
        )

    now = datetime.now(timezone.utc)
    exp = now + timedelta(seconds=settings.rtc_token_expire_seconds)
    claims = {
        "iss": api_key,
        "sub": identity,
        "name": display_name,
        "nbf": int(now.timestamp()),
        "exp": int(exp.timestamp()),
        "video": {
            "roomJoin": True,
            "room": room_key,
            "canPublish": can_publish,
            "canSubscribe": True,
            "canPublishData": True,
        },
    }
    token = jwt.encode(claims, api_secret, algorithm="HS256")
    return IssuedRtcCredentials(
        provider="livekit",
        token=token,
        server_url=server_url,
        app_id=None,
        expires_at=exp.replace(tzinfo=None),
    )


def issue_agora_rtc_token(
    room_key: str,
    user_account: str,
    can_publish: bool,
) -> IssuedRtcCredentials:
    """Generate a real Agora AccessToken2 (007) RTC token using AGORA_APP_ID & AGORA_APP_CERTIFICATE."""
    settings = get_settings()
    app_id = settings.agora_app_id.strip()
    app_cert = settings.agora_app_certificate.strip()
    if not app_id or not app_cert:
        raise ServiceUnavailableError(
            "Agora is selected but AGORA_APP_ID and AGORA_APP_CERTIFICATE are not configured in .env"
        )

    issue_ts = int(time.time())
    expire_seconds = settings.rtc_token_expire_seconds
    salt = secrets.randbelow(99_999_999) + 1
    privilege_expire = issue_ts + expire_seconds

    privileges = {1: privilege_expire}  # kPrivilegeJoinChannel
    if can_publish:
        privileges[2] = privilege_expire  # kPrivilegePublishAudioStream
        privileges[3] = privilege_expire  # kPrivilegePublishVideoStream
        privileges[4] = privilege_expire  # kPrivilegePublishDataStream

    # ServiceRtc type = 1
    rtc_service = (
        _pack_uint16(1)
        + _pack_map_uint32(privileges)
        + _pack_string(room_key)
        + _pack_string(user_account)
    )
    signing_info = (
        _pack_string(app_id)
        + _pack_uint32(issue_ts)
        + _pack_uint32(expire_seconds)
        + _pack_uint32(salt)
        + _pack_uint16(1)
        + rtc_service
    )

    derived_key = hmac.new(
        _pack_uint32(issue_ts), app_cert.encode("utf-8"), hashlib.sha256
    ).digest()
    derived_key = hmac.new(_pack_uint32(salt), derived_key, hashlib.sha256).digest()
    signature = hmac.new(derived_key, signing_info, hashlib.sha256).digest()

    compressed = zlib.compress(_pack_bytes(signature) + signing_info)
    token = f"007{app_id}{base64.b64encode(compressed).decode('ascii')}"
    expires_at = datetime.now(timezone.utc) + timedelta(seconds=expire_seconds)
    return IssuedRtcCredentials(
        provider="agora",
        token=token,
        server_url=None,
        app_id=app_id,
        expires_at=expires_at.replace(tzinfo=None),
    )


def issue_rtc_credentials(
    provider: str,
    room_key: str,
    identity: str,
    display_name: str,
    can_publish: bool,
) -> IssuedRtcCredentials:
    if provider == "livekit":
        return issue_livekit_token(room_key, identity, display_name, can_publish)
    if provider == "agora":
        return issue_agora_rtc_token(room_key, identity, can_publish)
    # Pure RTMP ingest / LL-HLS playback requires no client RTC token
    return IssuedRtcCredentials(
        provider="rtmp",
        token=None,
        server_url=None,
        app_id=None,
        expires_at=None,
    )
