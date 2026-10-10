import 'dart:async';
import 'dart:math';
import 'dart:ui' show ImageFilter;

import 'package:flutter/foundation.dart' show ValueListenable;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

import '../../../../core/constants/app_assets.dart';
import '../../../../core/services/reel_video_manager.dart';
import '../../../../core/widgets/custom_avatar.dart';
import '../../../../core/widgets/live_video_player.dart';
import '../../../gift/gift.dart';
import '../../../live_stream/domain/models/gift_item.dart';
import '../../../live_stream/domain/models/live_comment.dart';
import '../../../live_stream/presentation/widgets/active_gift_animation_overlay.dart';
import '../../../live_stream/presentation/widgets/floating_hearts_overlay.dart';
import '../../../live_stream/presentation/widgets/gift_bottom_sheet.dart';
import '../../../live_stream/presentation/widgets/live_stream_viewers_sheet.dart';
import '../../../live_stream/presentation/widgets/viewer_profile_screen.dart';
import '../widgets/live_tools_bottom_sheet.dart';

/// Live PK battle between two hosts: split video, clash score bar, supporters,
/// live chat with rising hearts, and gifting. UI sections live in `widgets/pk_battle/`.
class PkBattleLiveScreen extends StatefulWidget {
  final VoidCallback? onBack;

  const PkBattleLiveScreen({super.key, this.onBack});

  @override
  State<PkBattleLiveScreen> createState() => _PkBattleLiveScreenState();
}

class _PkBattleLiveScreenState extends State<PkBattleLiveScreen> {
  static const int _maxComments = 100;

  final GlobalKey<ActiveGiftAnimationOverlayState> _giftOverlayKey = GlobalKey();
  final GlobalKey<FloatingHeartsOverlayState> _floatingHeartsKey = GlobalKey();
  final GlobalKey<_PkHeartsLaneState> _heartsLaneKey = GlobalKey();
  final ScrollController _chatScroll = ScrollController();
  final ValueNotifier<int> _secondsRemaining = ValueNotifier<int>(106); // 01:46

  final _PkHost _left = _PkDemoData.leftHost;
  _PkHost _right = _PkDemoData.rightHost;
  int _leftScore = 7556900;
  int _rightScore = 483400;
  _PkSettings _settings = const _PkSettings();
  bool _isBattleEnded = false;
  bool _isFollowingLeft = false;
  bool _isFollowingRight = false;
  _PkGiftEvent _leftGift = _PkDemoData.leftGift;
  _PkGiftEvent _rightGift = _PkDemoData.rightGift;
  int _giftSeq = 0;

  late List<LiveComment> _comments = _initialComments();
  int _commentPoolIndex = 0;
  Timer? _countdownTimer;
  Timer? _commentTimer;

