import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/services/reel_video_manager.dart';
import '../../../../core/widgets/custom_avatar.dart';
import '../../../../core/widgets/reel_media_view.dart';
import '../../../live_stream/presentation/widgets/floating_hearts_overlay.dart';
import '../../../../core/widgets/tivoo_share_sheet.dart';
import '../../domain/models/explore_stream_model.dart';
import '../../../home/presentation/widgets/streamer_id_profile_sheet.dart';
import '../../../home/domain/models/live_stream_card_model.dart';
import '../../../profile/presentation/controllers/follow_controller.dart';
import '../../../profile/presentation/widgets/instagram_follow_button.dart';
import '../../../profile/presentation/widgets/instagram_follow_actions_sheet.dart';

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
  final bool _isFollowing = false;
  late bool _isLiked;
  late int _likesCount;
  int _userLikesCount = 0;
  DateTime? _lastLikeTap;
  late final AnimationController _likeAnimController;
  late final Animation<double> _likeScaleAnimation;

  static int _parseInitialLikes(String countStr) {
    try {
      final clean = countStr.trim().toUpperCase();
      if (clean.endsWith('K')) {
        final numPart = double.parse(clean.replaceAll('K', ''));
        return (numPart * 1000).toInt();
      } else if (clean.endsWith('M')) {
        final numPart = double.parse(clean.replaceAll('M', ''));
        return (numPart * 1000000).toInt();
      }
      return int.tryParse(clean.replaceAll(',', '')) ?? 10500;
    } catch (_) {
      return 10500;
    }
  }

  String _formatLikes(int count) {
    if (count >= 1000000) {
      return '${(count / 1000000).toStringAsFixed(1)}M';
    } else if (count >= 10000) {
      return '${(count / 1000).toStringAsFixed(1)}K';
    } else if (count >= 1000) {
      return '${(count / 1000).toStringAsFixed(1)}K';
    }
    return count.toString();
  }

  @override
  void initState() {
    super.initState();
    _isLiked = widget.stream.isLiked;
    _likesCount = _parseInitialLikes(widget.stream.diamondsCount);
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

  void _triggerLikeAction() {
    if (_userLikesCount >= 50) {
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Limit reached: 50 likes maximum per post! ❤️'),
          backgroundColor: Color(0xFF192233),
          behavior: SnackBarBehavior.floating,
          duration: Duration(seconds: 1),
        ),
      );
      return;
    }

    final now = DateTime.now();
    final isRapid = _lastLikeTap != null && now.difference(_lastLikeTap!).inMilliseconds < 400;
    _lastLikeTap = now;
    final burstCount = isRapid ? 3 : 1;

    setState(() {
      _userLikesCount++;
      _likesCount++;
      _isLiked = true;
    });

    _likeAnimController.forward(from: 0.0);
    _heartsKey.currentState?.addPinkHearts(count: burstCount);
    widget.onLikeTap?.call();
  }

  void _handleDoubleTap() {
    _triggerLikeAction();
  }

  void _handleLikeTap() {
    _triggerLikeAction();
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
                      label: _formatLikes(_likesCount),
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
                              content: Text('Join conversation on ${stream.streamerName}\'s video! 💬'),
                              duration: const Duration(seconds: 1),
                            ),
                          );
                        }
                      },
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
                          final shareUrl = 'https://tivoo.app/video/${stream.id}';
                          final shareText = 'Watch ${stream.streamerName}\'s video on Tivoo! $shareUrl';
                          TivooShareSheet.show(
                            context,
                            title: 'Share Video',
                            subtitle: '${stream.streamerName} • ${stream.category}',
                            shareUrl: shareUrl,
                            shareText: shareText,
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

                        // Prominent Instagram Follow Button on Explore Reel
                        InstagramFollowButton(
                          userId: stream.id,
                          userName: stream.streamerName,
                          userAvatar: stream.avatarAssetPath ?? stream.avatarUrl ?? '',
                          initialFollowers: 120400,
                          initialFollowing: _isFollowing,
                          height: 30,
                          fontSize: 11.5,
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
    final followMap = ref.watch(followControllerProvider);
    final rel = followMap[widget.stream.id] ??
        ref.read(followControllerProvider.notifier).getRelationship(
              widget.stream.id,
              defaultName: widget.stream.streamerName,
              defaultAvatar: widget.stream.avatarAssetPath ?? widget.stream.avatarUrl ?? '',
              initialFollowers: 120400,
              initialFollowing: _isFollowing,
            );
    final isFollowing = rel.isFollowingOrMutual;
    final isRequested = rel.isRequested;

    return Stack(
      alignment: Alignment.bottomCenter,
      clipBehavior: Clip.none,
      children: [
        GestureDetector(
          onTap: () {
            StreamerIdProfileSheet.show(
              context,
              stream: LiveStreamCardModel(
                id: widget.stream.id,
                userId: '109284',
                streamerName: widget.stream.streamerName,
                streamerBio: widget.stream.subCategory,
                streamerAssetPath: widget.stream.avatarAssetPath,
                streamerAvatarUrl: widget.stream.avatarUrl,
                viewersCount: widget.stream.viewersCount,
                diamondsCount: widget.stream.diamondsCount,
                isFollowing: isFollowing,
                isVerified: widget.stream.isVerified,
              ),
            );
          },
          child: Container(
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
        ),
        Positioned(
          bottom: -5,
          child: GestureDetector(
            onTap: () {
              if (rel.isNotFollowing) {
                ref.read(followControllerProvider.notifier).sendFollowRequest(
                      widget.stream.id,
                      targetName: widget.stream.streamerName,
                      targetAvatar: widget.stream.avatarAssetPath ?? widget.stream.avatarUrl ?? '',
                      onStatusNotify: (msg) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(msg),
                            backgroundColor: const Color(0xFF192233),
                            behavior: SnackBarBehavior.floating,
                            duration: const Duration(seconds: 2),
                          ),
                        );
                      },
                    );
              } else if (rel.isRequested) {
                InstagramFollowActionsSheet.showRequestedSheet(
                  context,
                  relationship: rel,
                  streamerId: widget.stream.id,
                  onCancelRequest: () {
                    ref.read(followControllerProvider.notifier).cancelFollowRequest(widget.stream.id);
                  },
                );
              } else {
                InstagramFollowActionsSheet.show(
                  context,
                  relationship: rel,
                  streamerId: widget.stream.id,
                );
              }
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.all(2),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: isFollowing
                    ? const LinearGradient(colors: [Color(0xFF4CAF50), Color(0xFF2E7D32)])
                    : isRequested
                        ? const LinearGradient(colors: [Color(0xFF1E2840), Color(0xFF2B3A5A)])
                        : AppColors.getStartedButtonGradient,
                boxShadow: const [BoxShadow(color: Colors.black45, blurRadius: 4)],
              ),
              child: Icon(
                isFollowing
                    ? Icons.check
                    : isRequested
                        ? Icons.schedule
                        : Icons.add,
                color: Colors.white,
                size: 12,
              ),
            ),
          ),
        ),
      ],
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
