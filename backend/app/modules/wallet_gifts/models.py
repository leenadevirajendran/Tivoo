from __future__ import annotations
from typing import Optional
from decimal import Decimal
import uuid
from datetime import datetime

from sqlalchemy import (
    JSON,
    BigInteger,
    Boolean,
    CheckConstraint,
    DateTime,
    ForeignKey,
    Index,
    Integer,
    Numeric,
    String,
)
from sqlalchemy.orm import Mapped, mapped_column, relationship

from app.core.security import utc_now
from app.db.session import Base
from app.models.user import MYSQL_TABLE_ARGS


class UserWallet(Base):
    __tablename__ = "user_wallets"
    __table_args__ = (
        CheckConstraint("coins_balance >= 0", name="ck_wallet_coins_nonnegative"),
        CheckConstraint("diamonds_balance >= 0", name="ck_wallet_diamonds_nonnegative"),
        MYSQL_TABLE_ARGS,
    )

    user_id: Mapped[str] = mapped_column(
        String(36), ForeignKey("users.id", ondelete="CASCADE"), primary_key=True
    )
    coins_balance: Mapped[int] = mapped_column(BigInteger, default=0, nullable=False)
    diamonds_balance: Mapped[int] = mapped_column(BigInteger, default=0, nullable=False)
    total_coins_spent: Mapped[int] = mapped_column(BigInteger, default=0, nullable=False)
    total_diamonds_earned: Mapped[int] = mapped_column(BigInteger, default=0, nullable=False)
    vip_level: Mapped[int] = mapped_column(Integer, default=0, nullable=False)
    updated_at: Mapped[datetime] = mapped_column(
        DateTime, default=utc_now, onupdate=utc_now, nullable=False
    )

    user = relationship("User")


class CoinPackage(Base):
    __tablename__ = "coin_packages"
    __table_args__ = (MYSQL_TABLE_ARGS,)

    id: Mapped[str] = mapped_column(String(36), primary_key=True, default=lambda: str(uuid.uuid4()))
    code: Mapped[str] = mapped_column(String(48), unique=True, nullable=False)
    title: Mapped[str] = mapped_column(String(80), nullable=False)
    coins_amount: Mapped[int] = mapped_column(Integer, nullable=False)
    bonus_coins: Mapped[int] = mapped_column(Integer, default=0, nullable=False)
    price_cents: Mapped[int] = mapped_column(Integer, nullable=False)
    currency: Mapped[str] = mapped_column(String(8), default="INR", nullable=False)
    store_product_id: Mapped[Optional[str]] = mapped_column(String(120), unique=True, nullable=True)
    is_popular: Mapped[bool] = mapped_column(Boolean, default=False, nullable=False)
    is_active: Mapped[bool] = mapped_column(Boolean, default=True, nullable=False)
    created_at: Mapped[datetime] = mapped_column(DateTime, default=utc_now, nullable=False)


class GiftCatalog(Base):
    __tablename__ = "gift_catalog"
    __table_args__ = (
        Index("ix_gift_catalog_active_sort", "is_active", "sort_order"),
        MYSQL_TABLE_ARGS,
    )

    id: Mapped[str] = mapped_column(String(36), primary_key=True, default=lambda: str(uuid.uuid4()))
    code: Mapped[str] = mapped_column(String(48), unique=True, nullable=False)
    name: Mapped[str] = mapped_column(String(80), nullable=False)
    category: Mapped[str] = mapped_column(String(40), default="Popular", nullable=False)
    icon: Mapped[str] = mapped_column(String(16), default="", nullable=False)
    animation_url: Mapped[str] = mapped_column(String(512), default="", nullable=False)
    coin_cost: Mapped[int] = mapped_column(Integer, nullable=False)
    diamond_value: Mapped[int] = mapped_column(Integer, nullable=False)
    tagline: Mapped[str] = mapped_column(String(180), default="", nullable=False)
    sort_order: Mapped[int] = mapped_column(Integer, default=0, nullable=False)
    is_active: Mapped[bool] = mapped_column(Boolean, default=True, nullable=False)
    created_at: Mapped[datetime] = mapped_column(DateTime, default=utc_now, nullable=False)


class GiftTransaction(Base):
    __tablename__ = "gift_transactions"
    __table_args__ = (
        Index("ix_gift_tx_created_sender", "created_at", "sender_id"),
        Index("ix_gift_tx_created_receiver", "created_at", "receiver_id"),
        MYSQL_TABLE_ARGS,
    )

    id: Mapped[str] = mapped_column(String(36), primary_key=True, default=lambda: str(uuid.uuid4()))
    idempotency_key: Mapped[Optional[str]] = mapped_column(String(80), unique=True, nullable=True)
    sender_id: Mapped[str] = mapped_column(
        String(36), ForeignKey("users.id", ondelete="CASCADE"), nullable=False, index=True
    )
    receiver_id: Mapped[str] = mapped_column(
        String(36), ForeignKey("users.id", ondelete="CASCADE"), nullable=False, index=True
    )
    gift_id: Mapped[str] = mapped_column(
        String(36), ForeignKey("gift_catalog.id", ondelete="RESTRICT"), nullable=False
    )
    live_room_id: Mapped[Optional[str]] = mapped_column(
        String(36), ForeignKey("live_rooms.id", ondelete="SET NULL"), nullable=True, index=True
    )
    pk_battle_id: Mapped[Optional[str]] = mapped_column(
        String(36), ForeignKey("pk_battles.id", ondelete="SET NULL"), nullable=True, index=True
    )
    quantity: Mapped[int] = mapped_column(Integer, default=1, nullable=False)
    total_coins: Mapped[int] = mapped_column(BigInteger, nullable=False)
    diamonds_credited: Mapped[int] = mapped_column(BigInteger, nullable=False)
    combo_streak: Mapped[int] = mapped_column(Integer, default=1, nullable=False)
    created_at: Mapped[datetime] = mapped_column(DateTime, default=utc_now, nullable=False)

    sender = relationship("User", foreign_keys=[sender_id])
    receiver = relationship("User", foreign_keys=[receiver_id])
    gift = relationship("GiftCatalog")


