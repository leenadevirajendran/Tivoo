import 'package:flutter/material.dart';

class HomeHeader extends StatelessWidget {
  final VoidCallback? onSearchTap;
  final VoidCallback? onFavoritesTap;
  final VoidCallback? onHistoryTap;
  final int selectedIndex;
  final ValueChanged<int>? onIndexChanged;

  static const List<Map<String, dynamic>> categoryTabs = [
    {'label': 'Live', 'icon': Icons.videocam_rounded, 'color': Color(0xFFFF2D55)},
    {'label': 'PK Battle', 'icon': Icons.sports_mma_outlined, 'color': Color(0xFF2979FF)},
    {'label': 'Chat Room', 'icon': Icons.mic_rounded, 'color': Color(0xFFBA43F6)},
  ];

  const HomeHeader({
    super.key,
    this.onSearchTap,
    this.onFavoritesTap,
    this.onHistoryTap,
    this.selectedIndex = 0, // Popular by default
    this.onIndexChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(14, 8, 14, 6),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // 1. Top Row: TIVOO Logo, Search Bar Pill, Heart & History Icons
          Row(
            children: [
              // TIVOO Branding (TaalMil style with green leaf glow)
              Row(
                mainAxisSize: MainAxisSize.min,
                children: const [
                  Text(
                    'Tiv',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.w900,
                      fontFamily: 'Outfit',
                      letterSpacing: 0.5,
                    ),
                  ),
                  Text(
                    'oo',
                    style: TextStyle(
                      color: Color(0xFF00E676),
                      fontSize: 22,
                      fontWeight: FontWeight.w900,
                      fontFamily: 'Outfit',
                      letterSpacing: 0.5,
                    ),
                  ),
                  SizedBox(width: 2),
                  Text('🌿', style: TextStyle(fontSize: 14)),
                ],
              ),

              const SizedBox(width: 10),

              // Search Bar Pill (TaalMil center rounded search)
              Expanded(
                child: GestureDetector(
                  onTap: onSearchTap,
                  child: Container(
                    height: 36,
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.15),
                      ),
                    ),
                    child: Row(
                      children: const [
                        Icon(Icons.search_rounded, color: Colors.white60, size: 18),
                        SizedBox(width: 6),
                        Text(
                          'Search',
                          style: TextStyle(
                            color: Colors.white60,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              const SizedBox(width: 8),

              // Favorites Heart Icon
              GestureDetector(
                onTap: onFavoritesTap,
                child: Container(
                  width: 34,
                  height: 34,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withValues(alpha: 0.06),
                  ),
                  child: const Icon(
                    Icons.favorite_border_rounded,
                    color: Colors.white70,
                    size: 19,
                  ),
                ),
              ),

              const SizedBox(width: 6),

              // History Clock Icon
              GestureDetector(
                onTap: onHistoryTap,
                child: Container(
                  width: 34,
                  height: 34,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withValues(alpha: 0.06),
                  ),
                  child: const Icon(
                    Icons.access_time_rounded,
                    color: Colors.white70,
                    size: 19,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 10),

          // 2. Category Switcher Pills (Voice Chat, Popular, Multi-Call, PK Battle, Community)
          SizedBox(
            height: 34,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              itemCount: categoryTabs.length,
              separatorBuilder: (context, index) => const SizedBox(width: 8),
              itemBuilder: (context, index) {
                final tab = categoryTabs[index];
                final isSelected = selectedIndex == index;
                final tabColor = (tab['color'] as Color?) ?? const Color(0xFF00E676);

                return GestureDetector(
                  onTap: () => onIndexChanged?.call(index),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? const Color(0xFF211D32)
                          : Colors.white.withValues(alpha: 0.05),
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(
                        color: isSelected
                            ? tabColor
                            : Colors.white.withValues(alpha: 0.1),
                        width: isSelected ? 1.2 : 0.8,
                      ),
                      boxShadow: isSelected
                          ? [
                              BoxShadow(
                                color: tabColor.withValues(alpha: 0.3),
                                blurRadius: 10,
                              ),
                            ]
                          : null,
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (isSelected) ...[
                          Container(
                            padding: const EdgeInsets.all(2.5),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: tabColor,
                            ),
                            child: Icon(
                              tab['icon'] as IconData,
                              color: Colors.white,
                              size: 11,
                            ),
                          ),
                          const SizedBox(width: 5),
                        ] else ...[
                          Icon(
                            tab['icon'] as IconData,
                            color: Colors.white60,
                            size: 14,
                          ),
                          const SizedBox(width: 5),
                        ],
                        Text(
                          tab['label'] as String,
                          style: TextStyle(
                            color: isSelected ? Colors.white : Colors.white60,
                            fontSize: 12.5,
                            fontWeight: isSelected ? FontWeight.w800 : FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
