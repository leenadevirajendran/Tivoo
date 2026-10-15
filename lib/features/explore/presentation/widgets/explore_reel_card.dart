import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_assets.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/services/reel_video_manager.dart';
import '../../../../core/widgets/custom_avatar.dart';
import '../../../../core/widgets/glass_container.dart';
import '../../../../core/widgets/reel_media_view.dart';
import '../../../gift/gift_options.dart';
import '../../../gift/gift_sheet_screen.dart';
import '../../../live_stream/presentation/widgets/floating_hearts_overlay.dart';
import '../../../live_stream/presentation/widgets/floating_stars_overlay.dart';
import '../../domain/models/explore_stream_model.dart';

class ExploreReelCard extends ConsumerStatefulWidget {
  final ExploreStreamModel stream;
  final bool isActive;
  final VoidCallback? onEnterLiveRoom;
  final VoidCallback? onLikeTap;
  final VoidCallback? onFollowTap;
  final VoidCallback? onShareTap;
  final VoidCallback? onCommentTap;

  const ExploreReelCard({
    super.key,
    required this.stream,
    this.isActive = true,
    this.onEnterLiveRoom,
    this.onLikeTap,
    this.onFollowTap,
    this.onShareTap,
    this.onCommentTap,
  });

  @override
  ConsumerState<ExploreReelCard> createState() => _ExploreReelCardState();
}