  // ---------------------------------------------------------------------------
  // Lifecycle
  // ---------------------------------------------------------------------------

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      // Free hardware decoders used by the feed so the two PK streams play smoothly.
      ReelVideoManager.instance.pauseAll();
      _startCountdown();
      _commentTimer = Timer.periodic(const Duration(seconds: 3), (_) => _simulateAudienceComment());
    });
  }

  @override
  void dispose() {
    ReelVideoManager.instance.pauseAll();
    _countdownTimer?.cancel();
    _commentTimer?.cancel();
    _chatScroll.dispose();
    _secondsRemaining.dispose();
    super.dispose();
  }

  // ---------------------------------------------------------------------------
  // Battle state
  // ---------------------------------------------------------------------------

  void _startCountdown() {
    _countdownTimer?.cancel();
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (_secondsRemaining.value > 0) {
        _secondsRemaining.value--;
      } else if (!_isBattleEnded && _settings.autoEnd) {
        _endBattle();
      }
    });
  }

  void _endBattle() {
    _countdownTimer?.cancel();
    _giftOverlayKey.currentState?.clear();
    setState(() => _isBattleEnded = true);
  }

  /// Starts a fresh round, optionally against a new opponent.
  void _restartBattle({_PkHost? opponent}) {
    setState(() {
      if (opponent != null) _right = opponent;
      _leftScore = 12340;
      _rightScore = 9870;
      _isBattleEnded = false;
      _secondsRemaining.value = _settings.durationSeconds;
    });
    _startCountdown();
  }

  void _addScore({required bool toLeft, required int points}) {
    setState(() => toLeft ? _leftScore += points : _rightScore += points);
  }

  void _goBack() {
    if (widget.onBack != null) {
      widget.onBack!();
    } else {
      Navigator.of(context).maybePop();
    }
  }

  // ---------------------------------------------------------------------------
  // Chat
  // ---------------------------------------------------------------------------

  List<LiveComment> _initialComments() {
    final now = DateTime.now();
    LiveComment c(String id, String name, String avatar, String msg, int minute, {bool gift = true}) => LiveComment(
      id: id,
      userName: name,
      userAssetPath: avatar,
      message: msg,
      type: gift ? LiveCommentType.gift : LiveCommentType.chat,
      timestamp: DateTime(now.year, now.month, now.day, 10, minute),
    );

    return [
      c('init_1', 'Diya', AppAssets.status4, 'sent Rose 🌹 x 1', 21),
      c('init_2', 'Ananya', AppAssets.status3, 'sent Ocean Whale 🐳 x 1', 22),
      c('init_3', 'Sanjay', AppAssets.status5, 'sent Angel Vehicle 🏹 x 1', 23),
      c('init_4', 'Rahul', AppAssets.avatarSaran, 'sent Car 🚗 x 1', 24),
      c('init_5', 'Sneha', AppAssets.status3, 'Keep going ${_left.name}! ⭐', 25, gift: false),
    ];
  }

  void _addComment(LiveComment comment) {
    final next = [..._comments, comment];
    _comments = next.length > _maxComments ? next.sublist(next.length - _maxComments) : next;
  }

  void _scrollChatToLatest() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_chatScroll.hasClients) return;
      _chatScroll.animateTo(0, duration: const Duration(milliseconds: 250), curve: Curves.easeOut);
    });
  }

  void _simulateAudienceComment() {
    if (!mounted || _isBattleEnded) return;
    final pool = _PkDemoData.incomingComments;
    final (name, avatar, message, isGift) = pool[_commentPoolIndex++ % pool.length];

    setState(() {
      _addComment(
        LiveComment(
          id: 'comm_${DateTime.now().millisecondsSinceEpoch}',
          userName: name,
          userAssetPath: avatar,
          message: message,
          type: isGift ? LiveCommentType.gift : LiveCommentType.chat,
          timestamp: DateTime.now(),
        ),
      );
      _leftScore += isGift ? 120 : 35;
      _rightScore += isGift ? 90 : 25;
      if (isGift) _showAudienceGiftPill(name, avatar, message);
    });
    _scrollChatToLatest();
    // Audience gifts show as a pill on the video; full gift animations play only when the user sends one.
  }

  static final RegExp _giftMessage = RegExp(r'^sent (.+?) (\S+) x\s?(\d+)');

  /// Shows "Name · Sent Rose 🌹 x1" on a video; audience gifts alternate between the two hosts.
  void _showAudienceGiftPill(String sender, String avatar, String message) {
    final match = _giftMessage.firstMatch(message);
    if (match == null) return;
    final giftName = match.group(1)!;
    _setGiftPill(
      toLeft: _giftSeq.isEven,
      sender: sender,
      avatar: avatar,
      giftName: giftName,
      emoji: match.group(2)!,
      image: _PkDemoData.giftImages[giftName],
      count: int.parse(match.group(3)!),
    );
  }

  void _setGiftPill({
    required bool toLeft,
    required String sender,
    required String avatar,
    required String giftName,
    required String emoji,
    required int count,
    String? image,
  }) {
    final event = _PkGiftEvent(
      id: _giftSeq++,
      sender: sender,
      senderAvatar: avatar,
      giftName: giftName,
      emoji: emoji,
      giftImage: image,
      count: count,
    );
    toLeft ? _leftGift = event : _rightGift = event;
  }

  void _sendComment(String text) {
    setState(() {
      _addComment(
        LiveComment(
          id: 'user_${DateTime.now().millisecondsSinceEpoch}',
          userName: 'You',
          userAssetPath: AppAssets.status5,
          message: text,
          timestamp: DateTime.now(),
        ),
      );
      _leftScore += 25;
    });
    _scrollChatToLatest();
    _floatingHeartsKey.currentState
      ?..addHeart(toLeft: true)
      ..addHeart(toLeft: true);
  }

  // ---------------------------------------------------------------------------
  // Gifts & likes
  // ---------------------------------------------------------------------------

  void _openGiftSheet({String? recipient}) {
    final target = recipient ?? _left.name;
    GiftBottomSheet.show(
      context,
      (gift) => _sendGift(gift, 1, target),
      recipients: [_left.name, _right.name],
      initialRecipient: target,
      onGiftWithQuantitySelected: (gift, quantity) => _sendGift(gift, quantity, target),
      onGiftWithRecipientSelected: _sendGift,
    );
  }

  void _sendGift(GiftItem gift, int quantity, String recipient) {
    final toLeft = recipient == _left.name;
    setState(() {
      toLeft ? _leftScore += gift.diamonds * 15 * quantity : _rightScore += gift.diamonds * 15 * quantity;
      _addComment(
        LiveComment(
          id: 'gift_${DateTime.now().millisecondsSinceEpoch}',
          userName: 'You',
          userAssetPath: AppAssets.status5,
          message: 'sent ${gift.name} ${gift.icon} x $quantity to $recipient',
          type: LiveCommentType.gift,
          timestamp: DateTime.now(),
        ),
      );
      _setGiftPill(
        toLeft: toLeft,
        sender: 'You',
        avatar: AppAssets.status5,
        giftName: gift.name,
        emoji: gift.icon,
        image: gift.imageAssetPath,
        count: quantity,
      );
    });
    _scrollChatToLatest();
    _giftOverlayKey.currentState?.playGift(
      gift,
      senderName: 'You',
      count: quantity,
      toLeft: toLeft,
      recipient: recipient,
    );
    // Hearts fly on the side of the host that received the gift.
    _floatingHeartsKey.currentState?.addHeart(toLeft: toLeft);
  }

  /// Double-tap on a stream likes that host.
  void _onArenaDoubleTap(TapDownDetails details, double width) {
    final toLeft = details.localPosition.dx < width / 2;
    _addScore(toLeft: toLeft, points: 50);
    _floatingHeartsKey.currentState?.addHeart(toLeft: toLeft);
    if (toLeft) _heartsLaneKey.currentState?.spawn(speed: 1.2);
  }

  /// Heart button / Like tile: burst of rising hearts and a small score boost.
  void _onLike() {
    _heartsLaneKey.currentState?.burst();
    _addScore(toLeft: true, points: 20);
    _floatingHeartsKey.currentState?.addHeart(toLeft: true);
  }

  // ---------------------------------------------------------------------------
  // Header actions
  // ---------------------------------------------------------------------------

  void _toggleFollow(bool isLeft) {
    setState(() => isLeft ? _isFollowingLeft = !_isFollowingLeft : _isFollowingRight = !_isFollowingRight);
    final host = isLeft ? _left : _right;
    final following = isLeft ? _isFollowingLeft : _isFollowingRight;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(following ? 'Now following ${host.name} ${isLeft ? '❤️' : '💙'}' : 'Unfollowed ${host.name}'),
        duration: const Duration(seconds: 1),
        backgroundColor: _PkColors.side(isLeft),
      ),
    );
  }

  void _openHostProfile(bool isLeft) {
    final host = isLeft ? _left : _right;
    ViewerProfileScreen.open(
      context,
      userName: host.name,
      avatarAsset: host.avatarAsset,
      handle: host.handle.isEmpty ? null : host.handle,
      bio: host.bio.isEmpty ? null : host.bio,
      followersCount: host.likes,
    );
  }

  // ---------------------------------------------------------------------------
  // Sheets
  // ---------------------------------------------------------------------------

  void _openPkSettings() {
    _PkSheets.showSettings(
      context,
      current: _settings,
      onSave: (settings) {
        setState(() => _settings = settings);
        _secondsRemaining.value = settings.durationSeconds;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('⏱️ PK Duration set to ${settings.durationSeconds ~/ 60} min!'),
            backgroundColor: const Color(0xFFFFD600),
            duration: const Duration(seconds: 2),
          ),
        );
      },
    );
  }

  void _openMatchFlow() {
    _PkMatchFlow(
      context: context,
      host: _left,
      onOpenSettings: _openPkSettings,
      onMatched: (rival) {
        _restartBattle(
          opponent: _right.copyWith(
            name: rival.name,
            avatarAsset: rival.avatarAsset,
            videoAsset: rival.videoAsset,
            likes: rival.viewers,
            viewers: rival.viewers,
          ),
        );
        _PkSheets.showBanner(
          context,
          title: '⚔️ PK Live Started!',
          message: 'Compete, send gifts & enjoy the battle!',
          icon: Icons.flash_on_rounded,
          color: const Color(0xFFFFD600),
        );
      },
    ).start();
  }

  void _openLiveTools() {
    LiveToolsBottomSheet.show(
      context,
      onPkSettingsTap: _openPkSettings,
      onInviteTap: _openMatchFlow,
      onGuestsTap: _openMatchFlow,
      onRankingTap: () => _PkSheets.showMoreOptions(context, onSettings: _openPkSettings, onPreviewWinner: _endBattle),
    );
  }

  // ---------------------------------------------------------------------------
  // Build
  // ---------------------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    // Size the video from the height left after the status / navigation bars.
    final padding = MediaQuery.paddingOf(context);
    final usableHeight = MediaQuery.sizeOf(context).height - padding.top - padding.bottom;
    final videoHeight = (usableHeight * 0.36).clamp(220.0, 400.0);
    final leftWins = _leftScore >= _rightScore;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: ActiveGiftAnimationOverlay(
        key: _giftOverlayKey,
        isSuppressed: _isBattleEnded,
        showTopBanner: false,
        onScoreImpact: ({required toLeft, required points}) {
          _addScore(toLeft: toLeft, points: points);
        },
        child: FloatingHeartsOverlay(
          key: _floatingHeartsKey,
          alignLeft: true,
          child: Scaffold(
            resizeToAvoidBottomInset: false,
            backgroundColor: _PkColors.background,
            body: DecoratedBox(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [_PkColors.backgroundTop, _PkColors.background],
                ),
              ),
              child: Stack(
                children: [
                  SafeArea(
                    bottom: false,
                    child: Column(
                      children: [
                        _PkHeader(
                          isFollowingLeft: _isFollowingLeft,
                          isFollowingRight: _isFollowingRight,
                          onBack: _goBack,
                          onEmblemTap: _openMatchFlow,
                          onFollowTap: _toggleFollow,
                          onHostTap: _openHostProfile,
                        ),
                        _PkTeamRow(
                          left: _left,
                          right: _right,
                          secondsRemaining: _secondsRemaining,
                          onTeamTap: () => LiveStreamViewersSheet.show(context),
                          onTimerTap: _openPkSettings,
                        ),
                        SizedBox(
                          height: videoHeight,
                          child: LayoutBuilder(
                            builder: (context, constraints) => GestureDetector(
                              onDoubleTapDown: (d) => _onArenaDoubleTap(d, constraints.maxWidth),
                              child: _PkVideoArena(
                                left: _left,
                                right: _right,
                                leftGift: _leftGift,
                                rightGift: _rightGift,
                              ),
                            ),
                          ),
                        ),
                        _PkScoreBar(
                          leftScore: _leftScore,
                          rightScore: _rightScore,
                          onLeftGiftTap: () => _openGiftSheet(recipient: _left.name),
                          onRightGiftTap: () => _openGiftSheet(recipient: _right.name),
                        ),
                        // Full command section on one background down to the screen edge.
                        Expanded(
                          child: _PkLowerSection(
                            commandList: _PkCommandList(
                              comments: _comments,
                              controller: _chatScroll,
                              onLiveTap: _scrollChatToLatest,
                            ),
                            rightColumn: _PkRightColumn(
                              hearts: _PkHeartsLane(key: _heartsLaneKey, ambient: !_isBattleEnded),
                              onGift: _openGiftSheet,
                              onLike: _onLike,
                              onShare: () => _PkSheets.showShare(context),
                            ),
                            inputBar: _PkInputBar(
                              onEmojiTap: () => _PkSheets.showMessageInput(context, onSend: _sendComment),
                              onMessageTap: () => _PkSheets.showMessageInput(context, onSend: _sendComment),
                              onMoreTap: _openLiveTools,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (_isBattleEnded)
                    _PkWinnerOverlay(
                      winner: leftWins ? _left : _right,
                      winnerScore: leftWins ? _leftScore : _rightScore,
                      loserScore: leftWins ? _rightScore : _leftScore,
                      onPlayAgain: _restartBattle,
                      onBackToLive: _goBack,
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// =============================================================================
// THEME
// =============================================================================

/// Design tokens for the PK Battle screen (dark navy + neon pink / blue).
class _PkColors {
  _PkColors._();

  static const Color background = Color(0xFF070A18);
  static const Color backgroundTop = Color(0xFF0B1434);
  static const Color surface = Color(0xE60E1428);
  static const Color stroke = Color(0xFF2A3355);

  static const Color pink = Color(0xFFFF2D78);
  static const Color blue = Color(0xFF1E88FF);
  static const Color cyan = Color(0xFF00C6FF);
  static const Color gold = Color(0xFFFFD54A);

  static const Color textPrimary = Colors.white;
  static const Color textSecondary = Color(0xFFB0BBD8);

  /// Accent for a side of the battle: left host is pink, right host is blue.
  static Color side(bool isLeft) => isLeft ? pink : blue;
}

/// Shared decorations so every card on the screen has the same neon-glass look.
class _PkDecor {
  _PkDecor._();

  static BoxDecoration glass({
    Color border = _PkColors.stroke,
    double radius = 16,
    double borderWidth = 1,
    double glow = 0,
    Color color = _PkColors.surface,
  }) {
    return BoxDecoration(
      color: color,
      borderRadius: BorderRadius.circular(radius),
      border: Border.all(color: border, width: borderWidth),
      boxShadow: glow > 0 ? [BoxShadow(color: border.withValues(alpha: 0.45), blurRadius: glow)] : null,
    );
  }
}

// =============================================================================
// DATA MODELS & DEMO DATA
// =============================================================================

/// One side of the PK battle.
class _PkHost {
  final String name;
  final String handle;
  final String bio;
  final String avatarAsset;
  final String videoAsset;
  final String likes;
  final String viewers;
  final String teamMembers;
  final List<String> teamAvatars;

  const _PkHost({
    required this.name,
    required this.avatarAsset,
    required this.videoAsset,
    required this.likes,
    required this.viewers,
    required this.teamMembers,
    required this.teamAvatars,
    this.handle = '',
    this.bio = '',
  });

  String get teamName => 'Team $name';

  _PkHost copyWith({String? name, String? avatarAsset, String? videoAsset, String? likes, String? viewers}) {
    return _PkHost(
      name: name ?? this.name,
      avatarAsset: avatarAsset ?? this.avatarAsset,
      videoAsset: videoAsset ?? this.videoAsset,
      likes: likes ?? this.likes,
      viewers: viewers ?? this.viewers,
      teamMembers: teamMembers,
      teamAvatars: teamAvatars,
      handle: name != null ? '@${name.toLowerCase()}' : handle,
      bio: name != null ? '' : bio,
    );
  }
}

/// Latest gift shown as a pill at the bottom of a host's video (from features/gift).
typedef _PkGiftEvent = PkGiftEvent;


/// User-configurable PK options (PK Settings sheet).
class _PkSettings {
  final int durationSeconds;
  final bool countdownDisplay;
  final bool showTimerToAudience;
  final bool autoEnd;

  const _PkSettings({
    this.durationSeconds = 300,
    this.countdownDisplay = true,
    this.showTimerToAudience = true,
    this.autoEnd = true,
  });
}

/// Demo data for the PK battle screen.
class _PkDemoData {
  _PkDemoData._();

  static const _PkHost leftHost = _PkHost(
    name: 'Neha',
    handle: '@neha_official',
    bio: '✨ Official PK Host | Singer & Creator ✨',
    avatarAsset: AppAssets.status4,
    videoAsset: AppAssets.video2,
    likes: '125.4K',
    viewers: '8.4K',
    teamMembers: '1.2K Members',
    teamAvatars: [AppAssets.status1, AppAssets.status3],
  );

  static const _PkHost rightHost = _PkHost(
    name: 'Arun',
    handle: '@arun_official',
    bio: '⚡ PK Warrior | Let the best team win! ⚡',
    avatarAsset: AppAssets.status5,
    videoAsset: AppAssets.video1,
    likes: '98.2K',
    viewers: '1.2K',
    teamMembers: '980 Members',
    teamAvatars: [AppAssets.status2, AppAssets.status4],
  );

  /// Viewers shown with a crown and highlighted message in the Command List.
  static const Set<String> vipNames = {'Sneha', 'Shena'};

  static const _PkGiftEvent leftGift = _PkGiftEvent(
    id: -1,
    sender: 'Riya',
    senderAvatar: AppAssets.status4,
    giftName: 'Rose',
    emoji: '🌹',
    giftImage: AppAssets.giftRose,
    count: 1,
  );

  static const _PkGiftEvent rightGift = _PkGiftEvent(
    id: -2,
    sender: 'Karthik',
    senderAvatar: AppAssets.avatarKarthik,
    giftName: 'Galaxy',
    emoji: '🔮',
    count: 5,
  );

  /// Sticker artwork for gifts mentioned in simulated chat messages.
  static const Map<String, String> giftImages = PKBattleGiftData.giftImages;

  /// Rotating pool of simulated audience messages: (name, avatar, message, isGift).
  static const List<(String, String, String, bool)> incomingComments = PKBattleGiftData.incomingComments;
}

// =============================================================================
// HEADER: PKtop banner + back arrow
// =============================================================================

/// Full-width "Neha · PK BATTLE · Arun" banner (assets/PKtop.png) with the back
/// arrow in the top-left corner. Avatars, Follow buttons and the PK emblem in
/// the artwork stay tappable through invisible hit areas.
class _PkHeader extends StatelessWidget {
  final bool isFollowingLeft;
  final bool isFollowingRight;
  final VoidCallback onBack;
  final VoidCallback onEmblemTap;
  final ValueChanged<bool> onFollowTap; // true = left host
  final ValueChanged<bool> onHostTap; // true = left host

  const _PkHeader({
    required this.isFollowingLeft,
    required this.isFollowingRight,
    required this.onBack,
    required this.onEmblemTap,
    required this.onFollowTap,
    required this.onHostTap,
  });

  // Artwork is 1536×1024. We show the band y = 170…700 (crown + cards + BATTLE)
  // at 90% of the screen width, centred.
  static const double _imgW = 1536;
  static const double _imgH = 1024;
  static const double _cropTop = 170;
  static const double _cropHeight = 530;
  static const double _widthFactor = 0.8;
  static const double _alignY = 2 * _cropTop / (_imgH - _cropHeight) - 1;

  // Hit areas in artwork pixels.
  static const _leftAvatar = Rect.fromLTRB(46, 371, 270, 595);
  static const _rightAvatar = Rect.fromLTRB(1266, 380, 1490, 604);
  static const _leftFollow = Rect.fromLTRB(258, 553, 526, 640);
  static const _rightFollow = Rect.fromLTRB(1002, 560, 1278, 648);
  static const _emblem = Rect.fromLTRB(560, 200, 975, 660);

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final bannerWidth = width * _widthFactor;
        final left = (width - bannerWidth) / 2;
        final scale = bannerWidth / _imgW;

        Widget hitArea(Rect r, VoidCallback onTap, String label, {Widget? child}) {
          return Positioned(
            left: left + r.left * scale,
            top: (r.top - _cropTop) * scale,
            width: r.width * scale,
            height: r.height * scale,
            child: Semantics(
              button: true,
              label: label,
              child: GestureDetector(behavior: HitTestBehavior.opaque, onTap: onTap, child: child),
            ),
          );
        }

        return SizedBox(
          width: width,
          height: _cropHeight * scale,
          child: Stack(
            children: [
              Positioned(
                left: left,
                width: bannerWidth,
                top: 0,
                bottom: 0,
                child: ShaderMask(
                  // Soft fade at the bottom so the banner melts into the background.
                  blendMode: BlendMode.dstIn,
                  shaderCallback: const LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Colors.white, Colors.white, Colors.transparent],
                    stops: [0, 0.92, 1],
                  ).createShader,
                  child: Image.asset(
                    AppAssets.pkTopBanner,
                    fit: BoxFit.cover,
                    alignment: const Alignment(0, _alignY),
                    filterQuality: FilterQuality.medium,
                  ),
                ),
              ),
              hitArea(_emblem, onEmblemTap, 'Start PK battle'),
              hitArea(_leftAvatar, () => onHostTap(true), 'Open left host profile'),
              hitArea(_rightAvatar, () => onHostTap(false), 'Open right host profile'),
              hitArea(
                _leftFollow,
                () => onFollowTap(true),
                'Follow left host',
                child: isFollowingLeft ? const _FollowingChip(isLeft: true) : null,
              ),
              hitArea(
                _rightFollow,
                () => onFollowTap(false),
                'Follow right host',
                child: isFollowingRight ? const _FollowingChip(isLeft: false) : null,
              ),
              Positioned(left: 8, top: 2, child: _BackButton(onTap: onBack)),
            ],
          ),
        );
      },
    );
  }
}

class _BackButton extends StatelessWidget {
  final VoidCallback onTap;
  const _BackButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: 'Back',
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: const Color(0x66070A18),
            border: Border.all(color: Colors.white.withValues(alpha: 0.35)),
          ),
          child: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 15),
        ),
      ),
    );
  }
}

