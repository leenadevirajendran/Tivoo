import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/constants/app_assets.dart';
import '../../../../core/widgets/custom_avatar.dart';
import '../../../live_stream/domain/models/gift_item.dart';
import '../../../live_stream/domain/models/live_comment.dart';
import '../../../live_stream/presentation/widgets/active_gift_animation_overlay.dart';
import '../../../live_stream/presentation/widgets/floating_hearts_overlay.dart';
import '../../../live_stream/presentation/widgets/floating_stars_overlay.dart';
import '../../../live_stream/presentation/widgets/gift_bottom_sheet.dart';
import '../../../../core/widgets/luxury_atmosphere_background.dart';

/// 5-Step Chat Room Flow with High-End TIVOO Aesthetics & GoogleFonts.outfit:
/// Step 1: Chat Room List Screen (Header: ← Chat Room 🔍, room cards with Join, and "+ Create Chat Room")
/// Step 2: Tap Join Modal (Room details preview: Host avatar, name, tag, capacity, Join / Cancel)
/// Request & Notification Page: Host receives join request and can [Accept & Join] or [Reject]!
/// Step 3: Inside Chat Room (Top host bar with notification bell, 3x3 9-seat audio grid, 5 action buttons: Mic, Sound, Gift, Star, More, live chat input bar)
/// Step 4: Host Ends Room Modal ("End Chat Room? All members will be removed...", Cancel / End Room)
/// Step 5: Room Ended Final Page (Official TIVOO home branding, 3D mic with golden confetti, "Chat Room Ended" ribbon, Host card, 4 stats cards, "Back to Home")
class ChatRoomPartyScreen extends StatefulWidget {
  final int initialStage;
  final VoidCallback? onBack;
  final bool isEmbeddedInHome;
  final ValueChanged<int>? onStageChanged;

  const ChatRoomPartyScreen({
    super.key,
    this.initialStage = 1,
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
  // 2 = Step 2: Tap Join (Room Details Preview)
  // 3 = Step 3: Inside Chat Room
  // 4 = Step 4: Host Ends Room Modal
  // 5 = Step 5: Room Ended Final Summary Page
  late int _currentStage;

  // Selected Room Data
  late Map<String, dynamic> _selectedRoom;

  // Search in Step 1
  bool _isSearchOpen = false;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';


  // Room mode in Step 3: Audio vs Video
  bool _isVideoRoom = false;

  // Audio controls
  bool _isMicMuted = false;
  bool _isSoundMuted = false;
  int _totalStarsCount = 12560;

  // Live Chat Comments and Controller
  final TextEditingController _chatInputController = TextEditingController();
  final ScrollController _chatScrollController = ScrollController();
  late List<LiveComment> _chatMessages;

  // Speaking wave animation controller
  late final AnimationController _waveController;
  late final Animation<double> _waveAnimation;

  // Confetti / Celebration animation for Step 5
  late final AnimationController _celebrationController;
  late final Animation<double> _celebrationAnimation;

  // Room List Data (Matching reference image Step 1)
  late List<Map<String, dynamic>> _roomsList;

  // 9 Seats for Step 3 (Matching reference image Step 3)
  late List<Map<String, dynamic>> _seats;

  // Pending Join Requests (for notification page)
  final List<Map<String, dynamic>> _pendingRequests = [];

  // Ambient heart timer
  Timer? _ambientTimer;

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

    // Initial Rooms list matching Step 1 in user reference (5 profiles only)
    _roomsList = [
      {
        'id': 'room_1',
        'hostName': 'Diya_Official',
        'isVerified': false,
        'tagline': "Let's talk & be friends 💕",
        'tag': 'Dream Team',
        'tagIcon': '👑',
        'capacity': '8/9',
        'viewers': '128',
        'avatar': AppAssets.avatarDiya,
        'isVideo': false,
        'isHost': true,
      },
      {
        'id': 'room_2',
        'hostName': 'Arun_kumar',
        'isVerified': false,
        'tagline': 'Good Vibes Only ✨',
        'tag': 'Friends',
        'tagIcon': '👥',
        'capacity': '6/9',
        'viewers': '96',
        'avatar': AppAssets.avatarArun,
        'isVideo': false,
        'isHost': false,
      },
      {
        'id': 'room_3',
        'hostName': 'Sneha_Live',
        'isVerified': false,
        'tagline': 'Chill Chat 🥰',
        'tag': 'Happy Family',
        'tagIcon': '👑',
        'capacity': '7/9',
        'viewers': '142',
        'avatar': AppAssets.avatarMeena,
        'isVideo': false,
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
        'isVideo': true,
        'isHost': false,
      },
      {
        'id': 'room_5',
        'hostName': 'Priya_S',
        'isVerified': true,
        'tagline': 'Feel Free to Talk 💕',
        'tag': 'Sweet Hearts',
        'tagIcon': '👥',
        'capacity': '8/9',
        'viewers': '115',
        'avatar': AppAssets.avatarNeha,
        'isVideo': false,
        'isHost': false,
      },
      {
        'id': 'room_6',
        'hostName': 'Karthik_99',
        'isVerified': false,
        'tagline': 'Gaming & Friends 🎮',
        'tag': 'Legends',
        'tagIcon': '👑',
        'capacity': '4/9',
        'viewers': '74',
        'avatar': AppAssets.avatarKarthik,
        'isVideo': false,
        'isHost': false,
      },
    ];

    _selectedRoom = _roomsList.first;
    _isVideoRoom = _selectedRoom['isVideo'] as bool;

    // 9 Seats for Step 3 matching Reference Image 2:
    // Row 1: Diya (Host, pink badge, Active, equalizer), Arun (Listening), Sneha (Listening)
    // Row 2: Karthik (Listening), Neha (Listening, leaf doodle), Vicky (Listening, crown doodle)
    // Row 3: Saran (Listening, sparkles doodle), Meena (Listening, heart doodle), Seat 9: "+ Invite" empty seat card!
    _seats = [
      {
        'seat': 1,
        'name': 'Diya',
        'isHost': true,
        'isInvite': false,
        'avatar': AppAssets.avatarDiya,
        'status': 'Active',
        'isSpeaking': true,
        'isMicOn': true,
      },
      {
        'seat': 2,
        'name': 'Arun',
        'isHost': false,
        'isInvite': false,
        'avatar': AppAssets.avatarArun,
        'status': 'Listening',
        'isSpeaking': false,
        'isMicOn': true,
      },
      {
        'seat': 3,
        'name': 'Sneha',
        'isHost': false,
        'isInvite': false,
        'avatar': AppAssets.avatarPriya,
        'status': 'Listening',
        'isSpeaking': false,
        'isMicOn': true,
      },
      {
        'seat': 4,
        'name': 'Karthik',
        'isHost': false,
        'isInvite': false,
        'avatar': AppAssets.avatarKarthik,
        'status': 'Listening',
        'isSpeaking': false,
        'isMicOn': true,
      },
      {
        'seat': 5,
        'name': 'Neha',
        'isHost': false,
        'isInvite': false,
        'avatar': AppAssets.avatarNeha,
        'status': 'Listening',
        'isSpeaking': false,
        'isMicOn': true,
      },
      {
        'seat': 6,
        'name': 'Vicky',
        'isHost': false,
        'isInvite': false,
        'avatar': AppAssets.avatarVicky,
        'status': 'Listening',
        'isSpeaking': false,
        'isMicOn': true,
      },
      {
        'seat': 7,
        'name': 'Saran',
        'isHost': false,
        'isInvite': false,
        'avatar': AppAssets.avatarSaran,
        'status': 'Listening',
        'isSpeaking': false,
        'isMicOn': true,
      },
      {
        'seat': 8,
        'name': 'Meena',
        'isHost': false,
        'isInvite': false,
        'avatar': AppAssets.avatarMeena,
        'status': 'Listening',
        'isSpeaking': false,
        'isMicOn': true,
      },
      {
        'seat': 9,
        'name': 'Invite',
        'isHost': false,
        'isInvite': true,
        'avatar': '',
        'isSpeaking': false,
        'isMicOn': false,
      },
    ];

    // Initial default pending request (simulating someone requesting to join audio seat)
    _pendingRequests.add({
      'name': 'Karthi',
      'avatar': AppAssets.avatarKarthik,
      'level': 'Lv.12',
      'message': 'wants to join your chat room as speaker',
      'time': 'Just now',
    });

    // Seed live comments
    final now = DateTime.now();
    _chatMessages = [
      LiveComment(
        id: 'c1',
        userName: 'User123',
        userAssetPath: AppAssets.avatarArun,
        message: 'So amazing! 👏',
        timestamp: now.subtract(const Duration(seconds: 40)),
      ),
      LiveComment(
        id: 'c2',
        userName: 'Queen',
        userAssetPath: AppAssets.avatarSneha,
        message: 'Super all ❤️🔥',
        timestamp: now.subtract(const Duration(seconds: 30)),
      ),
      LiveComment(
        id: 'c3',
        userName: 'Kavin',
        userAssetPath: AppAssets.avatarKarthik,
        message: 'sent a Star ⭐ to Diya',
        type: LiveCommentType.gift,
        timestamp: now.subtract(const Duration(seconds: 18)),
      ),
      LiveComment(
        id: 'c4',
        userName: 'Anitha',
        userAssetPath: AppAssets.avatarNeha,
        message: 'Happy evening everyone! ✨',
        timestamp: now.subtract(const Duration(seconds: 8)),
      ),
    ];

    _ambientTimer = Timer.periodic(const Duration(seconds: 6), (_) {
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
    _searchController.dispose();
    _chatInputController.dispose();
    _chatScrollController.dispose();
    super.dispose();
  }

  void _setStage(int stage) {
    if (_currentStage != stage) {
      setState(() {
        _currentStage = stage;
      });
      widget.onStageChanged?.call(stage);
    }
  }

  // ===========================================================================
  // MAIN BUILD
  // ===========================================================================
  @override
  Widget build(BuildContext context) {
    return ActiveGiftAnimationOverlay(
      key: _activeGiftKey,
      child: FloatingStarsOverlay(
        key: _starsKey,
        child: FloatingHeartsOverlay(
          key: _heartsKey,
          child: Scaffold(
            backgroundColor: Colors.transparent,
            body: Stack(
              fit: StackFit.expand,
              children: [
                // Global Luxury Atmosphere Background matching Home Screen
                const LuxuryAtmosphereBackground(
                  showParticles: true,
                  showLightBeams: true,
                ),

                // Active Stage View (Steps 1 to 5)
                SafeArea(
                  top: true,
                  bottom: true,
                  child: _buildCurrentStageView(),
                ),

                // Step 2 Modal Popup (when in Stage 2)
                if (_currentStage == 2)
                  _buildStep2TapJoinModal(),

                // Step 4 Modal Popup (when in Stage 4)
                if (_currentStage == 4)
                  _buildStep4HostEndsRoomModal(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCurrentStageView() {
    switch (_currentStage) {
      case 1:
        return _buildStep1ChatRoomListView(); // Step 1: Chat Room List
      case 2:
        return _buildStep1ChatRoomListView(); // Step 2 shows modal over list
      case 3:
        return _buildStep3InsideChatRoomView(); // Step 3: Inside Chat Room
      case 4:
        return _buildStep3InsideChatRoomView(); // Step 4 shows modal over room
      case 5:
        return _buildStep5RoomEndedView(); // Step 5: Room Ended Final Page
      default:
        return _buildStep1ChatRoomListView();
    }
  }

  // ===========================================================================
  // STEP 1: CHAT ROOM LIST (Matching Phone 1 in Reference Poster)
  // ===========================================================================
  Widget _buildStep1ChatRoomListView() {
    final filteredRooms = _roomsList.where((room) {
      if (_searchQuery.isNotEmpty) {
        final name = (room['hostName'] as String).toLowerCase();
        final tag = (room['tag'] as String).toLowerCase();
        final tagline = (room['tagline'] as String).toLowerCase();
        final q = _searchQuery.toLowerCase();
        if (!name.contains(q) && !tag.contains(q) && !tagline.contains(q)) {
          return false;
        }
      }
      return true;
    }).toList();

    return Column(
      children: [
        // 1. Top Bar: Back Button, TIVOO Logo, Chat Room Pill, Search (Matching Home Header)
        Padding(
          padding: const EdgeInsets.fromLTRB(10, 8, 14, 6),
          child: Row(
            children: [
              // Back Button (translucent circular glass)
              GestureDetector(
                onTap: () {
                  if (widget.onBack != null) {
                    widget.onBack!();
                  } else {
                    Navigator.of(context).maybePop();
                  }
                },
                child: Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.08),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.12),
                    ),
                  ),
                  child: const Center(
                    child: Icon(
                      Icons.arrow_back_ios_new_rounded,
                      color: Colors.white,
                      size: 16,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),

              // TIVOO Branding (matching Home Screen Logo)
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Tiv',
                    style: GoogleFonts.outfit(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 0.5,
                    ),
                  ),
                  Text(
                    'oo',
                    style: GoogleFonts.outfit(
                      color: const Color(0xFF00E676),
                      fontSize: 22,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(width: 2),
                  const Text('🌿', style: TextStyle(fontSize: 14)),
                ],
              ),

              const SizedBox(width: 8),

              // Active Chat Room Category Badge (matching Home Header tab)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFFBA43F6).withValues(alpha: 0.22),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: const Color(0xFFBA43F6).withValues(alpha: 0.60),
                    width: 1,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.mic_rounded,
                        color: Color(0xFFE1BEE7), size: 13),
                    const SizedBox(width: 4),
                    Text(
                      'Chat Room',
                      style: GoogleFonts.outfit(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),

              const Spacer(),

              // Search Button (glass circular button)
              GestureDetector(
                onTap: () {
                  setState(() {
                    _isSearchOpen = !_isSearchOpen;
                    if (!_isSearchOpen) {
                      _searchController.clear();
                      _searchQuery = '';
                    }
                  });
                },
                child: Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.08),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.12),
                    ),
                  ),
                  child: Center(
                    child: Icon(
                      _isSearchOpen
                          ? Icons.close_rounded
                          : Icons.search_rounded,
                      color: Colors.white70,
                      size: 18,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),

        // Interactive Search Bar (matching Home Header Search Pill)
        if (_isSearchOpen)
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 2, 16, 8),
            child: Container(
              height: 42,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(21),
                border: Border.all(
                  color: const Color(0xFFBA43F6).withValues(alpha: 0.50),
                  width: 1.2,
                ),
              ),
              child: TextField(
                controller: _searchController,
                autofocus: true,
                style: GoogleFonts.outfit(color: Colors.white, fontSize: 14),
                decoration: InputDecoration(
                  hintText: 'Search room by host or topic...',
                  hintStyle: GoogleFonts.outfit(
                      color: Colors.white38, fontSize: 13),
                  prefixIcon: const Icon(Icons.search_rounded,
                      color: Colors.white54, size: 18),
                  suffixIcon: _searchController.text.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear_rounded,
                              color: Colors.white54, size: 16),
                          onPressed: () {
                            _searchController.clear();
                            setState(() => _searchQuery = '');
                          },
                        )
                      : null,
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(vertical: 10),
                ),
                onChanged: (val) {
                  setState(() => _searchQuery = val.trim());
                },
              ),
            ),
          ),

        // 2. All 6 Profiles evenly filling the screen with Home Theme Styling
        Expanded(
          child: filteredRooms.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.search_off_rounded,
                          color: Colors.white38, size: 48),
                      const SizedBox(height: 10),
                      Text(
                        'No chat rooms found',
                        style: GoogleFonts.outfit(
                            color: Colors.white70, fontSize: 15),
                      ),
                    ],
                  ),
                )
              : filteredRooms.length <= 6
                  ? Column(
                      children: List.generate(filteredRooms.length, (index) {
                        return Expanded(
                          child: Center(
                            child: _buildRoomRowItem(filteredRooms[index]),
                          ),
                        );
                      }),
                    )
                  : ListView.builder(
                      physics: const BouncingScrollPhysics(),
                      itemCount: filteredRooms.length,
                      itemBuilder: (context, index) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4),
                          child: _buildRoomRowItem(filteredRooms[index]),
                        );
                      },
                    ),
        ),

