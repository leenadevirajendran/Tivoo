import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tivoo/core/constants/app_assets.dart';
import 'package:tivoo/features/live_stream/data/mock_live_comments.dart';
import 'package:tivoo/features/live_stream/domain/models/gift_item.dart';
import 'package:tivoo/features/live_stream/presentation/widgets/active_gift_animation_overlay.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('MockLiveComments includes Golden Lion gift matching storyboard specifications', () {
    final lion = MockLiveComments.virtualGifts.firstWhere((g) => g.id == 'gift_golden_lion');
    expect(lion.name, 'Golden Lion');
    expect(lion.diamonds, 5000);
    expect(lion.icon, '🦁');
    expect(lion.imageAssetPath, AppAssets.goldenLionHero);
  });

  testWidgets('Golden Lion 10s 3D animation sequence initializes and tests all 6 stages',
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

    // Trigger Golden Lion Gift
    final lionGift = GiftItem(
      id: 'gift_golden_lion',
      name: 'Golden Lion',
      icon: '🦁',
      imageAssetPath: AppAssets.goldenLionHero,
      diamonds: 5000,
    );

    key.currentState?.playGift(lionGift, senderName: 'Anju', count: 1);
    await tester.pump();

    // Verify ActiveGiftAnimationOverlay is present
    expect(find.byType(ActiveGiftAnimationOverlay), findsOneWidget);

    // Stage 1: Golden Particles Emerge (0 - 1.5s)
    await tester.pump(const Duration(milliseconds: 1000));
    expect(find.text('✦ 1. Golden Particles Emerge (0 - 1.5s)'), findsOneWidget);

    // Stage 2: Lion Takes Shape (1.5 - 3s)
    await tester.pump(const Duration(milliseconds: 1000));
    expect(find.text('✦ 2. Lion Takes Shape (1.5 - 3s)'), findsOneWidget);

    // Stage 3: Powerful Movement (3 - 5s)
    await tester.pump(const Duration(milliseconds: 1500));
    expect(find.text('✦ 3. Powerful Movement (3 - 5s)'), findsOneWidget);

    // Stage 4: Roar Effect (5 - 7s) & Top Banner verification
    await tester.pump(const Duration(milliseconds: 1500));
    expect(find.text('✦ 4. Roar Effect (5 - 7s)'), findsOneWidget);
    expect(find.text('Anju sent'), findsOneWidget);
    expect(find.text('Golden Lion'), findsOneWidget);
    expect(find.text('5,000 ⭐'), findsOneWidget);
    expect(find.text('POWER & COURAGE'), findsOneWidget);
    expect(scoreImpactPoints, 5000);

    // Stage 5: Cinematic Showcase (7 - 9s)
    await tester.pump(const Duration(milliseconds: 2000));
    expect(find.text('✦ 5. Cinematic Showcase (7 - 9s)'), findsOneWidget);

    // Stage 6: Final Pose (9 - 10s)
    await tester.pump(const Duration(milliseconds: 2000));
    expect(find.text('✦ 6. Final Pose (9 - 10s)'), findsOneWidget);

    // Complete remaining animation
    await tester.pump(const Duration(milliseconds: 1500));
  });
}