/// Drawn over the artwork's Follow button once the user follows that host.
class _FollowingChip extends StatelessWidget {
  final bool isLeft;
  const _FollowingChip({required this.isLeft});

  @override
  Widget build(BuildContext context) {
    final accent = _PkColors.side(isLeft);
    return Container(
      alignment: Alignment.center,
      padding: const EdgeInsets.symmetric(horizontal: 6),
      decoration: BoxDecoration(
        color: const Color(0xFF141A33),
        borderRadius: BorderRadius.circular(40),
        border: Border.all(color: accent, width: 1.2),
        boxShadow: [BoxShadow(color: accent.withValues(alpha: 0.45), blurRadius: 8)],
      ),
      child: const FittedBox(
        child: Text(
          'Following',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700),
        ),
      ),
    );
  }
}

// =============================================================================
// TEAM ROW + BATTLE TIMER
// =============================================================================

/// Second row: [Team Left]  [Battle Time 01:46]  [Team Right]
class _PkTeamRow extends StatelessWidget {
  final _PkHost left;
  final _PkHost right;
  final ValueListenable<int> secondsRemaining;
  final VoidCallback onTeamTap;
  final VoidCallback onTimerTap;

  const _PkTeamRow({
    required this.left,
    required this.right,
    required this.secondsRemaining,
    required this.onTeamTap,
    required this.onTimerTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 0, 12, 5),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: _TeamCard(host: left, isLeft: true, onTap: onTeamTap),
          ),
          const SizedBox(width: 6),
          _BattleTimer(secondsRemaining: secondsRemaining, onTap: onTimerTap),
          const SizedBox(width: 6),
          Expanded(
            child: _TeamCard(host: right, isLeft: false, onTap: onTeamTap),
          ),
        ],
      ),
    );
  }
}

class _TeamCard extends StatelessWidget {
  final _PkHost host;
  final bool isLeft;
  final VoidCallback onTap;

  const _TeamCard({required this.host, required this.isLeft, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: _PkDecor.glass(
          border: _PkColors.side(isLeft).withValues(alpha: 0.85),
          radius: 14,
          borderWidth: 1.2,
          glow: 8,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Flexible(
                  child: Text(
                    host.teamName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(color: _PkColors.textPrimary, fontSize: 11.5, fontWeight: FontWeight.w800),
                  ),
                ),
                const SizedBox(width: 4),
                const _PkGoldCrown(size: 11),
              ],
            ),
            const SizedBox(height: 3),
            Row(
              children: [
                _PkAvatarPair(assets: host.teamAvatars),
                const SizedBox(width: 5),
                Flexible(
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: Alignment.centerLeft,
                    child: Text(
                      host.teamMembers,
                      maxLines: 1,
                      style: const TextStyle(
                        color: _PkColors.textSecondary,
                        fontSize: 9.5,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _BattleTimer extends StatelessWidget {
  final ValueListenable<int> secondsRemaining;
  final VoidCallback onTap;

  const _BattleTimer({required this.secondsRemaining, required this.onTap});

  static String format(int totalSeconds) {
    final m = (totalSeconds ~/ 60).toString().padLeft(2, '0');
    final s = (totalSeconds % 60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
        decoration: _PkDecor.glass(
          border: _PkColors.cyan.withValues(alpha: 0.8),
          radius: 14,
          borderWidth: 1.3,
          glow: 10,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.access_time_rounded, color: Colors.white70, size: 9),
                SizedBox(width: 4),
                Text(
                  'Battle Time',
                  style: TextStyle(color: Colors.white70, fontSize: 9.5, fontWeight: FontWeight.w500),
                ),
              ],
            ),
            ValueListenableBuilder<int>(
              valueListenable: secondsRemaining,
              builder: (_, remaining, _) => Text(
                format(remaining),
                style: TextStyle(
                  color: remaining <= 10 ? const Color(0xFFFF5252) : Colors.white,
                  fontSize: 15.5,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.8,
                  fontFeatures: const [FontFeature.tabularFigures()],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// =============================================================================
// SPLIT VIDEO ARENA + VS BADGE
// =============================================================================

/// Split live video: left host | plasma seam + VS badge | right host.
class _PkVideoArena extends StatefulWidget {
  final _PkHost left;
  final _PkHost right;
  final _PkGiftEvent leftGift;
  final _PkGiftEvent rightGift;

  const _PkVideoArena({required this.left, required this.right, required this.leftGift, required this.rightGift});

  @override
  State<_PkVideoArena> createState() => _PkVideoArenaState();
}

class _PkVideoArenaState extends State<_PkVideoArena> with SingleTickerProviderStateMixin {
  static const double _radius = 18;

  late final AnimationController _energy = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1400),
  )..repeat();

  @override
  void dispose() {
    _energy.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Stack(
        fit: StackFit.expand,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(_radius),
            child: ColoredBox(
              color: Colors.black,
              child: Row(
                children: [
                  Expanded(
                    child: _StreamTile(
                      host: widget.left,
                      gift: widget.leftGift,
                      isLeft: true,
                      playerId: 'pk_left_stream',
                    ),
                  ),
                  Expanded(
                    child: _StreamTile(
                      host: widget.right,
                      gift: widget.rightGift,
                      isLeft: false,
                      playerId: 'pk_right_stream',
                    ),
                  ),
                ],
              ),
            ),
          ),
          IgnorePointer(
            child: RepaintBoundary(
              child: CustomPaint(
                painter: _PkVideoAuraPainter(animation: _energy, radius: _radius),
              ),
            ),
          ),
          IgnorePointer(
            child: RepaintBoundary(
              child: CustomPaint(painter: _PkPlasmaSeamPainter(animation: _energy)),
            ),
          ),
          LayoutBuilder(
            builder: (context, c) {
              // ~21% of the arena width, never taller than the arena.
              final w = (c.maxWidth * 0.21).clamp(70.0, 104.0);
              final fitted = w / _VsBadge.aspectRatio > c.maxHeight * 0.85
                  ? c.maxHeight * 0.85 * _VsBadge.aspectRatio
                  : w;
              return Center(
                child: _VsBadge(animation: _energy, width: fitted),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _StreamTile extends StatelessWidget {
  final _PkHost host;
  final _PkGiftEvent gift;
  final bool isLeft;
  final String playerId;

  const _StreamTile({required this.host, required this.gift, required this.isLeft, required this.playerId});

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        LiveVideoPlayer(
          key: ValueKey('${playerId}_${host.videoAsset}'),
          playerId: playerId,
          videoAssetPath: host.videoAsset,
          placeholderAssetPath: host.avatarAsset,
          fit: BoxFit.cover,
          autoPlay: true,
          isMuted: true,
          showSoundToggle: false,
        ),
        // Top vignette so the badges stay readable on bright video.
        const Positioned(
          top: 0,
          left: 0,
          right: 0,
          height: 56,
          child: DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Color(0xB3000000), Colors.transparent],
              ),
            ),
          ),
        ),
        Positioned(top: 10, left: 10, child: _ViewerBadge(count: host.viewers)),
        Positioned(top: 10, right: 12, child: _LiveBadge(isLeft: isLeft)),
        Positioned(
          left: 8,
          right: 8,
          bottom: 10,
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 350),
            transitionBuilder: (child, anim) => FadeTransition(
              opacity: anim,
              child: SlideTransition(
                position: Tween(begin: const Offset(0, 0.4), end: Offset.zero).animate(anim),
                child: child,
              ),
            ),
            child: PkGiftPill(key: ValueKey(gift.id), gift: gift),
          ),
        ),
      ],
    );
  }
}

class _ViewerBadge extends StatelessWidget {
  final String count;
  const _ViewerBadge({required this.count});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.55),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withValues(alpha: 0.12)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('🔥', style: TextStyle(fontSize: 11)),
          const SizedBox(width: 3),
          Text(
            count,
            style: const TextStyle(color: Colors.white, fontSize: 11.5, fontWeight: FontWeight.w800),
          ),
        ],
      ),
    );
  }
}

class _LiveBadge extends StatelessWidget {
  final bool isLeft;
  const _LiveBadge({required this.isLeft});

  @override
  Widget build(BuildContext context) {
    final color = isLeft ? const Color(0xFFFF1F5A) : const Color(0xFF1E6BFF);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 3.5),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: color.withValues(alpha: 0.6), blurRadius: 8)],
      ),
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircleAvatar(radius: 2.5, backgroundColor: Colors.white),
          SizedBox(width: 4),
          Text(
            'LIVE',
            style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w800, letterSpacing: 0.6),
          ),
        ],
      ),
    );
  }
}



/// VS emblem artwork (assets/VS.png) with a gentle pulse.
class _VsBadge extends StatelessWidget {
  final Animation<double> animation;
  final double width;
  const _VsBadge({required this.animation, required this.width});

  /// Width / height of the VS.png artwork.
  static const double aspectRatio = 420 / 664;

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: AnimatedBuilder(
        animation: animation,
        builder: (context, child) => Transform.scale(scale: 1 + 0.035 * sin(animation.value * 2 * pi), child: child),
        child: Image.asset(
          AppAssets.pkVsEmblem,
          width: width,
          height: width / aspectRatio,
          fit: BoxFit.contain,
          filterQuality: FilterQuality.medium,
        ),
      ),
    );
  }
}

// =============================================================================
// SCORE BAR
// =============================================================================

/// Pink vs blue clash bar with 3D gift boxes on both ends.
/// The split follows the live scores, clamped so neither side disappears.
class _PkScoreBar extends StatelessWidget {
  final int leftScore;
  final int rightScore;
  final VoidCallback? onLeftGiftTap;
  final VoidCallback? onRightGiftTap;

  const _PkScoreBar({
    required this.leftScore,
    required this.rightScore,
    this.onLeftGiftTap,
    this.onRightGiftTap,
  });

  static final NumberFormat _format = NumberFormat('#,###');

  static const _scoreStyle = TextStyle(
    color: Colors.white,
    fontSize: 18,
    fontWeight: FontWeight.w800,
    letterSpacing: 0.3,
    shadows: [Shadow(color: Colors.black87, blurRadius: 4, offset: Offset(0, 1.5))],
  );

