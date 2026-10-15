import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tivoo/features/explore/domain/models/explore_stream_model.dart';
import 'package:tivoo/features/explore/presentation/widgets/explore_header.dart';
import 'package:tivoo/features/explore/presentation/widgets/explore_reel_card.dart';
import 'package:tivoo/features/gift/gift_sheet_screen.dart';
import 'package:tivoo/features/gift/pk_gift_widgets.dart';
import 'package:tivoo/features/live_stream/presentation/widgets/live_action_bar.dart';

void main() {
  const testStream = ExploreStreamModel(
    id: 'stream_1',
    streamerName: 'Lena Rivers',
    category: 'Live',
    subCategory: 'Music & Chill',
    viewersCount: '12.5K',
    diamondsCount: '24.2K',
    avatarAssetPath: 'assets/Home/user1.png',
    coverAssetPath: 'assets/Home/user1.png',
    isLive: true,
    isVerified: true,
  );

  group('ExploreHeader Tests', () {
    testWidgets('ExploreHeader shows wallet icon and does not show *1m icon', (tester) async {
      bool walletTapped = false;

      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: ExploreHeader(
                onWalletTap: () => walletTapped = true,
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Verify wallet icon button exists
      expect(find.byIcon(Icons.account_balance_wallet_rounded), findsOneWidget);

      // Verify old *1M star pill is removed
      expect(find.text('1M'), findsNothing);

      // Tap the wallet icon
      await tester.tap(find.byIcon(Icons.account_balance_wallet_rounded));
      expect(walletTapped, isTrue);
    });

    testWidgets('ExploreHeader renders without overflow on compact 320px width', (tester) async {
      tester.view.physicalSize = const Size(320, 568);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: Builder(
                builder: (context) => MediaQuery(
                  data: MediaQuery.of(context).copyWith(size: const Size(320, 568)),
                  child: ExploreHeader(
                    onBackTap: () {},
                    onViewModeToggle: () {},
                    onSearchTap: () {},
                    onFilterTap: () {},
                  ),
                ),
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Explore'), findsOneWidget);
      expect(find.byIcon(Icons.account_balance_wallet_rounded), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  });

  group('ExploreReelCard Action Icons & Gift Tests', () {
    testWidgets('Action column shows Stars button with gstar image and opens GiftBottomSheet with wallet icon', (tester) async {
      tester.view.physicalSize = const Size(390, 844);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: ExploreReelCard(
                stream: testStream,
                isActive: false,
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Verify "Stars" label is present (replacing old "Gift" / "Star")
      expect(find.text('Star'), findsNothing);
      expect(find.text('Gift'), findsNothing);
      expect(find.text('Stars'), findsOneWidget);

      // Verify Like, Chat, Share buttons are present with consistent yellow styling
      expect(find.text('Chat'), findsOneWidget);
      expect(find.text('Share'), findsOneWidget);
      expect(find.text('24.2K'), findsOneWidget);

      final chatIcon = tester.widget<Icon>(find.byIcon(Icons.chat_bubble_outline_rounded));
      expect(chatIcon.color, const Color(0xFFFFD700));

      final shareIcon = tester.widget<Icon>(find.byIcon(Icons.share_rounded));
      expect(shareIcon.color, const Color(0xFFFFD700));

      final likeIcon = tester.widget<Icon>(find.byIcon(Icons.favorite_border_rounded));
      expect(likeIcon.color, const Color(0xFFFFD700));

      // Verify glossy_star.png image asset is present
      final imageFinder = find.byWidgetPredicate(
        (widget) => widget is Image && widget.image is AssetImage && (widget.image as AssetImage).assetName == 'assets/glossy_star.png',
      );
      expect(imageFinder, findsOneWidget);

      // Tap the Stars button
      await tester.tap(find.text('Stars'));
      await tester.pump(const Duration(milliseconds: 350));
      await tester.pumpAndSettle();

      // Verify GiftBottomSheet is displayed
      expect(find.byType(GiftBottomSheet), findsOneWidget);
      expect(find.textContaining('Lena Rivers'), findsWidgets);

      // Verify GiftBottomSheet header has 'Stars' title and wallet icon attached to the right
      expect(
        find.descendant(of: find.byType(GiftBottomSheet), matching: find.text('Stars')),
        findsOneWidget,
      );
      expect(
        find.descendant(of: find.byType(GiftBottomSheet), matching: find.byIcon(Icons.account_balance_wallet_rounded)),
        findsOneWidget,
      );
    });

    testWidgets('GiftBottomSheet header renders without overflow on 320px compact width with wallet icon', (tester) async {
      tester.view.physicalSize = const Size(320, 667);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: Builder(
                builder: (context) => ElevatedButton(
                  onPressed: () {
                    GiftBottomSheet.show(
                      context,
                      (_) {},
                      recipients: ['Lena Rivers', 'Alex Rivers'],
                      initialRecipient: 'Lena Rivers',
                    );
                  },
                  child: const Text('Open'),
                ),
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();

      expect(find.byType(GiftBottomSheet), findsOneWidget);
      expect(find.byIcon(Icons.account_balance_wallet_rounded), findsOneWidget);
      expect(find.text('Stars'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  });

  group('PK Battle Star Card Tests', () {
    testWidgets('PkGiftCard displays gstar.png, animated stars, and has no text label', (tester) async {
      bool giftTapped = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Center(
              child: SizedBox(
                width: 120,
                height: 120,
                child: PkGiftCard(
                  onTap: () => giftTapped = true,
                ),
              ),
            ),
          ),
        ),
      );
      await tester.pump(const Duration(milliseconds: 50));

      // Verify that there is NO "Stars" or "Gift" text in the card
      expect(find.descendant(of: find.byType(PkGiftCard), matching: find.byType(Text)), findsNothing);

      // Verify glossy_star.png image is present
      final glossyStarFinder = find.byWidgetPredicate(
        (widget) => widget is Image && widget.image is AssetImage && (widget.image as AssetImage).assetName == 'assets/glossy_star.png',
      );
      expect(glossyStarFinder, findsOneWidget);

      // Verify animated stars are rendered
      expect(find.descendant(of: find.byType(PkGiftCard), matching: find.byIcon(Icons.auto_awesome)), findsWidgets);
      expect(find.descendant(of: find.byType(PkGiftCard), matching: find.byIcon(Icons.star_rounded)), findsWidgets);

      // Tap the card
      await tester.tap(find.byType(PkGiftCard));
      expect(giftTapped, isTrue);
    });
  });

  group('LiveActionBar Tests', () {
    testWidgets('LiveActionBar matches Explore style with yellow touch, juststar.png, and opens Gift sheet', (tester) async {
      bool giftTapped = false;
      bool likeTapped = false;
      bool shareTapped = false;
      bool chatTapped = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Align(
              alignment: Alignment.centerRight,
              child: LiveActionBar(
                isFollowing: false,
                isLiked: false,
                likesCount: '12.5K',
                commentsCount: '850',
                starsCount: 'Stars',
                onFollowTap: () {},
                onLikeTap: () => likeTapped = true,
                onCommentTap: () => chatTapped = true,
                onGiftTap: () => giftTapped = true,
                onShareTap: () => shareTapped = true,
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Verify old Gift (🎁) and old Star buttons are removed
      expect(find.text('🎁'), findsNothing);
      expect(find.text('Gift'), findsNothing);
      expect(find.text('Star'), findsNothing);

      // Verify new Explore-style buttons are present: Like, Chat, Stars, Share
      expect(find.text('12.5K'), findsOneWidget);
      expect(find.text('Chat'), findsOneWidget);
      expect(find.text('Stars'), findsOneWidget);
      expect(find.text('Share'), findsOneWidget);

      // Verify glossy_star.png asset is present
      final starAssetFinder = find.byWidgetPredicate(
        (widget) => widget is Image && widget.image is AssetImage && (widget.image as AssetImage).assetName == 'assets/glossy_star.png',
      );
      expect(starAssetFinder, findsOneWidget);

      // Verify Chat icon is yellow
      final chatIcon = tester.widget<Icon>(find.byIcon(Icons.chat_bubble_outline_rounded));
      expect(chatIcon.color, const Color(0xFFFFD700));

      // Verify Share icon is yellow
      final shareIcon = tester.widget<Icon>(find.byIcon(Icons.share_rounded));
      expect(shareIcon.color, const Color(0xFFFFD700));

      // Tap Stars button and verify onGiftTap callback is invoked
      await tester.tap(find.text('Stars'));
      expect(giftTapped, isTrue);

      // Tap Like button and verify onLikeTap callback is invoked
      await tester.tap(find.text('12.5K'));
      expect(likeTapped, isTrue);

      // Tap Chat button and verify onCommentTap callback is invoked
      await tester.tap(find.text('Chat'));
      expect(chatTapped, isTrue);

      // Tap Share button and verify onShareTap callback is invoked
      await tester.tap(find.text('Share'));
      expect(shareTapped, isTrue);
    });
  });
}
