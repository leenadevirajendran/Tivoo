from __future__ import annotations
from fastapi import APIRouter, Depends, Header, Query, Request, status
from sqlalchemy.orm import Session

from app.core.security import get_current_user, require_admin_user
from app.db.session import get_db
from app.models.user import User
from app.modules.wallet_gifts.schemas import (
    AppleReceiptVerifyRequest,
    CheckoutSessionResponse,
    CoinPackageCreateRequest,
    CoinPackageListResponse,
    CoinPackageResponse,
    ConvertDiamondsRequest,
    GiftCatalogListResponse,
    GiftCreateRequest,
    GiftItemResponse,
    GooglePlayVerifyRequest,
    PaymentOrderResponse,
    PayoutCreateRequest,
    PayoutListResponse,
    PayoutResponse,
    PayoutReviewRequest,
    SendGiftRequest,
    SendGiftResponse,
    StripeCheckoutRequest,
    WalletLedgerListResponse,
    WalletSummaryResponse,
)
from app.modules.wallet_gifts.service import wallet_gifts_service

router = APIRouter(prefix="/api/wallet", tags=["Wallet, Coins & Creator Payouts"])
gifts_router = APIRouter(prefix="/api/gifts", tags=["Virtual Gifts"])
webhooks_router = APIRouter(prefix="/api/webhooks", tags=["In-App Purchase Webhooks"])


@gifts_router.get("", response_model=GiftCatalogListResponse)
def list_gifts(
    category: str | None = Query(default=None, max_length=40),
    db: Session = Depends(get_db),
) -> GiftCatalogListResponse:
    """List virtual gifts configured in MySQL gift_catalog."""
    return wallet_gifts_service.list_gifts(db, category=category)


@gifts_router.post("", response_model=GiftItemResponse, status_code=status.HTTP_201_CREATED)
def create_gift_item(
    payload: GiftCreateRequest,
    _: User = Depends(require_admin_user),
    db: Session = Depends(get_db),
) -> GiftItemResponse:
    """Admin endpoint to create a new virtual gift in MySQL gift_catalog."""
    return wallet_gifts_service.create_gift(db, payload)


@gifts_router.post("/send", response_model=SendGiftResponse, status_code=status.HTTP_201_CREATED)
def send_gift(
    payload: SendGiftRequest,
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db),
) -> SendGiftResponse:
    """Send a gift using an ACID MySQL transaction, updating PK scores, VIP level, and live WebSockets."""
    return wallet_gifts_service.send_gift(db, current_user, payload)


@router.get("/me", response_model=WalletSummaryResponse)
def get_my_wallet(
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db),
) -> WalletSummaryResponse:
    """Fetch authenticated user's Coins, Diamonds, spent total, and VIP level."""
    return wallet_gifts_service.get_my_wallet(db, current_user)


@router.get("/ledger", response_model=WalletLedgerListResponse)
def get_my_ledger(
    page: int = Query(default=1, ge=1),
    page_size: int = Query(default=20, ge=1, le=50),
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db),
) -> WalletLedgerListResponse:
    """Fetch immutable Coin/Diamond ledger entries for the authenticated user."""
    return wallet_gifts_service.list_ledger(db, current_user, page=page, page_size=page_size)


@router.get("/packages", response_model=CoinPackageListResponse)
def list_coin_packages(db: Session = Depends(get_db)) -> CoinPackageListResponse:
    """List active Coin recharge packages stored in MySQL."""
    return wallet_gifts_service.list_packages(db)


@router.post("/packages", response_model=CoinPackageResponse, status_code=status.HTTP_201_CREATED)
def create_coin_package(
    payload: CoinPackageCreateRequest,
    _: User = Depends(require_admin_user),
    db: Session = Depends(get_db),
) -> CoinPackageResponse:
    """Admin endpoint to add a Coin recharge package in MySQL."""
    return wallet_gifts_service.create_package(db, payload)


