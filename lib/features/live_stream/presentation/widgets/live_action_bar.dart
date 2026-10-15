import 'package:flutter/material.dart';
import '../../../../core/constants/app_assets.dart';
import '../../../../core/widgets/custom_avatar.dart';

/// Right Vertical Action Bar styled consistently with Explore Screen (Image 2):
/// - Host avatar with golden border & follow '+' badge
/// - Like button with spring scale & yellow glowing accent
/// - Chat / Comment button in tactile glassmorphic style
/// - Stars button using 'goldenstar.png' opening the Gift page
/// - Share button in tactile glassmorphic style
class LiveActionBar extends StatelessWidget {
  final String? streamerAvatarAsset;
  final String? streamerAvatarUrl;
  final bool isFollowing;
  final bool isLiked;
  final String likesCount;
  final String commentsCount;
  final String? starsCount;
  final VoidCallback onFollowTap;
  final VoidCallback onLikeTap;
  final VoidCallback? onCommentTap;
  final VoidCallback onShareTap;
  final VoidCallback? onStarTap;
  final VoidCallback? onGiftTap;
  final VoidCallback? onAvatarTap;

  const LiveActionBar({
    super.key,
    this.streamerAvatarAsset,
    this.streamerAvatarUrl,
    required this.isFollowing,
    required this.isLiked,
    required this.likesCount,
    required this.commentsCount,
    this.starsCount,
    required this.onFollowTap,
    required this.onLikeTap,
    this.onCommentTap,
    required this.onShareTap,
    this.onStarTap,
    this.onGiftTap,
    this.onAvatarTap,
  });

  @override
  Widget build(BuildContext context) {
    final isCompact = MediaQuery.sizeOf(context).width < 360;
    final buttonSize = isCompact ? 40.0 : 44.0;
    final spacing = isCompact ? 12.0 : 15.0;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // 1. Host Avatar with '+' follow badge
        _buildHostAvatarWithFollowBadge(buttonSize),

        SizedBox(height: spacing + 2),

        // 2. Like Button (Yellow glowing theme with like state)
        _LiveActionButton(
          size: buttonSize,
          icon: isLiked ? Icons.favorite_rounded : Icons.favorite_border_rounded,
          iconColor: isLiked ? const Color(0xFFFF2D55) : const Color(0xFFFFD700),
          label: likesCount.isEmpty ? '12.5K' : likesCount,
          borderColor: isLiked ? const Color(0xFFFF2D55) : const Color(0x99FFD700),
          glowColor: isLiked ? const Color(0x66FF2D55) : const Color(0x55FFD700),
          onTap: onLikeTap,
        ),

        SizedBox(height: spacing),

        // 3. Comment / Chat Button
        _LiveActionButton(
          size: buttonSize,
          icon: Icons.chat_bubble_outline_rounded,
          iconColor: const Color(0xFFFFD700),
          borderColor: const Color(0x99FFD700),
          glowColor: const Color(0x55FFD700),
          label: 'Chat',
          onTap: () {
            if (onCommentTap != null) {
              onCommentTap!();
            }
          },
        ),

        SizedBox(height: spacing),

        // 4. Stars Button with 'glossy_star.png' opening the Gift page
        _LiveActionButton(
          size: buttonSize,
          icon: Icons.star_rounded,
          iconColor: const Color(0xFFFFD700),
          borderColor: const Color(0x99FFD700),
          glowColor: const Color(0x55FFD700),
          label: 'Stars',
          customIcon: SizedBox(
            width: isCompact ? 24 : 27,
            height: isCompact ? 24 : 27,
            child: Image.asset(
              AppAssets.glossyStar,
              fit: BoxFit.contain,
              errorBuilder: (context, error, stackTrace) => const Icon(
                Icons.star_rounded,
                color: Color(0xFFFFD700),
                size: 24,
              ),
            ),
          ),
          onTap: () {
            if (onGiftTap != null) {
              onGiftTap!();
            } else if (onStarTap != null) {
              onStarTap!();
            }
          },
        ),

        SizedBox(height: spacing),

        // 5. Share Button with yellow glowing theme
        _LiveActionButton(
          size: buttonSize,
          icon: Icons.share_rounded,
          iconColor: const Color(0xFFFFD700),
          borderColor: const Color(0x99FFD700),
          glowColor: const Color(0x55FFD700),
          label: 'Share',
          onTap: onShareTap,
        ),
      ],
    );
  }

  Widget _buildHostAvatarWithFollowBadge(double size) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        GestureDetector(
          onTap: onAvatarTap,
          child: Container(
            width: size + 6,
            height: size + 6,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: const Color(0xFFFFD700), width: 1.5),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x44FFD700),
                  blurRadius: 8,
                ),
              ],
            ),
            child: ClipOval(
              child: CustomAvatar(
                radius: (size + 6) / 2,
                assetPath: (streamerAvatarAsset != null && streamerAvatarAsset!.isNotEmpty)
                    ? streamerAvatarAsset
                    : null,
                imageUrl: streamerAvatarUrl,
              ),
            ),
          ),
        ),

        // Follow '+' badge
        if (!isFollowing)
          Positioned(
            bottom: -5,
            left: 0,
            right: 0,
            child: Center(
              child: GestureDetector(
                onTap: onFollowTap,
                child: Container(
                  width: 20,
                  height: 20,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: const LinearGradient(
                      colors: [Color(0xFFFFD700), Color(0xFFFF9100)],
                    ),
                    border: Border.all(color: Colors.white, width: 1.5),
                    boxShadow: const [
                      BoxShadow(
                        color: Color(0x66FFD700),
                        blurRadius: 4,
                      ),
                    ],
                  ),
                  child: const Center(
                    child: Icon(
                      Icons.add,
                      size: 13,
                      color: Colors.black,
                    ),
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}

/// Tactile, responsive action button with spring-press animation and frosted glass styling matching Explore screen.
class _LiveActionButton extends StatefulWidget {
  final double size;
  final IconData icon;
  final Color iconColor;
  final String label;
  final VoidCallback onTap;
  final Widget? customIcon;
  final Color? borderColor;
  final Color? glowColor;

  const _LiveActionButton({
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
  State<_LiveActionButton> createState() => _LiveActionButtonState();
}

class _LiveActionButtonState extends State<_LiveActionButton> {
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
                  color: widget.borderColor ?? const Color(0x99FFD700),
                  width: 1.0,
                ),
                boxShadow: [
                  BoxShadow(
                    color: widget.glowColor ?? const Color(0x55FFD700),
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
