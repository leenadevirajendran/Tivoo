from __future__ import annotations
from contextlib import contextmanager
from decimal import Decimal
import hashlib
import hmac
import time
import uuid

from fastapi.testclient import TestClient
import pytest
from sqlalchemy import text

from app.core.config import get_settings
from app.db.session import SessionLocal
from app.main import app
from app.models.user import User
from app.modules.leaderboards_vip.models import VipLevelConfig
from app.modules.wallet_gifts.models import CoinPackage, GiftCatalog, UserWallet


def _uid() -> str:
    return uuid.uuid4().hex[:10]


@contextmanager
def _cleanup_test_data(user_ids: list[str], gift_ids: list[str] | None = None, package_ids: list[str] | None = None, vip_levels: list[int] | None = None):
    try:
        yield
    finally:
        db = SessionLocal()
        try:
            for uid in user_ids:
                u = db.get(User, uid)
                if u:
                    db.delete(u)
            for gid in gift_ids or []:
                g = db.get(GiftCatalog, gid)
                if g:
                    db.delete(g)
            for pid in package_ids or []:
                p = db.get(CoinPackage, pid)
                if p:
                    db.delete(p)
            for lvl in vip_levels or []:
                v = db.get(VipLevelConfig, lvl)
                if v:
                    db.delete(v)
            db.commit()
        finally:
            db.close()


def _create_user(client: TestClient, role_suffix: str) -> tuple[str, str, dict[str, str]]:
    suffix = _uid()
    email = f"{role_suffix}.{suffix}@example.com"
    username = f"{role_suffix}_{suffix}"
    reg = client.post(
        "/api/auth/register",
        json={
            "name": f"User {role_suffix.title()}",
            "username": username,
            "email": email,
            "password": "Password123!",
        },
    )
    assert reg.status_code == 201, reg.text
    data = reg.json()
    token = data["accessToken"]
    uid = data["user"]["id"]
    return uid, username, {"Authorization": f"Bearer {token}"}


def test_live_streaming_gateway_lifecycle() -> None:
    users: list[str] = []
    with _cleanup_test_data(users):
        with TestClient(app) as client:
            host_id, _, host_h = _create_user(client, "host")
            viewer_id, _, viewer_h = _create_user(client, "viewer")
            users.extend([host_id, viewer_id])

            # 1. Create live room (default provider: livekit)
            create_res = client.post(
                "/api/live/rooms",
                headers=host_h,
                json={
                    "title": "Evening Music Live Show",
                    "category": "Music",
                    "provider": "rtmp",
                    "allowChat": True,
                    "allowGifts": True,
                    "allowPk": True,
                },
            )
            assert create_res.status_code == 201, create_res.text
            room = create_res.json()
            room_id = room["id"]
            stream_key = room["streamKey"]
            assert stream_key.startswith("tk_")
            assert room["status"] == "scheduled"
            assert room["rtmpIngestUrl"]
            assert room["playbackHlsUrl"]

            # 2. Rotate stream key
            rotate_res = client.post(f"/api/live/rooms/{room_id}/rotate-key", headers=host_h)
            assert rotate_res.status_code == 200
            new_key = rotate_res.json()["streamKey"]
            assert new_key != stream_key

            # 3. Start room (goes LIVE)
            start_res = client.post(f"/api/live/rooms/{room_id}/start", headers=host_h)
            assert start_res.status_code == 200
            assert start_res.json()["status"] == "live"
            assert start_res.json()["startedAt"] is not None

            # 4. Viewer joins room (provider=rtmp gives HLS playback URL directly)
            join_res = client.post(f"/api/live/rooms/{room_id}/join", headers=viewer_h)
            assert join_res.status_code == 200
            join_data = join_res.json()
            assert join_data["playbackHlsUrl"]

            # Check room viewer count is 1
            get_res = client.get(f"/api/live/rooms/{room_id}")
            assert get_res.status_code == 200
            assert get_res.json()["viewerCount"] == 1

            # 5. Like room
            like_res = client.post(f"/api/live/rooms/{room_id}/like", headers=viewer_h)
            assert like_res.status_code == 200
            assert like_res.json()["likesCount"] == 1

            # 6. Viewer leaves room
            leave_res = client.post(f"/api/live/rooms/{room_id}/leave", headers=viewer_h)
            assert leave_res.status_code == 200
            assert leave_res.json()["viewerCount"] == 0

            # 7. End room
            end_res = client.post(f"/api/live/rooms/{room_id}/end", headers=host_h)
            assert end_res.status_code == 200
            assert end_res.json()["status"] == "ended"


