import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/glow_icon_button.dart';
import '../../../../core/theme/luxe_theme.dart';
import '../../../live_stream/presentation/controllers/star_wallet_controller.dart';
import '../../../wallet/presentation/screens/wallet_screen.dart';

/// Top Header for Explore Screen matching the modern dark glassmorphic design system.
/// Features a responsive title, unified circular action buttons (Back, Wallet, ViewMode, Search, Filter),
/// and auto-scaling layout that never clips on small screens.
class ExploreHeader extends ConsumerWidget {
  final VoidCallback? onSearchTap;
  final VoidCallback? onFilterTap;
  final VoidCallback? onViewModeToggle;
  final VoidCallback? onWalletTap;

  /// Top-left back arrow (hidden when null).
  final VoidCallback? onBackTap;
  final bool isReelsView;

  const ExploreHeader({
    super.key,
    this.onSearchTap,
    this.onFilterTap,
    this.onViewModeToggle,
    this.onWalletTap,
    this.onBackTap,
    this.isReelsView = true,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final wallet = ref.watch(starWalletProvider);
    final screenWidth = MediaQuery.of(context).size.width;
    final isCompact = screenWidth < 360;

    final buttonSize = isCompact ? 36.0 : 38.0;
    final buttonGap = isCompact ? 5.0 : 6.0;

    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: isCompact ? 10 : 14,
        vertical: 6,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // 1. Back button
          if (onBackTap != null) ...[
            LuxeCircleButton(
              icon: Icons.arrow_back_ios_new_rounded,
              label: 'Back to Home',
              size: buttonSize,
              onTap: onBackTap,
            ),
            SizedBox(width: buttonGap + 2),
          ],

          // 2. Title & Subtitle (Auto-scaled so it never truncates to "Expl...")
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Explore',
                    style: AppTextStyles.heroHeading.copyWith(
                      fontSize: isCompact ? 20 : 23,
                      fontWeight: FontWeight.w800,
                      color: isDark ? Colors.white : const Color(0xFF161622),
                      letterSpacing: -0.5,
                    ),
                  ),
                ),
                const SizedBox(height: 1),
                Text(
                  isReelsView ? 'Swipe to discover reels' : 'Discover amazing reels',
                  style: AppTextStyles.heroSubtitle.copyWith(
                    fontSize: isCompact ? 10.5 : 11.5,
                    color: isDark ? AppColors.textSecondary : const Color(0xFF6B6B78),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          SizedBox(width: buttonGap),

          // 3. Action Buttons Row: Wallet, ViewMode, Search, Filter
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Wallet Icon Button (matching other circular glass buttons)
              Tooltip(
                message: 'Wallet (${wallet.userId})',
                child: GlowIconButton(
                  icon: Icons.account_balance_wallet_rounded,
                  size: buttonSize,
                  iconSize: isCompact ? 17 : 19,
                  iconColor: const Color(0xFFFFD700),
                  glow: true,
                  glowColor: const Color(0x55FFD700),
                  backgroundColor: isDark
                      ? Colors.black.withValues(alpha: 0.45)
                      : Colors.white.withValues(alpha: 0.85),
                  onTap: () {
                    if (onWalletTap != null) {
                      onWalletTap!();
                    } else {
                      WalletScreen.push(context);
                    }
                  },
                ),
              ),
              SizedBox(width: buttonGap),

              // View Mode Toggle (Reels / Grid)
              if (onViewModeToggle != null) ...[
                GlowIconButton(
                  icon: isReelsView ? Icons.grid_view_rounded : Icons.slideshow_rounded,
                  size: buttonSize,
                  iconSize: isCompact ? 17 : 19,
                  iconColor: isReelsView ? AppColors.primaryYellow : AppColors.primaryPink,
                  glow: true,
                  glowColor: isReelsView
                      ? AppColors.primaryYellow.withValues(alpha: 0.3)
                      : AppColors.glowPink.withValues(alpha: 0.3),
                  backgroundColor: isDark
                      ? Colors.black.withValues(alpha: 0.45)
                      : Colors.white.withValues(alpha: 0.85),
                  onTap: onViewModeToggle,
                ),
                SizedBox(width: buttonGap),
              ],

              // Search Button
              GlowIconButton(
                icon: Icons.search_rounded,
                size: buttonSize,
                iconSize: isCompact ? 17 : 19,
                backgroundColor: isDark
                    ? Colors.black.withValues(alpha: 0.45)
                    : Colors.white.withValues(alpha: 0.85),
                onTap: onSearchTap,
              ),

              // Filter Button
              if (onFilterTap != null) ...[
                SizedBox(width: buttonGap),
                GlowIconButton(
                  icon: Icons.tune_rounded,
                  size: buttonSize,
                  iconSize: isCompact ? 17 : 19,
                  backgroundColor: isDark
                      ? Colors.black.withValues(alpha: 0.45)
                      : Colors.white.withValues(alpha: 0.85),
                  onTap: onFilterTap,
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}
