# Tivoo Backend (Python / FastAPI / MySQL / Real-Time WebSockets)

Production-grade, enterprise-structured Python backend supporting all core features of the **Tivoo Live & Short Video Social Platform**:

1. **User Authentication & Profiles**: JWT tokens, bcrypt, secure refresh rotation, phone OTP & real Gmail SMTP OTP (`Tivoo5477@gmail.com`), follower/following graph.
2. **Reels Video Hosting & Feed**: Upload handling (Local / AWS S3 / Cloudflare R2), FFmpeg background H.264 MP4 & adaptive HLS multi-bitrate transcoding, algorithmic "For You" & "Following" feeds, likes, nested comments.
3. **Live Streaming Gateway**: Room creation, stream key rotation, WebRTC & RTMP media server integration (LiveKit AccessToken JWT generation, Agora AccessToken2 HMAC-SHA256 tokens, RTMP ingest & HLS playback URLs).
4. **Real-Time PK Battle Engine**: Matchmaking queue (`SELECT ... FOR UPDATE`), direct challenge invitations, live gift score aggregation, round timers, and victory/defeat/draw calculation.
5. **Virtual Gift & Wallet Ledger**: User coin and diamond balances, in-app purchases (Stripe Checkout & Webhooks, Google Play RTDN / Android Publisher verification, Apple App Store Server Notifications v2 x5c JWS & receipt validation), ACID row-locked diamond/coin transfers, and creator payout escrow/approvals.
6. **Live Chat & Barrage WebSockets**: Real-time room chat, floating bullet barrage comments, and persistent direct messaging (DMs) over dedicated WebSockets (`/ws/live/{room_id}`, `/ws/pk/{battle_id}`, `/ws/dm`).
7. **Leaderboards & Gifter Levels**: Daily, Weekly, and Monthly top gifter and top streamer rankings (SQL period aggregations), dynamic VIP level calculation based on lifetime coins spent.
8. **Push Notifications**: Firebase Cloud Messaging (FCM HTTP v1 via Google Service Account OAuth2) to notify users when followed streamers go live, PK battles start, or DMs arrive.

Strictly connected to the local MySQL database `tivoo` (`127.0.0.1:3306`, user: `root`, password: `""`, accessible in phpMyAdmin at `http://localhost/phpmyadmin/index.php?route=/database/structure&db=tivoo`). **Zero mock data or test-mode bypasses** — all records are persistently stored and queried in MySQL InnoDB tables with utf8mb4 encoding.

---

## Project Layout

