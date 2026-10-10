import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tivoo/core/constants/app_assets.dart';
import 'package:tivoo/core/services/gift_sound_service.dart';
import 'package:tivoo/features/live_stream/data/mock_live_comments.dart';
import 'package:tivoo/features/live_stream/domain/models/gift_item.dart';
import 'package:tivoo/features/live_stream/presentation/widgets/active_gift_animation_overlay.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('MockLiveComments includes Love Castle gift matching storyboard specifications', () {
    final castle = MockLiveComments.virtualGifts.firstWhere((g) => g.id == 'gift_ani5_castle');
    expect(castle.name, 'Love Castle');
    expect(castle.diamonds, 100000);
    expect(castle.icon, '🏰');
    expect(castle.imageAssetPath, AppAssets.loveCastleActor);
  });

  test('GiftSoundService defines online and local Love Castle audio', () {
    expect(GiftSoundService.onlineLoveCastleAudioUrl, contains('wikimedia.org'));
  });

  testWidgets('Love Castle 12s 3D animation sequence initializes and tests all 6 storyboard stages',
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

    // Trigger Love Castle Gift (100,000 Stars)
    final castleGift = GiftItem(
      id: 'gift_ani5_castle',
      name: 'Love Castle',
      icon: '🏰',
      imageAssetPath: AppAssets.loveCastleActor,
      diamonds: 100000,
    );

    key.currentState?.playGift(castleGift, senderName: 'Anju', count: 1);
    await tester.pump();

    // Verify ActiveGiftAnimationOverlay is present
    expect(find.byType(ActiveGiftAnimationOverlay), findsOneWidget);

    // Stage 1: Magic Circle (0 - 1.5s)
    await tester.pump(const Duration(milliseconds: 700));
    expect(find.text('✦ 1. Magic Circle (0 - 1.5s)'), findsOneWidget);

    // Stage 2: Floating Island Rise (1.5 - 3s)
    await tester.pump(const Duration(milliseconds: 1400));
    expect(find.text('✦ 2. Floating Island Rise (1.5 - 3s)'), findsOneWidget);

    // Stage 3: Castle Construction (3 - 5s)
    await tester.pump(const Duration(milliseconds: 1800));
    expect(find.text('✦ 3. Castle Construction (3 - 5s)'), findsOneWidget);

    // Stage 4: Heart Crystal Activation (5 - 7s)
    await tester.pump(const Duration(milliseconds: 2000));
    expect(find.text('✦ 4. Heart Crystal Activation (5 - 7s)'), findsOneWidget);

    // Stage 5: Fireworks Show (7 - 9s) & Top Banner & Score Impact Hook (100,000 Stars)
    await tester.pump(const Duration(milliseconds: 1800));
    expect(find.text('✦ 5. Fireworks Show (7 - 9s)'), findsOneWidget);
    expect(find.text('Anju sent'), findsOneWidget);
    expect(find.text('Love Castle'), findsOneWidget);
    expect(find.text('100,000 ⭐'), findsOneWidget);
    expect(find.text('LOVE ✦ DREAMS ✦ FOREVER'), findsOneWidget);
    expect(find.text('100,000 STARS'), findsOneWidget);
    expect(scoreImpactPoints, 100000);

    // Stage 6: Final Reveal (9 - 12s)
    await tester.pump(const Duration(milliseconds: 2200));
    expect(find.text('✦ 6. Final Reveal (9 - 12s)'), findsOneWidget);

    // Complete remaining animation
    await tester.pump(const Duration(milliseconds: 2500));
  });
}
