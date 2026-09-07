import 'dart:async';

import 'package:bingo_pay/features/product_categories_details/data/models/product_categories_model.dart';
import 'package:bingo_pay/features/product_categories_details/data/services/product_cache_service.dart';
import 'package:bingo_pay/features/product_categories_details/domain/repositories/product_listing_repository.dart';
import 'package:bingo_pay/features/product_categories_details/presentation/product_categories_cubit/product_categories_cubit.dart';
import 'package:bingo_pay/features/wishlist/data/models/wishlist_model.dart';
import 'package:bingo_pay/features/wishlist/presentation/cubit/wishlist_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MockProductListingRepository extends Mock
    implements ProductListingRepository {}

List<ListingProductModel> _fakeProducts(int count, {required String prefix}) {
  return List.generate(
    count,
    (i) => ListingProductModel(
      id: '$prefix-$i',
      uuid: '$prefix-$i',
      brand: 'Brand',
      name: 'Product $prefix-$i',
      price: 100,
      icon: Icons.shopping_bag_outlined,
    ),
  );
}

void main() {
  test(
    'a wishlist toggle survives an immediate category switch — the '
    'ProductListingCubit driving the category screen is a separate, '
    'unrelated cubit from the app-scoped WishlistCubit',
    () async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();

      final wishlistCubit = WishlistCubit(prefs);
      addTearDown(wishlistCubit.close);
      await wishlistCubit.loadForUser('user-1');

      final cacheService = ProductCacheService(prefs);
      final repository = MockProductListingRepository();
      when(() => repository.resolveCategoryUuids(any()))
          .thenAnswer((invocation) async {
        final uuid = invocation.positionalArguments[0] as String;
        return [uuid];
      });

      final gateB = Completer<void>();
      when(
        () => repository.fetchProducts(
          categoryUuid: 'cat-a',
          page: any(named: 'page'),
          limit: any(named: 'limit'),
        ),
      ).thenAnswer((_) async => _fakeProducts(2, prefix: 'a'));
      when(
        () => repository.fetchProducts(
          categoryUuid: 'cat-b',
          page: any(named: 'page'),
          limit: any(named: 'limit'),
        ),
      ).thenAnswer((_) async {
        // Category B's load is still in flight when we check the toggle.
        await gateB.future;
        return _fakeProducts(2, prefix: 'b');
      });

      final listingCubit = ProductListingCubit(repository, cacheService);
      addTearDown(listingCubit.close);

      await listingCubit.loadCategory('Category A', 'cat-a');
      expect(wishlistCubit.isWishlisted('a-0'), isFalse);

      // Tap the heart on product a-0 ...
      final toggleFuture = wishlistCubit.toggle(
        const WishlistItem(id: 'a-0', brand: 'Brand', name: 'Product a-0', price: '100'),
        wasWishlisted: false,
      );

      // ... then immediately switch category, before the toggle's
      // fire-and-forget persistence has settled and before category B's
      // fetch resolves.
      final switchFuture = listingCubit.loadCategory('Category B', 'cat-b');

      // The toggle must already be visible — it's a synchronous state
      // update on a cubit that has nothing to do with the category switch.
      expect(wishlistCubit.isWishlisted('a-0'), isTrue,
          reason: 'the heart toggle applies to WishlistCubit state '
              'synchronously and is independent of ProductListingCubit');

      await toggleFuture;

      // Let category B's screen finish rendering (re-render happens here).
      gateB.complete();
      await switchFuture;

      expect(wishlistCubit.isWishlisted('a-0'), isTrue,
          reason: 'the wishlist toggle must not be lost when the category '
              'listing re-renders for a different category');

      // And it must be the *correct* product — switching categories must
      // not have toggled or affected any product from the new category.
      expect(wishlistCubit.isWishlisted('b-0'), isFalse);
      expect(wishlistCubit.isWishlisted('b-1'), isFalse);

      // The toggle must have been durably persisted too, not just held in
      // memory — simulate a fresh app session reading it back.
      final wishlistCubit2 = WishlistCubit(prefs);
      addTearDown(wishlistCubit2.close);
      await wishlistCubit2.loadForUser('user-1');
      expect(wishlistCubit2.isWishlisted('a-0'), isTrue,
          reason: 'the toggle must have been persisted to storage, not '
              'lost when the in-memory cubit is recreated');
    },
  );
}
