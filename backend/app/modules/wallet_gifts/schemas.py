from __future__ import annotations
from datetime import datetime
from typing import Literal

from pydantic import BaseModel, Field


class WalletSummaryResponse(BaseModel):
    userId: str
    coinsBalance: int
    diamondsBalance: int
    totalCoinsSpent: int
    totalDiamondsEarned: int
    vipLevel: int
    updatedAt: datetime


class WalletLedgerEntryResponse(BaseModel):
    id: str
    entryType: str
    currency: str
    deltaAmount: int
    balanceAfter: int
    referenceType: str
    referenceId: str
    description: str
    createdAt: datetime


class WalletLedgerListResponse(BaseModel):
    entries: list[WalletLedgerEntryResponse]
    total: int
    page: int
    pageSize: int
    hasMore: bool


class GiftCreateRequest(BaseModel):
    code: str = Field(..., min_length=2, max_length=48, pattern=r"^[a-zA-Z0-9_-]+$")
    name: str = Field(..., min_length=1, max_length=80)
    category: str = Field(default="Popular", max_length=40)
    icon: str = Field(default="", max_length=16)
    animationUrl: str = Field(default="", max_length=512)
    coinCost: int = Field(..., ge=1, le=10_000_000)
    diamondValue: int | None = Field(default=None, ge=1, le=10_000_000)
    tagline: str = Field(default="", max_length=180)
    sortOrder: int = 0
    isActive: bool = True


class GiftItemResponse(BaseModel):
    id: str
    code: str
    name: str
    category: str
    icon: str
    animationUrl: str
    coinCost: int
    diamondValue: int
    tagline: str
    sortOrder: int
    isActive: bool


class GiftCatalogListResponse(BaseModel):
    gifts: list[GiftItemResponse]
    total: int


class CoinPackageCreateRequest(BaseModel):
    code: str = Field(..., min_length=2, max_length=48, pattern=r"^[a-zA-Z0-9_-]+$")
    title: str = Field(..., min_length=2, max_length=80)
    coinsAmount: int = Field(..., ge=1, le=10_000_000)
    bonusCoins: int = Field(default=0, ge=0, le=5_000_000)
    priceCents: int = Field(..., ge=1)
    currency: str = Field(default="INR", min_length=3, max_length=8)
    storeProductId: str | None = Field(default=None, max_length=120)
    isPopular: bool = False
    isActive: bool = True


class CoinPackageResponse(BaseModel):
    id: str
    code: str
    title: str
    coinsAmount: int
    bonusCoins: int
    totalCoins: int
    priceCents: int
    currency: str
    storeProductId: str | None = None
    isPopular: bool


class CoinPackageListResponse(BaseModel):
    packages: list[CoinPackageResponse]
    total: int


class SendGiftRequest(BaseModel):
    giftId: str = Field(..., min_length=3, max_length=36)
    receiverId: str = Field(..., min_length=3, max_length=36)
    quantity: int = Field(default=1, ge=1, le=999)
    liveRoomId: str | None = None
    pkBattleId: str | None = None
    comboStreak: int = Field(default=1, ge=1, le=9999)
    idempotencyKey: str | None = Field(default=None, max_length=80)


class SendGiftResponse(BaseModel):
    transactionId: str
    giftId: str
    giftName: str
    senderId: str
    receiverId: str
    quantity: int
    totalCoinsSpent: int
    diamondsCredited: int
    senderCoinsBalance: int
    senderVipLevel: int
    receiverDiamondsBalance: int
    pkBattleId: str | None = None
    pkHostAScore: int | None = None
    pkHostBScore: int | None = None
    createdAt: datetime


class ConvertDiamondsRequest(BaseModel):
    diamondsAmount: int = Field(..., ge=1, le=10_000_000)


class StripeCheckoutRequest(BaseModel):
    packageId: str = Field(..., min_length=3, max_length=36)


class CheckoutSessionResponse(BaseModel):
    orderId: str
    provider: str
    checkoutUrl: str
    providerSessionId: str


class GooglePlayVerifyRequest(BaseModel):
    packageId: str = Field(..., min_length=3, max_length=36)
    productId: str = Field(..., min_length=2, max_length=120)
    purchaseToken: str = Field(..., min_length=10, max_length=512)


class AppleReceiptVerifyRequest(BaseModel):
    packageId: str = Field(..., min_length=3, max_length=36)
    receiptData: str = Field(..., min_length=20)
    transactionId: str | None = Field(default=None, max_length=160)


class PaymentOrderResponse(BaseModel):
    id: str
    userId: str
    packageId: str
    provider: str
    providerOrderId: str | None = None
    amountCents: int
    currency: str
    coinsCredited: int
    status: str
    newCoinsBalance: int | None = None
    completedAt: datetime | None = None
    createdAt: datetime


class PayoutCreateRequest(BaseModel):
    diamondsAmount: int = Field(..., ge=1)
    payoutMethod: Literal["bank_transfer", "upi", "paypal"]
    accountDetails: dict[str, str] = Field(..., min_length=1)


class PayoutReviewRequest(BaseModel):
    decision: Literal["paid", "rejected"]
    adminNote: str = Field(default="", max_length=255)


class PayoutResponse(BaseModel):
    id: str
    userId: str
    diamondsAmount: int
    payoutAmount: str
    currency: str
    payoutMethod: str
    status: str
    adminNote: str
    reviewedAt: datetime | None = None
    createdAt: datetime


class PayoutListResponse(BaseModel):
    payouts: list[PayoutResponse]
    total: int
