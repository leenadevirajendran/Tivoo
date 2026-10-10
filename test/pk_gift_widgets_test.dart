import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tivoo/features/gift/gift.dart';

void main() {
  group('PK Battle Gift Widgets Tests', () {
    testWidgets('PkGiftPill renders sender name, gift name and multiplier count', (tester) async {
      const event = PkGiftEvent(
        id: 1,
        sender: 'Sneha',
        senderAvatar: 'assets/status3.png',
        giftName: 'Roses',
        emoji: '🌹',
        count: 5,
      );

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: Center(
              child: PkGiftPill(gift: event),
            ),
          ),
        ),
      );

      expect(find.text('Sneha'), findsOneWidget);
      expect(find.text('Sent Roses'), findsOneWidget);
      expect(find.text('x5'), findsOneWidget);
    });

    testWidgets('PkGiftCard renders gift label and responds to tap', (tester) async {
      bool tapped = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Center(
              child: PkGiftCard(
                onTap: () {
                  tapped = true;
                },
              ),
            ),
          ),
        ),
      );

      expect(find.text('Gift'), findsOneWidget);
      expect(find.byType(BigGiftButton), findsOneWidget);

      await tester.tap(find.byType(PkGiftCard));
      expect(tapped, isTrue);
    });
  });
}
