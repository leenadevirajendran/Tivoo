import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';

class FloatingBottomNavBar extends StatelessWidget {
  final int currentIndex;
  final Function(int index) onTap;
  final VoidCallback onGoLiveTap;

  const FloatingBottomNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
    required this.onGoLiveTap,
  });

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: Container(
        margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        height: 72,
        decoration: BoxDecoration(
          color: const Color(0xF2101018),
          borderRadius: BorderRadius.circular(36),
          border: Border.all(
            color: Colors.white.withValues(alpha: 0.14),
            width: 0.8,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.6),
              blurRadius: 24,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(36),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Home Tab (0)
                _buildNavItem(
                  index: 0,
                  icon: Icons.home_filled,
                  label: AppStrings.navHome,
                ),

                // Explore Tab (1)
                _buildNavItem(
                  index: 1,
                  icon: Icons.search_rounded,
                  label: AppStrings.navExplore,
                ),

                // Center Live Broadcast Button
                _buildCenterLiveButton(),

                // Activity Tab (2)
                _buildNavItem(
                  index: 2,
                  icon: Icons.favorite_border_rounded,
                  label: AppStrings.navActivity,
                ),

                // Profile Tab (3)
                _buildNavItem(
                  index: 3,
                  icon: Icons.person_outline_rounded,
                  label: AppStrings.navProfile,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem({
    required int index,
    required IconData icon,
    required String label,
  }) {
    final isSelected = currentIndex == index;
    final color = isSelected ? AppColors.primaryPink : AppColors.textSecondary;

    return Expanded(
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: () => onTap(index),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                color: color,
                size: 24,
                shadows: isSelected
                    ? [
                        Shadow(
                          color: AppColors.primaryPink.withValues(alpha: 0.8),
                          blurRadius: 12,
                        ),
                      ]
                    : null,
              ),
              const SizedBox(height: 3),
              Text(
                label,
                style: AppTextStyles.navLabel.copyWith(
                  color: color,
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                ),
              ),
              const SizedBox(height: 2),
              AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                width: isSelected ? 16 : 0,
                height: 3,
                decoration: BoxDecoration(
                  color: AppColors.primaryPink,
                  borderRadius: BorderRadius.circular(2),
                  boxShadow: isSelected
                      ? [
                          BoxShadow(
                            color: AppColors.primaryPink.withValues(alpha: 0.7),
                            blurRadius: 6,
                          ),
                        ]
                      : null,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCenterLiveButton() {
    return GestureDetector(
      onTap: onGoLiveTap,
      child:
          Container(
                width: 52,
                height: 52,
                margin: const EdgeInsets.symmetric(horizontal: 6),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: AppColors.liveCenterButtonGradient,
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primaryYellow.withValues(alpha: 0.5),
                      blurRadius: 16,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: const Center(
                  child: Icon(
                    Icons.add_rounded,
                    color: AppColors.textOnPrimary,
                    size: 32,
                  ),
                ),
              )
              .animate(onPlay: (c) => c.repeat(reverse: true))
              .scale(
                begin: const Offset(1, 1),
                end: const Offset(1.08, 1.08),
                duration: 1200.ms,
                curve: Curves.easeInOut,
              ),
    );
  }
}