```text
backend/
|-- .env                              # Runtime environment variables (secrets live only here)
|-- .env.example                      # Safe template showing all supported options
|-- requirements.txt                  # Python dependencies
|-- run.py                            # Uvicorn production server entrypoint
|-- pytest.ini                        # Pytest test suite configuration
|-- migrations/
|   `-- schema.sql                    # Full MySQL DDL creating all 26 InnoDB tables
|-- app/
|   |-- main.py                       # FastAPI factory, CORS, static mounts, router registrations, WebSocket lifespan
|   |-- core/
|   |   |-- config.py                 # Pydantic Settings with full config validation
|   |   |-- security.py               # Password hashing, JWT token issue/decode, admin guards
|   |   `-- exceptions.py             # Global exception handlers and error envelopes
|   |-- db/
|   |   `-- session.py                # SQLAlchemy MySQL engine, sessionmaker, init_db(), health check
|   |-- models/
|   |   |-- user.py                   # User, OTPCode, RefreshToken, Follow
|   |   `-- video.py                  # Video, VideoLike, VideoComment, CommentLike
|   |-- realtime/
|   |   `-- connection_manager.py     # RealtimeConnectionManager (async/sync broadcast for rooms, battles & DMs)
|   |-- modules/
|   |   |-- live_gateway/             # Module 3: Live Streaming Gateway
|   |   |   |-- models.py             # LiveRoom, LiveParticipant
|   |   |   |-- schemas.py            # Room request/response DTOs, RTC token requests
|   |   |   |-- media_tokens.py       # LiveKit JWT builder, Agora AccessToken2 HMAC signer, RTMP URL generator
|   |   |   |-- service.py            # LiveGatewayService (create, start, end, join, leave, stream keys)
|   |   |   `-- router.py             # REST endpoints (/api/live/*)
|   |   |-- pk_battle/                # Module 4: Real-Time PK Battle Engine
|   |   |   |-- models.py             # PkQueueEntry, PkBattle, PkScoreEvent
|   |   |   |-- schemas.py            # Queue join/status, challenge, response DTOs
|   |   |   |-- service.py            # PkBattleService (atomic queue matching, timers, victory calculation)
|   |   |   `-- router.py             # REST endpoints (/api/pk/*)
|   |   |-- wallet_gifts/             # Module 5: Virtual Gift & Wallet Ledger
|   |   |   |-- models.py             # UserWallet, CoinPackage, GiftCatalog, GiftTransaction, WalletLedgerEntry, PaymentOrder, PayoutRequest
|   |   |   |-- schemas.py            # Wallet, gift catalog, checkout, webhook & payout DTOs
|   |   |   |-- webhooks.py           # Stripe HMAC signature verifier, Google Play RTDN decoder, Apple x5c JWS verifier
|   |   |   |-- service.py            # WalletGiftsService (ACID row-level lock gift transfers, IAP crediting, payouts)
|   |   |   `-- router.py             # REST endpoints (/api/wallet/*, /api/gifts/*, /api/webhooks/*)
|   |   |-- chat_realtime/            # Module 6: Live Chat & Barrage WebSockets
|   |   |   |-- models.py             # LiveChatMessage, DmConversation, DmMessage
|   |   |   |-- schemas.py            # Chat message, barrage, DM conversation DTOs
|   |   |   |-- service.py            # ChatRealtimeService (chat persistence, DMs, unread counts)
|   |   |   `-- router.py             # REST endpoints (/api/chat/*, /api/dm/*) & WebSockets (/ws/live/*, /ws/pk/*, /ws/dm)
|   |   |-- leaderboards_vip/         # Module 7: Leaderboards & Gifter Levels
|   |   |   |-- models.py             # VipLevelConfig
|   |   |   |-- schemas.py            # Ranking lists, user VIP tier status DTOs
|   |   |   |-- service.py            # LeaderboardVipService (Daily/Weekly/Monthly aggregations, VIP level tiers)
|   |   |   `-- router.py             # REST endpoints (/api/leaderboards/*, /api/vip/*)
|   |   `-- notifications_fcm/        # Module 8: Push Notifications
|   |       |-- models.py             # DevicePushToken, PushNotification
|   |       |-- schemas.py            # Token registration, notification list & read DTOs
|   |       |-- fcm_client.py         # Google Service Account RS256 OAuth2 -> FCM HTTP v1 dispatch
|   |       |-- service.py            # NotificationService (device tokens, dispatch on live/pk/gift/dm, inbox)
|   |       `-- router.py             # REST endpoints (/api/notifications/*)
|   |-- services/                     # Modules 1 & 2 services (auth, profiles, feed, storage, transcoder, email, sms)
|   `-- routers/                      # Modules 1 & 2 routers (auth, profiles, videos, web)
|-- templates/index.html              # Responsive creator web portal
|-- static/                           # CSS and JavaScript frontend assets
`-- tests/
    |-- test_api.py                   # Integration tests for Modules 1 & 2 (Auth & Video Feed)
    `-- test_modules_3_to_8.py        # Integration tests for Modules 3 through 8 against MySQL `tivoo`
