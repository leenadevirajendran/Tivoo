// "PK Ended" winner celebration overlay that keeps both hosts live on screen.

import 'dart:async';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../core/theme/luxe_theme.dart';
import '../../../core/widgets/custom_avatar.dart';
import '../core/pk_models.dart';

/// In-stream celebration overlay shown when PK battle ends:
/// - Announcement banner pops up in the center with celebration aesthetics
/// - Both winner and loser stay active in live stream on the same screen
/// - Automatically fades away after celebration announcement (or tap to dismiss)
/// - Back to battles and Stay in room buttons removed for clean viewer experience
class PkWinnerOverlay extends StatefulWidget {
  final PkHost left;
  final PkHost right;
  final int leftScore;
  final int rightScore;
  final bool isHost;
  final VoidCallback onPlayAgain;
  final VoidCallback onSkip;
  final VoidCallback? onBackToLive;
  final VoidCallback? onStay;

  const PkWinnerOverlay({
    super.key,
    required this.left,
    required this.right,
    required this.leftScore,
    required this.rightScore,
    this.isHost = false,
    required this.onPlayAgain,
    required this.onSkip,
    this.onBackToLive,
    this.onStay,
  });

  @override
  State<PkWinnerOverlay> createState() => _PkWinnerOverlayState();
}

