import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tivoo/core/constants/app_assets.dart';
import 'package:tivoo/core/services/gift_sound_service.dart';
import 'package:tivoo/features/live_stream/data/mock_live_comments.dart';
import 'package:tivoo/features/live_stream/domain/models/gift_item.dart';
import 'package:tivoo/features/live_stream/presentation/widgets/active_gift_animation_overlay.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
      const MethodChannel('xyz.luan/audioplayers.global'),
      (MethodCall methodCall) async => 1,
    );
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
      const MethodChannel('xyz.luan/audioplayers'),
      (MethodCall methodCall) async => 1,
    );
  });

  group('Roses Gift Specification & Assets Tests', () {
    test('Roses gift exists in MockLiveComments with 100,000 Stars', () {
      final rosesGift = MockLiveComments.virtualGifts.firstWhere(
        (g) => g.name == 'Roses',
        orElse: () => throw Exception('Roses gift not found'),
      );

      expect(rosesGift.name, 'Roses');
      expect(rosesGift.diamonds, 100000);
      expect(rosesGift.icon, '🌹');
      expect(rosesGift.imageAssetPath, contains('roses'));

      // Ensure old Shooting Star is completely removed
      final shootingStar = MockLiveComments.virtualGifts.where(
        (g) => g.name.toLowerCase().contains('shooting star'),
      );
      expect(shootingStar, isEmpty);
    });

    test('All generated scattered Roses visual image assets exist on disk', () {
      final streamHero = File('assets/gifts/roses_stream_hero.jpg');
      final singlePetal = File('assets/gifts/rose_single_petal.png');
      final redRose = File('assets/gifts/rose_head_red.png');
      final pinkRose = File('assets/gifts/rose_head_pink.png');
      final backdropImage = File('assets/gifts/roses_castle_backdrop.jpg');
      final giftIcon = File('assets/gift_roses.png');
      final ani10Icon = File('assets/Ani10.png');

      expect(streamHero.existsSync(), isTrue, reason: 'Stream hero missing');
      expect(singlePetal.existsSync(), isTrue, reason: 'Single petal sprite missing');
      expect(redRose.existsSync(), isTrue, reason: 'Red rose head missing');
      expect(pinkRose.existsSync(), isTrue, reason: 'Pink rose head missing');
      expect(backdropImage.existsSync(), isTrue, reason: 'Backdrop image missing');
      expect(giftIcon.existsSync(), isTrue, reason: 'Gift icon missing');
      expect(ani10Icon.existsSync(), isTrue, reason: 'Ani10 icon missing');

      expect(streamHero.lengthSync(), greaterThan(10000));
      expect(singlePetal.lengthSync(), greaterThan(10000));
      expect(redRose.lengthSync(), greaterThan(10000));
      expect(pinkRose.lengthSync(), greaterThan(10000));
    });

    test('All 6-step Roses audio assets exist on disk', () {
      final masterAudio = File('assets/sounds/sound_roses.wav');
      final stage1 = File('assets/sounds/sound_roses_1_bloom.wav');
      final stage2 = File('assets/sounds/sound_roses_2_ribbon.wav');
      final stage3 = File('assets/sounds/sound_roses_3_burst.wav');
      final stage4 = File('assets/sounds/sound_roses_4_swirl.wav');
      final stage5 = File('assets/sounds/sound_roses_5_petals.wav');
      final stage6 = File('assets/sounds/sound_roses_6_fade.wav');

      expect(masterAudio.existsSync(), isTrue);
      expect(stage1.existsSync(), isTrue);
      expect(stage2.existsSync(), isTrue);
      expect(stage3.existsSync(), isTrue);
      expect(stage4.existsSync(), isTrue);
      expect(stage5.existsSync(), isTrue);
      expect(stage6.existsSync(), isTrue);

      // Verify master audio length is full 12s synthesized uncompressed WAV
      expect(masterAudio.lengthSync(), greaterThan(500000));
    });

    test('GiftSoundService handles roses audio playback seamlessly', () async {
      final service = GiftSoundService.instance;
      await service.playGiftSound('roses');
      await service.playRosesMasterAudio();
      await service.stop();
    });
  });

  group('Roses 6-Step Storyboard Animation Overlay Tests', () {
    testWidgets('triggers Roses gift and transitions through all 6 animation steps in 12s',
        (WidgetTester tester) async {
      final GlobalKey<ActiveGiftAnimationOverlayState> overlayKey =
          GlobalKey<ActiveGiftAnimationOverlayState>();
      int scoreImpactPoints = 0;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ActiveGiftAnimationOverlay(
              key: overlayKey,
              onScoreImpact: ({required bool toLeft, required int points}) {
                scoreImpactPoints = points;
              },
              child: const Center(child: Text('Live Stream Streamer')),
            ),
          ),
        ),
      );

      expect(find.text('Live Stream Streamer'), findsOneWidget);

      final rosesGift = GiftItem(
        id: 'gift_ani10_roses',
        name: 'Roses',
        icon: '🌹',
        imageAssetPath: AppAssets.rosesStreamHero,
        diamonds: 100000,
      );

      overlayKey.currentState?.playGift(rosesGift, senderName: 'Romeo', count: 1);
      await tester.pump();

      expect(find.byType(ActiveGiftAnimationOverlay), findsOneWidget);

      // Step 1: First Petal (0.0 - 1.5s)
      await tester.pump(const Duration(milliseconds: 800));
      expect(find.text('Romeo sent Roses x1'), findsOneWidget);
      expect(find.text('100,000 ⭐'), findsOneWidget);
      expect(find.text('1. First Petal • Single Glowing Petal'), findsOneWidget);

      // Step 2: Petals Multiply (1.5 - 3.0s)
      await tester.pump(const Duration(milliseconds: 1400)); // now at 2.2s
      expect(find.text('2. Petals Multiply • Trail of Shimmering Light'), findsOneWidget);

      // Step 3: Roses Bloom in Motion (3.0 - 5.0s)
      await tester.pump(const Duration(milliseconds: 1800)); // now at 4.0s
      expect(find.text('3. Roses Bloom in Motion • Scattered Blossoms'), findsOneWidget);

      // Step 4: Swirling Elegance (5.0 - 8.0s) with +100,000 Stars Impact!
      await tester.pump(const Duration(milliseconds: 3200)); // now at 7.2s
      expect(find.text('4. Swirling Elegance • Circular Waves Dance'), findsOneWidget);
      expect(find.text('+100,000 Stars Impact!'), findsOneWidget);
      expect(scoreImpactPoints, 100000);

      // Step 5: Full Screen Bloom (8.0 - 11.0s)
      await tester.pump(const Duration(milliseconds: 2000)); // now at 9.2s
      expect(find.text('5. Full Screen Bloom • Dreamy Romantic Atmosphere'), findsOneWidget);

      // Step 6: Fade & Glow (11.0 - 12.0s)
      await tester.pump(const Duration(milliseconds: 2200)); // now at 11.4s
      expect(find.text('6. Fade & Glow • Soft Lingering Radiance'), findsOneWidget);

      // Animation complete (after 12.5s)
      await tester.pump(const Duration(milliseconds: 1200));
      expect(find.text('Romeo sent Roses x1'), findsNothing);
    });
  });
}
