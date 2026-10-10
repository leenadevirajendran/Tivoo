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

  group('Star Throne Specifications & Audio Asset Tests', () {
    test('MockLiveComments includes Star Throne with 5,000 Stars matching user reference', () {
      final throne = MockLiveComments.virtualGifts.firstWhere((g) => g.id == 'gift_ani4_throne');
      expect(throne.name, 'Star Throne');
      expect(throne.diamonds, 5000);
      expect(throne.imageAssetPath, AppAssets.starThroneActor);
    });

    test('Star Throne image assets exist on disk', () {
      expect(File('assets/gifts/star_throne_hero.jpg').existsSync(), isTrue);
      expect(File('assets/gifts/star_throne_actor.png').existsSync(), isTrue);
      expect(File('assets/gifts/star_throne_rune.jpg').existsSync(), isTrue);
      expect(File('assets/gift_star_throne.png').existsSync(), isTrue);
      expect(File('assets/Ani4.png').existsSync(), isTrue);
    });

    test('GiftSoundService defines Star Throne online audio and local sound files', () {
      expect(GiftSoundService.onlineStarThroneAudioUrl, isNotEmpty);
      expect(GiftSoundService.onlineStarThroneAudioUrl, contains('wikimedia.org'));
      expect(File('assets/sounds/sound_throne.wav').existsSync(), isTrue);
      expect(File('assets/sounds/sound_throne_1_starfall.wav').existsSync(), isTrue);
      expect(File('assets/sounds/sound_throne_2_swirl.wav').existsSync(), isTrue);
      expect(File('assets/sounds/sound_throne_3_sacred.wav').existsSync(), isTrue);
      expect(File('assets/sounds/sound_throne_4_rise.wav').existsSync(), isTrue);
      expect(File('assets/sounds/sound_throne_5_choir.wav').existsSync(), isTrue);
      expect(File('assets/sounds/sound_throne_6_glow.wav').existsSync(), isTrue);
    });
  });

  group('Star Throne 10s Animation Sequence Widget Tests', () {
    testWidgets('Plays all 6 stages of Star Throne with 5,000 Stars score impact',
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

      final throneGift = GiftItem(
        id: 'gift_ani4_throne',
        name: 'Star Throne',
        icon: '👑',
        imageAssetPath: AppAssets.starThroneActor,
        diamonds: 5000,
      );

      key.currentState?.playGift(throneGift, senderName: 'Ravi', count: 1);
      await tester.pump();

      expect(find.byType(ActiveGiftAnimationOverlay), findsOneWidget);

      // Stage 1: Star Descent (0 - 1.5s)
      await tester.pump(const Duration(milliseconds: 700));
      expect(find.text('1. Star Descent • Radiant Stardust Trail'), findsOneWidget);
      expect(find.text('5,000 ⭐'), findsOneWidget);
      expect(find.text('Ravi sent Star Throne x1'), findsOneWidget);

      // Stage 2: Energy Spiral (1.5 - 3.0s)
      await tester.pump(const Duration(milliseconds: 1400));
      expect(find.text('2. Energy Spiral • Cosmic Energy Waves'), findsOneWidget);

      // Stage 3: Throne Formation (3.0 - 5.0s)
      await tester.pump(const Duration(milliseconds: 1800));
      expect(find.text('3. Throne Formation • Golden Rune & Pillars'), findsOneWidget);

      // Stage 4: Rise to Power (5.0 - 7.0s)
      await tester.pump(const Duration(milliseconds: 2000));
      expect(find.text('4. Rise to Power • Celestial Rings & Glow'), findsOneWidget);

      // Stage 5: Royal Accession (7.0 - 9.0s) & Score Impact (5,000 Stars)
      await tester.pump(const Duration(milliseconds: 1600));
      expect(find.text('5. Royal Accession • Majestic Wings & Star Crown'), findsOneWidget);
      expect(find.text('+5000 Stars Impact!'), findsOneWidget);
      expect(scoreImpactPoints, 5000);

      // Stage 6: Final Glow (9.0 - 10.0s)
      await tester.pump(const Duration(milliseconds: 1800));
      expect(find.text('6. Final Glow • Lasting Star Radiance'), findsOneWidget);

      // Settle
      await tester.pump(const Duration(milliseconds: 1500));
    });
  });
}
