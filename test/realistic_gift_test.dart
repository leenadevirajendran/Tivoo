import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tivoo/core/services/gift_sound_service.dart';
import 'package:tivoo/features/live_stream/data/mock_live_comments.dart';
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

  group('GiftSoundService Tests', () {
    test('GiftSoundService instance plays and stops sounds correctly', () async {
      final service = GiftSoundService.instance;
      expect(service, isNotNull);
      expect(service.isMuted, false);

      // Verify sound play triggers without throwing for all user gift categories
      await service.playGiftSound('rocket');
      await service.playGiftSound('wings');
      await service.playGiftSound('car');
      await service.playGiftSound('yacht');
      await service.playGiftSound('castle');
      await service.playGiftSound('world_tour');
      await service.playGiftSound('diamond');
      await service.playGiftSound('crown');
      await service.playGiftSound('cake');
      await service.playGiftSound('teddy');
      await service.playGiftSound('kitty');
      await service.playGiftSound('love');
      await service.playGiftSound('flowers');
      await service.stop();

      // Verify mute toggle
      service.isMuted = true;
      expect(service.isMuted, true);
      await service.playGiftSound('rocket'); // No-op when muted
      service.isMuted = false;
      expect(service.isMuted, false);
    });
  });

  group('User Reference Gifts List Tests', () {
    test('MockLiveComments.virtualGifts contains reference gifts', () {
      final gifts = MockLiveComments.virtualGifts;
      expect(gifts.length, greaterThanOrEqualTo(10));

      final giftNames = gifts.map((g) => g.name).toSet();
      expect(giftNames, containsAll([
        'Galaxy Rocket',
        'Royal Crown',
        'Golden Horse',
        'Angel Vehicle',
        'Love Castle',
        'Luxury Car',
        'Luxury Yacht',
        'Diamond Wings',
        'Star Throne',
        'Roses',
        'Ocean Dolphin',
      ]));
      expect(giftNames.contains('Rose Carriage'), isFalse);
      expect(giftNames.contains('Shooting Star'), isFalse);

      final dolphin = gifts.firstWhere((g) => g.name == 'Ocean Dolphin');
      expect(dolphin.diamonds, 10000);

      // Check specific coin values matching user screenshot badges
      final rocket = gifts.firstWhere((g) => g.name == 'Galaxy Rocket');
      expect(rocket.diamonds, 1000);

      final royalCrown = gifts.firstWhere((g) => g.name == 'Royal Crown');
      expect(royalCrown.diamonds, 50000);

      final goldenHorse = gifts.firstWhere((g) => g.name == 'Golden Horse');
      expect(goldenHorse.diamonds, 25000);
    });
  });

  group('ActiveGiftAnimationOverlay Presentation Tests', () {
    testWidgets('triggers Galaxy Rocket gift, renders animation and skip button is removed',
        (WidgetTester tester) async {
      final GlobalKey<ActiveGiftAnimationOverlayState> overlayKey =
          GlobalKey<ActiveGiftAnimationOverlayState>();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ActiveGiftAnimationOverlay(
              key: overlayKey,
              child: const Center(child: Text('Live Stream Screen')),
            ),
          ),
        ),
      );

      expect(find.text('Live Stream Screen'), findsOneWidget);

      final rocketGift = MockLiveComments.virtualGifts.firstWhere((g) => g.name == 'Galaxy Rocket');
      overlayKey.currentState?.playGift(rocketGift, senderName: 'Tester');
      await tester.pump(const Duration(milliseconds: 100));

      // Skip button is permanently removed per user request
      expect(find.text('Skip'), findsNothing);
    });

    testWidgets('triggers Luxury Car gift, renders animation without skip button',
        (WidgetTester tester) async {
      final GlobalKey<ActiveGiftAnimationOverlayState> overlayKey =
          GlobalKey<ActiveGiftAnimationOverlayState>();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ActiveGiftAnimationOverlay(
              key: overlayKey,
              child: const Center(child: Text('Live Stream Screen')),
            ),
          ),
        ),
      );

      final carGift = MockLiveComments.virtualGifts.firstWhere((g) => g.name == 'Luxury Car');
      overlayKey.currentState?.playGift(carGift, senderName: 'Tester');
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.text('Skip'), findsNothing);
    });

    testWidgets('triggers Luxury Yacht gift, renders animation without skip button',
        (WidgetTester tester) async {
      final GlobalKey<ActiveGiftAnimationOverlayState> overlayKey =
          GlobalKey<ActiveGiftAnimationOverlayState>();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ActiveGiftAnimationOverlay(
              key: overlayKey,
              child: const Center(child: Text('Live Stream Screen')),
            ),
          ),
        ),
      );

      final yachtGift = MockLiveComments.virtualGifts.firstWhere((g) => g.name == 'Luxury Yacht');
      overlayKey.currentState?.playGift(yachtGift, senderName: 'Tester');
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.text('Skip'), findsNothing);
    });
  });
}
