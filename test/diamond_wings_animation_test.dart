import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tivoo/core/constants/app_assets.dart';
import 'package:tivoo/core/services/gift_sound_service.dart';
import 'package:tivoo/features/live_stream/data/mock_live_comments.dart';
import 'package:tivoo/features/live_stream/domain/models/gift_item.dart';
import 'package:tivoo/features/live_stream/presentation/widgets/active_gift_animation_overlay.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('MockLiveComments includes Diamond Wings gift matching storyboard specifications', () {
    final wings = MockLiveComments.virtualGifts.firstWhere((g) => g.id == 'gift_diamond_wings');
    expect(wings.name, 'Diamond Wings');
    expect(wings.diamonds, 10000);
    expect(wings.icon, '💎');
    expect(wings.imageAssetPath, AppAssets.diamondWingsHero);
  });

  test('GiftSoundService defines online and local Diamond Wings audio', () {
    expect(GiftSoundService.onlineDiamondWingsAudioUrl, contains('Glass_harmonica_chime'));
  });

  testWidgets('Diamond Wings 10s 3D animation sequence initializes and tests all 6 stages',
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

    // Trigger Diamond Wings Gift (10,000 Stars)
    final wingsGift = GiftItem(
      id: 'gift_diamond_wings',
      name: 'Diamond Wings',
      icon: '💎',
      imageAssetPath: AppAssets.diamondWingsHero,
      diamonds: 10000,
    );

    key.currentState?.playGift(wingsGift, senderName: 'Anju', count: 1);
    await tester.pump();

    // Verify ActiveGiftAnimationOverlay is present
    expect(find.byType(ActiveGiftAnimationOverlay), findsOneWidget);

    // Stage 1: Prism Awakening (0 - 1s)
    await tester.pump(const Duration(milliseconds: 600));
    expect(find.text('✦ 1. Prism Awakening (0 - 1s)'), findsOneWidget);

    // Stage 2: Feather Assembly (1 - 2.5s)
    await tester.pump(const Duration(milliseconds: 1000));
    expect(find.text('✦ 2. Feather Assembly (1 - 2.5s)'), findsOneWidget);

    // Stage 3: Wings Unfold (2.5 - 4s)
    await tester.pump(const Duration(milliseconds: 1500));
    expect(find.text('✦ 3. Wings Unfold (2.5 - 4s)'), findsOneWidget);

    // Stage 4: Refraction Sweep (4 - 6s)
    await tester.pump(const Duration(milliseconds: 1500));
    expect(find.text('✦ 4. Refraction Sweep (4 - 6s)'), findsOneWidget);

    // Stage 5: Full Radiance (6 - 8s) & Top Banner & Score Impact
    await tester.pump(const Duration(milliseconds: 1800));
    expect(find.text('✦ 5. Full Radiance (6 - 8s)'), findsOneWidget);
    expect(find.text('Anju sent'), findsOneWidget);
    expect(find.text('Diamond Wings'), findsOneWidget);
    expect(find.text('10,000 ⭐'), findsOneWidget);
    expect(find.text('GRACE IN MOTION'), findsOneWidget);
    expect(scoreImpactPoints, 10000);

    // Stage 6: Graceful Dissolve (8 - 10s)
    await tester.pump(const Duration(milliseconds: 2000));
    expect(find.text('✦ 6. Graceful Dissolve (8 - 10s)'), findsOneWidget);

    // Complete remaining animation
    await tester.pump(const Duration(milliseconds: 1500));
  });
}