  @override
  Widget build(BuildContext context) {
    final total = leftScore + rightScore;
    final ratio = total == 0 ? 0.5 : (leftScore / total).clamp(0.35, 0.62);

    return Padding(
      padding: const EdgeInsets.fromLTRB(18, 14, 18, 6),
      child: SizedBox(
        height: 32,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: const [
                    BoxShadow(color: Color(0x80FF0055), blurRadius: 10, offset: Offset(-2, 1.5)),
                    BoxShadow(color: Color(0x8000E5FF), blurRadius: 10, offset: Offset(2, 1.5)),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: TweenAnimationBuilder<double>(
                    tween: Tween(end: ratio.toDouble()),
                    duration: const Duration(milliseconds: 450),
                    curve: Curves.easeOutCubic,
                    builder: (_, value, _) => CustomPaint(painter: _PkScoreBarPainter(leftRatio: value)),
                  ),
                ),
              ),
            ),
            Positioned.fill(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 44),
                child: Row(
                  children: [
                    Expanded(
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        alignment: Alignment.centerLeft,
                        child: Text(_format.format(leftScore), style: _scoreStyle),
                      ),
                    ),
                    const SizedBox(width: 24),
                    Expanded(
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        alignment: Alignment.centerRight,
                        child: Text(_format.format(rightScore), style: _scoreStyle),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Positioned(
              left: -14,
              top: -16,
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: onLeftGiftTap,
                child: Image.asset(AppAssets.pkGiftRed, width: 54, height: 54),
              ),
            ),
            Positioned(
              right: -14,
              top: -16,
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: onRightGiftTap,
                child: Image.asset(AppAssets.pkGiftBlue, width: 54, height: 54),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// =============================================================================
// FLOATING HEARTS LANE
// =============================================================================

/// Vertical lane of rising pink hearts (triggered by the heart button / Like tile).
/// Owns its own animation state so the rest of the screen doesn't rebuild per heart.
class _PkHeartsLane extends StatefulWidget {
  final bool ambient;

  const _PkHeartsLane({super.key, this.ambient = true});

  @override
  State<_PkHeartsLane> createState() => _PkHeartsLaneState();
}

class _PkHeartsLaneState extends State<_PkHeartsLane> with TickerProviderStateMixin {
  static const int _maxHearts = 24;
  static const List<Color> _colors = [
    Color(0xFFFF2D6F),
    Color(0xFFFF2D55),
    Color(0xFFFF4081),
    Color(0xFFFF6584),
    Color(0xFFFF1744),
    Color(0xFFFF80AB),
  ];

  final List<_Heart> _hearts = [];
  final Random _random = Random();
  Timer? _ambientTimer;

  @override
  void initState() {
    super.initState();
    _syncAmbient();
  }

  @override
  void didUpdateWidget(covariant _PkHeartsLane oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.ambient != widget.ambient) _syncAmbient();
  }

  void _syncAmbient() {
    _ambientTimer?.cancel();
    if (!widget.ambient) return;
    _ambientTimer = Timer.periodic(const Duration(milliseconds: 550), (_) {
      if (_hearts.length < 14) spawn();
    });
  }

  /// Adds one rising heart. Higher [speed] = faster rise.
  void spawn({double speed = 1.0}) {
    if (!mounted) return;
    if (_hearts.length >= _maxHearts) {
      _hearts.removeAt(0).controller.dispose();
    }

    final controller = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: (2800 / speed).round().clamp(1600, 3600)),
    );
    final heart = _Heart(
      controller: controller,
      startX: _random.nextDouble() * 10 - 5,
      size: 22 + _random.nextDouble() * 8,
      color: _colors[_random.nextInt(_colors.length)],
      sway: (_random.nextDouble() * 2 - 1) * 8,
    );

    setState(() => _hearts.add(heart));
    controller.forward().whenComplete(() {
      if (!mounted) return;
      setState(() => _hearts.remove(heart));
      controller.dispose();
    });
  }

  /// Short staggered burst of hearts (heart button, Like tile).
  void burst() {
    for (var i = 0; i < 5; i++) {
      Future.delayed(Duration(milliseconds: i * 60), () => spawn(speed: 1.25 - i * 0.1));
    }
  }

  @override
  void dispose() {
    _ambientTimer?.cancel();
    for (final h in _hearts) {
      h.controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Stack(
        clipBehavior: Clip.none,
        children: [for (final h in _hearts) _RisingHeart(heart: h)],
      ),
    );
  }
}

class _RisingHeart extends StatelessWidget {
  final _Heart heart;
  const _RisingHeart({required this.heart});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: heart.controller,
      builder: (context, child) {
        final t = heart.controller.value;
        return Positioned(
          bottom: 4 + t * 260,
          left: 8 + heart.startX + sin(t * 2 * pi) * heart.sway,
          child: Opacity(
            opacity: (1 - t * 0.92).clamp(0.0, 1.0),
            child: Transform.scale(scale: 0.8 + t * 0.45, child: child),
          ),
        );
      },
      child: Icon(
        Icons.favorite_rounded,
        color: heart.color,
        size: heart.size,
        shadows: [Shadow(color: heart.color.withValues(alpha: 0.75), blurRadius: 12)],
      ),
    );
  }
}

class _Heart {
  final AnimationController controller;
  final double startX;
  final double size;
  final Color color;
  final double sway;

  _Heart({required this.controller, required this.startX, required this.size, required this.color, required this.sway});
}

// =============================================================================
// COMMAND SECTION: pills, Command List, Gift card, side buttons, input bar
// =============================================================================

/// Full-width bottom area on one background that runs to the screen edge:
///   [Command List ...............] [Gift card | ♥ Like | ↪ Share]
///   [😊] [Type a message...] [•••]
class _PkLowerSection extends StatelessWidget {
  final Widget commandList;
  final Widget rightColumn;
  final Widget inputBar;

  const _PkLowerSection({required this.commandList, required this.rightColumn, required this.inputBar});

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.paddingOf(context).bottom;
    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(10, 10, 10, 8 + bottomInset),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xF0121638), Color(0xFF0B0E2A), Color(0xFF080A1E)],
        ),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(26)),
        border: Border.all(color: const Color(0x557C5CFF)),
        boxShadow: const [BoxShadow(color: Color(0x447C5CFF), blurRadius: 24, offset: Offset(0, -4))],
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final rightWidth = (constraints.maxWidth * 0.27).clamp(92.0, 130.0);
          return Column(
            children: [
              Expanded(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Expanded(child: commandList),
                    const SizedBox(width: 8),
                    SizedBox(width: rightWidth, child: rightColumn),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              inputBar,
            ],
          );
        },
      ),
    );
  }
}

/// Neon-outlined container used by the pills, panels and input bar.
class _NeonBox extends StatelessWidget {
  final Widget child;
  final double radius;
  final List<Color> borderColors;
  final Color glow;
  final EdgeInsetsGeometry padding;
  final double? height;

  const _NeonBox({
    required this.child,
    this.radius = 20,
    this.borderColors = const [Color(0xFF7C5CFF), Color(0xFF2E9BFF)],
    this.glow = const Color(0x447C5CFF),
    this.padding = EdgeInsets.zero,
    this.height,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      padding: const EdgeInsets.all(1.2),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(radius),
        gradient: LinearGradient(colors: borderColors),
        boxShadow: [BoxShadow(color: glow, blurRadius: 12)],
      ),
      child: Container(
        padding: padding,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(radius - 1.2),
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF121A46), Color(0xFF0B1030)],
          ),
        ),
        child: child,
      ),
    );
  }
}

/// "Command List" panel: header with a Live pill, then comments (newest at the bottom).
class _PkCommandList extends StatelessWidget {
  final List<LiveComment> comments;
  final ScrollController controller;
  final VoidCallback onLiveTap;

  const _PkCommandList({required this.comments, required this.controller, required this.onLiveTap});

  @override
  Widget build(BuildContext context) {
    return _NeonBox(
      radius: 22,
      borderColors: const [Color(0xFF4A63FF), Color(0xFF7C5CFF), Color(0xFF2E9BFF)],
      glow: const Color(0x334A63FF),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(21),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 8, 8, 8),
              child: Row(
                children: [
                  const _GradientIcon(Icons.sms_outlined, size: 22, colors: [Color(0xFF9FD8FF), Color(0xFF6C7BFF)]),
                  const SizedBox(width: 8),
                  const Expanded(
                    child: Text(
                      'Command List',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(color: Colors.white, fontSize: 15.5, fontWeight: FontWeight.w700),
                    ),
                  ),
                  _LivePill(onTap: onLiveTap),
                ],
              ),
            ),
            Container(height: 1, color: Colors.white.withValues(alpha: 0.08)),
            Expanded(
              child: ListView.separated(
                controller: controller,
                reverse: true,
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(10, 2, 10, 2),
                itemCount: comments.length,
                separatorBuilder: (_, _) => Padding(
                  padding: const EdgeInsets.only(left: 46),
                  child: Container(height: 1, color: Colors.white.withValues(alpha: 0.06)),
                ),
                itemBuilder: (_, index) => _CommandRow(comment: comments[comments.length - 1 - index]),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LivePill extends StatelessWidget {
  final VoidCallback onTap;
  const _LivePill({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.fromLTRB(10, 4, 6, 4),
        decoration: BoxDecoration(
          color: const Color(0x33000000),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.white.withValues(alpha: 0.16)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 7,
              height: 7,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: Color(0xFF2EE59D),
                boxShadow: [BoxShadow(color: Color(0xAA2EE59D), blurRadius: 6)],
              ),
            ),
            const SizedBox(width: 5),
            const Text(
              'Live',
              style: TextStyle(color: Colors.white, fontSize: 12.5, fontWeight: FontWeight.w600),
            ),
            const Icon(Icons.keyboard_arrow_down_rounded, color: Colors.white, size: 18),
          ],
        ),
      ),
    );
  }
}

class _CommandRow extends StatelessWidget {
  final LiveComment comment;
  const _CommandRow({required this.comment});

  static final DateFormat _time = DateFormat('hh:mm a');
  static const _ringColors = [Color(0xFFFF3DA5), Color(0xFF2EC5FF), Color(0xFF2EE59D), Color(0xFFB05CFF)];

  bool get _isGift => comment.type == LiveCommentType.gift || comment.message.startsWith('sent ');
  bool get _isVip => _PkDemoData.vipNames.contains(comment.userName);

  @override
  Widget build(BuildContext context) {
    final ring = _ringColors[comment.userName.codeUnits.fold<int>(0, (a, b) => a + b) % _ringColors.length];
    final messageColor = _isGift ? _PkColors.gold : const Color(0xFF5CD6FF);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(1.8),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: ring, width: 1.8),
              boxShadow: [BoxShadow(color: ring.withValues(alpha: 0.45), blurRadius: 8)],
            ),
            child: CustomAvatar(radius: 15, assetPath: comment.userAssetPath ?? AppAssets.status4),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        comment.userName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(color: Colors.white, fontSize: 13.5, fontWeight: FontWeight.w700),
                      ),
                    ),
                    if (_isVip) ...[const SizedBox(width: 5), const _PkGoldCrown(size: 13)],
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  comment.message,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(color: messageColor, fontSize: 12.5, fontWeight: FontWeight.w500),
                ),
              ],
            ),
          ),
          const SizedBox(width: 6),
          Padding(
            padding: const EdgeInsets.only(top: 2),
            child: Text(
              _time.format(comment.timestamp),
              style: const TextStyle(color: Color(0xFF8E99B8), fontSize: 10.5),
            ),
          ),
        ],
      ),
    );
  }
}

/// Right column: Gift card on top, then wide ♥ Like and ↪ Share buttons.
class _PkRightColumn extends StatelessWidget {
  final VoidCallback onGift;
  final VoidCallback onLike;
  final VoidCallback onShare;
  final Widget hearts;

  const _PkRightColumn({required this.onGift, required this.onLike, required this.onShare, required this.hearts});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final pillHeight = (constraints.maxHeight * 0.17).clamp(36.0, 48.0);
        return Column(
          children: [
            Expanded(
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  Positioned.fill(child: PkGiftCard(onTap: onGift)),
                  // Hearts rise from the Gift card (above the Like / Share buttons).
                  Positioned(left: constraints.maxWidth / 2 - 22, width: 44, top: 0, bottom: 20, child: hearts),
                ],
              ),
            ),
            const SizedBox(height: 8),
            _SidePill(
              height: pillHeight,
              label: 'Like',
              onTap: onLike,
              icon: _GradientIcon(
                Icons.favorite_rounded,
                size: pillHeight * 0.55,
                colors: const [Color(0xFFFFA8F0), Color(0xFFE81CFF)],
              ),
            ),
            const SizedBox(height: 8),
            _SidePill(
              height: pillHeight,
              label: 'Share',
              onTap: onShare,
              icon: _GradientIcon(
                Icons.shortcut_rounded,
                size: pillHeight * 0.55,
                colors: const [Color(0xFFC6A2FF), Color(0xFF4A8BFF)],
              ),
            ),
          ],
        );
      },
    );
  }
}

class _SidePill extends StatelessWidget {
  final double height;
  final String label;
  final Widget icon;
  final VoidCallback onTap;

