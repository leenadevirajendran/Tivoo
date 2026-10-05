import 'dart:async';
import 'package:flutter/material.dart';
import '../../../../core/constants/app_assets.dart';
import '../../../../core/widgets/custom_avatar.dart';
import '../../../../core/widgets/luxury_atmosphere_background.dart';
import '../../../live_stream/domain/models/gift_item.dart';
import '../../../live_stream/domain/models/live_comment.dart';
import '../../../live_stream/presentation/widgets/active_gift_animation_overlay.dart';
import '../../../live_stream/presentation/widgets/floating_hearts_overlay.dart';
import '../../../live_stream/presentation/widgets/floating_stars_overlay.dart';
import '../../../live_stream/presentation/widgets/gift_bottom_sheet.dart';

/// 5-Step Chat Room Flow with Yellow/Gold Luxury Theme & Audio/Video Support:
/// Step 1: Chat Room List Screen (Header: ← Chat Room 🔍, filter chips, room cards, "+ Create Chat Room")
/// Step 2: Tap Join (Room details preview modal: Host avatar, name, tag, capacity, Join / Cancel)
/// Step 3: Inside Chat Room (Audio & Video 3x3 9-seat grid, Host Diya + members + "+ Invite",
///         Audio/Video mode switch, Mic, Sound, Gift, Star, More, live chat stream & input bar)
/// Step 4: Host Ends Room Modal ("End Chat Room? All members will be removed...", Cancel / End Room)
/// Step 5: Room Ended Final Page (Tiki/Tivoo branding, 3D mic with crown, ribbon, Host card, 4 stats, "Back to Home")
class ChatRoomPartyScreen extends StatefulWidget {
  final int initialStage;
  final VoidCallback? onBack;
  final bool isEmbeddedInHome;
  final ValueChanged<int>? onStageChanged;

  const ChatRoomPartyScreen({
    super.key,
    this.initialStage = 1, // Default starts on Step 1: Chat Room List
    this.onBack,
    this.isEmbeddedInHome = false,
    this.onStageChanged,
  });

  @override
  State<ChatRoomPartyScreen> createState() => _ChatRoomPartyScreenState();
}