@router.post("/convert-diamonds", response_model=WalletSummaryResponse)
def convert_diamonds_to_coins(
    payload: ConvertDiamondsRequest,
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db),
) -> WalletSummaryResponse:
    """Atomically convert creator Diamonds into spendable Coins."""
    return wallet_gifts_service.convert_diamonds_to_coins(
        db, current_user, payload.diamondsAmount
    )


@router.post("/topup/stripe-session", response_model=CheckoutSessionResponse)
def create_stripe_checkout_session_route(
    payload: StripeCheckoutRequest,
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db),
) -> CheckoutSessionResponse:
    """Create a pending PaymentOrder in MySQL and open a Stripe Checkout session."""
    return wallet_gifts_service.create_stripe_checkout(db, current_user, payload.packageId)


@router.post("/topup/google-play/verify", response_model=PaymentOrderResponse)
def verify_google_play_topup(
    payload: GooglePlayVerifyRequest,
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db),
) -> PaymentOrderResponse:
    """Verify an Android Google Play purchaseToken directly with Google and credit Coins."""
    return wallet_gifts_service.verify_google_play_and_credit(db, current_user, payload)


@router.post("/topup/apple/verify", response_model=PaymentOrderResponse)
def verify_apple_iap_topup(
    payload: AppleReceiptVerifyRequest,
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db),
) -> PaymentOrderResponse:
    """Verify an Apple App Store receipt directly with Apple servers and credit Coins."""
    return wallet_gifts_service.verify_apple_receipt_and_credit(db, current_user, payload)


@router.post("/payouts", response_model=PayoutResponse, status_code=status.HTTP_201_CREATED)
def request_creator_payout(
    payload: PayoutCreateRequest,
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db),
) -> PayoutResponse:
    """Escrow creator Diamonds and submit a payout withdrawal request."""
    return wallet_gifts_service.request_payout(db, current_user, payload)


@router.get("/payouts/me", response_model=PayoutListResponse)
def list_my_payouts(
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db),
) -> PayoutListResponse:
    """List the authenticated creator's payout withdrawal history."""
    return wallet_gifts_service.list_my_payouts(db, current_user)


@router.post("/payouts/{payout_id}/review", response_model=PayoutResponse)
def review_creator_payout(
    payout_id: str,
    payload: PayoutReviewRequest,
    admin_user: User = Depends(require_admin_user),
    db: Session = Depends(get_db),
) -> PayoutResponse:
    """Admin endpoint to approve ('paid') or reject (refund Diamonds) a payout request."""
    return wallet_gifts_service.review_payout(db, admin_user, payout_id, payload)


@webhooks_router.post("/stripe")
async def stripe_webhook(
    request: Request,
    stripe_signature: str = Header(default="", alias="Stripe-Signature"),
    db: Session = Depends(get_db),
) -> dict[str, object]:
    """Receive signed Stripe webhook events and credit Coins idempotently."""
    raw_body = await request.body()
    return wallet_gifts_service.process_stripe_webhook(db, raw_body, stripe_signature)


@webhooks_router.post("/google-play")
async def google_play_rtdn_webhook(
    request: Request,
    x_google_play_secret: str = Header(default="", alias="X-Google-Play-Secret"),
    db: Session = Depends(get_db),
) -> dict[str, object]:
    """Receive Google Play Real-Time Developer Notification webhooks."""
    body = await request.json()
    return wallet_gifts_service.process_google_play_webhook(db, body, x_google_play_secret)


@webhooks_router.post("/apple-iap")
async def apple_iap_webhook(
    request: Request,
    x_apple_webhook_secret: str = Header(default="", alias="X-Apple-Webhook-Secret"),
    db: Session = Depends(get_db),
) -> dict[str, object]:
    """Receive signed App Store Server Notification v2 JWS webhooks."""
    body = await request.json()
    return wallet_gifts_service.process_apple_webhook(db, body, x_apple_webhook_secret)