  const _SidePill({required this.height, required this.label, required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: label,
      child: GestureDetector(
        onTap: onTap,
        child: _NeonBox(
          height: height,
          radius: height / 2,
          borderColors: const [Color(0xFF4A63FF), Color(0xFF8A3DFF), Color(0xFF2E9BFF)],
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: FittedBox(
            fit: BoxFit.scaleDown,
            child: Row(
              children: [
                icon,
                const SizedBox(width: 8),
                Text(
                  label,
                  style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w700),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}



/// [😊] [Type a message...] [•••]
class _PkInputBar extends StatelessWidget {
  final VoidCallback onEmojiTap;
  final VoidCallback onMessageTap;
  final VoidCallback onMoreTap;

  const _PkInputBar({required this.onEmojiTap, required this.onMessageTap, required this.onMoreTap});

  @override
  Widget build(BuildContext context) {
    return _NeonBox(
      radius: 32,
      borderColors: const [Color(0xFF2E9BFF), Color(0xFF7C5CFF), Color(0xFFFF2D9A)],
      padding: const EdgeInsets.all(5),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final circle = (constraints.maxWidth / 8.2).clamp(36.0, 46.0);
          return Row(
            children: [
              _PanelCircle(
                size: circle,
                accent: const Color(0xFF2E9BFF),
                onTap: onEmojiTap,
                label: 'Emoji',
                child: Icon(Icons.sentiment_satisfied_alt_rounded, color: Colors.white, size: circle * 0.62),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: GestureDetector(
                  onTap: onMessageTap,
                  child: Container(
                    height: circle,
                    padding: const EdgeInsets.symmetric(horizontal: 14),
                    alignment: Alignment.centerLeft,
                    decoration: BoxDecoration(
                      color: const Color(0xFF0A0F33),
                      borderRadius: BorderRadius.circular(40),
                      border: Border.all(color: const Color(0xFF3A4590)),
                    ),
                    child: const Text(
                      'Type a message...',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(color: Color(0xFF8E9CD0), fontSize: 14),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              _PanelCircle(
                size: circle,
                accent: const Color(0xFF4A63FF),
                onTap: onMoreTap,
                label: 'More',
                child: Icon(Icons.more_horiz_rounded, color: Colors.white, size: circle * 0.55),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _PanelCircle extends StatelessWidget {
  final double size;
  final Widget child;
  final VoidCallback onTap;
  final String label;
  final Color? accent;

  const _PanelCircle({required this.size, required this.child, required this.onTap, required this.label, this.accent});

  @override
  Widget build(BuildContext context) {
    final border = accent ?? const Color(0xFF4A56A8);
    return Semantics(
      button: true,
      label: label,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          width: size,
          height: size,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: const RadialGradient(colors: [Color(0xFF1F2560), Color(0xFF0E1236)]),
            border: Border.all(color: border, width: 1.3),
            boxShadow: accent != null ? [BoxShadow(color: accent!.withValues(alpha: 0.5), blurRadius: 10)] : null,
          ),
          child: child,
        ),
      ),
    );
  }
}

class _GradientIcon extends StatelessWidget {
  final IconData icon;
  final double size;
  final List<Color> colors;

  const _GradientIcon(this.icon, {required this.size, required this.colors});

  @override
  Widget build(BuildContext context) {
    return ShaderMask(
      blendMode: BlendMode.srcIn,
      shaderCallback: LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: colors,
      ).createShader,
      child: Icon(icon, size: size, color: Colors.white),
    );
  }
}



// =============================================================================
// WINNER OVERLAY
// =============================================================================

/// "PK Ended" celebration card shown over a blurred backdrop.
class _PkWinnerOverlay extends StatelessWidget {
  final _PkHost winner;
  final int winnerScore;
  final int loserScore;
  final VoidCallback onPlayAgain;
  final VoidCallback onBackToLive;

  const _PkWinnerOverlay({
    required this.winner,
    required this.winnerScore,
    required this.loserScore,
    required this.onPlayAgain,
    required this.onBackToLive,
  });

  @override
  Widget build(BuildContext context) {
    final format = NumberFormat('#,###');
    return Stack(
      children: [
        Positioned.fill(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 9, sigmaY: 9),
            child: ColoredBox(color: Colors.black.withValues(alpha: 0.58)),
          ),
        ),
        Center(
          child: SingleChildScrollView(
            child: Container(
              margin: const EdgeInsets.all(24),
              padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 24),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(28),
                gradient: const LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Color(0xF2181433), Color(0xF80A0C1E)],
                ),
                border: Border.all(color: _PkColors.gold.withValues(alpha: 0.65), width: 1.8),
                boxShadow: [
                  BoxShadow(color: _PkColors.gold.withValues(alpha: 0.25), blurRadius: 30, spreadRadius: 2),
                  const BoxShadow(color: Color(0xD9000000), blurRadius: 24, offset: Offset(0, 12)),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'PK Ended',
                    style: TextStyle(
                      color: _PkColors.gold,
                      fontSize: 22,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 1,
                    ),
                  ),
                  const SizedBox(height: 10),
                  const Text('👑', style: TextStyle(fontSize: 46)),
                  const SizedBox(height: 4),
                  _WinnerAvatar(asset: winner.avatarAsset),
                  const SizedBox(height: 14),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 36, vertical: 8),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(colors: [Color(0xFFFFEA00), Color(0xFFFF9100), Color(0xFFFF6D00)]),
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: const [BoxShadow(color: Color(0xCCFFD600), blurRadius: 18, offset: Offset(0, 4))],
                    ),
                    child: const Text(
                      'WINNER',
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 24,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 2,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    winner.name,
                    style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Congrats! 🎉',
                    style: TextStyle(color: _PkColors.gold, fontSize: 18, fontWeight: FontWeight.w800),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Final Score: ${format.format(winnerScore)} vs ${format.format(loserScore)}',
                    style: const TextStyle(color: Colors.white70, fontSize: 13),
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFFFD600),
                        foregroundColor: Colors.black,
                        elevation: 8,
                        shadowColor: const Color(0xCCFFD600),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
                        padding: const EdgeInsets.symmetric(vertical: 13),
                      ),
                      onPressed: onPlayAgain,
                      child: const Text('Play Again', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w900)),
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.white,
                        side: const BorderSide(color: Colors.white38, width: 1.2),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
                        padding: const EdgeInsets.symmetric(vertical: 13),
                      ),
                      onPressed: onBackToLive,
                      child: const Text('Back to Live', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _WinnerAvatar extends StatelessWidget {
  final String asset;
  const _WinnerAvatar({required this.asset});

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        Container(
          width: 150,
          height: 150,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: RadialGradient(
              colors: [
                const Color(0xFFFFD600).withValues(alpha: 0.6),
                const Color(0xFFFF8F00).withValues(alpha: 0.2),
                Colors.transparent,
              ],
            ),
          ),
        ),
        const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('🪽', style: TextStyle(fontSize: 50)),
            SizedBox(width: 80),
            Text('🪽', style: TextStyle(fontSize: 50)),
          ],
        ),
        Container(
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: const Color(0xFFFFD600), width: 3),
            boxShadow: const [BoxShadow(color: Color(0xFFFFD600), blurRadius: 20, spreadRadius: 2)],
          ),
          child: CustomAvatar(radius: 48, assetPath: asset),
        ),
      ],
    );
  }
}

// =============================================================================
// BOTTOM SHEETS & DIALOGS
// =============================================================================

const Color _gold = Color(0xFFFFD600);

/// Common bottom-sheet shell: dark rounded top, accent top border, drag handle.
class _PkSheet extends StatelessWidget {
  final Widget child;
  final Color accent;
  final EdgeInsetsGeometry padding;
  final double? maxHeight;

  const _PkSheet({
    required this.child,
    this.accent = const Color(0x66FFD600),
    this.padding = const EdgeInsets.fromLTRB(18, 12, 18, 16),
    this.maxHeight,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: maxHeight != null ? BoxConstraints(maxHeight: maxHeight!) : null,
      padding: padding,
      decoration: BoxDecoration(
        color: const Color(0xFF101018),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        border: Border(top: BorderSide(color: accent, width: 1.5)),
        boxShadow: const [BoxShadow(color: Color(0x33FFD600), blurRadius: 24, spreadRadius: -2)],
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: maxHeight != null ? MainAxisSize.max : MainAxisSize.min,
          children: [
            Container(
              width: 38,
              height: 4,
              decoration: BoxDecoration(color: Colors.white24, borderRadius: BorderRadius.circular(2)),
            ),
            const SizedBox(height: 14),
            // Transparent Material so ListTiles inside the sheet can show ink.
            if (maxHeight != null)
              Expanded(
                child: Material(type: MaterialType.transparency, child: child),
              )
            else
              Material(type: MaterialType.transparency, child: child),
          ],
        ),
      ),
    );
  }
}

/// Sheet header row with a back chevron: "< Title".
class _PkSheetTitle extends StatelessWidget {
  final String title;
  const _PkSheetTitle(this.title);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        GestureDetector(
          onTap: () => Navigator.pop(context),
          child: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 18),
        ),
        const SizedBox(width: 12),
        Text(
          title,
          style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }
}

/// Full-width gold primary button used across PK dialogs.
class _PkPrimaryButton extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;
  const _PkPrimaryButton({required this.label, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: _gold,
          foregroundColor: Colors.black,
          elevation: 6,
          shadowColor: const Color(0xAAFFD600),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
          padding: const EdgeInsets.symmetric(vertical: 13),
        ),
        onPressed: onPressed,
        child: Text(label, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w900, letterSpacing: 0.5)),
      ),
    );
  }
}

class _PkSheets {
  _PkSheets._();

  // ---------------------------------------------------------------------------
  // Message input
  // ---------------------------------------------------------------------------
  static void showMessageInput(BuildContext context, {required ValueChanged<String> onSend}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _MessageInputSheet(onSend: onSend),
    );
  }

  // ---------------------------------------------------------------------------
  // PK settings
  // ---------------------------------------------------------------------------
  static void showSettings(
    BuildContext context, {
    required _PkSettings current,
    required ValueChanged<_PkSettings> onSave,
  }) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => _SettingsSheet(initial: current, onSave: onSave),
    );
  }

  // ---------------------------------------------------------------------------
  // PK rules
  // ---------------------------------------------------------------------------
  static void showRules(BuildContext context) {
    const rule = TextStyle(color: Colors.white70);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF14141E),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
          side: const BorderSide(color: _gold, width: 1.5),
        ),
        title: const Text(
          '📜 Official PK Rules',
          style: TextStyle(color: _gold, fontWeight: FontWeight.bold),
        ),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('1. PK Battle duration is configurable (3, 5, or 10 min).', style: rule),
            SizedBox(height: 8),
            Text("2. Every gift sent boosts the host's clash score bar.", style: rule),
            SizedBox(height: 8),
            Text('3. When the timer reaches 00:00, the host with the higher score wins!', style: rule),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text(
              'Got it',
              style: TextStyle(color: _gold, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Share
  // ---------------------------------------------------------------------------
  static void showShare(BuildContext context) {
    const options = [
      ('WhatsApp', '💬'),
      ('Instagram', '📸'),
      ('Telegram', '✈️'),
      ('Copy Link', '🔗'),
      ('Friends', '👥'),
    ];

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => _PkSheet(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                const Icon(Icons.reply_rounded, color: _gold, size: 22),
                const SizedBox(width: 8),
                const Expanded(
                  child: Text(
                    'Share PK Battle',
                    style: TextStyle(color: Colors.white, fontSize: 17, fontWeight: FontWeight.bold),
                  ),
                ),
                GestureDetector(
                  onTap: () => Navigator.pop(ctx),
                  child: const Icon(Icons.close_rounded, color: Colors.white70, size: 20),
                ),
              ],
            ),
            const SizedBox(height: 18),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                for (final (name, icon) in options)
                  GestureDetector(
                    onTap: () {
                      Navigator.pop(ctx);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            name == 'Copy Link'
                                ? '📋 PK Battle link copied to clipboard!'
                                : 'Shared battle to $name! 🚀',
                          ),
                          duration: const Duration(seconds: 1),
                        ),
                      );
                    },
                    child: Column(
                      children: [
                        Container(
                          width: 52,
                          height: 52,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: const Color(0xFF1B1B26),
                            border: Border.all(color: Colors.white12),
                          ),
                          child: Text(icon, style: const TextStyle(fontSize: 24)),
                        ),
                        const SizedBox(height: 6),
                        Text(name, style: const TextStyle(color: Colors.white70, fontSize: 11)),
                      ],
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // More options (opened from Live Tools → Ranking)
  // ---------------------------------------------------------------------------
  static void showMoreOptions(
    BuildContext context, {
    required VoidCallback onSettings,
    required VoidCallback onPreviewWinner,
  }) {
    Widget tile(BuildContext ctx, IconData icon, String title, String subtitle, VoidCallback onTap) {
      return ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: const BoxDecoration(color: Color(0x33FFD600), shape: BoxShape.circle),
          child: Icon(icon, color: _gold),
        ),
        title: Text(
          title,
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        subtitle: Text(subtitle, style: const TextStyle(color: Colors.white54, fontSize: 12)),
        onTap: () {
          Navigator.pop(ctx);
          onTap();
        },
      );
    }

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => _PkSheet(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            tile(ctx, Icons.settings_rounded, 'PK Battle Settings', 'Timer, auto-end & host acceptance', onSettings),
            tile(
              ctx,
              Icons.emoji_events_rounded,
              'Winner Celebration Screen',
              'Preview celebration ribbon & trophies',
              onPreviewWinner,
            ),
            tile(
              ctx,
              Icons.shield_outlined,
              'PK Rules',
              'View battle rules and scoring criteria',
              () => showRules(context),
            ),
          ],
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Top toast banner for PK events (started / declined ...)
  // ---------------------------------------------------------------------------
  static void showBanner(
    BuildContext context, {
    required String title,
    required String message,
    required IconData icon,
    required Color color,
  }) {
    final messenger = ScaffoldMessenger.of(context)..hideCurrentSnackBar();
    messenger.showSnackBar(
      SnackBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        behavior: SnackBarBehavior.floating,
        margin: EdgeInsets.only(bottom: MediaQuery.sizeOf(context).height * 0.78, left: 14, right: 14),
        duration: const Duration(seconds: 3),
        content: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: const Color(0xFF141220),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: color, width: 1.5),
            boxShadow: [BoxShadow(color: color.withValues(alpha: 0.4), blurRadius: 16, spreadRadius: 1)],
          ),
          child: Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(color: color.withValues(alpha: 0.2), shape: BoxShape.circle),
                child: Icon(icon, color: color, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(color: Colors.white, fontSize: 13.5, fontWeight: FontWeight.bold),
                    ),
                    Text(message, style: const TextStyle(color: Colors.white70, fontSize: 11.5)),
                  ],
                ),
              ),
              const Text('Now', style: TextStyle(color: Colors.white38, fontSize: 10)),
            ],
          ),
        ),
      ),
    );
  }
}