def test_pk_battle_engine_matchmaking_and_settlement() -> None:
    users: list[str] = []
    with _cleanup_test_data(users):
        with TestClient(app) as client:
            host_a_id, _, h_a = _create_user(client, "pka")
            host_b_id, _, h_b = _create_user(client, "pkb")
            users.extend([host_a_id, host_b_id])

            # 1. Host A enters matchmaking queue
            q1 = client.post("/api/pk/queue/join", headers=h_a, json={"durationSeconds": 60})
            assert q1.status_code == 200
            assert q1.json()["matched"] is False
            assert q1.json()["queueStatus"] == "waiting"

            # 2. Host B enters queue -> matched immediately!
            q2 = client.post("/api/pk/queue/join", headers=h_b, json={"durationSeconds": 60})
            assert q2.status_code == 200
            res2 = q2.json()
            assert res2["matched"] is True
            battle = res2["battle"]
            battle_id = battle["id"]
            assert battle["status"] == "active"
            assert battle["hostA"]["id"] == host_a_id
            assert battle["hostB"]["id"] == host_b_id

            # 3. Fetch battle details and countdown
            b_res = client.get(f"/api/pk/battles/{battle_id}")
            assert b_res.status_code == 200
            assert b_res.json()["secondsLeft"] > 0

            # 4. End battle early
            end_res = client.post(f"/api/pk/battles/{battle_id}/end", headers=h_a)
            assert end_res.status_code == 200
            assert end_res.json()["status"] == "ended"
            assert end_res.json()["isDraw"] is True  # 0 to 0 score is draw


