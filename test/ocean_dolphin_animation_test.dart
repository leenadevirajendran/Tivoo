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

  group('Ocean Dolphin Gift Specification & Assets Tests', () {
    test('Ocean Dolphin gift exists in MockLiveComments with 10,000 Stars', () {
      final dolphinGift = MockLiveComments.virtualGifts.firstWhere(
        (g) => g.name == 'Ocean Dolphin',
        orElse: () => throw Exception('Ocean Dolphin gift not found'),
      );

      expect(dolphinGift.name, 'Ocean Dolphin');
      expect(dolphinGift.diamonds, 10000);
      expect(dolphinGift.icon, '🐬');
      expect(dolphinGift.imageAssetPath, contains('ocean_dolphin'));
    });

    test('All generated Ocean Dolphin visual image assets exist on disk', () {
      final heroImage = File('assets/gifts/ocean_dolphin_hero.jpg');
      final actorImage = File('assets/gifts/ocean_dolphin_actor.png');
      final riderImage = File('assets/gifts/ocean_dolphin_rider.png');
      final rippleImage = File('assets/gifts/ocean_dolphin_ripple.png');
      final backdropImage = File('assets/gifts/ocean_dolphin_backdrop.jpg');
      final iconWhale = File('assets/gift_ocean_whale.png');
      final iconDolphin = File('assets/gift_ocean_dolphin.png');
      final ani1Icon = File('assets/Ani1.png');

      expect(heroImage.existsSync(), isTrue, reason: 'Hero image missing');
      expect(actorImage.existsSync(), isTrue, reason: 'Actor image missing');
      expect(riderImage.existsSync(), isTrue, reason: 'Rider image missing');
      expect(rippleImage.existsSync(), isTrue, reason: 'Ripple image missing');
      expect(backdropImage.existsSync(), isTrue, reason: 'Backdrop image missing');
      expect(iconWhale.existsSync(), isTrue, reason: 'Icon whale missing');
      expect(iconDolphin.existsSync(), isTrue, reason: 'Icon dolphin missing');
      expect(ani1Icon.existsSync(), isTrue, reason: 'Ani1 icon missing');

      expect(heroImage.lengthSync(), greaterThan(10000));
      expect(actorImage.lengthSync(), greaterThan(10000));
      expect(riderImage.lengthSync(), greaterThan(10000));
      expect(rippleImage.lengthSync(), greaterThan(10000));
    });

    test('All 6-step Ocean Dolphin audio assets exist on disk', () {
      final masterAudio = File('assets/sounds/sound_whale.wav');
      final dolphinMaster = File('assets/sounds/sound_ocean_dolphin.wav');
      final stage1 = File('assets/sounds/sound_dolphin_1_splash.wav');
      final stage2 = File('assets/sounds/sound_dolphin_2_rising.wav');
      final stage3 = File('assets/sounds/sound_dolphin_3_breath.wav');
      final stage4 = File('assets/sounds/sound_dolphin_4_harmonic.wav');
      final stage5 = File('assets/sounds/sound_dolphin_5_flow.wav');
      final stage6 = File('assets/sounds/sound_dolphin_6_echo.wav');

      expect(masterAudio.existsSync(), isTrue);
      expect(dolphinMaster.existsSync(), isTrue);
      expect(stage1.existsSync(), isTrue);
      expect(stage2.existsSync(), isTrue);
      expect(stage3.existsSync(), isTrue);
      expect(stage4.existsSync(), isTrue);
      expect(stage5.existsSync(), isTrue);
      expect(stage6.existsSync(), isTrue);

      // Verify master audio length is full 10s synthesized uncompressed WAV
      expect(masterAudio.lengthSync(), greaterThan(500000));
    });

    test('GiftSoundService handles dolphin audio playback seamlessly', () async {
      final service = GiftSoundService.instance;
      await service.playGiftSound('dolphin');
      await service.playGiftSound('ocean_dolphin');
      await service.playGiftSound('whale');
      await service.playOceanDolphinMasterAudio();
      await service.stop();
    });
  });

  group('Ocean Dolphin 6-Step Storyboard Animation Overlay Tests', () {
    testWidgets('triggers Ocean Dolphin gift and transitions through all 6 animation steps in 10s',
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

      final dolphinGift = GiftItem(
        id: 'gift_ani1_whale',
        name: 'Ocean Dolphin',
        icon: '🐬',
        imageAssetPath: AppAssets.oceanDolphinHero,
        diamonds: 10000,
      );

      overlayKey.currentState?.playGift(dolphinGift, senderName: 'Ananya', count: 1);
      await tester.pump();

      expect(find.byType(ActiveGiftAnimationOverlay), findsOneWidget);

      // Step 1: Ocean Ripple Burst (0.0 - 1.5s)
      await tester.pump(const Duration(milliseconds: 700));
      expect(find.text('Ananya sent Ocean Dolphin x1'), findsOneWidget);
      expect(find.text('10,000 ⭐'), findsOneWidget);
      expect(find.text('1. Ocean Ripple Burst • Luminous Vortex'), findsOneWidget);

      // Step 2: Whale Formation (1.5 - 3.0s)
      await tester.pump(const Duration(milliseconds: 1400)); // now at 2.1s
      expect(find.text('2. Whale Formation • Crystal Trails'), findsOneWidget);

      // Step 3: Whale Awakens (3.0 - 5.0s)
      await tester.pump(const Duration(milliseconds: 1800)); // now at 3.9s
      expect(find.text('3. Whale Awakens • Light Flows Across Body'), findsOneWidget);

      // Step 4: Rider Appears (5.0 - 7.0s) with +10,000 Stars Impact!
      await tester.pump(const Duration(milliseconds: 2000)); // now at 5.9s
      expect(find.text('4. Rider Appears • Angelic Blessing'), findsOneWidget);
      expect(find.text('+10,000 Stars Impact!'), findsOneWidget);
      expect(scoreImpactPoints, 10000);

      // Step 5: Majestic Glide (7.0 - 9.0s)
      await tester.pump(const Duration(milliseconds: 2000)); // now at 7.9s
      expect(find.text('5. Majestic Glide • Flying Sky & Ocean'), findsOneWidget);

      // Step 6: Fade Out (9.0 - 10.0s)
      await tester.pump(const Duration(milliseconds: 1500)); // now at 9.4s
      expect(find.text('6. Fade Out • Trail of Stardust & Light'), findsOneWidget);

      // Animation complete (after 10.5s)
      await tester.pump(const Duration(milliseconds: 1200));
      expect(find.text('Ananya sent Ocean Dolphin x1'), findsNothing);
    });
  });
}