class _MessageInputSheet extends StatefulWidget {
  final ValueChanged<String> onSend;
  const _MessageInputSheet({required this.onSend});

  @override
  State<_MessageInputSheet> createState() => _MessageInputSheetState();
}

class _MessageInputSheetState extends State<_MessageInputSheet> {
  static const _quickEmojis = ['🌹', '❤️', '🔥', '👏', '⭐', '🐳', '🏎️', '👑', '🎉', '💯'];
  final TextEditingController _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _insertEmoji(String emoji) {
    _controller.text += emoji;
    _controller.selection = TextSelection.collapsed(offset: _controller.text.length);
  }

  void _send() {
    final text = _controller.text.trim();
    if (text.isEmpty) return;
    Navigator.pop(context);
    widget.onSend(text);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: const Color(0xF5090C1A),
          borderRadius: const BorderRadius.vertical(top: Radius.circular(22)),
          border: Border.all(color: const Color(0x992979FF), width: 1.2),
        ),
        child: SafeArea(
          top: false,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    for (final emoji in _quickEmojis)
                      GestureDetector(
                        onTap: () => _insertEmoji(emoji),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
                          margin: const EdgeInsets.only(right: 6, bottom: 10),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.08),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.white12),
                          ),
                          child: Text(emoji, style: const TextStyle(fontSize: 18)),
                        ),
                      ),
                  ],
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
                        border: Border.all(color: const Color(0xCC2979FF), width: 1.2),
                      ),
                      child: TextField(
                        controller: _controller,
                        autofocus: true,
                        textInputAction: TextInputAction.send,
                        style: const TextStyle(color: Colors.white, fontSize: 14),
                        decoration: const InputDecoration(
                          hintText: 'Type a message...',
                          hintStyle: TextStyle(color: Colors.white54, fontSize: 13.5),
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(vertical: 10),
                        ),
                        onSubmitted: (_) => _send(),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  GestureDetector(
                    onTap: _send,
                    child: Container(
                      width: 44,
                      height: 44,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: LinearGradient(
                          colors: [_PkColors.pink, Color(0xFF2979FF)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        boxShadow: [BoxShadow(color: Color(0x66FF2D78), blurRadius: 10)],
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
  }
}

class _SettingsSheet extends StatefulWidget {
  final _PkSettings initial;
  final ValueChanged<_PkSettings> onSave;

  const _SettingsSheet({required this.initial, required this.onSave});

  @override
  State<_SettingsSheet> createState() => _SettingsSheetState();
}

class _SettingsSheetState extends State<_SettingsSheet> {
  late int _duration = widget.initial.durationSeconds;
  late bool _countdown = widget.initial.countdownDisplay;
  late bool _showToAudience = widget.initial.showTimerToAudience;
  late bool _autoEnd = widget.initial.autoEnd;

  @override
  Widget build(BuildContext context) {
    return _PkSheet(
      accent: const Color(0x55FFD600),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _PkSheetTitle('PK Settings'),
          const SizedBox(height: 20),
          const Row(
            children: [
              Icon(Icons.timer_rounded, color: _gold, size: 18),
              SizedBox(width: 8),
              Text(
                'Battle Duration',
                style: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              for (final (label, secs) in const [('3 min', 180), ('5 min', 300), ('10 min', 600)]) ...[
                if (secs != 180) const SizedBox(width: 10),
                _durationPill(label, secs),
              ],
            ],
          ),
          const SizedBox(height: 24),
          _switchRow(Icons.alarm_on_rounded, 'Countdown Display', _countdown, (v) => setState(() => _countdown = v)),
          const SizedBox(height: 12),
          _switchRow(
            Icons.visibility_rounded,
            'Show Timer to Audience',
            _showToAudience,
            (v) => setState(() => _showToAudience = v),
          ),
          const SizedBox(height: 12),
          _switchRow(Icons.group_work_rounded, 'Auto End PK', _autoEnd, (v) => setState(() => _autoEnd = v)),
          const SizedBox(height: 24),
          _PkPrimaryButton(
            label: 'Save',
            onPressed: () {
              Navigator.pop(context);
              widget.onSave(
                _PkSettings(
                  durationSeconds: _duration,
                  countdownDisplay: _countdown,
                  showTimerToAudience: _showToAudience,
                  autoEnd: _autoEnd,
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _durationPill(String label, int seconds) {
    final selected = seconds == _duration;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _duration = seconds),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.symmetric(vertical: 11),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: selected ? _gold : const Color(0xFF1B1B26),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: selected ? _gold : Colors.white12, width: selected ? 1.8 : 1),
            boxShadow: selected ? const [BoxShadow(color: Color(0x66FFD600), blurRadius: 10, spreadRadius: 1)] : null,
          ),
          child: Text(
            label,
            style: TextStyle(
              color: selected ? Colors.black : Colors.white,
              fontSize: 14,
              fontWeight: selected ? FontWeight.w900 : FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }

  Widget _switchRow(IconData icon, String title, bool value, ValueChanged<bool> onChanged) {
    return Row(
      children: [
        Icon(icon, color: Colors.white70, size: 18),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            title,
            style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w600),
          ),
        ),
        Switch(
          value: value,
          onChanged: onChanged,
          activeThumbColor: _gold,
          activeTrackColor: const Color(0x66FFD600),
          inactiveThumbColor: Colors.white38,
          inactiveTrackColor: Colors.white12,
        ),
      ],
    );
  }
}

// =============================================================================
// PK MATCHMAKING FLOW
// =============================================================================

/// A creator that can be challenged.
class _PkOpponent {
  final String name;
  final String avatarAsset;
  final String videoAsset;
  final String viewers;

  const _PkOpponent(this.name, this.avatarAsset, this.videoAsset, this.viewers);
}

/// Opponent search flow:
/// Choose mode → (Random matching → Match found) | (Search & select → Send request → Waiting)
/// → Opponent accepted 3·2·1 → [onMatched].
class _PkMatchFlow {
  final BuildContext context;
  final _PkHost host;
  final ValueChanged<_PkOpponent> onMatched;
  final VoidCallback onOpenSettings;

  _PkMatchFlow({required this.context, required this.host, required this.onMatched, required this.onOpenSettings});

  static const List<_PkOpponent> _liveCreators = [
    _PkOpponent('Riya', AppAssets.status4, AppAssets.video2, '28.4K'),
    _PkOpponent('Arjun', AppAssets.status5, AppAssets.video1, '22.1K'),
    _PkOpponent('Simran', AppAssets.status1, AppAssets.video3, '18.7K'),
    _PkOpponent('Karthik', AppAssets.status2, AppAssets.video4, '16.5K'),
    _PkOpponent('Pooja', AppAssets.status3, AppAssets.video5, '14.3K'),
    _PkOpponent('Vikram', AppAssets.status5, AppAssets.video6, '12.1K'),
  ];

  static const _PkOpponent _randomMatch = _PkOpponent('Arjun', AppAssets.status5, AppAssets.video1, '8.3K');

  void start() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) => _ChooseModeSheet(
        onRandom: () => _next(ctx, _showRandomMatching),
        onSearch: () => _next(ctx, _showSearchAndSelect),
        onRules: () => _next(ctx, () => _PkSheets.showRules(context)),
        onSettings: () => _next(ctx, onOpenSettings),
      ),
    );
  }

  /// Closes the current route and continues the flow if the screen is still alive.
  void _next(BuildContext routeContext, VoidCallback then) {
    Navigator.pop(routeContext);
    if (context.mounted) then();
  }

  void _showRandomMatching() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      isDismissible: false,
      builder: (ctx) => _RandomMatchingSheet(onFound: () => _next(ctx, () => _showMatchFound(_randomMatch))),
    );
  }

  void _showMatchFound(_PkOpponent rival) {
    showDialog(
      context: context,
      barrierColor: Colors.black87,
      barrierDismissible: false,
      builder: (ctx) => _GoldDialog(
        children: [
          const Text('👥', style: TextStyle(fontSize: 32)),
          const SizedBox(height: 6),
          const Text(
            'Match Found!',
            style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 4),
          const Text(
            'Waiting for the other creator to accept...',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.white60, fontSize: 13),
          ),
          const SizedBox(height: 22),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _AvatarWithLabel(asset: host.avatarAsset, name: host.name, subtitle: '💛 ${host.likes}'),
              const SizedBox(width: 14),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(colors: [Color(0xFFFFEA00), Color(0xFFFF9100)]),
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: const [BoxShadow(color: Color(0x88FFD600), blurRadius: 10)],
                ),
                child: const Text(
                  'VS',
                  style: TextStyle(color: Colors.black, fontSize: 14, fontWeight: FontWeight.w900),
                ),
              ),
              const SizedBox(width: 14),
              _AvatarWithLabel(asset: rival.avatarAsset, name: rival.name, subtitle: '💛 ${rival.viewers}'),
            ],
          ),
          const SizedBox(height: 22),
          Container(
            width: 48,
            height: 48,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: _gold, width: 2),
              color: const Color(0x33FFD600),
            ),
            child: const Text(
              '15s',
              style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w900),
            ),
          ),
          const SizedBox(height: 22),
          _PkPrimaryButton(label: 'Accept PK', onPressed: () => _next(ctx, () => _showAcceptedCountdown(rival))),
          const SizedBox(height: 10),
          TextButton(
            onPressed: () => _next(
              ctx,
              () => _PkSheets.showBanner(
                context,
                title: 'PK Declined',
                message: 'You declined the PK match.',
                icon: Icons.cancel_outlined,
                color: const Color(0xFFFF5252),
              ),
            ),
            child: const Text(
              'Decline',
              style: TextStyle(color: Colors.white54, fontSize: 14, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  void _showSearchAndSelect() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) =>
          _SearchSelectSheet(creators: _liveCreators, onChallenge: (c) => _next(ctx, () => _showSendRequest(c))),
    );
  }

  void _showSendRequest(_PkOpponent rival) {
    showDialog(
      context: context,
      barrierColor: Colors.black87,
      builder: (ctx) => _GoldDialog(
        children: [
          _GoldRingAvatar(asset: rival.avatarAsset, radius: 44),
          const SizedBox(height: 12),
          Text(
            rival.name,
            style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
          ),
          Text(
            '💛 ${rival.viewers} viewers',
            style: const TextStyle(color: _gold, fontSize: 12, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 16),
          const Text(
            'Send PK Request?',
            style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          Text(
            '${rival.name} will receive a request to join PK battle.',
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.white60, fontSize: 12.5),
          ),
          const SizedBox(height: 22),
          _PkPrimaryButton(label: 'Send Request', onPressed: () => _next(ctx, () => _showWaiting(rival))),
          const SizedBox(height: 10),
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel', style: TextStyle(color: Colors.white54, fontSize: 14)),
          ),
        ],
      ),
    );
  }

  void _showWaiting(_PkOpponent rival) {
    showDialog(
      context: context,
      barrierColor: Colors.black87,
      barrierDismissible: false,
      builder: (ctx) => _WaitingDialog(rival: rival, onAccepted: () => _next(ctx, () => _showAcceptedCountdown(rival))),
    );
  }

  void _showAcceptedCountdown(_PkOpponent rival) {
    showDialog(
      context: context,
      barrierColor: Colors.black87,
      barrierDismissible: false,
      builder: (ctx) => _AcceptedCountdownDialog(rival: rival, onDone: () => _next(ctx, () => onMatched(rival))),
    );
  }
}

