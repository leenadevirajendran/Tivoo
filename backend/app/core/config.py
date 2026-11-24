from __future__ import annotations
from functools import lru_cache
from pathlib import Path
from typing import Literal
from urllib.parse import quote_plus

from pydantic import Field, computed_field
from pydantic_settings import BaseSettings, SettingsConfigDict

BACKEND_ROOT = Path(__file__).resolve().parents[2]


class Settings(BaseSettings):
    """Application settings loaded strictly from environment / .env."""

    model_config = SettingsConfigDict(
        env_file=str(BACKEND_ROOT / ".env"),
        env_file_encoding="utf-8",
        extra="ignore",
        case_sensitive=False,
    )

    # Application
    app_name: str = Field(default="Tivoo API")
    app_env: str = Field(default="production")
    app_debug: bool = Field(default=False)
    api_host: str = Field(default="0.0.0.0")
    api_port: int = Field(default=8000, ge=1, le=65535)
    public_base_url: str = Field(default="http://localhost:8000")
    allowed_origins: str = Field(default="*")

    # MySQL Database
    db_host: str = Field(...)
    db_port: int = Field(default=3306, ge=1, le=65535)
    db_name: str = Field(...)
    db_user: str = Field(...)
    db_password: str = Field(default="")
    db_charset: str = Field(default="utf8mb4")
    db_pool_size: int = Field(default=10, ge=1)
    db_max_overflow: int = Field(default=20, ge=0)

    # Security & JWT
    jwt_secret_key: str = Field(..., min_length=32)
    jwt_algorithm: str = Field(default="HS256")
    access_token_expire_minutes: int = Field(default=60, ge=5)
    refresh_token_expire_days: int = Field(default=30, ge=1)
    otp_expire_minutes: int = Field(default=10, ge=1)
    otp_length: int = Field(default=6, ge=4, le=8)
    otp_max_attempts: int = Field(default=5, ge=1)
    otp_resend_cooldown_seconds: int = Field(default=45, ge=0)

    # Email SMTP
    mail_sender: str = Field(default="")
    mail_sender_name: str = Field(default="Tivoo")
    mail_smtp_host: str = Field(default="smtp.gmail.com")
    mail_smtp_port: int = Field(default=587)
    mail_use_tls: bool = Field(default=True)
    mail_app_password: str = Field(default="")

    # SMS OTP
    sms_provider: Literal["none", "twilio", "webhook"] = Field(default="none")
    twilio_account_sid: str = Field(default="")
    twilio_auth_token: str = Field(default="")
    twilio_from_number: str = Field(default="")
    sms_webhook_url: str = Field(default="")
    sms_webhook_api_key: str = Field(default="")

    # Storage (local | s3 | r2)
    storage_backend: Literal["local", "s3", "r2"] = Field(default="local")
    local_storage_dir: str = Field(default="storage")
    max_video_upload_mb: int = Field(default=500, ge=1)
    max_image_upload_mb: int = Field(default=15, ge=1)

    s3_bucket_name: str = Field(default="")
    s3_region: str = Field(default="auto")
    s3_endpoint_url: str = Field(default="")
    s3_access_key_id: str = Field(default="")
    s3_secret_access_key: str = Field(default="")
    cdn_public_base_url: str = Field(default="")

    # Transcoding (FFmpeg / HLS)
    ffmpeg_bin: str = Field(default="ffmpeg")
    ffprobe_bin: str = Field(default="ffprobe")
    transcode_max_workers: int = Field(default=2, ge=1, le=8)
    hls_segment_seconds: int = Field(default=4, ge=2, le=10)
    enable_auto_transcode: bool = Field(default=True)

    # Admin Access
    admin_emails: str = Field(default="")

    # 3. Live Streaming Gateway (LiveKit / Agora / RTMP)
    live_media_provider: Literal["livekit", "agora", "rtmp"] = Field(default="livekit")
    livekit_url: str = Field(default="")
    livekit_api_key: str = Field(default="")
    livekit_api_secret: str = Field(default="")
    agora_app_id: str = Field(default="")
    agora_app_certificate: str = Field(default="")
    rtmp_ingest_base_url: str = Field(default="rtmp://localhost/live")
    hls_live_base_url: str = Field(default="")
    rtmp_webhook_secret: str = Field(default="")
    rtc_token_expire_seconds: int = Field(default=3600, ge=60, le=86400)

    # 4. PK Battle Engine
    pk_default_round_seconds: int = Field(default=300, ge=30, le=3600)
    pk_min_round_seconds: int = Field(default=30, ge=10)
    pk_max_round_seconds: int = Field(default=3600, le=7200)

    # 5. Virtual Gift, Wallet Ledger & Payments / Payouts
    gift_coin_to_diamond_rate: float = Field(default=0.70, gt=0.0, le=2.0)
    diamond_to_currency_rate: float = Field(default=0.50, gt=0.0)
    payout_currency: str = Field(default="INR", max_length=8)
    min_withdrawal_diamonds: int = Field(default=100, ge=1)
    stripe_secret_key: str = Field(default="")
    stripe_webhook_secret: str = Field(default="")
    stripe_success_url: str = Field(default="http://localhost:8000/?payment=success")
    stripe_cancel_url: str = Field(default="http://localhost:8000/?payment=cancelled")
    google_play_package_name: str = Field(default="")
    google_play_webhook_secret: str = Field(default="")
    google_play_service_account_json: str = Field(default="")
    apple_bundle_id: str = Field(default="")
    apple_shared_secret: str = Field(default="")
    apple_iap_webhook_secret: str = Field(default="")

    # 8. Push Notifications (Firebase Cloud Messaging HTTP v1)
    fcm_project_id: str = Field(default="")
    fcm_service_account_path: str = Field(default="")
    fcm_service_account_json: str = Field(default="")
    fcm_http_timeout_seconds: float = Field(default=10.0, gt=0.5)

    @computed_field
    @property
    def database_url(self) -> str:
        user_enc = quote_plus(self.db_user)
        pass_enc = quote_plus(self.db_password)
        auth = f"{user_enc}:{pass_enc}" if self.db_password else user_enc
        return (
            f"mysql+pymysql://{auth}@{self.db_host}:{self.db_port}/"
            f"{self.db_name}?charset={self.db_charset}"
        )

    @computed_field
    @property
    def cors_origin_list(self) -> list[str]:
        raw = self.allowed_origins.strip()
        if not raw or raw == "*":
            return ["*"]
        return [origin.strip() for origin in raw.split(",") if origin.strip()]

    @computed_field
    @property
    def local_storage_path(self) -> Path:
        path = Path(self.local_storage_dir)
        return path if path.is_absolute() else (BACKEND_ROOT / path).resolve()

    @computed_field
    @property
    def max_video_upload_bytes(self) -> int:
        return self.max_video_upload_mb * 1024 * 1024

    @computed_field
    @property
    def max_image_upload_bytes(self) -> int:
        return self.max_image_upload_mb * 1024 * 1024

    @computed_field
    @property
    def admin_email_set(self) -> set[str]:
        return {
            email.strip().lower()
            for email in self.admin_emails.split(",")
            if email.strip()
        }

    @computed_field
    @property
    def effective_hls_live_base_url(self) -> str:
        base = self.hls_live_base_url.strip().rstrip("/")
        if base:
            return base
        return f"{self.public_base_url.rstrip('/')}/hls-live"


@lru_cache
def get_settings() -> Settings:
    return Settings()

