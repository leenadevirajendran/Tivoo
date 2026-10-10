import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tivoo/core/constants/app_assets.dart';
import 'package:tivoo/features/live_stream/domain/models/gift_item.dart';
import 'package:tivoo/features/live_stream/presentation/widgets/active_gift_animation_overlay.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('Golden Horse 10s 3D animation sequence initializes and renders correctly', (WidgetTester tester) async {
    final key = GlobalKey<ActiveGiftAnimationOverlayState>();

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ActiveGiftAnimationOverlay(
            key: key,
            onScoreImpact: ({required bool toLeft, required int points}) {},
            child: const SizedBox(width: 400, height: 800),
          ),
        ),
      ),
    );

    // Trigger Golden Horse Gift
    final horseGift = GiftItem(
      id: 'ani2_golden_horse',
      name: 'Golden Horse',
      icon: '🐎',
      imageAssetPath: AppAssets.ani2,
      diamonds: 1000,
    );

    key.currentState?.playGift(horseGift, senderName: 'Arjun', count: 1);
    await tester.pump();

    // Verify horse is active
    expect(find.byType(ActiveGiftAnimationOverlay), findsOneWidget);

    // Pump to 1.0s (Stage 1: Golden Particles Emerge)
    await tester.pump(const Duration(milliseconds: 1000));
    expect(find.text('✦ 1. Golden Particles Emerge'), findsOneWidget);

    // Pump to 2.0s (Stage 2: Horse Forms)
    await tester.pump(const Duration(milliseconds: 1000));
    expect(find.text('✦ 2. Horse Forms'), findsOneWidget);

    // Pump to 3.5s (Stage 3: Detailed Formation)
    await tester.pump(const Duration(milliseconds: 1500));
    expect(find.text('✦ 3. Detailed Formation'), findsOneWidget);

    // Pump to 5.0s (Stage 4: Graceful Movement & Top Banner appears)
    await tester.pump(const Duration(milliseconds: 1500));
    expect(find.text('✦ 4. Graceful Movement'), findsOneWidget);
    expect(find.text('Arjun sent'), findsOneWidget);
    expect(find.text('Golden Horse'), findsOneWidget);

    // Pump to 7.5s (Stage 5: Cinematic Showcase)
    await tester.pump(const Duration(milliseconds: 2500));
    expect(find.text('✦ 5. Cinematic Showcase'), findsOneWidget);

    // Pump to 9.2s (Stage 6: Final Pose)
    await tester.pump(const Duration(milliseconds: 1700));
    expect(find.text('✦ 6. Final Pose'), findsOneWidget);

    // Complete 10s animation
    await tester.pump(const Duration(milliseconds: 1000));
  });
}
