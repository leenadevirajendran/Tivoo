import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/luxe_theme.dart';
import '../../../../core/widgets/custom_avatar.dart';
import '../../../activity/presentation/screens/activity_screen.dart';
import '../../../profile/presentation/controllers/profile_controller.dart';
import '../../domain/models/family_team_model.dart';
import '../controllers/family_controller.dart';
import '../widgets/family_share_link_sheet.dart';
import 'family_join_link_screen.dart';

/// Clean, concise frontend UI for Family Team screen.
/// Includes Facebook-style Family Joining Request workflow:
/// - Leader View: "Share Family Link", Join Requests notification routing to the Notification Panel
/// - Invitee View: Family Preview and "Join to Family" action
class FamilyTeamScreen extends ConsumerWidget {
  const FamilyTeamScreen({super.key});

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

    final pendingCount = family.pendingRequests.length;

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
          // 1. Notification Panel icon with pending requests badge
          IconButton(
            tooltip: 'Notifications',
            icon: Badge(
              isLabelVisible: isLeader && pendingCount > 0,
              label: Text(
                '$pendingCount',
                style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold),
              ),
              backgroundColor: const Color(0xFFFF2D55),
              child: const Icon(Icons.notifications_rounded, color: Colors.white, size: 22),
            ),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const ActivityScreen()),
              );
            },
          ),
          // 2. Share Family Link icon
          IconButton(
            tooltip: 'Share Family Link',
            icon: const Icon(Icons.share_rounded, color: Colors.white, size: 20),
            onPressed: () => FamilyShareLinkSheet.show(context, family: family),
          ),
          // 3. Preview Join Link icon
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

                    // 2. Leader's Join Requests Notification Banner (Routes to Notification Panel)
                    if (isLeader) ...[
                      _buildJoinRequestsNotificationCard(context, family),
                      const SizedBox(height: 12),
                    ],

                    // 3. Section Header: Family Members
                    _buildMembersHeader(family, state, isFull),

                    // 4. Member Roster (Shows current and accepted members)
                    _buildMembersList(family),

                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ),

            // 5. Bottom Panel: "Share Family Link" for Leader, "Request to Join" for Visitor
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

  /// Leader's Join Requests Notification Card that routes directly to the Notification Panel
  Widget _buildJoinRequestsNotificationCard(
    BuildContext context,
    FamilyTeamModel family,
  ) {
    final pendingCount = family.pendingRequests.length;
    final hasPending = pendingCount > 0;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(18),
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const ActivityScreen()),
            );
          },
          child: Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: hasPending
                    ? [const Color(0xFF261D3B), const Color(0xFF171426)]
                    : [const Color(0xFF181628), const Color(0xFF12101E)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                color: hasPending
                    ? LuxeColors.gold.withValues(alpha: 0.45)
                    : Colors.white12,
                width: 1.2,
              ),
              boxShadow: hasPending
                  ? [
                      BoxShadow(
                        color: LuxeColors.gold.withValues(alpha: 0.12),
                        blurRadius: 14,
                        offset: const Offset(0, 4),
                      ),
                    ]
                  : null,
            ),
            child: Row(
              children: [
                Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: hasPending
                            ? const Color(0xFFFF9500).withValues(alpha: 0.2)
                            : Colors.white10,
                        border: Border.all(
                          color: hasPending ? const Color(0xFFFF9500) : Colors.white24,
                          width: 1,
                        ),
                      ),
                      child: Icon(
                        hasPending
                            ? Icons.notifications_active_rounded
                            : Icons.notifications_none_rounded,
                        color: hasPending ? const Color(0xFFFFC928) : Colors.white60,
                        size: 22,
                      ),
                    ),
                    if (hasPending)
                      Positioned(
                        top: -2,
                        right: -2,
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: const BoxDecoration(
                            color: Color(0xFFFF2D55),
                            shape: BoxShape.circle,
                          ),
                          child: Text(
                            '$pendingCount',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 9.5,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Text(
                            'Join Requests',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: hasPending
                                  ? const Color(0x33FF9500)
                                  : Colors.white10,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              hasPending ? '$pendingCount NEW' : '0 PENDING',
                              style: TextStyle(
                                color: hasPending ? const Color(0xFFFFC928) : Colors.white38,
                                fontSize: 9,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 3),
                      Text(
                        hasPending
                            ? '${family.pendingRequests.map((r) => r.userName).join(', ')} requested to join. Tap to review in Notification Panel.'
                            : 'All caught up. New join requests will appear in your Notification Panel.',
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 11.5,
                          height: 1.25,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: hasPending
                        ? LuxeColors.gold
                        : Colors.white.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Review',
                        style: TextStyle(
                          color: hasPending ? Colors.black : Colors.white70,
                          fontSize: 11.5,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const SizedBox(width: 2),
                      Icon(
                        Icons.chevron_right_rounded,
                        color: hasPending ? Colors.black : Colors.white70,
                        size: 16,
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
