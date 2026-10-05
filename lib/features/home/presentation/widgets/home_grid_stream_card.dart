import 'package:flutter/material.dart';
import '../../../../core/constants/app_assets.dart';
import '../../../../core/widgets/custom_avatar.dart';
import '../../domain/models/live_stream_card_model.dart';

class HomeGridStreamCard extends StatelessWidget {
  final LiveStreamCardModel stream;
  final VoidCallback? onTap;

  const HomeGridStreamCard({
    super.key,
    required this.stream,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    // Generate a heat score from viewers or ID for consistent visual display matching Screenshot 1
    final heatScore = (stream.viewersCount.hashCode.abs() % 160) + 40;

    return RepaintBoundary(
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          boxShadow: const [
            BoxShadow(
              color: Color(0x33000000),
              blurRadius: 10,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Stack(
            fit: StackFit.expand,
            children: [
              // 1. Cover Image / Media
              _buildCover(),

              // 2. Gradient Shade for top badge & bottom info
              Positioned.fill(
                child: Container(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Color(0x66000000),
                        Colors.transparent,
                        Colors.transparent,
                        Color(0xCC000000),
                      ],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      stops: [0.0, 0.25, 0.60, 1.0],
                    ),
                  ),
                ),
              ),

              // 3. Top Badges (Images 1 & 2 styles)
              Positioned(
                top: 8,
                left: 8,
                right: 8,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Left Badges
                    Flexible(
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        alignment: Alignment.centerLeft,
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (stream.isPk) ...[
                              // PK Badge (Image 1)
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                                decoration: BoxDecoration(
                                  gradient: const LinearGradient(
                                    colors: [Color(0xFFFF2D55), Color(0xFFFF4081)],
                                  ),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: const Text(
                                  'PK',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 9,
                                    fontWeight: FontWeight.w900,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 3),
                              // Gaming controller LIVE badge (Image 1)
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                                decoration: BoxDecoration(
                                  gradient: const LinearGradient(
                                    colors: [Color(0xFF2979FF), Color(0xFF00E5FF)],
                                  ),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: const Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(Icons.sports_esports_rounded, color: Colors.white, size: 10),
                                    SizedBox(width: 2),
                                    Text(
                                      'LIVE',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 8,
                                        fontWeight: FontWeight.w900,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ] else ...[
                              // Red LIVE Badge (Image 2)
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFFF1744),
                                  borderRadius: BorderRadius.circular(5),
                                ),
                                child: const Text(
                                  'LIVE',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 9,
                                    fontWeight: FontWeight.w900,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 4),

                    // Right Top Stats (Image 2: 🤍 15  👤 03)
                    if (stream.likesCount != null)
                      Flexible(
                        child: FittedBox(
                          fit: BoxFit.scaleDown,
                          alignment: Alignment.centerRight,
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.favorite, color: Colors.white, size: 10),
                              const SizedBox(width: 2),
                              Text(
                                stream.likesCount!,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 9.5,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(width: 4),
                              const Icon(Icons.person, color: Colors.white, size: 10),
                              const SizedBox(width: 2),
                              Text(
                                stream.viewersCount,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 9.5,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                  ],
                ),
              ),

              // 4. Bottom Info: Streamer avatar, Name, Heat score & Audio badge
              Positioned(
                bottom: 8,
                left: 8,
                right: 8,
                child: Row(
                  children: [
                    CustomAvatar(
                      radius: 13,
                      assetPath: stream.streamerAssetPath ?? AppAssets.status1,
                      imageUrl: stream.streamerAvatarUrl,
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            stream.streamerName,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              shadows: [
                                Shadow(color: Colors.black, blurRadius: 4),
                              ],
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Text('🔥', style: TextStyle(fontSize: 10)),
                              const SizedBox(width: 2),
                              Text(
                                '${stream.heatScore ?? heatScore}',
                                style: const TextStyle(
                                  color: Color(0xFFFF9100),
                                  fontSize: 10,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    // Bottom-Right Circular Badge (Image 1 Audio equalizer badge)
                    if (stream.isPk)
                      Container(
                        width: 26,
                        height: 26,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.black.withValues(alpha: 0.5),
                          border: Border.all(color: Colors.white54, width: 1),
                        ),
                        child: const Icon(
                          Icons.graphic_eq_rounded,
                          color: Colors.white,
                          size: 15,
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}

  Widget _buildCover() {
    if (stream.coverAssetPath != null && stream.coverAssetPath!.isNotEmpty) {
      return Image.asset(
        stream.coverAssetPath!,
        fit: BoxFit.cover,
        cacheWidth: 400,
      );
    }
    if (stream.streamerAssetPath != null && stream.streamerAssetPath!.isNotEmpty) {
      return Image.asset(
        stream.streamerAssetPath!,
        fit: BoxFit.cover,
        cacheWidth: 400,
      );
    }
    return Image.asset(
      AppAssets.status1,
      fit: BoxFit.cover,
      cacheWidth: 400,
    );
  }
}
