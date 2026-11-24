from __future__ import annotations
import httpx

from app.core.config import get_settings
from app.core.exceptions import ServiceUnavailableError


class SmsService:
    """Real SMS OTP dispatcher configurable via .env (Twilio or HTTP Webhook)."""

    def send_otp_sms(self, phone_number: str, otp_code: str, purpose: str) -> None:
        settings = get_settings()
        provider = settings.sms_provider
        message = (
            f"Your Tivoo verification code is {otp_code}. "
            f"It expires in {settings.otp_expire_minutes} minutes."
        )

        if provider == "none":
            raise ServiceUnavailableError(
                "Phone SMS provider is not configured. Set SMS_PROVIDER (twilio or webhook) in backend .env."
            )

        if provider == "twilio":
            sid = settings.twilio_account_sid.strip()
            token = settings.twilio_auth_token.strip()
            from_num = settings.twilio_from_number.strip()
            if not sid or not token or not from_num:
                raise ServiceUnavailableError(
                    "Twilio credentials are incomplete in backend .env."
                )
            url = f"https://api.twilio.com/2010-04-01/Accounts/{sid}/Messages.json"
            try:
                response = httpx.post(
                    url,
                    auth=(sid, token),
                    data={"To": phone_number, "From": from_num, "Body": message},
                    timeout=15.0,
                )
                response.raise_for_status()
            except httpx.HTTPError as exc:
                raise ServiceUnavailableError(f"Twilio SMS request failed: {exc}") from exc
            return

        if provider == "webhook":
            url = settings.sms_webhook_url.strip()
            if not url:
                raise ServiceUnavailableError("SMS_WEBHOOK_URL is empty in backend .env.")
            headers = {"Content-Type": "application/json"}
            if settings.sms_webhook_api_key.strip():
                headers["Authorization"] = f"Bearer {settings.sms_webhook_api_key.strip()}"
            try:
                response = httpx.post(
                    url,
                    headers=headers,
                    json={"to": phone_number, "message": message, "purpose": purpose},
                    timeout=15.0,
                )
                response.raise_for_status()
            except httpx.HTTPError as exc:
                raise ServiceUnavailableError(f"SMS webhook request failed: {exc}") from exc


sms_service = SmsService()