class _ExploreReelCardState extends ConsumerState<ExploreReelCard>
    with SingleTickerProviderStateMixin {
  final GlobalKey<FloatingHeartsOverlayState> _heartsKey = GlobalKey();
  final GlobalKey<FloatingStarsOverlayState> _starsKey = GlobalKey();
  bool _isFollowing = false;
  late bool _isLiked;
  late final AnimationController _likeAnimController;
  late final Animation<double> _likeScaleAnimation;

  @override
  void initState() {
    super.initState();
    _isLiked = widget.stream.isLiked;
    _likeAnimController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 260),
    );
    _likeScaleAnimation = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 1.35), weight: 50),
      TweenSequenceItem(tween: Tween(begin: 1.35, end: 1.0), weight: 50),
    ]).animate(CurvedAnimation(parent: _likeAnimController, curve: Curves.easeInOut));
  }

  @override
  void didUpdateWidget(covariant ExploreReelCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.stream.isLiked != widget.stream.isLiked) {
      _isLiked = widget.stream.isLiked;
    }
  }

  @override
  void dispose() {
    _likeAnimController.dispose();
    super.dispose();
  }

  void _handleDoubleTap() {
    if (!_isLiked) {
      setState(() => _isLiked = true);
      widget.onLikeTap?.call();
    }
    _likeAnimController.forward(from: 0.0);
    _heartsKey.currentState?.addHeart();
    _heartsKey.currentState?.addHeart();
  }

  void _handleLikeTap() {
    setState(() => _isLiked = !_isLiked);
    if (_isLiked) {
      _likeAnimController.forward(from: 0.0);
      _heartsKey.currentState?.addHeart();
    }
    widget.onLikeTap?.call();
  }

  /// Opens the full Gifts Sheet matching Chat Room and PK Battle screens,
  /// allowing users to send gifts to the streamer, host, or other users.
  void _handleGiftTap() {
    GiftBottomSheet.show(
      context,
      (gift) => _onGiftSent(gift, 1, widget.stream.streamerName),
      recipients: [widget.stream.streamerName, 'Host', 'All'],
      initialRecipient: widget.stream.streamerName,
      onGiftWithQuantitySelected: (gift, qty) => _onGiftSent(gift, qty, widget.stream.streamerName),
      onGiftWithRecipientSelected: (gift, qty, recipient) => _onGiftSent(gift, qty, recipient),
    );
  }

  void _onGiftSent(GiftItem gift, int quantity, String recipient) {
    _starsKey.currentState?.addStars(gift.diamonds * quantity * 2);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: const Color(0xFF1F1836),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: Color(0xFFFFD700), width: 1.2),
        ),
        content: Row(
          children: [
            Text(gift.icon, style: const TextStyle(fontSize: 22)),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                'Sent ${quantity > 1 ? "$quantity " : ""}${gift.name} to $recipient! 🎉',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _toggleFollow() {
    setState(() => _isFollowing = !_isFollowing);
    widget.onFollowTap?.call();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          _isFollowing
              ? 'Followed ${widget.stream.streamerName} ❤️'
              : 'Unfollowed ${widget.stream.streamerName}',
        ),
        duration: const Duration(seconds: 1),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final stream = widget.stream;
    final hasVideo = stream.videoAssetPath != null && stream.videoAssetPath!.isNotEmpty;
    final screenHeight = MediaQuery.of(context).size.height;
    final isCompact = screenHeight < 720;

    final actionSpacing = isCompact ? 11.0 : 15.0;
    final buttonSize = isCompact ? 40.0 : 44.0;
    final iconSize = isCompact ? 20.0 : 22.0;

    return FloatingHeartsOverlay(
      key: _heartsKey,
      child: FloatingStarsOverlay(
        key: _starsKey,
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onDoubleTap: _handleDoubleTap,
          child: Stack(
            fit: StackFit.expand,
            children: [
              // 1. Full Reel Media (Video Player or Cover Image)
              Positioned.fill(child: _buildMediaBackground()),

              // 2. Cinematic Gradient Scrims for Readability
              Positioned.fill(
                child: Container(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Color(0x99000000),
                        Colors.transparent,
                        Colors.transparent,
                        Color(0xCC000000),
                      ],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      stops: [0.0, 0.20, 0.58, 1.0],
                    ),
                  ),
                ),
              ),

              // 3. Ambient Neon Accent Glow in bottom corner
              Positioned(
                left: -30,
                bottom: 40,
                width: 220,
                height: 220,
                child: IgnorePointer(
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: RadialGradient(
                        colors: [
                          AppColors.glowPurple.withValues(alpha: 0.22),
                          AppColors.glowPurple.withValues(alpha: 0.0),
                        ],
                      ),
                    ),
                  ),
                ),
              ),

              // 4. Top Reel Viewer Counter Pill (Beneath header, NO LIVE badge)
              Positioned(
                top: 104,
                left: 16,
                right: 16,
                child: Row(
                  children: [
                    // Viewers counter pill
                    GlassContainer(
                      enableBlur: false,
                      blur: 0,
                      opacity: 0.45,
                      borderRadius: BorderRadius.circular(16),
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3.5),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.remove_red_eye_outlined, color: Colors.white, size: 12),
                          const SizedBox(width: 4),
                          Text(
                            stream.viewersCount,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const Spacer(),

                    // Video indicator badge if this reel has video playback
                    if (hasVideo)
                      GlassContainer(
                        enableBlur: false,
                        blur: 0,
                        opacity: 0.55,
                        borderRadius: BorderRadius.circular(16),
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3.5),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 6,
                              height: 6,
                              decoration: const BoxDecoration(
                                shape: BoxShape.circle,
                                color: AppColors.primaryPink,
                              ),
                            ),
                            const SizedBox(width: 4),
                            const Text(
                              'REEL',
                              style: TextStyle(
                                color: AppColors.primaryPink,
                                fontSize: 10.5,
                                fontWeight: FontWeight.w800,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),

              // 5. Right-side Interactive Action Column with Tactile Glassmorphic Buttons
              Positioned(
                right: 12,
                bottom: isCompact ? 86 : 96,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Streamer Avatar with Follow "+" Badge
                    _buildStreamerAvatarAction(),
                    SizedBox(height: actionSpacing + 2),

                    // Like Button with heart animation
                    _ReelActionButton(
                      size: buttonSize,
                      icon: _isLiked ? Icons.favorite : Icons.favorite_border_rounded,
                      iconColor: _isLiked ? const Color(0xFFFF2D55) : const Color(0xFFFFD700),
                      label: stream.diamondsCount,
                      borderColor: _isLiked ? const Color(0xFFFF2D55) : const Color(0x99FFD700),
                      glowColor: _isLiked ? const Color(0x66FF2D55) : const Color(0x55FFD700),
                      onTap: _handleLikeTap,
                      customIcon: ScaleTransition(
                        scale: _likeScaleAnimation,
                        child: Icon(
                          _isLiked ? Icons.favorite : Icons.favorite_border_rounded,
                          color: _isLiked ? const Color(0xFFFF2D55) : const Color(0xFFFFD700),
                          size: iconSize + 2,
                        ),
                      ),
                    ),
                    SizedBox(height: actionSpacing),

                    // Comment / Chat Button
                    _ReelActionButton(
                      size: buttonSize,
                      icon: Icons.chat_bubble_outline_rounded,
                      iconColor: const Color(0xFFFFD700),
                      borderColor: const Color(0x99FFD700),
                      glowColor: const Color(0x55FFD700),
                      label: 'Chat',
                      onTap: () {
                        if (widget.onCommentTap != null) {
                          widget.onCommentTap!();
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Join conversation on ${stream.streamerName}\'s reel! 💬'),
                              duration: const Duration(seconds: 1),
                            ),
                          );
                        }
                      },
                    ),
                    SizedBox(height: actionSpacing),

                    // Gift Button (Using gstar.png and launching Gift Store)
                    _ReelActionButton(
                      size: buttonSize,
                      icon: Icons.star_rounded,
                      iconColor: const Color(0xFFFFD700),
                      label: 'Stars',
                      borderColor: const Color(0x99FFD700),
                      glowColor: const Color(0x55FFD700),
                      onTap: _handleGiftTap,
                      customIcon: SizedBox(
                        width: isCompact ? 24 : 27,
                        height: isCompact ? 24 : 27,
                        child: Image.asset(
                          AppAssets.glossyStar,
                          fit: BoxFit.contain,
                          errorBuilder: (context, error, stackTrace) => const Icon(
                            Icons.card_giftcard_rounded,
                            color: Color(0xFFFFD700),
                            size: 22,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: actionSpacing),

                    // Share Button
                    _ReelActionButton(
                      size: buttonSize,
                      icon: Icons.share_rounded,
                      iconColor: const Color(0xFFFFD700),
                      borderColor: const Color(0x99FFD700),
                      glowColor: const Color(0x55FFD700),
                      label: 'Share',
                      onTap: () {
                        if (widget.onShareTap != null) {
                          widget.onShareTap!();
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Shared ${stream.streamerName}\'s reel!'),
                              duration: const Duration(seconds: 1),
                            ),
                          );
                        }
                      },
                    ),
                    SizedBox(height: actionSpacing),

                    // Sound Mute Toggle (if video is active)
                    if (hasVideo)
                      ValueListenableBuilder<bool>(
                        valueListenable: ReelVideoManager.instance.isMutedNotifier,
                        builder: (context, isMuted, _) {
                          return _ReelActionButton(
                            size: buttonSize,
                            icon: isMuted ? Icons.volume_off_rounded : Icons.volume_up_rounded,
                            iconColor: const Color(0xFFFFD700),
                            borderColor: const Color(0x99FFD700),
                            glowColor: const Color(0x55FFD700),
                            label: isMuted ? 'Muted' : 'Sound',
                            onTap: () {
                              ReelVideoManager.instance.toggleMute();
                            },
                          );
                        },
                      ),
                  ],
                ),
              ),

              // 6. Bottom Creator Details with Prominent Follow Button (Left Aligned)
              Positioned(
                left: 16,
                right: 80,
                bottom: isCompact ? 86 : 96,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Creator Name + Verified Icon + Prominent Follow Button
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            stream.streamerName,
                            style: AppTextStyles.streamerName.copyWith(
                              fontSize: isCompact ? 15 : 16.5,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                              shadows: const [Shadow(color: Colors.black54, blurRadius: 6)],
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (stream.isVerified) ...[
                          const SizedBox(width: 5),
                          const Icon(Icons.verified, color: AppColors.primaryYellow, size: 16),
                        ],
                        const SizedBox(width: 10),

                        // Prominent Follow Button on Explore Reel
                        GestureDetector(
                          onTap: _toggleFollow,
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 5),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(16),
                              gradient: _isFollowing
                                  ? const LinearGradient(
                                      colors: [Color(0x55FFFFFF), Color(0x33FFFFFF)],
                                    )
                                  : AppColors.followButtonGradient,
                              boxShadow: _isFollowing
                                  ? null
                                  : [
                                      BoxShadow(
                                        color: AppColors.primaryYellow.withValues(alpha: 0.35),
                                        blurRadius: 8,
                                        offset: const Offset(0, 2),
                                      ),
                                    ],
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                if (!_isFollowing) ...[
                                  const Icon(Icons.add, color: Colors.black, size: 13),
                                  const SizedBox(width: 3),
                                ],
                                Text(
                                  _isFollowing ? 'Following' : 'Follow',
                                  style: TextStyle(
                                    fontSize: 11.5,
                                    fontWeight: FontWeight.w800,
                                    color: _isFollowing ? Colors.white : Colors.black,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 5),

                    // Subcategory / Caption Description
                    Text(
                      stream.subCategory,
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 13,
                        fontWeight: FontWeight.w400,
                        shadows: [Shadow(color: Colors.black54, blurRadius: 4)],
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMediaBackground() {
    return ReelMediaView(
      videoAssetPath: widget.stream.videoAssetPath,
      coverAssetPath: widget.stream.coverAssetPath,
      coverImageUrl: widget.stream.coverImageUrl,
      isActive: widget.isActive,
    );
  }

  Widget _buildStreamerAvatarAction() {
    return GestureDetector(
      onTap: _toggleFollow,
      child: Stack(
        alignment: Alignment.bottomCenter,
        clipBehavior: Clip.none,
        children: [
          Container(
            padding: const EdgeInsets.all(2),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.primaryYellow, width: 1.5),
            ),
            child: CustomAvatar(
              radius: 21,
              assetPath: widget.stream.avatarAssetPath,
              imageUrl: widget.stream.avatarUrl,
            ),
          ),
          Positioned(
            bottom: -5,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.all(2),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: _isFollowing
                    ? const LinearGradient(colors: [Color(0xFF4CAF50), Color(0xFF2E7D32)])
                    : AppColors.getStartedButtonGradient,
                boxShadow: const [BoxShadow(color: Colors.black45, blurRadius: 4)],
              ),
              child: Icon(_isFollowing ? Icons.check : Icons.add, color: Colors.white, size: 12),
            ),
          ),
        ],
      ),
    );
  }
}

