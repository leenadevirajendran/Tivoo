from __future__ import annotations
from datetime import datetime, timedelta
from typing import Literal

from sqlalchemy import and_, desc, func, select
from sqlalchemy.orm import Session

from app.core.exceptions import NotFoundError
from app.core.security import utc_now
from app.models.user import User
from app.modules.leaderboards_vip.models import VipLevelConfig
from app.modules.leaderboards_vip.schemas import (
    LeaderboardEntryResponse,
    LeaderboardResponse,
    UserVipStatusResponse,
    VipTierCreateRequest,
    VipTierListResponse,
    VipTierResponse,
)
from app.modules.wallet_gifts.models import GiftTransaction, UserWallet


class LeaderboardVipService:
    """Computes Daily/Weekly/Monthly rankings and VIP levels directly from MySQL ledger data."""

    @staticmethod
    def _period_start(period: Literal["daily", "weekly", "monthly"]) -> datetime:
        now = utc_now()
        day_start = now.replace(hour=0, minute=0, second=0, microsecond=0)
        if period == "daily":
            return day_start
        if period == "weekly":
            return day_start - timedelta(days=day_start.weekday())
        return day_start.replace(day=1)

    @staticmethod
    def _serialize_tier(row: VipLevelConfig) -> VipTierResponse:
        return VipTierResponse(
            level=row.level,
            name=row.name,
            tierBracket=row.tier_bracket,
            minCoinsSpent=row.min_coins_spent,
            badgeColorHex=row.badge_color_hex,
            frameUrl=row.frame_url,
            perks=list(row.perks or []),
            isActive=row.is_active,
        )

    def get_top_gifters(
        self,
        db: Session,
        period: Literal["daily", "weekly", "monthly"] = "daily",
        limit: int = 50,
    ) -> LeaderboardResponse:
        start_dt = self._period_start(period)
        score_col = func.sum(GiftTransaction.total_coins).label("total_score")
        tx_count_col = func.count(GiftTransaction.id).label("tx_count")

        rows = db.execute(
            select(
                User.id,
                User.name,
                User.username,
                User.avatar_url,
                User.is_verified,
                func.coalesce(UserWallet.vip_level, 0).label("vip_level"),
                score_col,
                tx_count_col,
            )
            .join(GiftTransaction, GiftTransaction.sender_id == User.id)
            .outerjoin(UserWallet, UserWallet.user_id == User.id)
            .where(GiftTransaction.created_at >= start_dt)
            .group_by(
                User.id,
                User.name,
                User.username,
                User.avatar_url,
                User.is_verified,
                UserWallet.vip_level,
            )
            .order_by(desc(score_col), desc(tx_count_col))
            .limit(limit)
        ).all()

        entries = [
            LeaderboardEntryResponse(
                rank=idx,
                userId=row.id,
                name=row.name,
                username=row.username,
                avatarUrl=row.avatar_url,
                isVerified=bool(row.is_verified),
                vipLevel=int(row.vip_level or 0),
                score=int(row.total_score or 0),
                giftsCount=int(row.tx_count or 0),
            )
            for idx, row in enumerate(rows, start=1)
        ]
        return LeaderboardResponse(
            boardType="top_gifters",
            period=period,
            periodStart=start_dt,
            entries=entries,
            total=len(entries),
        )

    def get_top_streamers(
        self,
        db: Session,
        period: Literal["daily", "weekly", "monthly"] = "daily",
        limit: int = 50,
    ) -> LeaderboardResponse:
        start_dt = self._period_start(period)
        score_col = func.sum(GiftTransaction.diamonds_credited).label("total_score")
        tx_count_col = func.count(GiftTransaction.id).label("tx_count")

        rows = db.execute(
            select(
                User.id,
                User.name,
                User.username,
                User.avatar_url,
                User.is_verified,
                func.coalesce(UserWallet.vip_level, 0).label("vip_level"),
                score_col,
                tx_count_col,
            )
            .join(GiftTransaction, GiftTransaction.receiver_id == User.id)
            .outerjoin(UserWallet, UserWallet.user_id == User.id)
            .where(GiftTransaction.created_at >= start_dt)
            .group_by(
                User.id,
                User.name,
                User.username,
                User.avatar_url,
                User.is_verified,
                UserWallet.vip_level,
            )
            .order_by(desc(score_col), desc(tx_count_col))
            .limit(limit)
        ).all()

        entries = [
            LeaderboardEntryResponse(
                rank=idx,
                userId=row.id,
                name=row.name,
                username=row.username,
                avatarUrl=row.avatar_url,
                isVerified=bool(row.is_verified),
                vipLevel=int(row.vip_level or 0),
                score=int(row.total_score or 0),
                giftsCount=int(row.tx_count or 0),
            )
            for idx, row in enumerate(rows, start=1)
        ]
        return LeaderboardResponse(
            boardType="top_streamers",
            period=period,
            periodStart=start_dt,
            entries=entries,
            total=len(entries),
        )

    def list_vip_tiers(self, db: Session) -> VipTierListResponse:
        rows = list(
            db.scalars(
                select(VipLevelConfig)
                .where(VipLevelConfig.is_active.is_(True))
                .order_by(VipLevelConfig.level.asc())
            ).all()
        )
        return VipTierListResponse(
            tiers=[self._serialize_tier(r) for r in rows],
            total=len(rows),
        )

    def upsert_vip_tier(self, db: Session, payload: VipTierCreateRequest) -> VipTierResponse:
        row = db.get(VipLevelConfig, payload.level)
        if row:
            row.name = payload.name.strip()
            row.tier_bracket = payload.tierBracket.strip()
            row.min_coins_spent = payload.minCoinsSpent
            row.badge_color_hex = payload.badgeColorHex
            row.frame_url = payload.frameUrl.strip()
            row.perks = payload.perks
            row.is_active = payload.isActive
        else:
            row = VipLevelConfig(
                level=payload.level,
                name=payload.name.strip(),
                tier_bracket=payload.tierBracket.strip(),
                min_coins_spent=payload.minCoinsSpent,
                badge_color_hex=payload.badgeColorHex,
                frame_url=payload.frameUrl.strip(),
                perks=payload.perks,
                is_active=payload.isActive,
            )
            db.add(row)
        db.commit()
        db.refresh(row)
        return self._serialize_tier(row)

    def get_user_vip_status(self, db: Session, user_id: str) -> UserVipStatusResponse:
        user = db.get(User, user_id)
        if not user or not user.is_active:
            raise NotFoundError("User not found")

        wallet = db.get(UserWallet, user.id)
        total_spent = int(wallet.total_coins_spent) if wallet else 0

        tiers = list(
            db.scalars(
                select(VipLevelConfig)
                .where(VipLevelConfig.is_active.is_(True))
                .order_by(VipLevelConfig.min_coins_spent.asc(), VipLevelConfig.level.asc())
            ).all()
        )

        current_tier: VipLevelConfig | None = None
        next_tier: VipLevelConfig | None = None
        unlocked_perks: list[str] = []

        for tier in tiers:
            if total_spent >= tier.min_coins_spent:
                current_tier = tier
                for perk in tier.perks or []:
                    if perk not in unlocked_perks:
                        unlocked_perks.append(perk)
            else:
                next_tier = tier
                break

        if current_tier and wallet and wallet.vip_level != current_tier.level:
            wallet.vip_level = current_tier.level
            db.commit()

        prev_threshold = current_tier.min_coins_spent if current_tier else 0
        if next_tier:
            span = max(1, next_tier.min_coins_spent - prev_threshold)
            progress = round(
                min(100.0, max(0.0, ((total_spent - prev_threshold) / span) * 100.0)), 2
            )
            coins_remaining = max(0, next_tier.min_coins_spent - total_spent)
        else:
            progress = 100.0 if current_tier else 0.0
            coins_remaining = 0

        return UserVipStatusResponse(
            userId=user.id,
            totalCoinsSpent=total_spent,
            currentLevel=current_tier.level if current_tier else 0,
            currentTierName=current_tier.name if current_tier else "Starter",
            tierBracket=current_tier.tier_bracket if current_tier else "basic",
            badgeColorHex=current_tier.badge_color_hex if current_tier else "#98A4BC",
            unlockedPerks=unlocked_perks,
            nextLevel=next_tier.level if next_tier else None,
            nextTierName=next_tier.name if next_tier else None,
            nextLevelMinCoins=next_tier.min_coins_spent if next_tier else None,
            coinsToNextLevel=coins_remaining,
            progressPercent=progress,
        )


leaderboard_vip_service = LeaderboardVipService()
