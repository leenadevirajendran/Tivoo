from __future__ import annotations
import shutil

from fastapi import APIRouter, Request
from fastapi.responses import HTMLResponse
from fastapi.templating import Jinja2Templates

from app.core.config import BACKEND_ROOT, get_settings
from app.db.session import check_db_health
from app.modules.notifications_fcm.fcm_client import fcm_client

router = APIRouter(tags=["Web Portal & Health"])

TEMPLATES_DIR = BACKEND_ROOT / "templates"
TEMPLATES_DIR.mkdir(parents=True, exist_ok=True)
templates = Jinja2Templates(directory=str(TEMPLATES_DIR))


@router.get("/", response_class=HTMLResponse)
def render_portal(request: Request) -> HTMLResponse:
    """Serve the responsive Tivoo creator studio & feed portal backed by MySQL."""
    settings = get_settings()
    return templates.TemplateResponse(
        request=request,
        name="index.html",
        context={
            "app_name": settings.app_name,
            "storage_backend": settings.storage_backend,
            "mail_sender": settings.mail_sender,
            "smtp_configured": bool(settings.mail_app_password.strip()),
            "max_video_upload_mb": settings.max_video_upload_mb,
            "max_image_upload_mb": settings.max_image_upload_mb,
            "db_name": settings.db_name,
        },
    )


@router.get("/api/health")
def health_check() -> dict[str, object]:
    """Report live MySQL database connectivity, FFmpeg readiness, storage, and SMTP config."""
    settings = get_settings()
    db_ok = check_db_health()
    ffmpeg_path = shutil.which(settings.ffmpeg_bin)
    ffprobe_path = shutil.which(settings.ffprobe_bin)

    overall_status = "ok" if db_ok else "degraded"
    return {
        "status": overall_status,
        "app": settings.app_name,
        "environment": settings.app_env,
        "database": {
            "connected": db_ok,
            "host": settings.db_host,
            "port": settings.db_port,
            "name": settings.db_name,
        },
        "storage": {
            "backend": settings.storage_backend,
            "bucket": settings.s3_bucket_name if settings.storage_backend != "local" else None,
        },
        "transcoding": {
            "enabled": settings.enable_auto_transcode,
            "ffmpegAvailable": bool(ffmpeg_path),
            "ffprobeAvailable": bool(ffprobe_path),
        },
        "emailOtp": {
            "sender": settings.mail_sender,
            "smtpHost": settings.mail_smtp_host,
            "smtpPort": settings.mail_smtp_port,
            "configured": bool(settings.mail_sender.strip() and settings.mail_app_password.strip()),
        },
        "liveStreaming": {
            "defaultProvider": settings.live_media_provider,
            "livekitConfigured": bool(
                settings.livekit_url.strip()
                and settings.livekit_api_key.strip()
                and settings.livekit_api_secret.strip()
            ),
            "agoraConfigured": bool(
                settings.agora_app_id.strip() and settings.agora_app_certificate.strip()
            ),
            "rtmpIngestBase": settings.rtmp_ingest_base_url,
        },
        "payments": {
            "stripeConfigured": bool(
                settings.stripe_secret_key.strip() and settings.stripe_webhook_secret.strip()
            ),
            "googlePlayConfigured": bool(settings.google_play_package_name.strip()),
            "appleIapConfigured": bool(
                settings.apple_bundle_id.strip() or settings.apple_shared_secret.strip()
            ),
        },
        "fcm": {
            "configured": fcm_client.is_configured(),
        },
    }
