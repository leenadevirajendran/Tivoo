from __future__ import annotations
from email.message import EmailMessage
import smtplib
import ssl

from app.core.config import get_settings
from app.core.exceptions import ServiceUnavailableError


class EmailService:
    """Real SMTP email sender for OTP verification, login codes, and password resets."""

    def send_otp_email(self, recipient: str, otp_code: str, purpose: str) -> None:
        settings = get_settings()
        sender = settings.mail_sender.strip()
        app_password = settings.mail_app_password.replace(" ", "").strip()

        if not sender or not app_password:
            # Helpful fallback for local dev when MAIL_APP_PASSWORD is not set yet
            print(
                f"\n{'='*64}\n"
                f"[TIVOO EMAIL OTP - SENDER: {sender}]\n"
                f"Recipient: {recipient}\n"
                f"Purpose:   {purpose}\n"
                f"OTP CODE:  >>> {otp_code} <<<\n"
                f"To deliver directly to Gmail inbox, set MAIL_APP_PASSWORD in backend/.env\n"
                f"{'='*64}\n",
                flush=True,
            )
            return

        purpose_labels = {
            "login": ("Sign in to Tivoo", "Use this one-time code to sign in to your Tivoo account:"),
            "verify_email": ("Verify your Tivoo email", "Use this code to verify your email address on Tivoo:"),
            "reset_password": ("Reset your Tivoo password", "Use this code to reset your Tivoo password:"),
        }
        subject, subtitle = purpose_labels.get(
            purpose,
            ("Your Tivoo verification code", "Use this verification code:"),
        )

        msg = EmailMessage()
        msg["Subject"] = f"{subject} ({otp_code})"
        msg["From"] = f"{settings.mail_sender_name} <{sender}>"
        msg["To"] = recipient

        msg.set_content(
            f"{subtitle}\n\n"
            f"Verification Code: {otp_code}\n\n"
            f"This code expires in {settings.otp_expire_minutes} minutes.\n"
            "If you did not request this code, please ignore this email.\n"
        )

        msg.add_alternative(
            f"""
            <html>
              <body style="margin:0;padding:24px;background:#0b0e17;font-family:Segoe UI,Arial,sans-serif;color:#ffffff;">
                <div style="max-width:480px;margin:0 auto;background:#15182b;border:1px solid #2b2f55;border-radius:18px;padding:28px;">
                  <div style="font-size:24px;font-weight:800;letter-spacing:0.6px;color:#ff2dc0;margin-bottom:8px;">
                    Tivoo
                  </div>
                  <h2 style="margin:0 0 10px 0;font-size:20px;color:#ffffff;">{subject}</h2>
                  <p style="margin:0 0 20px 0;font-size:14px;line-height:1.5;color:#cbd5e1;">
                    {subtitle}
                  </p>
                  <div style="background:#0e1020;border:1px dashed #9d4edd;border-radius:12px;padding:16px;text-align:center;margin-bottom:20px;">
                    <span style="font-size:32px;font-weight:800;letter-spacing:8px;color:#fffc00;">{otp_code}</span>
                  </div>
                  <p style="margin:0;font-size:12px;color:#94a3b8;">
                    This OTP expires in <strong>{settings.otp_expire_minutes} minutes</strong>. Never share this code with anyone.
                  </p>
                </div>
              </body>
            </html>
            """,
            subtype="html",
        )

        try:
            context = ssl.create_default_context()
            if settings.mail_use_tls:
                with smtplib.SMTP(settings.mail_smtp_host, settings.mail_smtp_port, timeout=15) as server:
                    server.ehlo()
                    server.starttls(context=context)
                    server.ehlo()
                    server.login(sender, app_password)
                    server.send_message(msg)
            else:
                with smtplib.SMTP_SSL(settings.mail_smtp_host, settings.mail_smtp_port, context=context, timeout=15) as server:
                    server.login(sender, app_password)
                    server.send_message(msg)
        except smtplib.SMTPAuthenticationError as exc:
            raise ServiceUnavailableError(
                "Gmail SMTP authentication failed. Check MAIL_SENDER and MAIL_APP_PASSWORD in backend .env."
            ) from exc
        except (smtplib.SMTPException, OSError) as exc:
            raise ServiceUnavailableError(f"Failed to send OTP email: {exc}") from exc


email_service = EmailService()

