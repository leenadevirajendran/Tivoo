import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_assets.dart';
import '../../../../core/utils/responsive.dart';
import '../../../../core/widgets/custom_avatar.dart';
import '../../../family/presentation/screens/family_team_screen.dart';
import '../../../settings/presentation/screens/settings_screen.dart';
import '../controllers/profile_controller.dart';
import '../widgets/edit_profile_dialog.dart';
import '../widgets/tiki_verification_sheet.dart';

/// Tiki Live Profile Screen strictly matching the user's reference screenshot:
/// - Top Bar: Live camera [Q1] badge, Wallet icon, Hamburger menu
/// - Profile Identity: Rohit Rajdhani avatar with neon magenta glow, rohit_rajdhani66, verified badge, level 10 pill
/// - Stats Row: 4.7K Followers, 300 Following, 53.1K Likes
/// - Bio Section: #Knowledge tag, Rohit Rajdhani, official host notice, TIKI Honor badges with chevron
/// - Action Buttons: Edit Profile, Find Friends, Instagram icon
/// - Tiki Star / Angels / Family banner: Tiki Star No.500+, Angels with avatars + yellow Share button, Family RS TECH
/// - Tabs: Videos 411 (with yellow underline) and Likes 39637
/// - 3-Column Video Grid: Drafts card with Tiki logo, Pinned video cards with view counts, and video thumbnails
class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  int _selectedTab = 0; // 0 = Videos, 1 = Likes

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(profileControllerProvider);
    final controller = ref.read(profileControllerProvider.notifier);
    final profile = state.profile;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        top: true,
        bottom: false,
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Center(
            child: ConstrainedBox(
              constraints: BoxConstraints(
                maxWidth: context.isTablet ? 700 : double.infinity,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 1. Top Bar: Live Camera [Q1], Wallet & Hamburger Menu
                  _buildTopBar(context),

                  const SizedBox(height: 12),

                  // 2. Profile Identity Header (Avatar with pink neon glow, username, stats)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: _buildProfileIdentityHeader(),
                  ),

                  const SizedBox(height: 12),

                  // 3. Bio & TIKI Honor Row
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: _buildBioSection(),
                  ),

                  const SizedBox(height: 14),

                  // 4. Action Buttons (Edit Profile, Find Friends, Instagram)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: _buildActionButtons(context, controller, profile),
                  ),

                  const SizedBox(height: 14),

                  // 5. Tiki Star / Angels / Family RS TECH Banner
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: _buildTikiStarAngelsFamilyBanner(context),
                  ),

                  const SizedBox(height: 16),

                  // 6. Content Tabs: Videos 411 (yellow indicator) & Likes 39637
                  _buildContentTabs(),

                  const SizedBox(height: 6),

                  // 7. 3-Column Video Grid matching Screenshot
                  _buildVideosGrid(context),

                  // Bottom padding for floating navigation bar
                  const SizedBox(height: 110),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// 1. Top Bar: Live Camera [Q1], Wallet & Hamburger Menu
  Widget _buildTopBar(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Live Broadcast Camera Pill with [Q1]
          GestureDetector(
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('🎥 Ready to broadcast! Tap center button to go live'),
                  duration: Duration(seconds: 1),
                ),
              );
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: Colors.white24, width: 0.8),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.video_call_rounded, color: Colors.white, size: 18),
                  SizedBox(width: 4),
                  Text(
                    'Q1',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 11,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Right Icons: Wallet & Menu
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                icon: const Icon(
                  Icons.account_balance_wallet_outlined,
                  color: Colors.white,
                  size: 24,
                ),
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('💎 Wallet Balance: 6,850 Diamonds • 120 Stars'),
                      duration: Duration(seconds: 1),
                    ),
                  );
                },
              ),
              IconButton(
                icon: const Icon(
                  Icons.menu_rounded,
                  color: Colors.white,
                  size: 26,
                ),
                onPressed: () => _showProfileMenuOptions(context),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// 2. Profile Identity Header: Large avatar with neon magenta glow, username, badges & stats
  Widget _buildProfileIdentityHeader() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // Large Avatar with Neon Pink / Magenta Glowing Border
        Container(
          padding: const EdgeInsets.all(3.5),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: const LinearGradient(
              colors: [Color(0xFFFF2D75), Color(0xFFE91E63)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFFFF2D75).withValues(alpha: 0.55),
                blurRadius: 18,
                spreadRadius: 2,
              ),
            ],
          ),
          child: const CustomAvatar(
            radius: 40,
            assetPath: AppAssets.status5,
            alignment: Alignment(0.0, -0.65),
          ),
        ),

        const SizedBox(width: 18),

        // Right Column: Username with verified & level, plus Followers/Following/Likes stats
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Username, Verified Badge & Level 10 Badge
              Row(
                children: [
                  const Flexible(
                    child: Text(
                      'rohit_rajdhani66',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 17,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 0.2,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 5),
                  const Icon(
                    Icons.verified_rounded,
                    color: Color(0xFFB0BEC5),
                    size: 16,
                  ),
                  const SizedBox(width: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: const Color(0xFF2C2C38),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: Colors.white12, width: 0.8),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.arrow_upward_rounded,
                          color: Colors.white70,
                          size: 10,
                        ),
                        SizedBox(width: 2),
                        Text(
                          '10',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 12),

              // Stats Row (4.7K Followers, 300 Following, 53.1K Likes)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildStatItem('4.7K', 'Followers'),
                  _buildStatItem('300', 'Following'),
                  _buildStatItem('53.1K', 'Likes'),
                  const SizedBox(width: 8),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStatItem(String count, String label) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          count,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.w900,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: const TextStyle(
            color: Colors.white60,
            fontSize: 11,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  /// 3. Bio Section with Tag, Official Host notice, and TIKI Honor row
  Widget _buildBioSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Category Tag
        const Text(
          '#Knowledge',
          style: TextStyle(
            color: Color(0xFF90A4AE),
            fontSize: 12.5,
            fontWeight: FontWeight.w600,
          ),
        ),

        const SizedBox(height: 4),

        // Display Name
        const Text(
          'Rohit Rajdhani',
          style: TextStyle(
            color: Colors.white,
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
        ),

        const SizedBox(height: 4),

        // Bio Text strictly matching Image:
        // "OFFICIAL HOST BANNE KE LIYE MASSAGE KARE 80848 06861 LIVE AANE KA TIME 9PM"
        const Text(
          'OFFICIAL HOST BANNE KE LIYE MASSAGE KARE 80848 06861 LIVE AANE KA TIME 9PM',
          style: TextStyle(
            color: Colors.white70,
            fontSize: 12,
            height: 1.35,
            fontWeight: FontWeight.w500,
          ),
        ),

        const SizedBox(height: 8),

        // TIKI Honor Row with 3 badges and chevron (Opens Tiki Verification Roadmap)
        GestureDetector(
          onTap: () => TikiVerificationSheet.show(context),
          child: Row(
            children: [
              const Text(
                'TIKI Honor:',
                style: TextStyle(
                  color: Color(0xFFFFB300),
                  fontSize: 12,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(width: 8),

              // Badge 1: Orange/Red Shield
              _buildHonorBadge(
                gradient: const LinearGradient(
                  colors: [Color(0xFFFF9100), Color(0xFFFF3D00)],
                ),
                child: const Text('🛡️', style: TextStyle(fontSize: 11)),
              ),
              const SizedBox(width: 6),

              // Badge 2: Gold Medal
              _buildHonorBadge(
                gradient: const LinearGradient(
                  colors: [Color(0xFFFFD700), Color(0xFFFFA000)],
                ),
                child: const Text('🥇', style: TextStyle(fontSize: 11)),
              ),
              const SizedBox(width: 6),

              // Badge 3: Cyan/Blue Star Shield
              _buildHonorBadge(
                gradient: const LinearGradient(
                  colors: [Color(0xFF00E5FF), Color(0xFF0091EA)],
                ),
                child: const Text('⭐', style: TextStyle(fontSize: 10)),
              ),

              const SizedBox(width: 4),
              const Icon(Icons.chevron_right_rounded, color: Colors.white38, size: 16),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildHonorBadge({required Gradient gradient, required Widget child}) {
    return Container(
      width: 22,
      height: 22,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: gradient,
        boxShadow: const [
          BoxShadow(color: Colors.black45, blurRadius: 4),
        ],
      ),
      child: Center(child: child),
    );
  }

  /// 4. Action Buttons: Edit Profile, Find Friends, Instagram
  Widget _buildActionButtons(
    BuildContext context,
    ProfileController controller,
    dynamic profile,
  ) {
    return Row(
      children: [
        // Edit Profile Button
        Expanded(
          child: GestureDetector(
            onTap: () {
              EditProfileDialog.show(
                context,
                profile: profile,
                onSave: ({
                  required String name,
                  required String username,
                  required String bio,
                  required String aboutMe,
                }) {
                  controller.updateProfile(
                    name: name,
                    username: username,
                    bio: bio,
                    aboutMe: aboutMe,
                  );
                },
              );
            },
            child: Container(
              height: 38,
              decoration: BoxDecoration(
                color: const Color(0xFF252532),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.white12, width: 0.8),
              ),
              child: const Center(
                child: Text(
                  'Edit Profile',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
        ),

        const SizedBox(width: 10),

        // Find Friends Button
        Expanded(
          child: GestureDetector(
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Finding live friends & contacts... 👥'),
                  duration: Duration(seconds: 1),
                ),
              );
            },
            child: Container(
              height: 38,
              decoration: BoxDecoration(
                color: const Color(0xFF252532),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.white12, width: 0.8),
              ),
              child: const Center(
                child: Text(
                  'Find Friends',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
        ),

        const SizedBox(width: 10),

        // Instagram Icon Button
        GestureDetector(
          onTap: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Opening @rohit_rajdhani66 on Instagram 📸'),
                duration: Duration(seconds: 1),
              ),
            );
          },
          child: Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: const Color(0xFF252532),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Colors.white12, width: 0.8),
            ),
            child: const Icon(
              Icons.camera_alt_outlined,
              color: Colors.white,
              size: 20,
            ),
          ),
        ),
      ],
    );
  }

  /// 5. Tiki Star / Angels / Family RS TECH Banner
  Widget _buildTikiStarAngelsFamilyBanner(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFF1B1A28),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withValues(alpha: 0.08), width: 0.8),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // 1. Tiki Star Section (Opens Tiki Verification Roadmap)
          GestureDetector(
            onTap: () => TikiVerificationSheet.show(context),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 28,
                  height: 28,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white10,
                  ),
                  child: const Center(
                    child: Text('🌟', style: TextStyle(fontSize: 14)),
                  ),
                ),
                const SizedBox(width: 6),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: const [
                    Text(
                      'Tiki Star',
                      style: TextStyle(color: Colors.white54, fontSize: 9.5),
                    ),
                    Text(
                      'No.500+',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Divider
          Container(width: 1, height: 26, color: Colors.white12),

          // 2. Angels Section with Yellow Share Button
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'Angels',
                    style: TextStyle(color: Colors.white54, fontSize: 9.5),
                  ),
                  const SizedBox(height: 2),
                  SizedBox(
                    width: 38,
                    height: 18,
                    child: Stack(
                      children: const [
                        Positioned(
                          left: 0,
                          child: CustomAvatar(
                            radius: 8,
                            assetPath: AppAssets.status2,
                            alignment: Alignment(0.0, -0.65),
                          ),
                        ),
                        Positioned(
                          left: 12,
                          child: CustomAvatar(
                            radius: 8,
                            assetPath: AppAssets.status3,
                            alignment: Alignment(0.0, -0.65),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 8),
              // Yellow Share Pill Button
              GestureDetector(
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Sharing Rohit Rajdhani profile link! ✨'),
                      duration: Duration(seconds: 1),
                    ),
                  );
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFD700),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: const Text(
                    'Share',
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 10.5,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
              ),
            ],
          ),

          // Divider
          Container(width: 1, height: 26, color: Colors.white12),

          // 3. Family RS TECH Section (Opens FamilyTeamScreen)
          GestureDetector(
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const FamilyTeamScreen()),
              );
            },
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 28,
                  height: 28,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.black87,
                  ),
                  child: const Center(
                    child: Text('🛡️', style: TextStyle(fontSize: 13)),
                  ),
                ),
                const SizedBox(width: 6),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: const [
                    Text(
                      'Family',
                      style: TextStyle(color: Colors.white54, fontSize: 9.5),
                    ),
                    Text(
                      'RS TECH',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// 6. Content Tabs: Videos 411 (with active yellow underline) and Likes 39637
  Widget _buildContentTabs() {
    return Column(
      children: [
        Row(
          children: [
            // Videos 411 Tab
            Expanded(
              child: GestureDetector(
                onTap: () => setState(() => _selectedTab = 0),
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  color: Colors.transparent,
                  child: Column(
                    children: [
                      Text(
                        'Videos 411',
                        style: TextStyle(
                          color: _selectedTab == 0 ? Colors.white : Colors.white54,
                          fontSize: 14,
                          fontWeight: _selectedTab == 0 ? FontWeight.w900 : FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 6),
                      // Active Yellow Bar Indicator
                      if (_selectedTab == 0)
                        Container(
                          width: 38,
                          height: 3,
                          decoration: BoxDecoration(
                            color: const Color(0xFFFFD700),
                            borderRadius: BorderRadius.circular(2),
                          ),
                        )
                      else
                        const SizedBox(height: 3),
                    ],
                  ),
                ),
              ),
            ),

            // Likes 39637 Tab
            Expanded(
              child: GestureDetector(
                onTap: () => setState(() => _selectedTab = 1),
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  color: Colors.transparent,
                  child: Column(
                    children: [
                      Text(
                        'Likes 39637',
                        style: TextStyle(
                          color: _selectedTab == 1 ? Colors.white : Colors.white54,
                          fontSize: 14,
                          fontWeight: _selectedTab == 1 ? FontWeight.w900 : FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 6),
                      if (_selectedTab == 1)
                        Container(
                          width: 38,
                          height: 3,
                          decoration: BoxDecoration(
                            color: const Color(0xFFFFD700),
                            borderRadius: BorderRadius.circular(2),
                          ),
                        )
                      else
                        const SizedBox(height: 3),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
        Container(height: 0.5, color: Colors.white12),
      ],
    );
  }

  /// 7. 3-Column Video Grid matching Screenshot
  Widget _buildVideosGrid(BuildContext context) {
    if (_selectedTab == 1) {
      // Likes tab empty state
      return Container(
        padding: const EdgeInsets.symmetric(vertical: 60),
        alignment: Alignment.center,
        child: Column(
          children: const [
            Icon(Icons.favorite_rounded, color: Color(0xFFFF2D55), size: 40),
            SizedBox(height: 10),
            Text(
              '39,637 Liked Videos by Rohit',
              style: TextStyle(color: Colors.white70, fontSize: 13),
            ),
          ],
        ),
      );
    }

    final videoItems = [
      // 0: Drafts Card (with Tiki yellow logo box & Drafts 1 video)
      {
        'isDraft': true,
        'title': 'Drafts',
        'subtitle': '1 video',
        'caption': 'Motivational',
        'asset': AppAssets.status1,
      },
      // 1: Pinned Video 1 (caption overlay + 4926 views)
      {
        'isPinned': true,
        'views': '4926',
        'caption': 'Official Host Notification',
        'asset': AppAssets.status1,
      },
      // 2: Pinned Video 2 (corner card + 6.3K views)
      {
        'isPinned': true,
        'views': '6.3K',
        'caption': 'Live Stream Highlights',
        'asset': AppAssets.status2,
      },
      // 3: Pinned Video 3 (2.8K views)
      {
        'isPinned': true,
        'views': '2.8K',
        'caption': 'Voice Room Special',
        'asset': AppAssets.status3,
      },
      // 4: Video 4 (8.1K views)
      {
        'views': '8.1K',
        'caption': 'Weekend PK Battle',
        'asset': AppAssets.status4,
      },
      // 5: Video 5 (5.4K views)
      {
        'views': '5.4K',
        'caption': 'TaalMil All-Stars',
        'asset': AppAssets.status5,
      },
      // 6: Video 6 (12.3K views)
      {
        'views': '12.3K',
        'caption': 'Late Night Live',
        'asset': AppAssets.liveCard1,
      },
      // 7: Video 7 (3.9K views)
      {
        'views': '3.9K',
        'caption': 'Top Diamonds Winner',
        'asset': AppAssets.liveCard2,
      },
      // 8: Video 8 (15.1K views)
      {
        'views': '15.1K',
        'caption': 'Supercar Gift Celebration',
        'asset': AppAssets.status1,
      },
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 2),
      itemCount: videoItems.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        childAspectRatio: 0.73,
        crossAxisSpacing: 2.5,
        mainAxisSpacing: 2.5,
      ),
      itemBuilder: (context, index) {
        final item = videoItems[index];
        final isDraft = item['isDraft'] == true;
        final isPinned = item['isPinned'] == true;
        final asset = item['asset'] as String;

        return GestureDetector(
          onTap: () {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  isDraft
                      ? 'Opening Drafts video folder'
                      : 'Playing video: ${item['caption']} (${item['views']} views) ▶️',
                ),
                duration: const Duration(seconds: 1),
              ),
            );
          },
          child: Stack(
            fit: StackFit.expand,
            children: [
              // Background Video Cover Image
              Image.asset(
                asset,
                fit: BoxFit.cover,
                cacheWidth: 350,
              ),

              // Gradient Scrim
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.transparent,
                      Colors.black.withValues(alpha: isDraft ? 0.75 : 0.45),
                    ],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    stops: const [0.55, 1.0],
                  ),
                ),
              ),

              // Top-Left "Pinned" Badge
              if (isPinned)
                Positioned(
                  top: 6,
                  left: 6,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.65),
                      borderRadius: BorderRadius.circular(4),
                      border: Border.all(color: Colors.white24, width: 0.5),
                    ),
                    child: const Text(
                      'Pinned',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 9.5,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),

              // Drafts Special Content Card
              if (isDraft) ...[
                Positioned.fill(
                  child: Container(
                    color: Colors.black45,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                        Text(
                          'Drafts',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        SizedBox(height: 2),
                        Text(
                          '1 video',
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 10.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                // Yellow Tiki Icon Box on bottom left
                Positioned(
                  bottom: 6,
                  left: 6,
                  child: Container(
                    width: 18,
                    height: 18,
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFD700),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: const Center(
                      child: Text(
                        'T',
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 11,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                  ),
                ),
              ],

              // Bottom-Left Views Count (Play icon + view count)
              if (!isDraft && item['views'] != null)
                Positioned(
                  bottom: 6,
                  left: 6,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.play_arrow_rounded,
                        color: Colors.white,
                        size: 15,
                      ),
                      const SizedBox(width: 2),
                      Text(
                        item['views'] as String,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10.5,
                          fontWeight: FontWeight.bold,
                          shadows: [
                            Shadow(color: Colors.black87, blurRadius: 4),
                          ],
                        ),
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

  void _showProfileMenuOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) {
        return Container(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.sizeOf(ctx).height * 0.85,
          ),
          decoration: const BoxDecoration(
            color: Color(0xFF101018),
            borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
            border: Border(top: BorderSide(color: Color(0x66FF2D78), width: 1.5)),
            boxShadow: [
              BoxShadow(color: Color(0x33FF2D78), blurRadius: 28, spreadRadius: -2),
            ],
          ),
          child: SafeArea(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(height: 12),
                Container(
                  width: 38,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.white24,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(height: 16),

                // User Identity Header from Images 2 & 3
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(2),
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: LinearGradient(
                            colors: [Color(0xFFFF2D78), Color(0xFFBA43F6)],
                          ),
                        ),
                        child: const CustomAvatar(
                          radius: 22,
                          assetPath: AppAssets.status4,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: const [
                            Text(
                              'Jayachandran',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(height: 2),
                            Text(
                              '@jayachandran_official',
                              style: TextStyle(
                                color: Colors.white54,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                      GestureDetector(
                        onTap: () => Navigator.pop(ctx),
                        child: const Icon(Icons.close_rounded, color: Colors.white70, size: 22),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 16),
                const Divider(color: Colors.white10, height: 1),

                // Options List
                Expanded(
                  child: ListView(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    children: [
                      _buildMenuItem(
                        icon: Icons.person_outline_rounded,
                        iconColor: const Color(0xFF82B1FF),
                        title: 'My Profile',
                        onTap: () => Navigator.pop(ctx),
                      ),
                      _buildMenuItem(
                        icon: Icons.insights_rounded,
                        iconColor: const Color(0xFFFFD600),
                        title: 'Creator Tools',
                        subtitle: 'Analytics, LIVE Center, Monetization',
                        onTap: () {
                          Navigator.pop(ctx);
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('📊 Creator Tools & Analytics'), duration: Duration(seconds: 1)),
                          );
                        },
                      ),
                      _buildMenuItem(
                        icon: Icons.account_balance_wallet_rounded,
                        iconColor: const Color(0xFFFF9100),
                        title: 'Wallet / Balance',
                        subtitle: 'Diamonds, Coins, Stars',
                        onTap: () {
                          Navigator.pop(ctx);
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('💎 Wallet: 6,850 Diamonds • 120 Stars'), duration: Duration(seconds: 1)),
                          );
                        },
                      ),
                      _buildMenuItem(
                        icon: Icons.shopping_bag_outlined,
                        iconColor: const Color(0xFFBA43F6),
                        title: 'Tiki Shop',
                        onTap: () {
                          Navigator.pop(ctx);
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('🛍️ Tiki Official Merchandise Shop'), duration: Duration(seconds: 1)),
                          );
                        },
                      ),
                      _buildMenuItem(
                        icon: Icons.military_tech_outlined,
                        iconColor: const Color(0xFFFFD600),
                        title: 'My Level & Rewards',
                        onTap: () {
                          Navigator.pop(ctx);
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('👑 Level 10 Host • SVIP Badge Active'), duration: Duration(seconds: 1)),
                          );
                        },
                      ),
                      _buildMenuItem(
                        icon: Icons.groups_rounded,
                        iconColor: const Color(0xFFFF80AB),
                        title: 'Family / Team',
                        onTap: () {
                          Navigator.pop(ctx);
                          Navigator.of(context).push(
                            MaterialPageRoute(builder: (_) => const FamilyTeamScreen()),
                          );
                        },
                      ),
                      _buildMenuItem(
                        icon: Icons.qr_code_rounded,
                        iconColor: const Color(0xFF00E5FF),
                        title: 'My QR Code',
                        onTap: () {
                          Navigator.pop(ctx);
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('🔲 Scan to follow Jayachandran'), duration: Duration(seconds: 1)),
                          );
                        },
                      ),
                      _buildMenuItem(
                        icon: Icons.bookmark_border_rounded,
                        iconColor: const Color(0xFF69F0AE),
                        title: 'Saved Videos',
                        onTap: () {
                          Navigator.pop(ctx);
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('🔖 24 Bookmarked Videos'), duration: Duration(seconds: 1)),
                          );
                        },
                      ),
                      _buildMenuItem(
                        icon: Icons.access_time_rounded,
                        iconColor: const Color(0xFF40C4FF),
                        title: 'Your Activity',
                        onTap: () {
                          Navigator.pop(ctx);
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('⏱️ Daily Watch Time: 1h 45m'), duration: Duration(seconds: 1)),
                          );
                        },
                      ),
                      _buildMenuItem(
                        icon: Icons.settings_outlined,
                        iconColor: Colors.white70,
                        title: 'Settings & Privacy',
                        subtitle: 'AI Content Moderation, Privacy, Account',
                        onTap: () {
                          Navigator.pop(ctx);
                          Navigator.of(context).push(
                            MaterialPageRoute(builder: (_) => const SettingsScreen()),
                          );
                        },
                      ),
                      _buildMenuItem(
                        icon: Icons.help_outline_rounded,
                        iconColor: Colors.white70,
                        title: 'Help & Support',
                        onTap: () {
                          Navigator.pop(ctx);
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('❓ 24/7 Creator Help Center'), duration: Duration(seconds: 1)),
                          );
                        },
                      ),
                    ],
                  ),
                ),

                // Tiki Premium Upgrade Banner matching Image 2 & 3
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF2E124D), Color(0xFF1E0E33)],
                      ),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: const Color(0x66BA43F6)),
                    ),
                    child: Row(
                      children: [
                        const Text('👑', style: TextStyle(fontSize: 22)),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: const [
                              Text(
                                'Tiki Premium',
                                style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold),
                              ),
                              Text(
                                'Unlock exclusive VIP gifts & 4K video streams',
                                style: TextStyle(color: Colors.white60, fontSize: 10.5),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Color(0xFFFF2D78), Color(0xFFFF0055)],
                            ),
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: const Text(
                            'Upgrade',
                            style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required Color iconColor,
    required String title,
    String? subtitle,
    required VoidCallback onTap,
  }) {
    return ListTile(
      dense: true,
      contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 1),
      leading: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: iconColor.withValues(alpha: 0.14),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: iconColor, size: 20),
      ),
      title: Text(
        title,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 14,
          fontWeight: FontWeight.w600,
        ),
      ),
      subtitle: subtitle != null
          ? Text(
              subtitle,
              style: const TextStyle(color: Colors.white54, fontSize: 11),
            )
          : null,
      trailing: const Icon(Icons.arrow_forward_ios_rounded, color: Colors.white24, size: 14),
      onTap: onTap,
    );
  }
}
