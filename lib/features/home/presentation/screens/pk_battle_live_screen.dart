import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../core/constants/app_assets.dart';
import '../../../../core/services/reel_video_manager.dart';
import '../../../../core/widgets/custom_avatar.dart';
import '../../../../core/widgets/live_video_player.dart';
import '../../../live_stream/domain/models/gift_item.dart';
import '../../../live_stream/domain/models/live_comment.dart';
import '../../../live_stream/presentation/widgets/active_gift_animation_overlay.dart';
import '../../../live_stream/presentation/widgets/floating_hearts_overlay.dart';
import '../../../live_stream/presentation/widgets/gift_bottom_sheet.dart';
import '../widgets/live_tools_bottom_sheet.dart';

/// Clean, high-performance PK Battle Live Screen matching the dark luxury cyberpunk UI.
class PkBattleLiveScreen extends StatefulWidget {
  final VoidCallback? onBack;

  const PkBattleLiveScreen({super.key, this.onBack});

  @override
  State<PkBattleLiveScreen> createState() => _PkBattleLiveScreenState();
}

class _PkBattleLiveScreenState extends State<PkBattleLiveScreen>
    with TickerProviderStateMixin {
  final GlobalKey<ActiveGiftAnimationOverlayState> _activeGiftKey = GlobalKey();
  final GlobalKey<FloatingHeartsOverlayState> _heartsKey = GlobalKey();

  // Streamer data
  final String _leftStreamerName = 'Neha';
  final String _leftStreamerAsset = AppAssets.status4;
  final String _leftVideoAsset = AppAssets.video2;
  final String _leftLikes = '125.4K';

  final String _rightStreamerName = 'Arun';
  final String _rightStreamerAsset = AppAssets.status5;
  final String _rightVideoAsset = AppAssets.video1;
  final String _rightLikes = '98.2K';

  // Live Scores
  int _leftScore = 7556900;
  int _rightScore = 483400;

  // PK Timer (01:46)
  int _secondsRemaining = 106;
  Timer? _countdownTimer;
  Timer? _commentTimer;
  Timer? _ambientHeartTimer;

  bool _isFollowingNeha = false;
  bool _isFollowingArun = false;

  // Comments stream
  List<LiveComment> _comments = [];
  final ScrollController _chatScrollController = ScrollController();
  final List<_FloatingLaneHeart> _laneHearts = [];
  final Random _random = Random();

  final List<Map<String, String>> _incomingCommentPool = [
    {'name': 'Diya', 'avatar': AppAssets.status4, 'msg': 'sent Rose 🌹 x 1', 'isGift': 'true'},
    {'name': 'Ananya', 'avatar': AppAssets.status3, 'msg': 'sent Ocean Whale 🐳 x 1', 'isGift': 'true'},
    {'name': 'Sanjay', 'avatar': AppAssets.status5, 'msg': 'sent Angel Vehicle 🚀 x 1', 'isGift': 'true'},
    {'name': 'Rahul', 'avatar': AppAssets.avatarSaran, 'msg': 'sent Car 🚗 x 1', 'isGift': 'true'},
    {'name': 'Sneha', 'avatar': AppAssets.status3, 'msg': 'Keep going Neha! ⭐', 'isGift': 'false'},
    {'name': 'Kavya', 'avatar': AppAssets.status4, 'msg': 'Team Neha let\'s win! 🔥', 'isGift': 'false'},
    {'name': 'Vicky', 'avatar': AppAssets.status2, 'msg': 'Arun comeback time! 💪', 'isGift': 'false'},
  ];
  int _poolIndex = 0;

  @override
  void initState() {
    super.initState();
    ReelVideoManager.instance.pauseAll();

    _initInitialComments();
    _startCountdown();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      // Ambient floating hearts
      _ambientHeartTimer = Timer.periodic(const Duration(milliseconds: 600), (_) {
        if (!mounted) return;
        if (_laneHearts.length < 12) {
          _spawnLaneHeart();
        }
      });

      // Auto comment stream
      _commentTimer = Timer.periodic(const Duration(milliseconds: 3200), (_) {
        if (!mounted) return;
        _receiveNextMockComment();
      });
    });
  }

  void _initInitialComments() {
    final now = DateTime.now();
    _comments = [
      LiveComment(
        id: 'init_1',
        userName: 'Diya',
        userAssetPath: AppAssets.status4,
        message: 'sent Rose 🌹 x 1',
        type: LiveCommentType.gift,
        timestamp: DateTime(now.year, now.month, now.day, 10, 21),
      ),
      LiveComment(
        id: 'init_2',
        userName: 'Ananya',
        userAssetPath: AppAssets.status3,
        message: 'sent Ocean Whale 🐳 x 1',
        type: LiveCommentType.gift,
        timestamp: DateTime(now.year, now.month, now.day, 10, 22),
      ),
      LiveComment(
        id: 'init_3',
        userName: 'Sanjay',
        userAssetPath: AppAssets.status5,
        message: 'sent Angel Vehicle 🚀 x 1',
        type: LiveCommentType.gift,
        timestamp: DateTime(now.year, now.month, now.day, 10, 23),
      ),
      LiveComment(
        id: 'init_4',
        userName: 'Rahul',
        userAssetPath: AppAssets.avatarSaran,
        message: 'sent Car 🚗 x 1',
        type: LiveCommentType.gift,
        timestamp: DateTime(now.year, now.month, now.day, 10, 24),
      ),
      LiveComment(
        id: 'init_5',
        userName: 'Sneha',
        userAssetPath: AppAssets.status3,
        message: 'Keep going Neha! ⭐',
        type: LiveCommentType.chat,
        timestamp: DateTime(now.year, now.month, now.day, 10, 25),
      ),
    ];
  }

  void _startCountdown() {
    _countdownTimer?.cancel();
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) return;
      if (_secondsRemaining > 0) {
        setState(() => _secondsRemaining--);
      } else {
        timer.cancel();
      }
    });
  }

  void _receiveNextMockComment() {
    final item = _incomingCommentPool[_poolIndex % _incomingCommentPool.length];
    _poolIndex++;
    final isGift = item['isGift'] == 'true';

    final comment = LiveComment(
      id: 'mock_${DateTime.now().millisecondsSinceEpoch}',
      userName: item['name']!,
      userAssetPath: item['avatar']!,
      message: item['msg']!,
      type: isGift ? LiveCommentType.gift : LiveCommentType.chat,
      timestamp: DateTime.now(),
    );

    setState(() {
      _comments.add(comment);
      if (isGift) {
        _leftScore += 1500;
        _rightScore += 450;
      } else {
        _leftScore += 250;
      }
    });

    _scrollToBottom();

    if (isGift) {
      _triggerMockGift(item['name']!, item['msg']!);
    }
  }

  void _triggerMockGift(String sender, String message) {
    GiftItem? gift;
    if (message.contains('Rose')) {
      gift = const GiftItem(id: 'rose', name: 'Rose', icon: '🌹', diamonds: 1, imageAssetPath: AppAssets.giftRose);
    } else if (message.contains('Ocean Whale')) {
      gift = const GiftItem(id: 'ocean_whale', name: 'Ocean Whale', icon: '🐳', diamonds: 4000, imageAssetPath: AppAssets.giftOceanWhale);
    } else if (message.contains('Car')) {
      gift = const GiftItem(id: 'car', name: 'Car', icon: '🚗', diamonds: 500, imageAssetPath: AppAssets.giftSuperCar);
    } else if (message.contains('Angel Vehicle')) {
      gift = const GiftItem(id: 'angel_vehicle', name: 'Angel Vehicle', icon: '🚀', diamonds: 3500, imageAssetPath: AppAssets.giftAngelVehicle);
    }

    if (gift != null) {
      _activeGiftKey.currentState?.playGift(
        gift,
        senderName: sender,
        toLeft: true,
        recipient: 'Neha ✨',
      );
    }
  }

  void _spawnLaneHeart() {
    final heart = _FloatingLaneHeart(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      size: 20.0 + _random.nextDouble() * 16.0,
      opacity: 0.65 + _random.nextDouble() * 0.35,
      horizontalOffset: (_random.nextDouble() - 0.5) * 28.0,
      onComplete: (id) {
        if (mounted) {
          setState(() {
            _laneHearts.removeWhere((h) => h.id == id);
          });
        }
      },
    );
    setState(() => _laneHearts.add(heart));
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_chatScrollController.hasClients) {
        _chatScrollController.animateTo(
          _chatScrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _handleSendComment(String text) {
    final trimmed = text.trim();
    if (trimmed.isEmpty) return;

    final userComment = LiveComment(
      id: 'user_${DateTime.now().millisecondsSinceEpoch}',
      userName: 'You',
      userAssetPath: AppAssets.status5,
      message: trimmed,
      timestamp: DateTime.now(),
    );

    setState(() {
      _comments.add(userComment);
      _leftScore += 500;
    });

    _scrollToBottom();
    _spawnLaneHeart();
    _heartsKey.currentState?.addHeart(toLeft: true);
  }

  void _openCommentInputModal() {
    final textController = TextEditingController();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return Padding(
          padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: const BoxDecoration(
              color: Color(0xF00D0F1D),
              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
              border: Border(top: BorderSide(color: Color(0xFF2979FF), width: 1.2)),
            ),
            child: SafeArea(
              top: false,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: ['🌹', '❤️', '🔥', '👏', '⭐', '🐳', '🚗', '👑', '🎉', '💯'].map((emoji) {
                        return GestureDetector(
                          onTap: () {
                            textController.text += emoji;
                            textController.selection = TextSelection.fromPosition(
                              TextPosition(offset: textController.text.length),
                            );
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
                            margin: const EdgeInsets.only(right: 6, bottom: 8),
                            decoration: BoxDecoration(
                              color: Colors.white10,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(emoji, style: const TextStyle(fontSize: 18)),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                  Row(
                    children: [
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.08),
                            borderRadius: BorderRadius.circular(24),
                            border: Border.all(color: const Color(0xFF2979FF).withValues(alpha: 0.6)),
                          ),
                          child: TextField(
                            controller: textController,
                            autofocus: true,
                            style: const TextStyle(color: Colors.white, fontSize: 14),
                            decoration: const InputDecoration(
                              hintText: 'Type a message...',
                              hintStyle: TextStyle(color: Colors.white54, fontSize: 13),
                              border: InputBorder.none,
                              contentPadding: EdgeInsets.symmetric(vertical: 10),
                            ),
                            onSubmitted: (val) {
                              if (val.trim().isNotEmpty) {
                                Navigator.pop(ctx);
                                _handleSendComment(val);
                              }
                            },
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      GestureDetector(
                        onTap: () {
                          if (textController.text.trim().isNotEmpty) {
                            final val = textController.text;
                            Navigator.pop(ctx);
                            _handleSendComment(val);
                          }
                        },
                        child: Container(
                          width: 42,
                          height: 42,
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: LinearGradient(
                              colors: [Color(0xFFFF2D78), Color(0xFF2979FF)],
                            ),
                          ),
                          child: const Icon(Icons.send_rounded, color: Colors.white, size: 20),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void _openGiftSheet() {
    GiftBottomSheet.show(
      context,
      (gift) => _processGift(gift, 1, recipient: 'Neha ✨'),
      recipients: const ['Neha ✨', 'Arun'],
      initialRecipient: 'Neha ✨',
      onGiftWithQuantitySelected: (gift, quantity) {
        _processGift(gift, quantity, recipient: 'Neha ✨');
      },
      onGiftWithRecipientSelected: (gift, quantity, recipient) {
        _processGift(gift, quantity, recipient: recipient);
      },
    );
  }

  void _processGift(GiftItem gift, int quantity, {String recipient = 'Neha ✨'}) {
    final isArun = recipient.toLowerCase().contains('arun');
    final points = gift.diamonds * 20 * quantity;

    setState(() {
      if (isArun) {
        _rightScore += points;
      } else {
        _leftScore += points;
      }
    });

    _activeGiftKey.currentState?.playGift(
      gift,
      senderName: 'You',
      toLeft: !isArun,
      recipient: recipient,
    );

    _heartsKey.currentState?.addHeart(toLeft: !isArun);
  }

  String _formatTimer(int totalSec) {
    final m = totalSec ~/ 60;
    final s = totalSec % 60;
    return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }

  String _formatScore(int score) {
    final formatter = NumberFormat('#,###');
    return formatter.format(score);
  }

  @override
  void dispose() {
    _countdownTimer?.cancel();
    _commentTimer?.cancel();
    _ambientHeartTimer?.cancel();
    _chatScrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final botPadding = mediaQuery.padding.bottom;

    return Scaffold(
      backgroundColor: const Color(0xFF070913),
      body: ActiveGiftAnimationOverlay(
        key: _activeGiftKey,
        child: FloatingHeartsOverlay(
          key: _heartsKey,
          child: Stack(
            children: [
              // 1. Background glow
              Positioned.fill(
                child: Container(
                  decoration: const BoxDecoration(
                    gradient: RadialGradient(
                      center: Alignment(0, -0.3),
                      radius: 1.4,
                      colors: [
                        Color(0xFF141935),
                        Color(0xFF080A14),
                        Color(0xFF030408),
                      ],
                    ),
                  ),
                ),
              ),

              // 2. Main Content Column
              SafeArea(
                bottom: false,
                child: Column(
                  children: [
                    const SizedBox(height: 4),

                    // Top Header (Neha vs Arun Streamers & PK Battle Logo)
                    _buildTopBattleHeader(),

                    // Team Neha vs Team Arun Sub-headers
                    const SizedBox(height: 6),
                    _buildTeamSubHeader(),

                    const SizedBox(height: 8),

                    // Split Video Arena
                    Expanded(
                      child: Stack(
                        children: [
                          // Video split views
                          Positioned.fill(
                            child: _buildSplitVideoArena(),
                          ),

                          // Bottom Overlaid PK Info: Score Bar, Top Supporters, Live Comments
                          Positioned(
                            left: 0,
                            right: 0,
                            bottom: 0,
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                // Clash Score Bar (Red vs Blue with 3D Gift icons)
                                _buildClashScoreBar(),

                                const SizedBox(height: 6),

                                // Top Supporters & Send Gift CTA Bar
                                _buildTopSupportersAndSendGiftBar(),

                                const SizedBox(height: 8),

                                // Live Comments Stream with Right Floating Hearts Lane
                                _buildLiveChatAndHeartsArea(),

                                const SizedBox(height: 4),

                                // "New Messages v" Pill
                                _buildNewMessagesPill(),

                                const SizedBox(height: 6),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Bottom Action Bar
                    _buildBottomActionBar(botPadding),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ===========================================================================
  // TOP BATTLE HEADER
  // ===========================================================================
  Widget _buildTopBattleHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Left Streamer (Neha)
          Expanded(
            child: Row(
              children: [
                // Avatar with Pink Ring
                Container(
                  padding: const EdgeInsets.all(2),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: const Color(0xFFFF2D78), width: 1.8),
                    boxShadow: const [
                      BoxShadow(color: Color(0x66FF2D78), blurRadius: 8),
                    ],
                  ),
                  child: CustomAvatar(radius: 20, assetPath: _leftStreamerAsset),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        children: [
                          Flexible(
                            child: Text(
                              _leftStreamerName,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 13.5,
                                fontWeight: FontWeight.bold,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: 3),
                          const Text('👑', style: TextStyle(fontSize: 12)),
                        ],
                      ),
                      const SizedBox(height: 1),
                      Row(
                        children: [
                          const Text('❤️ ', style: TextStyle(fontSize: 9)),
                          Text(
                            _leftLikes,
                            style: const TextStyle(color: Colors.white70, fontSize: 10.5, fontWeight: FontWeight.w500),
                          ),
                        ],
                      ),
                      const SizedBox(height: 3),
                      GestureDetector(
                        onTap: () => setState(() => _isFollowingNeha = !_isFollowingNeha),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 3),
                          decoration: BoxDecoration(
                            color: _isFollowingNeha ? Colors.white24 : const Color(0xFFFF2D78),
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              if (!_isFollowingNeha)
                                const BoxShadow(color: Color(0x66FF2D78), blurRadius: 6),
                            ],
                          ),
                          child: Text(
                            _isFollowingNeha ? 'Following' : 'Follow',
                            style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Center PK Battle Logo & Timer
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // PK Crown & Badge
              Stack(
                alignment: Alignment.center,
                clipBehavior: Clip.none,
                children: [
                  const Positioned(
                    top: -10,
                    child: Text('👑', style: TextStyle(fontSize: 14)),
                  ),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Pink wing
                      Container(
                        width: 14,
                        height: 12,
                        decoration: const BoxDecoration(
                          gradient: LinearGradient(colors: [Color(0x00FF2D78), Color(0xFFFF2D78)]),
                          borderRadius: BorderRadius.horizontal(left: Radius.circular(8)),
                        ),
                      ),
                      ShaderMask(
                        shaderCallback: (bounds) => const LinearGradient(
                          colors: [Color(0xFFFFEA00), Color(0xFFFF9100), Color(0xFFFF2D78)],
                        ).createShader(bounds),
                        child: const Text(
                          'PK',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 22,
                            fontWeight: FontWeight.w900,
                            fontStyle: FontStyle.italic,
                            letterSpacing: -0.5,
                          ),
                        ),
                      ),
                      // Blue wing
                      Container(
                        width: 14,
                        height: 12,
                        decoration: const BoxDecoration(
                          gradient: LinearGradient(colors: [Color(0xFF2979FF), Color(0x002979FF)]),
                          borderRadius: BorderRadius.horizontal(right: Radius.circular(8)),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                decoration: BoxDecoration(
                  color: const Color(0xFF0D122B),
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: const Color(0xFF2979FF).withValues(alpha: 0.6), width: 0.8),
                ),
                child: const Text(
                  'BATTLE',
                  style: TextStyle(color: Color(0xFF82B1FF), fontSize: 8.5, fontWeight: FontWeight.w900, letterSpacing: 1),
                ),
              ),
              const SizedBox(height: 3),
              // Battle Time Pill
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                decoration: BoxDecoration(
                  color: const Color(0xD00A0D1E),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFF202A50), width: 1),
                ),
                child: Column(
                  children: [
                    const Text(
                      'Battle Time',
                      style: TextStyle(color: Colors.white60, fontSize: 8.5, fontWeight: FontWeight.w500),
                    ),
                    Text(
                      _formatTimer(_secondsRemaining),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          // Right Streamer (Arun)
          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Flexible(
                            child: Text(
                              _rightStreamerName,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 13.5,
                                fontWeight: FontWeight.bold,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: 3),
                          const Text('👑', style: TextStyle(fontSize: 12)),
                        ],
                      ),
                      const SizedBox(height: 1),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          const Text('❤️ ', style: TextStyle(fontSize: 9)),
                          Text(
                            _rightLikes,
                            style: const TextStyle(color: Colors.white70, fontSize: 10.5, fontWeight: FontWeight.w500),
                          ),
                        ],
                      ),
                      const SizedBox(height: 3),
                      GestureDetector(
                        onTap: () => setState(() => _isFollowingArun = !_isFollowingArun),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 3),
                          decoration: BoxDecoration(
                            color: _isFollowingArun ? Colors.white24 : const Color(0xFF2979FF),
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              if (!_isFollowingArun)
                                const BoxShadow(color: Color(0x662979FF), blurRadius: 6),
                            ],
                          ),
                          child: Text(
                            _isFollowingArun ? 'Following' : 'Follow',
                            style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                // Avatar with Blue Ring
                Container(
                  padding: const EdgeInsets.all(2),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: const Color(0xFF2979FF), width: 1.8),
                    boxShadow: const [
                      BoxShadow(color: Color(0x662979FF), blurRadius: 8),
                    ],
                  ),
                  child: CustomAvatar(radius: 20, assetPath: _rightStreamerAsset),
                ),
                const SizedBox(width: 6),
                // Close button
                GestureDetector(
                  onTap: () {
                    if (widget.onBack != null) {
                      widget.onBack!();
                    } else {
                      Navigator.of(context).maybePop();
                    }
                  },
                  child: Container(
                    width: 26,
                    height: 26,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white.withValues(alpha: 0.12),
                    ),
                    child: const Icon(Icons.close_rounded, color: Colors.white, size: 16),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ===========================================================================
  // TEAM SUB HEADER
  // ===========================================================================
  Widget _buildTeamSubHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Team Neha Pill
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: const Color(0x99170E20),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0x44FF2D78)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Team Neha 👑',
                  style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
                ),
                const SizedBox(width: 6),
                // Mini avatar cluster
                SizedBox(
                  width: 32,
                  height: 16,
                  child: Stack(
                    children: [
                      Positioned(left: 0, child: CustomAvatar(radius: 8, assetPath: AppAssets.status2)),
                      Positioned(left: 14, child: CustomAvatar(radius: 8, assetPath: AppAssets.status3)),
                    ],
                  ),
                ),
                const SizedBox(width: 4),
                const Text(
                  '1.2K Members',
                  style: TextStyle(color: Colors.white60, fontSize: 10),
                ),
              ],
            ),
          ),

          // Team Arun Pill
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: const Color(0x990E182A),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0x442979FF)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Mini avatar cluster
                SizedBox(
                  width: 32,
                  height: 16,
                  child: Stack(
                    children: [
                      Positioned(left: 0, child: CustomAvatar(radius: 8, assetPath: AppAssets.status5)),
                      Positioned(left: 14, child: CustomAvatar(radius: 8, assetPath: AppAssets.status1)),
                    ],
                  ),
                ),
                const SizedBox(width: 4),
                const Text(
                  '980 Members',
                  style: TextStyle(color: Colors.white60, fontSize: 10),
                ),
                const SizedBox(width: 6),
                const Text(
                  'Team Arun 👑',
                  style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ===========================================================================
  // SPLIT VIDEO ARENA
  // ===========================================================================
  Widget _buildSplitVideoArena() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 6),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFF1E2442), width: 1.5),
        ),
        child: Stack(
          children: [
            // Left & Right Video Player split
            Row(
              children: [
                // Left Video Stream (Neha)
                Expanded(
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      LiveVideoPlayer(
                        playerId: 'pk_left',
                        videoAssetPath: _leftVideoAsset,
                      ),
                      // Top Left Overlay Badge
                      Positioned(
                        top: 10,
                        left: 10,
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2.5),
                              decoration: BoxDecoration(
                                color: Colors.black54,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: const Row(
                                children: [
                                  Text('🔥', style: TextStyle(fontSize: 10)),
                                  SizedBox(width: 3),
                                  Text(
                                    '8.4K',
                                    style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 5),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2.5),
                              decoration: BoxDecoration(
                                color: const Color(0xFFFF2D55),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: const Text(
                                'LIVE',
                                style: TextStyle(color: Colors.white, fontSize: 9.5, fontWeight: FontWeight.w900),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                // Right Video Stream (Arun)
                Expanded(
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      LiveVideoPlayer(
                        playerId: 'pk_right',
                        videoAssetPath: _rightVideoAsset,
                      ),
                      // Top Right Overlay Badge
                      Positioned(
                        top: 10,
                        left: 10,
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2.5),
                              decoration: BoxDecoration(
                                color: Colors.black54,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: const Row(
                                children: [
                                  Text('🔥', style: TextStyle(fontSize: 10)),
                                  SizedBox(width: 3),
                                  Text(
                                    '1.2K',
                                    style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 5),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2.5),
                              decoration: BoxDecoration(
                                color: const Color(0xFF2979FF),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: const Text(
                                'LIVE',
                                style: TextStyle(color: Colors.white, fontSize: 9.5, fontWeight: FontWeight.w900),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            // Center Energy Clash Line & VS Badge
            Positioned.fill(
              child: Center(
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    // Vertical Glowing Energy Beam
                    Container(
                      width: 3,
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Color(0x00FF2D78),
                            Color(0xFFFF2D78),
                            Color(0xFF2979FF),
                            Color(0x002979FF),
                          ],
                        ),
                        boxShadow: [
                          BoxShadow(color: Color(0xAAFF2D78), blurRadius: 10, spreadRadius: 2),
                          BoxShadow(color: Color(0xAA2979FF), blurRadius: 10, spreadRadius: 2),
                        ],
                      ),
                    ),

                    // Centered VS Badge
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: const RadialGradient(
                          colors: [Color(0xFF2A1538), Color(0xFF0F152D)],
                        ),
                        border: Border.all(color: const Color(0xFFFF2D78), width: 2),
                        boxShadow: const [
                          BoxShadow(color: Color(0xAAFF2D78), blurRadius: 14, spreadRadius: 1),
                          BoxShadow(color: Color(0xAA2979FF), blurRadius: 14, spreadRadius: 1),
                        ],
                      ),
                      child: const Center(
                        child: Text(
                          'VS',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 15,
                            fontWeight: FontWeight.w900,
                            fontStyle: FontStyle.italic,
                            letterSpacing: -0.5,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ===========================================================================
  // CLASH SCORE BAR (Red vs Blue with 3D Gifts)
  // ===========================================================================
  Widget _buildClashScoreBar() {
    final total = _leftScore + _rightScore;
    final leftFlex = total == 0 ? 50 : ((_leftScore / total) * 100).clamp(15, 85).toInt();
    final rightFlex = 100 - leftFlex;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 10),
      height: 38,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(19),
        boxShadow: const [
          BoxShadow(color: Colors.black87, blurRadius: 12, offset: Offset(0, 4)),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(19),
        child: Row(
          children: [
            // Left Score Bar (Pink/Red Gradient)
            Expanded(
              flex: leftFlex,
              child: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFFFF1744), Color(0xFFFF2D78), Color(0xFFFF5252)],
                  ),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: Row(
                  children: [
                    const Text('🎁', style: TextStyle(fontSize: 18)),
                    const SizedBox(width: 6),
                    Text(
                      _formatScore(_leftScore),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 13,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 0.3,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Middle chevron angle
            Container(
              width: 12,
              color: const Color(0xFF2979FF),
            ),

            // Right Score Bar (Cyan/Blue Gradient)
            Expanded(
              flex: rightFlex,
              child: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFF00B0FF), Color(0xFF2979FF), Color(0xFF1E88E5)],
                  ),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Text(
                      _formatScore(_rightScore),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 13,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 0.3,
                      ),
                    ),
                    const SizedBox(width: 6),
                    const Text('🎁', style: TextStyle(fontSize: 18)),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ===========================================================================
  // TOP SUPPORTERS & SEND GIFT BUTTON
  // ===========================================================================
  Widget _buildTopSupportersAndSendGiftBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Left Supporters (Neha)
          Column(
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildRankedAvatar(AppAssets.status4, 1, const Color(0xFFFFD700)),
                  const SizedBox(width: 4),
                  _buildRankedAvatar(AppAssets.status3, 2, const Color(0xFFC0C0C0)),
                  const SizedBox(width: 4),
                  _buildRankedAvatar(AppAssets.status2, 3, const Color(0xFFCD7F32)),
                ],
              ),
              const SizedBox(height: 3),
              const Text(
                'Top Supporters',
                style: TextStyle(color: Colors.white70, fontSize: 10, fontWeight: FontWeight.w500),
              ),
            ],
          ),

          // Center Send Gift Button
          GestureDetector(
            onTap: _openGiftSheet,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 7),
              decoration: BoxDecoration(
                color: const Color(0xEE111728),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFFFD54F), width: 1.4),
                boxShadow: const [
                  BoxShadow(color: Color(0x55FFD54F), blurRadius: 10, spreadRadius: 1),
                ],
              ),
              child: const Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('🎁', style: TextStyle(fontSize: 22)),
                  SizedBox(height: 2),
                  Text(
                    'Send Gift',
                    style: TextStyle(
                      color: Color(0xFFFFE082),
                      fontSize: 11,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Right Supporters (Arun)
          Column(
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildRankedAvatar(AppAssets.status5, 1, const Color(0xFFFFD700)),
                  const SizedBox(width: 4),
                  _buildRankedAvatar(AppAssets.status1, 2, const Color(0xFFC0C0C0)),
                  const SizedBox(width: 4),
                  _buildRankedAvatar(AppAssets.avatarMeena, 3, const Color(0xFFCD7F32)),
                ],
              ),
              const SizedBox(height: 3),
              const Text(
                'Top Supporters',
                style: TextStyle(color: Colors.white70, fontSize: 10, fontWeight: FontWeight.w500),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRankedAvatar(String asset, int rank, Color badgeColor) {
    return Stack(
      clipBehavior: Clip.none,
      alignment: Alignment.center,
      children: [
        if (rank == 1)
          const Positioned(
            top: -9,
            child: Text('👑', style: TextStyle(fontSize: 11)),
          ),
        Container(
          padding: const EdgeInsets.all(1.5),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: badgeColor, width: 1.2),
          ),
          child: CustomAvatar(radius: 14, assetPath: asset),
        ),
        Positioned(
          bottom: -4,
          child: Container(
            width: 14,
            height: 14,
            decoration: BoxDecoration(
              color: badgeColor,
              shape: BoxShape.circle,
              border: Border.all(color: Colors.black, width: 1),
            ),
            child: Center(
              child: Text(
                '$rank',
                style: const TextStyle(
                  color: Colors.black,
                  fontSize: 8.5,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  // ===========================================================================
  // LIVE CHAT & FLOATING HEARTS AREA
  // ===========================================================================
  Widget _buildLiveChatAndHeartsArea() {
    return Container(
      height: 130,
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          // Left: Upward scrolling comments
          Expanded(
            child: ListView.builder(
              controller: _chatScrollController,
              padding: EdgeInsets.zero,
              itemCount: _comments.length,
              itemBuilder: (ctx, index) {
                final c = _comments[index];
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 2.5),
                  child: Row(
                    children: [
                      CustomAvatar(radius: 12, assetPath: c.userAssetPath ?? AppAssets.status4),
                      const SizedBox(width: 8),
                      Expanded(
                        child: RichText(
                          text: TextSpan(
                            children: [
                              TextSpan(
                                text: '${c.userName} ',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              TextSpan(
                                text: c.message,
                                style: TextStyle(
                                  color: c.type == LiveCommentType.gift
                                      ? const Color(0xFFFFD54F)
                                      : Colors.white.withValues(alpha: 0.9),
                                  fontSize: 11.5,
                                  fontWeight: c.type == LiveCommentType.gift ? FontWeight.w600 : FontWeight.normal,
                                ),
                              ),
                            ],
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        DateFormat('hh:mm a').format(c.timestamp),
                        style: const TextStyle(color: Colors.white38, fontSize: 9.5),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),

          const SizedBox(width: 8),

          // Right: Floating Hearts Stream Lane
          SizedBox(
            width: 44,
            height: 130,
            child: Stack(
              alignment: Alignment.bottomCenter,
              children: [
                ..._laneHearts.map((heart) => _LaneHeartWidget(key: ValueKey(heart.id), heart: heart)),
                // Big Interactive Glow Heart at bottom
                GestureDetector(
                  onTap: () {
                    _spawnLaneHeart();
                    _heartsKey.currentState?.addHeart(toLeft: true);
                  },
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: Color(0x33FF2D78),
                      boxShadow: [
                        BoxShadow(color: Color(0x88FF2D78), blurRadius: 14, spreadRadius: 2),
                      ],
                    ),
                    child: const Center(
                      child: Icon(Icons.favorite_rounded, color: Color(0xFFFF2D78), size: 26),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ===========================================================================
  // "NEW MESSAGES v" PILL
  // ===========================================================================
  Widget _buildNewMessagesPill() {
    return GestureDetector(
      onTap: _scrollToBottom,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        decoration: BoxDecoration(
          color: const Color(0xEE0E1428),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: const Color(0xFF2979FF).withValues(alpha: 0.6), width: 1),
        ),
        child: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'New Messages',
              style: TextStyle(color: Colors.white, fontSize: 10.5, fontWeight: FontWeight.w600),
            ),
            SizedBox(width: 4),
            Icon(Icons.keyboard_arrow_down_rounded, color: Color(0xFF82B1FF), size: 14),
          ],
        ),
      ),
    );
  }

  // ===========================================================================
  // BOTTOM ACTION BAR
  // ===========================================================================
  Widget _buildBottomActionBar(double bottomPadding) {
    return Container(
      padding: EdgeInsets.fromLTRB(10, 6, 10, max(bottomPadding, 10)),
      child: Row(
        children: [
          // Star Icon Button
          GestureDetector(
            onTap: () => _heartsKey.currentState?.addHeart(toLeft: true),
            child: Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xD012172A),
                border: Border.all(color: const Color(0xFFFFD54F), width: 1.2),
                boxShadow: const [
                  BoxShadow(color: Color(0x44FFD54F), blurRadius: 8),
                ],
              ),
              child: const Center(
                child: Icon(Icons.star_rounded, color: Color(0xFFFFD54F), size: 24),
              ),
            ),
          ),
          const SizedBox(width: 8),

          // "Type a message..." input trigger
          Expanded(
            child: GestureDetector(
              onTap: _openCommentInputModal,
              child: Container(
                height: 42,
                padding: const EdgeInsets.symmetric(horizontal: 14),
                decoration: BoxDecoration(
                  color: const Color(0xBB121628),
                  borderRadius: BorderRadius.circular(21),
                  border: Border.all(color: Colors.white12),
                ),
                child: const Row(
                  children: [
                    Expanded(
                      child: Text(
                        'Type a message...',
                        style: TextStyle(color: Colors.white54, fontSize: 12.5),
                      ),
                    ),
                    Icon(Icons.sentiment_satisfied_alt_rounded, color: Colors.white54, size: 20),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),

          // Gift Button (Hot Pink / Gold Glow)
          GestureDetector(
            onTap: _openGiftSheet,
            child: Container(
              height: 42,
              padding: const EdgeInsets.symmetric(horizontal: 10),
              decoration: BoxDecoration(
                color: const Color(0xD0180F24),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: const Color(0xFFFF2D78), width: 1.4),
                boxShadow: const [
                  BoxShadow(color: Color(0x66FF2D78), blurRadius: 8),
                ],
              ),
              child: const Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('🎁', style: TextStyle(fontSize: 16)),
                  Text(
                    'Gift',
                    style: TextStyle(color: Colors.white, fontSize: 9.5, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 8),

          // Share Button
          GestureDetector(
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Live Stream link copied to clipboard!'),
                  duration: Duration(seconds: 2),
                ),
              );
            },
            child: Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xD012172A),
                border: Border.all(color: Colors.white12),
              ),
              child: const Center(
                child: Icon(Icons.share_rounded, color: Colors.white, size: 20),
              ),
            ),
          ),
          const SizedBox(width: 8),

          // More Options Button (...)
          GestureDetector(
            onTap: () => LiveToolsBottomSheet.show(context),
            child: Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xD012172A),
                border: Border.all(color: Colors.white12),
              ),
              child: const Center(
                child: Icon(Icons.more_horiz_rounded, color: Colors.white, size: 20),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// =============================================================================
// FLOATING LANE HEARTS HELPER MODEL & ANIMATION WIDGET
// =============================================================================
class _FloatingLaneHeart {
  final String id;
  final double size;
  final double opacity;
  final double horizontalOffset;
  final Function(String id) onComplete;

  _FloatingLaneHeart({
    required this.id,
    required this.size,
    required this.opacity,
    required this.horizontalOffset,
    required this.onComplete,
  });
}

class _LaneHeartWidget extends StatefulWidget {
  final _FloatingLaneHeart heart;

  const _LaneHeartWidget({super.key, required this.heart});

  @override
  State<_LaneHeartWidget> createState() => _LaneHeartWidgetState();
}

class _LaneHeartWidgetState extends State<_LaneHeartWidget>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _progress;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2200),
    );

    _progress = CurvedAnimation(parent: _controller, curve: Curves.easeOut);

    _controller.forward().then((_) {
      widget.heart.onComplete(widget.heart.id);
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _progress,
      builder: (ctx, child) {
        final val = _progress.value;
        final yOffset = -val * 110.0;
        final xOffset = sin(val * pi * 2.5) * widget.heart.horizontalOffset;
        final opacity = ((1.0 - val) * widget.heart.opacity).clamp(0.0, 1.0);
        final scale = 0.8 + (val * 0.4);

        return Transform.translate(
          offset: Offset(xOffset, yOffset),
          child: Transform.scale(
            scale: scale,
            child: Opacity(
              opacity: opacity,
              child: Icon(
                Icons.favorite_rounded,
                color: const Color(0xFFFF2D78),
                size: widget.heart.size,
              ),
            ),
          ),
        );
      },
    );
  }
}
