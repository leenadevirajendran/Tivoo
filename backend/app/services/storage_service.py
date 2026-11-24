from __future__ import annotations
import mimetypes
from pathlib import Path
import shutil

import boto3
from botocore.exceptions import BotoCoreError, ClientError

from app.core.config import get_settings
from app.core.exceptions import ServiceUnavailableError

_EXTRA_MIME_TYPES = {
    ".m3u8": "application/vnd.apple.mpegurl",
    ".ts": "video/mp2t",
    ".mp4": "video/mp4",
    ".jpg": "image/jpeg",
    ".jpeg": "image/jpeg",
    ".png": "image/png",
    ".webp": "image/webp",
}


class StorageService:
    """Unified media storage supporting local disk, AWS S3, and Cloudflare R2."""

    def _guess_content_type(self, file_path: Path) -> str:
        ext = file_path.suffix.lower()
        if ext in _EXTRA_MIME_TYPES:
            return _EXTRA_MIME_TYPES[ext]
        guessed, _ = mimetypes.guess_type(str(file_path))
        return guessed or "application/octet-stream"

    def _get_s3_client(self):
        settings = get_settings()
        if not settings.s3_bucket_name or not settings.s3_access_key_id or not settings.s3_secret_access_key:
            raise ServiceUnavailableError(
                "S3/R2 storage credentials are not configured in backend .env."
            )
        kwargs: dict[str, str] = {
            "service_name": "s3",
            "region_name": settings.s3_region or "auto",
            "aws_access_key_id": settings.s3_access_key_id,
            "aws_secret_access_key": settings.s3_secret_access_key,
        }
        if settings.s3_endpoint_url.strip():
            kwargs["endpoint_url"] = settings.s3_endpoint_url.strip()
        return boto3.client(**kwargs)

    def build_public_url(self, key: str) -> str:
        """Build URL for an uploaded object key."""
        clean_key = key.lstrip("/")
        settings = get_settings()
        if settings.storage_backend == "local":
            return f"/media/{clean_key}"

        if settings.cdn_public_base_url.strip():
            base = settings.cdn_public_base_url.strip().rstrip("/")
            return f"{base}/{clean_key}"

        if settings.s3_endpoint_url.strip():
            endpoint = settings.s3_endpoint_url.strip().rstrip("/")
            return f"{endpoint}/{settings.s3_bucket_name}/{clean_key}"

        region = settings.s3_region or "us-east-1"
        return f"https://{settings.s3_bucket_name}.s3.{region}.amazonaws.com/{clean_key}"

    def save_bytes(self, data: bytes, key: str, content_type: str | None = None) -> str:
        """Store raw bytes at storage `key` and return its public URL."""
        clean_key = key.lstrip("/")
        settings = get_settings()

        if settings.storage_backend == "local":
            dest = (settings.local_storage_path / clean_key).resolve()
            dest.parent.mkdir(parents=True, exist_ok=True)
            dest.write_bytes(data)
            return self.build_public_url(clean_key)

        client = self._get_s3_client()
        try:
            client.put_object(
                Bucket=settings.s3_bucket_name,
                Key=clean_key,
                Body=data,
                ContentType=content_type or "application/octet-stream",
            )
        except (BotoCoreError, ClientError) as exc:
            raise ServiceUnavailableError(f"Cloud upload failed: {exc}") from exc
        return self.build_public_url(clean_key)

    def save_local_file(self, local_path: Path, key: str) -> str:
        """Store a file from disk at storage `key` and return its public URL."""
        clean_key = key.lstrip("/")
        settings = get_settings()

        if settings.storage_backend == "local":
            dest = (settings.local_storage_path / clean_key).resolve()
            dest.parent.mkdir(parents=True, exist_ok=True)
            if local_path.resolve() != dest:
                shutil.copy2(local_path, dest)
            return self.build_public_url(clean_key)

        client = self._get_s3_client()
        ctype = self._guess_content_type(local_path)
        cache_ctrl = "public, max-age=31536000" if local_path.suffix.lower() != ".m3u8" else "public, max-age=60"
        try:
            client.upload_file(
                str(local_path),
                settings.s3_bucket_name,
                clean_key,
                ExtraArgs={"ContentType": ctype, "CacheControl": cache_ctrl},
            )
        except (BotoCoreError, ClientError) as exc:
            raise ServiceUnavailableError(f"Cloud upload failed: {exc}") from exc
        return self.build_public_url(clean_key)

    def save_directory(self, local_dir: Path, prefix_key: str) -> None:
        """Recursively upload all files inside `local_dir` under `prefix_key`."""
        clean_prefix = prefix_key.strip("/")
        for path in local_dir.rglob("*"):
            if path.is_file():
                rel = path.relative_to(local_dir).as_posix()
                self.save_local_file(path, f"{clean_prefix}/{rel}")

    def resolve_local_path(self, key: str) -> Path:
        """Return absolute path on disk when using local storage."""
        settings = get_settings()
        return (settings.local_storage_path / key.lstrip("/")).resolve()

    def delete_key(self, key: str) -> None:
        """Delete a single object key if non-empty."""
        if not key:
            return
        clean_key = key.lstrip("/")
        settings = get_settings()

        if settings.storage_backend == "local":
            target = (settings.local_storage_path / clean_key).resolve()
            if target.exists() and target.is_file():
                target.unlink(missing_ok=True)
            return

        client = self._get_s3_client()
        try:
            client.delete_object(Bucket=settings.s3_bucket_name, Key=clean_key)
        except (BotoCoreError, ClientError):
            pass

    def delete_prefix(self, prefix_key: str) -> None:
        """Delete an entire directory/prefix (used for HLS segment cleanup)."""
        if not prefix_key:
            return
        clean_prefix = prefix_key.strip("/")
        settings = get_settings()

        if settings.storage_backend == "local":
            target = (settings.local_storage_path / clean_prefix).resolve()
            if target.exists() and target.is_dir():
                shutil.rmtree(target, ignore_errors=True)
            return

        client = self._get_s3_client()
        try:
            paginator = client.get_paginator("list_objects_v2")
            for page in paginator.paginate(Bucket=settings.s3_bucket_name, Prefix=f"{clean_prefix}/"):
                objs = [{"Key": obj["Key"]} for obj in page.get("Contents", [])]
                if objs:
                    client.delete_objects(Bucket=settings.s3_bucket_name, Delete={"Objects": objs})
        except (BotoCoreError, ClientError):
            pass


storage_service = StorageService()