class _ChatRoomPartyScreenState extends State<ChatRoomPartyScreen>
    with TickerProviderStateMixin {
  final GlobalKey<ActiveGiftAnimationOverlayState> _activeGiftKey = GlobalKey();
  final GlobalKey<FloatingHeartsOverlayState> _heartsKey = GlobalKey();
  final GlobalKey<FloatingStarsOverlayState> _starsKey = GlobalKey();

  // Navigation stage:
  // 1 = Step 1: Chat Room List
  // 3 = Step 3: Inside Chat Room (Audio / Video Talk Mode - 9 Seats)
  // 5 = Step 5: Room Ended Final Summary Page
  late int _currentStage;

  // Selected Room Data
  late Map<String, dynamic> _selectedRoom;

  // Filter chips in Step 1
  int _selectedFilterIndex = 0;
  final List<String> _filters = [
    'All',
    '🎙️ Audio',
    '📹 Video',
    'Trending',
    'Friends',
  ];

  // Room mode in Step 3: Audio vs Video
  bool _isVideoRoom = false;

  // Mic controls
  bool _isMicMuted = false;
  int _totalStarsCount = 12560;

  // Viewer-side interactive member selection & gifts (Matching Reference Poster)
  int? _selectedMemberIndex;
  bool _isFollowingSelectedMember = false;
  int _selectedGiftTab = 0; // 0: Stars, 1: Flowers, 2: Special
  final Map<int, String> _memberFloatingGifts = {};

  // PK-Style Comment Capsule & Input Field (Matching User Reference Screenshot)
  bool _showCommentInput = false;
  final TextEditingController _commentInputController = TextEditingController();
  final FocusNode _commentFocusNode = FocusNode();

  // Speaking wave animation controller
  late final AnimationController _waveController;
  late final Animation<double> _waveAnimation;

  // Confetti / Celebration animation for Step 5
  late final AnimationController _celebrationController;
  late final Animation<double> _celebrationAnimation;

  // Room List Data (Matching reference image Step 1)
  late List<Map<String, dynamic>> _roomsList;

  // 9 Seats for Step 3 (High Quality Studio Portraits matching Image 1)
  late List<Map<String, dynamic>> _seats;

  // Live Chat Comments
  late List<LiveComment> _chatMessages;
  final ScrollController _chatScrollController = ScrollController();
  Timer? _ambientTimer;
  Timer? _requestSentTimer;

  @override
  void initState() {
    super.initState();
    _currentStage = widget.initialStage == 0 ? 1 : widget.initialStage;

    _waveController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 950),
    )..repeat(reverse: true);

    _waveAnimation = Tween<double>(begin: 0.94, end: 1.12).animate(
      CurvedAnimation(parent: _waveController, curve: Curves.easeInOut),
    );

    _celebrationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1600),
    )..repeat(reverse: true);

    _celebrationAnimation = Tween<double>(begin: -6.0, end: 6.0).animate(
      CurvedAnimation(parent: _celebrationController, curve: Curves.easeInOut),
    );

    // Step 1 Rooms matching reference image
    _roomsList = [
      {
        'id': 'room_1',
        'hostName': 'Diya_Official',
        'isVerified': true,
        'tagline': "Let's talk & be friends 💕",
        'tag': 'Dream Team',
        'tagIcon': '👑',
        'capacity': '8/9',
        'viewers': '128',
        'avatar': AppAssets.avatarDiya,
        'isVideo': false, // Audio room
        'isHost': true,
      },
      {
        'id': 'room_2',
        'hostName': 'Arun_kumar',
        'isVerified': true,
        'tagline': 'Good Vibes Only ✨',
        'tag': 'Friends',
        'tagIcon': '👥',
        'capacity': '6/9',
        'viewers': '96',
        'avatar': AppAssets.avatarArun,
        'isVideo': true, // Video room
        'isHost': false,
      },
      {
        'id': 'room_3',
        'hostName': 'Sneha_Live',
        'isVerified': true,
        'tagline': 'Chill Chat 🥰',
        'tag': 'Happy Family',
        'tagIcon': '👑',
        'capacity': '7/9',
        'viewers': '142',
        'avatar': AppAssets.avatarSneha,
        'isVideo': false, // Audio room
        'isHost': false,
      },
      {
        'id': 'room_4',
        'hostName': 'Vicky_143',
        'isVerified': false,
        'tagline': 'Music & Friends 🎵',
        'tag': 'Rockers',
        'tagIcon': '👑',
        'capacity': '5/9',
        'viewers': '88',
        'avatar': AppAssets.avatarVicky,
        'isVideo': true, // Video room
        'isHost': false,
      },
      {
        'id': 'room_5',
        'hostName': 'Priya_S',
        'isVerified': true,
        'tagline': 'Feel Free to Talk 💕',
        'tag': 'Sweet Hearts',
        'tagIcon': '👑',
        'capacity': '8/9',
        'viewers': '115',
        'avatar': AppAssets.avatarNeha,
        'isVideo': false, // Audio room
        'isHost': false,
      },
    ];

    _selectedRoom = _roomsList.first;
    _isVideoRoom = _selectedRoom['isVideo'] as bool;

    // Step 3 9 Seats: Ultra HD Studio Portraits matching Poster (9 People Live Together)
    // Seat 1: Host Diya (Red mic with Host badge)
    // Seat 2: Arun (Green mic)
    // Seat 3: Sneha (Green mic)
    // Seat 4: Karthik (Green mic)
    // Seat 5: Priya (Red mic)
    // Seat 6: Vicky (Red mic)
    // Seat 7: Neha (Green mic)
    // Seat 8: Saran (Green mic)
    // Seat 9: Meena (Green mic)
    _seats = [
      {
        'seat': 1,
        'name': 'Diya',
        'isHost': true,
        'isInvite': false,
        'avatar': AppAssets.avatarDiya,
        'video': AppAssets.video1,
        'isSpeaking': true,
        'isMicOn': false, // Red in reference poster
      },
      {
        'seat': 2,
        'name': 'Arun',
        'isHost': false,
        'isInvite': false,
        'avatar': AppAssets.avatarArun,
        'video': AppAssets.video2,
        'isSpeaking': true,
        'isMicOn': true, // Green in reference poster
      },
      {
        'seat': 3,
        'name': 'Sneha',
        'isHost': false,
        'isInvite': false,
        'avatar': AppAssets.avatarSneha,
        'video': AppAssets.video3,
        'isSpeaking': false,
        'isMicOn': true, // Green in reference poster
      },
      {
        'seat': 4,
        'name': 'Karthik',
        'isHost': false,
        'isInvite': false,
        'avatar': AppAssets.avatarKarthik,
        'video': AppAssets.video4,
        'isSpeaking': true,
        'isMicOn': true, // Green in reference poster
      },
      {
        'seat': 5,
        'name': 'Priya',
        'isHost': false,
        'isInvite': false,
        'avatar': AppAssets.avatarPriya,
        'video': AppAssets.video5,
        'isSpeaking': true,
        'isMicOn': false, // Red in reference poster
      },
      {
        'seat': 6,
        'name': 'Vicky',
        'isHost': false,
        'isInvite': false,
        'avatar': AppAssets.avatarVicky,
        'video': AppAssets.video6,
        'isSpeaking': false,
        'isMicOn': false, // Red in reference poster
      },
      {
        'seat': 7,
        'name': 'Neha',
        'isHost': false,
        'isInvite': false,
        'avatar': AppAssets.avatarNeha,
        'video': AppAssets.video1,
        'isSpeaking': true,
        'isMicOn': true, // Green in reference poster
      },
      {
        'seat': 8,
        'name': 'Saran',
        'isHost': false,
        'isInvite': false,
        'avatar': AppAssets.avatarSaran,
        'video': AppAssets.video2,
        'isSpeaking': true,
        'isMicOn': true, // Green in reference poster
      },
      {
        'seat': 9,
        'name': 'Meena',
        'isHost': false,
        'isInvite': false,
        'avatar': AppAssets.avatarMeena,
        'video': AppAssets.video3,
        'isSpeaking': true,
        'isMicOn': true, // Green in reference poster
      },
    ];

    // Seed chat comments (ordered chronologically matching poster)
    final now = DateTime.now();
    _chatMessages = [
      LiveComment(
        id: 'c1',
        userName: 'User123',
        userAssetPath: AppAssets.avatarArun,
        message: 'So amazing! 👏',
        timestamp: now.subtract(const Duration(seconds: 50)),
      ),
      LiveComment(
        id: 'c2',
        userName: 'Queen',
        userAssetPath: AppAssets.avatarSneha,
        message: 'Super all ❤️🔥',
        timestamp: now.subtract(const Duration(seconds: 40)),
      ),
      LiveComment(
        id: 'c3',
        userName: 'Kavin',
        userAssetPath: AppAssets.avatarKarthik,
        message: 'sent a Star ⭐ to Arun',
        type: LiveCommentType.gift,
        timestamp: now.subtract(const Duration(seconds: 28)),
      ),
      LiveComment(
        id: 'c4',
        userName: 'Anitha',
        userAssetPath: AppAssets.avatarNeha,
        message: 'sent a Bouquet 💐 to Sneha',
        type: LiveCommentType.gift,
        timestamp: now.subtract(const Duration(seconds: 16)),
      ),
      LiveComment(
        id: 'c5',
        userName: 'User123',
        userAssetPath: AppAssets.avatarArun,
        message: 'sent a Rose 🌹 to Priya',
        type: LiveCommentType.gift,
        timestamp: now.subtract(const Duration(seconds: 6)),
      ),
    ];

    // Ambient floating heart generator
    _ambientTimer = Timer.periodic(const Duration(seconds: 5), (_) {
      if (!mounted) return;
      if (_currentStage == 3) {
        _heartsKey.currentState?.addHeart();
      }
    });
  }

  @override
  void dispose() {
    _waveController.dispose();
    _celebrationController.dispose();
    _ambientTimer?.cancel();
    _requestSentTimer?.cancel();
    _commentInputController.dispose();
    _commentFocusNode.dispose();
    _chatScrollController.dispose();
    super.dispose();
  }

  void _setStage(int stage) {
    _requestSentTimer?.cancel();
    setState(() => _currentStage = stage);
    widget.onStageChanged?.call(stage);

    if (stage == 4) {
      // Step 4: After 2.5 seconds of sending request, Host automatically gets notification (Step 5)!
      _requestSentTimer = Timer(const Duration(milliseconds: 2500), () {
        if (mounted && _currentStage == 4) {
          _setStage(5);
        }
      });
    }
  }

  void _openGiftSheet() {
    GiftBottomSheet.show(
      context,
      (gift) => _processGiftSelection(gift),
      recipients: const ['Diya (Host)', 'All 9 Members', 'Arun', 'Sneha'],
      initialRecipient: 'Diya (Host)',
      onGiftWithRecipientSelected: (gift, qty, recipient) {
        _processGiftSelection(gift, quantity: qty, recipient: recipient);
      },
    );
  }

  void _processGiftSelection(
    GiftItem gift, {
    int quantity = 1,
    String recipient = 'Diya (Host)',
  }) {
    final isStar = gift.id.startsWith('star_') ||
        gift.name.toLowerCase().contains('star');

    if (isStar) {
      final multiplier = (gift.diamonds ~/ 5).clamp(1, 20);
      _starsKey.currentState?.addStars(multiplier);
      setState(() => _totalStarsCount += gift.diamonds * quantity);
    } else {
      _heartsKey.currentState?.addHeart();
      _activeGiftKey.currentState?.playGift(
        gift,
        senderName: 'You',
        count: quantity,
        recipient: recipient,
      );
    }

    final newComment = LiveComment(
      id: 'g_${DateTime.now().millisecondsSinceEpoch}',
      userName: 'You',
      userAssetPath: AppAssets.avatarArun,
      message: 'sent ${gift.name} ${gift.icon} x $quantity to $recipient',
      type: LiveCommentType.gift,
      timestamp: DateTime.now(),
    );

    setState(() {
      _chatMessages.add(newComment);
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Sent ${gift.name} ${gift.icon} to $recipient!'),
        backgroundColor: const Color(0xFFFFD600),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _tapStarButton() {
    final targetIndex = _selectedMemberIndex ?? 0;
    _starsKey.currentState?.addStars(3);
    setState(() {
      _totalStarsCount += 10;
      _memberFloatingGifts[targetIndex] = '⭐ +100';
    });
    final targetName = _seats[targetIndex]['name'] as String;
    final newComment = LiveComment(
      id: 'g_${DateTime.now().millisecondsSinceEpoch}',
      userName: 'User123',
      userAssetPath: AppAssets.avatarArun,
      message: 'sent a Star ⭐ to $targetName',
      type: LiveCommentType.gift,
      timestamp: DateTime.now(),
    );
    setState(() {
      _chatMessages.add(newComment);
    });
    Timer(const Duration(milliseconds: 2600), () {
      if (!mounted) return;
      setState(() {
        _memberFloatingGifts.remove(targetIndex);
      });
    });
  }

  void _sendQuickRose() {
    final targetIndex = _selectedMemberIndex ?? 0;
    _sendQuickGiftToMember(targetIndex, 'Rose', '🌹', 10, '+1');
  }

  void _sendQuickGiftToMember(
    int memberIndex,
    String giftName,
    String giftIcon,
    int cost,
    String badge,
  ) {
    if (memberIndex < 0 || memberIndex >= _seats.length) return;
    final member = _seats[memberIndex];
    final memberName = member['name'] as String;

    setState(() {
      _memberFloatingGifts[memberIndex] = '$giftIcon $badge';
      _totalStarsCount += cost;
    });

    if (giftName == 'Star') {
      _starsKey.currentState?.addStars(3);
    } else {
      _heartsKey.currentState?.addHeart();
    }

    final newComment = LiveComment(
      id: 'g_${DateTime.now().millisecondsSinceEpoch}',
      userName: 'User123',
      userAssetPath: AppAssets.avatarArun,
      message: 'sent a $giftName $giftIcon to $memberName',
      type: LiveCommentType.gift,
      timestamp: DateTime.now(),
    );

    setState(() {
      _chatMessages.add(newComment);
    });

    Timer(const Duration(milliseconds: 2600), () {
      if (!mounted) return;
      setState(() {
        _memberFloatingGifts.remove(memberIndex);
      });
    });
  }

  void _handleSendComment(String text) {
    final trimmed = text.trim();
    if (trimmed.isNotEmpty) {
      final newComment = LiveComment(
        id: 'usr_${DateTime.now().millisecondsSinceEpoch}',
        userName: 'User123',
        userAssetPath: AppAssets.avatarArun,
        message: trimmed,
        timestamp: DateTime.now(),
      );
      setState(() {
        _chatMessages.add(newComment);
        _showCommentInput = false;
      });
      _commentInputController.clear();
      _heartsKey.currentState?.addHeart();
    } else {
      setState(() => _showCommentInput = false);
    }
  }

  // ===========================================================================
  // STEP 2: TAP JOIN (ROOM PREVIEW & DETAILS MODAL)
  // ===========================================================================
  void _showJoinPreviewModal(Map<String, dynamic> room) {
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'JoinModal',
      barrierColor: Colors.black.withValues(alpha: 0.78),
      transitionDuration: const Duration(milliseconds: 260),
      pageBuilder: (ctx, anim1, anim2) {
        return Center(
          child: Material(
            color: Colors.transparent,
            child: Container(
              width: MediaQuery.sizeOf(context).width * 0.84,
              padding: const EdgeInsets.fromLTRB(22, 18, 22, 22),
              decoration: BoxDecoration(
                color: const Color(0xFF141224),
                borderRadius: BorderRadius.circular(28),
                border: Border.all(
                  color: const Color(0xFFFFD600).withValues(alpha: 0.45),
                  width: 1.4,
                ),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x33FFD600),
                    blurRadius: 24,
                    spreadRadius: 2,
                    offset: Offset(0, 8),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Close button on top right
                  Align(
                    alignment: Alignment.topRight,
                    child: GestureDetector(
                      onTap: () => Navigator.of(ctx).pop(),
                      child: Container(
                        padding: const EdgeInsets.all(5),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.08),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.close_rounded,
                          color: Colors.white70,
                          size: 18,
                        ),
                      ),
                    ),
                  ),

                  // Big Circular Host Avatar with Crown Badge
                  Stack(
                    alignment: Alignment.bottomRight,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: const Color(0xFFFFD600),
                            width: 2.4,
                          ),
                          boxShadow: const [
                            BoxShadow(
                              color: Color(0x55FFD600),
                              blurRadius: 16,
                            ),
                          ],
                        ),
                        child: CustomAvatar(
                          radius: 46,
                          assetPath: room['avatar'] as String,
                        ),
                      ),
                      Positioned(
                        right: 2,
                        bottom: 2,
                        child: Container(
                          padding: const EdgeInsets.all(5),
                          decoration: const BoxDecoration(
                            color: Color(0xFFFFB300),
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Color(0x66FFB300),
                                blurRadius: 6,
                              ),
                            ],
                          ),
                          child: const Text('👑', style: TextStyle(fontSize: 13)),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),

                  // Host Name + Blue checkmark
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        room['hostName'] as String,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18.5,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      if (room['isVerified'] == true) ...[
                        const SizedBox(width: 5),
                        const Icon(
                          Icons.verified_rounded,
                          color: Color(0xFF29B6F6),
                          size: 17,
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 6),

                  // Room Tagline
                  Text(
                    room['tagline'] as String,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 13.5,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 10),

                  // Team Badge & Audio/Video Indicator
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFF231E3D),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: const Color(0xFFFFD600).withValues(alpha: 0.3),
                          ),
                        ),
                        child: Row(
                          children: [
                            Text(
                              room['tagIcon'] as String,
                              style: const TextStyle(fontSize: 12),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              room['tag'] as String,
                              style: const TextStyle(
                                color: Color(0xFFFFD600),
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: (room['isVideo'] as bool)
                              ? const Color(0xFF381F56)
                              : const Color(0xFF1E334D),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          (room['isVideo'] as bool) ? '📹 Video' : '🎙️ Audio',
                          style: TextStyle(
                            color: (room['isVideo'] as bool)
                                ? const Color(0xFFE040FB)
                                : const Color(0xFF40C4FF),
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // Capacity
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.person_outline_rounded,
                        color: Colors.white60,
                        size: 15,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        room['capacity'] as String,
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 22),

                  // Big Purple/Pink Gradient "Join Room" Button (Image 3 Step 3)
                  GestureDetector(
                    onTap: () {
                      Navigator.of(ctx).pop();
                      _startJoinRequestFlow(context, room);
                    },
                    child: Container(
                      width: double.infinity,
                      height: 48,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFFBA43F6), Color(0xFFE040FB)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: const [
                          BoxShadow(
                            color: Color(0x66BA43F6),
                            blurRadius: 14,
                            offset: Offset(0, 4),
                          ),
                        ],
                      ),
                      child: const Center(
                        child: Text(
                          'Join Room',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),

                  // "Cancel" button
                  GestureDetector(
                    onTap: () => Navigator.of(ctx).pop(),
                    child: Container(
                      width: double.infinity,
                      height: 44,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.06),
                        borderRadius: BorderRadius.circular(22),
                      ),
                      child: const Center(
                        child: Text(
                          'Cancel',
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 14.5,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  // ===========================================================================
  // IMAGE 3 FLOW: JOIN REQUEST SENT -> HOST NOTIFICATION -> ACCEPT / REJECT
  // ===========================================================================

  // Step 4: Show "Join Request Sent" Modal (Image 3 Step 4)
  void _startJoinRequestFlow(BuildContext parentContext, Map<String, dynamic> room) {
    setState(() {
      _selectedRoom = room;
      _isVideoRoom = room['isVideo'] as bool;
    });

    showDialog(
      context: parentContext,
      barrierDismissible: false,
      barrierColor: Colors.black.withValues(alpha: 0.75),
      builder: (requestDialogCtx) {
        // Auto trigger Host Notification after 1.8s (simulation of Image 3 Step 5)
        Timer? simTimer;
        simTimer = Timer(const Duration(milliseconds: 1800), () {
          if (requestDialogCtx.mounted) {
            Navigator.of(requestDialogCtx).pop(); // dismiss request sent
            _showHostNotificationDialog(parentContext, room);
          }
        });

        return Dialog(
          backgroundColor: const Color(0xFF0F1424),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
            side: BorderSide(color: const Color(0xFF2979FF).withValues(alpha: 0.4), width: 1.2),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 26),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Paper plane in glowing circular container (Image 3 Step 4)
                Container(
                  width: 72,
                  height: 72,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: const LinearGradient(
                      colors: [Color(0xFF2979FF), Color(0xFF00B0FF)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF00B0FF).withValues(alpha: 0.5),
                        blurRadius: 16,
                      ),
                    ],
                  ),
                  child: const Center(
                    child: Icon(
                      Icons.send_rounded,
                      color: Colors.white,
                      size: 34,
                    ),
                  ),
                ),
                const SizedBox(height: 18),

                // Title: Join Request Sent
                const Text(
                  'Join Request Sent',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 8),

                // Description
                const Text(
                  'Your request has been sent to the host. Please wait for acceptance.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 13,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 20),

                // Hourglass icon
                const Icon(
                  Icons.hourglass_empty_rounded,
                  color: Color(0xFFFFD600),
                  size: 26,
                ),
                const SizedBox(height: 18),

                // Cancel Request Button
                GestureDetector(
                  onTap: () {
                    simTimer?.cancel();
                    Navigator.of(requestDialogCtx).pop();
                    ScaffoldMessenger.of(parentContext).showSnackBar(
                      const SnackBar(
                        content: Text('Join request cancelled'),
                        duration: Duration(seconds: 1),
                      ),
                    );
                  },
                  child: Container(
                    width: double.infinity,
                    height: 42,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(21),
                      border: Border.all(color: Colors.white24, width: 1),
                    ),
                    child: const Center(
                      child: Text(
                        'Cancel Request',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // Step 5: Host Gets Notification Modal (Image 3 Step 5 & Screen A)
  void _showHostNotificationDialog(BuildContext parentContext, Map<String, dynamic> room) {
    showDialog(
      context: parentContext,
      barrierDismissible: false,
      barrierColor: Colors.black.withValues(alpha: 0.70),
      builder: (hostDialogCtx) {
        return Dialog(
          backgroundColor: const Color(0xFF0F1424),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
            side: BorderSide(color: const Color(0xFFFF2D78).withValues(alpha: 0.5), width: 1.2),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Top Row: Title + Close
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Join Request (1)',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    GestureDetector(
                      onTap: () => Navigator.of(hostDialogCtx).pop(),
                      child: const Icon(Icons.close_rounded, color: Colors.white54, size: 20),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Applicant Avatar & Name (Image 3 Step 5: "Karthi wants to join your room")
                Row(
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                      ),
                      child: ClipOval(
                        child: CustomAvatar(radius: 22, assetPath: AppAssets.status1),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: const [
                          Text(
                            'Karthi',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 2),
                          Text(
                            'wants to join your room',
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 12.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // Reject (Red) & Accept (Green) Buttons (Image 3 Step 5)
                Row(
                  children: [
                    // Reject Button
                    Expanded(
                      child: GestureDetector(
                        onTap: () {
                          Navigator.of(hostDialogCtx).pop();
                          _showRejectedAlert(parentContext);
                        },
                        child: Container(
                          height: 42,
                          decoration: BoxDecoration(
                            color: const Color(0xFFD32F2F),
                            borderRadius: BorderRadius.circular(21),
                            boxShadow: const [
                              BoxShadow(color: Color(0x55D32F2F), blurRadius: 8),
                            ],
                          ),
                          child: const Center(
                            child: Text(
                              'Reject',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),

                    // Accept Button
                    Expanded(
                      child: GestureDetector(
                        onTap: () {
                          Navigator.of(hostDialogCtx).pop();
                          // Show "You joined the room" banner & enter room (Image 3 Step 6 / D)
                          _setStage(3); // Enter Chat Room!
                          ScaffoldMessenger.of(parentContext).showSnackBar(
                            SnackBar(
                              backgroundColor: const Color(0xFF00C853),
                              behavior: SnackBarBehavior.floating,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              content: Row(
                                children: const [
                                  Icon(Icons.check_circle_rounded, color: Colors.white),
                                  SizedBox(width: 8),
                                  Text(
                                    'You joined the room',
                                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                                  ),
                                ],
                              ),
                              duration: const Duration(seconds: 2),
                            ),
                          );
                        },
                        child: Container(
                          height: 42,
                          decoration: BoxDecoration(
                            color: const Color(0xFF00C853),
                            borderRadius: BorderRadius.circular(21),
                            boxShadow: const [
                              BoxShadow(color: Color(0x5500C853), blurRadius: 8),
                            ],
                          ),
                          child: const Center(
                            child: Text(
                              'Accept',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
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
      },
    );
  }

  // Step B: User Gets Rejected Alert (Image 3 B & C)
  void _showRejectedAlert(BuildContext parentContext) {
    showDialog(
      context: parentContext,
      builder: (alertCtx) {
        return Dialog(
          backgroundColor: const Color(0xFF0F1424),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
            side: const BorderSide(color: Colors.white12),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Red (X) Icon
                Container(
                  width: 56,
                  height: 56,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: Color(0xFFD32F2F),
                  ),
                  child: const Center(
                    child: Icon(Icons.close_rounded, color: Colors.white, size: 32),
                  ),
                ),
                const SizedBox(height: 16),

                // "Your request was rejected"
                const Text(
                  'Your request was rejected',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 6),

                // "You will continue watching as a viewer"
                const Text(
                  'You will continue watching as a viewer.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 20),

                // OK Button
                GestureDetector(
                  onTap: () {
                    Navigator.of(alertCtx).pop();
                    _setStage(3); // Enter room in viewer mode!
                  },
                  child: Container(
                    width: double.infinity,
                    height: 42,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF2979FF), Color(0xFF651FFF)],
                      ),
                      borderRadius: BorderRadius.circular(21),
                    ),
                    child: const Center(
                      child: Text(
                        'OK',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // ===========================================================================
  // STEP 4: HOST ENDS ROOM CONFIRMATION MODAL
  // ===========================================================================
  void _showEndRoomDialog() {
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'EndRoomModal',
      barrierColor: Colors.black.withValues(alpha: 0.82),
      transitionDuration: const Duration(milliseconds: 240),
      pageBuilder: (ctx, anim1, anim2) {
        return Center(
          child: Material(
            color: Colors.transparent,
            child: Container(
              width: MediaQuery.sizeOf(context).width * 0.82,
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 20),
              decoration: BoxDecoration(
                color: const Color(0xFF141124),
                borderRadius: BorderRadius.circular(26),
                border: Border.all(
                  color: const Color(0xFFFF2D55).withValues(alpha: 0.5),
                  width: 1.3,
                ),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x33FF2D55),
                    blurRadius: 24,
                    spreadRadius: 1,
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Glowing Power Button Icon (Matching Image 1 Step 4)
                  Container(
                    width: 58,
                    height: 58,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: const Color(0xFF2E1220),
                      border: Border.all(
                        color: const Color(0xFFFF2D55),
                        width: 1.5,
                      ),
                      boxShadow: const [
                        BoxShadow(
                          color: Color(0x66FF2D55),
                          blurRadius: 16,
                        ),
                      ],
                    ),
                    child: const Center(
                      child: Icon(
                        Icons.power_settings_new_rounded,
                        color: Color(0xFFFF2D55),
                        size: 30,
                      ),
                    ),
                  ),
                  const SizedBox(height: 18),

                  // Title: "End Chat Room?"
                  const Text(
                    'End Chat Room?',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 8),

                  // Subtitle: "All members will be removed and the room will end."
                  const Text(
                    'All members will be removed\nand the room will end.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 13,
                      height: 1.35,
                    ),
                  ),
                  const SizedBox(height: 22),

                  // Row: [Cancel] & [End Room]
                  Row(
                    children: [
                      Expanded(
                        child: GestureDetector(
                          onTap: () => Navigator.of(ctx).pop(),
                          child: Container(
                            height: 44,
                            decoration: BoxDecoration(
                              color: const Color(0xFF221E36),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: Colors.white12),
                            ),
                            child: const Center(
                              child: Text(
                                'Cancel',
                                style: TextStyle(
                                  color: Colors.white70,
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: GestureDetector(
                          onTap: () {
                            Navigator.of(ctx).pop();
                            _setStage(5); // Navigate to Step 5: Room Ended Final Page!
                          },
                          child: Container(
                            height: 44,
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [Color(0xFFFF2D55), Color(0xFFCC0836)],
                              ),
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: const [
                                BoxShadow(
                                  color: Color(0x66FF2D55),
                                  blurRadius: 10,
                                  offset: Offset(0, 3),
                                ),
                              ],
                            ),
                            child: const Center(
                              child: Text(
                                'End Room',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
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

  // ===========================================================================
  // "+ CREATE CHAT ROOM" MODAL SHEET (Audio Room vs Video Room)
  // ===========================================================================
  void _showCreateRoomSheet() {
    String roomTitle = 'My Fun Party';
    String roomTag = 'Dream Team';
    bool isVideoSelected = false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Container(
              padding: EdgeInsets.fromLTRB(
                20,
                16,
                20,
                MediaQuery.of(ctx).viewInsets.bottom + 24,
              ),
              decoration: BoxDecoration(
                color: const Color(0xFF141224),
                borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
                border: Border.all(
                  color: const Color(0xFFFFD600).withValues(alpha: 0.4),
                  width: 1.2,
                ),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x44FFD600),
                    blurRadius: 20,
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.white30,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),

                  // Header
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Create Chat Room',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 19,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      GestureDetector(
                        onTap: () => Navigator.of(ctx).pop(),
                        child: const Icon(
                          Icons.close_rounded,
                          color: Colors.white60,
                          size: 20,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Choose Type: Audio Room vs Video Room
                  const Text(
                    'Room Mode',
                    style: TextStyle(
                      color: Color(0xFFFFD600),
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: GestureDetector(
                          onTap: () => setModalState(() => isVideoSelected = false),
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            decoration: BoxDecoration(
                              color: !isVideoSelected
                                  ? const Color(0xFFFFD600)
                                  : const Color(0xFF1D1A30),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: !isVideoSelected
                                    ? const Color(0xFFFFD600)
                                    : Colors.white12,
                              ),
                            ),
                            child: Column(
                              children: [
                                Icon(
                                  Icons.mic_rounded,
                                  color: !isVideoSelected ? Colors.black : Colors.white,
                                  size: 24,
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  '🎙️ Audio Room',
                                  style: TextStyle(
                                    color: !isVideoSelected ? Colors.black : Colors.white,
                                    fontWeight: FontWeight.w800,
                                    fontSize: 13,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: GestureDetector(
                          onTap: () => setModalState(() => isVideoSelected = true),
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            decoration: BoxDecoration(
                              color: isVideoSelected
                                  ? const Color(0xFFFFD600)
                                  : const Color(0xFF1D1A30),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: isVideoSelected
                                    ? const Color(0xFFFFD600)
                                    : Colors.white12,
                              ),
                            ),
                            child: Column(
                              children: [
                                Icon(
                                  Icons.videocam_rounded,
                                  color: isVideoSelected ? Colors.black : Colors.white,
                                  size: 24,
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  '📹 Video Room',
                                  style: TextStyle(
                                    color: isVideoSelected ? Colors.black : Colors.white,
                                    fontWeight: FontWeight.w800,
                                    fontSize: 13,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Room Name Input
                  const Text(
                    'Room Title',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1F1C33),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: Colors.white12),
                    ),
                    child: TextField(
                      style: const TextStyle(color: Colors.white, fontSize: 14),
                      decoration: const InputDecoration(
                        hintText: 'Enter room name...',
                        hintStyle: TextStyle(color: Colors.white38),
                        border: InputBorder.none,
                      ),
                      onChanged: (v) => roomTitle = v,
                    ),
                  ),
                  const SizedBox(height: 14),

                  // Team Tags
                  const Text(
                    'Category / Team Tag',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      '👑 Dream Team',
                      '👥 Friends',
                      '🎵 Music Lovers',
                      '✨ Good Vibes',
                    ].map((tag) {
                      final isSel = roomTag == tag.replaceAll('👑 ', '').replaceAll('👥 ', '').replaceAll('🎵 ', '').replaceAll('✨ ', '');
                      return GestureDetector(
                        onTap: () {
                          setModalState(() {
                            roomTag = tag.replaceAll('👑 ', '').replaceAll('👥 ', '').replaceAll('🎵 ', '').replaceAll('✨ ', '');
                          });
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: isSel ? const Color(0xFFFFD600) : const Color(0xFF221E36),
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(
                              color: isSel ? const Color(0xFFFFD600) : Colors.white12,
                            ),
                          ),
                          child: Text(
                            tag,
                            style: TextStyle(
                              color: isSel ? Colors.black : Colors.white70,
                              fontWeight: isSel ? FontWeight.w900 : FontWeight.w500,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 22),

                  // Start Room Button (Luminous Yellow)
                  GestureDetector(
                    onTap: () {
                      Navigator.of(ctx).pop();
                      final newRoom = {
                        'id': 'room_${DateTime.now().millisecondsSinceEpoch}',
                        'hostName': 'You (Host)',
                        'isVerified': true,
                        'tagline': roomTitle.isEmpty ? 'Welcome to my party!' : roomTitle,
                        'tag': roomTag,
                        'tagIcon': '👑',
                        'capacity': '1/9',
                        'viewers': '1',
                        'avatar': AppAssets.avatarArun,
                        'isVideo': isVideoSelected,
                        'isHost': true,
                      };
                      setState(() {
                        _roomsList.insert(0, newRoom);
                        _selectedRoom = newRoom;
                        _isVideoRoom = isVideoSelected;
                      });
                      _setStage(3); // Enter newly created room!
                    },
                    child: Container(
                      width: double.infinity,
                      height: 48,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFFFFEA00), Color(0xFFFF9100)],
                        ),
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: const [
                          BoxShadow(
                            color: Color(0x66FFD600),
                            blurRadius: 14,
                            offset: Offset(0, 4),
                          ),
                        ],
                      ),
                      child: const Center(
                        child: Text(
                          'Start Room Now',
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 15.5,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return ActiveGiftAnimationOverlay(
      key: _activeGiftKey,
      child: FloatingStarsOverlay(
        key: _starsKey,
        child: FloatingHeartsOverlay(
          key: _heartsKey,
          child: Scaffold(
            backgroundColor: const Color(0xFF090812),
            body: Stack(
              fit: StackFit.expand,
              children: [
                // Deep dark obsidian luxury atmosphere
                const LuxuryAtmosphereBackground(),

                // Active Stage View (Authentic full-screen flow one by one from 1 to 6)
                SafeArea(
                  top: true,
                  bottom: true,
                  child: _buildCurrentStageView(),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }



  // ===========================================================================
  // STAGE ROUTER: STEPS 1 TO 6 AND BRANCHES A TO E
  // ===========================================================================
  Widget _buildCurrentStageView() {
    switch (_currentStage) {
      case 1:
        return _buildStep1HomePageView(); // Step 1: Home Page (Live / PK / Chat Room)
      case 2:
        return _buildStep2ChatRoomListView(); // Step 2: Chat Room List (Hosts live)
      case 3:
        return _buildStep3RoomPreviewView(); // Step 3: Viewer Taps Join
      case 4:
        return _buildStep4JoinRequestSentView(); // Step 4: Join Request Sent
      case 5:
        return _buildStep5HostNotificationView(); // Step 5 / A: Host Gets Notification & Rejects/Accepts
      case 6:
        return _buildStep6AcceptedRoomView(); // Step 6 / D: Host Accepts / If Accepted - User Enters
      case 7:
        return _buildStepBRejectedAlertView(); // Step B: User Gets Rejected Alert
      case 8:
        return _buildStepCViewerRoomView(); // Step C: User Stays as Viewer
      case 9:
        return _buildStepEFlowSummaryView(); // Step E: Flow Summary (User Side)
      case 10:
        return _buildRoomListView(); // Legacy list view
      case 11:
        return _buildInsideChatRoomView(); // Legacy full studio interactive view
      case 12:
        return _buildRoomEndedView(); // Legacy room ended summary
      default:
        return _buildStep1HomePageView();
    }
  }

  // ===========================================================================
  // 1: HOME PAGE (Live / PK / Chat Room) - Matching Image 1
  // ===========================================================================
  Widget _buildStep1HomePageView() {
    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 1. Hero Card: "Join a Chat Room - Talk with the World" (Image 1)
                _buildJoinChatRoomBanner(),
                const SizedBox(height: 18),

                // 2. Section Header: "Popular Rooms" + "See All"
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Popular Rooms',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16.5,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.3,
                      ),
                    ),
                    GestureDetector(
                      onTap: () => _setStage(2),
                      child: const Text(
                        'See All',
                        style: TextStyle(
                          color: Color(0xFFB39DDB),
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // 3. 2x2 Grid of 4 Popular Rooms (Image 1)
                _buildPopularRoomsGrid(),
                const SizedBox(height: 20),

                // 4. Section Header: "Recommended for You"
                const Text(
                  'Recommended for You',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.3,
                  ),
                ),
                const SizedBox(height: 12),

                // 5. Recommended List Items (Image 1)
                _buildRecommendedItem(
                  title: 'Chill Vibes',
                  viewers: '92',
                  imageAsset: AppAssets.status1,
                  onJoin: () => _setStage(3),
                ),
                const SizedBox(height: 10),
                _buildRecommendedItem(
                  title: 'Movie Talks',
                  viewers: '76',
                  imageAsset: AppAssets.status2,
                  onJoin: () => _setStage(3),
                ),
                const SizedBox(height: 10),
                _buildRecommendedItem(
                  title: 'Life Coaching',
                  viewers: '54',
                  imageAsset: AppAssets.status3,
                  onJoin: () => _setStage(3),
                ),
                const SizedBox(height: 12),
              ],
            ),
          ),
        ),

        // Bottom "+ Create Chat Room" Pink Pill Button (Matching Image 3)
        _buildCreateChatRoomButton(),
      ],
    );
  }

  /// Prominent Pink Pill Button: "+ Create Chat Room" (Matching Image 3)
  Widget _buildCreateChatRoomButton() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
      child: GestureDetector(
        onTap: _showCreateRoomSheet,
        child: Container(
          width: double.infinity,
          height: 52,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFFFF007F), Color(0xFFFF2D78)],
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
            ),
            borderRadius: BorderRadius.circular(26),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFFFF007F).withValues(alpha: 0.50),
                blurRadius: 18,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: const [
              Icon(Icons.add_rounded, color: Colors.white, size: 26),
              SizedBox(width: 8),
              Text(
                'Create Chat Room',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16.5,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 0.3,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Hero Banner: Lavender/light-blue gradient card with 3D smiling microphone character (Image 1)
  Widget _buildJoinChatRoomBanner() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(18, 16, 14, 16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFE4DAFB), Color(0xFFC8DCFB)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: const [
          BoxShadow(
            color: Color(0x332979FF),
            blurRadius: 18,
            offset: Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          // Left text column
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Join a',
                  style: TextStyle(
                    color: Color(0xFF3B2874),
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 1),
                const Text(
                  'Chat Room',
                  style: TextStyle(
                    color: Color(0xFF1B1B53),
                    fontSize: 23,
                    fontWeight: FontWeight.w900,
                    letterSpacing: -0.2,
                  ),
                ),
                const SizedBox(height: 3),
                const Text(
                  'Talk with the World',
                  style: TextStyle(
                    color: Color(0xFF5B5391),
                    fontSize: 12.5,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 12),

                // "Join Now" Blue Pill Button (Image 1)
                GestureDetector(
                  onTap: () => _setStage(2),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 8),
                    decoration: BoxDecoration(
                      color: const Color(0xFF2979FF),
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF2979FF).withValues(alpha: 0.45),
                          blurRadius: 10,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: const Text(
                      'Join Now',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 13,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 0.3,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Right 3D Blue Smiling Microphone Character Graphic
          _build3DMicrophoneCharacter(),
        ],
      ),
    );
  }

  /// 3D Blue Smiling Microphone Character Graphic (Image 1)
  Widget _build3DMicrophoneCharacter() {
    return SizedBox(
      width: 110,
      height: 115,
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.center,
        children: [
          // Star sparkles
          const Positioned(
            top: 2,
            left: 12,
            child: Text('✦', style: TextStyle(color: Color(0xFF64B5F6), fontSize: 16)),
          ),
          const Positioned(
            top: 0,
            right: 10,
            child: Text('★', style: TextStyle(color: Color(0xFFFF4081), fontSize: 20)),
          ),
          const Positioned(
            top: 36,
            right: 0,
            child: Text('✦', style: TextStyle(color: Color(0xFFFFD54F), fontSize: 16)),
          ),
          const Positioned(
            bottom: 24,
            left: 2,
            child: Text('✦', style: TextStyle(color: Colors.white, fontSize: 14)),
          ),

          // Stand circular base
          Positioned(
            bottom: 6,
            child: Container(
              width: 52,
              height: 14,
              decoration: BoxDecoration(
                color: const Color(0xFF1565C0),
                borderRadius: BorderRadius.circular(7),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF2979FF).withValues(alpha: 0.5),
                    blurRadius: 10,
                  ),
                ],
              ),
            ),
          ),

          // Stand stem
          Positioned(
            bottom: 15,
            child: Container(
              width: 9,
              height: 22,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF42A5F5), Color(0xFF1976D2)],
                ),
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ),

          // Microphone Capsule Head with smiling face
          Positioned(
            top: 14,
            child: Container(
              width: 62,
              height: 74,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Color(0xFF64B5F6),
                    Color(0xFF2979FF),
                    Color(0xFF0D47A1),
                  ],
                ),
                borderRadius: BorderRadius.circular(31),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF1E88E5).withValues(alpha: 0.6),
                    blurRadius: 14,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // Top gloss shine highlight
                  Positioned(
                    top: 6,
                    left: 14,
                    child: Container(
                      width: 24,
                      height: 5,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.5),
                        borderRadius: BorderRadius.circular(3),
                      ),
                    ),
                  ),

                  // Happy Eyes & Cute Smile
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const SizedBox(height: 6),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            width: 5,
                            height: 7,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(3),
                            ),
                          ),
                          const SizedBox(width: 14),
                          Container(
                            width: 5,
                            height: 7,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(3),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 5),
                      // Smiling open mouth
                      Container(
                        width: 18,
                        height: 10,
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.vertical(bottom: Radius.circular(10)),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// 2x2 Grid of Popular Rooms (Image 1)
  Widget _buildPopularRoomsGrid() {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 12,
      crossAxisSpacing: 12,
      childAspectRatio: 1.25,
      children: [
        // 1. Friends Forever (Coral to Purple)
        _buildPopularRoomCard(
          title: 'Friends Forever',
          viewers: '128',
          gradientColors: const [Color(0xFFFF5E62), Color(0xFF8E24AA)],
          hostAvatar: AppAssets.avatarArun,
          listenerAvatars: const [
            AppAssets.avatarDiya,
            AppAssets.avatarPriya,
            AppAssets.avatarSneha,
            AppAssets.avatarNeha,
          ],
          onTap: () => _setStage(2),
        ),

        // 2. Music Lovers (Indigo to Purple)
        _buildPopularRoomCard(
          title: 'Music Lovers',
          viewers: '256',
          gradientColors: const [Color(0xFF3949AB), Color(0xFF8E24AA)],
          hostAvatar: AppAssets.avatarKarthik,
          listenerAvatars: const [
            AppAssets.avatarPriya,
            AppAssets.avatarMeena,
            AppAssets.avatarSaran,
          ],
          onTap: () => _setStage(2),
        ),

        // 3. Tamil Pasanga (Electric Cyan to Blue)
        _buildPopularRoomCard(
          title: 'Tamil Pasanga',
          viewers: '89',
          gradientColors: const [Color(0xFF00B0FF), Color(0xFF1565C0)],
          hostAvatar: AppAssets.avatarSaran,
          listenerAvatars: const [
            AppAssets.avatarArun,
            AppAssets.avatarVicky,
            AppAssets.avatarKarthik,
            AppAssets.avatarDiya,
          ],
          onTap: () => _setStage(2),
        ),

        // 4. Global Talk (Emerald Green to Teal)
        _buildPopularRoomCard(
          title: 'Global Talk',
          viewers: '320',
          gradientColors: const [Color(0xFF00E676), Color(0xFF00897B)],
          hostAvatar: AppAssets.avatarMeena,
          listenerAvatars: const [
            AppAssets.avatarSneha,
            AppAssets.avatarNeha,
            AppAssets.avatarDiya,
            AppAssets.avatarPriya,
          ],
          onTap: () => _setStage(2),
        ),
      ],
    );
  }

  /// Popular Room Card with Listener Avatars Stack and Host Circular Photo (Image 1)
  Widget _buildPopularRoomCard({
    required String title,
    required String viewers,
    required List<Color> gradientColors,
    required String hostAvatar,
    required List<String> listenerAvatars,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: gradientColors,
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: gradientColors.last.withValues(alpha: 0.35),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 13.5,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 3),
                Row(
                  children: [
                    const Icon(Icons.person, color: Colors.white70, size: 13),
                    const SizedBox(width: 3),
                    Text(
                      viewers,
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 11.5,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ],
            ),

            // Bottom row: Overlapping listeners on left, Host photo on right
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                // Overlapping avatar circles
                SizedBox(
                  height: 22,
                  child: Row(
                    children: [
                      for (int i = 0; i < listenerAvatars.length; i++)
                        Transform.translate(
                          offset: Offset(-i * 7.0, 0),
                          child: Container(
                            width: 20,
                            height: 20,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.white, width: 1.2),
                              image: DecorationImage(
                                image: AssetImage(listenerAvatars[i]),
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),

                // Host circular avatar
                Container(
                  width: 34,
                  height: 34,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 1.5),
                    boxShadow: const [
                      BoxShadow(
                        color: Colors.black38,
                        blurRadius: 6,
                        offset: Offset(0, 2),
                      ),
                    ],
                    image: DecorationImage(
                      image: AssetImage(hostAvatar),
                      fit: BoxFit.cover,
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

  /// Recommended For You Row Item (Image 1)
  Widget _buildRecommendedItem({
    required String title,
    required String viewers,
    required String imageAsset,
    required VoidCallback onJoin,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFF141126),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white10),
      ),
      child: Row(
        children: [
          // Thumbnail rounded image
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.asset(
              imageAsset,
              width: 48,
              height: 48,
              fit: BoxFit.cover,
            ),
          ),
          const SizedBox(width: 14),

          // Title & Viewers
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(Icons.person, color: Colors.white60, size: 13),
                    const SizedBox(width: 3),
                    Text(
                      viewers,
                      style: const TextStyle(
                        color: Colors.white60,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Purple/Indigo "Join" pill button (Image 1)
          GestureDetector(
            onTap: onJoin,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 8),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF651FFF), Color(0xFF7C4DFF)],
                ),
                borderRadius: BorderRadius.circular(18),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x44651FFF),
                    blurRadius: 8,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: const Text(
                'Join',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 13,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }



  // ===========================================================================
  // 2: CHAT ROOM LIST (Hosts who are live in chat rooms) - Matching Image 2
  // ===========================================================================
  Widget _buildStep2ChatRoomListView() {
    final liveRooms = [
      {
        'host': 'Nila 💕',
        'title': 'Friends Talk 📢',
        'tags': ['Friendship', 'Tamil'],
        'capacity': '8/9',
        'avatar': AppAssets.avatarDiya,
      },
      {
        'host': 'Priya',
        'title': 'Open Talk',
        'tags': ['Casual', 'Talk'],
        'capacity': '6/9',
        'avatar': AppAssets.avatarPriya,
      },
      {
        'host': 'Kavi',
        'title': 'Music Friends',
        'tags': ['Music', 'Tamil'],
        'capacity': '5/9',
        'avatar': AppAssets.avatarSneha,
      },
      {
        'host': 'Divya',
        'title': 'Fun Chat',
        'tags': ['Friends', 'Fun'],
        'capacity': '7/9',
        'avatar': AppAssets.avatarNeha,
      },
    ];

    return Column(
      children: [
        // Header: Back Arrow + Live Chat Rooms (Image 2)
        Padding(
          padding: const EdgeInsets.fromLTRB(6, 6, 14, 10),
          child: Row(
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 20),
                onPressed: () => _setStage(1),
              ),
              const SizedBox(width: 4),
              const Text(
                'Live Chat Rooms',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 0.3,
                ),
              ),
            ],
          ),
        ),

        // List of 4 Host Cards (Image 2)
        Expanded(
          child: ListView.builder(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
            itemCount: liveRooms.length,
            itemBuilder: (context, index) {
              final room = liveRooms[index];
              final tags = room['tags'] as List<String>;

              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFF131024),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: index == 0
                        ? const Color(0xFFE91E63).withValues(alpha: 0.35)
                        : Colors.white10,
                  ),
                  boxShadow: const [
                    BoxShadow(
                      color: Colors.black45,
                      blurRadius: 10,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    // Square photo thumbnail with Golden Crown and "Chat Live" pink pill (Image 2)
                    Stack(
                      alignment: Alignment.bottomCenter,
                      clipBehavior: Clip.none,
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(16),
                          child: Image.asset(
                            room['avatar'] as String,
                            width: 66,
                            height: 66,
                            fit: BoxFit.cover,
                          ),
                        ),

                        // Golden Crown 👑 on top-left
                        Positioned(
                          top: -3,
                          left: -3,
                          child: Container(
                            padding: const EdgeInsets.all(3),
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                              color: Color(0xFF21153B),
                            ),
                            child: const Text('👑', style: TextStyle(fontSize: 13)),
                          ),
                        ),

                        // Pink "Chat Live" badge at bottom
                        Positioned(
                          bottom: -4,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [Color(0xFFFF007F), Color(0xFFFF4081)],
                              ),
                              borderRadius: BorderRadius.circular(10),
                              boxShadow: const [
                                BoxShadow(
                                  color: Color(0x66FF007F),
                                  blurRadius: 6,
                                ),
                              ],
                            ),
                            child: const Text(
                              'Chat Live',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 9.5,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(width: 14),

                    // Middle Column: Host Name, Title, and Tags
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            room['host'] as String,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            room['title'] as String,
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 12.5,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          if (index == 0) ...[
                            const SizedBox(height: 5),
                            Row(
                              children: [
                                for (final tag in tags) ...[
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                    margin: const EdgeInsets.only(right: 6),
                                    decoration: BoxDecoration(
                                      color: Colors.white.withValues(alpha: 0.08),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: Text(
                                      tag,
                                      style: const TextStyle(
                                        color: Colors.white70,
                                        fontSize: 10.5,
                                      ),
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ],
                        ],
                      ),
                    ),
                    const SizedBox(width: 10),

                    // Right Column: Capacity on top, Royal Blue "Join" pill button below (Image 2)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              index == 3 ? Icons.sync_rounded : Icons.people_alt_rounded,
                              color: Colors.white70,
                              size: 13,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              room['capacity'] as String,
                              style: const TextStyle(
                                color: Colors.white70,
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),

                        // Royal Blue "Join" Button (Image 2)
                        GestureDetector(
                          onTap: () => _setStage(3),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                            decoration: BoxDecoration(
                              color: const Color(0xFF2979FF),
                              borderRadius: BorderRadius.circular(18),
                              boxShadow: const [
                                BoxShadow(
                                  color: Color(0x552979FF),
                                  blurRadius: 8,
                                  offset: Offset(0, 2),
                                ),
                              ],
                            ),
                            child: const Text(
                              'Join',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 13,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            },
          ),
        ),

        // Bottom "+ Create Chat Room" Pink Pill Button (Matching Image 3)
        _buildCreateChatRoomButton(),
      ],
    );
  }

  // ===========================================================================
  // 3: VIEWER TAPS JOIN (Room Preview & [ Join Room ]) - Matching Image 3
  // ===========================================================================
  Widget _buildStep3RoomPreviewView() {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(16, 6, 16, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Top Nav: Back Arrow + 👥 8/9
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 20),
                onPressed: () => _setStage(2),
              ),
              Row(
                children: const [
                  Icon(Icons.people_alt_rounded, color: Colors.white70, size: 16),
                  SizedBox(width: 5),
                  Text(
                    '8/9',
                    style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 10),

          // Large Cover Portrait Photo of Nila
          Container(
            width: double.infinity,
            height: 250,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: const Color(0xFFE91E63).withValues(alpha: 0.35),
                width: 1.5,
              ),
              image: const DecorationImage(
                image: AssetImage(AppAssets.avatarDiya),
                fit: BoxFit.cover,
              ),
              boxShadow: const [
                BoxShadow(
                  color: Colors.black54,
                  blurRadius: 18,
                  offset: Offset(0, 8),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Host Name + Crown + Subtitle
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: const [
              Text('👑', style: TextStyle(fontSize: 18)),
              SizedBox(width: 6),
              Text(
                'Nila 💕',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          const Text(
            'Friends Talk ✨',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 10),

          // Tags: Friendship & Tamil
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.white12),
                ),
                child: const Text('Friendship', style: TextStyle(color: Colors.white70, fontSize: 12)),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.white12),
                ),
                child: const Text('Tamil', style: TextStyle(color: Colors.white70, fontSize: 12)),
              ),
            ],
          ),
          const SizedBox(height: 18),

          // Row of 6 Member Circular Avatars
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildMemberAvatarMini(AppAssets.avatarArun),
                _buildMemberAvatarMini(AppAssets.avatarPriya),
                _buildMemberAvatarMini(AppAssets.avatarSneha),
                _buildMemberAvatarMini(AppAssets.avatarNeha),
                _buildMemberAvatarMini(AppAssets.avatarVicky),
                _buildMemberAvatarMini(AppAssets.avatarKarthik),
              ],
            ),
          ),
          const SizedBox(height: 14),

          // Quote: "Nice people 💕 Let's Talk ✨"
          const Text(
            'Nice people 💕 Let\'s Talk ✨',
            style: TextStyle(
              color: Color(0xFFFFD600),
              fontSize: 13.5,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 24),

          // Prominent Button: [ Join Room ] with hand pointer indicator
          GestureDetector(
            onTap: () => _setStage(4),
            child: Container(
              width: double.infinity,
              height: 52,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF7B1FA2), Color(0xFFE91E63)],
                ),
                borderRadius: BorderRadius.circular(26),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x66E91E63),
                    blurRadius: 18,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: Stack(
                alignment: Alignment.center,
                children: const [
                  Text(
                    'Join Room',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 17,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 0.5,
                    ),
                  ),
                  Positioned(
                    right: 20,
                    child: Text('👆', style: TextStyle(fontSize: 22)),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMemberAvatarMini(String asset) {
    return Container(
      padding: const EdgeInsets.all(1.5),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white38, width: 1),
      ),
      child: CustomAvatar(radius: 17, assetPath: asset),
    );
  }

  // ===========================================================================
  // 4: JOIN REQUEST SENT (Only host will get notification) - Matching Image 4
  // ===========================================================================
  Widget _buildStep4JoinRequestSentView() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Spacer(),

          // Big Glowing Circular Paperplane Icon ✈️
          Container(
            width: 90,
            height: 90,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: const LinearGradient(
                colors: [Color(0xFF2979FF), Color(0xFF00B0FF)],
              ),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF00B0FF).withValues(alpha: 0.5),
                  blurRadius: 28,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: const Center(
              child: Icon(
                Icons.send_rounded,
                color: Colors.white,
                size: 44,
              ),
            ),
          ),
          const SizedBox(height: 24),

          // Title: Join Request Sent
          const Text(
            'Join Request Sent',
            style: TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 10),

          // Subtitle: Your request has been sent to the host. Please wait for acceptance.
          const Text(
            'Your request has been sent to the host. Please wait for acceptance.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white70,
              fontSize: 14,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 28),

          // Cancel Request Button
          GestureDetector(
            onTap: () => _setStage(3),
            child: Container(
              width: 170,
              height: 42,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(21),
                border: Border.all(color: Colors.white30, width: 1.2),
                color: Colors.white.withValues(alpha: 0.06),
              ),
              child: const Center(
                child: Text(
                  'Cancel Request',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 13.5,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 28),

          // Hourglass Icon ⏳ (Tap to immediately simulate host notification)
          GestureDetector(
            onTap: () => _setStage(5),
            child: const Icon(
              Icons.hourglass_empty_rounded,
              color: Color(0xFFFFD600),
              size: 34,
            ),
          ),

          const Spacer(),
        ],
      ),
    );
  }

  // ===========================================================================
  // 5: HOST GETS NOTIFICATION (Screen 5 & Screen A Host Rejects)
  // ===========================================================================
  Widget _buildStep5HostNotificationView() {
    return Stack(
      children: [
        // Live Screen Background (Host Nila's perspective)
        Column(
          children: [
            // Top Bar: Host Nila + 👥 8/9 + +Follow + 👁️ 124
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              child: Row(
                children: [
                  CustomAvatar(radius: 18, assetPath: AppAssets.avatarDiya),
                  const SizedBox(width: 8),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Text('Nila 💕', style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold)),
                      Text('Host 👑', style: TextStyle(color: Color(0xFFFFD600), fontSize: 10.5, fontWeight: FontWeight.w600)),
                    ],
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFF2D55),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Text('+ Follow', style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold)),
                  ),
                  const Spacer(),
                  Row(
                    children: const [
                      Icon(Icons.remove_red_eye_rounded, color: Colors.white70, size: 14),
                      SizedBox(width: 4),
                      Text('124', style: TextStyle(color: Colors.white, fontSize: 11.5)),
                      SizedBox(width: 10),
                      Icon(Icons.people_alt_rounded, color: Colors.white70, size: 14),
                      SizedBox(width: 4),
                      Text('8/9', style: TextStyle(color: Colors.white, fontSize: 11.5)),
                    ],
                  ),
                ],
              ),
            ),

            // Live Camera View
            Expanded(
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.white12),
                  image: const DecorationImage(
                    image: AssetImage(AppAssets.avatarDiya),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 190), // Spacing for floating bottom sheet
          ],
        ),

        // Floating Bottom Modal: Join Request (1) - Screen 5 & Screen A
        Positioned(
          left: 12,
          right: 12,
          bottom: 12,
          child: Container(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
            decoration: BoxDecoration(
              color: const Color(0xFF141126),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: const Color(0xFFE91E63).withValues(alpha: 0.5),
                width: 1.4,
              ),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x66E91E63),
                  blurRadius: 20,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Header: Join Request (1) + Close button
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Join Request (1)',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    GestureDetector(
                      onTap: () => _setStage(2),
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.08),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.close_rounded, color: Colors.white70, size: 16),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // Request Item: Karthi avatar + wants to join your room
                Row(
                  children: [
                    CustomAvatar(radius: 22, assetPath: AppAssets.avatarKarthik),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Text(
                          'Karthi',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 15,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        SizedBox(height: 2),
                        Text(
                          'wants to join your room',
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Action Buttons: [ Reject ] (Red - Screen A) & [ Accept ] (Green - Screen 6)
                Row(
                  children: [
                    // Reject Button (Screen A)
                    Expanded(
                      child: GestureDetector(
                        onTap: () => _setStage(7), // Triggers Step B Rejected Alert!
                        child: Container(
                          height: 44,
                          decoration: BoxDecoration(
                            color: const Color(0xFFD32F2F),
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: const [
                              BoxShadow(
                                color: Color(0x55D32F2F),
                                blurRadius: 10,
                                offset: Offset(0, 3),
                              ),
                            ],
                          ),
                          child: const Center(
                            child: Text(
                              'Reject',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 15,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),

                    // Accept Button (Screen 6 / D)
                    Expanded(
                      child: GestureDetector(
                        onTap: () => _setStage(6), // Triggers Step 6 Accepted & User Enters!
                        child: Container(
                          height: 44,
                          decoration: BoxDecoration(
                            color: const Color(0xFF00C853),
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: const [
                              BoxShadow(
                                color: Color(0x5500C853),
                                blurRadius: 10,
                                offset: Offset(0, 3),
                              ),
                            ],
                          ),
                          child: const Center(
                            child: Text(
                              'Accept',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 15,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),

                // Bottom host controls: Mic, Video, Chat, Gift, More
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildHostBottomBtn(Icons.mic_off_rounded, 'Mic', isRed: true),
                    _buildHostBottomBtn(Icons.videocam_rounded, 'Video'),
                    _buildHostBottomBtn(Icons.chat_bubble_outline_rounded, 'Chat'),
                    _buildHostBottomBtn(Icons.card_giftcard_rounded, 'Gift'),
                    _buildHostBottomBtn(Icons.more_horiz_rounded, 'More'),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildHostBottomBtn(IconData icon, String label, {bool isRed = false}) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.all(7),
          decoration: BoxDecoration(
            color: isRed ? const Color(0xFFD32F2F) : Colors.white.withValues(alpha: 0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: Colors.white, size: 16),
        ),
        const SizedBox(height: 3),
        Text(label, style: const TextStyle(color: Colors.white70, fontSize: 10)),
      ],
    );
  }

  // ===========================================================================
  // 6: HOST ACCEPTS / D: IF ACCEPTED - USER ENTERS - Matching Image 6 & Screen D
  // ===========================================================================
  Widget _buildStep6AcceptedRoomView() {
    return Stack(
      children: [
        Column(
          children: [
            // Top Bar: Nila 💕 + 👥 9/9 + +Follow + 👁️ 124
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              child: Row(
                children: [
                  CustomAvatar(radius: 18, assetPath: AppAssets.avatarDiya),
                  const SizedBox(width: 8),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Text('Nila 💕', style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold)),
                      Text('Host 👑', style: TextStyle(color: Color(0xFFFFD600), fontSize: 10.5, fontWeight: FontWeight.w600)),
                    ],
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFF2D55),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Text('+ Follow', style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold)),
                  ),
                  const Spacer(),
                  Row(
                    children: [
                      const Icon(Icons.remove_red_eye_rounded, color: Colors.white70, size: 14),
                      const SizedBox(width: 4),
                      const Text('124', style: TextStyle(color: Colors.white, fontSize: 11.5)),
                      const SizedBox(width: 10),
                      const Icon(Icons.people_alt_rounded, color: Colors.white70, size: 14),
                      const SizedBox(width: 4),
                      const Text('9/9', style: TextStyle(color: Colors.white, fontSize: 11.5)),
                      const SizedBox(width: 10),
                      GestureDetector(
                        onTap: () => _setStage(2),
                        child: const Icon(Icons.close_rounded, color: Colors.white70, size: 20),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // 8-Seat Room Grid (Nila, Karthi, Priya, Arun + 4 Invite Seats)
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 14),
                child: GridView.count(
                  crossAxisCount: 2,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 1.15,
                  children: [
                    // Seat 1: Host Nila
                    _buildActiveRoomSeat(
                      name: 'Nila',
                      badge: 'Host 👑',
                      isHost: true,
                      avatarAsset: AppAssets.avatarDiya,
                    ),

                    // Seat 2: Karthi (You just entered!)
                    _buildActiveRoomSeat(
                      name: 'Karthi (You)',
                      badge: 'Joined 🟢',
                      isHost: false,
                      isYou: true,
                      avatarAsset: AppAssets.avatarKarthik,
                    ),

                    // Seat 3: Priya
                    _buildActiveRoomSeat(
                      name: 'Priya',
                      badge: 'Member',
                      isHost: false,
                      avatarAsset: AppAssets.avatarPriya,
                    ),

                    // Seat 4: Arun
                    _buildActiveRoomSeat(
                      name: 'Arun',
                      badge: 'Member',
                      isHost: false,
                      avatarAsset: AppAssets.avatarArun,
                    ),

                    // Seat 5: + Invite
                    _buildEmptyInviteSeat(),
                    // Seat 6: + Invite
                    _buildEmptyInviteSeat(),
                  ],
                ),
              ),
            ),

            // Bottom controls
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildHostBottomBtn(Icons.mic_rounded, 'Mic'),
                  _buildHostBottomBtn(Icons.videocam_rounded, 'Video'),
                  _buildHostBottomBtn(Icons.chat_bubble_outline_rounded, 'Chat'),
                  _buildHostBottomBtn(Icons.card_giftcard_rounded, 'Gift'),
                  _buildHostBottomBtn(Icons.more_horiz_rounded, 'More'),
                ],
              ),
            ),
          ],
        ),

        // Floating Toast Banner: "✓ You joined the room" (Matching Image 6 & D)
        Positioned(
          left: 24,
          right: 24,
          bottom: 70,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF00C853), Color(0xFF009624)],
              ),
              borderRadius: BorderRadius.circular(24),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x6600C853),
                  blurRadius: 16,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: const [
                Icon(Icons.check_circle_rounded, color: Colors.white, size: 20),
                SizedBox(width: 8),
                Text(
                  'You joined the room',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildActiveRoomSeat({
    required String name,
    required String badge,
    required bool isHost,
    bool isYou = false,
    required String avatarAsset,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF161228),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: isYou
              ? const Color(0xFF00E676)
              : (isHost ? const Color(0xFFFFD600) : Colors.white12),
          width: isYou || isHost ? 2 : 1,
        ),
        boxShadow: isYou
            ? const [
                BoxShadow(
                  color: Color(0x4400E676),
                  blurRadius: 10,
                ),
              ]
            : null,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CustomAvatar(radius: 28, assetPath: avatarAsset),
          const SizedBox(height: 6),
          Text(
            name,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 13,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 2),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: isHost
                  ? const Color(0xFFFFB300)
                  : (isYou ? const Color(0xFF00C853) : Colors.white12),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              badge,
              style: TextStyle(
                color: isHost ? Colors.black : Colors.white,
                fontSize: 10,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyInviteSeat() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.04),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white12, style: BorderStyle.solid),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: const [
          Icon(Icons.add_rounded, color: Colors.white54, size: 28),
          SizedBox(height: 4),
          Text(
            'Invite',
            style: TextStyle(color: Colors.white60, fontSize: 12, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }

  // ===========================================================================
  // 7 / B: USER GETS REJECTED ALERT - Matching Image B
  // ===========================================================================
  Widget _buildStepBRejectedAlertView() {
    return Center(
      child: Container(
        width: MediaQuery.sizeOf(context).width * 0.84,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
        decoration: BoxDecoration(
          color: const Color(0xFF141126),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: Colors.white12),
          boxShadow: const [
            BoxShadow(
              color: Colors.black87,
              blurRadius: 28,
              offset: Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Big Red Circular ✕ Icon
            Container(
              width: 64,
              height: 64,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: Color(0xFFD32F2F),
                boxShadow: [
                  BoxShadow(
                    color: Color(0x66D32F2F),
                    blurRadius: 18,
                  ),
                ],
              ),
              child: const Center(
                child: Icon(Icons.close_rounded, color: Colors.white, size: 38),
              ),
            ),
            const SizedBox(height: 18),

            // Title: Your request was rejected
            const Text(
              'Your request was rejected',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 8),

            // Subtitle: You will continue watching as a viewer.
            const Text(
              'You will continue watching as a viewer.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white70,
                fontSize: 13.5,
              ),
            ),
            const SizedBox(height: 24),

            // OK Button (Goes to Step C: Viewer Room)
            GestureDetector(
              onTap: () => _setStage(8), // Advances to Step C Viewer View!
              child: Container(
                width: double.infinity,
                height: 46,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF2979FF), Color(0xFF7B1FA2)],
                  ),
                  borderRadius: BorderRadius.circular(23),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x557B1FA2),
                      blurRadius: 12,
                      offset: Offset(0, 3),
                    ),
                  ],
                ),
                child: const Center(
                  child: Text(
                    'OK',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ===========================================================================
  // 8 / C: USER STAYS AS VIEWER - Matching Image C
  // ===========================================================================
  Widget _buildStepCViewerRoomView() {
    final comments = [
      {'user': 'Raja', 'msg': 'Nice voice 💕'},
      {'user': 'Anu', 'msg': 'Super ✨'},
      {'user': 'Siva', 'msg': 'Hi all 👏'},
      {'user': 'Meena', 'msg': '👏👏👏'},
    ];

    return Column(
      children: [
        // Top Bar: Nila 💕 + 👥 8/9 + 👁️ 124
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
          child: Row(
            children: [
              CustomAvatar(radius: 18, assetPath: AppAssets.avatarDiya),
              const SizedBox(width: 8),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text('Nila 💕', style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold)),
                  Text('Friends Talk ✨', style: TextStyle(color: Colors.white70, fontSize: 11)),
                ],
              ),
              const Spacer(),
              Row(
                children: [
                  const Icon(Icons.remove_red_eye_rounded, color: Colors.white70, size: 14),
                  const SizedBox(width: 4),
                  const Text('124', style: TextStyle(color: Colors.white, fontSize: 11.5)),
                  const SizedBox(width: 10),
                  const Icon(Icons.people_alt_rounded, color: Colors.white70, size: 14),
                  const SizedBox(width: 4),
                  const Text('8/9', style: TextStyle(color: Colors.white, fontSize: 11.5)),
                  const SizedBox(width: 10),
                  GestureDetector(
                    onTap: () => _setStage(2),
                    child: const Icon(Icons.close_rounded, color: Colors.white70, size: 20),
                  ),
                ],
              ),
            ],
          ),
        ),

        // Member Avatar Strip
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
          child: Row(
            children: [
              _buildMemberAvatarMini(AppAssets.avatarArun),
              const SizedBox(width: 6),
              _buildMemberAvatarMini(AppAssets.avatarPriya),
              const SizedBox(width: 6),
              _buildMemberAvatarMini(AppAssets.avatarSneha),
              const SizedBox(width: 6),
              _buildMemberAvatarMini(AppAssets.avatarNeha),
              const SizedBox(width: 6),
              _buildMemberAvatarMini(AppAssets.avatarVicky),
              const SizedBox(width: 6),
              _buildMemberAvatarMini(AppAssets.avatarKarthik),
            ],
          ),
        ),
        const SizedBox(height: 6),

        // Status banner: Nice people 💕 Let's Talk ✨
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 14),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.05),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: const [
              Text('✨', style: TextStyle(fontSize: 14)),
              SizedBox(width: 6),
              Text(
                'Nice people 💕 Let\'s Talk ✨',
                style: TextStyle(color: Color(0xFFFFD600), fontSize: 12, fontWeight: FontWeight.w700),
              ),
            ],
          ),
        ),

        // Live Chat Comments Stream
        Expanded(
          child: Stack(
            children: [
              ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                itemCount: comments.length,
                itemBuilder: (context, index) {
                  final c = comments[index];
                  return Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.35),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          '${c['user']}: ',
                          style: const TextStyle(
                            color: Color(0xFFFFD600),
                            fontSize: 12.5,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        Text(
                          c['msg'] as String,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12.5,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),

              // Floating Hearts indicator on right
              Positioned(
                right: 16,
                bottom: 20,
                child: Column(
                  children: const [
                    Text('💕', style: TextStyle(fontSize: 22)),
                    SizedBox(height: 6),
                    Text('💖', style: TextStyle(fontSize: 26)),
                    SizedBox(height: 6),
                    Text('💗', style: TextStyle(fontSize: 20)),
                  ],
                ),
              ),
            ],
          ),
        ),

        // Bottom Chat Input Bar
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: const BoxDecoration(
            color: Color(0xFF141126),
            border: Border(top: BorderSide(color: Colors.white10)),
          ),
          child: Row(
            children: [
              Expanded(
                child: Container(
                  height: 38,
                  padding: const EdgeInsets.symmetric(horizontal: 14),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(19),
                  ),
                  child: Row(
                    children: const [
                      Text(
                        'Say something...',
                        style: TextStyle(color: Colors.white54, fontSize: 13),
                      ),
                      Spacer(),
                      Icon(Icons.sentiment_satisfied_alt_rounded, color: Colors.white54, size: 18),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 8),
              IconButton(
                icon: const Icon(Icons.card_giftcard_rounded, color: Color(0xFFFFD600), size: 22),
                onPressed: _openGiftSheet,
              ),
              IconButton(
                icon: const Icon(Icons.favorite_rounded, color: Color(0xFFFF2D55), size: 22),
                onPressed: () => _heartsKey.currentState?.addHeart(),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ===========================================================================
  // 9 / E: FLOW SUMMARY (USER SIDE) - Matching Image Section E
  // ===========================================================================
  Widget _buildStepEFlowSummaryView() {
    final summaryItems = [
      {'step': '1', 'title': 'Open App → Tap Chat Room', 'target': 1},
      {'step': '2', 'title': 'See live chat rooms list', 'target': 2},
      {'step': '3', 'title': 'Tap Join on any host room', 'target': 3},
      {'step': '4', 'title': 'Request sent (only host sees)', 'target': 4},
      {'step': '5', 'title': 'Wait for host to accept', 'target': 5},
      {'step': '6', 'title': 'If accepted → Enter room', 'target': 6},
      {'step': '7', 'title': 'If rejected → Remain as viewer', 'target': 7},
    ];

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Badge + Title
          Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    colors: [Color(0xFFFF2D55), Color(0xFF9C27B0)],
                  ),
                ),
                child: const Center(
                  child: Text(
                    'E',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              const Text(
                'Flow Summary (User Side)',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 19,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // 7 Numbered Steps List
          for (final item in summaryItems) ...[
            Container(
              margin: const EdgeInsets.only(bottom: 10),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              decoration: BoxDecoration(
                color: const Color(0xFF151128),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.white10),
              ),
              child: Row(
                children: [
                  Container(
                    width: 28,
                    height: 28,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF2979FF), Color(0xFF7B1FA2)],
                      ),
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(
                        item['step'] as String,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 13,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      item['title'] as String,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 13.5,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: () => _setStage(item['target'] as int),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xFFE91E63).withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: const Color(0xFFE91E63)),
                      ),
                      child: const Text(
                        'Try',
                        style: TextStyle(
                          color: Color(0xFFFF4081),
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
          const SizedBox(height: 16),

          // Restart Entire Flow from Step 1 Button
          GestureDetector(
            onTap: () => _setStage(1),
            child: Container(
              width: double.infinity,
              height: 48,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF7B1FA2), Color(0xFFE91E63)],
                ),
                borderRadius: BorderRadius.circular(24),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x66E91E63),
                    blurRadius: 14,
                    offset: Offset(0, 3),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  Icon(Icons.refresh_rounded, color: Colors.white, size: 20),
                  SizedBox(width: 8),
                  Text(
                    'Restart Flow from Step 1 (Home Page)',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 14.5,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ===========================================================================
  // STEP 1: CHAT ROOM LIST SCREEN (Matching Reference Image Step 1)
  // ===========================================================================
  Widget _buildRoomListView() {
    final filter = _filters[_selectedFilterIndex];
    final filteredRooms = _roomsList.where((room) {
      if (filter == '🎙️ Audio') return !(room['isVideo'] as bool);
      if (filter == '📹 Video') return room['isVideo'] as bool;
      if (filter == 'Friends') return room['tag'] == 'Friends';
      if (filter == 'Trending') return (room['viewers'] as String).compareTo('100') >= 0;
      return true;
    }).toList();

    return Stack(
      children: [
        Column(
          children: [
            // Screen 1 Header: Left Back Arrow ←, Title "Chat Room", Right Search Icon 🔍
            Padding(
              padding: const EdgeInsets.fromLTRB(10, 8, 14, 8),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(
                      Icons.arrow_back_ios_new_rounded,
                      color: Colors.white,
                      size: 20,
                    ),
                    onPressed: () {
                      if (widget.onBack != null) {
                        widget.onBack!();
                      } else if (Navigator.of(context).canPop()) {
                        Navigator.of(context).pop();
                      }
                    },
                  ),
                  const SizedBox(width: 4),
                  const Text(
                    'Chat Room',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(
                      Icons.search_rounded,
                      color: Color(0xFFFFD600),
                      size: 24,
                    ),
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Search chat rooms...'),
                          backgroundColor: Color(0xFFFFD600),
                          duration: Duration(seconds: 1),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),

            // Horizontal Filter Chips: All, Audio, Video, Trending, Friends
            SizedBox(
              height: 38,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 14),
                itemCount: _filters.length,
                itemBuilder: (context, index) {
                  final isSel = _selectedFilterIndex == index;
                  return GestureDetector(
                    onTap: () => setState(() => _selectedFilterIndex = index),
                    child: Container(
                      margin: const EdgeInsets.only(right: 8),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 7,
                      ),
                      decoration: BoxDecoration(
                        color: isSel
                            ? const Color(0xFFFFD600)
                            : const Color(0xFF1B182E),
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(
                          color: isSel
                              ? const Color(0xFFFFD600)
                              : Colors.white10,
                        ),
                        boxShadow: isSel
                            ? const [
                                BoxShadow(
                                  color: Color(0x44FFD600),
                                  blurRadius: 8,
                                ),
                              ]
                            : null,
                      ),
                      child: Center(
                        child: Text(
                          _filters[index],
                          style: TextStyle(
                            color: isSel ? Colors.black : Colors.white70,
                            fontWeight: isSel ? FontWeight.w900 : FontWeight.w600,
                            fontSize: 12.5,
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 10),

            // Room Cards List
            Expanded(
              child: ListView.builder(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(14, 4, 14, 90),
                itemCount: filteredRooms.length,
                itemBuilder: (context, index) {
                  final room = filteredRooms[index];
                  final isVideo = room['isVideo'] as bool;

                  return Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFF141224),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: const Color(0xFFFFD600).withValues(alpha: 0.22),
                        width: 1,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.35),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Stack(
                          clipBehavior: Clip.none,
                          children: [
                            Container(
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: const Color(0xFFFFD600).withValues(alpha: 0.6),
                                  width: 1.5,
                                ),
                              ),
                              child: CustomAvatar(
                                radius: 26,
                                assetPath: room['avatar'] as String,
                              ),
                            ),
                            Positioned(
                              bottom: -2,
                              right: -2,
                              child: Container(
                                padding: const EdgeInsets.all(3),
                                decoration: BoxDecoration(
                                  color: isVideo
                                      ? const Color(0xFFE040FB)
                                      : const Color(0xFFFFB300),
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  isVideo ? Icons.videocam_rounded : Icons.mic_rounded,
                                  color: Colors.black,
                                  size: 11,
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
                              Row(
                                children: [
                                  Flexible(
                                    child: Text(
                                      room['hostName'] as String,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 15,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  if (room['isVerified'] == true) ...[
                                    const SizedBox(width: 4),
                                    const Icon(
                                      Icons.verified_rounded,
                                      color: Color(0xFF29B6F6),
                                      size: 14,
                                    ),
                                  ],
                                ],
                              ),
                              const SizedBox(height: 2),
                              Text(
                                room['tagline'] as String,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  color: Colors.white70,
                                  fontSize: 12,
                                ),
                              ),
                              const SizedBox(height: 5),
                              Row(
                                children: [
                                  Text(
                                    room['tagIcon'] as String,
                                    style: const TextStyle(fontSize: 11),
                                  ),
                                  const SizedBox(width: 3),
                                  Text(
                                    room['tag'] as String,
                                    style: const TextStyle(
                                      color: Color(0xFFFFD600),
                                      fontSize: 11,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  const Icon(
                                    Icons.person_outline_rounded,
                                    color: Colors.white54,
                                    size: 12,
                                  ),
                                  const SizedBox(width: 2),
                                  Text(
                                    room['capacity'] as String,
                                    style: const TextStyle(
                                      color: Colors.white60,
                                      fontSize: 11,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        GestureDetector(
                          onTap: () => _showJoinPreviewModal(room),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [Color(0xFFFFEA00), Color(0xFFFF9100)],
                              ),
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: const [
                                BoxShadow(
                                  color: Color(0x44FFD600),
                                  blurRadius: 8,
                                  offset: Offset(0, 2),
                                ),
                              ],
                            ),
                            child: const Text(
                              'Join',
                              style: TextStyle(
                                color: Colors.black,
                                fontSize: 13,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),

        // Bottom Floating "+ Create Chat Room" button
        Positioned(
          bottom: 16,
          left: 20,
          right: 20,
          child: GestureDetector(
            onTap: _showCreateRoomSheet,
            child: Container(
              height: 52,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFFFF007F), Color(0xFFFF2D78)],
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                ),
                borderRadius: BorderRadius.circular(26),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFFFF007F).withValues(alpha: 0.50),
                    blurRadius: 18,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  Icon(Icons.add_rounded, color: Colors.white, size: 26),
                  SizedBox(width: 8),
                  Text(
                    'Create Chat Room',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16.5,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 0.3,
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

  // ===========================================================================
  // STEP 3: INSIDE CHAT ROOM (Matching Viewer Poster & PK Battle Input Bar)
  // 9 People Live Together | See • Talk • Send Gifts • Enjoy
  // ===========================================================================
  Widget _buildInsideChatRoomView() {
    final selectedIndex = _selectedMemberIndex;
    final hasSelectedMember = selectedIndex != null &&
        selectedIndex >= 0 &&
        selectedIndex < _seats.length;
    final selectedMember = hasSelectedMember ? _seats[selectedIndex] : null;

    return Column(
      children: [
        // Screen 3 Header (Exact Match to User Reference Image 1):
        // Left: 🎙️ in purple circle + Diya + "Host" badge (NO "Chat Room" text)
        // Right: Video/Mic status + ⭐ 520 (star count) + ✕ close button
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          child: Row(
            children: [
              // Purple mic circle icon
              Container(
                width: 30,
                height: 30,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    colors: [Color(0xFFAB47BC), Color(0xFF7B1FA2)],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Color(0x55AB47BC),
                      blurRadius: 6,
                    ),
                  ],
                ),
                child: const Center(
                  child: Icon(
                    Icons.mic_rounded,
                    color: Colors.white,
                    size: 16,
                  ),
                ),
              ),
              const SizedBox(width: 8),

              // Host Name (Diya)
              Text(
                _selectedRoom['hostName'] as String? ?? 'Diya',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 15.5,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.2,
                ),
              ),
              const SizedBox(width: 6),

              // "Host" Pink/Red Badge
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2.5),
                decoration: BoxDecoration(
                  color: const Color(0xFFFF2D55),
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x44FF2D55),
                      blurRadius: 4,
                    ),
                  ],
                ),
                child: const Text(
                  'Host',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),

              const Spacer(),

              // Audio / Video Toggle Pill
              GestureDetector(
                onTap: () {
                  setState(() => _isVideoRoom = !_isVideoRoom);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        _isVideoRoom
                            ? 'Switched to 📹 Video Room Mode'
                            : 'Switched to 🎙️ Audio Room Mode',
                      ),
                      backgroundColor: const Color(0xFFFFD600),
                      duration: const Duration(seconds: 1),
                    ),
                  );
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                  decoration: BoxDecoration(
                    color: _isVideoRoom
                        ? const Color(0xFF3B1D54)
                        : const Color(0xFF18283E),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: _isVideoRoom
                          ? const Color(0xFFE040FB)
                          : const Color(0xFF40C4FF),
                      width: 0.8,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        _isVideoRoom
                            ? Icons.videocam_rounded
                            : Icons.mic_rounded,
                        color: _isVideoRoom
                            ? const Color(0xFFE040FB)
                            : const Color(0xFF40C4FF),
                        size: 11,
                      ),
                      const SizedBox(width: 3),
                      Text(
                        _isVideoRoom ? 'Video' : 'Audio',
                        style: TextStyle(
                          color: _isVideoRoom
                              ? const Color(0xFFE040FB)
                              : const Color(0xFF40C4FF),
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 6),

              // Mic Mute / Unmute Toggle
              GestureDetector(
                onTap: () {
                  setState(() => _isMicMuted = !_isMicMuted);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(_isMicMuted ? 'Mic Muted 🔇' : 'Mic On 🎙️'),
                      duration: const Duration(seconds: 1),
                    ),
                  );
                },
                child: Container(
                  padding: const EdgeInsets.all(4.5),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: _isMicMuted
                        ? const Color(0x33FF2D55)
                        : const Color(0x3300E676),
                    border: Border.all(
                      color: _isMicMuted
                          ? const Color(0xFFFF2D55)
                          : const Color(0xFF00E676),
                      width: 0.8,
                    ),
                  ),
                  child: Icon(
                    _isMicMuted ? Icons.mic_off_rounded : Icons.mic_rounded,
                    color: _isMicMuted
                        ? const Color(0xFFFF2D55)
                        : const Color(0xFF00E676),
                    size: 11,
                  ),
                ),
              ),
              const SizedBox(width: 6),

              // Stars Counter Pill (Matching ⭐ 520 in Image 1)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0x9918142A),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: const Color(0xFFFFD600).withValues(alpha: 0.4),
                    width: 0.8,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text('⭐', style: TextStyle(fontSize: 12)),
                    const SizedBox(width: 4),
                    Text(
                      '${_totalStarsCount > 1000 ? "${(_totalStarsCount / 1000).toStringAsFixed(1)}K" : _totalStarsCount}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),

              // ✕ Close Button (Matching Image 1, triggers Step 4 confirmation modal)
              GestureDetector(
                onTap: _showEndRoomDialog,
                child: Container(
                  width: 30,
                  height: 30,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withValues(alpha: 0.12),
                  ),
                  child: const Center(
                    child: Icon(
                      Icons.close_rounded,
                      color: Colors.white,
                      size: 19,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),

        // 3x3 Grid of 9 Seats:
        // Elongated portrait cards (childAspectRatio: 0.72) to eliminate the empty gap,
        // prominent profiles, crisp studio portraits, clear numbers/Host tag, bottom names & mic badges!
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
          child: _buildNineSeatsLayout(),
        ),

        // Step 2 Member Selection Popup (if tapped a member like Priya)
        if (hasSelectedMember && selectedMember != null)
          _buildMemberProfilePopup(selectedMember, selectedIndex),

        // Live Chat Messages Stream:
        // Uniform sizing ("chat room la konjma length iruku yellathu ora mathiri panni kudu different illama"),
        // Bottom 2 comments clearly visible and solid (nalla theriyanu),
        // Older messages moving upwards are transparent/lite (lite theriyu)!
        Expanded(
          child: ShaderMask(
            shaderCallback: (bounds) => const LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Colors.transparent, Colors.white, Colors.white],
              stops: [0.0, 0.12, 1.0],
            ).createShader(bounds),
            blendMode: BlendMode.dstIn,
            child: ListView.builder(
              reverse: true, // Anchor to bottom
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              itemCount: _chatMessages.length,
              itemBuilder: (context, index) {
                final itemIndex = _chatMessages.length - 1 - index;
                if (itemIndex < 0 || itemIndex >= _chatMessages.length) {
                  return const SizedBox.shrink();
                }
                final msg = _chatMessages[itemIndex];
                return _buildUnifiedCommentCapsule(msg, index);
              },
            ),
          ),
        ),

        // Bottom Action Area:
        // If a member is selected -> Step 2 "Send Gift to [Name]" panel ([Stars] [Flowers] [Special])
        // Else -> PK-style comment input capsule with 😊 + Type a message... + ⭐, 🌹, 🎁 buttons!
        if (hasSelectedMember && selectedMember != null)
          _buildViewerGiftBar(selectedMember, selectedIndex)
        else
          _buildPKStyleCommentInputBar(),
      ],
    );
  }

  /// 9 Seats Layout matching Poster:
  /// Large profiles ("profile nalla theriyanu athu chinna tha iruku"),
  /// filling the upper half handsomely, clear studio portraits for all 9 people!
  Widget _buildNineSeatsLayout() {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: _seats.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 6,
        mainAxisSpacing: 6,
        childAspectRatio: 0.72, // Elongated portrait cards to eliminate empty space and fill screen properly
      ),
      itemBuilder: (context, index) {
        final seat = _seats[index];
        final isHost = seat['isHost'] as bool;
        final isSpeaking = seat['isSpeaking'] as bool;
        final isMicOn = seat['isMicOn'] as bool;
        final isSelected = _selectedMemberIndex == index;
        final floatingBadge = _memberFloatingGifts[index];

        return GestureDetector(
          onTap: () {
            setState(() {
              if (_selectedMemberIndex == index) {
                _selectedMemberIndex = null; // Toggle off if tapped again
              } else {
                _selectedMemberIndex = index;
                _isFollowingSelectedMember = false;
                _showCommentInput = false;
              }
            });
          },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 220),
            curve: Curves.easeOutCubic,
            decoration: BoxDecoration(
              color: const Color(0xFF161326),
              borderRadius: BorderRadius.circular(16),
              border: isSelected
                  ? Border.all(
                      color: const Color(0xFFFF2D55),
                      width: 2.2,
                    )
                  : isSpeaking
                      ? Border.all(
                          color: const Color(0xFF00E676),
                          width: 1.4,
                        )
                      : Border.all(
                          color: Colors.white.withValues(alpha: 0.10),
                          width: 0.8,
                        ),
              boxShadow: [
                if (isSelected)
                  const BoxShadow(
                    color: Color(0x99FF2D55),
                    blurRadius: 12,
                    spreadRadius: 1,
                  )
                else if (isSpeaking)
                  const BoxShadow(
                    color: Color(0x3300E676),
                    blurRadius: 6,
                  )
                else
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.45),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(15),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  // High-Res Studio Portrait Photo
                  Image.asset(
                    seat['avatar'] as String,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Container(
                      color: const Color(0xFF221E36),
                      child: const Icon(Icons.person, color: Colors.white30, size: 36),
                    ),
                  ),

                  // Bottom gradient for text legibility
                  DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Colors.transparent,
                          Colors.black.withValues(alpha: 0.85),
                        ],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        stops: const [0.52, 1.0],
                      ),
                    ),
                  ),

                  // Top-Left Number/Host Badge (Matching Poster)
                  Positioned(
                    top: 5,
                    left: 5,
                    child: isHost
                        ? Container(
                            padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFF2D55),
                              borderRadius: BorderRadius.circular(6),
                              boxShadow: const [
                                BoxShadow(
                                  color: Color(0x55FF2D55),
                                  blurRadius: 4,
                                ),
                              ],
                            ),
                            child: const Text(
                              'Host',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 9.5,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                          )
                        : Container(
                            padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                            decoration: BoxDecoration(
                              color: Colors.black.withValues(alpha: 0.60),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              '${seat['seat']}',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                          ),
                  ),

                  // Bottom Row: Person's Name on left, Mic badge on right (Matching Poster)
                  Positioned(
                    bottom: 5,
                    left: 6,
                    right: 6,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Flexible(
                          child: Text(
                            '${seat['seat']} ${seat['name']}',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 11.5,
                              fontWeight: FontWeight.bold,
                              shadows: [
                                Shadow(color: Colors.black, blurRadius: 4),
                              ],
                            ),
                          ),
                        ),
                        isSpeaking
                            ? ScaleTransition(
                                scale: _waveAnimation,
                                child: _buildMicBadge(isMicOn),
                              )
                            : _buildMicBadge(isMicOn),
                      ],
                    ),
                  ),

                  // Floating Gift Animation Badge over this specific member (Poster Step 3 & 4)
                  if (floatingBadge != null)
                    Positioned.fill(
                      child: Center(
                        child: TweenAnimationBuilder<double>(
                          tween: Tween(begin: 0.6, end: 1.0),
                          duration: const Duration(milliseconds: 320),
                          curve: Curves.elasticOut,
                          builder: (context, val, child) {
                            return Transform.scale(
                              scale: val,
                              child: child,
                            );
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 5,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xEE120A1E),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: const Color(0xFFFF2D55),
                                width: 1.5,
                              ),
                              boxShadow: const [
                                BoxShadow(
                                  color: Color(0x88FF2D55),
                                  blurRadius: 10,
                                ),
                              ],
                            ),
                            child: Text(
                              floatingBadge,
                              style: const TextStyle(
                                color: Color(0xFFFFD600),
                                fontSize: 13,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  /// Step 2 Member Profile Popup Card (Poster Step 2: "Select a Member")
  Widget _buildMemberProfilePopup(Map<String, dynamic> member, int memberIndex) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xEE1A132C),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: const Color(0xFFFF2D55).withValues(alpha: 0.8),
          width: 1.2,
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0x55FF2D55),
            blurRadius: 12,
            spreadRadius: 1,
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: const Color(0xFFFF2D55),
                width: 1.8,
              ),
            ),
            child: CustomAvatar(
              radius: 18,
              assetPath: member['avatar'] as String,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  member['name'] as String,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  member['isHost'] == true ? 'Host • Live Creator' : 'Live Member #${member['seat']}',
                  style: const TextStyle(
                    color: Colors.white60,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
          // Follow Button
          GestureDetector(
            onTap: () {
              setState(() {
                _isFollowingSelectedMember = !_isFollowingSelectedMember;
              });
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: _isFollowingSelectedMember
                      ? [const Color(0xFF00E676), const Color(0xFF00B0FF)]
                      : [const Color(0xFFFF2D55), const Color(0xFFE040FB)],
                ),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: (_isFollowingSelectedMember
                            ? const Color(0xFF00E676)
                            : const Color(0xFFFF2D55))
                        .withValues(alpha: 0.4),
                    blurRadius: 6,
                  ),
                ],
              ),
              child: Text(
                _isFollowingSelectedMember ? '✓ Following' : '+ Follow',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 11.5,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(width: 6),
          // Close button
          GestureDetector(
            onTap: () => setState(() => _selectedMemberIndex = null),
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.12),
              ),
              child: const Icon(
                Icons.close_rounded,
                color: Colors.white70,
                size: 16,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Step 2 "Send Gift to [Name]" Bottom Bar (Poster Step 2: [Stars] [Flowers] [Special])
  Widget _buildViewerGiftBar(Map<String, dynamic> member, int memberIndex) {
    final memberName = member['name'] as String;

    return Container(
      padding: const EdgeInsets.fromLTRB(14, 8, 14, 12),
      decoration: BoxDecoration(
        color: const Color(0xFA120E22),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(22)),
        border: Border(
          top: BorderSide(
            color: const Color(0xFFFF2D55).withValues(alpha: 0.5),
            width: 1.2,
          ),
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0x33FF2D55),
            blurRadius: 10,
            offset: Offset(0, -3),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header: "Send Gift to Priya"
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Send Gift to $memberName',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 13.5,
                  fontWeight: FontWeight.bold,
                ),
              ),
              GestureDetector(
                onTap: _openGiftSheet,
                child: Row(
                  children: const [
                    Text(
                      'More Gifts',
                      style: TextStyle(
                        color: Color(0xFFFFD600),
                        fontSize: 11.5,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Icon(
                      Icons.arrow_forward_ios_rounded,
                      color: Color(0xFFFFD600),
                      size: 11,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),

          // Tabs: [Stars] [Flowers] [Special]
          Row(
            children: [
              _buildGiftCategoryTab(0, 'Stars'),
              const SizedBox(width: 8),
              _buildGiftCategoryTab(1, 'Flowers'),
              const SizedBox(width: 8),
              _buildGiftCategoryTab(2, 'Special'),
            ],
          ),
          const SizedBox(height: 10),

          // 4 Quick Gifts: Star ⭐ (1), Rose 🌹 (10), Tulip 🌷 (50), Bouquet 💐 (100)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildQuickGiftTile(
                icon: '⭐',
                name: 'Star',
                cost: 1,
                badge: '+100',
                onTap: () => _sendQuickGiftToMember(memberIndex, 'Star', '⭐', 1, '+100'),
              ),
              _buildQuickGiftTile(
                icon: '🌹',
                name: 'Rose',
                cost: 10,
                badge: '+1',
                onTap: () => _sendQuickGiftToMember(memberIndex, 'Rose', '🌹', 10, '+1'),
              ),
              _buildQuickGiftTile(
                icon: '🌷',
                name: 'Tulip',
                cost: 50,
                badge: '+50',
                onTap: () => _sendQuickGiftToMember(memberIndex, 'Tulip', '🌷', 50, '+50'),
              ),
              _buildQuickGiftTile(
                icon: '💐',
                name: 'Bouquet',
                cost: 100,
                badge: '+100',
                onTap: () => _sendQuickGiftToMember(memberIndex, 'Bouquet', '💐', 100, '+100'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildGiftCategoryTab(int index, String title) {
    final isSelected = _selectedGiftTab == index;
    return GestureDetector(
      onTap: () => setState(() => _selectedGiftTab = index),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFFF2D55) : const Color(0xFF221B35),
          borderRadius: BorderRadius.circular(14),
          boxShadow: isSelected
              ? const [
                  BoxShadow(
                    color: Color(0x66FF2D55),
                    blurRadius: 6,
                  ),
                ]
              : null,
        ),
        child: Text(
          title,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.white60,
            fontSize: 11.5,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
          ),
        ),
      ),
    );
  }

  Widget _buildQuickGiftTile({
    required String icon,
    required String name,
    required int cost,
    required String badge,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 76,
        padding: const EdgeInsets.symmetric(vertical: 6),
        decoration: BoxDecoration(
          color: const Color(0xFF1E1730),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: Colors.white.withValues(alpha: 0.10),
            width: 0.8,
          ),
        ),
        child: Column(
          children: [
            Text(icon, style: const TextStyle(fontSize: 26)),
            const SizedBox(height: 2),
            Text(
              name,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 11,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 1),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.diamond_rounded,
                  color: Color(0xFFFFD600),
                  size: 10,
                ),
                const SizedBox(width: 2),
                Text(
                  '$cost',
                  style: const TextStyle(
                    color: Color(0xFFFFD600),
                    fontSize: 10.5,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// PK-Style Comment Capsule & Bottom Bar (Matching User Reference Image 2)
  /// Rounded capsule: height 44, Color(0xCC121018), border: Border.all(color: Color(0xFFFFD600), width: 1.4),
  /// glow: BoxShadow(color: Color(0x33FFD600), blurRadius: 8), left: 😊 emoji + "Type a message...",
  /// Right icons: ⭐, 🌹, 🎁
  Widget _buildPKStyleCommentInputBar() {
    return Container(
      padding: const EdgeInsets.fromLTRB(12, 4, 12, 10),
      child: Row(
        children: [
          // Capsule Input Box (Matching PK Screen & User Screenshot)
          Expanded(
            child: _showCommentInput
                ? Container(
                    height: 44,
                    padding: const EdgeInsets.symmetric(horizontal: 14),
                    decoration: BoxDecoration(
                      color: const Color(0xCC121018),
                      borderRadius: BorderRadius.circular(22),
                      border: Border.all(
                        color: const Color(0xFFFFD600),
                        width: 1.4,
                      ),
                      boxShadow: const [
                        BoxShadow(
                          color: Color(0x33FFD600),
                          blurRadius: 8,
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        const Text('😊', style: TextStyle(fontSize: 18)),
                        const SizedBox(width: 8),
                        Expanded(
                          child: TextField(
                            controller: _commentInputController,
                            focusNode: _commentFocusNode,
                            autofocus: true,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 13.5,
                              fontWeight: FontWeight.w600,
                            ),
                            onSubmitted: _handleSendComment,
                            decoration: const InputDecoration(
                              hintText: 'Type a message...',
                              hintStyle: TextStyle(
                                color: Colors.white60,
                                fontSize: 13.5,
                                fontWeight: FontWeight.w500,
                              ),
                              border: InputBorder.none,
                              isDense: true,
                              contentPadding: EdgeInsets.zero,
                            ),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(
                            Icons.send_rounded,
                            color: Color(0xFFFFD600),
                            size: 22,
                          ),
                          onPressed: () =>
                              _handleSendComment(_commentInputController.text),
                        ),
                      ],
                    ),
                  )
                : GestureDetector(
                    onTap: () {
                      setState(() => _showCommentInput = true);
                      Future.delayed(const Duration(milliseconds: 100), () {
                        if (mounted) _commentFocusNode.requestFocus();
                      });
                    },
                    child: Container(
                      height: 44,
                      padding: const EdgeInsets.symmetric(horizontal: 14),
                      decoration: BoxDecoration(
                        color: const Color(0xCC121018),
                        borderRadius: BorderRadius.circular(22),
                        border: Border.all(
                          color: const Color(0xFFFFD600),
                          width: 1.4,
                        ),
                        boxShadow: const [
                          BoxShadow(
                            color: Color(0x33FFD600),
                            blurRadius: 8,
                          ),
                        ],
                      ),
                      child: Row(
                        children: const [
                          Text('😊', style: TextStyle(fontSize: 18)),
                          SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'Type a message...',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color: Colors.white60,
                                fontSize: 13.5,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
          ),
          const SizedBox(width: 6),

          // Star ⭐ Button
          GestureDetector(
            onTap: _tapStarButton,
            child: Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xDD1A132C),
                border: Border.all(
                  color: const Color(0xFFFFD600).withValues(alpha: 0.8),
                  width: 1.2,
                ),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x44FFD600),
                    blurRadius: 6,
                  ),
                ],
              ),
              child: const Center(
                child: Text('⭐', style: TextStyle(fontSize: 18)),
              ),
            ),
          ),
          const SizedBox(width: 5),

          // Rose 🌹 Button
          GestureDetector(
            onTap: _sendQuickRose,
            child: Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xDD1A132C),
                border: Border.all(
                  color: const Color(0xFFFF2D55).withValues(alpha: 0.8),
                  width: 1.2,
                ),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x44FF2D55),
                    blurRadius: 6,
                  ),
                ],
              ),
              child: const Center(
                child: Text('🌹', style: TextStyle(fontSize: 18)),
              ),
            ),
          ),
          const SizedBox(width: 5),

          // Gift 🎁 Button
          GestureDetector(
            onTap: _openGiftSheet,
            child: Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: const LinearGradient(
                  colors: [Color(0xFFFF2D55), Color(0xFFE040FB)],
                ),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x55FF2D55),
                    blurRadius: 8,
                  ),
                ],
              ),
              child: const Center(
                child: Icon(
                  Icons.card_giftcard_rounded,
                  color: Colors.white,
                  size: 19,
                ),
              ),
            ),
          ),
          const SizedBox(width: 5),

          // More Options Button (...) - Matching User Reference Image 1
          GestureDetector(
            onTap: _showMoreOptionsSheet,
            child: Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xDD1A132C),
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.28),
                  width: 1.2,
                ),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x33000000),
                    blurRadius: 6,
                  ),
                ],
              ),
              child: const Center(
                child: Icon(
                  Icons.more_horiz_rounded,
                  color: Colors.white,
                  size: 20,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// More Options Modal Sheet (Matching User Reference Image 1: Design 2 - List Style)
  /// Features: Share Room, Invite Friends, Room Settings, Background, Effects, Report, Room Info, Help & Support, Leave Room
  void _showMoreOptionsSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return Container(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.sizeOf(context).height * 0.78,
          ),
          decoration: BoxDecoration(
            color: const Color(0xFB0D1527),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(26)),
            border: Border.all(
              color: const Color(0x3340C4FF),
              width: 1.2,
            ),
            boxShadow: const [
              BoxShadow(
                color: Color(0x99000000),
                blurRadius: 24,
                spreadRadius: 2,
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Top drag indicator
              Container(
                margin: const EdgeInsets.only(top: 10, bottom: 4),
                width: 36,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.white24,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),

              // Title Row: "More Options" + ✕ Close
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 6, 14, 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'More Options',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.3,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(
                        Icons.close_rounded,
                        color: Colors.white70,
                        size: 20,
                      ),
                      onPressed: () => Navigator.pop(ctx),
                    ),
                  ],
                ),
              ),

              const Divider(color: Colors.white12, height: 1),

              // 9 List Items with Descriptions (Matching Image 1)
              Expanded(
                child: ListView(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  children: [
                    _buildMoreOptionItem(
                      icon: Icons.share_rounded,
                      iconBg: const Color(0xFF1E88E5),
                      title: 'Share Room',
                      subtitle: 'Share link to invite',
                      onTap: () {
                        Navigator.pop(ctx);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Room link copied! Share with friends 🔗'),
                            backgroundColor: Color(0xFFFFD600),
                            duration: Duration(seconds: 2),
                          ),
                        );
                      },
                    ),
                    _buildMoreOptionItem(
                      icon: Icons.person_add_alt_1_rounded,
                      iconBg: const Color(0xFFE91E63),
                      title: 'Invite Friends',
                      subtitle: 'Invite from contacts',
                      onTap: () {
                        Navigator.pop(ctx);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Inviting friends from contacts... 👥'),
                            backgroundColor: Color(0xFFFF2D55),
                            duration: Duration(seconds: 2),
                          ),
                        );
                      },
                    ),
                    _buildMoreOptionItem(
                      icon: Icons.settings_rounded,
                      iconBg: const Color(0xFF546E7A),
                      title: 'Room Settings',
                      subtitle: 'Manage room controls',
                      onTap: () {
                        Navigator.pop(ctx);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Room controls and audio settings ⚙️'),
                            backgroundColor: Color(0xFFFFD600),
                            duration: Duration(seconds: 2),
                          ),
                        );
                      },
                    ),
                    _buildMoreOptionItem(
                      icon: Icons.image_rounded,
                      iconBg: const Color(0xFF7E57C2),
                      title: 'Background',
                      subtitle: 'Change background',
                      onTap: () {
                        Navigator.pop(ctx);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Atmosphere background changed ✨'),
                            backgroundColor: Color(0xFF7E57C2),
                            duration: Duration(seconds: 2),
                          ),
                        );
                      },
                    ),
                    _buildMoreOptionItem(
                      icon: Icons.auto_fix_high_rounded,
                      iconBg: const Color(0xFFFF9800),
                      title: 'Effects',
                      subtitle: 'Filters, beauty, stickers',
                      onTap: () {
                        Navigator.pop(ctx);
                        _heartsKey.currentState?.addHeart();
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Filters and effects enabled 🪄'),
                            backgroundColor: Color(0xFFFF9800),
                            duration: Duration(seconds: 2),
                          ),
                        );
                      },
                    ),
                    _buildMoreOptionItem(
                      icon: Icons.flag_rounded,
                      iconBg: const Color(0xFFD32F2F),
                      title: 'Report',
                      subtitle: 'Report user or content',
                      onTap: () {
                        Navigator.pop(ctx);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Report submitted. Our moderators are reviewing 🚩'),
                            backgroundColor: Color(0xFFD32F2F),
                            duration: Duration(seconds: 2),
                          ),
                        );
                      },
                    ),
                    _buildMoreOptionItem(
                      icon: Icons.info_outline_rounded,
                      iconBg: const Color(0xFF00ACC1),
                      title: 'Room Info',
                      subtitle: 'See room details',
                      onTap: () {
                        Navigator.pop(ctx);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Room Host: ${_selectedRoom['hostName']} • 9 Live Members • 12.4K Watching'),
                            backgroundColor: const Color(0xFF00ACC1),
                            duration: const Duration(seconds: 2),
                          ),
                        );
                      },
                    ),
                    _buildMoreOptionItem(
                      icon: Icons.help_outline_rounded,
                      iconBg: const Color(0xFF43A047),
                      title: 'Help & Support',
                      subtitle: 'Get help',
                      onTap: () {
                        Navigator.pop(ctx);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Connecting to Tivoo Live Support 💬'),
                            backgroundColor: Color(0xFF43A047),
                            duration: Duration(seconds: 2),
                          ),
                        );
                      },
                    ),
                    _buildMoreOptionItem(
                      icon: Icons.logout_rounded,
                      iconBg: const Color(0xFFFF2D55),
                      title: 'Leave Room',
                      subtitle: '',
                      isDestructive: true,
                      onTap: () {
                        Navigator.pop(ctx);
                        _showEndRoomDialog();
                      },
                    ),
                    const SizedBox(height: 12),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildMoreOptionItem({
    required IconData icon,
    required Color iconBg,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    bool isDestructive = false,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
        child: Row(
          children: [
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: iconBg,
                boxShadow: [
                  BoxShadow(
                    color: iconBg.withValues(alpha: 0.35),
                    blurRadius: 6,
                  ),
                ],
              ),
              child: Center(
                child: Icon(icon, color: Colors.white, size: 18),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      color: isDestructive ? const Color(0xFFFF2D55) : Colors.white,
                      fontSize: 14.5,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  if (subtitle.isNotEmpty) ...[
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        color: Colors.white54,
                        fontSize: 11.5,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const Icon(
              Icons.chevron_right_rounded,
              color: Colors.white38,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }

  /// Uniform Comment Capsule matching PK screen
  /// ("chat room la konjma length iruku yellathu ora mathiri panni kudu different illama")
  Widget _buildUnifiedCommentCapsule(LiveComment msg, int index) {
    // User Requirement: First 2 comments from bottom are solid (nalla theriyanu)
    // Older comments moving upwards are lite/transparent (lite theriyu)!
    final bool isBottom2 = index < 2;
    final double opacity = isBottom2 ? 1.0 : 0.44;
    final bool isGift = msg.type == LiveCommentType.gift ||
        msg.message.contains('sent a ') ||
        msg.message.contains('sent ');

    return Opacity(
      opacity: opacity,
      child: Align(
        alignment: Alignment.centerLeft,
        child: Container(
          margin: const EdgeInsets.only(bottom: 5),
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4.5),
          decoration: BoxDecoration(
            color: isBottom2
                ? const Color(0x99100E20)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isBottom2
                  ? const Color(0xCCFFD600)
                  : const Color(0x18FFD600),
              width: isBottom2 ? 1.0 : 0.5,
            ),
            boxShadow: isBottom2
                ? const [
                    BoxShadow(
                      color: Color(0x20FFD600),
                      blurRadius: 5,
                      spreadRadius: 0.5,
                    ),
                  ]
                : null,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              CustomAvatar(
                radius: isBottom2 ? 12 : 10,
                assetPath: msg.userAssetPath ?? AppAssets.avatarArun,
              ),
              const SizedBox(width: 7),
              Flexible(
                child: isGift
                    ? RichText(
                        text: TextSpan(
                          children: [
                            TextSpan(
                              text: '${msg.userName} ',
                              style: TextStyle(
                                color: Colors.white.withValues(alpha: isBottom2 ? 1.0 : 0.88),
                                fontWeight: FontWeight.bold,
                                fontSize: 11.5,
                                shadows: const [
                                  Shadow(color: Colors.black87, blurRadius: 2.5),
                                ],
                              ),
                            ),
                            TextSpan(
                              text: msg.message,
                              style: const TextStyle(
                                color: Color(0xFFFFD600),
                                fontWeight: FontWeight.w700,
                                fontSize: 11.0,
                                shadows: [
                                  Shadow(color: Colors.black87, blurRadius: 2.5),
                                ],
                              ),
                            ),
                          ],
                        ),
                      )
                    : RichText(
                        text: TextSpan(
                          children: [
                            TextSpan(
                              text: '${msg.userName}: ',
                              style: TextStyle(
                                color: isBottom2
                                    ? const Color(0xFFFFD600)
                                    : const Color(0xDDFFD600),
                                fontWeight: FontWeight.bold,
                                fontSize: 11.5,
                                shadows: const [
                                  Shadow(color: Colors.black87, blurRadius: 2.5),
                                ],
                              ),
                            ),
                            TextSpan(
                              text: msg.message,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 11.5,
                                shadows: [
                                  Shadow(color: Colors.black87, blurRadius: 2.5),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMicBadge(bool isMicOn) {
    return Container(
      padding: const EdgeInsets.all(3.5),
      decoration: BoxDecoration(
        color: isMicOn ? const Color(0xFF00E676) : const Color(0xFFFF2D55),
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: (isMicOn ? const Color(0xFF00E676) : const Color(0xFFFF2D55))
                .withValues(alpha: 0.45),
            blurRadius: 4,
          ),
        ],
      ),
      child: Icon(
        isMicOn ? Icons.mic_rounded : Icons.mic_off_rounded,
        color: Colors.white,
        size: 9.5,
      ),
    );
  }

  // ===========================================================================
  // STEP 5: ROOM ENDED (FINAL PAGE - SAME FOR EVERYONE)
  // ===========================================================================
  Widget _buildRoomEndedView() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(18, 10, 18, 16),
      child: Column(
        children: [
          // 1. Top Tiki/Tivoo Logo
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 28,
                height: 28,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    colors: [Color(0xFFFFEA00), Color(0xFFFF9100)],
                  ),
                ),
                child: const Center(
                  child: Icon(
                    Icons.play_arrow_rounded,
                    color: Colors.black,
                    size: 20,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              const Text(
                'Tiki',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // 2. Celebratory 3D Microphone with golden crown & floating sparkles
          AnimatedBuilder(
            animation: _celebrationAnimation,
            builder: (context, child) {
              return Transform.translate(
                offset: Offset(0, _celebrationAnimation.value),
                child: child,
              );
            },
            child: Stack(
              alignment: Alignment.center,
              children: [
                Container(
                  width: 90,
                  height: 90,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFFFFD600).withValues(alpha: 0.35),
                        blurRadius: 36,
                        spreadRadius: 8,
                      ),
                    ],
                  ),
                ),
                const Positioned(
                  top: 0,
                  right: 14,
                  child: Text('✨', style: TextStyle(fontSize: 16)),
                ),
                const Positioned(
                  bottom: 6,
                  left: 10,
                  child: Text('🎉', style: TextStyle(fontSize: 14)),
                ),
                const Positioned(
                  top: 8,
                  left: 16,
                  child: Text('⭐', style: TextStyle(fontSize: 13)),
                ),
                Container(
                  width: 72,
                  height: 72,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: const LinearGradient(
                      colors: [Color(0xFF8A2BE2), Color(0xFF4A148C)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    border: Border.all(
                      color: const Color(0xFFFFD600),
                      width: 2,
                    ),
                  ),
                  child: Stack(
                    alignment: Alignment.center,
                    children: const [
                      Positioned(
                        top: 4,
                        child: Text('👑', style: TextStyle(fontSize: 12)),
                      ),
                      Icon(Icons.mic_rounded, color: Colors.white, size: 34),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),

          // 3. Ribbon Banner: "Chat Room Ended"
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 6),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFFFF2D55), Color(0xFFE040FB)],
              ),
              borderRadius: BorderRadius.circular(16),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x66FF2D55),
                  blurRadius: 12,
                  offset: Offset(0, 3),
                ),
              ],
            ),
            child: const Text(
              'Chat Room Ended',
              style: TextStyle(
                color: Colors.white,
                fontSize: 14.5,
                fontWeight: FontWeight.w900,
                letterSpacing: 0.5,
              ),
            ),
          ),
          const SizedBox(height: 6),

          // Subtitle
          const Text(
            'Thank you everyone\nfor being part of this room!',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white70,
              fontSize: 12.5,
              height: 1.3,
            ),
          ),
          const SizedBox(height: 12),

          // 4. Host Summary Card (Matching reference image Step 5)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: const Color(0xFF141224),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                color: const Color(0xFFFFD600).withValues(alpha: 0.35),
              ),
            ),
            child: Row(
              children: [
                Stack(
                  alignment: Alignment.bottomCenter,
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: const Color(0xFFFFD600),
                          width: 1.5,
                        ),
                      ),
                      child: CustomAvatar(
                        radius: 24,
                        assetPath: _selectedRoom['avatar'] as String,
                      ),
                    ),
                    Positioned(
                      bottom: -2,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 4,
                          vertical: 1,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFF2D55),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: const Text(
                          'Host',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 7.5,
                            fontWeight: FontWeight.bold,
                          ),
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
                      Row(
                        children: [
                          Text(
                            _selectedRoom['hostName'] as String,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(width: 4),
                          const Icon(
                            Icons.verified_rounded,
                            color: Color(0xFF29B6F6),
                            size: 13,
                          ),
                        ],
                      ),
                      const SizedBox(height: 2),
                      Row(
                        children: [
                          const Text('👑', style: TextStyle(fontSize: 10)),
                          const SizedBox(width: 3),
                          Text(
                            _selectedRoom['tag'] as String,
                            style: const TextStyle(
                              color: Color(0xFFFFD600),
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 2),
                      Text(
                        _selectedRoom['tagline'] as String,
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 11,
                        ),
                      ),
                      const SizedBox(height: 2),
                      const Text(
                        'Sep 22, 2026  10:45 PM',
                        style: TextStyle(
                          color: Colors.white38,
                          fontSize: 10,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),

          // 5. 2x2 Stats Grid (Matching reference image Step 5)
          Expanded(
            child: GridView.count(
              crossAxisCount: 2,
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
              childAspectRatio: 1.45,
              physics: const NeverScrollableScrollPhysics(),
              children: [
                _buildStatTile(
                  icon: Icons.star_rounded,
                  iconColor: const Color(0xFFFFD600),
                  value: '$_totalStarsCount',
                  label: 'Total Stars',
                ),
                _buildStatTile(
                  icon: Icons.schedule_rounded,
                  iconColor: const Color(0xFF00E676),
                  value: '2h 35m',
                  label: 'Total Duration',
                ),
                _buildStatTile(
                  icon: Icons.groups_rounded,
                  iconColor: const Color(0xFFFF2D55),
                  value: _selectedRoom['viewers'] as String,
                  label: 'Total Members',
                ),
                _buildStatTile(
                  icon: Icons.visibility_rounded,
                  iconColor: const Color(0xFF00E5FF),
                  value: '3,620',
                  label: 'Total Views',
                ),
              ],
            ),
          ),

          // 6. Bottom "Back to Home" Button
          GestureDetector(
            onTap: () {
              _setStage(1); // Return to Step 1: Chat Room List
            },
            child: Container(
              width: double.infinity,
              height: 48,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFFFFEA00), Color(0xFFFF9100)],
                ),
                borderRadius: BorderRadius.circular(24),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x66FFD600),
                    blurRadius: 14,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: const Center(
                child: Text(
                  'Back to Home',
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 16,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatTile({
    required IconData icon,
    required Color iconColor,
    required String value,
    required String label,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFF141224),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFFFFD600).withValues(alpha: 0.2),
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: iconColor, size: 24),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white60,
              fontSize: 11,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
