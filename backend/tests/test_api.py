from __future__ import annotations
from contextlib import contextmanager
from io import BytesIO
from pathlib import Path
import re
import subprocess
import tempfile
import time
import uuid

from fastapi.testclient import TestClient
from PIL import Image
import pytest
from sqlalchemy import inspect, text

from app.core.config import get_settings
from app.db.session import SessionLocal, engine
from app.main import app
from app.models.user import User


def _unique_suffix() -> str:
    return uuid.uuid4().hex[:10]


def _make_png_bytes(color: tuple[int, int, int] = (255, 59, 107)) -> bytes:
    buf = BytesIO()
    Image.new("RGB", (128, 128), color=color).save(buf, format="PNG")
    return buf.getvalue()


def _generate_test_mp4(ffmpeg_bin: str) -> bytes:
    """Create a real 1-second 320x240 H.264/AAC MP4 using FFmpeg for upload/HLS tests."""
    with tempfile.TemporaryDirectory(prefix="tivoo_test_vid_") as tmp:
        out_path = Path(tmp) / "sample.mp4"
        cmd = [
            ffmpeg_bin,
            "-y",
            "-f",
            "lavfi",
            "-i",
            "testsrc=duration=1:size=320x240:rate=15",
            "-f",
            "lavfi",
            "-i",
            "anullsrc=channel_layout=stereo:sample_rate=44100",
            "-t",
            "1",
            "-c:v",
            "libx264",
            "-pix_fmt",
            "yuv420p",
            "-c:a",
            "aac",
            "-shortest",
            str(out_path),
        ]
        try:
            result = subprocess.run(cmd, capture_output=True, text=True, check=False)
            if result.returncode != 0 or not out_path.exists():
                pytest.skip(f"FFmpeg test clip generation unavailable: {result.stderr[:200]}")
            return out_path.read_bytes()
        except (FileNotFoundError, OSError):
            pytest.skip("FFmpeg binary not installed on this machine")


@contextmanager
def _cleanup_created_users(user_ids: list[str], emails: list[str] | None = None, avatar_urls: list[str] | None = None):
    try:
        yield
    finally:
        db = SessionLocal()
        try:
            for uid in user_ids:
                user = db.get(User, uid)
                if user is not None:
                    db.delete(user)
            for addr in emails or []:
                db.execute(
                    text("DELETE FROM otp_codes WHERE target = :target"),
                    {"target": addr},
                )
            db.commit()
        finally:
            db.close()

        local_root = get_settings().local_storage_path
        for url in avatar_urls or []:
            if url.startswith("/media/"):
                rel = url.removeprefix("/media/").lstrip("/")
                target = local_root / rel
                if target.exists() and target.is_file():
                    target.unlink()


def test_health_and_mysql_tivoo_schema() -> None:
    with TestClient(app) as client:
        page = client.get("/")
        assert page.status_code == 200
        assert "Reels Upload" in page.text

        health = client.get("/api/health")
        assert health.status_code == 200
        payload = health.json()
        assert payload["database"]["connected"] is True
        assert payload["database"]["name"] in ("tivoo", "tivoo_db")

    inspector = inspect(engine)
    tables = set(inspector.get_table_names())
    expected_tables = {
        "users",
        "otp_codes",
        "refresh_tokens",
        "follows",
        "videos",
        "video_likes",
        "video_comments",
        "comment_likes",
    }
    assert expected_tables.issubset(tables)


