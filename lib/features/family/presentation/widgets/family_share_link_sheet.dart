import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../core/constants/app_assets.dart';
import '../../../../core/theme/luxe_theme.dart';
import '../../../../core/widgets/custom_avatar.dart';
import '../../domain/models/family_team_model.dart';
import '../screens/family_join_link_screen.dart';

/// Facebook-style Family Invite Link Bottom Sheet.
/// Displays generated dummy join link, instant Copy option, Tivoo Direct Messages,
/// and external social sharing (WhatsApp, Instagram, etc.).
class FamilyShareLinkSheet extends StatefulWidget {
  final FamilyTeamModel family;

  const FamilyShareLinkSheet({
    super.key,
    required this.family,
  });

  static Future<void> show(BuildContext context, {required FamilyTeamModel family}) {
    HapticFeedback.lightImpact();
    return showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) => FamilyShareLinkSheet(family: family),
    );
  }

  @override
  State<FamilyShareLinkSheet> createState() => _FamilyShareLinkSheetState();
}

class _FamilyShareLinkSheetState extends State<FamilyShareLinkSheet> {
  final Set<String> _sentFollowerIds = {};
  bool _copied = false;

  late final String _dummyJoinLink =
      'https://tivoo.app/family/join?code=${widget.family.name.replaceAll(' ', '')}2026';

  late final String _shareText =
      '🛡️ Join our Family team "${widget.family.name}" on Tivoo! We support each other in PK battles and grow together. Tap the link to send your joining request: $_dummyJoinLink';

  static const List<_TivooFollower> _followers = [
    _TivooFollower(id: 'u1', name: 'Diya Sharma', username: '@diya_official', avatar: AppAssets.avatarDiya),
    _TivooFollower(id: 'u2', name: 'Priya Singh', username: '@priya_star', avatar: AppAssets.avatarPriya),
    _TivooFollower(id: 'u3', name: 'Neha Verma', username: '@neha_live', avatar: AppAssets.avatarNeha),
    _TivooFollower(id: 'u4', name: 'Arun Kumar', username: '@arun_k', avatar: AppAssets.avatarArun),
    _TivooFollower(id: 'u5', name: 'Vicky', username: '@vicky_vibes', avatar: AppAssets.avatarVicky),
    _TivooFollower(id: 'u6', name: 'Sneha', username: '@sneha_dance', avatar: AppAssets.avatarSneha),
    _TivooFollower(id: 'u7', name: 'Karthik', username: '@karthik_pro', avatar: AppAssets.avatarKarthik),
  ];