def test_virtual_gift_and_wallet_ledger_acid_transfer() -> None:
    users: list[str] = []
    gifts: list[str] = []
    packages: list[str] = []
    tiers: list[int] = [1, 2]

    settings = get_settings()

    with _cleanup_test_data(users, gifts, packages, tiers):
        with TestClient(app) as client:
            sender_id, _, s_h = _create_user(client, "sender")
            creator_id, _, c_h = _create_user(client, "creator")
            users.extend([sender_id, creator_id])

            # Make sender an Admin to create gifts and packages
            db = SessionLocal()
            try:
                su = db.get(User, sender_id)
                su.roles = ["Creator", "Admin"]
                # Also configure VIP Tier 1
                db.execute(text("DELETE FROM vip_level_configs WHERE level IN (1, 2)"))
                db.commit()
            finally:
                db.close()

            # 1. Admin creates VIP tier
            tier_res = client.post(
                "/api/vip/tiers",
                headers=s_h,
                json={
                    "level": 1,
                    "name": "Bronze VIP",
                    "tierBracket": "bronze",
                    "minCoinsSpent": 50,
                    "badgeColorHex": "#CD7F32",
                    "perks": ["Bronze badge", "Priority chat"],
                },
            )
            assert tier_res.status_code == 201, tier_res.text

            # 2. Admin creates a gift in catalog
            gift_res = client.post(
                "/api/gifts",
                headers=s_h,
                json={
                    "code": f"dragon_{_uid()}",
                    "name": "Celestial Dragon",
                    "category": "Luxury",
                    "icon": "🐉",
                    "coinCost": 50,
                    "diamondValue": 35,
                    "tagline": "Roars with fire across the screen!",
                },
            )
            assert gift_res.status_code == 201, gift_res.text
            gift_id = gift_res.json()["id"]
            gifts.append(gift_id)

            # 3. Credit sender wallet with 200 coins
            db = SessionLocal()
            try:
                w = db.get(UserWallet, sender_id)
                if not w:
                    w = UserWallet(user_id=sender_id, coins_balance=200)
                    db.add(w)
                else:
                    w.coins_balance = 200
                db.commit()
            finally:
                db.close()

            # Verify wallet balance
            w_res = client.get("/api/wallet/me", headers=s_h)
            assert w_res.status_code == 200
            assert w_res.json()["coinsBalance"] == 200

            # 4. Send gift (ACID transfer)
            idemp = f"idemp_{_uid()}"
            send_res = client.post(
                "/api/gifts/send",
                headers=s_h,
                json={
                    "giftId": gift_id,
                    "receiverId": creator_id,
                    "quantity": 1,
                    "idempotencyKey": idemp,
                },
            )
            assert send_res.status_code == 201, send_res.text
            data = send_res.json()
            assert data["totalCoinsSpent"] == 50
            assert data["diamondsCredited"] == 35
            assert data["senderCoinsBalance"] == 150
            assert data["receiverDiamondsBalance"] == 35
            assert data["senderVipLevel"] == 1  # Reached Bronze VIP (50 coins)

            # Idempotency check: sending with same key returns identical transaction without double deduction!
            dup_res = client.post(
                "/api/gifts/send",
                headers=s_h,
                json={
                    "giftId": gift_id,
                    "receiverId": creator_id,
                    "quantity": 1,
                    "idempotencyKey": idemp,
                },
            )
            assert dup_res.status_code == 201
            assert dup_res.json()["senderCoinsBalance"] == 150  # NOT 100!

            # Check creator wallet
            c_wallet = client.get("/api/wallet/me", headers=c_h)
            assert c_wallet.status_code == 200
            assert c_wallet.json()["diamondsBalance"] == 35

            # 5. Creator converts 10 diamonds to 10 coins
            conv_res = client.post(
                "/api/wallet/convert-diamonds",
                headers=c_h,
                json={"diamondsAmount": 10},
            )
            assert conv_res.status_code == 200
            assert conv_res.json()["diamondsBalance"] == 25
            assert conv_res.json()["coinsBalance"] == 10

            # 6. Check ledger
            ledger_res = client.get("/api/wallet/ledger", headers=s_h)
            assert ledger_res.status_code == 200
            assert ledger_res.json()["total"] >= 1

            # 7. Creator requests payout (35 - 10 = 25 diamonds)
            # Temporarily set min_withdrawal_diamonds to 10 for test
            orig_min = settings.min_withdrawal_diamonds
            settings.min_withdrawal_diamonds = 10
            try:
                payout_res = client.post(
                    "/api/wallet/payouts",
                    headers=c_h,
                    json={
                        "diamondsAmount": 15,
                        "payoutMethod": "bank_transfer",
                        "accountDetails": {
                            "bankName": "HDFC Bank",
                            "accountNumber": "1234567890",
                            "ifsc": "HDFC0001234",
                        },
                    },
                )
                assert payout_res.status_code == 201, payout_res.text
                payout_id = payout_res.json()["id"]

                # Payout review by admin (Reject -> diamonds refunded!)
                review_res = client.post(
                    f"/api/wallet/payouts/{payout_id}/review",
                    headers=s_h,
                    json={"decision": "rejected", "adminNote": "Invalid IFSC code"},
                )
                assert review_res.status_code == 200
                assert review_res.json()["status"] == "rejected"

                # Verify 15 diamonds refunded
                c_wallet_after = client.get("/api/wallet/me", headers=c_h)
                assert c_wallet_after.json()["diamondsBalance"] == 25
            finally:
                settings.min_withdrawal_diamonds = orig_min