// =============================================================================
// Sheets & dialogs
// =============================================================================

class _ChooseModeSheet extends StatelessWidget {
  final VoidCallback onRandom;
  final VoidCallback onSearch;
  final VoidCallback onRules;
  final VoidCallback onSettings;

  const _ChooseModeSheet({
    required this.onRandom,
    required this.onSearch,
    required this.onRules,
    required this.onSettings,
  });

  @override
  Widget build(BuildContext context) {
    return _PkSheet(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 58,
            height: 58,
            alignment: Alignment.center,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(colors: [Color(0xFFFFEA00), Color(0xFFFF9100)]),
              boxShadow: [BoxShadow(color: Color(0x88FFD600), blurRadius: 18, spreadRadius: 2)],
            ),
            child: const Text('⚔️', style: TextStyle(fontSize: 28)),
          ),
          const SizedBox(height: 10),
          const Text(
            'PK Battle',
            style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w900, letterSpacing: 0.5),
          ),
          const SizedBox(height: 4),
          const Text('Choose a way to find your opponent', style: TextStyle(color: Colors.white60, fontSize: 13)),
          const SizedBox(height: 22),
          _ModeOption(
            leading: const Text('🎲', style: TextStyle(fontSize: 26)),
            title: 'Random Matching',
            subtitle: 'Find a random live creator',
            onTap: onRandom,
          ),
          const SizedBox(height: 14),
          _ModeOption(
            leading: const Icon(Icons.search_rounded, color: _gold, size: 28),
            title: 'Search & Select',
            subtitle: 'Find and invite a specific creator',
            onTap: onSearch,
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _LinkButton(icon: Icons.shield_outlined, label: 'PK Rules', color: _gold, onTap: onRules),
              const SizedBox(width: 28),
              _LinkButton(icon: Icons.settings_outlined, label: 'Settings', color: Colors.white70, onTap: onSettings),
            ],
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}

class _ModeOption extends StatelessWidget {
  final Widget leading;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _ModeOption({required this.leading, required this.title, required this.subtitle, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          gradient: const LinearGradient(colors: [Color(0xFF261D07), Color(0xFF140E02)]),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: _gold, width: 1.5),
          boxShadow: const [BoxShadow(color: Color(0x33FFD600), blurRadius: 12)],
        ),
        child: Row(
          children: [
            Container(
              width: 46,
              height: 46,
              alignment: Alignment.center,
              decoration: BoxDecoration(color: _gold.withValues(alpha: 0.18), borderRadius: BorderRadius.circular(14)),
              child: leading,
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 3),
                  Text(subtitle, style: const TextStyle(color: Colors.white60, fontSize: 12)),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios_rounded, color: _gold, size: 16),
          ],
        ),
      ),
    );
  }
}

class _LinkButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _LinkButton({required this.icon, required this.label, required this.color, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Row(
        children: [
          Icon(icon, color: color, size: 16),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(color: color, fontSize: 13, fontWeight: FontWeight.bold),
          ),
          Icon(Icons.chevron_right_rounded, color: color, size: 16),
        ],
      ),
    );
  }
}

class _RandomMatchingSheet extends StatefulWidget {
  final VoidCallback onFound;
  const _RandomMatchingSheet({required this.onFound});

  @override
  State<_RandomMatchingSheet> createState() => _RandomMatchingSheetState();
}

class _RandomMatchingSheetState extends State<_RandomMatchingSheet> {
  static const _nearby = [
    AppAssets.status1,
    AppAssets.status2,
    AppAssets.status3,
    AppAssets.status4,
    AppAssets.status5,
    AppAssets.status1,
  ];

  late final Timer _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer(const Duration(milliseconds: 2800), widget.onFound);
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return _PkSheet(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('🎲', style: TextStyle(fontSize: 34)),
          const SizedBox(height: 6),
          const Text(
            'Random Matching',
            style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 4),
          const Text('Finding a live creator for you...', style: TextStyle(color: Colors.white60, fontSize: 13)),
          const SizedBox(height: 28),
          SizedBox(
            width: 240,
            height: 240,
            child: Stack(
              alignment: Alignment.center,
              children: [
                for (final (size, alpha) in const [(240.0, 0x33), (170.0, 0x66)])
                  Container(
                    width: size,
                    height: size,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: _gold.withAlpha(alpha), width: 1.5),
                    ),
                  ),
                Container(
                  width: 100,
                  height: 100,
                  alignment: Alignment.center,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(colors: [Color(0xFFFFEA00), Color(0xFFFF9100)]),
                    boxShadow: [BoxShadow(color: Color(0xAAFFD600), blurRadius: 24, spreadRadius: 2)],
                  ),
                  child: const Text(
                    'Searching...',
                    style: TextStyle(color: Colors.black, fontSize: 13, fontWeight: FontWeight.w900),
                  ),
                ),
                for (var i = 0; i < _nearby.length; i++)
                  Transform.translate(
                    offset: Offset.fromDirection(i / _nearby.length * 2 * pi, 95),
                    child: _GoldRingAvatar(asset: _nearby[i], radius: 18, ringWidth: 1.8),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 28),
          const Text(
            "Please wait, we'll find the best match for you.",
            style: TextStyle(color: Colors.white70, fontSize: 13),
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.white,
                side: const BorderSide(color: Colors.white24),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
                padding: const EdgeInsets.symmetric(vertical: 13),
              ),
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
            ),
          ),
        ],
      ),
    );
  }
}

class _SearchSelectSheet extends StatefulWidget {
  final List<_PkOpponent> creators;
  final ValueChanged<_PkOpponent> onChallenge;

  const _SearchSelectSheet({required this.creators, required this.onChallenge});

  @override
  State<_SearchSelectSheet> createState() => _SearchSelectSheetState();
}

class _SearchSelectSheetState extends State<_SearchSelectSheet> {
  static const _tabs = ['Live Now', 'Recommended', 'Following'];
  String _selectedTab = _tabs.first;

  @override
  Widget build(BuildContext context) {
    return _PkSheet(
      accent: const Color(0x6600E5FF),
      maxHeight: MediaQuery.sizeOf(context).height * 0.82,
      child: Column(
        children: [
          const _PkSheetTitle('Search & Select'),
          const SizedBox(height: 14),
          Container(
            height: 42,
            padding: const EdgeInsets.symmetric(horizontal: 14),
            decoration: BoxDecoration(
              color: const Color(0xFF181822),
              borderRadius: BorderRadius.circular(22),
              border: Border.all(color: Colors.white12),
            ),
            child: const Row(
              children: [
                Icon(Icons.search_rounded, color: Colors.white54, size: 20),
                SizedBox(width: 10),
                Text('Search creators (name or ID)', style: TextStyle(color: Colors.white38, fontSize: 13)),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              for (final tab in _tabs)
                Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: _TabChip(
                    label: tab,
                    selected: tab == _selectedTab,
                    onTap: () => setState(() => _selectedTab = tab),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 14),
          Expanded(
            child: ListView.separated(
              itemCount: widget.creators.length,
              separatorBuilder: (_, _) => const SizedBox(height: 10),
              itemBuilder: (_, i) =>
                  _CreatorTile(creator: widget.creators[i], onChallenge: () => widget.onChallenge(widget.creators[i])),
            ),
          ),
        ],
      ),
    );
  }
}

class _TabChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _TabChip({required this.label, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        decoration: BoxDecoration(
          color: selected ? _gold : const Color(0xFF1A1A26),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: selected ? _gold : Colors.white12),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: selected ? Colors.black : Colors.white70,
            fontSize: 12,
            fontWeight: selected ? FontWeight.bold : FontWeight.w600,
          ),
        ),
      ),
    );
  }
}

class _CreatorTile extends StatelessWidget {
  final _PkOpponent creator;
  final VoidCallback onChallenge;

  const _CreatorTile({required this.creator, required this.onChallenge});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFF14141E),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
      ),
      child: Row(
        children: [
          Stack(
            children: [
              _GoldRingAvatar(asset: creator.avatarAsset, radius: 22, ringWidth: 1.5, glow: false),
              Positioned(
                bottom: 0,
                right: 0,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                  decoration: BoxDecoration(color: _gold, borderRadius: BorderRadius.circular(6)),
                  child: const Text(
                    'LIVE',
                    style: TextStyle(color: Colors.black, fontSize: 8, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  creator.name,
                  style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 2),
                Text(
                  '💛 ${creator.viewers} viewers',
                  style: const TextStyle(color: _gold, fontSize: 12, fontWeight: FontWeight.w600),
                ),
              ],
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: _gold,
              foregroundColor: Colors.black,
              elevation: 4,
              shadowColor: const Color(0x66FFD600),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 7),
            ),
            onPressed: onChallenge,
            child: const Text('PK', style: TextStyle(fontSize: 13.5, fontWeight: FontWeight.w900)),
          ),
        ],
      ),
    );
  }
}

class _WaitingDialog extends StatefulWidget {
  final _PkOpponent rival;
  final VoidCallback onAccepted;

  const _WaitingDialog({required this.rival, required this.onAccepted});

  @override
  State<_WaitingDialog> createState() => _WaitingDialogState();
}

class _WaitingDialogState extends State<_WaitingDialog> {
  late final Timer _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer(const Duration(milliseconds: 2500), widget.onAccepted);
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return _GoldDialog(
      children: [
        const _GoldOrb(size: 72, child: Text('✈️', style: TextStyle(fontSize: 34))),
        const SizedBox(height: 16),
        const Text(
          'PK Request Sent!',
          style: TextStyle(color: Colors.white, fontSize: 19, fontWeight: FontWeight.w900),
        ),
        const SizedBox(height: 4),
        Text(
          '${widget.rival.name} will be notified. Please wait...',
          textAlign: TextAlign.center,
          style: const TextStyle(color: Colors.white60, fontSize: 13),
        ),
        const SizedBox(height: 20),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          decoration: BoxDecoration(
            color: const Color(0x33FFD600),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: _gold),
          ),
          child: const Text(
            '30s',
            style: TextStyle(color: _gold, fontSize: 15, fontWeight: FontWeight.w900),
          ),
        ),
        const SizedBox(height: 22),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton(
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.white70,
              side: const BorderSide(color: Colors.white24),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
              padding: const EdgeInsets.symmetric(vertical: 12),
            ),
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel Request', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ),
      ],
    );
  }
}

class _AcceptedCountdownDialog extends StatefulWidget {
  final _PkOpponent rival;
  final VoidCallback onDone;

  const _AcceptedCountdownDialog({required this.rival, required this.onDone});

  @override
  State<_AcceptedCountdownDialog> createState() => _AcceptedCountdownDialogState();
}

