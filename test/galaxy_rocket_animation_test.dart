import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tivoo/core/constants/app_assets.dart';
import 'package:tivoo/features/live_stream/domain/models/gift_item.dart';
import 'package:tivoo/features/live_stream/presentation/widgets/active_gift_animation_overlay.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('Galaxy Rocket 10s 3D animation sequence initializes and tests all 6 stages',
      (WidgetTester tester) async {
    final key = GlobalKey<ActiveGiftAnimationOverlayState>();
    int scoreImpactPoints = 0;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ActiveGiftAnimationOverlay(
            key: key,
            onScoreImpact: ({required bool toLeft, required int points}) {
              scoreImpactPoints = points;
            },
            child: const SizedBox(width: 400, height: 800),
          ),
        ),
      ),
    );

    // Trigger Galaxy Rocket Gift
    final rocketGift = GiftItem(
      id: 'ani6_galaxy_rocket',
      name: 'Galaxy Rocket',
      icon: '🚀',
      imageAssetPath: AppAssets.galaxyRocketHero,
      diamonds: 1000,
    );

    key.currentState?.playGift(rocketGift, senderName: 'Ravi', count: 1);
    await tester.pump();

    // Verify ActiveGiftAnimationOverlay is present
    expect(find.byType(ActiveGiftAnimationOverlay), findsOneWidget);

    // Stage 1: Rocket Ignition (0 - 1.5s)
    await tester.pump(const Duration(milliseconds: 1000));
    expect(find.text('✦ 1. Rocket Ignition (0 - 1.5s)'), findsOneWidget);

    // Stage 2: Lift Off (1.5 - 3s)
    await tester.pump(const Duration(milliseconds: 1000));
    expect(find.text('✦ 2. Lift Off (1.5 - 3s)'), findsOneWidget);

    // Stage 3: Sky Journey (3 - 5s)
    await tester.pump(const Duration(milliseconds: 1500));
    expect(find.text('✦ 3. Sky Journey (3 - 5s)'), findsOneWidget);

    // Stage 4: Galaxy Travel (5 - 7s) & Top Banner verification
    await tester.pump(const Duration(milliseconds: 1500));
    expect(find.text('✦ 4. Galaxy Travel (5 - 7s)'), findsOneWidget);
    expect(find.text('Ravi sent'), findsOneWidget);
    expect(find.text('Galaxy Rocket'), findsOneWidget);
    expect(find.text('POWER & BEYOND'), findsOneWidget);

    // Stage 5: Cosmic Burst (7 - 9s) & Score Impact verification
    await tester.pump(const Duration(milliseconds: 2000));
    expect(find.text('✦ 5. Cosmic Burst (7 - 9s)'), findsOneWidget);
    expect(scoreImpactPoints, 1000);

    // Stage 6: Final Pose (9 - 10s)
    await tester.pump(const Duration(milliseconds: 2000));
    expect(find.text('✦ 6. Final Pose (9 - 10s)'), findsOneWidget);

    // Complete remaining animation
    await tester.pump(const Duration(milliseconds: 1500));
  });
}
