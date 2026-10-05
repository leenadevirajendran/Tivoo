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

/// Pixel-perfect, ultra-stylish PK Battle Live Screen strictly matching the user's reference UI.
class PkBattleLiveScreen extends StatefulWidget {
  final VoidCallback? onBack;

  const PkBattleLiveScreen({super.key, this.onBack});

  @override
  State<PkBattleLiveScreen> createState() => _PkBattleLiveScreenState();
}

class _PkBattleLiveScreenState extends State<PkBattleLiveScreen> {
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
  final int _secondsRemaining = 106;

  bool _isFollowingNeha = false;
  bool _isFollowingArun = false;

  // Comments stream
  List<LiveComment> _comments = [];
  final ScrollController _chatScrollController = ScrollController();
  final List<_FloatingLaneHeart> _laneHearts = [];
  final Random _random = Random();

  @override
  void initState() {
    super.initState();
    ReelVideoManager.instance.pauseAll();
    _initInitialComments();
    _initStaticLaneHearts();
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

  void _initStaticLaneHearts() {
    _laneHearts.clear();
    final offsets = [0.0, 4.0, -3.0, 2.0];
    final sizes = [15.0, 17.0, 19.0, 21.0];
    final opacities = [0.5, 0.65, 0.8, 0.95];

    for (int i = 0; i < 4; i++) {
      _laneHearts.add(
        _FloatingLaneHeart(
          id: 'static_$i',
          size: sizes[i],
          opacity: opacities[i],
          horizontalOffset: offsets[i],
        ),
      );
    }
  }

  void _spawnLaneHeart() {
    final heart = _FloatingLaneHeart(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      size: 16.0 + _random.nextDouble() * 10.0,
      opacity: 0.8 + _random.nextDouble() * 0.2,
      horizontalOffset: (_random.nextDouble() - 0.5) * 12.0,
    );
    if (mounted) {
      setState(() {
        _laneHearts.add(heart);
        if (_laneHearts.length > 8) {
          _laneHearts.removeAt(0);
        }
      });
    }
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
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
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
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            margin: const EdgeInsets.only(right: 6, bottom: 8),
                            decoration: BoxDecoration(
                              color: Colors.white10,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(emoji, style: const TextStyle(fontSize: 16)),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                  Row(
                    children: [
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.08),
                            borderRadius: BorderRadius.circular(24),
                            border: Border.all(color: const Color(0xFF2979FF).withValues(alpha: 0.6)),
                          ),
                          child: TextField(
                            controller: textController,
                            autofocus: true,
                            style: const TextStyle(color: Colors.white, fontSize: 13.5),
                            decoration: const InputDecoration(
                              hintText: 'Type a message...',
                              hintStyle: TextStyle(color: Colors.white54, fontSize: 12.5),
                              border: InputBorder.none,
                              contentPadding: EdgeInsets.symmetric(vertical: 8),
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
                          width: 38,
                          height: 38,
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: LinearGradient(
                              colors: [Color(0xFFFF2D78), Color(0xFF2979FF)],
                            ),
                          ),
                          child: const Icon(Icons.send_rounded, color: Colors.white, size: 18),
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
    _chatScrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final botPadding = mediaQuery.padding.bottom;

    return Scaffold(
      backgroundColor: const Color(0xFF04060E),
      body: ActiveGiftAnimationOverlay(
        key: _activeGiftKey,
        child: FloatingHeartsOverlay(
          key: _heartsKey,
          child: Stack(
            children: [
              // 1. Deep Space Neon Cyber Background
              Positioned.fill(
                child: Container(
                  decoration: const BoxDecoration(
                    gradient: RadialGradient(
                      center: Alignment(0, -0.4),
                      radius: 1.4,
                      colors: [
                        Color(0xFF131938),
                        Color(0xFF080B1A),
                        Color(0xFF03040A),
                      ],
                    ),
                  ),
                ),
              ),

              // 2. Clean Layered UI Structure
              SafeArea(
                bottom: false,
                child: Column(
                  children: [
                    const SizedBox(height: 2),

                    // Top Battle Header (Card Capsules + PK Battle Logo + Timer + Close Button)
                    _buildTopBattleHeader(),

                    const SizedBox(height: 6),

                    // Team Neha vs Team Arun Sub-headers
                    _buildTeamSubHeader(),

                    const SizedBox(height: 8),

                    // Split Dual Live Stream Video Arena
                    _buildSplitVideoArena(),

                    const SizedBox(height: 6),

                    // Clash Score Bar (7,556,900 vs 483,400 with 3D Gifts)
                    _buildClashScoreBar(),

                    const SizedBox(height: 6),

                    // Top Supporters Pedestals & Send Gift CTA Bar
                    _buildTopSupportersAndSendGiftBar(),

                    const SizedBox(height: 6),

                    // Live Comments Stream & Right Floating Hearts Column
                    Expanded(
                      child: _buildLiveChatAndHeartsArea(),
                    ),

                    // "New Messages v" Pill
                    _buildNewMessagesPill(),

                    const SizedBox(height: 6),

                    // Bottom Action Bar (Star, Message Input, Gift, Share, More)
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
  // 1. TOP BATTLE HEADER (Matching Image 2 Reference)
  // ===========================================================================
  Widget _buildTopBattleHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Left Streamer Capsule (Neha)
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 6),
              decoration: BoxDecoration(
                color: const Color(0x99160E22),
                borderRadius: BorderRadius.circular(22),
                border: Border.all(color: const Color(0xFFFF2D78).withValues(alpha: 0.7), width: 1.2),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFFFF2D78).withValues(alpha: 0.15),
                    blurRadius: 10,
                  ),
                ],
              ),
              child: Row(
                children: [
                  // Circular Avatar with Glowing Ring
                  Container(
                    padding: const EdgeInsets.all(2),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: const Color(0xFFFF2D78), width: 1.8),
                    ),
                    child: CustomAvatar(radius: 17, assetPath: _leftStreamerAsset),
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Row(
                          children: [
                            Text(
                              _leftStreamerName,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 12.5,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(width: 2),
                            const Text('👑', style: TextStyle(fontSize: 10)),
                          ],
                        ),
                        const SizedBox(height: 1),
                        Row(
                          children: [
                            const Text('❤️ ', style: TextStyle(fontSize: 8.5)),
                            Text(
                              _leftLikes,
                              style: const TextStyle(color: Colors.white70, fontSize: 10, fontWeight: FontWeight.w600),
                            ),
                          ],
                        ),
                        const SizedBox(height: 3),
                        GestureDetector(
                          onTap: () => setState(() => _isFollowingNeha = !_isFollowingNeha),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2.5),
                            decoration: BoxDecoration(
                              color: _isFollowingNeha ? Colors.white24 : const Color(0xFFFF2D78),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              _isFollowingNeha ? 'Following' : 'Follow',
                              style: const TextStyle(color: Colors.white, fontSize: 9.5, fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Center PK Battle Logo & Timer Emblem
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // 3D PK Logo with Wings
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
                        // Left Pink Wing
                        Container(
                          width: 14,
                          height: 12,
                          decoration: const BoxDecoration(
                            gradient: LinearGradient(colors: [Color(0x00FF2D78), Color(0xFFFF2D78)]),
                            borderRadius: BorderRadius.horizontal(left: Radius.circular(8)),
                          ),
                        ),
                        // 3D Gold "PK"
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
                        // Right Blue Wing
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
                // BATTLE Label Pill
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                  decoration: BoxDecoration(
                    color: const Color(0xFF090D1E),
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: const Color(0xFFFFD54F).withValues(alpha: 0.6), width: 0.8),
                  ),
                  child: const Text(
                    'BATTLE',
                    style: TextStyle(
                      color: Color(0xFFFFD54F),
                      fontSize: 8,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 0.8,
                    ),
                  ),
                ),
                const SizedBox(height: 3),
                // Battle Time Countdown Badge
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: const Color(0xEE090D1E),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: const Color(0xFF243260), width: 1),
                  ),
                  child: Column(
                    children: [
                      const Text(
                        'Battle Time',
                        style: TextStyle(color: Colors.white60, fontSize: 7.5, fontWeight: FontWeight.w500),
                      ),
                      Text(
                        _formatTimer(_secondsRemaining),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 13,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Right Streamer Capsule (Arun) & Floating Exit Button
          Expanded(
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 6),
                  decoration: BoxDecoration(
                    color: const Color(0x990E182A),
                    borderRadius: BorderRadius.circular(22),
                    border: Border.all(color: const Color(0xFF2979FF).withValues(alpha: 0.7), width: 1.2),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF2979FF).withValues(alpha: 0.15),
                        blurRadius: 10,
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                Text(
                                  _rightStreamerName,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 12.5,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(width: 2),
                                const Text('👑', style: TextStyle(fontSize: 10)),
                              ],
                            ),
                            const SizedBox(height: 1),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                const Text('❤️ ', style: TextStyle(fontSize: 8.5)),
                                Text(
                                  _rightLikes,
                                  style: const TextStyle(color: Colors.white70, fontSize: 10, fontWeight: FontWeight.w600),
                                ),
                              ],
                            ),
                            const SizedBox(height: 3),
                            GestureDetector(
                              onTap: () => setState(() => _isFollowingArun = !_isFollowingArun),
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2.5),
                                decoration: BoxDecoration(
                                  color: _isFollowingArun ? Colors.white24 : const Color(0xFF2979FF),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Text(
                                  _isFollowingArun ? 'Following' : 'Follow',
                                  style: const TextStyle(color: Colors.white, fontSize: 9.5, fontWeight: FontWeight.bold),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 6),
                      // Circular Avatar with Blue Ring
                      Container(
                        padding: const EdgeInsets.all(2),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: const Color(0xFF2979FF), width: 1.8),
                        ),
                        child: CustomAvatar(radius: 17, assetPath: _rightStreamerAsset),
                      ),
                    ],
                  ),
                ),

                // Floating Close 'X' Button on top-right of the card
                Positioned(
                  top: -5,
                  right: -4,
                  child: GestureDetector(
                    onTap: () {
                      if (widget.onBack != null) {
                        widget.onBack!();
                      } else {
                        Navigator.of(context).maybePop();
                      }
                    },
                    child: Container(
                      width: 20,
                      height: 20,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: const Color(0xFF14192F),
                        border: Border.all(color: const Color(0xFF2979FF), width: 1.2),
                      ),
                      child: const Center(
                        child: Icon(Icons.close_rounded, color: Colors.white, size: 12),
                      ),
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
  // 2. TEAM SUB HEADER (Matching Image 2 Reference)
  // ===========================================================================
  Widget _buildTeamSubHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Team Neha Pill
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: const Color(0x99170E20),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0x66FF2D78)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Team Neha 👑',
                  style: TextStyle(color: Colors.white, fontSize: 10.5, fontWeight: FontWeight.bold),
                ),
                const SizedBox(width: 5),
                // Mini avatar cluster
                SizedBox(
                  width: 28,
                  height: 14,
                  child: Stack(
                    children: [
                      Positioned(left: 0, child: CustomAvatar(radius: 7, assetPath: AppAssets.status2)),
                      Positioned(left: 12, child: CustomAvatar(radius: 7, assetPath: AppAssets.status3)),
                    ],
                  ),
                ),
                const SizedBox(width: 4),
                const Text(
                  '1.2K Members',
                  style: TextStyle(color: Colors.white60, fontSize: 9.5),
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
              border: Border.all(color: const Color(0x662979FF)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Mini avatar cluster
                SizedBox(
                  width: 28,
                  height: 14,
                  child: Stack(
                    children: [
                      Positioned(left: 0, child: CustomAvatar(radius: 7, assetPath: AppAssets.status5)),
                      Positioned(left: 12, child: CustomAvatar(radius: 7, assetPath: AppAssets.status1)),
                    ],
                  ),
                ),
                const SizedBox(width: 4),
                const Text(
                  '980 Members',
                  style: TextStyle(color: Colors.white60, fontSize: 9.5),
                ),
                const SizedBox(width: 5),
                const Text(
                  'Team Arun 👑',
                  style: TextStyle(color: Colors.white, fontSize: 10.5, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ===========================================================================
  // 3. SPLIT DUAL VIDEO ARENA (Matching Image 3 Reference)
  // ===========================================================================
  Widget _buildSplitVideoArena() {
    return Container(
      height: 235,
      margin: const EdgeInsets.symmetric(horizontal: 6),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF1B2244), width: 1.2),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Stack(
          children: [
            // Dual Live Stream Split
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
                      // Top Left Overlay Badge: [🔥 8.4K] [LIVE]
                      Positioned(
                        top: 8,
                        left: 8,
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
                                  Text('🔥', style: TextStyle(fontSize: 9)),
                                  SizedBox(width: 3),
                                  Text(
                                    '8.4K',
                                    style: TextStyle(color: Colors.white, fontSize: 9.5, fontWeight: FontWeight.bold),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 4),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2.5),
                              decoration: BoxDecoration(
                                color: const Color(0xFFFF2D55),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: const Text(
                                'LIVE',
                                style: TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.w900),
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
                      // Top Right Overlay Badge: [🔥 1.2K] [LIVE]
                      Positioned(
                        top: 8,
                        left: 8,
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
                                  Text('🔥', style: TextStyle(fontSize: 9)),
                                  SizedBox(width: 3),
                                  Text(
                                    '1.2K',
                                    style: TextStyle(color: Colors.white, fontSize: 9.5, fontWeight: FontWeight.bold),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 4),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2.5),
                              decoration: BoxDecoration(
                                color: const Color(0xFF2979FF),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: const Text(
                                'LIVE',
                                style: TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.w900),
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

            // Center Clash Laser Beam & VS Badge
            Positioned.fill(
              child: Center(
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    // Vertical Lightning Energy Beam
                    Container(
                      width: 2.5,
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
                          BoxShadow(color: Color(0xCCFF2D78), blurRadius: 8, spreadRadius: 1),
                          BoxShadow(color: Color(0xCC2979FF), blurRadius: 8, spreadRadius: 1),
                        ],
                      ),
                    ),

                    // Centered Circular VS Clash Emblem
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: const RadialGradient(
                          colors: [Color(0xFF2C133D), Color(0xFF0C132C)],
                        ),
                        border: Border.all(color: const Color(0xFFFF2D78), width: 2),
                        boxShadow: const [
                          BoxShadow(color: Color(0xAAFF2D78), blurRadius: 12, spreadRadius: 1),
                          BoxShadow(color: Color(0xAA2979FF), blurRadius: 12, spreadRadius: 1),
                        ],
                      ),
                      child: const Center(
                        child: Text(
                          'VS',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 13.5,
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
  // 4. CLASH SCORE BAR (Matching Image 3 Reference)
  // ===========================================================================
  Widget _buildClashScoreBar() {
    final total = _leftScore + _rightScore;
    final leftFlex = total == 0 ? 50 : ((_leftScore / total) * 100).clamp(25, 75).toInt();
    final rightFlex = 100 - leftFlex;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8),
      height: 36,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        boxShadow: const [
          BoxShadow(color: Colors.black87, blurRadius: 10, offset: Offset(0, 3)),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(18),
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
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Row(
                  children: [
                    const Text('🎁', style: TextStyle(fontSize: 16)),
                    const SizedBox(width: 5),
                    Flexible(
                      child: Text(
                        _formatScore(_leftScore),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12.5,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 0.3,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Middle Glowing Diamond Divider
            Container(
              width: 3,
              color: Colors.white,
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
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Flexible(
                      child: Text(
                        _formatScore(_rightScore),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12.5,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 0.3,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 5),
                    const Text('🎁', style: TextStyle(fontSize: 16)),
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
  // 5. TOP SUPPORTERS & SEND GIFT CTA (Matching Image 4 Reference)
  // ===========================================================================
  Widget _buildTopSupportersAndSendGiftBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Left Top Supporters (Neha)
          Column(
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildRankedAvatar(AppAssets.status4, 1, const Color(0xFFFFD700), showCrown: true),
                  const SizedBox(width: 4),
                  _buildRankedAvatar(AppAssets.status3, 2, const Color(0xFFC0C0C0), showCrown: true),
                  const SizedBox(width: 4),
                  _buildRankedAvatar(AppAssets.status2, 3, const Color(0xFFCD7F32)),
                ],
              ),
              const SizedBox(height: 2),
              const Text(
                'Top Supporters',
                style: TextStyle(color: Colors.white70, fontSize: 9, fontWeight: FontWeight.w500),
              ),
            ],
          ),

          // Center Send Gift Button
          GestureDetector(
            onTap: _openGiftSheet,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
              decoration: BoxDecoration(
                color: const Color(0xEE111728),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFFFD54F), width: 1.3),
                boxShadow: const [
                  BoxShadow(color: Color(0x55FFD54F), blurRadius: 8, spreadRadius: 1),
                ],
              ),
              child: const Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('🎁', style: TextStyle(fontSize: 19)),
                  Text(
                    'Send Gift',
                    style: TextStyle(
                      color: Color(0xFFFFE082),
                      fontSize: 10,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Right Top Supporters (Arun)
          Column(
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildRankedAvatar(AppAssets.status5, 1, const Color(0xFFFFD700), showCrown: true),
                  const SizedBox(width: 4),
                  _buildRankedAvatar(AppAssets.status1, 2, const Color(0xFFC0C0C0)),
                  const SizedBox(width: 4),
                  _buildRankedAvatar(AppAssets.avatarMeena, 3, const Color(0xFFCD7F32)),
                ],
              ),
              const SizedBox(height: 2),
              const Text(
                'Top Supporters',
                style: TextStyle(color: Colors.white70, fontSize: 9, fontWeight: FontWeight.w500),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRankedAvatar(String asset, int rank, Color badgeColor, {bool showCrown = false}) {
    return Stack(
      clipBehavior: Clip.none,
      alignment: Alignment.center,
      children: [
        if (showCrown)
          const Positioned(
            top: -8,
            child: Text('👑', style: TextStyle(fontSize: 10)),
          ),
        Container(
          padding: const EdgeInsets.all(1.5),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: badgeColor, width: 1.2),
          ),
          child: CustomAvatar(radius: 13, assetPath: asset),
        ),
        Positioned(
          bottom: -4,
          child: Container(
            width: 13,
            height: 13,
            decoration: BoxDecoration(
              color: badgeColor,
              shape: BoxShape.circle,
              border: Border.all(color: Colors.black, width: 0.8),
            ),
            child: Center(
              child: Text(
                '$rank',
                style: const TextStyle(
                  color: Colors.black,
                  fontSize: 8,
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
  // 6. LIVE COMMENTS & RIGHT FLOATING HEARTS (Matching Image 4 Reference)
  // ===========================================================================
  Widget _buildLiveChatAndHeartsArea() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Stack(
        children: [
          // Comments Stream List
          Positioned.fill(
            right: 46,
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
                      CustomAvatar(radius: 11, assetPath: c.userAssetPath ?? AppAssets.status4),
                      const SizedBox(width: 7),
                      Expanded(
                        child: RichText(
                          text: TextSpan(
                            children: [
                              TextSpan(
                                text: '${c.userName} ',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 11.5,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              TextSpan(
                                text: c.message,
                                style: TextStyle(
                                  color: c.type == LiveCommentType.gift
                                      ? const Color(0xFFFFD54F)
                                      : Colors.white.withValues(alpha: 0.9),
                                  fontSize: 11,
                                  fontWeight: c.type == LiveCommentType.gift ? FontWeight.w600 : FontWeight.normal,
                                ),
                              ),
                            ],
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        DateFormat('hh:mm a').format(c.timestamp),
                        style: const TextStyle(color: Colors.white38, fontSize: 9),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),

          // Right Floating Pink Hearts Column
          Positioned(
            right: 0,
            top: 0,
            bottom: 0,
            width: 44,
            child: Stack(
              alignment: Alignment.bottomCenter,
              children: [
                // Ascending Hearts Stack
                ..._laneHearts.map((heart) => _LaneHeartWidget(key: ValueKey(heart.id), heart: heart)),

                // Bottom Interactive Hot-Pink Heart Button
                GestureDetector(
                  onTap: () {
                    _spawnLaneHeart();
                    _heartsKey.currentState?.addHeart(toLeft: true);
                  },
                  child: Container(
                    width: 38,
                    height: 38,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: Color(0x33FF2D78),
                      boxShadow: [
                        BoxShadow(color: Color(0x88FF2D78), blurRadius: 14, spreadRadius: 2),
                      ],
                    ),
                    child: const Center(
                      child: Icon(Icons.favorite_rounded, color: Color(0xFFFF2D78), size: 24),
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
  // 7. "NEW MESSAGES v" PILL (Matching Image 4 Reference)
  // ===========================================================================
  Widget _buildNewMessagesPill() {
    return GestureDetector(
      onTap: _scrollToBottom,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 3.5),
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
              style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w600),
            ),
            SizedBox(width: 4),
            Icon(Icons.keyboard_arrow_down_rounded, color: Color(0xFF82B1FF), size: 13),
          ],
        ),
      ),
    );
  }

  // ===========================================================================
  // 8. BOTTOM ACTION BAR (Matching Image 5 Reference)
  // ===========================================================================
  Widget _buildBottomActionBar(double bottomPadding) {
    return Container(
      padding: EdgeInsets.fromLTRB(8, 4, 8, max(bottomPadding, 8)),
      child: Row(
        children: [
          // 1. Star Button with Gold Border
          GestureDetector(
            onTap: () => _heartsKey.currentState?.addHeart(toLeft: true),
            child: Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xD012172A),
                border: Border.all(color: const Color(0xFFFFD54F), width: 1.3),
                boxShadow: const [
                  BoxShadow(color: Color(0x44FFD54F), blurRadius: 8),
                ],
              ),
              child: const Center(
                child: Icon(Icons.star_rounded, color: Color(0xFFFFD54F), size: 22),
              ),
            ),
          ),
          const SizedBox(width: 6),

          // 2. "Type a message..." Text Field with Smiley Emoji
          Expanded(
            child: GestureDetector(
              onTap: _openCommentInputModal,
              child: Container(
                height: 38,
                padding: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  color: const Color(0xBB121628),
                  borderRadius: BorderRadius.circular(19),
                  border: Border.all(color: Colors.white12),
                ),
                child: const Row(
                  children: [
                    Expanded(
                      child: Text(
                        'Type a message...',
                        style: TextStyle(color: Colors.white54, fontSize: 12),
                      ),
                    ),
                    Icon(Icons.sentiment_satisfied_alt_rounded, color: Colors.white54, size: 18),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(width: 6),

          // 3. Glowing Gift Button (Square with Neon Pink Border)
          GestureDetector(
            onTap: _openGiftSheet,
            child: Container(
              height: 38,
              padding: const EdgeInsets.symmetric(horizontal: 9),
              decoration: BoxDecoration(
                color: const Color(0xD0180F24),
                borderRadius: BorderRadius.circular(11),
                border: Border.all(color: const Color(0xFFFF2D78), width: 1.3),
                boxShadow: const [
                  BoxShadow(color: Color(0x66FF2D78), blurRadius: 8),
                ],
              ),
              child: const Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('🎁', style: TextStyle(fontSize: 14)),
                  Text(
                    'Gift',
                    style: TextStyle(color: Colors.white, fontSize: 8.5, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 6),

          // 4. Share Button
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
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xD012172A),
                border: Border.all(color: Colors.white12),
              ),
              child: const Center(
                child: Icon(Icons.share_rounded, color: Colors.white, size: 18),
              ),
            ),
          ),
          const SizedBox(width: 6),

          // 5. More Options Button (...)
          GestureDetector(
            onTap: () => LiveToolsBottomSheet.show(context),
            child: Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xD012172A),
                border: Border.all(color: Colors.white12),
              ),
              child: const Center(
                child: Icon(Icons.more_horiz_rounded, color: Colors.white, size: 18),
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

  _FloatingLaneHeart({
    required this.id,
    required this.size,
    required this.opacity,
    required this.horizontalOffset,
  });
}

class _LaneHeartWidget extends StatelessWidget {
  final _FloatingLaneHeart heart;

  const _LaneHeartWidget({super.key, required this.heart});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: 44.0 + (int.tryParse(heart.id.split('_').last) ?? 0) * 18.0,
        left: heart.horizontalOffset > 0 ? heart.horizontalOffset : 0,
        right: heart.horizontalOffset < 0 ? -heart.horizontalOffset : 0,
      ),
      child: Opacity(
        opacity: heart.opacity,
        child: Icon(
          Icons.favorite_rounded,
          color: const Color(0xFFFF2D78),
          size: heart.size,
        ),
      ),
    );
  }
}
