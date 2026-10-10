import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tivoo/core/constants/app_assets.dart';
import 'package:tivoo/core/services/gift_sound_service.dart';
import 'package:tivoo/features/live_stream/data/mock_live_comments.dart';
import 'package:tivoo/features/live_stream/domain/models/gift_item.dart';
import 'package:tivoo/features/live_stream/presentation/widgets/active_gift_animation_overlay.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Luxury Yacht Specifications & Rose Carriage Removal Tests', () {
    test('MockLiveComments includes Luxury Yacht with 5,000 Stars', () {
      final yacht = MockLiveComments.virtualGifts.firstWhere((g) => g.id == 'gift_yacht');
      expect(yacht.name, 'Luxury Yacht');
      expect(yacht.diamonds, 5000);
      expect(yacht.imageAssetPath, AppAssets.luxuryYachtActor);
    });

    test('MockLiveComments does NOT contain Rose Carriage', () {
      final hasCarriage = MockLiveComments.virtualGifts.any(
        (g) => g.id == 'gift_ani8_carriage' || g.name.toLowerCase().contains('carriage'),
      );
      expect(hasCarriage, isFalse);
    });

    test('GiftSoundService defines Luxury Yacht online audio and playback assets', () {
      expect(GiftSoundService.onlineLuxuryYachtAudioUrl, isNotEmpty);
      expect(GiftSoundService.onlineLuxuryYachtAudioUrl, contains('wikimedia.org'));
      expect(File('assets/sounds/sound_yacht.wav').existsSync(), isTrue);
    });
  });

  group('Luxury Yacht 10s Animation Sequence Widget Tests', () {
    testWidgets('Plays all 6 stages of Luxury Yacht with 5,000 Stars score impact',
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

      final yachtGift = GiftItem(
        id: 'gift_yacht',
        name: 'Luxury Yacht',
        icon: '🛥️',
        imageAssetPath: AppAssets.luxuryYachtActor,
        diamonds: 5000,
      );

      key.currentState?.playGift(yachtGift, senderName: 'Ravi', count: 1);
      await tester.pump();

      expect(find.byType(ActiveGiftAnimationOverlay), findsOneWidget);

      // Stage 1: Yacht Emerges (0 - 1.5s)
      await tester.pump(const Duration(milliseconds: 700));
      expect(find.text('1. Yacht Emerges • Sparkling Waves'), findsOneWidget);
      expect(find.text('5,000 ⭐'), findsOneWidget);
      expect(find.text('Ravi sent Luxury Yacht'), findsOneWidget);

      // Stage 2: Sail Forward (1.5 - 3.0s)
      await tester.pump(const Duration(milliseconds: 1400));
      expect(find.text('2. Sail Forward • Smooth Water Trail'), findsOneWidget);

      // Stage 3: Grand View (3.0 - 5.0s)
      await tester.pump(const Duration(milliseconds: 1800));
      expect(find.text('3. Grand View • Luxury & Elegance'), findsOneWidget);

      // Stage 4: Fireworks & Sparkles (5.0 - 7.0s)
      await tester.pump(const Duration(milliseconds: 2000));
      expect(find.text('4. Fireworks & Sparkles'), findsOneWidget);

      // Stage 5: Circular Glow (7.0 - 9.0s) & Score Impact (5,000 Stars)
      await tester.pump(const Duration(milliseconds: 1600));
      expect(find.text('5. Circular Glow • Golden Rings'), findsOneWidget);
      expect(find.text('+5000 Stars Impact!'), findsOneWidget);
      expect(scoreImpactPoints, 5000);

      // Stage 6: Final Pose (9.0 - 10.0s)
      await tester.pump(const Duration(milliseconds: 1800));
      expect(find.text('6. Final Pose • Lasting Glow'), findsOneWidget);

      // Settle
      await tester.pump(const Duration(milliseconds: 1500));
    });
  });
}
