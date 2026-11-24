from __future__ import annotations
from typing import Optional
from datetime import datetime

from sqlalchemy import JSON, BigInteger, Boolean, DateTime, Index, Integer, String
from sqlalchemy.orm import Mapped, mapped_column

from app.core.security import utc_now
from app.db.session import Base
from app.models.user import MYSQL_TABLE_ARGS


class VipLevelConfig(Base):
    __tablename__ = "vip_level_configs"
    __table_args__ = (
        Index("ix_vip_level_min_coins", "min_coins_spent"),
        MYSQL_TABLE_ARGS,
    )

    level: Mapped[int] = mapped_column(Integer, primary_key=True, autoincrement=False)
    name: Mapped[str] = mapped_column(String(64), nullable=False)
    tier_bracket: Mapped[str] = mapped_column(String(40), default="bronze", nullable=False)
    min_coins_spent: Mapped[int] = mapped_column(BigInteger, unique=True, nullable=False)
    badge_color_hex: Mapped[str] = mapped_column(String(16), default="#FF3B6B", nullable=False)
    frame_url: Mapped[str] = mapped_column(String(512), default="", nullable=False)
    perks: Mapped[list[str]] = mapped_column(JSON, default=list, nullable=False)
    is_active: Mapped[bool] = mapped_column(Boolean, default=True, nullable=False)
    created_at: Mapped[datetime] = mapped_column(DateTime, default=utc_now, nullable=False)
