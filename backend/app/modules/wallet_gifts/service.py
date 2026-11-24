from __future__ import annotations
import base64
from decimal import Decimal
import hmac
import json

from sqlalchemy import and_, desc, func, select
from sqlalchemy.exc import IntegrityError
from sqlalchemy.orm import Session, joinedload

from app.core.config import get_settings
from app.core.exceptions import (
    BadRequestError,
    ConflictError,
    ForbiddenError,
    NotFoundError,
    ServiceUnavailableError,
    UnauthorizedError,
)
from app.core.security import utc_now
from app.models.user import User
from app.modules.leaderboards_vip.models import VipLevelConfig
from app.modules.live_gateway.models import LiveRoom
from app.modules.notifications_fcm.service import notification_service
from app.modules.pk_battle.models import PkBattle, PkScoreEvent
from app.modules.pk_battle.service import pk_battle_service
from app.modules.wallet_gifts.models import (
    CoinPackage,
    GiftCatalog,
    GiftTransaction,
    PaymentOrder,
    PayoutRequest,
    UserWallet,
    WalletLedgerEntry,
)
from app.modules.wallet_gifts.schemas import (
    AppleReceiptVerifyRequest,
    CheckoutSessionResponse,
    CoinPackageCreateRequest,
    CoinPackageListResponse,
    CoinPackageResponse,
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
    WalletLedgerEntryResponse,
    WalletLedgerListResponse,
    WalletSummaryResponse,
)
from app.modules.wallet_gifts.webhooks import (
    create_stripe_checkout_session,
    decode_apple_signed_jws,
    verify_apple_receipt,
    verify_google_play_purchase,
    verify_stripe_signature,
)
from app.realtime.connection_manager import realtime_hub


