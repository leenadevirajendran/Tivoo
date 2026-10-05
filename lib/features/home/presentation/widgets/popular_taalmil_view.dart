import 'package:flutter/material.dart';
import '../../../live_stream/presentation/screens/live_stream_screen.dart';
import '../../domain/models/live_stream_card_model.dart';
import '../screens/pk_battle_live_screen.dart';
import 'home_grid_stream_card.dart';

/// Popular view strictly matching the reference design in Screenshot 1 (TaalMil style):
/// - Mini Broadcasters row (`aashi 🔥140`, `payal 🔥133`)
/// - WEEKLY ALL-STARS gold crown event banner with indicator dots
/// - 2-Column Live Stream cards grid (no Star/Gift on cards)
/// - Floating live broadcast circle button on the bottom right
class PopularTaalmilView extends StatelessWidget {
  final List<LiveStreamCardModel> streams;
  final VoidCallback? onBroadcastTap;

  const PopularTaalmilView({
    super.key,
    required this.streams,
    this.onBroadcastTap,
  });

  @override
  Widget build(BuildContext context) {
    final topPadding = MediaQuery.paddingOf(context).top + 112;
    // Main Virtualized 2-Column Live Stream Grid directly below header tabs
    return _buildLiveGrid(context, topPadding);
  }

  /// 2-Column Live Streams Grid matching Screenshot 1
  Widget _buildLiveGrid(BuildContext context, double topPadding) {
    if (streams.isEmpty) {
      return Center(
        child: Padding(
          padding: EdgeInsets.only(top: topPadding + 40, left: 40, right: 40),
          child: const Text(
            'No live broadcasts right now',
            style: TextStyle(color: Colors.white54),
          ),
        ),
      );
    }

    return GridView.builder(
      physics: const BouncingScrollPhysics(),
      padding: EdgeInsets.fromLTRB(12, topPadding, 12, 110),
      itemCount: streams.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.72, // Tall portrait aspect ratio matching Screenshot 1
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
      ),
      itemBuilder: (context, index) {
        final stream = streams[index];
        return HomeGridStreamCard(
          stream: stream,
          onTap: () {
            if (stream.isPk) {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => PkBattleLiveScreen(
                    onBack: () => Navigator.of(context).pop(),
                  ),
                ),
              );
              return;
            }
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => LiveStreamScreen(
                  streams: streams,
                  initialIndex: index,
                ),
              ),
            );
          },
        );
      },
    );
  }
}