def test_auth_otp_and_profile_lifecycle(monkeypatch: pytest.MonkeyPatch) -> None:
    suffix = _unique_suffix()
    created_ids: list[str] = []
    created_emails: list[str] = []
    uploaded_urls: list[str] = []

    with _cleanup_created_users(created_ids, created_emails, uploaded_urls):
        with TestClient(app) as client:
            # 1. Register user
            email = f"creator.{suffix}@example.com"
            created_emails.append(email)
            username = f"creator_{suffix}"
            reg_res = client.post(
                "/api/auth/register",
                json={
                    "name": "Test Creator",
                    "username": username,
                    "email": email,
                    "password": "StrongPassword123!",
                    "bio": "Testing real MySQL backend",
                },
            )
            assert reg_res.status_code == 201, reg_res.text
            reg_data = reg_res.json()
            user_id = reg_data["user"]["id"]
            created_ids.append(user_id)
            access_token = reg_data["accessToken"]
            refresh_token = reg_data["refreshToken"]
            assert reg_data["user"]["email"] == email

            # Duplicate registration must fail with 409
            dup_res = client.post(
                "/api/auth/register",
                json={
                    "name": "Dup Creator",
                    "username": username,
                    "email": f"other.{suffix}@example.com",
                    "password": "StrongPassword123!",
                },
            )
            assert dup_res.status_code == 409

            # Verify OTP to activate account if required
            client.post(
                "/api/auth/email/verify-otp",
                json={"email": email, "otp": "123456", "purpose": "verify_email"},
            )

            # 2. Password login & /me
            login_res = client.post(
                "/api/auth/login",
                json={"identifier": username, "password": "StrongPassword123!"},
            )
            assert login_res.status_code == 200
            assert login_res.json()["user"]["id"] == user_id

            me_res = client.get(
                "/api/auth/me",
                headers={"Authorization": f"Bearer {access_token}"},
            )
            assert me_res.status_code == 200
            assert me_res.json()["username"] == username

            # 3. Profile update & avatar upload
            patch_res = client.patch(
                "/api/profiles/me",
                headers={"Authorization": f"Bearer {access_token}"},
                json={"bio": "Updated bio in MySQL"},
            )
            assert patch_res.status_code == 200
            assert patch_res.json()["bio"] == "Updated bio in MySQL"

            avatar_res = client.post(
                "/api/profiles/me/avatar",
                headers={"Authorization": f"Bearer {access_token}"},
                files={"file": ("avatar.png", _make_png_bytes(), "image/png")},
            )
            assert avatar_res.status_code == 200
            avatar_url = avatar_res.json()["avatarUrl"]
            uploaded_urls.append(avatar_url)
            assert avatar_url.startswith("/media/profiles/")
            assert client.get(avatar_url).status_code == 200

            # 4. Email OTP without app password configured returns 503 and keeps DB clean
            settings = get_settings()
            if not settings.mail_app_password.strip():
                no_smtp_res = client.post(
                    "/api/auth/email/send-otp",
                    json={"email": email, "purpose": "login"},
                )
                assert no_smtp_res.status_code == 503
                with engine.connect() as conn:
                    count = conn.execute(
                        text("SELECT COUNT(*) FROM otp_codes WHERE target = :target"),
                        {"target": email},
                    ).scalar_one()
                    assert count == 0

            # 5. Email OTP with SMTP transport stubbed captures real OTP stored hashed in MySQL
            sent_messages: list[str] = []

            class DummySMTP:
                def __init__(self, host: str, port: int, timeout: int = 20) -> None:
                    self.host = host
                    self.port = port

                def __enter__(self) -> "DummySMTP":
                    return self

                def __exit__(self, *args: object) -> None:
                    return None

                def ehlo(self) -> None:
                    return None

                def starttls(self, context: object = None) -> None:
                    return None

                def login(self, user: str, password: str) -> None:
                    return None

                def send_message(self, msg: object) -> None:
                    sent_messages.append(str(msg))

            with monkeypatch.context() as mp:
                mp.setattr(settings, "mail_app_password", "test-app-password-only")
                mp.setattr("smtplib.SMTP", DummySMTP)
                otp_send = client.post(
                    "/api/auth/email/send-otp",
                    json={"email": email, "purpose": "login"},
                )
                assert otp_send.status_code == 200, otp_send.text
                assert len(sent_messages) == 1
                match = re.search(r"\b(\d{6})\b", sent_messages[0])
                assert match is not None
                otp_code = match.group(1)

                otp_verify = client.post(
                    "/api/auth/email/verify-otp",
                    json={"email": email, "otp": otp_code, "purpose": "login"},
                )
                assert otp_verify.status_code == 200, otp_verify.text
                assert otp_verify.json()["user"]["isEmailVerified"] is True

            # 6. Refresh token rotation and logout revocation
            refresh_res = client.post(
                "/api/auth/refresh",
                json={"refreshToken": refresh_token},
            )
            assert refresh_res.status_code == 200
            new_refresh = refresh_res.json()["refreshToken"]
            new_access = refresh_res.json()["accessToken"]
            assert new_refresh != refresh_token

            logout_res = client.post(
                "/api/auth/logout",
                headers={"Authorization": f"Bearer {new_access}"},
                json={"refreshToken": new_refresh},
            )
            assert logout_res.status_code == 200

            reuse_res = client.post(
                "/api/auth/refresh",
                json={"refreshToken": new_refresh},
            )
            assert reuse_res.status_code == 401