        // 3. Bottom Docked Gradient Pill: "+ Create Chat Room" (Matching Home Theme)
        _buildCreateChatRoomButton(),
      ],
    );
  }

  /// Profile Item Row:
  /// - Glassmorphism Card matching Home Screen theme
  /// - Square Avatar (72x72, r: 15)
  /// - Host Name + Verified Indicator + Subtitle + 👑 Tag + 🔥 Viewers + 👤 Capacity
  /// - Rectangular "Join" Button matching Home "LIVE" theme
  Widget _buildRoomRowItem(Map<String, dynamic> room) {
    final hostName = room['hostName'] as String;
    final isVerified = room['isVerified'] as bool? ?? false;
    final tagline = room['tagline'] as String;
    final tag = room['tag'] as String;
    final tagIcon = room['tagIcon'] as String? ?? '👑';
    final capacity = room['capacity'] as String;
    final viewers = room['viewers'] as String? ?? '96';
    final avatar = room['avatar'] as String;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 14, vertical: 3),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFF131122).withValues(alpha: 0.65),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.08),
          width: 1,
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0x33000000),
            blurRadius: 10,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Left: Square Profile Avatar with rounded corners
          ClipRRect(
            borderRadius: BorderRadius.circular(15),
            child: Image.asset(
              avatar,
              width: 72,
              height: 72,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  color: const Color(0xFF221E36),
                  borderRadius: BorderRadius.circular(15),
                ),
                child: const Icon(Icons.person, color: Colors.white30, size: 36),
              ),
            ),
          ),
          const SizedBox(width: 12),

          // Center: Host Name, Tagline, Crown/Team Badge, Flame Viewers, Member count
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                // Host Name + blue verified indicator
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        hostName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.outfit(
                          color: Colors.white,
                          fontSize: 17.5,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.1,
                        ),
                      ),
                    ),
                    if (isVerified) ...[
                      const SizedBox(width: 5),
                      Container(
                        width: 14,
                        height: 14,
                        decoration: const BoxDecoration(
                          color: Color(0xFF00B0FF),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.check,
                          color: Colors.white,
                          size: 9.5,
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 3),

                // Tagline / topic
                Text(
                  tagline,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.outfit(
                    color: Colors.white.withValues(alpha: 0.70),
                    fontSize: 12.5,
                    fontWeight: FontWeight.w400,
                  ),
                ),
                const SizedBox(height: 6),

                // Team badge + 🔥 Flame Viewers (matching Home Screen!) + 👤 Capacity
                Row(
                  children: [
                    Text(tagIcon, style: const TextStyle(fontSize: 12.5)),
                    const SizedBox(width: 3),
                    Flexible(
                      child: Text(
                        tag,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.outfit(
                          color: const Color(0xFFFFD54F),
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    // Flame viewers count (matching Home Screen 🔥 counter)
                    const Text('🔥', style: TextStyle(fontSize: 11)),
                    const SizedBox(width: 2),
                    Text(
                      viewers,
                      style: GoogleFonts.outfit(
                        color: const Color(0xFFFFB300),
                        fontSize: 11.5,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(width: 6),
                    const Icon(
                      Icons.person,
                      color: Colors.white54,
                      size: 13,
                    ),
                    const SizedBox(width: 2),
                    Text(
                      capacity,
                      style: GoogleFonts.outfit(
                        color: Colors.white70,
                        fontSize: 11.5,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),

          // Right: Stadium Pill "Join" Button matching Home Screen "Live" Button
          GestureDetector(
            onTap: () {
              setState(() {
                _selectedRoom = room;
                _isVideoRoom = room['isVideo'] as bool? ?? false;
              });
              _setStage(2); // Opens Step 2 Tap Join Modal
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: const Color(0xFF211D32),
                borderRadius: BorderRadius.circular(18),
                border: Border.all(
                  color: const Color(0xFFFF2D55),
                  width: 1.5,
                ),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFFFF2D55).withValues(alpha: 0.35),
                    blurRadius: 8,
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.all(3.5),
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: Color(0xFFFF2D55),
                    ),
                    child: const Icon(
                      Icons.videocam_rounded,
                      color: Colors.white,
                      size: 11,
                    ),
                  ),
                  const SizedBox(width: 5),
                  Text(
                    'Join',
                    style: GoogleFonts.outfit(
                      color: Colors.white,
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.2,
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

  /// Prominent Gradient Pill Button: "+ Create Chat Room" (Matching Home Theme)
  Widget _buildCreateChatRoomButton() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 6, 16, 16),
      child: GestureDetector(
        onTap: _showCreateRoomSheet,
        child: Container(
          width: double.infinity,
          height: 52,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFFFF2D55), Color(0xFFFF5E8A)],
            ),
            borderRadius: BorderRadius.circular(26),
            boxShadow: const [
              BoxShadow(
                color: Color(0x66FF2D55),
                blurRadius: 16,
                spreadRadius: 1,
                offset: Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.add_rounded, color: Colors.white, size: 24),
              const SizedBox(width: 6),
              Text(
                'Create Chat Room',
                style: GoogleFonts.outfit(
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

  // ===========================================================================
  // CREATE CHAT ROOM MODAL (HOST CREATES ROOM)
  // ===========================================================================
  void _showCreateRoomSheet() {
    final titleController = TextEditingController(text: "My Party Room 💕");
    String selectedTag = 'Dream Team';
    bool isVideoSelected = false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setModalState) => Container(
          padding: EdgeInsets.fromLTRB(
              20, 20, 20, MediaQuery.of(ctx).viewInsets.bottom + 24),
          decoration: const BoxDecoration(
            color: Color(0xFF141126),
            borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
            boxShadow: [
              BoxShadow(
                color: Colors.black87,
                blurRadius: 25,
                offset: Offset(0, -6),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Create Chat Room',
                    style: GoogleFonts.outfit(
                      color: Colors.white,
                      fontSize: 19.5,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close_rounded, color: Colors.white70),
                    onPressed: () => Navigator.pop(ctx),
                  ),
                ],
              ),
              const SizedBox(height: 14),

              // Room Title Field
              Text(
                'Room Title / Topic',
                style: GoogleFonts.outfit(
                  color: Colors.white70,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 6),
              Container(
                decoration: BoxDecoration(
                  color: const Color(0xFF1E1A36),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: Colors.white12),
                ),
                child: TextField(
                  controller: titleController,
                  style: GoogleFonts.outfit(color: Colors.white, fontSize: 14.5),
                  decoration: InputDecoration(
                    hintText: 'Enter room topic...',
                    hintStyle: GoogleFonts.outfit(color: Colors.white38),
                    border: InputBorder.none,
                    contentPadding:
                        const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Category / Team Tag Selector
              Text(
                'Category / Team Badge',
                style: GoogleFonts.outfit(
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
                  'Dream Team',
                  'Friends',
                  'Music',
                  'Chill Chat',
                  'Happy Family',
                ].map((tag) {
                  final isSel = selectedTag == tag;
                  return GestureDetector(
                    onTap: () => setModalState(() => selectedTag = tag),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: isSel
                            ? const Color(0xFFFF2A6D)
                            : const Color(0xFF1E1A36),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: isSel
                              ? const Color(0xFFFF2A6D)
                              : Colors.white12,
                        ),
                      ),
                      child: Text(
                        '👑 $tag',
                        style: GoogleFonts.outfit(
                          color: isSel ? Colors.white : Colors.white70,
                          fontSize: 12,
                          fontWeight:
                              isSel ? FontWeight.w800 : FontWeight.w600,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 16),

              // Room Mode Selector
              Text(
                'Room Mode',
                style: GoogleFonts.outfit(
                  color: Colors.white70,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () =>
                          setModalState(() => isVideoSelected = false),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        decoration: BoxDecoration(
                          color: !isVideoSelected
                              ? const Color(0xFFFF2A6D).withValues(alpha: 0.2)
                              : const Color(0xFF1E1A36),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: !isVideoSelected
                                ? const Color(0xFFFF2A6D)
                                : Colors.white12,
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.mic_rounded,
                                color: Color(0xFFFF2A6D), size: 18),
                            const SizedBox(width: 6),
                            Text(
                              '🎙️ Audio (9 Seats)',
                              style: GoogleFonts.outfit(
                                color: Colors.white,
                                fontSize: 13,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: GestureDetector(
                      onTap: () =>
                          setModalState(() => isVideoSelected = true),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        decoration: BoxDecoration(
                          color: isVideoSelected
                              ? const Color(0xFFFF2A6D).withValues(alpha: 0.2)
                              : const Color(0xFF1E1A36),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: isVideoSelected
                                ? const Color(0xFFFF2A6D)
                                : Colors.white12,
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.videocam_rounded,
                                color: Color(0xFFE040FB), size: 18),
                            const SizedBox(width: 6),
                            Text(
                              '📹 Video Party',
                              style: GoogleFonts.outfit(
                                color: Colors.white,
                                fontSize: 13,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 22),

              // "Create & Start Room" Button
              GestureDetector(
                onTap: () {
                  final newRoom = {
                    'id': 'room_${DateTime.now().millisecondsSinceEpoch}',
                    'hostName': 'You (Host)',
                    'isVerified': true,
                    'tagline': titleController.text.trim().isEmpty
                        ? "Let's party together 💕"
                        : titleController.text.trim(),
                    'tag': selectedTag,
                    'tagIcon': '👑',
                    'capacity': '1/9',
                    'viewers': '1',
                    'avatar': AppAssets.avatarDiya,
                    'isVideo': isVideoSelected,
                    'isHost': true,
                  };

                  setState(() {
                    _roomsList.insert(0, newRoom);
                    _selectedRoom = newRoom;
                    _isVideoRoom = isVideoSelected;
                  });

                  Navigator.pop(ctx);
                  _setStage(3); // Enters Step 3 as Host!

                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('🎉 Chat Room Created! You are the Host.'),
                      backgroundColor: Color(0xFFFF2A6D),
                      duration: Duration(seconds: 2),
                    ),
                  );
                },
                child: Container(
                  width: double.infinity,
                  height: 48,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFFFF2A6D), Color(0xFFFF5E8A)],
                    ),
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: const [
                      BoxShadow(
                        color: Color(0x66FF2A6D),
                        blurRadius: 10,
                        offset: Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Center(
                    child: Text(
                      'Create Room & Go Live',
                      style: GoogleFonts.outfit(
                        color: Colors.white,
                        fontSize: 15.5,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 0.3,
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
  }

  // ===========================================================================
  // STEP 2: TAP JOIN MODAL (Matching Phone 2 in Reference Poster)
  // ===========================================================================
  Widget _buildStep2TapJoinModal() {
    final hostName = _selectedRoom['hostName'] as String;
    final isVerified = _selectedRoom['isVerified'] as bool? ?? false;
    final tagline = _selectedRoom['tagline'] as String;
    final tag = _selectedRoom['tag'] as String;
    final capacity = _selectedRoom['capacity'] as String;
    final avatar = _selectedRoom['avatar'] as String;

    return Container(
      color: Colors.black.withValues(alpha: 0.65), // Dimmed background
      child: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Container(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
            decoration: BoxDecoration(
              color: const Color(0xFF141126),
              borderRadius: BorderRadius.circular(28),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.12),
                width: 1.2,
              ),
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
                // Top Right '✕' close button
                Align(
                  alignment: Alignment.topRight,
                  child: GestureDetector(
                    onTap: () => _setStage(1), // Back to list
                    child: Container(
                      padding: const EdgeInsets.all(4),
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

                // Big Circular Host Avatar with Crown Badge on Side (Reference Image 2)
                Stack(
                  clipBehavior: Clip.none,
                  alignment: Alignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(3),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: const Color(0xFFFF2A6D),
                          width: 2,
                        ),
                        boxShadow: const [
                          BoxShadow(
                            color: Color(0x66FF2A6D),
                            blurRadius: 14,
                          ),
                        ],
                      ),
                      child: CustomAvatar(
                        radius: 44,
                        assetPath: avatar,
                      ),
                    ),
                    // Gold Crown Icon Badge at side of avatar (Reference Image 2)
                    Positioned(
                      right: -4,
                      bottom: 6,
                      child: Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: const LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              Color(0xFFFFEA00),
                              Color(0xFFFFB300),
                              Color(0xFFFF8F00),
                            ],
                          ),
                          border: Border.all(
                            color: const Color(0xFFFFF9C4),
                            width: 1.5,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFFFF8F00).withValues(alpha: 0.6),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Center(
                          child: CustomPaint(
                            size: const Size(18, 15),
                            painter: const _CrownIconPainter(color: Color(0xFFD84315)),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),

                // Host Name (e.g. Diya_Official) with blue tick
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      hostName,
                      style: GoogleFonts.outfit(
                        color: Colors.white,
                        fontSize: 19.5,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 0.3,
                      ),
                    ),
                    if (isVerified) ...[
                      const SizedBox(width: 5),
                      const Icon(
                        Icons.check_circle_rounded,
                        color: Color(0xFF29B6F6),
                        size: 16,
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 4),

                // Subtitle: "Let's talk & be friends 💕"
                Text(
                  tagline,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.outfit(
                    color: Colors.white.withValues(alpha: 0.75),
                    fontSize: 13.5,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 12),

                // 👑 Dream Team Badge
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text('👑', style: TextStyle(fontSize: 14)),
                    const SizedBox(width: 5),
                    Text(
                      tag,
                      style: GoogleFonts.outfit(
                        color: const Color(0xFFFFD54F),
                        fontSize: 13.5,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),

                // Member capacity: 👥 8/9
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.people_alt_rounded,
                        color: Colors.white70, size: 16),
                    const SizedBox(width: 6),
                    Text(
                      capacity,
                      style: GoogleFonts.outfit(
                        color: Colors.white,
                        fontSize: 14.5,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // Pill Button: "Join" (Matching Home Screen Live Button Design)
                GestureDetector(
                  onTap: () {
                    _handleJoinRequestFromModal();
                  },
                  child: Container(
                    width: double.infinity,
                    height: 48,
                    decoration: BoxDecoration(
                      color: const Color(0xFF211D32),
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(
                        color: const Color(0xFFFF2D55),
                        width: 1.8,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFFFF2D55).withValues(alpha: 0.35),
                          blurRadius: 10,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(5),
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            color: Color(0xFFFF2D55),
                          ),
                          child: const Icon(
                            Icons.videocam_rounded,
                            color: Colors.white,
                            size: 14,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Join',
                          style: GoogleFonts.outfit(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 0.3,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 12),

                // Pill Button: "Cancel" (Matching Reference Image 2 Dark Slate Style, Stadium Shape)
                GestureDetector(
                  onTap: () => _setStage(1),
                  child: Container(
                    width: double.infinity,
                    height: 48,
                    decoration: BoxDecoration(
                      color: const Color(0xFF162136),
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(
                        color: const Color(0xFF2C3959),
                        width: 1.4,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.35),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Center(
                      child: Text(
                        'Cancel',
                        style: GoogleFonts.outfit(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.3,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Triggered after user clicks "Join" in Step 2:
  /// Directly transitions into the chatroom screen (no popup!)
  void _handleJoinRequestFromModal() {
    _setStage(3); // Enter chat room directly
  }

  // ===========================================================================
  // NOTIFICATION PAGE / DIALOG: ACCEPT OR REJECT JOIN REQUEST
  // (User requested: "If anyone gives a request the notification page where
  // the user can accept join and reject the request")
  // ===========================================================================
  void _showHostJoinRequestNotificationDialog() {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (ctx) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.symmetric(horizontal: 24),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: const Color(0xFF16122C),
            borderRadius: BorderRadius.circular(26),
            border: Border.all(
              color: const Color(0xFFFF2A6D).withValues(alpha: 0.5),
              width: 1.5,
            ),
            boxShadow: const [
              BoxShadow(
                color: Color(0x77FF2A6D),
                blurRadius: 24,
                offset: Offset(0, 6),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header: 🔔 Join Request (1)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: const Color(0xFFFF2A6D).withValues(alpha: 0.2),
                        ),
                        child: const Icon(Icons.notifications_active_rounded,
                            color: Color(0xFFFF2A6D), size: 18),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Join Request (1)',
                        style: GoogleFonts.outfit(
                          color: Colors.white,
                          fontSize: 17.5,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ],
                  ),
                  GestureDetector(
                    onTap: () => Navigator.pop(ctx),
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.08),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.close_rounded,
                          color: Colors.white70, size: 16),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Requester Profile: Karthi wants to join audio seat
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFF1E1A36),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.white10),
                ),
                child: Row(
                  children: [
                    Stack(
                      alignment: Alignment.bottomRight,
                      children: [
                        CustomAvatar(
                          radius: 24,
                          assetPath: AppAssets.avatarKarthik,
                        ),
                        Container(
                          padding: const EdgeInsets.all(2),
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            color: Color(0xFF00E676),
                          ),
                          child: const Icon(Icons.mic,
                              color: Colors.black, size: 10),
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
                                'Karthi',
                                style: GoogleFonts.outfit(
                                  color: Colors.white,
                                  fontSize: 15.5,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                              const SizedBox(width: 6),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 6, vertical: 1.5),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFFFD54F)
                                      .withValues(alpha: 0.2),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  'Lv.12',
                                  style: GoogleFonts.outfit(
                                    color: const Color(0xFFFFD54F),
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 3),
                          Text(
                            'wants to join your room as speaker',
                            style: GoogleFonts.outfit(
                              color: Colors.white70,
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Action Buttons: [ Reject ] & [ Accept & Join ]
              Row(
                children: [
                  // Reject Button
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        Navigator.pop(ctx);
                        setState(() {
                          _pendingRequests.clear();
                        });
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text(
                                '❌ Join request rejected. User stays as listener.'),
                            backgroundColor: Color(0xFFD32F2F),
                            duration: Duration(seconds: 2),
                          ),
                        );
                      },
                      child: Container(
                        height: 44,
                        decoration: BoxDecoration(
                          color: const Color(0xFF261D2E),
                          borderRadius: BorderRadius.circular(22),
                          border: Border.all(
                            color: const Color(0xFFD32F2F).withValues(alpha: 0.6),
                            width: 1.2,
                          ),
                        ),
                        child: Center(
                          child: Text(
                            'Reject',
                            style: GoogleFonts.outfit(
                              color: const Color(0xFFFF5252),
                              fontSize: 14.5,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),

                  // Accept & Join Button
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        Navigator.pop(ctx);
                        // Accept user: Fill Seat 9 (replacing "+ Invite" with Karthi!)
                        setState(() {
                          _seats[8] = {
                            'seat': 9,
                            'name': 'Karthi',
                            'isHost': false,
                            'isInvite': false,
                            'avatar': AppAssets.avatarKarthik,
                            'isSpeaking': true,
                            'isMicOn': true,
                          };
                          _selectedRoom['capacity'] = '9/9';
                          _pendingRequests.clear();
                        });

                        _heartsKey.currentState?.addHeart();
                        _starsKey.currentState?.addStars(4);

                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text(
                                '🎉 Accepted! Karthi joined audio seat 9.'),
                            backgroundColor: Color(0xFF00C853),
                            duration: Duration(seconds: 2),
                          ),
                        );
                      },
                      child: Container(
                        height: 44,
                        decoration: BoxDecoration(
                          color: const Color(0xFF211D32),
                          borderRadius: BorderRadius.circular(22),
                          border: Border.all(
                            color: const Color(0xFFFF2D55),
                            width: 1.6,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFFFF2D55).withValues(alpha: 0.35),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(4),
                              decoration: const BoxDecoration(
                                shape: BoxShape.circle,
                                color: Color(0xFFFF2D55),
                              ),
                              child: const Icon(
                                Icons.videocam_rounded,
                                color: Colors.white,
                                size: 12,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Accept & Join',
                              style: GoogleFonts.outfit(
                                color: Colors.white,
                                fontSize: 14.5,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ],
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
  }

  // ===========================================================================
  // STEP 3: INSIDE CHAT ROOM (Matching Reference Image 2)
  // ===========================================================================
  Widget _buildStep3InsideChatRoomView() {
    final hostName = _selectedRoom['hostName'] as String;
    final tag = _selectedRoom['tag'] as String;
    final capacity = _selectedRoom['capacity'] as String;

    return Stack(
      children: [
        // Botanical glow foliage at bottom corners (Reference Image 2)
        Positioned(
          bottom: 0,
          left: 0,
          child: IgnorePointer(
            child: _buildBotanicalLeaves(isLeft: true),
          ),
        ),
        Positioned(
          bottom: 0,
          right: 0,
          child: IgnorePointer(
            child: _buildBotanicalLeaves(isLeft: false),
          ),
        ),

        // Main Chat Room Content
        Column(
          children: [
            const SizedBox(height: 6),

            // 1. Top Bar: Back Arrow | Crowned Mic Avatar | Diya_Official 👑 | 👑 Dream Team 👥 8/9 | [Leave] | ⋮
            _buildChatRoomHeader(hostName: hostName, tag: tag, capacity: capacity),

            // 2. Room Tagline Banner: 👑 Good Vibes • Great People • Better Conversations 💜 ♡
            _buildTaglineBanner(),

            // 3. 3x3 Grid of 9 Seats (Filling Screen dynamically)
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
                child: _buildNineSeatsGrid(),
              ),
            ),

            // 4. Unified Rounded Bottom Dock: 5 Action Buttons + Capsule Chat Input
            _buildUnifiedBottomDock(),
          ],
        ),
      ],
    );
  }

  /// Top Bar matching Reference Image 2 (Smooth & Responsive, No Overflow)
  Widget _buildChatRoomHeader({
    required String hostName,
    required String tag,
    required String capacity,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      child: Row(
        children: [
          // 1. Back Chevron Button
          GestureDetector(
            onTap: () {
              if (widget.onBack != null) {
                widget.onBack!();
              } else {
                _setStage(1);
              }
            },
            child: Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.06),
              ),
              child: const Center(
                child: Icon(
                  Icons.arrow_back_ios_new_rounded,
                  color: Colors.white,
                  size: 16,
                ),
              ),
            ),
          ),
          const SizedBox(width: 6),

          // 2. Crowned Microphone Room Avatar (with vibrant outer glow ring)
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: const SweepGradient(
                colors: [
                  Color(0xFFFFD54F),
                  Color(0xFFFF2A6D),
                  Color(0xFFBA68C8),
                  Color(0xFFFFD54F),
                ],
              ),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFFFF2A6D).withValues(alpha: 0.40),
                  blurRadius: 8,
                  spreadRadius: 1,
                ),
              ],
            ),
            padding: const EdgeInsets.all(2.0),
            child: Container(
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: Color(0xFF1B0F33),
              ),
              child: const Stack(
                alignment: Alignment.center,
                children: [
                  // Purple glowing mic icon
                  Icon(
                    Icons.mic_rounded,
                    color: Color(0xFFCE93D8),
                    size: 20,
                  ),
                  // Golden crown on top
                  Positioned(
                    top: 1,
                    child: Text('👑', style: TextStyle(fontSize: 9.5)),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 8),

          // 3. Room Host Title & Details (Smooth Responsive Layout)
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Flexible(
                      child: Text(
                        hostName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.outfit(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.1,
                        ),
                      ),
                    ),
                    const SizedBox(width: 4),
                    const Text('👑', style: TextStyle(fontSize: 13)),
                  ],
                ),
                const SizedBox(height: 2),
                FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text('👑', style: TextStyle(fontSize: 10)),
                      const SizedBox(width: 3),
                      Text(
                        tag,
                        style: GoogleFonts.outfit(
                          color: const Color(0xFFFFD54F),
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(width: 6),
                      const Icon(
                        Icons.people_alt_rounded,
                        color: Colors.white70,
                        size: 11.5,
                      ),
                      const SizedBox(width: 2.5),
                      Text(
                        capacity,
                        style: GoogleFonts.outfit(
                          color: Colors.white70,
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 6),

          // 4. Leave Button: Outline Pink Pill with Logout Icon (Compact & Sleek)
          GestureDetector(
            onTap: () {
              _setStage(4); // Triggers Step 4 Host Ends Room modal
            },
            child: Container(
              height: 30,
              padding: const EdgeInsets.symmetric(horizontal: 10),
              decoration: BoxDecoration(
                color: const Color(0xFF2E0C22).withValues(alpha: 0.55),
                borderRadius: BorderRadius.circular(15),
                border: Border.all(
                  color: const Color(0xFFFF2A6D),
                  width: 1.3,
                ),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFFFF2A6D).withValues(alpha: 0.22),
                    blurRadius: 6,
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.logout_rounded,
                    color: Color(0xFFFF2A6D),
                    size: 14,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'Leave',
                    style: GoogleFonts.outfit(
                      color: Colors.white,
                      fontSize: 11.5,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 4),

          // 5. Vertical Three Dots Menu
          GestureDetector(
            onTap: _showMoreOptionsMenu,
            child: Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.05),
              ),
              child: const Center(
                child: Icon(
                  Icons.more_vert_rounded,
                  color: Colors.white70,
                  size: 20,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Tagline Banner matching Reference Image 2 (Smooth Scale-Down, No Overflow)
  Widget _buildTaglineBanner() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 1, 12, 6),
      child: Row(
        children: [
          // Doodle crown on the left
          const Text(
            '👑',
            style: TextStyle(fontSize: 15, color: Color(0xFFC7923E)),
          ),
          const SizedBox(width: 6),
          Expanded(
            child: FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.center,
              child: Text(
                'Good Vibes  •  Great People  •  Better Conversations',
                textAlign: TextAlign.center,
                style: GoogleFonts.outfit(
                  color: const Color(0xFFD1C4E9),
                  fontSize: 11,
                  fontStyle: FontStyle.italic,
                  fontWeight: FontWeight.w500,
                  letterSpacing: 0.1,
                ),
              ),
            ),
          ),
          const SizedBox(width: 6),
          // Outline doodle hearts on the right
          const Text(
            '💜  ♡',
            style: TextStyle(fontSize: 12, color: Color(0xFFCE93D8)),
          ),
        ],
      ),
    );
  }

  /// 9-Seat Grid (3x3) dynamically sizing to fill the screen (Reference Image 2):
  /// Seat 1: Host Diya (pink border, 👑 Host badge, pink equalizer ılıı, Active, purple mic button)
  /// Seats 2 to 8: Arun, Sneha, Karthik, Neha (🌿), Vicky (👑), Saran (✨), Meena (💜) with Listening status & mic
  /// Seat 9: "+ Invite" empty seat card with dashed purple border & radiating sunburst
  Widget _buildNineSeatsGrid() {
    return LayoutBuilder(
      builder: (context, constraints) {
        const crossAxisSpacing = 9.0;
        const mainAxisSpacing = 9.0;
        final totalWidth = constraints.maxWidth;
        final totalHeight = constraints.maxHeight;
        final itemWidth = (totalWidth - (crossAxisSpacing * 2)) / 3;
        final itemHeight = (totalHeight - (mainAxisSpacing * 2)) / 3;
        final aspectRatio = (itemHeight > 0) ? (itemWidth / itemHeight) : 0.72;

        return GridView.builder(
          physics: const NeverScrollableScrollPhysics(),
          itemCount: 9,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            crossAxisSpacing: crossAxisSpacing,
            mainAxisSpacing: mainAxisSpacing,
            childAspectRatio: aspectRatio.clamp(0.60, 0.88),
          ),
          itemBuilder: (context, index) {
            final seat = _seats[index];
            final isHost = seat['isHost'] as bool? ?? false;
            final isInvite = seat['isInvite'] as bool? ?? false;
            final name = seat['name'] as String;
            final avatar = seat['avatar'] as String;
            final status = (seat['status'] as String?) ?? (isHost ? 'Active' : 'Listening');

            if (isInvite) {
              // Seat 9: Frosted Invite Slot with dashed border and radiating + (Reference Image 2)
              return GestureDetector(
                onTap: _showHostJoinRequestNotificationDialog,
                child: CustomPaint(
                  painter: _DashedBorderPainter(
                    color: const Color(0xFF7C4DFF).withValues(alpha: 0.55),
                    borderRadius: 18,
                  ),
                  child: Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFF100E26).withValues(alpha: 0.90),
                      borderRadius: BorderRadius.circular(18),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 8),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Sunburst Radiating Add Icon
                        _buildRadiatingAddIcon(),
                        const SizedBox(height: 8),
                        Text(
                          'Invite',
                          style: GoogleFonts.outfit(
                            color: Colors.white,
                            fontSize: 13.5,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          'Bring your friends\ninto the room',
                          textAlign: TextAlign.center,
                          style: GoogleFonts.outfit(
                            color: const Color(0xFFB39DDB),
                            fontSize: 9.5,
                            fontWeight: FontWeight.w500,
                            height: 1.25,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }

            // Occupied Seat (Studio Portrait Photo + Name + Status + Mic + Doodles)
            return GestureDetector(
              onTap: () => _showSeatMemberDetails(seat, index),
              child: AnimatedBuilder(
                animation: _waveAnimation,
                builder: (context, child) {
                  final glowScale = isHost ? _waveAnimation.value : 1.0;
                  return Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFF141126),
                      borderRadius: BorderRadius.circular(18),
                      border: isHost
                          ? Border.all(color: const Color(0xFFFF2A6D), width: 1.8)
                          : Border.all(
                              color: Colors.white.withValues(alpha: 0.12),
                              width: 1.2,
                            ),
                      boxShadow: [
                        if (isHost)
                          BoxShadow(
                            color: const Color(0xFFFF2A6D)
                                .withValues(alpha: 0.38 * glowScale),
                            blurRadius: 10 * glowScale,
                            spreadRadius: 1,
                          ),
                      ],
                    ),
                    child: child,
                  );
                },
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16.5),
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      // Studio Portrait Photo
                      Image.asset(
                        avatar,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => Container(
                          color: const Color(0xFF221E36),
                          child: const Icon(
                            Icons.person,
                            color: Colors.white30,
                            size: 36,
                          ),
                        ),
                      ),

                      // Bottom Dark Gradient Shade
                      DecoratedBox(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              Colors.transparent,
                              Colors.black.withValues(alpha: 0.88),
                            ],
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            stops: const [0.45, 1.0],
                          ),
                        ),
                      ),

                      // Top-Left: Host Badge (👑 Host) for Diya
                      if (isHost)
                        Positioned(
                          top: 6,
                          left: 6,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2.5),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFF2A6D),
                              borderRadius: BorderRadius.circular(8),
                              boxShadow: [
                                BoxShadow(
                                  color: const Color(0xFFFF2A6D).withValues(alpha: 0.5),
                                  blurRadius: 4,
                                ),
                              ],
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Text('👑', style: TextStyle(fontSize: 9.5)),
                                const SizedBox(width: 2.5),
                                Text(
                                  'Host',
                                  style: GoogleFonts.outfit(
                                    color: Colors.white,
                                    fontSize: 10,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),

                      // Top-Right: Animated Audio Equalizer Bars for Diya (Reference Image 2)
                      if (isHost)
                        Positioned(
                          top: 8,
                          right: 8,
                          child: _buildEqualizerBars(),
                        ),

                      // Bottom: Name + Status (Active/Listening) + Circular Mic Button
                      Positioned(
                        left: 7,
                        right: 6,
                        bottom: 6,
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            // Name + Status
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    name,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: GoogleFonts.outfit(
                                      color: Colors.white,
                                      fontSize: 13,
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                  const SizedBox(height: 1),
                                  Row(
                                    children: [
                                      Container(
                                        width: 5.5,
                                        height: 5.5,
                                        decoration: const BoxDecoration(
                                          color: Color(0xFF00E676),
                                          shape: BoxShape.circle,
                                        ),
                                      ),
                                      const SizedBox(width: 3.5),
                                      Text(
                                        status,
                                        style: GoogleFonts.outfit(
                                          color: isHost ? const Color(0xFF00E676) : Colors.white70,
                                          fontSize: 9.5,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            // Circular Mic Icon Badge
                            Container(
                              width: 28,
                              height: 28,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                gradient: isHost
                                    ? const LinearGradient(
                                        colors: [Color(0xFF8E24AA), Color(0xFFE91E63)],
                                      )
                                    : null,
                                color: isHost ? null : const Color(0xFF19162D).withValues(alpha: 0.85),
                                border: Border.all(
                                  color: isHost
                                      ? Colors.white.withValues(alpha: 0.3)
                                      : Colors.white.withValues(alpha: 0.20),
                                  width: 1,
                                ),
                                boxShadow: [
                                  if (isHost)
                                    BoxShadow(
                                      color: const Color(0xFFE91E63).withValues(alpha: 0.45),
                                      blurRadius: 6,
                                    ),
                                ],
                              ),
                              child: const Center(
                                child: Icon(
                                  Icons.mic_rounded,
                                  color: Colors.white,
                                  size: 15,
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
            );
          },
        );
      },
    );
  }

  /// Animated Pink Equalizer Bars for Diya (Reference Image 2)
  Widget _buildEqualizerBars() {
    return AnimatedBuilder(
      animation: _waveController,
      builder: (context, child) {
        final v = _waveController.value;
        return Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Container(
              width: 2.2,
              height: 5 + (v * 7),
              decoration: BoxDecoration(
                color: const Color(0xFFFF2A6D),
                borderRadius: BorderRadius.circular(1.5),
              ),
            ),
            const SizedBox(width: 2),
            Container(
              width: 2.2,
              height: 12 - (v * 6),
              decoration: BoxDecoration(
                color: const Color(0xFFFF2A6D),
                borderRadius: BorderRadius.circular(1.5),
              ),
            ),
            const SizedBox(width: 2),
            Container(
              width: 2.2,
              height: 4 + ((1.0 - v) * 8),
              decoration: BoxDecoration(
                color: const Color(0xFFFF2A6D),
                borderRadius: BorderRadius.circular(1.5),
              ),
            ),
          ],
        );
      },
    );
  }

  /// Radiating Sunburst Add Icon for Invite Slot (Reference Image 2)
  Widget _buildRadiatingAddIcon() {
    return SizedBox(
      width: 46,
      height: 46,
      child: Stack(
        alignment: Alignment.center,
        children: [
          CustomPaint(
            size: const Size(46, 46),
            painter: _RadiatingTicksPainter(),
          ),
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: const Color(0xFF221A44),
              border: Border.all(
                color: const Color(0xFF9C27B0).withValues(alpha: 0.8),
                width: 1.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF9C27B0).withValues(alpha: 0.4),
                  blurRadius: 8,
                ),
              ],
            ),
            child: const Center(
              child: Icon(Icons.add_rounded, color: Colors.white, size: 20),
            ),
          ),
        ],
      ),
    );
  }

  /// Tapping a seat opens interactive member dialog (profile / gifts / mute)
  void _showSeatMemberDetails(Map<String, dynamic> seat, int index) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        padding: const EdgeInsets.all(20),
        decoration: const BoxDecoration(
          color: Color(0xFF141126),
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CustomAvatar(radius: 36, assetPath: seat['avatar'] as String),
            const SizedBox(height: 10),
            Text(
              seat['name'] as String,
              style: GoogleFonts.outfit(
                color: Colors.white,
                fontSize: 18.5,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              seat['isHost'] == true ? '👑 Room Host' : '🎙️ Audio Speaker',
              style: GoogleFonts.outfit(
                  color: const Color(0xFFFFD54F),
                  fontSize: 13,
                  fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 18),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildSeatActionIcon(Icons.card_giftcard_rounded, 'Send Gift',
                    () {
                  Navigator.pop(ctx);
                  _openGiftSheet();
                }),
                _buildSeatActionIcon(Icons.star_rounded, 'Give Star', () {
                  Navigator.pop(ctx);
                  _sendStar();
                }),
                _buildSeatActionIcon(
                    seat['isMicOn'] == true ? Icons.mic_off : Icons.mic,
                    seat['isMicOn'] == true ? 'Mute' : 'Unmute', () {
                  setState(() {
                    _seats[index]['isMicOn'] = !(_seats[index]['isMicOn'] as bool);
                  });
                  Navigator.pop(ctx);
                }),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSeatActionIcon(IconData icon, String label, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.08),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: const Color(0xFFFF2A6D), size: 22),
          ),
          const SizedBox(height: 6),
          Text(
            label,
            style: GoogleFonts.outfit(
              color: Colors.white70,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  // ===========================================================================
  // UNIFIED BOTTOM DOCK (Reference Image 2)
  // 5 Action Buttons + Capsule Chat Input inside Sleek Rounded Dock
  // ===========================================================================
  Widget _buildUnifiedBottomDock() {
    return Container(
      margin: const EdgeInsets.fromLTRB(14, 2, 14, 10),
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 12),
      decoration: BoxDecoration(
        color: const Color(0xFF0F0E24).withValues(alpha: 0.85),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.08),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.5),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Row 1: 5 Circular Action Buttons (Mic, Sound, Gift, Star, More)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              // 1. Mic
              _buildDockActionButton(
                icon: _isMicMuted ? Icons.mic_off_rounded : Icons.mic_rounded,
                label: 'Mic',
                isHighlighted: true,
                iconColor: Colors.white,
                borderColor: const Color(0xFFFF2A6D),
                onTap: () {
                  setState(() => _isMicMuted = !_isMicMuted);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(_isMicMuted ? 'Mic Muted 🔇' : 'Mic Active 🎙️'),
                      duration: const Duration(seconds: 1),
                    ),
                  );
                },
              ),

              // 2. Sound
              _buildDockActionButton(
                icon: _isSoundMuted ? Icons.volume_off_rounded : Icons.volume_up_rounded,
                label: 'Sound',
                iconColor: const Color(0xFFFF4081),
                borderColor: const Color(0xFF7C4DFF).withValues(alpha: 0.4),
                onTap: () {
                  setState(() => _isSoundMuted = !_isSoundMuted);
                },
              ),

              // 3. Gift
              _buildDockActionButton(
                icon: Icons.card_giftcard_rounded,
                label: 'Gift',
                iconColor: const Color(0xFFFF4081),
                borderColor: const Color(0xFFFF2A6D).withValues(alpha: 0.4),
                onTap: _openGiftSheet,
              ),

              // 4. Star
              _buildDockActionButton(
                icon: Icons.star_rounded,
                label: 'Star',
                iconColor: const Color(0xFFFFD54F),
                borderColor: const Color(0xFF7C4DFF).withValues(alpha: 0.4),
                onTap: _sendStar,
              ),

              // 5. More
              _buildDockActionButton(
                icon: Icons.more_horiz_rounded,
                label: 'More',
                iconColor: Colors.white,
                borderColor: const Color(0xFF7C4DFF).withValues(alpha: 0.4),
                onTap: _showMoreOptionsMenu,
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Row 2: Capsule Chat Input + Smiley + Gradient Paper Airplane Send Button
          Container(
            height: 48,
            padding: const EdgeInsets.symmetric(horizontal: 14),
            decoration: BoxDecoration(
              color: const Color(0xFF141328),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.12),
                width: 1,
              ),
            ),
            child: Row(
              children: [
                // Smiley Icon
                GestureDetector(
                  onTap: () {
                    _chatInputController.text += ' 😊';
                  },
                  child: const Icon(
                    Icons.sentiment_satisfied_alt_rounded,
                    color: Colors.white70,
                    size: 22,
                  ),
                ),
                const SizedBox(width: 10),

                // Text Input
                Expanded(
                  child: TextField(
                    controller: _chatInputController,
                    style: GoogleFonts.outfit(color: Colors.white, fontSize: 13.5),
                    decoration: InputDecoration(
                      hintText: 'Type a message...',
                      hintStyle: GoogleFonts.outfit(
                        color: Colors.white38,
                        fontSize: 13.5,
                      ),
                      border: InputBorder.none,
                      isDense: true,
                      contentPadding: const EdgeInsets.symmetric(vertical: 10),
                    ),
                    onSubmitted: (_) => _sendMessage(),
                  ),
                ),

                // Purple/Indigo Gradient Send Button with Paper Plane
                GestureDetector(
                  onTap: _sendMessage,
                  child: Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: const LinearGradient(
                        colors: [Color(0xFF7C4DFF), Color(0xFF536DFE)],
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF7C4DFF).withValues(alpha: 0.4),
                          blurRadius: 6,
                        ),
                      ],
                    ),
                    child: const Center(
                      child: Icon(
                        Icons.send_rounded,
                        color: Colors.white,
                        size: 17,
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

  Widget _buildDockActionButton({
    required IconData icon,
    required String label,
    required Color iconColor,
    required Color borderColor,
    required VoidCallback onTap,
    bool isHighlighted = false,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isHighlighted ? const Color(0xFF1B0E27) : const Color(0xFF15122B),
              border: Border.all(
                color: borderColor,
                width: isHighlighted ? 1.8 : 1.3,
              ),
              boxShadow: [
                if (isHighlighted)
                  BoxShadow(
                    color: borderColor.withValues(alpha: 0.35),
                    blurRadius: 10,
                  ),
              ],
            ),
            child: Center(
              child: Icon(icon, color: iconColor, size: 24),
            ),
          ),
          const SizedBox(height: 5),
          Text(
            label,
            style: GoogleFonts.outfit(
              color: Colors.white,
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  /// Botanical foliage widget for bottom corners (Reference Image 2)
  Widget _buildBotanicalLeaves({required bool isLeft}) {
    return SizedBox(
      width: 140,
      height: 90,
      child: CustomPaint(
        painter: _BotanicalLeavesPainter(isLeft: isLeft),
      ),
    );
  }

  /// Star action: spawns floating stars & increments counter
  void _sendStar() {
    _starsKey.currentState?.addStars(3);
    setState(() {
      _totalStarsCount += 10;
      _chatMessages.add(
        LiveComment(
          id: 'c_${DateTime.now().millisecondsSinceEpoch}',
          userName: 'You',
          userAssetPath: AppAssets.avatarDiya,
          message: 'sent a Star ⭐ to Diya',
          type: LiveCommentType.gift,
          timestamp: DateTime.now(),
        ),
      );
    });
  }

  /// Gift Sheet opener
  void _openGiftSheet() {
    GiftBottomSheet.show(
      context,
      (GiftItem gift) {
        _activeGiftKey.currentState?.playGift(gift);
        setState(() {
          _chatMessages.add(
            LiveComment(
              id: 'c_${DateTime.now().millisecondsSinceEpoch}',
              userName: 'You',
              userAssetPath: AppAssets.avatarDiya,
              message: 'sent a ${gift.name} 🎁 to Diya',
              type: LiveCommentType.gift,
              timestamp: DateTime.now(),
            ),
          );
        });
      },
      recipients: ['Diya', 'Arun', 'Sneha', 'Karthik', 'All'],
      initialRecipient: 'Diya',
    );
  }

  /// More options bottom sheet
  void _showMoreOptionsMenu() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        decoration: const BoxDecoration(
          color: Color(0xFF141126),
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.share_rounded, color: Colors.white),
              title: Text('Share Room',
                  style: GoogleFonts.outfit(
                      color: Colors.white, fontWeight: FontWeight.w600)),
              onTap: () {
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Room link copied! 🔗')),
                );
              },
            ),
            ListTile(
              leading: Icon(
                _isVideoRoom ? Icons.mic_rounded : Icons.videocam_rounded,
                color: const Color(0xFFFF2A6D),
              ),
              title: Text(
                _isVideoRoom ? 'Switch to Audio Mode' : 'Switch to Video Mode',
                style: GoogleFonts.outfit(
                    color: Colors.white, fontWeight: FontWeight.w600),
              ),
              onTap: () {
                setState(() => _isVideoRoom = !_isVideoRoom);
                Navigator.pop(ctx);
              },
            ),
            ListTile(
              leading: const Icon(Icons.report_problem_outlined,
                  color: Colors.white70),
              title: Text('Room Rules & Help',
                  style: GoogleFonts.outfit(
                      color: Colors.white70, fontWeight: FontWeight.w500)),
              onTap: () => Navigator.pop(ctx),
            ),
          ],
        ),
      ),
    );
  }


  void _sendMessage() {
    final text = _chatInputController.text.trim();
    if (text.isEmpty) return;

    setState(() {
      _chatMessages.add(
        LiveComment(
          id: 'c_${DateTime.now().millisecondsSinceEpoch}',
          userName: 'You',
          userAssetPath: AppAssets.avatarDiya,
          message: text,
          timestamp: DateTime.now(),
        ),
      );
      _chatInputController.clear();
    });
  }

  // ===========================================================================
  // STEP 4: HOST ENDS ROOM MODAL (Matching Phone 4 in Reference Poster)
  // "End Chat Room? All members will be removed and the room will end."
  // [Cancel] [End Room]
  // ===========================================================================
  Widget _buildStep4HostEndsRoomModal() {
    return Container(
      color: Colors.black.withValues(alpha: 0.70), // Dimmed background
      child: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Container(
            padding: const EdgeInsets.fromLTRB(22, 28, 22, 24),
            decoration: BoxDecoration(
              color: const Color(0xFF141126),
              borderRadius: BorderRadius.circular(28),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.12),
                width: 1.2,
              ),
              boxShadow: const [
                BoxShadow(
                  color: Colors.black87,
                  blurRadius: 30,
                  offset: Offset(0, 10),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Circular Red Glowing Power Icon (⏻) (Phone 4)
                Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: const Color(0xFFD32F2F).withValues(alpha: 0.15),
                    border: Border.all(
                      color: const Color(0xFFFF1744),
                      width: 2,
                    ),
                    boxShadow: const [
                      BoxShadow(
                        color: Color(0x66FF1744),
                        blurRadius: 18,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  child: const Center(
                    child: Icon(
                      Icons.power_settings_new_rounded,
                      color: Color(0xFFFF1744),
                      size: 34,
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // Title: "End Chat Room?" (Phone 4)
                Text(
                  'End Chat Room?',
                  style: GoogleFonts.outfit(
                    color: Colors.white,
                    fontSize: 20.5,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 0.3,
                  ),
                ),
                const SizedBox(height: 8),

                // Subtitle: "All members will be removed and the room will end."
                Text(
                  'All members will be removed\nand the room will end.',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.outfit(
                    color: Colors.white70,
                    fontSize: 13.5,
                    height: 1.4,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 24),

                // Two Action Buttons: [Cancel] & [End Room] (Phone 4)
                Row(
                  children: [
                    // [Cancel] Button (Dark/Grey rounded)
                    Expanded(
                      child: GestureDetector(
                        onTap: () => _setStage(3), // Stay in room
                        child: Container(
                          height: 44,
                          decoration: BoxDecoration(
                            color: const Color(0xFF231F38),
                            borderRadius: BorderRadius.circular(22),
                            border: Border.all(
                              color: Colors.white.withValues(alpha: 0.15),
                            ),
                          ),
                          child: Center(
                            child: Text(
                              'Cancel',
                              style: GoogleFonts.outfit(
                                color: Colors.white,
                                fontSize: 14.5,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),

                    // [End Room] Button (Pink gradient rounded)
                    Expanded(
                      child: GestureDetector(
                        onTap: () {
                          // Transition to Step 5: Room Ended Final Page!
                          _setStage(5);
                        },
                        child: Container(
                          height: 44,
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Color(0xFFFF2A6D), Color(0xFFFF5E8A)],
                            ),
                            borderRadius: BorderRadius.circular(22),
                            boxShadow: const [
                              BoxShadow(
                                color: Color(0x66FF2A6D),
                                blurRadius: 10,
                                offset: Offset(0, 3),
                              ),
                            ],
                          ),
                          child: Center(
                            child: Text(
                              'End Room',
                              style: GoogleFonts.outfit(
                                color: Colors.white,
                                fontSize: 14.5,
                                fontWeight: FontWeight.w900,
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
      ),
    );
  }

  // ===========================================================================
  // STEP 5: ROOM ENDED (FINAL PAGE - SAME FOR EVERYONE)
  // Official TIVOO Home Branding with GoogleFonts.outfit
  // ===========================================================================
  Widget _buildStep5RoomEndedView() {
    final hostName = _selectedRoom['hostName'] as String;
    final isVerified = _selectedRoom['isVerified'] as bool? ?? true;
    final tag = _selectedRoom['tag'] as String;
    final tagline = _selectedRoom['tagline'] as String;
    final avatar = _selectedRoom['avatar'] as String;

    return Padding(
      padding: const EdgeInsets.fromLTRB(18, 8, 18, 14),
      child: Column(
        children: [
          // 1. Official TIVOO Home Page Logo (Replacing Tiki)
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Tiv',
                style: GoogleFonts.outfit(
                  color: Colors.white,
                  fontSize: 28,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 0.5,
                ),
              ),
              Text(
                'oo',
                style: GoogleFonts.outfit(
                  color: const Color(0xFF00E676),
                  fontSize: 28,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(width: 3),
              const Text('🌿', style: TextStyle(fontSize: 18)),
            ],
          ),
          const SizedBox(height: 10),

          // 2. Celebratory 3D "Chat Room Ended" Illustration with Golden Crown & Ribbon (endchat.png)
          AnimatedBuilder(
            animation: _celebrationAnimation,
            builder: (context, child) {
              return Transform.translate(
                offset: Offset(0, _celebrationAnimation.value),
                child: child,
              );
            },
            child: Image.asset(
              AppAssets.endChat,
              height: 145,
              fit: BoxFit.contain,
              errorBuilder: (context, error, stackTrace) => Image.asset(
                'assets/endchat.jpg',
                height: 145,
                fit: BoxFit.contain,
              ),
            ),
          ),
          const SizedBox(height: 6),

          // Subtitle: "Thank you everyone for being part of this room!"
          Text(
            'Thank you everyone\nfor being part of this room!',
            textAlign: TextAlign.center,
            style: GoogleFonts.outfit(
              color: Colors.white70,
              fontSize: 13,
              fontWeight: FontWeight.w500,
              height: 1.35,
            ),
          ),
          const SizedBox(height: 14),

          // 4. Host Info Card: Avatar with pink Host badge, Diya_Official, Dream Team, Tagline, Date/Time
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFF141126),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.10),
              ),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x33000000),
                  blurRadius: 10,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              children: [
                // Host Avatar with "Host" badge
                Stack(
                  alignment: Alignment.bottomCenter,
                  clipBehavior: Clip.none,
                  children: [
                    CustomAvatar(radius: 26, assetPath: avatar),
                    Positioned(
                      bottom: -4,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 6, vertical: 1.5),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFF2A6D),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          'Host',
                          style: GoogleFonts.outfit(
                            color: Colors.white,
                            fontSize: 9,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(width: 14),

                // Host info column
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Flexible(
                            child: Text(
                              hostName,
                              style: GoogleFonts.outfit(
                                color: Colors.white,
                                fontSize: 15.5,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                          ),
                          if (isVerified) ...[
                            const SizedBox(width: 4),
                            const Icon(
                              Icons.check_circle_rounded,
                              color: Color(0xFF29B6F6),
                              size: 14,
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 2),
                      Row(
                        children: [
                          const Text('👑', style: TextStyle(fontSize: 11)),
                          const SizedBox(width: 3),
                          Text(
                            tag,
                            style: GoogleFonts.outfit(
                              color: const Color(0xFFFFD54F),
                              fontSize: 11.5,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 2),
                      Text(
                        tagline,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.outfit(
                          color: Colors.white70,
                          fontSize: 11.5,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Sep 16, 2026 10:45 PM',
                        style: GoogleFonts.outfit(
                          color: Colors.white.withValues(alpha: 0.45),
                          fontSize: 10.5,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),

          // 5. Four Stats Cards in 2x2 Grid (12,560 Total Stars | 2h 35m Duration | 128 Members | 3,620 Views)
          Expanded(
            child: GridView.count(
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 1.32,
              physics: const NeverScrollableScrollPhysics(),
              children: [
                _buildStatMetricCard(
                  iconWidget: const Icon(
                    Icons.star_rounded,
                    color: Color(0xFFFFB300),
                    size: 38,
                  ),
                  value: _totalStarsCount.toString().replaceAllMapped(
                      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
                      (Match m) => '${m[1]},'),
                  label: 'Total Stars',
                  accentColor: const Color(0xFFFFB300),
                ),
                _buildStatMetricCard(
                  iconWidget: const Icon(
                    Icons.access_time_filled_rounded,
                    color: Color(0xFF00E676),
                    size: 36,
                  ),
                  value: '2h 35m',
                  label: 'Total Duration',
                  accentColor: const Color(0xFF00E676),
                ),
                _buildStatMetricCard(
                  iconWidget: const Icon(
                    Icons.groups_rounded,
                    color: Color(0xFFFF2A6D),
                    size: 38,
                  ),
                  value: '128',
                  label: 'Total Members',
                  accentColor: const Color(0xFFFF2A6D),
                ),
                _buildStatMetricCard(
                  iconWidget: const Icon(
                    Icons.remove_red_eye_rounded,
                    color: Color(0xFF00E5FF),
                    size: 38,
                  ),
                  value: '3,620',
                  label: 'Total Views',
                  accentColor: const Color(0xFF00E5FF),
                ),
              ],
            ),
          ),

          // 6. Full-Width Pink Pill Button: "Back to Home"
          Padding(
            padding: const EdgeInsets.only(top: 8, bottom: 4),
            child: GestureDetector(
              onTap: () {
                if (widget.onBack != null) {
                  widget.onBack!();
                } else {
                  _setStage(1); // Return to Chat Room List
                }
              },
              child: Container(
                width: double.infinity,
                height: 50,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFFFF2A6D), Color(0xFFFF5E8A)],
                  ),
                  borderRadius: BorderRadius.circular(25),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x66FF2A6D),
                      blurRadius: 12,
                      offset: Offset(0, 3),
                    ),
                  ],
                ),
                child: Center(
                  child: Text(
                    'Back to Home',
                    style: GoogleFonts.outfit(
                      color: Colors.white,
                      fontSize: 16.5,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 0.3,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatMetricCard({
    required Widget iconWidget,
    required String value,
    required String label,
    required Color accentColor,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFF141126),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: accentColor.withValues(alpha: 0.28),
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: accentColor.withValues(alpha: 0.10),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
          const BoxShadow(
            color: Color(0x33000000),
            blurRadius: 6,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          iconWidget,
          const SizedBox(height: 6),
          Text(
            value,
            style: GoogleFonts.outfit(
              color: Colors.white,
              fontSize: 18.5,
              fontWeight: FontWeight.w900,
              letterSpacing: 0.2,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: GoogleFonts.outfit(
              color: Colors.white60,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

/// Custom vector painter for the 3-point royal crown badge (Reference Image 2)
class _CrownIconPainter extends CustomPainter {
  final Color color;
  const _CrownIconPainter({this.color = const Color(0xFFD84315)});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill
      ..isAntiAlias = true;

    final w = size.width;
    final h = size.height;

    // Base horizontal bar
    final baseRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(w * 0.10, h * 0.78, w * 0.80, h * 0.16),
      const Radius.circular(1.5),
    );
    canvas.drawRRect(baseRect, paint);

    // Crown peaks body
    final path = Path()
      ..moveTo(w * 0.14, h * 0.74)
      ..lineTo(w * 0.86, h * 0.74)
      ..lineTo(w * 0.88, h * 0.35) // right peak top
      ..lineTo(w * 0.65, h * 0.52) // right valley
      ..lineTo(w * 0.50, h * 0.18) // middle peak top
      ..lineTo(w * 0.35, h * 0.52) // left valley
      ..lineTo(w * 0.12, h * 0.35) // left peak top
      ..close();
    canvas.drawPath(path, paint);

    // 3 Jewels/Spheres on peak tips
    final spherePaint = Paint()
      ..color = color
      ..style = PaintingStyle.fill
      ..isAntiAlias = true;

    final ballRadius = w * 0.085;
    canvas.drawCircle(Offset(w * 0.12, h * 0.32), ballRadius, spherePaint);
    canvas.drawCircle(Offset(w * 0.50, h * 0.16), ballRadius * 1.1, spherePaint);
    canvas.drawCircle(Offset(w * 0.88, h * 0.32), ballRadius, spherePaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// Custom painter for glowing botanical foliage in the bottom corners (Reference Image 2)
class _BotanicalLeavesPainter extends CustomPainter {
  final bool isLeft;

  const _BotanicalLeavesPainter({required this.isLeft});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.fill
      ..shader = LinearGradient(
        colors: isLeft
            ? [
                const Color(0xFFFF2A6D).withValues(alpha: 0.65),
                const Color(0xFF9C27B0).withValues(alpha: 0.45),
                const Color(0xFFBA68C8).withValues(alpha: 0.18),
              ]
            : [
                const Color(0xFF9C27B0).withValues(alpha: 0.65),
                const Color(0xFFFF2A6D).withValues(alpha: 0.45),
                const Color(0xFFFF80AB).withValues(alpha: 0.18),
              ],
        begin: Alignment.bottomCenter,
        end: Alignment.topCenter,
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));

    canvas.save();
    if (!isLeft) {
      canvas.translate(size.width, 0);
      canvas.scale(-1, 1);
    }

    // Stem / branch
    final stemPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0
      ..strokeCap = StrokeCap.round
      ..color = const Color(0xFFFF2A6D).withValues(alpha: 0.45);

    final stemPath = Path();
    stemPath.moveTo(0, size.height);
    stemPath.quadraticBezierTo(size.width * 0.4, size.height * 0.6, size.width * 0.85, 10);
    canvas.drawPath(stemPath, stemPaint);

    // Leaves along the branch
    _drawLeaf(canvas, paint, Offset(size.width * 0.22, size.height * 0.74), -0.6, 26, 12);
    _drawLeaf(canvas, paint, Offset(size.width * 0.44, size.height * 0.54), 0.4, 30, 14);
    _drawLeaf(canvas, paint, Offset(size.width * 0.64, size.height * 0.34), -0.5, 28, 13);
    _drawLeaf(canvas, paint, Offset(size.width * 0.84, 14), 0.2, 24, 11);
    _drawLeaf(canvas, paint, Offset(size.width * 0.14, size.height * 0.88), 0.5, 22, 10);

    canvas.restore();
  }

  void _drawLeaf(Canvas canvas, Paint paint, Offset center, double angle, double length, double width) {
    canvas.save();
    canvas.translate(center.dx, center.dy);
    canvas.rotate(angle);

    final leafPath = Path();
    leafPath.moveTo(0, 0);
    leafPath.quadraticBezierTo(width * 1.3, -length * 0.5, 0, -length);
    leafPath.quadraticBezierTo(-width * 1.3, -length * 0.5, 0, 0);
    leafPath.close();

    canvas.drawPath(leafPath, paint);
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// Custom painter for rounded dashed border for the Invite slot (Reference Image 2)
class _DashedBorderPainter extends CustomPainter {
  final Color color;
  final double borderRadius;

  static const double strokeWidth = 1.4;
  static const double dashLength = 6.0;
  static const double dashGap = 4.0;

  const _DashedBorderPainter({
    required this.color,
    this.borderRadius = 18.0,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke;

    final rrect = RRect.fromRectAndRadius(
      Rect.fromLTWH(
        strokeWidth / 2,
        strokeWidth / 2,
        size.width - strokeWidth,
        size.height - strokeWidth,
      ),
      Radius.circular(borderRadius),
    );

    final path = Path()..addRRect(rrect);
    final metrics = path.computeMetrics();

    for (final metric in metrics) {
      double distance = 0.0;
      while (distance < metric.length) {
        final length = math.min(dashLength, metric.length - distance);
        final extractPath = metric.extractPath(distance, distance + length);
        canvas.drawPath(extractPath, paint);
        distance += dashLength + dashGap;
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// Custom painter for the 6 radiating tick marks sunburst around the Invite + icon (Reference Image 2)
class _RadiatingTicksPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final paint = Paint()
      ..strokeWidth = 2.0
      ..strokeCap = StrokeCap.round;

    final colors = [
      const Color(0xFFE040FB),
      const Color(0xFF00E5FF),
      const Color(0xFFE040FB),
      const Color(0xFF7C4DFF),
      const Color(0xFF00E5FF),
      const Color(0xFFE040FB),
    ];

    const count = 6;
    const innerRadius = 20.0;
    const outerRadius = 25.0;

    for (int i = 0; i < count; i++) {
      final angle = (i * (2 * math.pi / count)) - (math.pi / 6);
      paint.color = colors[i % colors.length];
      final p1 = Offset(
        center.dx + innerRadius * math.cos(angle),
        center.dy + innerRadius * math.sin(angle),
      );
      final p2 = Offset(
        center.dx + outerRadius * math.cos(angle),
        center.dy + outerRadius * math.sin(angle),
      );
      canvas.drawLine(p1, p2, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
