from __future__ import annotations
from dataclasses import dataclass
import json
from pathlib import Path
import threading
import time
from typing import Any

import httpx
import jwt

from app.core.config import BACKEND_ROOT, get_settings

FCM_SCOPE = "https://www.googleapis.com/auth/firebase.messaging"
DEFAULT_TOKEN_URI = "https://oauth2.googleapis.com/token"


@dataclass
class FcmDispatchOutcome:
    status: str  # sent | partial_failure | failed | skipped_unconfigured | no_device_tokens
    error: str | None = None
    invalid_tokens: list[str] | None = None


class FcmHttpV1Client:
    """Real Firebase Cloud Messaging HTTP v1 client using Service Account OAuth2 JWT."""

    def __init__(self) -> None:
        self._lock = threading.Lock()
        self._cached_access_token: str | None = None
        self._cached_token_expiry: float = 0.0

    def _load_service_account(self) -> tuple[str, dict[str, Any]] | None:
        settings = get_settings()
        raw_json = settings.fcm_service_account_json.strip()
        sa_data: dict[str, Any] | None = None

        if raw_json:
            try:
                sa_data = json.loads(raw_json)
            except json.JSONDecodeError:
                return None
        elif settings.fcm_service_account_path.strip():
            raw_path = Path(settings.fcm_service_account_path.strip())
            resolved = raw_path if raw_path.is_absolute() else (BACKEND_ROOT / raw_path)
            if not resolved.is_file():
                return None
            try:
                sa_data = json.loads(resolved.read_text(encoding="utf-8"))
            except (OSError, json.JSONDecodeError):
                return None

        if not sa_data:
            return None

        project_id = settings.fcm_project_id.strip() or str(sa_data.get("project_id", "")).strip()
        if not project_id or not sa_data.get("client_email") or not sa_data.get("private_key"):
            return None
        return project_id, sa_data

    def is_configured(self) -> bool:
        return self._load_service_account() is not None

    def _get_oauth_access_token(self, sa_data: dict[str, Any]) -> str:
        now = time.time()
        with self._lock:
            if self._cached_access_token and now < (self._cached_token_expiry - 60):
                return self._cached_access_token

        token_uri = str(sa_data.get("token_uri") or DEFAULT_TOKEN_URI)
        assertion = jwt.encode(
            {
                "iss": sa_data["client_email"],
                "scope": FCM_SCOPE,
                "aud": token_uri,
                "iat": int(now),
                "exp": int(now + 3600),
            },
            sa_data["private_key"],
            algorithm="RS256",
        )

        settings = get_settings()
        with httpx.Client(timeout=settings.fcm_http_timeout_seconds) as client:
            resp = client.post(
                token_uri,
                data={
                    "grant_type": "urn:ietf:params:oauth:grant-type:jwt-bearer",
                    "assertion": assertion,
                },
            )
            resp.raise_for_status()
            payload = resp.json()

        access_token = str(payload["access_token"])
        expires_in = int(payload.get("expires_in", 3600))
        with self._lock:
            self._cached_access_token = access_token
            self._cached_token_expiry = time.time() + expires_in
        return access_token

    def send_to_tokens(
        self,
        tokens: list[str],
        title: str,
        body: str,
        data: dict[str, str],
    ) -> FcmDispatchOutcome:
        if not tokens:
            return FcmDispatchOutcome(status="no_device_tokens")

        loaded = self._load_service_account()
        if not loaded:
            return FcmDispatchOutcome(
                status="skipped_unconfigured",
                error="FCM_SERVICE_ACCOUNT_PATH or FCM_SERVICE_ACCOUNT_JSON is not configured in .env",
            )

        project_id, sa_data = loaded
        try:
            bearer = self._get_oauth_access_token(sa_data)
        except Exception as exc:
            return FcmDispatchOutcome(status="failed", error=f"OAuth2 token error: {exc}")

        endpoint = f"https://fcm.googleapis.com/v1/projects/{project_id}/messages:send"
        settings = get_settings()
        headers = {"Authorization": f"Bearer {bearer}", "Content-Type": "application/json"}
        string_data = {str(k): str(v) for k, v in data.items()}

        sent = 0
        invalid_tokens: list[str] = []
        errors: list[str] = []

        with httpx.Client(timeout=settings.fcm_http_timeout_seconds) as client:
            for token in tokens:
                message_payload = {
                    "message": {
                        "token": token,
                        "notification": {"title": title, "body": body},
                        "data": string_data,
                        "android": {"priority": "high"},
                        "apns": {"headers": {"apns-priority": "10"}},
                    }
                }
                try:
                    res = client.post(endpoint, headers=headers, json=message_payload)
                    if 200 <= res.status_code < 300:
                        sent += 1
                        continue
                    err_text = res.text[:300]
                    errors.append(f"HTTP {res.status_code}: {err_text}")
                    if "UNREGISTERED" in err_text or "registration-token-not-registered" in err_text:
                        invalid_tokens.append(token)
                except Exception as exc:
                    errors.append(str(exc))

        if sent == len(tokens):
            return FcmDispatchOutcome(status="sent", invalid_tokens=invalid_tokens)
        if sent > 0:
            return FcmDispatchOutcome(
                status="partial_failure",
                error="; ".join(errors[:3]),
                invalid_tokens=invalid_tokens,
            )
        return FcmDispatchOutcome(
            status="failed",
            error="; ".join(errors[:3]) or "FCM send failed",
            invalid_tokens=invalid_tokens,
        )


fcm_client = FcmHttpV1Client()
