import 'package:flutter_test/flutter_test.dart';
import 'package:tivoo/features/live_stream/domain/models/gift_options.dart';
import 'package:tivoo/features/live_stream/domain/models/gift_item.dart';
import 'package:tivoo/features/live_stream/data/mock_live_comments.dart';

void main() {
  group('Unified Gift Options System Tests', () {
    test('GiftCatalog contains all virtual gifts and matches MockLiveComments', () {
      expect(GiftCatalog.allGifts.isNotEmpty, isTrue);
      expect(GiftCatalog.virtualGifts, equals(MockLiveComments.virtualGifts));
      expect(GiftCatalog.allGifts.length, greaterThanOrEqualTo(15));
    });

    test('GiftCatalog findById returns exact gift', () {
      final crown = GiftCatalog.findById('gift_ani7_crown');
      expect(crown, isNotNull);
      expect(crown!.name, equals('Royal Crown'));
      expect(crown.diamonds, equals(50000));
      expect(crown.isCrown, isTrue);
      expect(crown.animationType, equals(GiftAnimationType.royalCrown));
      expect(crown.soundCategory, equals('crown'));

      final dolphin = GiftCatalog.findById('gift_ani1_whale');
      expect(dolphin, isNotNull);
      expect(dolphin!.name, equals('Ocean Dolphin'));
      expect(dolphin.diamonds, equals(10000));
      expect(dolphin.isOceanDolphin, isTrue);
      expect(dolphin.animationType, equals(GiftAnimationType.oceanDolphin));

      final roses = GiftCatalog.findById('gift_ani10_roses');
      expect(roses, isNotNull);
      expect(roses!.name, equals('Roses'));
      expect(roses.diamonds, equals(100000));
      expect(roses.isRoses, isTrue);
      expect(roses.animationType, equals(GiftAnimationType.roses));

      final superCar = GiftCatalog.findById('gift_super_car');
      expect(superCar, isNotNull);
      expect(superCar!.name, equals('Super Car'));

      final flowers = GiftCatalog.findById('gift_flowers');
      expect(flowers, isNotNull);
      expect(flowers!.name, equals('Flowers'));
    });

    test('GiftCatalog findByName is case-insensitive', () {
      final yacht = GiftCatalog.findByName('luxury yacht');
      expect(yacht, isNotNull);
      expect(yacht!.diamonds, equals(5000));
      expect(yacht.isLuxuryYacht, isTrue);

      final horse = GiftCatalog.findByName('GOLDEN HORSE');
      expect(horse, isNotNull);
      expect(horse!.diamonds, equals(25000));
      expect(horse.isGoldenHorse, isTrue);
    });

    test('Category filtering returns expected gift subsets', () {
      final popular = GiftCatalog.filterByCategory('Popular');
      expect(popular.isNotEmpty, isTrue);

      final love = GiftCatalog.filterByCategory('Love');
      expect(love.isNotEmpty, isTrue);

      final luxury = GiftCatalog.filterByCategory('Luxury');
      expect(luxury.isNotEmpty, isTrue);
      expect(luxury.every((g) => g.diamonds >= 1000), isTrue);

      final all = GiftCatalog.filterByCategory('All');
      expect(all.length, equals(GiftCatalog.allGifts.length));
    });

    test('Combo presets contain standard multipliers', () {
      final multipliers = GiftComboOption.presets.map((c) => c.count).toList();
      expect(multipliers, containsAll([1, 5, 10, 66, 88, 99, 188, 520, 1314]));
    });

    test('PKBattleGiftData calculates correct PK battle points', () {
      final car = GiftCatalog.findByName('Luxury Car')!;
      final points = PKBattleGiftData.calculatePkPoints(car, 2);
      expect(points, equals(500 * 15 * 2));

      expect(PKBattleGiftData.giftImages.containsKey('Rose'), isTrue);
      expect(PKBattleGiftData.giftImages.containsKey('Ocean Dolphin'), isTrue);
      expect(PKBattleGiftData.incomingComments.isNotEmpty, isTrue);
    });

    test('Coin recharge packs are configured properly', () {
      expect(CoinPackOption.standardPacks.isNotEmpty, isTrue);
      final popularPack = CoinPackOption.standardPacks.firstWhere((p) => p.isPopular);
      expect(popularPack.coins, equals(350));
      expect(popularPack.price, equals('₹249'));
    });

    test('GiftAnimationMeta registry contains entries for all animation types', () {
      for (final type in GiftAnimationType.values) {
        expect(GiftAnimationMeta.registry.containsKey(type), isTrue);
      }
    });
  });
}