```

---

## Database Architecture (`tivoo`)

All 26 tables are verified in MySQL `tivoo` under InnoDB with `utf8mb4_unicode_ci`:

1. `users`: Core profile, credentials, verification statuses, role (`user`/`admin`).
2. `otp_codes`: Phone & email OTPs hashed with HMAC-SHA256, expiration and attempt tracking.
3. `refresh_tokens`: SHA-256 hashed JWT refresh tokens with rotation support.
4. `follows`: Directed follower/following social graph.
5. `videos`: Short video metadata, HLS master playlist URL, MP4 fallback, aspect ratio, resolution.
6. `video_likes`: User video likes with foreign keys and unique constraints.
7. `video_comments`: Nested comments on videos.
8. `comment_likes`: Comment upvotes.
9. `live_rooms`: Live stream sessions, RTMP stream keys, LiveKit/Agora room tokens, viewer counters.
10. `live_participants`: Active viewer tracking with join/leave timestamps.
11. `pk_queue_entries`: Matchmaking queue for Host A vs Host B pairing.
12. `pk_battles`: Active & historical PK battles, round timers, host scores, winner tracking.
13. `pk_score_events`: Real-time score log per battle (linking gifts sent to battle score additions).
14. `user_wallets`: User coin balance, diamond balance, lifetime spend & earnings.
15. `coin_packages`: In-app purchase packages with prices, coin amounts, and bonus coins.
16. `gift_catalog`: Available gifts (Rose, Rocket, Dragon, etc.), animations, coin cost, diamond payout.
17. `gift_transactions`: ACID gift send audit trail with sender, receiver, live room, and PK battle references.
18. `wallet_ledger_entries`: Double-entry accounting ledger of every balance change.
19. `payment_orders`: Top-up orders initiated through Stripe, Google Play, or Apple In-App Purchase.
20. `payout_requests`: Creator withdrawal requests with payout method, status, and admin approval logs.
21. `live_chat_messages`: Live stream chat comments and barrage (floating bullet) messages.
22. `dm_conversations`: 1-on-1 direct message conversation threads.
23. `dm_messages`: Direct chat messages with read receipts.
24. `vip_level_configs`: Configurable VIP tiers (VIP 1 to VIP 10+) with required spend thresholds and badges.
25. `device_push_tokens`: User mobile device push tokens (FCM/APNS).
26. `push_notifications`: Persistent notification inbox for in-app alert feeds.

---

## Real-Time WebSockets

The backend provides three bidirectional, low-latency WebSocket channels with heartbeat support:

### 1. Live Stream WebSocket: `/ws/live/{room_id}`
- **Connect**: Connect as anonymous or authenticated spectator/host: `ws://localhost:8000/ws/live/<room_id>?token=<jwt_token>`
- **Client Actions**:
  - `{"action": "chat", "message": "Hello stream!", "isBarrage": false}`
  - `{"action": "like"}`
  - `{"action": "ping"}`
- **Server Events**:
  - `joined`: Viewer joined, contains updated `viewerCount`.
  - `chat_message`: Broadcasted message with user avatar, name, and barrage flags.
  - `room_liked`: Real-time like burst counter.
  - `gift_received`: Broadcast when a gift is sent (gift name, icon, animation, sender, receiver, combo).
  - `pk_started` / `pk_score_update` / `pk_ended`: Synchronized PK events.
  - `room_ended`: Sent when the host closes the live stream.

### 2. PK Battle WebSocket: `/ws/pk/{battle_id}`
- **Connect**: `ws://localhost:8000/ws/pk/<battle_id>?token=<jwt_token>`
- **Client Actions**: `{"action": "ping"}`
- **Server Events**:
  - `score_update`: Real-time score bar changes (host A points, host B points, remaining seconds).
  - `battle_settled`: Final outcome (`winnerId`, `status: settled`).

### 3. Direct Messaging WebSocket: `/ws/dm`
- **Connect**: `ws://localhost:8000/ws/dm?token=<jwt_token>`
- **Client Actions**:
  - `{"action": "send_dm", "recipientId": "<user_id>", "text": "Hey there!"}`
  - `{"action": "typing", "recipientId": "<user_id>"}`
  - `{"action": "mark_read", "conversationId": "<conv_id>"}`
- **Server Events**:
  - `dm_received`: Instant message payload delivered to recipient.
  - `user_typing`: Typing indicator broadcast.
  - `dm_read_receipt`: Read status update.