  void _copyToClipboard() {
    Clipboard.setData(ClipboardData(text: _dummyJoinLink));
    HapticFeedback.mediumImpact();
    setState(() => _copied = true);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: const [
            Icon(Icons.check_circle_rounded, color: Color(0xFF00E676), size: 18),
            SizedBox(width: 8),
            Text('Family joining link copied to clipboard! 📋'),
          ],
        ),
        backgroundColor: const Color(0xFF1B1638),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
      ),
    );

    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) setState(() => _copied = false);
    });
  }

  void _sendDirectMessage(_TivooFollower follower) {
    HapticFeedback.lightImpact();
    setState(() => _sentFollowerIds.add(follower.id));

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.mark_email_read_rounded, color: Color(0xFF00E676), size: 18),
            const SizedBox(width: 8),
            Text('Invite link sent to ${follower.name}\'s messages ✉️'),
          ],
        ),
        backgroundColor: const Color(0xFF1B1638),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  Future<void> _shareToApp(String appName) async {
    Navigator.of(context).pop();

    try {
      if (appName == 'WhatsApp') {
        final uri = Uri.parse('whatsapp://send?text=${Uri.encodeComponent(_shareText)}');
        final webUri = Uri.parse('https://api.whatsapp.com/send?text=${Uri.encodeComponent(_shareText)}');
        if (await canLaunchUrl(uri)) {
          await launchUrl(uri, mode: LaunchMode.externalApplication);
          return;
        }
        await launchUrl(webUri, mode: LaunchMode.externalApplication);
      } else if (appName == 'Telegram') {
        final uri = Uri.parse('tg://msg_url?url=${Uri.encodeComponent(_dummyJoinLink)}&text=${Uri.encodeComponent(_shareText)}');
        final webUri = Uri.parse('https://t.me/share/url?url=${Uri.encodeComponent(_dummyJoinLink)}&text=${Uri.encodeComponent(_shareText)}');
        if (await canLaunchUrl(uri)) {
          await launchUrl(uri, mode: LaunchMode.externalApplication);
          return;
        }
        await launchUrl(webUri, mode: LaunchMode.externalApplication);
      }
    } catch (_) {}

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Sharing family invite via $appName...'),
          backgroundColor: const Color(0xFF1B1638),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final mq = MediaQuery.of(context);

    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF12101F),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        border: Border.all(color: LuxeColors.gold.withValues(alpha: 0.35), width: 1.2),
        boxShadow: const [
          BoxShadow(color: Colors.black87, blurRadius: 30, offset: Offset(0, -6)),
        ],
      ),
      padding: EdgeInsets.fromLTRB(16, 12, 16, 16 + mq.padding.bottom),
      child: SafeArea(
        top: false,
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top drag pill
              Center(
                child: Container(
                  width: 44,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.white24,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 14),

              // Title and Header
              Row(
                children: [
                  Container(
                    width: 42,
                    height: 42,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: const LinearGradient(
                        colors: [Color(0xFFFFD700), Color(0xFFFF8F00)],
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFFFFD700).withValues(alpha: 0.35),
                          blurRadius: 10,
                        ),
                      ],
                    ),
                    child: Center(
                      child: Text(
                        widget.family.badgeIcon,
                        style: const TextStyle(fontSize: 22),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Share Family Link',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 17,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 0.3,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Invite creators to join "${widget.family.name}"',
                          style: const TextStyle(color: Colors.white60, fontSize: 12),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close_rounded, color: Colors.white54, size: 22),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Dummy Family Link Display Box
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFF1B182B),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.white12, width: 1),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.link_rounded, color: LuxeColors.gold, size: 18),
                        const SizedBox(width: 6),
                        const Text(
                          'Family Joining Link',
                          style: TextStyle(
                            color: LuxeColors.gold,
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const Spacer(),
                        // Test Preview Button
                        GestureDetector(
                          onTap: () {
                            Navigator.pop(context);
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => const FamilyJoinLinkScreen(),
                              ),
                            );
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: const Color(0x3300E5FF),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: const Color(0xFF00E5FF), width: 0.8),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: const [
                                Text(
                                  'Preview Link',
                                  style: TextStyle(
                                    color: Color(0xFF00E5FF),
                                    fontSize: 10.5,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                                SizedBox(width: 3),
                                Icon(Icons.open_in_new_rounded, color: Color(0xFF00E5FF), size: 11),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                            decoration: BoxDecoration(
                              color: Colors.black26,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              _dummyJoinLink,
                              style: const TextStyle(
                                color: Colors.white70,
                                fontSize: 11.5,
                                fontFamily: 'monospace',
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        // Copy Button
                        GestureDetector(
                          onTap: _copyToClipboard,
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: _copied
                                    ? [const Color(0xFF00E676), const Color(0xFF00B0FF)]
                                    : [LuxeColors.gold, const Color(0xFFFF9500)],
                              ),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  _copied ? Icons.check_rounded : Icons.copy_rounded,
                                  color: Colors.black,
                                  size: 15,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  _copied ? 'Copied' : 'Copy',
                                  style: const TextStyle(
                                    color: Colors.black,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w900,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 18),

              // Section 1: Send in Tivoo Messages (Followers)
              const Text(
                'Send in Tivoo Messages',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 10),
              SizedBox(
                height: 100,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  physics: const BouncingScrollPhysics(),
                  itemCount: _followers.length,
                  separatorBuilder: (_, _) => const SizedBox(width: 14),
                  itemBuilder: (context, i) {
                    final f = _followers[i];
                    final isSent = _sentFollowerIds.contains(f.id);

                    return SizedBox(
                      width: 68,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          CustomAvatar(radius: 23, assetPath: f.avatar),
                          const SizedBox(height: 4),
                          Text(
                            f.name,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 10.5,
                              fontWeight: FontWeight.w600,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 4),
                          GestureDetector(
                            onTap: () => _sendDirectMessage(f),
                            child: Container(
                              width: double.infinity,
                              padding: const EdgeInsets.symmetric(vertical: 2.5),
                              decoration: BoxDecoration(
                                color: isSent
                                    ? const Color(0xFF00E676).withValues(alpha: 0.2)
                                    : const Color(0xFF00E5FF),
                                borderRadius: BorderRadius.circular(12),
                                border: isSent
                                    ? Border.all(color: const Color(0xFF00E676), width: 0.8)
                                    : null,
                              ),
                              child: Center(
                                child: Text(
                                  isSent ? 'Sent ✓' : 'Send',
                                  style: TextStyle(
                                    color: isSent ? const Color(0xFF00E676) : Colors.black,
                                    fontSize: 10,
                                    fontWeight: FontWeight.w800,
                                  ),
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
              const SizedBox(height: 14),

              // Section 2: Share to External Apps
              const Text(
                'Share to Apps',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _ShareAppIcon(
                    icon: Icons.chat_bubble_rounded,
                    label: 'WhatsApp',
                    gradient: const [Color(0xFF25D366), Color(0xFF128C7E)],
                    onTap: () => _shareToApp('WhatsApp'),
                  ),
                  _ShareAppIcon(
                    icon: Icons.camera_alt_rounded,
                    label: 'Instagram',
                    gradient: const [Color(0xFF833AB4), Color(0xFFFD1D1D), Color(0xFFFCB045)],
                    onTap: () => _shareToApp('Instagram'),
                  ),
                  _ShareAppIcon(
                    icon: Icons.send_rounded,
                    label: 'Telegram',
                    gradient: const [Color(0xFF0088CC), Color(0xFF229ED9)],
                    onTap: () => _shareToApp('Telegram'),
                  ),
                  _ShareAppIcon(
                    icon: Icons.facebook_rounded,
                    label: 'Facebook',
                    gradient: const [Color(0xFF1877F2), Color(0xFF0C5EC9)],
                    onTap: () => _shareToApp('Facebook'),
                  ),
                  _ShareAppIcon(
                    icon: Icons.more_horiz_rounded,
                    label: 'More',
                    gradient: const [Color(0xFF3B384F), Color(0xFF201D33)],
                    onTap: () => _shareToApp('More Apps'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TivooFollower {
  final String id;
  final String name;
  final String username;
  final String avatar;

  const _TivooFollower({
    required this.id,
    required this.name,
    required this.username,
    required this.avatar,
  });
}

class _ShareAppIcon extends StatelessWidget {
  final IconData icon;
  final String label;
  final List<Color> gradient;
  final VoidCallback onTap;

  const _ShareAppIcon({
    required this.icon,
    required this.label,
    required this.gradient,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: gradient,
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              boxShadow: [
                BoxShadow(
                  color: gradient.first.withValues(alpha: 0.3),
                  blurRadius: 10,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Icon(icon, color: Colors.white, size: 22),
          ),
          const SizedBox(height: 6),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 10.5,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