class _PkWinnerOverlayState extends State<PkWinnerOverlay> with SingleTickerProviderStateMixin {
  late final AnimationController _anim = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 480),
  )..forward();

  late final Animation<double> _scale = CurvedAnimation(
    parent: _anim,
    curve: Curves.elasticOut,
  );

  late final Animation<double> _fade = CurvedAnimation(
    parent: _anim,
    curve: Curves.easeInOut,
  );

  Timer? _autoDismissTimer;
  bool _isDismissing = false;

  @override
  void initState() {
    super.initState();
    // Auto fade away after 3.2 seconds
    _autoDismissTimer = Timer(const Duration(milliseconds: 3200), _dismissOverlay);
  }

  void _dismissOverlay() {
    if (!mounted || _isDismissing) return;
    _isDismissing = true;
    _autoDismissTimer?.cancel();
    _anim.reverse().then((_) {
      if (mounted) {
        widget.onStay?.call();
      }
    });
  }

  @override
  void dispose() {
    _autoDismissTimer?.cancel();
    _anim.dispose();
    super.dispose();
  }

  bool get isDraw => widget.leftScore == widget.rightScore;
  bool get isLeftWinner => widget.leftScore > widget.rightScore;
  PkHost get winner => isLeftWinner ? widget.left : widget.right;
  PkHost get loser => isLeftWinner ? widget.right : widget.left;
  int get winnerScore => isLeftWinner ? widget.leftScore : widget.rightScore;
  int get loserScore => isLeftWinner ? widget.rightScore : widget.leftScore;

  @override
  Widget build(BuildContext context) {
    final format = NumberFormat('#,###');
    final mq = MediaQuery.of(context);
    final topPadding = mq.padding.top;
    final isSmall = mq.size.width < 360;

    return GestureDetector(
      onTap: _dismissOverlay,
      behavior: HitTestBehavior.opaque,
      child: Stack(
        children: [
          // 1. Semi-transparent backdrop scrim with blur
          Positioned.fill(
            child: FadeTransition(
              opacity: _fade,
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 4, sigmaY: 4),
                child: Container(color: Colors.black.withValues(alpha: 0.50)),
              ),
            ),
          ),

          // 2. Badges directly over the video arena (Left & Right)
          Positioned(
            top: topPadding + 84,
            left: 14,
            right: 14,
            child: Row(
              children: [
                Expanded(
                  child: isDraw
                      ? const _DrawBadge()
                      : (isLeftWinner ? const _WinnerBadge() : const _LoserBadge()),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: isDraw
                      ? const _DrawBadge()
                      : (!isLeftWinner ? const _WinnerBadge() : const _LoserBadge()),
                ),
              ],
            ),
          ),

          // 3. Center Announcement Banner Pop-up
          Center(
            child: ScaleTransition(
              scale: _scale,
              child: FadeTransition(
                opacity: _fade,
                child: Container(
                  width: (mq.size.width * 0.86).clamp(270.0, 360.0),
                  margin: const EdgeInsets.symmetric(horizontal: 20),
                  padding: EdgeInsets.symmetric(horizontal: isSmall ? 16 : 22, vertical: isSmall ? 18 : 22),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(28),
                    gradient: const LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [Color(0xF5181335), Color(0xF50D0B20), Color(0xF5180C28)],
                    ),
                    border: Border.all(
                      color: isDraw ? const Color(0xFF7B52FF) : LuxeColors.gold,
                      width: 1.6,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: (isDraw ? const Color(0xFF7B52FF) : const Color(0xFFFFC928)).withValues(alpha: 0.45),
                        blurRadius: 30,
                        spreadRadius: 2,
                      ),
                      const BoxShadow(color: Colors.black87, blurRadius: 24),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Glowing Trophy / Crown Badge
                      Container(
                        width: isSmall ? 64 : 76,
                        height: isSmall ? 64 : 76,
                        padding: const EdgeInsets.all(3),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: isDraw
                              ? const LinearGradient(colors: [Color(0xFF7B52FF), Color(0xFF00E5FF)])
                              : LuxeColors.goldGradient,
                          boxShadow: [
                            BoxShadow(
                              color: (isDraw ? const Color(0xFF7B52FF) : const Color(0xFFFFC928)).withValues(alpha: 0.6),
                              blurRadius: 18,
                            ),
                          ],
                        ),
                        child: CustomAvatar(
                          radius: isSmall ? 28 : 34,
                          assetPath: isDraw ? widget.left.avatarAsset : winner.avatarAsset,
                        ),
                      ),
                      const SizedBox(height: 12),

                      // Winner Title
                      Text(
                        isDraw ? 'PK Battle Draw!' : '${winner.name} Won! 🏆',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: isSmall ? 18 : 21,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 0.3,
                          shadows: const [Shadow(color: Colors.black, blurRadius: 8)],
                        ),
                      ),
                      const SizedBox(height: 4),

                      // Scores Clash Detail
                      Container(
                        margin: const EdgeInsets.symmetric(vertical: 8),
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.07),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: Colors.white12, width: 0.8),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.star_rounded, color: Color(0xFFFFDF00), size: 16),
                            const SizedBox(width: 4),
                            Text(
                              isDraw
                                  ? '${format.format(widget.leftScore)}  VS  ${format.format(widget.rightScore)}'
                                  : '${format.format(winnerScore)} pts   VS   ${format.format(loserScore)} pts',
                              style: const TextStyle(
                                color: LuxeColors.gold,
                                fontSize: 13,
                                fontWeight: FontWeight.w800,
                                letterSpacing: 0.4,
                              ),
                            ),
                          ],
                        ),
                      ),

                      Text(
                        isDraw
                            ? 'Incredible clash! Both battlers tied.'
                            : 'Glorious victory over ${loser.name}!',
                        textAlign: TextAlign.center,
                        style: const TextStyle(color: Colors.white60, fontSize: 12),
                      ),

                      // If Host mode, show Host Rebattle/End Battle; for viewers, only pure announcement that fades away
                      if (widget.isHost) ...[
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(
                              child: OutlinedButton(
                                style: OutlinedButton.styleFrom(
                                  side: BorderSide(color: Colors.white.withValues(alpha: 0.25), width: 1.2),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                                  padding: EdgeInsets.symmetric(vertical: isSmall ? 10 : 12),
                                ),
                                onPressed: widget.onSkip,
                                child: const Text(
                                  'End Battle',
                                  style: TextStyle(color: Colors.white70, fontSize: 13, fontWeight: FontWeight.w700),
                                ),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Container(
                                decoration: BoxDecoration(
                                  gradient: LuxeColors.goldGradient,
                                  borderRadius: BorderRadius.circular(18),
                                  boxShadow: const [
                                    BoxShadow(color: Color(0x66FFC928), blurRadius: 10, offset: Offset(0, 2)),
                                  ],
                                ),
                                child: Material(
                                  color: Colors.transparent,
                                  child: InkWell(
                                    borderRadius: BorderRadius.circular(18),
                                    onTap: widget.onPlayAgain,
                                    child: Padding(
                                      padding: EdgeInsets.symmetric(vertical: isSmall ? 10 : 12),
                                      child: const Center(
                                        child: Text(
                                          'Rebattle',
                                          style: TextStyle(
                                            color: Color(0xFF1F1400),
                                            fontSize: 13.5,
                                            fontWeight: FontWeight.w900,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _WinnerBadge extends StatelessWidget {
  const _WinnerBadge();

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.topCenter,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
        decoration: BoxDecoration(
          gradient: const LinearGradient(colors: [Color(0xFFFFEA79), Color(0xFFFFC928), Color(0xFFE59A00)]),
          borderRadius: BorderRadius.circular(14),
          boxShadow: const [
            BoxShadow(color: Color(0xAAFFD600), blurRadius: 10, offset: Offset(0, 2)),
          ],
        ),
        child: const Text(
          'WINNER',
          style: TextStyle(
            color: Color(0xFF1F1400),
            fontSize: 12,
            fontWeight: FontWeight.w900,
            letterSpacing: 1,
          ),
        ),
      ),
    );
  }
}

class _LoserBadge extends StatelessWidget {
  const _LoserBadge();

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.topCenter,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        decoration: BoxDecoration(
          color: const Color(0xCC1A102A),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Colors.white24, width: 0.9),
        ),
        child: const Text(
          'DEFEATED',
          style: TextStyle(
            color: Color(0xFF8E88A8),
            fontSize: 11,
            fontWeight: FontWeight.w800,
            letterSpacing: 0.8,
          ),
        ),
      ),
    );
  }
}

class _DrawBadge extends StatelessWidget {
  const _DrawBadge();

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.topCenter,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
        decoration: BoxDecoration(
          gradient: const LinearGradient(colors: [Color(0xFF5B3CFF), Color(0xFFB04DFF)]),
          borderRadius: BorderRadius.circular(14),
          boxShadow: const [
            BoxShadow(color: Color(0x887B52FF), blurRadius: 10, offset: Offset(0, 2)),
          ],
        ),
        child: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('🤝', style: TextStyle(fontSize: 13)),
            SizedBox(width: 4),
            Text(
              'DRAW',
              style: TextStyle(
                color: Colors.white,
                fontSize: 11.5,
                fontWeight: FontWeight.w900,
                letterSpacing: 0.8,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
