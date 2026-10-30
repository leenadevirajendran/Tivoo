import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/luxe_theme.dart';
import '../../../../core/widgets/custom_avatar.dart';
import '../../../profile/presentation/controllers/profile_controller.dart';
import '../../domain/models/family_team_model.dart';
import '../controllers/family_controller.dart';
import '../widgets/family_share_link_sheet.dart';
import 'family_join_link_screen.dart';

/// Clean, concise frontend UI for Family Team screen.
/// Includes Facebook-style Family Joining Request workflow:
/// - Leader View: "Share Family Link", "Join Requests" management (Accept / Reject)
/// - Invitee View: Family Preview and "Join to Family" action
class FamilyTeamScreen extends ConsumerWidget {
  const FamilyTeamScreen({super.key});

  String _formatTimeAgo(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    return '${diff.inDays}d ago';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(familyControllerProvider);
    final controller = ref.read(familyControllerProvider.notifier);
    final family = state.currentFamily;
    final isFull = state.isFamilyFull;

    // Check if the current user is the Family Leader
    final profile = ref.watch(profileControllerProvider).profile;
    final isLeader = state.verification.isFamilyLeader ||
        family.leaderId == profile.id ||
        family.leaderName.toLowerCase() == profile.name.toLowerCase();

    return Scaffold(
      backgroundColor: const Color(0xFF0C0B14),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          family.name,
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900, letterSpacing: 0.5),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            tooltip: 'Share Family Link',
            icon: const Icon(Icons.share_rounded, color: Colors.white, size: 20),
            onPressed: () => FamilyShareLinkSheet.show(context, family: family),
          ),
          IconButton(
            tooltip: 'Preview Join Link',
            icon: const Icon(Icons.open_in_new_rounded, color: LuxeColors.gold, size: 20),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const FamilyJoinLinkScreen()),
              );
            },
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 1. Family Banner (Capacity limit 100 shown cleanly)
                    _buildHeroBanner(family, isFull),

                    const SizedBox(height: 12),

                    // 2. Leader's Join Requests Management Section
                    if (isLeader) ...[
                      _buildJoinRequestsSection(context, family, controller),
                      const SizedBox(height: 12),
                    ],

                    // 3. Section Header: Family Members
                    _buildMembersHeader(family, state, isFull),

                    // 4. Member Roster (No star balances, clean cards)
                    _buildMembersList(family),

                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ),

            // 5. Request / Join / Share Action Panel
            _buildBottomPanel(context, state, controller, isLeader, isFull),
          ],
        ),
      ),
    );
  }

  Widget _buildHeroBanner(FamilyTeamModel family, bool isFull) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF1E1B2E), Color(0xFF12101C)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: LuxeColors.gold.withValues(alpha: 0.3), width: 1.2),
        boxShadow: const [
          BoxShadow(color: Colors.black87, blurRadius: 18, offset: Offset(0, 6)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Stack(
                clipBehavior: Clip.none,
                children: [
                  Container(
                    width: 52,
                    height: 52,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(colors: [Color(0xFFFFD700), Color(0xFFFF8F00)]),
                      boxShadow: [BoxShadow(color: Color(0x66FFD700), blurRadius: 10)],
                    ),
                    child: Center(child: Text(family.badgeIcon, style: const TextStyle(fontSize: 26))),
                  ),
                  const Positioned(top: -5, right: -2, child: Text('👑', style: TextStyle(fontSize: 15))),
                ],
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            family.name,
                            style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w900),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(color: LuxeColors.gold, borderRadius: BorderRadius.circular(8)),
                          child: const Text(
                            'TOP FAMILY',
                            style: TextStyle(color: Colors.black, fontSize: 8.5, fontWeight: FontWeight.w900),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 3),
                    Text(
                      'Leader: ${family.leaderName} 👑',
                      style: const TextStyle(color: Color(0xFFFFD54F), fontSize: 12, fontWeight: FontWeight.bold),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(family.slogan, style: const TextStyle(color: Colors.white70, fontSize: 12, height: 1.3)),
          const SizedBox(height: 12),
          // Capacity Chip
          Container(
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isFull ? const Color(0xFFFF2D55).withValues(alpha: 0.5) : const Color(0xFF00E676).withValues(alpha: 0.35),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.group_rounded,
                  size: 18,
                  color: isFull ? const Color(0xFFFF2D55) : const Color(0xFF00E676),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Members: ${family.memberCount}/100',
                    style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w800),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 6),
                Text(
                  isFull ? 'Capacity Full' : 'Limit 100',
                  style: TextStyle(
                    color: isFull ? const Color(0xFFFF2D55) : LuxeColors.textDim,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Leader's Join Requests Management Section
  Widget _buildJoinRequestsSection(
    BuildContext context,
    FamilyTeamModel family,
    FamilyController controller,
  ) {
    final pending = family.pendingRequests;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF161426),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: pending.isNotEmpty
              ? LuxeColors.gold.withValues(alpha: 0.35)
              : Colors.white10,
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.mark_email_unread_rounded, color: LuxeColors.gold, size: 18),
              const SizedBox(width: 8),
              const Text(
                'Join Requests',
                style: TextStyle(color: Colors.white, fontSize: 14.5, fontWeight: FontWeight.w800),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2.5),
                decoration: BoxDecoration(
                  color: pending.isNotEmpty
                      ? const Color(0xFFFF9500).withValues(alpha: 0.2)
                      : Colors.white10,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: pending.isNotEmpty
                        ? const Color(0xFFFF9500).withValues(alpha: 0.5)
                        : Colors.white24,
                  ),
                ),
                child: Text(
                  '${pending.length} Pending',
                  style: TextStyle(
                    color: pending.isNotEmpty ? const Color(0xFFFFC928) : Colors.white60,
                    fontSize: 10.5,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),

          if (pending.isEmpty)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.03),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: const [
                  Icon(Icons.check_circle_outline_rounded, color: Color(0xFF00E676), size: 18),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'No pending requests. Share your Family Link to invite creators!',
                      style: TextStyle(color: Colors.white60, fontSize: 11.5),
                    ),
                  ),
                ],
              ),
            )
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: pending.length,
              separatorBuilder: (_, _) => const SizedBox(height: 10),
              itemBuilder: (context, index) {
                final req = pending[index];

                return Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1E1A33),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: Colors.white12),
                  ),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          CustomAvatar(radius: 20, assetPath: req.userAvatar),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  req.userName,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 13.5,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  '${req.userTikiId} • ${_formatTimeAgo(req.requestedAt)}',
                                  style: const TextStyle(color: Colors.white54, fontSize: 11),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: const Color(0x33FF9500),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: const Text(
                              'REQUEST',
                              style: TextStyle(
                                color: Color(0xFFFFC928),
                                fontSize: 9,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          // Reject Button
                          Expanded(
                            child: SizedBox(
                              height: 34,
                              child: OutlinedButton.icon(
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: const Color(0xFFFF2D55),
                                  side: const BorderSide(color: Color(0x66FF2D55), width: 1),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                  padding: EdgeInsets.zero,
                                ),
                                onPressed: () {
                                  controller.declineJoinRequest(req.id);
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text('Declined join request from ${req.userName}.'),
                                      backgroundColor: const Color(0xFF1B1638),
                                      behavior: SnackBarBehavior.floating,
                                      duration: const Duration(seconds: 2),
                                    ),
                                  );
                                },
                                icon: const Icon(Icons.close_rounded, size: 15),
                                label: const Text('Reject', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700)),
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          // Accept Button
                          Expanded(
                            child: SizedBox(
                              height: 34,
                              child: ElevatedButton.icon(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: LuxeColors.gold,
                                  foregroundColor: Colors.black,
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                  padding: EdgeInsets.zero,
                                  elevation: 0,
                                ),
                                onPressed: () {
                                  controller.acceptJoinRequest(req.id);
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Row(
                                        children: [
                                          const Icon(Icons.check_circle_rounded, color: Color(0xFF00E676), size: 18),
                                          const SizedBox(width: 8),
                                          Text('Accepted ${req.userName} into ${family.name}! 🎉'),
                                        ],
                                      ),
                                      backgroundColor: const Color(0xFF1B1638),
                                      behavior: SnackBarBehavior.floating,
                                      duration: const Duration(seconds: 2),
                                    ),
                                  );
                                },
                                icon: const Icon(Icons.check_rounded, size: 15, color: Colors.black),
                                label: const Text(
                                  'Accept',
                                  style: TextStyle(
                                    color: Colors.black,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w900,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              },
            ),
        ],
      ),
    );
  }

  Widget _buildMembersHeader(FamilyTeamModel family, FamilyState state, bool isFull) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
      child: Row(
        children: [
          Expanded(
            child: Text(
              'Family Members (${family.memberCount}/100)',
              style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w800),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: isFull
                  ? const Color(0xFFFF2D55).withValues(alpha: 0.2)
                  : const Color(0xFF00E676).withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: isFull ? const Color(0xFFFF2D55) : const Color(0xFF00E676).withValues(alpha: 0.4),
              ),
            ),
            child: Text(
              isFull ? 'CAPACITY FULL' : '${state.spotsRemaining} spots left',
              style: TextStyle(
                color: isFull ? const Color(0xFFFF2D55) : const Color(0xFF00E676),
                fontSize: 10,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMembersList(FamilyTeamModel family) {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      itemCount: family.members.length,
      itemBuilder: (context, index) {
        final m = family.members[index];
        final isLeaderRole = m.role.contains('Leader');

        return Container(
          margin: const EdgeInsets.only(bottom: 8),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
          decoration: BoxDecoration(
            color: isLeaderRole ? const Color(0x33FFD700) : const Color(0xFF191724),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: isLeaderRole ? const Color(0xFFFFD700) : Colors.white12,
              width: isLeaderRole ? 1.2 : 0.6,
            ),
          ),
          child: Row(
            children: [
              CustomAvatar(radius: 19, assetPath: m.avatar),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            m.name,
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 13.5,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: isLeaderRole ? const Color(0xFFFFD700) : Colors.white12,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            m.role,
                            style: TextStyle(
                              color: isLeaderRole ? Colors.black : Colors.white70,
                              fontSize: 9.5,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${m.tikiId} • Joined ${m.joinedDate}',
                      style: const TextStyle(color: Colors.white54, fontSize: 11),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildBottomPanel(
    BuildContext context,
    FamilyState state,
    FamilyController controller,
    bool isLeader,
    bool isFull,
  ) {
    if (isFull) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
        decoration: const BoxDecoration(
          color: Color(0xFF14121E),
          border: Border(top: BorderSide(color: Color(0xFFFF2D55), width: 1.2)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            Icon(Icons.lock_rounded, color: Color(0xFFFF2D55), size: 18),
            SizedBox(width: 8),
            Text(
              'Family Full (100/100 Members) • Requests Closed',
              style: TextStyle(color: Color(0xFFFF2D55), fontSize: 13, fontWeight: FontWeight.w800),
            ),
          ],
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: const BoxDecoration(
        color: Color(0xFF14121E),
        border: Border(top: BorderSide(color: Colors.white12)),
      ),
      child: isLeader
          ? SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: LuxeColors.gold,
                  foregroundColor: Colors.black,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  elevation: 2,
                ),
                onPressed: () {
                  FamilyShareLinkSheet.show(context, family: state.currentFamily);
                },
                icon: const Icon(Icons.share_rounded, color: Colors.black, size: 19),
                label: const Text(
                  'Share Family Link',
                  style: TextStyle(color: Colors.black, fontWeight: FontWeight.w900, fontSize: 14.5),
                ),
              ),
            )
          : SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: state.hasRequestedToJoin ? Colors.grey.shade800 : const Color(0xFFFFD700),
                  foregroundColor: Colors.black,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  elevation: 0,
                ),
                onPressed: state.hasRequestedToJoin
                    ? null
                    : () {
                        controller.submitJoinRequest(
                          userName: 'Kasshvi',
                          userAvatar: 'assets/images/user_avatar.png',
                          userTikiId: 'ID: 10341053',
                        );
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Join request sent as Private Notification to Leader Rohit Rajdhani! 📩⏳'),
                          ),
                        );
                      },
                icon: Icon(
                  state.hasRequestedToJoin ? Icons.hourglass_top_rounded : Icons.group_add_rounded,
                  color: state.hasRequestedToJoin ? Colors.white60 : Colors.black,
                  size: 18,
                ),
                label: Text(
                  state.hasRequestedToJoin ? 'Join Request Sent (Pending) ⏳' : 'Request to Join Family',
                  style: TextStyle(
                    color: state.hasRequestedToJoin ? Colors.white60 : Colors.black,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
    );
  }
}