def test_follow_video_upload_hls_transcoding_and_feed() -> None:
    settings = get_settings()
    mp4_bytes = _generate_test_mp4(settings.ffmpeg_bin)
    suffix = _unique_suffix()
    created_ids: list[str] = []

    with _cleanup_created_users(created_ids):
        with TestClient(app) as client:
            # Register two users
            u1_res = client.post(
                "/api/auth/register",
                json={
                    "name": "Author One",
                    "username": f"author1_{suffix}",
                    "email": f"author1.{suffix}@example.com",
                    "password": "Password123!",
                },
            )
            assert u1_res.status_code == 201
            u1 = u1_res.json()
            created_ids.append(u1["user"]["id"])

            u2_res = client.post(
                "/api/auth/register",
                json={
                    "name": "Viewer Two",
                    "username": f"viewer2_{suffix}",
                    "email": f"viewer2.{suffix}@example.com",
                    "password": "Password123!",
                },
            )
            assert u2_res.status_code == 201
            u2 = u2_res.json()
            created_ids.append(u2["user"]["id"])

            h1 = {"Authorization": f"Bearer {u1['accessToken']}"}
            h2 = {"Authorization": f"Bearer {u2['accessToken']}"}

            # User 2 follows User 1
            follow_res = client.post(f"/api/follows/{u1['user']['id']}", headers=h2)
            assert follow_res.status_code == 200
            assert follow_res.json()["status"] == "following"

            # Upload real MP4 reel by User 1
            upload_res = client.post(
                "/api/videos",
                headers=h1,
                files={"video": ("clip.mp4", mp4_bytes, "video/mp4")},
                data={
                    "caption": "Real FFmpeg HLS reel #music #tivoo",
                    "category": "Music",
                    "audience": "Public",
                    "snap_lens_name": "Neon Pulse",
                    "allow_comments": "true",
                    "allow_downloads": "true",
                },
            )
            assert upload_res.status_code == 201, upload_res.text
            video_data = upload_res.json()
            video_id = video_data["id"]

            # Wait briefly for background FFmpeg H.264 + HLS transcoding
            deadline = time.time() + 25.0
            while time.time() < deadline:
                poll_res = client.get(f"/api/videos/{video_id}", headers=h2)
                assert poll_res.status_code == 200
                video_data = poll_res.json()
                if video_data["transcodingStatus"] in ("ready", "failed"):
                    break
                time.sleep(0.4)

            if shutil.which("ffmpeg"):
                assert video_data["transcodingStatus"] == "ready", video_data
                assert video_data["hlsUrl"] and video_data["hlsUrl"].endswith(".m3u8")
                assert video_data["thumbnailUrl"]

                hls_res = client.get(video_data["hlsUrl"])
                assert hls_res.status_code == 200
                assert "#EXTM3U" in hls_res.text

                mp4_res = client.get(video_data["videoUrl"])
                assert mp4_res.status_code == 200
            else:
                assert video_data["transcodingStatus"] in ("ready", "failed")

            # Verify feeds contain our video
            for_you = client.get("/api/feed/for-you", headers=h2)
            assert for_you.status_code == 200
            assert any(v["id"] == video_id for v in for_you.json()["videos"])

            following_feed = client.get("/api/feed/following", headers=h2)
            assert following_feed.status_code == 200
            assert any(v["id"] == video_id for v in following_feed.json()["videos"])

            # Like, View, and Comment by User 2
            like_res = client.post(f"/api/videos/{video_id}/like", headers=h2)
            assert like_res.status_code == 200
            assert like_res.json()["isLiked"] is True
            assert like_res.json()["likesCount"] == 1

            view_res = client.post(f"/api/videos/{video_id}/view")
            assert view_res.status_code == 200
            assert view_res.json()["viewsCount"] == 1

            comment_res = client.post(
                f"/api/videos/{video_id}/comments",
                headers=h2,
                json={"text": "Awesome stream quality!"},
            )
            assert comment_res.status_code == 201
            comment_id = comment_res.json()["id"]

            comments_list = client.get(f"/api/videos/{video_id}/comments", headers=h2)
            assert comments_list.status_code == 200
            assert comments_list.json()["total"] == 1

            c_like = client.post(f"/api/comments/{comment_id}/like", headers=h1)
            assert c_like.status_code == 200
            assert c_like.json()["likesCount"] == 1

            # Delete comment and video cleanly
            assert client.delete(f"/api/comments/{comment_id}", headers=h2).status_code == 200
            assert client.delete(f"/api/videos/{video_id}", headers=h1).status_code == 200
