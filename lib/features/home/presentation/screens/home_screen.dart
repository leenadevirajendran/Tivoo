import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../controllers/home_controller.dart';
import '../widgets/home_header.dart';
import '../widgets/popular_taalmil_view.dart';
import 'chat_room_party_screen.dart';
import 'pk_battle_live_screen.dart';

/// Main Tivoo Home Screen with 3 Category Tabs:
/// - Live: 2-column stream grid matching Images 1 & 2
/// - PK Battle: Competition arena with 10m/20m timer, invite, score clash bar, top star MVPs, win/loss
/// - Chat Room: Audio Party (9 seats) & Video Party (6 member slots fully visible with zero cut-off)
class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  int _selectedTabIndex = 0; // 0 = Live, 1 = PK Battle, 2 = Chat Room

  void _navigateToTab(int index) {
    if (index == 1) {
      // PK Battle tab clicked: navigate to dedicated full-screen PK Battle Live Screen!
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => PkBattleLiveScreen(
            onBack: () => Navigator.of(context).pop(),
          ),
        ),
      );
      return;
    }
    if (index == 2) {
      // Chat Room tab clicked: navigate to dedicated full-screen Chat Room Party Screen!
      // This ensures 100% full screen with no overlapping home header and no bottom nav bar!
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => ChatRoomPartyScreen(
            initialStage: 1,
            onBack: () => Navigator.of(context).pop(),
          ),
        ),
      );
      return;
    }
    // Live (0) is the default home stream feed
    if (_selectedTabIndex != index) {
      setState(() => _selectedTabIndex = index);
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(homeControllerProvider);
    final displayStreams = state.allStreams;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          // Home Feed: Live Stream Grid
          Positioned.fill(
            child: PopularTaalmilView(streams: displayStreams),
          ),

          // 2. Floating Top Header with Tabs (Live, PK Battle, Chat Room)
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Color(0xF2000000),
                    Color(0xB3000000),
                    Colors.transparent,
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  stops: [0.0, 0.75, 1.0],
                ),
              ),
              child: SafeArea(
                bottom: false,
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 6),
                  child: HomeHeader(
                    selectedIndex: _selectedTabIndex,
                    onIndexChanged: _navigateToTab,
                    onSearchTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Search live streamers, topics & rooms'),
                          duration: Duration(seconds: 1),
                        ),
                      );
                    },
                    onFavoritesTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Favorite streamers list'),
                          duration: Duration(seconds: 1),
                        ),
                      );
                    },
                    onHistoryTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Watch history'),
                          duration: Duration(seconds: 1),
                        ),
                      );
                    },
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