---

## API Endpoints Reference

### Authentication & Profiles (`/api/auth`, `/api/profiles`, `/api/follows`)
- `POST /api/auth/register` - Register user with email, username, password.
- `POST /api/auth/login` - Login with username/email and password.
- `POST /api/auth/refresh` - Rotate JWT refresh token.
- `POST /api/auth/send-otp` - Dispatch real email OTP (`Tivoo5477@gmail.com`) or SMS OTP.
- `POST /api/auth/verify-otp` - Verify OTP code and activate account.
- `GET /api/profiles/{username}` - Retrieve profile details.
- `PUT /api/profiles/me` - Update bio, avatar, display name.
- `POST /api/follows/{user_id}` - Follow/unfollow user.

### Reels & Feed (`/api/videos`, `/api/feed`, `/api/comments`)
- `POST /api/videos/upload` - Upload video file with automated FFmpeg HLS transcoding.
- `GET /api/videos/{id}` - Fetch video playback info (HLS master playlist + fallback MP4).
- `GET /api/feed/for-you` - Algorithmic feed scored on engagement and recency.
- `GET /api/feed/following` - Chronological feed of followed creators.
- `POST /api/videos/{id}/like` - Toggle video like.
- `POST /api/videos/{id}/comments` - Add comment.

### Live Streaming Gateway (`/api/live`)
- `POST /api/live/rooms` - Host creates a live room (returns RTMP stream key and HLS playback URL).
- `GET /api/live/rooms` - List ongoing live streams.
- `GET /api/live/rooms/{id}` - Get room details.
- `POST /api/live/rooms/{id}/token` - Get sub-second WebRTC viewer/publisher token (LiveKit JWT or Agora AccessToken2).
- `POST /api/live/rooms/{id}/start` - Mark live stream active.
- `POST /api/live/rooms/{id}/end` - End live stream and notify all spectators.
- `POST /api/live/rooms/{id}/join` - Viewer joins live room.
- `POST /api/live/rooms/{id}/leave` - Viewer leaves live room.
- `POST /api/live/rooms/{id}/like` - Increment live room likes.
- `POST /api/live/rtmp-webhook` - Ingest server webhook for RTMP `on_publish` and `on_done`.

### PK Battle Engine (`/api/pk`)
- `POST /api/pk/queue/join` - Join auto-matchmaking queue (atomic matching).
- `POST /api/pk/queue/leave` - Cancel matchmaking queue.
- `GET /api/pk/queue/status` - Poll matchmaking status.
- `POST /api/pk/challenge` - Send direct PK challenge from Host A to Host B.
- `POST /api/pk/accept` - Host B accepts challenge and starts PK countdown.
- `GET /api/pk/battles/{id}` - Get real-time battle score, round countdown, and victory status.
- `GET /api/pk/battles` - List active and historical PK battles.

### Virtual Gifts & Wallet Ledger (`/api/wallet`, `/api/gifts`, `/api/webhooks`)
- `GET /api/wallet/me` - Get coin balance, diamond balance, and VIP tier.
- `GET /api/wallet/ledger` - Paginated double-entry transaction history.
- `POST /api/wallet/convert-diamonds` - Convert earned diamonds into spending coins.
- `GET /api/gifts` - View all available gifts in catalog.
- `POST /api/gifts` - Admin creates new gift item.
- `POST /api/gifts/send` - **ACID-Compliant Gift Transfer**:
  - Row-level locks sender and receiver wallets in strict ascending order (preventing deadlocks).
  - Deducts coins from sender, credits diamonds to receiver.
  - Automatically credits PK battle score if the room is currently in PK mode.
  - Updates sender's VIP level and logs to wallet ledger.
  - Broadcasts animated gift event to all room spectators over WebSockets.