class _AcceptedCountdownDialogState extends State<_AcceptedCountdownDialog> {
  int _count = 3;
  late final Timer _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (_count > 1) {
        setState(() => _count--);
      } else {
        t.cancel();
        widget.onDone();
      }
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return _GoldDialog(
      children: [
        _GoldRingAvatar(asset: widget.rival.avatarAsset, radius: 36, ringWidth: 2, glow: false),
        const SizedBox(height: 12),
        const Text(
          'Opponent Accepted!',
          style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 4),
        const Text('Get ready! PK is starting...', style: TextStyle(color: Colors.white60, fontSize: 13)),
        const SizedBox(height: 20),
        _GoldOrb(
          size: 76,
          child: Text(
            '$_count',
            style: const TextStyle(color: Colors.white, fontSize: 38, fontWeight: FontWeight.w900),
          ),
        ),
      ],
    );
  }
}

// =============================================================================
// Small building blocks
// =============================================================================

class _GoldDialog extends StatelessWidget {
  final List<Widget> children;
  const _GoldDialog({required this.children});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 24),
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: const Color(0xFF14101E),
          borderRadius: BorderRadius.circular(32),
          border: Border.all(color: _gold, width: 1.8),
          boxShadow: const [BoxShadow(color: Color(0x66FFD600), blurRadius: 28, spreadRadius: 2)],
        ),
        child: Column(mainAxisSize: MainAxisSize.min, children: children),
      ),
    );
  }
}

class _GoldOrb extends StatelessWidget {
  final double size;
  final Widget child;
  const _GoldOrb({required this.size, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(colors: [Color(0xFFFFEA00), Color(0xFFFF9100)]),
        boxShadow: [BoxShadow(color: Color(0xCCFFD600), blurRadius: 22, spreadRadius: 2)],
      ),
      child: child,
    );
  }
}

class _GoldRingAvatar extends StatelessWidget {
  final String asset;
  final double radius;
  final double ringWidth;
  final bool glow;

  const _GoldRingAvatar({required this.asset, required this.radius, this.ringWidth = 2.5, this.glow = true});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(2.5),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: _gold, width: ringWidth),
        boxShadow: glow ? const [BoxShadow(color: Color(0x88FFD600), blurRadius: 12)] : null,
      ),
      child: CustomAvatar(radius: radius, assetPath: asset),
    );
  }
}

class _AvatarWithLabel extends StatelessWidget {
  final String asset;
  final String name;
  final String subtitle;

  const _AvatarWithLabel({required this.asset, required this.name, required this.subtitle});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _GoldRingAvatar(asset: asset, radius: 36),
        const SizedBox(height: 6),
        Text(
          name,
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13.5),
        ),
        Text(
          subtitle,
          style: const TextStyle(color: _gold, fontSize: 11, fontWeight: FontWeight.w800),
        ),
      ],
    );
  }
}

// =============================================================================
// SMALL DECORATIONS (crowns, wings, avatar pair)
// =============================================================================

/// Small vector gold crown used next to host and team names.
class _PkGoldCrown extends StatelessWidget {
  final double size;
  const _PkGoldCrown({this.size = 14});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size * 0.85,
      child: CustomPaint(painter: _GoldCrownPainter()),
    );
  }
}

class _GoldCrownPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final paint = Paint()
      ..shader = const LinearGradient(
        colors: [Color(0xFFFFF9C4), Color(0xFFFFD700), Color(0xFFFF8F00)],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ).createShader(Offset.zero & size);

    final body = Path()
      ..moveTo(0, h * 0.85)
      ..lineTo(0, h * 0.35)
      ..lineTo(w * 0.25, h * 0.55)
      ..lineTo(w * 0.5, h * 0.05)
      ..lineTo(w * 0.75, h * 0.55)
      ..lineTo(w, h * 0.35)
      ..lineTo(w, h * 0.85)
      ..close();
    canvas.drawPath(body, paint);

    canvas.drawRRect(
      RRect.fromRectAndRadius(Rect.fromLTWH(0, h * 0.85, w, h * 0.15), const Radius.circular(1)),
      Paint()..color = const Color(0xFFFFD700),
    );
    canvas.drawCircle(Offset(w * 0.5, h * 0.06), w * 0.09, Paint()..color = const Color(0xFFFF1744));
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// Mini stack of two overlapping member avatars.
class _PkAvatarPair extends StatelessWidget {
  final List<String> assets;

  const _PkAvatarPair({required this.assets});

  @override
  Widget build(BuildContext context) {
    const size = 13.0;
    return SizedBox(
      width: size + (assets.length - 1) * 10,
      height: size,
      child: Stack(
        children: [
          for (var i = 0; i < assets.length; i++)
            Positioned(
              left: i * 10.0,
              child: Container(
                width: size,
                height: size,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 1),
                ),
                child: ClipOval(
                  child: CustomAvatar(radius: size / 2, assetPath: assets[i]),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

// =============================================================================
// PAINTERS (plasma seam, video aura, score bar)
// =============================================================================

/// Animated pink/blue seam running down the middle of the split video, with a
/// soft bloom behind the VS emblem.
class _PkPlasmaSeamPainter extends CustomPainter {
  final Animation<double> animation;

  _PkPlasmaSeamPainter({required this.animation}) : super(repaint: animation);

  static const _pink = Color(0xFFFF0055);
  static const _cyan = Color(0xFF2E8BFF);

  @override
  void paint(Canvas canvas, Size size) {
    final progress = animation.value;
    final cx = size.width / 2;
    final cy = size.height / 2;

    // Bloom behind the VS badge.
    final pulse = 0.85 + 0.15 * sin(progress * 4 * pi);
    canvas.drawCircle(
      Offset(cx - 10, cy),
      40,
      Paint()
        ..color = _pink.withValues(alpha: 0.55 * pulse)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 24),
    );
    canvas.drawCircle(
      Offset(cx + 10, cy),
      40,
      Paint()
        ..color = _cyan.withValues(alpha: 0.55 * pulse)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 24),
    );

    _paintBeam(canvas, cx, size.height, progress);
  }

  void _paintBeam(Canvas canvas, double cx, double height, double progress) {
    const steps = 30;
    final dy = height / steps;

    final pinkAura = Path()..moveTo(cx - 2, 0);
    final cyanAura = Path()..moveTo(cx + 2, 0);
    final pinkBody = Path()..moveTo(cx - 2.5, 0);
    final cyanBody = Path()..moveTo(cx + 2.5, 0);
    final core = Path()..moveTo(cx, 0);

    for (var i = 0; i <= steps; i++) {
      final y = i * dy;
      final offset = sin((y * 0.05) - progress * 2 * pi) * 1.6 + cos((y * 0.11) + progress * 3 * pi) * 0.9;
      pinkAura.lineTo(cx - 3, y);
      cyanAura.lineTo(cx + 3, y);
      pinkBody.lineTo(cx - 1.6 + offset.clamp(-3.0, 0.0), y);
      cyanBody.lineTo(cx + 1.6 + offset.clamp(0.0, 3.0), y);
      core.lineTo(cx + offset * 0.3, y);
    }

    Paint stroke(Color c, double width, [double blur = 0]) {
      final p = Paint()
        ..color = c
        ..strokeWidth = width
        ..style = PaintingStyle.stroke;
      if (blur > 0) p.maskFilter = MaskFilter.blur(BlurStyle.normal, blur);
      return p;
    }

    // Thin, bright seam: soft side glows, coloured edges, white-hot core.
    canvas.drawPath(pinkAura, stroke(_pink.withValues(alpha: 0.45), 10, 8));
    canvas.drawPath(cyanAura, stroke(_cyan.withValues(alpha: 0.45), 10, 8));
    canvas.drawPath(pinkBody, stroke(const Color(0xFFFF1A75), 2.2, 1.5));
    canvas.drawPath(cyanBody, stroke(const Color(0xFF4FA3FF), 2.2, 1.5));
    canvas.drawPath(core, stroke(Colors.white, 3, 2));
    canvas.drawPath(core, stroke(Colors.white, 1.3));

    // Energy pulses travelling along the beam.
    for (var k = 0; k < 3; k++) {
      final y = ((progress * 1.6 + k / 3) % 1.0) * height;
      final x = cx + sin((y * 0.04) - progress * 2 * pi) * 1.5;
      canvas.drawCircle(
        Offset(x, y),
        4.5,
        Paint()
          ..color = k.isEven ? const Color(0xFFFF80AB) : const Color(0xFF80D8FF)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 5),
      );
      canvas.drawCircle(Offset(x, y), 2.2, Paint()..color = Colors.white);
    }
  }

  @override
  bool shouldRepaint(covariant _PkPlasmaSeamPainter oldDelegate) => false;
}

/// Pulsing neon border around both video halves (pink left, cyan right) with travelling sparks.
class _PkVideoAuraPainter extends CustomPainter {
  final Animation<double> animation;
  final double radius;

  _PkVideoAuraPainter({required this.animation, this.radius = 18}) : super(repaint: animation);

  @override
  void paint(Canvas canvas, Size size) {
    final progress = animation.value;
    final w = size.width;
    final h = size.height;
    final cx = w / 2;
    final pulse = 0.7 + 0.3 * sin(progress * 2 * pi);
    final r = Radius.circular(radius);

    final leftBorder = Path()
      ..moveTo(cx, 0)
      ..lineTo(radius, 0)
      ..arcToPoint(Offset(0, radius), radius: r, clockwise: false)
      ..lineTo(0, h - radius)
      ..arcToPoint(Offset(radius, h), radius: r, clockwise: false)
      ..lineTo(cx, h);

    final rightBorder = Path()
      ..moveTo(cx, 0)
      ..lineTo(w - radius, 0)
      ..arcToPoint(Offset(w, radius), radius: r)
      ..lineTo(w, h - radius)
      ..arcToPoint(Offset(w - radius, h), radius: r)
      ..lineTo(cx, h);

    void neon(Path path, Color glow, Color core) {
      canvas.drawPath(
        path,
        Paint()
          ..color = glow.withValues(alpha: 0.6 * pulse)
          ..strokeWidth = 4
          ..style = PaintingStyle.stroke
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8),
      );
      canvas.drawPath(
        path,
        Paint()
          ..color = core.withValues(alpha: 0.9 * pulse)
          ..strokeWidth = 2
          ..style = PaintingStyle.stroke,
      );
    }

    neon(leftBorder, const Color(0xFFFF007F), const Color(0xFFFF1493));
    neon(rightBorder, const Color(0xFF00E5FF), const Color(0xFF00B0FF));

    final spark = Paint()
      ..color = Colors.white
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3);
    for (var i = 0; i < 3; i++) {
      final t = (progress + i * 0.33) % 1.0;
      canvas.drawCircle(Offset(cx * (1 - t), 0), 2.2, spark);
      canvas.drawCircle(Offset(cx + cx * t, h), 2.2, spark);
    }
  }

  @override
  bool shouldRepaint(covariant _PkVideoAuraPainter oldDelegate) => oldDelegate.radius != radius;
}

/// Glossy pink/blue clash bar with a glowing white oval at the junction.
class _PkScoreBarPainter extends CustomPainter {
  final double leftRatio;

  _PkScoreBarPainter({required this.leftRatio});

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final cx = w * leftRatio;

    canvas.drawRect(
      Rect.fromLTWH(0, 0, cx, h),
      Paint()
        ..shader = const LinearGradient(
          colors: [Color(0xFFFF0055), Color(0xFFFF007F), Color(0xFFFF1A88)],
        ).createShader(Rect.fromLTWH(0, 0, cx, h)),
    );
    canvas.drawRect(
      Rect.fromLTWH(cx, 0, w - cx, h),
      Paint()
        ..shader = const LinearGradient(
          colors: [Color(0xFF0072FF), Color(0xFF00A6FF), Color(0xFF00F0FF)],
        ).createShader(Rect.fromLTWH(cx, 0, w - cx, h)),
    );

    // Top gloss
    final gloss = Rect.fromLTWH(0, 0, w, h * 0.45);
    canvas.drawRect(
      gloss,
      Paint()
        ..shader = LinearGradient(
          colors: [Colors.white.withValues(alpha: 0.42), Colors.white.withValues(alpha: 0.1), Colors.transparent],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ).createShader(gloss),
    );

    // Junction oval
    final oval = Rect.fromCenter(center: Offset(cx, h / 2), width: 6.5, height: h * 0.9);
    canvas.drawOval(
      oval,
      Paint()
        ..color = Colors.white.withValues(alpha: 0.85)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 7),
    );
    canvas.drawOval(oval, Paint()..color = Colors.white);
  }

  @override
  bool shouldRepaint(covariant _PkScoreBarPainter oldDelegate) => oldDelegate.leftRatio != leftRatio;
}
