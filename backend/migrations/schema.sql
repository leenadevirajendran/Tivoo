-- ============================================================================
-- Tivoo MySQL Database Schema (phpMyAdmin / MySQL 8+ / MariaDB)
-- Database: tivoo
-- Note: The FastAPI app also executes Base.metadata.create_all() on startup,
--       and this file serves as a canonical reference / manual phpMyAdmin SQL script.
-- ============================================================================

CREATE DATABASE IF NOT EXISTS `tivoo`
  CHARACTER SET utf8mb4
  COLLATE utf8mb4_unicode_ci;

USE `tivoo`;

CREATE TABLE IF NOT EXISTS `users` (
  `id` CHAR(36) NOT NULL,
  `name` VARCHAR(100) NOT NULL,
  `username` VARCHAR(50) NOT NULL,
  `email` VARCHAR(255) NULL,
  `phone_number` VARCHAR(30) NULL,
  `password_hash` VARCHAR(255) NULL,
  `bio` VARCHAR(300) NOT NULL DEFAULT '',
  `about_me` TEXT NOT NULL,
  `avatar_url` VARCHAR(512) NOT NULL DEFAULT '',
  `cover_background_url` VARCHAR(512) NOT NULL DEFAULT '',
  `roles` JSON NOT NULL,
  `is_verified` TINYINT(1) NOT NULL DEFAULT 0,
  `is_email_verified` TINYINT(1) NOT NULL DEFAULT 0,
  `is_phone_verified` TINYINT(1) NOT NULL DEFAULT 0,
  `is_private` TINYINT(1) NOT NULL DEFAULT 0,
  `is_online` TINYINT(1) NOT NULL DEFAULT 1,
  `is_active` TINYINT(1) NOT NULL DEFAULT 1,
  `following_count` INT NOT NULL DEFAULT 0,
  `followers_count` INT NOT NULL DEFAULT 0,
  `likes_count` INT NOT NULL DEFAULT 0,
  `live_streams_count` INT NOT NULL DEFAULT 0,
  `total_views` BIGINT NOT NULL DEFAULT 0,
  `last_login_at` DATETIME NULL,
  `created_at` DATETIME NOT NULL,
  `updated_at` DATETIME NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uq_users_username` (`username`),
  UNIQUE KEY `uq_users_email` (`email`),
  UNIQUE KEY `uq_users_phone` (`phone_number`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS `otp_codes` (
  `id` CHAR(36) NOT NULL,
  `user_id` CHAR(36) NULL,
  `channel` VARCHAR(16) NOT NULL,
  `target` VARCHAR(255) NOT NULL,
  `purpose` VARCHAR(32) NOT NULL,
  `code_hash` VARCHAR(128) NOT NULL,
  `attempts` INT NOT NULL DEFAULT 0,
  `max_attempts` INT NOT NULL DEFAULT 5,
  `is_used` TINYINT(1) NOT NULL DEFAULT 0,
  `expires_at` DATETIME NOT NULL,
  `created_at` DATETIME NOT NULL,
  PRIMARY KEY (`id`),
  KEY `ix_otp_target_channel` (`target`, `channel`, `purpose`),
  KEY `ix_otp_expires_at` (`expires_at`),
  CONSTRAINT `fk_otp_user` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS `refresh_tokens` (
  `id` CHAR(36) NOT NULL,
  `user_id` CHAR(36) NOT NULL,
  `token_hash` VARCHAR(128) NOT NULL,
  `device_info` VARCHAR(255) NOT NULL DEFAULT '',
  `is_revoked` TINYINT(1) NOT NULL DEFAULT 0,
  `expires_at` DATETIME NOT NULL,
  `created_at` DATETIME NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uq_refresh_token_hash` (`token_hash`),
  KEY `ix_refresh_user` (`user_id`),
  CONSTRAINT `fk_refresh_user` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS `follows` (
  `id` CHAR(36) NOT NULL,
  `follower_id` CHAR(36) NOT NULL,
  `following_id` CHAR(36) NOT NULL,
  `status` VARCHAR(20) NOT NULL DEFAULT 'following',
  `is_close_friend` TINYINT(1) NOT NULL DEFAULT 0,
  `is_muted` TINYINT(1) NOT NULL DEFAULT 0,
  `requested_at` DATETIME NULL,
  `followed_at` DATETIME NULL,
  `created_at` DATETIME NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uq_follow_pair` (`follower_id`, `following_id`),
  KEY `ix_follows_following_status` (`following_id`, `status`),
  CONSTRAINT `fk_follow_follower` FOREIGN KEY (`follower_id`) REFERENCES `users` (`id`) ON DELETE CASCADE,
  CONSTRAINT `fk_follow_following` FOREIGN KEY (`following_id`) REFERENCES `users` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS `videos` (
  `id` CHAR(36) NOT NULL,
  `author_id` CHAR(36) NOT NULL,
  `caption` TEXT NOT NULL,
  `category` VARCHAR(64) NOT NULL DEFAULT 'Entertainment',
  `hashtags` JSON NOT NULL,
  `audience` VARCHAR(32) NOT NULL DEFAULT 'Public',
  `allow_comments` TINYINT(1) NOT NULL DEFAULT 1,
  `allow_downloads` TINYINT(1) NOT NULL DEFAULT 1,
  `allow_share` TINYINT(1) NOT NULL DEFAULT 1,
  `location` VARCHAR(150) NULL,
  `music_title` VARCHAR(150) NULL,
  `snap_lens_name` VARCHAR(100) NULL,
  `storage_backend` VARCHAR(20) NOT NULL DEFAULT 'local',
  `raw_storage_key` VARCHAR(512) NOT NULL DEFAULT '',
  `video_storage_key` VARCHAR(512) NOT NULL DEFAULT '',
  `hls_storage_prefix` VARCHAR(512) NOT NULL DEFAULT '',
  `thumbnail_storage_key` VARCHAR(512) NOT NULL DEFAULT '',
  `video_url` VARCHAR(700) NOT NULL,
  `hls_url` VARCHAR(700) NULL,
  `thumbnail_url` VARCHAR(700) NULL,
  `duration_seconds` FLOAT NOT NULL DEFAULT 0,
  `width` INT NOT NULL DEFAULT 0,
  `height` INT NOT NULL DEFAULT 0,
  `file_size_bytes` BIGINT NOT NULL DEFAULT 0,
  `transcoding_status` VARCHAR(24) NOT NULL DEFAULT 'pending',
  `transcoding_error` TEXT NULL,
  `likes_count` INT NOT NULL DEFAULT 0,
  `comments_count` INT NOT NULL DEFAULT 0,
  `views_count` INT NOT NULL DEFAULT 0,
  `shares_count` INT NOT NULL DEFAULT 0,
  `created_at` DATETIME NOT NULL,
  `updated_at` DATETIME NOT NULL,
  PRIMARY KEY (`id`),
  KEY `ix_videos_author` (`author_id`),
  KEY `ix_videos_feed_sort` (`transcoding_status`, `audience`, `created_at`),
  CONSTRAINT `fk_video_author` FOREIGN KEY (`author_id`) REFERENCES `users` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS `video_likes` (
  `id` CHAR(36) NOT NULL,
  `video_id` CHAR(36) NOT NULL,
  `user_id` CHAR(36) NOT NULL,
  `created_at` DATETIME NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uq_video_like` (`video_id`, `user_id`),
  CONSTRAINT `fk_vlike_video` FOREIGN KEY (`video_id`) REFERENCES `videos` (`id`) ON DELETE CASCADE,
  CONSTRAINT `fk_vlike_user` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS `video_comments` (
  `id` CHAR(36) NOT NULL,
  `video_id` CHAR(36) NOT NULL,
  `user_id` CHAR(36) NOT NULL,
  `parent_comment_id` CHAR(36) NULL,
  `text` TEXT NOT NULL,
  `likes_count` INT NOT NULL DEFAULT 0,
  `created_at` DATETIME NOT NULL,
  PRIMARY KEY (`id`),
  KEY `ix_video_comments_video_created` (`video_id`, `created_at`),
  CONSTRAINT `fk_vcomment_video` FOREIGN KEY (`video_id`) REFERENCES `videos` (`id`) ON DELETE CASCADE,
  CONSTRAINT `fk_vcomment_user` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE,
  CONSTRAINT `fk_vcomment_parent` FOREIGN KEY (`parent_comment_id`) REFERENCES `video_comments` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS `comment_likes` (
  `id` CHAR(36) NOT NULL,
  `comment_id` CHAR(36) NOT NULL,
  `user_id` CHAR(36) NOT NULL,
  `created_at` DATETIME NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uq_comment_like` (`comment_id`, `user_id`),
  CONSTRAINT `fk_clike_comment` FOREIGN KEY (`comment_id`) REFERENCES `video_comments` (`id`) ON DELETE CASCADE,
  CONSTRAINT `fk_clike_user` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;


-- ============================================================================
-- Modules 3-8: Live Gateway, PK Battle, Wallet/Gifts, Chat/DMs, VIP, FCM
-- ============================================================================

CREATE TABLE IF NOT EXISTS `device_push_tokens` (
  `id` CHAR(36) NOT NULL,
  `user_id` CHAR(36) NOT NULL,
  `platform` VARCHAR(16) NOT NULL,
  `fcm_token` VARCHAR(512) NOT NULL,
  `device_id` VARCHAR(128) NOT NULL DEFAULT '',
  `is_active` TINYINT(1) NOT NULL DEFAULT 1,
  `last_seen_at` DATETIME NOT NULL,
  `created_at` DATETIME NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uq_fcm_token` (`fcm_token`),
  KEY `ix_device_tokens_user_active` (`user_id`, `is_active`),
  CONSTRAINT `fk_dpt_user` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS `push_notifications` (
  `id` CHAR(36) NOT NULL,
  `user_id` CHAR(36) NOT NULL,
  `actor_id` CHAR(36) NULL,
  `notification_type` VARCHAR(40) NOT NULL,
  `title` VARCHAR(160) NOT NULL,
  `body` VARCHAR(500) NOT NULL,
  `data_payload` JSON NOT NULL,
  `fcm_status` VARCHAR(32) NOT NULL DEFAULT 'pending',
  `fcm_error` TEXT NULL,
  `is_read` TINYINT(1) NOT NULL DEFAULT 0,
  `read_at` DATETIME NULL,
  `created_at` DATETIME NOT NULL,
  PRIMARY KEY (`id`),
  KEY `ix_push_notifications_user_read_created` (`user_id`, `is_read`, `created_at`),
  CONSTRAINT `fk_pn_user` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE,
  CONSTRAINT `fk_pn_actor` FOREIGN KEY (`actor_id`) REFERENCES `users` (`id`) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS `live_rooms` (
  `id` CHAR(36) NOT NULL,
  `host_id` CHAR(36) NOT NULL,
  `room_key` VARCHAR(64) NOT NULL,
  `title` VARCHAR(180) NOT NULL,
  `category` VARCHAR(60) NOT NULL DEFAULT 'Entertainment',
  `cover_url` VARCHAR(512) NOT NULL DEFAULT '',
  `provider` VARCHAR(20) NOT NULL DEFAULT 'livekit',
  `status` VARCHAR(20) NOT NULL DEFAULT 'scheduled',
  `stream_key_hash` VARCHAR(128) NOT NULL,
  `stream_key_masked` VARCHAR(32) NOT NULL,
  `rtmp_ingest_url` VARCHAR(512) NOT NULL,
  `playback_hls_url` VARCHAR(512) NOT NULL,
  `allow_chat` TINYINT(1) NOT NULL DEFAULT 1,
  `allow_gifts` TINYINT(1) NOT NULL DEFAULT 1,
  `allow_pk` TINYINT(1) NOT NULL DEFAULT 1,
  `viewer_count` INT NOT NULL DEFAULT 0,
  `peak_viewers` INT NOT NULL DEFAULT 0,
  `likes_count` INT NOT NULL DEFAULT 0,
  `total_gifts_diamonds` INT NOT NULL DEFAULT 0,
  `started_at` DATETIME NULL,
  `ended_at` DATETIME NULL,
  `created_at` DATETIME NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uq_live_room_key` (`room_key`),
  KEY `ix_live_rooms_status_created` (`status`, `created_at`),
  KEY `ix_live_rooms_host_status` (`host_id`, `status`),
  CONSTRAINT `fk_live_room_host` FOREIGN KEY (`host_id`) REFERENCES `users` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS `live_participants` (
  `id` CHAR(36) NOT NULL,
  `room_id` CHAR(36) NOT NULL,
  `user_id` CHAR(36) NOT NULL,
  `role` VARCHAR(20) NOT NULL DEFAULT 'viewer',
  `is_active` TINYINT(1) NOT NULL DEFAULT 1,
  `joined_at` DATETIME NOT NULL,
  `last_heartbeat_at` DATETIME NOT NULL,
  `left_at` DATETIME NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uq_live_participant` (`room_id`, `user_id`),
  KEY `ix_live_participants_room_active` (`room_id`, `is_active`),
  CONSTRAINT `fk_lp_room` FOREIGN KEY (`room_id`) REFERENCES `live_rooms` (`id`) ON DELETE CASCADE,
  CONSTRAINT `fk_lp_user` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS `pk_queue_entries` (
  `id` CHAR(36) NOT NULL,
  `host_id` CHAR(36) NOT NULL,
  `room_id` CHAR(36) NULL,
  `preferred_duration_seconds` INT NOT NULL DEFAULT 300,
  `status` VARCHAR(20) NOT NULL DEFAULT 'waiting',
  `matched_battle_id` CHAR(36) NULL,
  `updated_at` DATETIME NOT NULL,
  `created_at` DATETIME NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uq_pk_queue_host` (`host_id`),
  KEY `ix_pk_queue_status_created` (`status`, `created_at`),
  CONSTRAINT `fk_pkq_host` FOREIGN KEY (`host_id`) REFERENCES `users` (`id`) ON DELETE CASCADE,
  CONSTRAINT `fk_pkq_room` FOREIGN KEY (`room_id`) REFERENCES `live_rooms` (`id`) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS `pk_battles` (
  `id` CHAR(36) NOT NULL,
  `host_a_id` CHAR(36) NOT NULL,
  `host_b_id` CHAR(36) NOT NULL,
  `room_a_id` CHAR(36) NULL,
  `room_b_id` CHAR(36) NULL,
  `status` VARCHAR(20) NOT NULL DEFAULT 'pending',
  `duration_seconds` INT NOT NULL DEFAULT 300,
  `host_a_score` BIGINT NOT NULL DEFAULT 0,
  `host_b_score` BIGINT NOT NULL DEFAULT 0,
  `winner_id` CHAR(36) NULL,
  `is_draw` TINYINT(1) NOT NULL DEFAULT 0,
  `started_at` DATETIME NULL,
  `ends_at` DATETIME NULL,
  `ended_at` DATETIME NULL,
  `created_at` DATETIME NOT NULL,
  PRIMARY KEY (`id`),
  KEY `ix_pk_battles_status_created` (`status`, `created_at`),
  KEY `ix_pk_battles_hosts` (`host_a_id`, `host_b_id`),
  CONSTRAINT `fk_pk_host_a` FOREIGN KEY (`host_a_id`) REFERENCES `users` (`id`) ON DELETE CASCADE,
  CONSTRAINT `fk_pk_host_b` FOREIGN KEY (`host_b_id`) REFERENCES `users` (`id`) ON DELETE CASCADE,
  CONSTRAINT `fk_pk_room_a` FOREIGN KEY (`room_a_id`) REFERENCES `live_rooms` (`id`) ON DELETE SET NULL,
  CONSTRAINT `fk_pk_room_b` FOREIGN KEY (`room_b_id`) REFERENCES `live_rooms` (`id`) ON DELETE SET NULL,
  CONSTRAINT `fk_pk_winner` FOREIGN KEY (`winner_id`) REFERENCES `users` (`id`) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS `pk_score_events` (
  `id` CHAR(36) NOT NULL,
  `battle_id` CHAR(36) NOT NULL,
  `target_host_id` CHAR(36) NOT NULL,
  `sender_id` CHAR(36) NOT NULL,
  `gift_transaction_id` CHAR(36) NULL,
  `points_added` BIGINT NOT NULL,
  `host_a_score_after` BIGINT NOT NULL,
  `host_b_score_after` BIGINT NOT NULL,
  `created_at` DATETIME NOT NULL,
  PRIMARY KEY (`id`),
  KEY `ix_pk_score_events_battle_created` (`battle_id`, `created_at`),
  CONSTRAINT `fk_pse_battle` FOREIGN KEY (`battle_id`) REFERENCES `pk_battles` (`id`) ON DELETE CASCADE,
  CONSTRAINT `fk_pse_target` FOREIGN KEY (`target_host_id`) REFERENCES `users` (`id`) ON DELETE CASCADE,
  CONSTRAINT `fk_pse_sender` FOREIGN KEY (`sender_id`) REFERENCES `users` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS `vip_level_configs` (
  `level` INT NOT NULL,
  `name` VARCHAR(64) NOT NULL,
  `tier_bracket` VARCHAR(40) NOT NULL DEFAULT 'bronze',
  `min_coins_spent` BIGINT NOT NULL,
  `badge_color_hex` VARCHAR(16) NOT NULL DEFAULT '#FF3B6B',
  `frame_url` VARCHAR(512) NOT NULL DEFAULT '',
  `perks` JSON NOT NULL,
  `is_active` TINYINT(1) NOT NULL DEFAULT 1,
  `created_at` DATETIME NOT NULL,
  PRIMARY KEY (`level`),
  UNIQUE KEY `uq_vip_min_coins` (`min_coins_spent`),
  KEY `ix_vip_level_min_coins` (`min_coins_spent`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS `user_wallets` (
  `user_id` CHAR(36) NOT NULL,
  `coins_balance` BIGINT NOT NULL DEFAULT 0,
  `diamonds_balance` BIGINT NOT NULL DEFAULT 0,
  `total_coins_spent` BIGINT NOT NULL DEFAULT 0,
  `total_diamonds_earned` BIGINT NOT NULL DEFAULT 0,
  `vip_level` INT NOT NULL DEFAULT 0,
  `updated_at` DATETIME NOT NULL,
  PRIMARY KEY (`user_id`),
  CONSTRAINT `ck_wallet_coins_nonnegative` CHECK (`coins_balance` >= 0),
  CONSTRAINT `ck_wallet_diamonds_nonnegative` CHECK (`diamonds_balance` >= 0),
  CONSTRAINT `fk_wallet_user` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS `coin_packages` (
  `id` CHAR(36) NOT NULL,
  `code` VARCHAR(48) NOT NULL,
  `title` VARCHAR(80) NOT NULL,
  `coins_amount` INT NOT NULL,
  `bonus_coins` INT NOT NULL DEFAULT 0,
  `price_cents` INT NOT NULL,
  `currency` VARCHAR(8) NOT NULL DEFAULT 'INR',
  `store_product_id` VARCHAR(120) NULL,
  `is_popular` TINYINT(1) NOT NULL DEFAULT 0,
  `is_active` TINYINT(1) NOT NULL DEFAULT 1,
  `created_at` DATETIME NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uq_coin_pkg_code` (`code`),
  UNIQUE KEY `uq_coin_pkg_sku` (`store_product_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS `gift_catalog` (
  `id` CHAR(36) NOT NULL,
  `code` VARCHAR(48) NOT NULL,
  `name` VARCHAR(80) NOT NULL,
  `category` VARCHAR(40) NOT NULL DEFAULT 'Popular',
  `icon` VARCHAR(16) NOT NULL DEFAULT '',
  `animation_url` VARCHAR(512) NOT NULL DEFAULT '',
  `coin_cost` INT NOT NULL,
  `diamond_value` INT NOT NULL,
  `tagline` VARCHAR(180) NOT NULL DEFAULT '',
  `sort_order` INT NOT NULL DEFAULT 0,
  `is_active` TINYINT(1) NOT NULL DEFAULT 1,
  `created_at` DATETIME NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uq_gift_code` (`code`),
  KEY `ix_gift_catalog_active_sort` (`is_active`, `sort_order`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS `gift_transactions` (
  `id` CHAR(36) NOT NULL,
  `idempotency_key` VARCHAR(80) NULL,
  `sender_id` CHAR(36) NOT NULL,
  `receiver_id` CHAR(36) NOT NULL,
  `gift_id` CHAR(36) NOT NULL,
  `live_room_id` CHAR(36) NULL,
  `pk_battle_id` CHAR(36) NULL,
  `quantity` INT NOT NULL DEFAULT 1,
  `total_coins` BIGINT NOT NULL,
  `diamonds_credited` BIGINT NOT NULL,
  `combo_streak` INT NOT NULL DEFAULT 1,
  `created_at` DATETIME NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uq_gift_tx_idemp` (`idempotency_key`),
  KEY `ix_gift_tx_created_sender` (`created_at`, `sender_id`),
  KEY `ix_gift_tx_created_receiver` (`created_at`, `receiver_id`),
  CONSTRAINT `fk_gtx_sender` FOREIGN KEY (`sender_id`) REFERENCES `users` (`id`) ON DELETE CASCADE,
  CONSTRAINT `fk_gtx_receiver` FOREIGN KEY (`receiver_id`) REFERENCES `users` (`id`) ON DELETE CASCADE,
  CONSTRAINT `fk_gtx_gift` FOREIGN KEY (`gift_id`) REFERENCES `gift_catalog` (`id`) ON DELETE RESTRICT,
  CONSTRAINT `fk_gtx_room` FOREIGN KEY (`live_room_id`) REFERENCES `live_rooms` (`id`) ON DELETE SET NULL,
  CONSTRAINT `fk_gtx_battle` FOREIGN KEY (`pk_battle_id`) REFERENCES `pk_battles` (`id`) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS `wallet_ledger_entries` (
  `id` CHAR(36) NOT NULL,
  `user_id` CHAR(36) NOT NULL,
  `entry_type` VARCHAR(36) NOT NULL,
  `currency` VARCHAR(16) NOT NULL,
  `delta_amount` BIGINT NOT NULL,
  `balance_after` BIGINT NOT NULL,
  `reference_type` VARCHAR(36) NOT NULL DEFAULT '',
  `reference_id` VARCHAR(64) NOT NULL DEFAULT '',
  `description` VARCHAR(255) NOT NULL DEFAULT '',
  `created_at` DATETIME NOT NULL,
  PRIMARY KEY (`id`),
  KEY `ix_wallet_ledger_user_created` (`user_id`, `created_at`),
  CONSTRAINT `fk_wle_user` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS `payment_orders` (
  `id` CHAR(36) NOT NULL,
  `user_id` CHAR(36) NOT NULL,
  `package_id` CHAR(36) NOT NULL,
  `provider` VARCHAR(24) NOT NULL,
  `provider_order_id` VARCHAR(160) NULL,
  `provider_event_id` VARCHAR(160) NULL,
  `amount_cents` INT NOT NULL,
  `currency` VARCHAR(8) NOT NULL DEFAULT 'INR',
  `coins_credited` INT NOT NULL,
  `status` VARCHAR(24) NOT NULL DEFAULT 'pending',
  `raw_payload` JSON NOT NULL,
  `completed_at` DATETIME NULL,
  `created_at` DATETIME NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uq_payment_event_id` (`provider_event_id`),
  KEY `ix_payment_orders_user_status` (`user_id`, `status`),
  CONSTRAINT `fk_po_user` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE,
  CONSTRAINT `fk_po_package` FOREIGN KEY (`package_id`) REFERENCES `coin_packages` (`id`) ON DELETE RESTRICT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS `payout_requests` (
  `id` CHAR(36) NOT NULL,
  `user_id` CHAR(36) NOT NULL,
  `diamonds_amount` BIGINT NOT NULL,
  `payout_amount` DECIMAL(12, 2) NOT NULL,
  `currency` VARCHAR(8) NOT NULL DEFAULT 'INR',
  `payout_method` VARCHAR(32) NOT NULL,
  `account_details` JSON NOT NULL,
  `status` VARCHAR(24) NOT NULL DEFAULT 'pending',
  `admin_note` VARCHAR(255) NOT NULL DEFAULT '',
  `reviewed_by_id` CHAR(36) NULL,
  `reviewed_at` DATETIME NULL,
  `created_at` DATETIME NOT NULL,
  PRIMARY KEY (`id`),
  KEY `ix_payout_requests_user_status` (`user_id`, `status`),
  CONSTRAINT `fk_pr_user` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE,
  CONSTRAINT `fk_pr_reviewer` FOREIGN KEY (`reviewed_by_id`) REFERENCES `users` (`id`) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS `live_chat_messages` (
  `id` CHAR(36) NOT NULL,
  `room_id` CHAR(36) NOT NULL,
  `sender_id` CHAR(36) NOT NULL,
  `message_type` VARCHAR(20) NOT NULL DEFAULT 'chat',
  `content` VARCHAR(500) NOT NULL,
  `color_hex` VARCHAR(16) NOT NULL DEFAULT '#FFFFFF',
  `is_pinned` TINYINT(1) NOT NULL DEFAULT 0,
  `created_at` DATETIME NOT NULL,
  PRIMARY KEY (`id`),
  KEY `ix_live_chat_room_created` (`room_id`, `created_at`),
  CONSTRAINT `fk_lcm_room` FOREIGN KEY (`room_id`) REFERENCES `live_rooms` (`id`) ON DELETE CASCADE,
  CONSTRAINT `fk_lcm_sender` FOREIGN KEY (`sender_id`) REFERENCES `users` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS `dm_conversations` (
  `id` CHAR(36) NOT NULL,
  `participant_a_id` CHAR(36) NOT NULL,
  `participant_b_id` CHAR(36) NOT NULL,
  `last_message_text` VARCHAR(300) NOT NULL DEFAULT '',
  `last_message_at` DATETIME NOT NULL,
  `created_at` DATETIME NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uq_dm_participant_pair` (`participant_a_id`, `participant_b_id`),
  KEY `ix_dm_conv_last_msg` (`last_message_at`),
  CONSTRAINT `fk_dmc_a` FOREIGN KEY (`participant_a_id`) REFERENCES `users` (`id`) ON DELETE CASCADE,
  CONSTRAINT `fk_dmc_b` FOREIGN KEY (`participant_b_id`) REFERENCES `users` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS `dm_messages` (
  `id` CHAR(36) NOT NULL,
  `conversation_id` CHAR(36) NOT NULL,
  `sender_id` CHAR(36) NOT NULL,
  `recipient_id` CHAR(36) NOT NULL,
  `message_type` VARCHAR(16) NOT NULL DEFAULT 'text',
  `content` TEXT NOT NULL,
  `media_url` VARCHAR(512) NULL,
  `is_read` TINYINT(1) NOT NULL DEFAULT 0,
  `read_at` DATETIME NULL,
  `created_at` DATETIME NOT NULL,
  PRIMARY KEY (`id`),
  KEY `ix_dm_messages_conv_created` (`conversation_id`, `created_at`),
  KEY `ix_dm_messages_recipient_read` (`recipient_id`, `is_read`),
  CONSTRAINT `fk_dmm_conv` FOREIGN KEY (`conversation_id`) REFERENCES `dm_conversations` (`id`) ON DELETE CASCADE,
  CONSTRAINT `fk_dmm_sender` FOREIGN KEY (`sender_id`) REFERENCES `users` (`id`) ON DELETE CASCADE,
  CONSTRAINT `fk_dmm_recipient` FOREIGN KEY (`recipient_id`) REFERENCES `users` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