def test_live_chat_and_direct_messaging() -> None:
    users: list[str] = []
    with _cleanup_test_data(users):
        with TestClient(app) as client:
            u1_id, _, u1_h = _create_user(client, "chat1")
            u2_id, _, u2_h = _create_user(client, "chat2")
            users.extend([u1_id, u2_id])

            # 1. Live room chat & barrage
            room_res = client.post(
                "/api/live/rooms",
                headers=u1_h,
                json={"title": "Chat Test Stream", "category": "Gaming", "provider": "rtmp"},
            )
            assert room_res.status_code == 201
            room_id = room_res.json()["id"]

            chat_res = client.post(
                f"/api/chat/live/{room_id}/messages",
                headers=u2_h,
                json={"messageType": "chat", "content": "Hello streamer!"},
            )
            assert chat_res.status_code == 201
            assert chat_res.json()["content"] == "Hello streamer!"

            barrage_res = client.post(
                f"/api/chat/live/{room_id}/messages",
                headers=u2_h,
                json={"messageType": "barrage", "content": "BULLET COMMENT", "colorHex": "#FF0000"},
            )
            assert barrage_res.status_code == 201
            assert barrage_res.json()["messageType"] == "barrage"

            list_chat = client.get(f"/api/chat/live/{room_id}/messages")
            assert list_chat.status_code == 200
            assert list_chat.json()["total"] == 2

            # 2. Direct Messages (DM)
            dm_send = client.post(
                f"/api/dm/with/{u2_id}/messages",
                headers=u1_h,
                json={"messageType": "text", "content": "Hey, let's collaborate on a live stream!"},
            )
            assert dm_send.status_code == 201, dm_send.text
            assert dm_send.json()["isRead"] is False

            # Recipient checks inbox
            inbox = client.get("/api/dm/conversations", headers=u2_h)
            assert inbox.status_code == 200
            assert inbox.json()["total"] == 1
            conv = inbox.json()["conversations"][0]
            assert conv["unreadCount"] == 1
            assert conv["peerId"] == u1_id

            # Recipient opens thread (marks read)
            thread = client.get(f"/api/dm/with/{u1_id}/messages", headers=u2_h)
            assert thread.status_code == 200
            assert thread.json()["total"] == 1
            assert thread.json()["messages"][0]["isRead"] is True

            # Re-check inbox -> unread count is 0
            inbox2 = client.get("/api/dm/conversations", headers=u2_h)
            assert inbox2.json()["conversations"][0]["unreadCount"] == 0


def test_leaderboards_and_vip_level_status() -> None:
    with TestClient(app) as client:
        gifters = client.get("/api/leaderboards/gifters?period=daily")
        assert gifters.status_code == 200
        assert gifters.json()["boardType"] == "top_gifters"

        streamers = client.get("/api/leaderboards/streamers?period=weekly")
        assert streamers.status_code == 200
        assert streamers.json()["boardType"] == "top_streamers"

        tiers = client.get("/api/vip/tiers")
        assert tiers.status_code == 200
        assert isinstance(tiers.json()["tiers"], list)


def test_notifications_fcm_lifecycle() -> None:
    users: list[str] = []
    with _cleanup_test_data(users):
        with TestClient(app) as client:
            u_id, _, u_h = _create_user(client, "notif")
            users.append(u_id)

            # 1. Register device token
            dev_res = client.post(
                "/api/notifications/devices",
                headers=u_h,
                json={
                    "fcmToken": "fcm_test_device_token_xyz_1234567890",
                    "platform": "android",
                    "deviceId": "pixel_7_pro",
                },
            )
            assert dev_res.status_code == 200
            assert dev_res.json()["isActive"] is True

            # 2. Check notifications inbox
            notif_list = client.get("/api/notifications", headers=u_h)
            assert notif_list.status_code == 200
            assert notif_list.json()["total"] >= 0

            # 3. Mark all read
            read_res = client.post("/api/notifications/read-all", headers=u_h)
            assert read_res.status_code == 200
            assert read_res.json()["unreadCount"] == 0

            # 4. Unregister device token
            unreg = client.request(
                "DELETE",
                "/api/notifications/devices",
                headers=u_h,
                json={"fcmToken": "fcm_test_device_token_xyz_1234567890"},
            )
            assert unreg.status_code == 200