/// Tactile, responsive action button with spring-press animation and frosted glass styling.
class _ReelActionButton extends StatefulWidget {
  final double size;
  final IconData icon;
  final Color iconColor;
  final String label;
  final VoidCallback onTap;
  final Widget? customIcon;
  final Color? borderColor;
  final Color? glowColor;

  const _ReelActionButton({
    required this.size,
    required this.icon,
    required this.iconColor,
    required this.label,
    required this.onTap,
    this.customIcon,
    this.borderColor,
    this.glowColor,
  });

  @override
  State<_ReelActionButton> createState() => _ReelActionButtonState();
}

class _ReelActionButtonState extends State<_ReelActionButton> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) => setState(() => _isPressed = false),
      onTapCancel: () => setState(() => _isPressed = false),
      onTap: widget.onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          AnimatedScale(
            scale: _isPressed ? 0.92 : 1.0,
            duration: const Duration(milliseconds: 100),
            curve: Curves.easeInOut,
            child: Container(
              width: widget.size,
              height: widget.size,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.black.withValues(alpha: 0.45),
                border: Border.all(
                  color: widget.borderColor ?? Colors.white.withValues(alpha: 0.18),
                  width: 1.0,
                ),
                boxShadow: [
                  BoxShadow(
                    color: widget.glowColor ?? Colors.black.withValues(alpha: 0.35),
                    blurRadius: 10,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Center(
                child: widget.customIcon ??
                    Icon(
                      widget.icon,
                      color: widget.iconColor,
                      size: widget.size * 0.52,
                    ),
              ),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            widget.label,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 11,
              fontWeight: FontWeight.w600,
              shadows: [Shadow(color: Colors.black87, blurRadius: 4)],
            ),
          ),
        ],
      ),
    );
  }
}