class WalletGiftsService:
    """ACID-compliant coin/diamond ledger, gift transfers, IAP webhooks, and creator payouts."""

    @staticmethod
    def _ensure_wallet_exists(db: Session, user_id: str) -> UserWallet:
        wallet = db.get(UserWallet, user_id)
        if wallet:
            return wallet
        try:
            with db.begin_nested():
                wallet = UserWallet(user_id=user_id)
                db.add(wallet)
                db.flush()
            return wallet
        except IntegrityError:
            wallet = db.get(UserWallet, user_id)
            if not wallet:
                raise
            return wallet

    def _lock_wallets(self, db: Session, user_ids: list[str]) -> dict[str, UserWallet]:
        unique_sorted = sorted(set(user_ids))
        for uid in unique_sorted:
            self._ensure_wallet_exists(db, uid)
        rows = list(
            db.scalars(
                select(UserWallet)
                .where(UserWallet.user_id.in_(unique_sorted))
                .order_by(UserWallet.user_id.asc())
                .with_for_update()
            ).all()
        )
        return {row.user_id: row for row in rows}

    @staticmethod
    def _recompute_vip_level(db: Session, total_coins_spent: int) -> int:
        level = db.scalar(
            select(func.max(VipLevelConfig.level)).where(
                and_(
                    VipLevelConfig.is_active.is_(True),
                    VipLevelConfig.min_coins_spent <= total_coins_spent,
                )
            )
        )
        return int(level or 0)

    @staticmethod
    def _serialize_wallet(w: UserWallet) -> WalletSummaryResponse:
        return WalletSummaryResponse(
            userId=w.user_id,
            coinsBalance=w.coins_balance,
            diamondsBalance=w.diamonds_balance,
            totalCoinsSpent=w.total_coins_spent,
            totalDiamondsEarned=w.total_diamonds_earned,
            vipLevel=w.vip_level,
            updatedAt=w.updated_at,
        )

    @staticmethod
    def _serialize_gift(g: GiftCatalog) -> GiftItemResponse:
        return GiftItemResponse(
            id=g.id,
            code=g.code,
            name=g.name,
            category=g.category,
            icon=g.icon,
            animationUrl=g.animation_url,
            coinCost=g.coin_cost,
            diamondValue=g.diamond_value,
            tagline=g.tagline,
            sortOrder=g.sort_order,
            isActive=g.is_active,
        )

    @staticmethod
    def _serialize_package(p: CoinPackage) -> CoinPackageResponse:
        return CoinPackageResponse(
            id=p.id,
            code=p.code,
            title=p.title,
            coinsAmount=p.coins_amount,
            bonusCoins=p.bonus_coins,
            totalCoins=p.coins_amount + p.bonus_coins,
            priceCents=p.price_cents,
            currency=p.currency,
            storeProductId=p.store_product_id,
            isPopular=p.is_popular,
        )

    @staticmethod
    def _serialize_payout(p: PayoutRequest) -> PayoutResponse:
        return PayoutResponse(
            id=p.id,
            userId=p.user_id,
            diamondsAmount=p.diamonds_amount,
            payoutAmount=f"{p.payout_amount:.2f}",
            currency=p.currency,
            payoutMethod=p.payout_method,
            status=p.status,
            adminNote=p.admin_note,
            reviewedAt=p.reviewed_at,
            createdAt=p.created_at,
        )

    def get_my_wallet(self, db: Session, user: User) -> WalletSummaryResponse:
        wallet = self._ensure_wallet_exists(db, user.id)
        db.commit()
        db.refresh(wallet)
        return self._serialize_wallet(wallet)

    def list_ledger(
        self,
        db: Session,
        user: User,
        page: int = 1,
        page_size: int = 20,
    ) -> WalletLedgerListResponse:
        total = int(
            db.scalar(
                select(func.count())
                .select_from(WalletLedgerEntry)
                .where(WalletLedgerEntry.user_id == user.id)
            )
            or 0
        )
        rows = list(
            db.scalars(
                select(WalletLedgerEntry)
                .where(WalletLedgerEntry.user_id == user.id)
                .order_by(WalletLedgerEntry.created_at.desc())
                .offset((page - 1) * page_size)
                .limit(page_size)
            ).all()
        )
        return WalletLedgerListResponse(
            entries=[
                WalletLedgerEntryResponse(
                    id=r.id,
                    entryType=r.entry_type,
                    currency=r.currency,
                    deltaAmount=r.delta_amount,
                    balanceAfter=r.balance_after,
                    referenceType=r.reference_type,
                    referenceId=r.reference_id,
                    description=r.description,
                    createdAt=r.created_at,
                )
                for r in rows
            ],
            total=total,
            page=page,
            pageSize=page_size,
            hasMore=(page * page_size) < total,
        )

    def list_gifts(
        self,
        db: Session,
        category: str | None = None,
        include_inactive: bool = False,
    ) -> GiftCatalogListResponse:
        conditions = []
        if not include_inactive:
            conditions.append(GiftCatalog.is_active.is_(True))
        if category and category.strip().lower() != "all":
            conditions.append(GiftCatalog.category == category.strip())

        rows = list(
            db.scalars(
                select(GiftCatalog)
                .where(*conditions)
                .order_by(GiftCatalog.sort_order.asc(), GiftCatalog.coin_cost.asc())
            ).all()
        )
        return GiftCatalogListResponse(
            gifts=[self._serialize_gift(r) for r in rows],
            total=len(rows),
        )

    def create_gift(self, db: Session, payload: GiftCreateRequest) -> GiftItemResponse:
        settings = get_settings()
        existing = db.scalar(select(GiftCatalog).where(GiftCatalog.code == payload.code))
        if existing:
            raise ConflictError(f"Gift code '{payload.code}' already exists")

        diamond_value = payload.diamondValue
        if diamond_value is None:
            diamond_value = max(1, int(round(payload.coinCost * settings.gift_coin_to_diamond_rate)))

        gift = GiftCatalog(
            code=payload.code.strip(),
            name=payload.name.strip(),
            category=payload.category.strip() or "Popular",
            icon=payload.icon.strip(),
            animation_url=payload.animationUrl.strip(),
            coin_cost=payload.coinCost,
            diamond_value=diamond_value,
            tagline=payload.tagline.strip(),
            sort_order=payload.sortOrder,
            is_active=payload.isActive,
        )
        db.add(gift)
        db.commit()
        db.refresh(gift)
        return self._serialize_gift(gift)

    def list_packages(self, db: Session) -> CoinPackageListResponse:
        rows = list(
            db.scalars(
                select(CoinPackage)
                .where(CoinPackage.is_active.is_(True))
                .order_by(CoinPackage.price_cents.asc())
            ).all()
        )
        return CoinPackageListResponse(
            packages=[self._serialize_package(r) for r in rows],
            total=len(rows),
        )

    def create_package(self, db: Session, payload: CoinPackageCreateRequest) -> CoinPackageResponse:
        existing = db.scalar(select(CoinPackage).where(CoinPackage.code == payload.code))
        if existing:
            raise ConflictError(f"Coin package code '{payload.code}' already exists")

        pkg = CoinPackage(
            code=payload.code.strip(),
            title=payload.title.strip(),
            coins_amount=payload.coinsAmount,
            bonus_coins=payload.bonusCoins,
            price_cents=payload.priceCents,
            currency=payload.currency.strip().upper(),
            store_product_id=payload.storeProductId.strip() if payload.storeProductId else None,
            is_popular=payload.isPopular,
            is_active=payload.isActive,
        )
        db.add(pkg)
        db.commit()
        db.refresh(pkg)
        return self._serialize_package(pkg)

    def send_gift(self, db: Session, sender: User, payload: SendGiftRequest) -> SendGiftResponse:
        """Execute an ACID coin-debit & diamond-credit gift transfer with PK score updates."""
        if payload.receiverId == sender.id:
            raise BadRequestError("You cannot send virtual gifts to yourself")

        if payload.idempotencyKey:
            prior = db.scalar(
                select(GiftTransaction)
                .options(joinedload(GiftTransaction.gift))
                .where(GiftTransaction.idempotency_key == payload.idempotencyKey.strip())
            )
            if prior:
                wallets = {
                    w.user_id: w
                    for w in db.scalars(
                        select(UserWallet).where(UserWallet.user_id.in_([prior.sender_id, prior.receiver_id]))
                    ).all()
                }
                s_w = wallets.get(prior.sender_id)
                r_w = wallets.get(prior.receiver_id)
                return SendGiftResponse(
                    transactionId=prior.id,
                    giftId=prior.gift_id,
                    giftName=prior.gift.name if prior.gift else "Gift",
                    senderId=prior.sender_id,
                    receiverId=prior.receiver_id,
                    quantity=prior.quantity,
                    totalCoinsSpent=prior.total_coins,
                    diamondsCredited=prior.diamonds_credited,
                    senderCoinsBalance=s_w.coins_balance if s_w else 0,
                    senderVipLevel=s_w.vip_level if s_w else 0,
                    receiverDiamondsBalance=r_w.diamonds_balance if r_w else 0,
                    pkBattleId=prior.pk_battle_id,
                    createdAt=prior.created_at,
                )

        gift = db.get(GiftCatalog, payload.giftId)
        if not gift or not gift.is_active:
            raise NotFoundError("Gift item not found or inactive")

        receiver = db.get(User, payload.receiverId)
        if not receiver or not receiver.is_active:
            raise NotFoundError("Recipient creator not found")

        room: LiveRoom | None = None
        if payload.liveRoomId:
            room = db.scalar(
                select(LiveRoom).where(LiveRoom.id == payload.liveRoomId).with_for_update()
            )
            if not room or room.status == "ended":
                raise NotFoundError("Live room not found or has ended")
            if not room.allow_gifts:
                raise ForbiddenError("Gifts are disabled in this live room")

        battle: PkBattle | None = None
        if payload.pkBattleId:
            battle = db.scalar(
                select(PkBattle)
                .options(joinedload(PkBattle.host_a), joinedload(PkBattle.host_b))
                .where(PkBattle.id == payload.pkBattleId)
                .with_for_update()
            )
            if not battle:
                raise NotFoundError("PK battle not found")
            battle = pk_battle_service.auto_finalize_if_expired(db, battle)
            if battle.status != "active":
                raise BadRequestError(f"PK battle is '{battle.status}' and cannot receive points")
            if receiver.id not in (battle.host_a_id, battle.host_b_id):
                raise BadRequestError("Recipient must be Host A or Host B in this PK battle")

        total_coins = gift.coin_cost * payload.quantity
        diamonds_credited = gift.diamond_value * payload.quantity

        locked = self._lock_wallets(db, [sender.id, receiver.id])
        sender_wallet = locked[sender.id]
        receiver_wallet = locked[receiver.id]

        if sender_wallet.coins_balance < total_coins:
            raise BadRequestError(
                f"Insufficient Coins balance ({sender_wallet.coins_balance} available, {total_coins} required)"
            )

        sender_wallet.coins_balance -= total_coins
        sender_wallet.total_coins_spent += total_coins
        sender_wallet.vip_level = self._recompute_vip_level(db, sender_wallet.total_coins_spent)

        receiver_wallet.diamonds_balance += diamonds_credited
        receiver_wallet.total_diamonds_earned += diamonds_credited

        tx = GiftTransaction(
            idempotency_key=payload.idempotencyKey.strip() if payload.idempotencyKey else None,
            sender_id=sender.id,
            receiver_id=receiver.id,
            gift_id=gift.id,
            live_room_id=room.id if room else None,
            pk_battle_id=battle.id if battle else None,
            quantity=payload.quantity,
            total_coins=total_coins,
            diamonds_credited=diamonds_credited,
            combo_streak=payload.comboStreak,
        )
        db.add(tx)
        db.flush()

        db.add(
            WalletLedgerEntry(
                user_id=sender.id,
                entry_type="gift_sent",
                currency="coins",
                delta_amount=-total_coins,
                balance_after=sender_wallet.coins_balance,
                reference_type="gift_transaction",
                reference_id=tx.id,
                description=f"Sent {payload.quantity}x {gift.name} to @{receiver.username}",
            )
        )
        db.add(
            WalletLedgerEntry(
                user_id=receiver.id,
                entry_type="gift_received",
                currency="diamonds",
                delta_amount=diamonds_credited,
                balance_after=receiver_wallet.diamonds_balance,
                reference_type="gift_transaction",
                reference_id=tx.id,
                description=f"Received {payload.quantity}x {gift.name} from @{sender.username}",
            )
        )

        if room:
            room.total_gifts_diamonds += diamonds_credited

        pk_a_score: int | None = None
        pk_b_score: int | None = None
        if battle:
            if receiver.id == battle.host_a_id:
                battle.host_a_score += total_coins
            else:
                battle.host_b_score += total_coins
            pk_a_score = battle.host_a_score
            pk_b_score = battle.host_b_score
            db.add(
                PkScoreEvent(
                    battle_id=battle.id,
                    target_host_id=receiver.id,
                    sender_id=sender.id,
                    gift_transaction_id=tx.id,
                    points_added=total_coins,
                    host_a_score_after=battle.host_a_score,
                    host_b_score_after=battle.host_b_score,
                )
            )

        db.commit()
        db.refresh(tx)

        gift_event = {
            "transactionId": tx.id,
            "giftId": gift.id,
            "giftCode": gift.code,
            "giftName": gift.name,
            "icon": gift.icon,
            "animationUrl": gift.animation_url,
            "senderId": sender.id,
            "senderName": sender.name,
            "senderUsername": sender.username,
            "senderVipLevel": sender_wallet.vip_level,
            "receiverId": receiver.id,
            "quantity": payload.quantity,
            "comboStreak": payload.comboStreak,
            "totalCoins": total_coins,
            "diamondsCredited": diamonds_credited,
        }
        if room:
            realtime_hub.broadcast_room_sync(room.id, "gift_sent", gift_event)
        if battle:
            battle_payload = pk_battle_service.serialize_battle(battle).model_dump(mode="json")
            realtime_hub.broadcast_room_sync(f"pk:{battle.id}", "pk_score_updated", battle_payload)
            if battle.room_a_id:
                realtime_hub.broadcast_room_sync(battle.room_a_id, "pk_score_updated", battle_payload)
            if battle.room_b_id and battle.room_b_id != battle.room_a_id:
                realtime_hub.broadcast_room_sync(battle.room_b_id, "pk_score_updated", battle_payload)

        notification_service.notify_gift_received(
            db=db,
            sender=sender,
            recipient_id=receiver.id,
            gift_name=gift.name,
            quantity=payload.quantity,
            diamonds_credited=diamonds_credited,
            room_id=room.id if room else None,
        )

        return SendGiftResponse(
            transactionId=tx.id,
            giftId=gift.id,
            giftName=gift.name,
            senderId=sender.id,
            receiverId=receiver.id,
            quantity=payload.quantity,
            totalCoinsSpent=total_coins,
            diamondsCredited=diamonds_credited,
            senderCoinsBalance=sender_wallet.coins_balance,
            senderVipLevel=sender_wallet.vip_level,
            receiverDiamondsBalance=receiver_wallet.diamonds_balance,
            pkBattleId=battle.id if battle else None,
            pkHostAScore=pk_a_score,
            pkHostBScore=pk_b_score,
            createdAt=tx.created_at,
        )

    def convert_diamonds_to_coins(
        self,
        db: Session,
        user: User,
        diamonds_amount: int,
    ) -> WalletSummaryResponse:
        locked = self._lock_wallets(db, [user.id])
        wallet = locked[user.id]
        if wallet.diamonds_balance < diamonds_amount:
            raise BadRequestError(
                f"Insufficient Diamonds balance ({wallet.diamonds_balance} available)"
            )

        wallet.diamonds_balance -= diamonds_amount
        wallet.coins_balance += diamonds_amount
        db.add(
            WalletLedgerEntry(
                user_id=user.id,
                entry_type="diamond_convert_debit",
                currency="diamonds",
                delta_amount=-diamonds_amount,
                balance_after=wallet.diamonds_balance,
                reference_type="conversion",
                reference_id=user.id,
                description=f"Converted {diamonds_amount} Diamonds into Coins",
            )
        )
        db.add(
            WalletLedgerEntry(
                user_id=user.id,
                entry_type="coin_convert_credit",
                currency="coins",
                delta_amount=diamonds_amount,
                balance_after=wallet.coins_balance,
                reference_type="conversion",
                reference_id=user.id,
                description=f"Received {diamonds_amount} Coins from Diamond conversion",
            )
        )
        db.commit()
        db.refresh(wallet)
        return self._serialize_wallet(wallet)

    def _credit_payment_order_idempotently(
        self,
        db: Session,
        order_id: str | None,
        user_id: str,
        package: CoinPackage,
        provider: str,
        provider_order_id: str,
        provider_event_id: str,
        raw_payload: dict,
    ) -> PaymentOrderResponse:
        existing_event = db.scalar(
            select(PaymentOrder).where(PaymentOrder.provider_event_id == provider_event_id)
        )
        if existing_event:
            wallet = self._ensure_wallet_exists(db, existing_event.user_id)
            return PaymentOrderResponse(
                id=existing_event.id,
                userId=existing_event.user_id,
                packageId=existing_event.package_id,
                provider=existing_event.provider,
                providerOrderId=existing_event.provider_order_id,
                amountCents=existing_event.amount_cents,
                currency=existing_event.currency,
                coinsCredited=existing_event.coins_credited,
                status=existing_event.status,
                newCoinsBalance=wallet.coins_balance,
                completedAt=existing_event.completed_at,
                createdAt=existing_event.created_at,
            )

        order = (
            db.scalar(
                select(PaymentOrder).where(PaymentOrder.id == order_id).with_for_update()
            )
            if order_id
            else None
        )
        coins_total = package.coins_amount + package.bonus_coins
        if not order:
            order = PaymentOrder(
                user_id=user_id,
                package_id=package.id,
                provider=provider,
                provider_order_id=provider_order_id,
                provider_event_id=provider_event_id,
                amount_cents=package.price_cents,
                currency=package.currency,
                coins_credited=coins_total,
                status="pending",
                raw_payload=raw_payload,
            )
            db.add(order)
            db.flush()
        else:
            if order.status == "completed":
                wallet = self._ensure_wallet_exists(db, order.user_id)
                return PaymentOrderResponse(
                    id=order.id,
                    userId=order.user_id,
                    packageId=order.package_id,
                    provider=order.provider,
                    providerOrderId=order.provider_order_id,
                    amountCents=order.amount_cents,
                    currency=order.currency,
                    coinsCredited=order.coins_credited,
                    status=order.status,
                    newCoinsBalance=wallet.coins_balance,
                    completedAt=order.completed_at,
                    createdAt=order.created_at,
                )
            order.provider_order_id = provider_order_id
            order.provider_event_id = provider_event_id
            order.raw_payload = raw_payload

        locked = self._lock_wallets(db, [order.user_id])
        wallet = locked[order.user_id]
        wallet.coins_balance += coins_total
        order.status = "completed"
        order.completed_at = utc_now()

        db.add(
            WalletLedgerEntry(
                user_id=order.user_id,
                entry_type="topup",
                currency="coins",
                delta_amount=coins_total,
                balance_after=wallet.coins_balance,
                reference_type="payment_order",
                reference_id=order.id,
                description=f"Purchased {package.title} (+{coins_total} Coins via {provider})",
            )
        )
        db.commit()
        db.refresh(order)
        db.refresh(wallet)

        return PaymentOrderResponse(
            id=order.id,
            userId=order.user_id,
            packageId=order.package_id,
            provider=order.provider,
            providerOrderId=order.provider_order_id,
            amountCents=order.amount_cents,
            currency=order.currency,
            coinsCredited=order.coins_credited,
            status=order.status,
            newCoinsBalance=wallet.coins_balance,
            completedAt=order.completed_at,
            createdAt=order.created_at,
        )

    def create_stripe_checkout(
        self,
        db: Session,
        user: User,
        package_id: str,
    ) -> CheckoutSessionResponse:
        package = db.get(CoinPackage, package_id)
        if not package or not package.is_active:
            raise NotFoundError("Coin package not found or inactive")

        coins_total = package.coins_amount + package.bonus_coins
        order = PaymentOrder(
            user_id=user.id,
            package_id=package.id,
            provider="stripe",
            amount_cents=package.price_cents,
            currency=package.currency,
            coins_credited=coins_total,
            status="pending",
        )
        db.add(order)
        db.commit()
        db.refresh(order)

        session_id, checkout_url = create_stripe_checkout_session(
            order_id=order.id,
            user_id=user.id,
            package_id=package.id,
            package_title=package.title,
            coins_total=coins_total,
            price_cents=package.price_cents,
            currency=package.currency,
        )
        order.provider_order_id = session_id
        db.commit()
        return CheckoutSessionResponse(
            orderId=order.id,
            provider="stripe",
            checkoutUrl=checkout_url,
            providerSessionId=session_id,
        )

    def process_stripe_webhook(
        self,
        db: Session,
        raw_body: bytes,
        signature_header: str,
    ) -> dict[str, object]:
        event = verify_stripe_signature(raw_body, signature_header)
        event_id = str(event.get("id", ""))
        event_type = str(event.get("type", ""))
        if event_type != "checkout.session.completed":
            return {"received": True, "ignored": event_type}

        obj = event.get("data", {}).get("object", {}) or {}
        if obj.get("payment_status") not in (None, "paid", "no_payment_required"):
            return {"received": True, "status": obj.get("payment_status")}

        metadata = obj.get("metadata") or {}
        order_id = metadata.get("order_id") or obj.get("client_reference_id")
        user_id = metadata.get("user_id")
        package_id = metadata.get("package_id")

        order = db.get(PaymentOrder, order_id) if order_id else None
        if order:
            user_id = order.user_id
            package_id = order.package_id

        if not user_id or not package_id:
            raise BadRequestError("Stripe webhook missing order metadata")
        package = db.get(CoinPackage, package_id)
        if not package:
            raise NotFoundError("Coin package not found")

        result = self._credit_payment_order_idempotently(
            db=db,
            order_id=order.id if order else None,
            user_id=str(user_id),
            package=package,
            provider="stripe",
            provider_order_id=str(obj.get("id") or ""),
            provider_event_id=event_id or f"stripe_{obj.get('id')}",
            raw_payload=event,
        )
        return {"received": True, "order": result.model_dump(mode="json")}

    def verify_google_play_and_credit(
        self,
        db: Session,
        user: User,
        payload: GooglePlayVerifyRequest,
    ) -> PaymentOrderResponse:
        package = db.get(CoinPackage, payload.packageId)
        if not package or not package.is_active:
            raise NotFoundError("Coin package not found or inactive")
        if package.store_product_id and package.store_product_id != payload.productId:
            raise BadRequestError("Product SKU does not match selected coin package")

        purchase_data = verify_google_play_purchase(payload.productId, payload.purchaseToken)
        provider_order_id = str(purchase_data.get("orderId") or payload.purchaseToken[:48])
        return self._credit_payment_order_idempotently(
            db=db,
            order_id=None,
            user_id=user.id,
            package=package,
            provider="google_play",
            provider_order_id=provider_order_id,
            provider_event_id=f"gp_{provider_order_id}",
            raw_payload=purchase_data,
        )

    def verify_apple_receipt_and_credit(
        self,
        db: Session,
        user: User,
        payload: AppleReceiptVerifyRequest,
    ) -> PaymentOrderResponse:
        package = db.get(CoinPackage, payload.packageId)
        if not package or not package.is_active:
            raise NotFoundError("Coin package not found or inactive")

        receipt_resp = verify_apple_receipt(payload.receiptData)
        latest = receipt_resp.get("receipt", {}).get("in_app") or []
        tx_info = latest[-1] if latest else {}
        tx_id = str(
            tx_info.get("transaction_id")
            or payload.transactionId
            or ""
        ).strip()
        if not tx_id:
            raise BadRequestError("Apple receipt missing transaction_id")

        if package.store_product_id and tx_info.get("product_id") and tx_info.get("product_id") != package.store_product_id:
            raise BadRequestError("Apple receipt product_id mismatch")

        return self._credit_payment_order_idempotently(
            db=db,
            order_id=None,
            user_id=user.id,
            package=package,
            provider="apple_iap",
            provider_order_id=tx_id,
            provider_event_id=f"apple_{tx_id}",
            raw_payload=tx_info,
        )

    def process_google_play_webhook(
        self,
        db: Session,
        body: dict,
        provided_secret: str,
    ) -> dict[str, object]:
        settings = get_settings()
        expected = settings.google_play_webhook_secret.strip()
        if not expected:
            raise ServiceUnavailableError("GOOGLE_PLAY_WEBHOOK_SECRET is not configured in .env")
        if not hmac.compare_digest(provided_secret, expected):
            raise UnauthorizedError("Invalid Google Play webhook secret")

        message = body.get("message") or {}
        raw_data = message.get("data")
        if not raw_data:
            return {"received": True, "ignored": "no_pubsub_data"}
        decoded = json.loads(base64.b64decode(raw_data).decode("utf-8"))
        notif = decoded.get("oneTimeProductNotification") or {}
        sku = notif.get("sku")
        purchase_token = notif.get("purchaseToken")
        if not sku or not purchase_token or int(notif.get("notificationType", 0)) != 1:
            return {"received": True, "ignored": "non_purchase_notification"}

        package = db.scalar(select(CoinPackage).where(CoinPackage.store_product_id == sku))
        if not package:
            raise NotFoundError(f"Coin package not found for SKU '{sku}'")
        purchase_data = verify_google_play_purchase(sku, purchase_token)
        user_id = purchase_data.get("obfuscatedExternalAccountId")
        if not user_id:
            raise BadRequestError("Google Play purchase missing obfuscatedExternalAccountId")

        provider_order_id = str(purchase_data.get("orderId") or purchase_token[:48])
        result = self._credit_payment_order_idempotently(
            db=db,
            order_id=None,
            user_id=str(user_id),
            package=package,
            provider="google_play",
            provider_order_id=provider_order_id,
            provider_event_id=f"gp_{provider_order_id}",
            raw_payload=purchase_data,
        )
        return {"received": True, "order": result.model_dump(mode="json")}

    def process_apple_webhook(
        self,
        db: Session,
        body: dict,
        provided_secret: str,
    ) -> dict[str, object]:
        settings = get_settings()
        expected = settings.apple_iap_webhook_secret.strip()
        if expected and not hmac.compare_digest(provided_secret, expected):
            raise UnauthorizedError("Invalid Apple IAP webhook secret")

        signed_payload = body.get("signedPayload")
        if not signed_payload:
            raise BadRequestError("Missing signedPayload JWS")
        decoded = decode_apple_signed_jws(signed_payload)
        tx_jws = (decoded.get("data") or {}).get("signedTransactionInfo")
        tx_data = decode_apple_signed_jws(tx_jws) if tx_jws else {}

        sku = tx_data.get("productId")
        tx_id = tx_data.get("transactionId")
        user_id = tx_data.get("appAccountToken")
        if not sku or not tx_id or not user_id:
            return {"received": True, "notificationType": decoded.get("notificationType")}

        package = db.scalar(select(CoinPackage).where(CoinPackage.store_product_id == sku))
        if not package:
            raise NotFoundError(f"Coin package not found for productId '{sku}'")

        result = self._credit_payment_order_idempotently(
            db=db,
            order_id=None,
            user_id=str(user_id),
            package=package,
            provider="apple_iap",
            provider_order_id=str(tx_id),
            provider_event_id=f"apple_{tx_id}",
            raw_payload=tx_data,
        )
        return {"received": True, "order": result.model_dump(mode="json")}

    def request_payout(
        self,
        db: Session,
        user: User,
        payload: PayoutCreateRequest,
    ) -> PayoutResponse:
        settings = get_settings()
        if payload.diamondsAmount < settings.min_withdrawal_diamonds:
            raise BadRequestError(
                f"Minimum withdrawal is {settings.min_withdrawal_diamonds} Diamonds"
            )

        locked = self._lock_wallets(db, [user.id])
        wallet = locked[user.id]
        if wallet.diamonds_balance < payload.diamondsAmount:
            raise BadRequestError(
                f"Insufficient Diamonds balance ({wallet.diamonds_balance} available)"
            )

        payout_amount = (
            Decimal(payload.diamondsAmount) * Decimal(str(settings.diamond_to_currency_rate))
        ).quantize(Decimal("0.01"))

        wallet.diamonds_balance -= payload.diamondsAmount
        payout = PayoutRequest(
            user_id=user.id,
            diamonds_amount=payload.diamondsAmount,
            payout_amount=payout_amount,
            currency=settings.payout_currency,
            payout_method=payload.payoutMethod,
            account_details=payload.accountDetails,
            status="pending",
        )
        db.add(payout)
        db.flush()

        db.add(
            WalletLedgerEntry(
                user_id=user.id,
                entry_type="withdrawal_request",
                currency="diamonds",
                delta_amount=-payload.diamondsAmount,
                balance_after=wallet.diamonds_balance,
                reference_type="payout_request",
                reference_id=payout.id,
                description=f"Requested {payload.payoutMethod} withdrawal for {payout_amount} {settings.payout_currency}",
            )
        )
        db.commit()
        db.refresh(payout)
        return self._serialize_payout(payout)

    def list_my_payouts(self, db: Session, user: User) -> PayoutListResponse:
        rows = list(
            db.scalars(
                select(PayoutRequest)
                .where(PayoutRequest.user_id == user.id)
                .order_by(desc(PayoutRequest.created_at))
            ).all()
        )
        return PayoutListResponse(
            payouts=[self._serialize_payout(r) for r in rows],
            total=len(rows),
        )

    def review_payout(
        self,
        db: Session,
        admin_user: User,
        payout_id: str,
        payload: PayoutReviewRequest,
    ) -> PayoutResponse:
        payout = db.scalar(
            select(PayoutRequest).where(PayoutRequest.id == payout_id).with_for_update()
        )
        if not payout:
            raise NotFoundError("Payout request not found")
        if payout.status != "pending":
            raise BadRequestError(f"Payout request is already '{payout.status}'")

        payout.status = payload.decision
        payout.admin_note = payload.adminNote.strip()
        payout.reviewed_by_id = admin_user.id
        payout.reviewed_at = utc_now()

        if payload.decision == "rejected":
            locked = self._lock_wallets(db, [payout.user_id])
            wallet = locked[payout.user_id]
            wallet.diamonds_balance += payout.diamonds_amount
            db.add(
                WalletLedgerEntry(
                    user_id=payout.user_id,
                    entry_type="withdrawal_refund",
                    currency="diamonds",
                    delta_amount=payout.diamonds_amount,
                    balance_after=wallet.diamonds_balance,
                    reference_type="payout_request",
                    reference_id=payout.id,
                    description=f"Refunded rejected payout ({payout.admin_note or 'rejected by admin'})",
                )
            )

        db.commit()
        db.refresh(payout)
        return self._serialize_payout(payout)


wallet_gifts_service = WalletGiftsService()