class WalletLedgerEntry(Base):
    __tablename__ = "wallet_ledger_entries"
    __table_args__ = (
        Index("ix_wallet_ledger_user_created", "user_id", "created_at"),
        MYSQL_TABLE_ARGS,
    )

    id: Mapped[str] = mapped_column(String(36), primary_key=True, default=lambda: str(uuid.uuid4()))
    user_id: Mapped[str] = mapped_column(
        String(36), ForeignKey("users.id", ondelete="CASCADE"), nullable=False, index=True
    )
    entry_type: Mapped[str] = mapped_column(String(36), nullable=False)
    currency: Mapped[str] = mapped_column(String(16), nullable=False)  # coins | diamonds
    delta_amount: Mapped[int] = mapped_column(BigInteger, nullable=False)
    balance_after: Mapped[int] = mapped_column(BigInteger, nullable=False)
    reference_type: Mapped[str] = mapped_column(String(36), default="", nullable=False)
    reference_id: Mapped[str] = mapped_column(String(64), default="", nullable=False)
    description: Mapped[str] = mapped_column(String(255), default="", nullable=False)
    created_at: Mapped[datetime] = mapped_column(DateTime, default=utc_now, nullable=False)


class PaymentOrder(Base):
    __tablename__ = "payment_orders"
    __table_args__ = (
        Index("ix_payment_orders_user_status", "user_id", "status"),
        MYSQL_TABLE_ARGS,
    )

    id: Mapped[str] = mapped_column(String(36), primary_key=True, default=lambda: str(uuid.uuid4()))
    user_id: Mapped[str] = mapped_column(
        String(36), ForeignKey("users.id", ondelete="CASCADE"), nullable=False, index=True
    )
    package_id: Mapped[str] = mapped_column(
        String(36), ForeignKey("coin_packages.id", ondelete="RESTRICT"), nullable=False
    )
    provider: Mapped[str] = mapped_column(String(24), nullable=False)  # stripe | google_play | apple_iap
    provider_order_id: Mapped[Optional[str]] = mapped_column(String(160), nullable=True, index=True)
    provider_event_id: Mapped[Optional[str]] = mapped_column(String(160), unique=True, nullable=True)
    amount_cents: Mapped[int] = mapped_column(Integer, nullable=False)
    currency: Mapped[str] = mapped_column(String(8), default="INR", nullable=False)
    coins_credited: Mapped[int] = mapped_column(Integer, nullable=False)
    status: Mapped[str] = mapped_column(String(24), default="pending", nullable=False)
    raw_payload: Mapped[dict] = mapped_column(JSON, default=dict, nullable=False)
    completed_at: Mapped[Optional[datetime]] = mapped_column(DateTime, nullable=True)
    created_at: Mapped[datetime] = mapped_column(DateTime, default=utc_now, nullable=False)


class PayoutRequest(Base):
    __tablename__ = "payout_requests"
    __table_args__ = (
        Index("ix_payout_requests_user_status", "user_id", "status"),
        MYSQL_TABLE_ARGS,
    )

    id: Mapped[str] = mapped_column(String(36), primary_key=True, default=lambda: str(uuid.uuid4()))
    user_id: Mapped[str] = mapped_column(
        String(36), ForeignKey("users.id", ondelete="CASCADE"), nullable=False, index=True
    )
    diamonds_amount: Mapped[int] = mapped_column(BigInteger, nullable=False)
    payout_amount: Mapped[Decimal] = mapped_column(Numeric(12, 2), nullable=False)
    currency: Mapped[str] = mapped_column(String(8), default="INR", nullable=False)
    payout_method: Mapped[str] = mapped_column(String(32), nullable=False)  # bank_transfer | upi | paypal
    account_details: Mapped[dict[str, str]] = mapped_column(JSON, default=dict, nullable=False)
    status: Mapped[str] = mapped_column(String(24), default="pending", nullable=False)  # pending | paid | rejected
    admin_note: Mapped[str] = mapped_column(String(255), default="", nullable=False)
    reviewed_by_id: Mapped[Optional[str]] = mapped_column(
        String(36), ForeignKey("users.id", ondelete="SET NULL"), nullable=True
    )
    reviewed_at: Mapped[Optional[datetime]] = mapped_column(DateTime, nullable=True)
    created_at: Mapped[datetime] = mapped_column(DateTime, default=utc_now, nullable=False)