- `GET /api/wallet/packages` - List coin purchase packages.
- `POST /api/wallet/topup/checkout` - Create Stripe Checkout session for coin top-up.
- `POST /api/wallet/verify-iap` - Server-side verification for Google Play and Apple App Store in-app purchases.
- `POST /api/wallet/payout-request` - Creator submits diamond cash-out request.
- `GET /api/wallet/payout-requests` - Admin views withdrawal requests.
- `POST /api/wallet/payout-requests/{id}/review` - Admin approves or rejects payout (refunds escrow on rejection).
- `POST /api/webhooks/stripe` - Stripe webhook handler verifying `Stripe-Signature`.
- `POST /api/webhooks/google-play` - Google Play Real-Time Developer Notifications (RTDN).
- `POST /api/webhooks/apple` - Apple App Store Server Notifications v2 (ES256 JWS decode).

### Live Chat & DMs (`/api/chat`, `/api/dm`)
- `POST /api/chat/live/{room_id}/messages` - Send room chat or barrage message via REST.
- `GET /api/chat/live/{room_id}/messages` - Fetch recent live chat history.
- `POST /api/dm/send` - Send 1-on-1 DM.
- `GET /api/dm/conversations` - List conversations with latest messages and unread counts.
- `GET /api/dm/conversations/{user_id}/messages` - Fetch chat history between two users.
- `POST /api/dm/conversations/{conv_id}/read` - Mark DM conversation as read.

### Leaderboards & VIP Levels (`/api/leaderboards`, `/api/vip`)
- `GET /api/leaderboards/gifters?period=daily|weekly|monthly` - Top spenders ranking.
- `GET /api/leaderboards/streamers?period=daily|weekly|monthly` - Top earning creators ranking.
- `GET /api/vip/tiers` - List all VIP tier configs and thresholds.
- `POST /api/vip/tiers` - Admin creates/updates VIP tier.
- `GET /api/vip/my-status` - Current user's VIP level, badge, and progress toward next tier.

### Push Notifications (`/api/notifications`)
- `POST /api/notifications/devices` - Register iOS (APNS) or Android (FCM) device push token.
- `DELETE /api/notifications/devices` - Unregister push token on logout.
- `GET /api/notifications` - Paginated user notification inbox.
- `POST /api/notifications/read` - Mark notifications as read.
- `GET /api/notifications/unread-count` - Get badge count for unread alerts.

---

## Running the Server

```powershell
cd D:\APK\Tivoo-main\backend
.\.venv\Scripts\python.exe run.py
```

- **Interactive Swagger OpenAPI Docs**: `http://localhost:8000/docs`
- **Alternative ReDoc**: `http://localhost:8000/redoc`
- **Health Check & Diagnostics**: `http://localhost:8000/api/health`
- **Creator Web Portal**: `http://localhost:8000/`

---

## Automated Test Verification

All 9 automated integration tests run against the live MySQL `tivoo` database and clean up their test fixtures:

```powershell
cd D:\APK\Tivoo-main\backend
.\.venv\Scripts\python.exe -m pytest -c pytest.ini tests -v
```

Test coverage includes:
- `test_health_and_mysql_tivoo_schema`: MySQL connection & 26 tables integrity.
- `test_auth_otp_and_profile_lifecycle`: Registration, bcrypt, JWT, refresh rotation, profile updates.
- `test_follow_video_upload_hls_transcoding_and_feed`: Video upload, FFmpeg HLS transcoding, algorithmic feed.
- `test_live_streaming_gateway_lifecycle`: Room creation, RTMP stream key generation, LiveKit/Agora tokens, start/end lifecycle.
- `test_pk_battle_engine_matchmaking_and_settlement`: Queue matchmaking, challenge acceptance, gift score additions, round expiration victory calculation.
- `test_virtual_gift_and_wallet_ledger_acid_transfer`: In-app coin purchase, ACID deadlock-free diamond transfer, double-entry ledger entries.
- `test_live_chat_and_direct_messaging`: Room barrage comments, 1-on-1 DM inbox, unread counts, read receipts.
- `test_leaderboards_and_vip_level_status`: Daily/Weekly/Monthly gift spend rankings and VIP tier calculation.
- `test_notifications_fcm_lifecycle`: Device push token registration, FCM dispatch, notification inbox.
