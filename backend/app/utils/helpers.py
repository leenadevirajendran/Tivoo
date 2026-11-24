from __future__ import annotations
import re
from pathlib import Path

_PHONE_CLEAN_RE = re.compile(r"[^\d+]")
_HASHTAG_RE = re.compile(r"#([A-Za-z0-9_]+)")
_USERNAME_CLEAN_RE = re.compile(r"[^a-zA-Z0-9._]")


def normalize_email(email: str) -> str:
    return email.strip().lower()


def normalize_phone(phone: str) -> str:
    cleaned = _PHONE_CLEAN_RE.sub("", phone.strip())
    if cleaned and not cleaned.startswith("+"):
        cleaned = f"+{cleaned}"
    return cleaned


def normalize_username(username: str) -> str:
    cleaned = _USERNAME_CLEAN_RE.sub("", username.strip().lower())
    return cleaned[:50]


def format_compact_count(value: int) -> str:
    """Format integers cleanly like '1.2K' or '3.4M'."""
    if value >= 1_000_000:
        return f"{value / 1_000_000:.1f}M"
    if value >= 1_000:
        return f"{value / 1_000:.1f}K"
    return str(max(0, value))


def extract_hashtags(caption: str, explicit_tags: list[str] | None = None) -> list[str]:
    """Combine explicit tags and #hashtags found in caption without duplicates."""
    seen: dict[str, str] = {}
    for raw in (explicit_tags or []) + [f"#{m}" for m in _HASHTAG_RE.findall(caption or "")]:
        cleaned = raw.strip()
        if not cleaned:
            continue
        if not cleaned.startswith("#"):
            cleaned = f"#{cleaned}"
        key = cleaned.lower()
        if key not in seen:
            seen[key] = cleaned
    return list(seen.values())[:15]


def safe_extension(filename: str | None, fallback: str = ".mp4") -> str:
    if not filename:
        return fallback
    ext = Path(filename).suffix.lower()
    return ext if ext and re.fullmatch(r"\.[a-z0-9]{1,8}", ext) else fallback

