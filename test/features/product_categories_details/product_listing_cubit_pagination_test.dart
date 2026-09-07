import 'dart:async';

import 'package:bingo_pay/core/error/exceptions.dart';
import 'package:bingo_pay/features/product_categories_details/data/models/product_categories_model.dart';
import 'package:bingo_pay/features/product_categories_details/data/services/product_cache_service.dart';
import 'package:bingo_pay/features/product_categories_details/domain/repositories/product_listing_repository.dart';
import 'package:bingo_pay/features/product_categories_details/presentation/product_categories_cubit/product_categories_cubit.dart';
import 'package:bingo_pay/features/product_categories_details/presentation/product_categories_cubit/product_categories_state.dart';
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

ListingProductModel _priced(String id, double price, {double? rating}) {
  return ListingProductModel(
    id: id,
    uuid: id,
    brand: 'Brand',
    name: 'Product $id',
    price: price,
    rating: rating,
    icon: Icons.shopping_bag_outlined,
  );
}

void main() {
  late MockProductListingRepository repository;
  late ProductCacheService cacheService;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    cacheService = ProductCacheService(await SharedPreferences.getInstance());
    repository = MockProductListingRepository();
    // categoryUuid: '' resolves to just itself — no category tree to walk.
    when(() => repository.resolveCategoryUuids(any()))
        .thenAnswer((invocation) async {
      final uuid = invocation.positionalArguments[0] as String;
      return [uuid];
    });
  });

  test(
    'loadMoreProducts appends the next page and stops once a page is short',
    () async {
      // Page 1 is a full page (20) so more should be available; page 2
      // comes back short (5), which should mark that UUID exhausted.
      when(
        () => repository.fetchProducts(
          categoryUuid: any(named: 'categoryUuid'),
          page: any(named: 'page'),
          limit: any(named: 'limit'),
        ),
      ).thenAnswer((invocation) async {
        final page = invocation.namedArguments[#page] as int;
        if (page == 1) return _fakeProducts(20, prefix: 'p1');
        if (page == 2) return _fakeProducts(5, prefix: 'p2');
        return _fakeProducts(0, prefix: 'p3');
      });

      final cubit = ProductListingCubit(repository, cacheService);
      addTearDown(cubit.close);

      await cubit.loadCategory('Test Category', '');

      final loaded = cubit.state as ProductListingLoaded;
      expect(loaded.products.length, 20);
      expect(loaded.currentPage, 1);
      expect(loaded.hasMorePages, isTrue,
          reason: 'a full first page must report more pages available');

      await cubit.loadMoreProducts();

      final afterMore = cubit.state as ProductListingLoaded;
      expect(afterMore.products.length, 25);
      expect(afterMore.currentPage, 2);
      expect(afterMore.hasMorePages, isFalse,
          reason: 'a short page must mark pagination exhausted');

      // hasMorePages is now false, so a further call must be a no-op.
      await cubit.loadMoreProducts();
      expect(cubit.state, same(afterMore));
    },
  );

  test('loadMoreProducts de-duplicates products already loaded', () async {
    when(
      () => repository.fetchProducts(
        categoryUuid: any(named: 'categoryUuid'),
        page: any(named: 'page'),
        limit: any(named: 'limit'),
      ),
    ).thenAnswer((_) async => _fakeProducts(20, prefix: 'dup'));

    final cubit = ProductListingCubit(repository, cacheService);
    addTearDown(cubit.close);

    await cubit.loadCategory('Test Category', '');
    await cubit.loadMoreProducts();

    final state = cubit.state as ProductListingLoaded;
    expect(state.products.length, 20,
        reason: 'repeated ids from the next page must not duplicate entries');
  });

  test(
    'tapping into a category renders its products and caches them under '
    'that category uuid',
    () async {
      const categoryUuid = 'cat-123';
      when(
        () => repository.fetchProducts(
          categoryUuid: any(named: 'categoryUuid'),
          page: any(named: 'page'),
          limit: any(named: 'limit'),
        ),
      ).thenAnswer((_) async => _fakeProducts(3, prefix: 'shoes'));

      final cubit = ProductListingCubit(repository, cacheService);
      addTearDown(cubit.close);

      await cubit.loadCategory('Shoes', categoryUuid);

      final loaded = cubit.state as ProductListingLoaded;
      expect(loaded.categoryName, 'Shoes');
      expect(loaded.products.length, 3,
          reason: 'the fetched products must render');
      expect(loaded.isCachedData, isFalse,
          reason: 'this came straight from the API, not a cache replay');

      final cached = await cacheService.getCachedProducts(categoryUuid);
      expect(cached, isNotNull, reason: 'the result must be cached');
      expect(cached!.products.map((p) => p.id), loaded.products.map((p) => p.id),
          reason: 'the cache must hold exactly what was rendered, keyed by '
              'the tapped category\'s uuid');
    },
  );

  test(
    'revisiting a previously-cached category shows the cache instantly '
    '(isCachedData + cachedTimeAgo) while a fresh fetch runs, then '
    'replaces it once the fetch completes',
    () async {
      const categoryUuid = 'cat-456';
      await cacheService.cacheProducts(
        categoryUuid,
        _fakeProducts(2, prefix: 'old'),
      );

      // Hold the fresh fetch open so the interim cached-data state can be
      // observed before it gets overwritten.
      final fetchGate = Completer<void>();
      when(
        () => repository.fetchProducts(
          categoryUuid: any(named: 'categoryUuid'),
          page: any(named: 'page'),
          limit: any(named: 'limit'),
        ),
      ).thenAnswer((_) async {
        await fetchGate.future;
        return _fakeProducts(2, prefix: 'fresh');
      });

      final cubit = ProductListingCubit(repository, cacheService);
      addTearDown(cubit.close);

      final states = <ProductListingState>[];
      final sub = cubit.stream.listen(states.add);

      final loadFuture = cubit.loadCategory('Test Category', categoryUuid);

      // Let the cache-check microtasks run without letting the fetch
      // resolve yet.
      await Future.delayed(Duration.zero);

      final cachedState = states.whereType<ProductListingLoaded>().firstWhere(
            (s) => s.isCachedData,
            orElse: () => throw StateError('cached state never emitted'),
          );
      expect(cachedState.products.map((p) => p.id), ['old-0', 'old-1'],
          reason: 'the cache must render instantly on re-entry');
      expect(cachedState.cachedTimeAgo, isNotNull,
          reason: 'the "cached Xh ago" label needs this to be set');
      expect(cachedState.isStaleData, isFalse,
          reason: 'a fresh (non-expired) cache is not "stale"');

      fetchGate.complete();
      await loadFuture;
      await sub.cancel();

      final finalState = cubit.state as ProductListingLoaded;
      expect(finalState.isCachedData, isFalse,
          reason: 'once the fetch completes, the fresh result replaces '
              'the cached placeholder');
      expect(finalState.products.map((p) => p.id), ['fresh-0', 'fresh-1']);
    },
  );

  test(
    'category API rate-limited (429) with a cache present falls back to '
    'the cache instead of a hard error screen',
    () async {
      const categoryUuid = 'cat-789';
      await cacheService.cacheProducts(
        categoryUuid,
        _fakeProducts(2, prefix: 'cached'),
      );

      when(
        () => repository.fetchProducts(
          categoryUuid: any(named: 'categoryUuid'),
          page: any(named: 'page'),
          limit: any(named: 'limit'),
        ),
      ).thenThrow(const RateLimitException(message: 'Too many requests'));

      final cubit = ProductListingCubit(repository, cacheService);
      addTearDown(cubit.close);

      await cubit.loadCategory('Test Category', categoryUuid);

      // The cache-first emit at the top of loadCategory already showed the
      // cache; assert on the state after the rate-limited fetch settles.
      final state = cubit.state;
      expect(state, isA<ProductListingLoaded>(),
          reason: '429 must not surface as a hard ProductListingError screen');
      final loaded = state as ProductListingLoaded;
      expect(loaded.products.map((p) => p.id), ['cached-0', 'cached-1']);
      expect(loaded.isCachedData, isTrue);
    },
  );

  test(
    'category API rate-limited (429) with no cache falls back to an '
    'empty state instead of a hard error screen',
    () async {
      when(
        () => repository.fetchProducts(
          categoryUuid: any(named: 'categoryUuid'),
          page: any(named: 'page'),
          limit: any(named: 'limit'),
        ),
      ).thenThrow(const RateLimitException(message: 'Too many requests'));

      final cubit = ProductListingCubit(repository, cacheService);
      addTearDown(cubit.close);

      await cubit.loadCategory('Test Category', 'cat-no-cache');

      final state = cubit.state;
      expect(state, isA<ProductListingLoaded>(),
          reason: '429 with nothing cached must still be a loaded/empty '
              'state, not ProductListingError');
      final loaded = state as ProductListingLoaded;
      expect(loaded.products, isEmpty);
    },
  );

  test(
    'a fresh category with no cache whose API call fails while offline '
    'shows an empty state instead of a hard error screen',
    () async {
      when(
        () => repository.fetchProducts(
          categoryUuid: any(named: 'categoryUuid'),
          page: any(named: 'page'),
          limit: any(named: 'limit'),
        ),
      ).thenThrow(const NetworkException());

      final cubit = ProductListingCubit(repository, cacheService);
      addTearDown(cubit.close);

      await cubit.loadCategory('Test Category', 'cat-offline-no-cache');

      final state = cubit.state;
      expect(state, isNot(isA<ProductListingError>()),
          reason: 'offline with nothing cached must not surface a hard '
              'error screen');
      expect(state, isA<ProductListingLoaded>());
      final loaded = state as ProductListingLoaded;
      expect(loaded.products, isEmpty);
    },
  );

  test(
    'rapidly tapping two different categories discards the first '
    'category\'s late response via the _currentRequestId guard',
    () async {
      final gateA = Completer<void>();

      when(
        () => repository.fetchProducts(
          categoryUuid: 'cat-a',
          page: any(named: 'page'),
          limit: any(named: 'limit'),
        ),
      ).thenAnswer((_) async {
        // Category A's response arrives late, after B's already landed.
        await gateA.future;
        return _fakeProducts(2, prefix: 'a');
      });

      when(
        () => repository.fetchProducts(
          categoryUuid: 'cat-b',
          page: any(named: 'page'),
          limit: any(named: 'limit'),
        ),
      ).thenAnswer((_) async => _fakeProducts(2, prefix: 'b'));

      final cubit = ProductListingCubit(repository, cacheService);
      addTearDown(cubit.close);

      // Tap A, then tap B before A's request resolves (rapid tap, <1s apart).
      final futureA = cubit.loadCategory('Category A', 'cat-a');
      final futureB = cubit.loadCategory('Category B', 'cat-b');

      await futureB;

      final afterB = cubit.state as ProductListingLoaded;
      expect(afterB.categoryName, 'Category B');
      expect(afterB.products.map((p) => p.id), ['b-0', 'b-1'],
          reason: 'B is the latest tap and must be what renders');

      // Now let A's stale response arrive late.
      gateA.complete();
      await futureA;

      final finalState = cubit.state as ProductListingLoaded;
      expect(finalState.categoryName, 'Category B',
          reason:
              'A\'s late response must be discarded by the request-id guard, '
              'not overwrite B\'s already-rendered products');
      expect(finalState.products.map((p) => p.id), ['b-0', 'b-1']);
    },
  );

  test(
    'double-tapping the same category while it is loading is a no-op '
    '(the _isLoading guard)',
    () async {
      final gate = Completer<void>();

      when(
        () => repository.fetchProducts(
          categoryUuid: 'cat-x',
          page: any(named: 'page'),
          limit: any(named: 'limit'),
        ),
      ).thenAnswer((_) async {
        await gate.future;
        return _fakeProducts(2, prefix: 'x');
      });

      final cubit = ProductListingCubit(repository, cacheService);
      addTearDown(cubit.close);

      // First tap starts loading and is still in flight (gated).
      final firstTap = cubit.loadCategory('Category X', 'cat-x');

      // Second tap on the same category while the first is still loading.
      final secondTap = cubit.loadCategory('Category X', 'cat-x');

      // The second tap must return immediately without waiting on the gate.
      await secondTap.timeout(
        const Duration(milliseconds: 500),
        onTimeout: () => fail(
          'second tap on the same in-flight category did not no-op — it '
          'appears to have started its own fetch and is waiting on it',
        ),
      );

      gate.complete();
      await firstTap;

      // Only one fetch should ever have been issued for this category.
      verify(
        () => repository.fetchProducts(
          categoryUuid: 'cat-x',
          page: any(named: 'page'),
          limit: any(named: 'limit'),
        ),
      ).called(1);

      final finalState = cubit.state as ProductListingLoaded;
      expect(finalState.products.map((p) => p.id), ['x-0', 'x-1']);
    },
  );

  test(
    'applying a price filter recomputes filteredProducts and composes '
    'correctly with an already-active rating filter',
    () async {
      final products = [
        _priced('cheap-highrated', 10000, rating: 4.5),
        _priced('cheap-lowrated', 15000, rating: 3.0),
        _priced('mid-highrated', 30000, rating: 4.2),
        _priced('mid-lowrated', 35000, rating: 2.5),
        _priced('expensive-highrated', 60000, rating: 4.8),
      ];
      when(
        () => repository.fetchProducts(
          categoryUuid: any(named: 'categoryUuid'),
          page: any(named: 'page'),
          limit: any(named: 'limit'),
        ),
      ).thenAnswer((_) async => products);

      final cubit = ProductListingCubit(repository, cacheService);
      addTearDown(cubit.close);

      await cubit.loadCategory('Test Category', 'cat-filters');

      // Apply the rating filter first (4★ & up).
      cubit.applyRatingFilter('4★ & up');
      var loaded = cubit.state as ProductListingLoaded;
      expect(
        loaded.filteredProducts.map((p) => p.id).toSet(),
        {'cheap-highrated', 'mid-highrated', 'expensive-highrated'},
        reason: 'only 4★+ products should remain after the rating filter',
      );

      // Now layer a price band on top — it must combine with (not replace)
      // the active rating filter.
      cubit.applyPriceFilter('\$20k–\$50k');
      loaded = cubit.state as ProductListingLoaded;
      expect(
        loaded.filteredProducts.map((p) => p.id).toSet(),
        {'mid-highrated'},
        reason: 'must satisfy both the \$20k-\$50k band AND the 4★+ rating '
            'filter at the same time',
      );
      expect(loaded.selectedPriceFilter, '\$20k–\$50k');
      expect(loaded.selectedRatingFilter, '4★ & up',
          reason: 'applying the price filter must not clear the rating '
              'filter that was already active');

      // Switching to a different price band must recompute against the
      // full product list, still respecting the rating filter.
      cubit.applyPriceFilter('Under \$20k');
      loaded = cubit.state as ProductListingLoaded;
      expect(
        loaded.filteredProducts.map((p) => p.id).toSet(),
        {'cheap-highrated'},
      );

      // Tapping the same price band again toggles it off, leaving only the
      // rating filter applied.
      cubit.applyPriceFilter('Under \$20k');
      loaded = cubit.state as ProductListingLoaded;
      expect(loaded.selectedPriceFilter, isNull);
      expect(
        loaded.filteredProducts.map((p) => p.id).toSet(),
        {'cheap-highrated', 'mid-highrated', 'expensive-highrated'},
        reason: 'clearing the price filter must fall back to just the '
            'rating filter, not clear everything',
      );
    },
  );

  test(
    'applying "4 stars & up" recomputes filteredProducts and composes '
    'correctly with an already-active price filter',
    () async {
      final products = [
        _priced('cheap-highrated', 10000, rating: 4.5),
        _priced('cheap-lowrated', 15000, rating: 3.0),
        _priced('mid-highrated', 30000, rating: 4.2),
        _priced('mid-lowrated', 35000, rating: 2.5),
        _priced('expensive-highrated', 60000, rating: 4.8),
      ];
      when(
        () => repository.fetchProducts(
          categoryUuid: any(named: 'categoryUuid'),
          page: any(named: 'page'),
          limit: any(named: 'limit'),
        ),
      ).thenAnswer((_) async => products);

      final cubit = ProductListingCubit(repository, cacheService);
      addTearDown(cubit.close);

      await cubit.loadCategory('Test Category', 'cat-rating-filters');

      // Apply the price filter first ($20k-$50k band).
      cubit.applyPriceFilter('\$20k–\$50k');
      var loaded = cubit.state as ProductListingLoaded;
      expect(
        loaded.filteredProducts.map((p) => p.id).toSet(),
        {'mid-highrated', 'mid-lowrated'},
        reason: 'only the \$20k-\$50k band should remain before any rating '
            'filter is applied',
      );

      // Now layer "4 stars & up" on top — it must combine with (not
      // replace) the active price filter.
      cubit.applyRatingFilter('4★ & up');
      loaded = cubit.state as ProductListingLoaded;
      expect(
        loaded.filteredProducts.map((p) => p.id).toSet(),
        {'mid-highrated'},
        reason: 'must satisfy both the 4★+ rating AND the already-active '
            '\$20k-\$50k price filter at the same time',
      );
      expect(loaded.selectedRatingFilter, '4★ & up');
      expect(loaded.selectedPriceFilter, '\$20k–\$50k',
          reason: 'applying the rating filter must not clear the price '
              'filter that was already active');

      // Tapping "4 stars & up" again toggles it off, leaving only the
      // price filter applied.
      cubit.applyRatingFilter('4★ & up');
      loaded = cubit.state as ProductListingLoaded;
      expect(loaded.selectedRatingFilter, isNull);
      expect(
        loaded.filteredProducts.map((p) => p.id).toSet(),
        {'mid-highrated', 'mid-lowrated'},
        reason: 'clearing the rating filter must fall back to just the '
            'price filter, not clear everything',
      );
    },
  );

  test(
    'applying a sort while a filter is active reorders the list without '
    'disturbing the active filter',
    () async {
      final products = [
        _priced('cheap-highrated', 10000, rating: 4.5),
        _priced('cheap-lowrated', 15000, rating: 3.0),
        _priced('mid-highrated', 30000, rating: 4.8),
        _priced('mid-midrated', 35000, rating: 4.2),
        _priced('expensive-highrated', 60000, rating: 4.1),
      ];
      when(
        () => repository.fetchProducts(
          categoryUuid: any(named: 'categoryUuid'),
          page: any(named: 'page'),
          limit: any(named: 'limit'),
        ),
      ).thenAnswer((_) async => products);

      final cubit = ProductListingCubit(repository, cacheService);
      addTearDown(cubit.close);

      await cubit.loadCategory('Test Category', 'cat-sort');

      // Filter down to the 4★+ products first.
      cubit.applyRatingFilter('4★ & up');
      var loaded = cubit.state as ProductListingLoaded;
      expect(
        loaded.filteredProducts.map((p) => p.id).toSet(),
        {'cheap-highrated', 'mid-highrated', 'mid-midrated', 'expensive-highrated'},
      );

      // Sort by price (high to low) — must reorder the *filtered* set, not
      // bring back the excluded low-rated products.
      cubit.applySort(SortOption.priceHigh);
      loaded = cubit.state as ProductListingLoaded;
      expect(
        loaded.filteredProducts.map((p) => p.id).toList(),
        ['expensive-highrated', 'mid-midrated', 'mid-highrated', 'cheap-highrated'],
        reason: 'must be sorted by price descending within the filtered set',
      );
      expect(loaded.selectedRatingFilter, '4★ & up',
          reason: 'sorting must not clear the active rating filter');
      expect(loaded.selectedSort, SortOption.priceHigh);

      // Sort by rating instead — filter must still hold, only order changes.
      cubit.applySort(SortOption.rating);
      loaded = cubit.state as ProductListingLoaded;
      expect(
        loaded.filteredProducts.map((p) => p.id).toList(),
        ['mid-highrated', 'cheap-highrated', 'mid-midrated', 'expensive-highrated'],
        reason: 'must be sorted by rating descending within the filtered set',
      );
      expect(loaded.selectedRatingFilter, '4★ & up');
    },
  );

  test(
    'a narrow filter combo that matches nothing shows an empty-results '
    'state without crashing',
    () async {
      final products = [
        _priced('cheap-lowrated', 10000, rating: 3.0),
        _priced('mid-lowrated', 30000, rating: 2.5),
        _priced('expensive-highrated', 60000, rating: 4.8),
      ];
      when(
        () => repository.fetchProducts(
          categoryUuid: any(named: 'categoryUuid'),
          page: any(named: 'page'),
          limit: any(named: 'limit'),
        ),
      ).thenAnswer((_) async => products);

      final cubit = ProductListingCubit(repository, cacheService);
      addTearDown(cubit.close);

      await cubit.loadCategory('Test Category', 'cat-zero-results');

      // Under $20k AND 4★+ — no product in this fixture satisfies both.
      expect(
        () => cubit.applyPriceFilter('Under \$20k'),
        returnsNormally,
      );
      expect(
        () => cubit.applyRatingFilter('4★ & up'),
        returnsNormally,
      );

      final loaded = cubit.state as ProductListingLoaded;
      expect(loaded.filteredProducts, isEmpty,
          reason: 'no product satisfies both the price and rating filters');
      // The original, unfiltered list must be untouched so clearing filters
      // can restore it.
      expect(loaded.products.length, 3);
      expect(loaded.selectedPriceFilter, 'Under \$20k');
      expect(loaded.selectedRatingFilter, '4★ & up');

      // Sorting an already-empty filtered list must also not crash.
      expect(() => cubit.applySort(SortOption.priceLow), returnsNormally);
      final afterSort = cubit.state as ProductListingLoaded;
      expect(afterSort.filteredProducts, isEmpty);

      // Clearing filters must restore the full list.
      cubit.clearFilters();
      final cleared = cubit.state as ProductListingLoaded;
      expect(cleared.filteredProducts.length, 3);
      expect(cleared.selectedPriceFilter, isNull);
      expect(cleared.selectedRatingFilter, isNull);
    },
  );

  test(
    'toggling grid/list view mode switches the layout while preserving '
    'active filters, sort, and product state',
    () async {
      final products = [
        _priced('a', 25000, rating: 4.1),
        _priced('b', 22000, rating: 4.9),
        _priced('c', 40000, rating: 4.5),
        _priced('d-excluded', 15000, rating: 2.0),
      ];
      when(
        () => repository.fetchProducts(
          categoryUuid: any(named: 'categoryUuid'),
          page: any(named: 'page'),
          limit: any(named: 'limit'),
        ),
      ).thenAnswer((_) async => products);

      final cubit = ProductListingCubit(repository, cacheService);
      addTearDown(cubit.close);

      await cubit.loadCategory('Test Category', 'cat-view-mode');

      var loaded = cubit.state as ProductListingLoaded;
      expect(loaded.viewMode, ViewMode.grid,
          reason: 'grid is the default view mode');

      cubit.applyPriceFilter('\$20k–\$50k');
      cubit.applySort(SortOption.priceLow);

      final beforeToggle = cubit.state as ProductListingLoaded;
      final filteredBefore = beforeToggle.filteredProducts.map((p) => p.id).toList();

      cubit.toggleViewMode();
      var afterToggle = cubit.state as ProductListingLoaded;
      expect(afterToggle.viewMode, ViewMode.list,
          reason: 'first tap switches from grid to list');
      expect(afterToggle.filteredProducts.map((p) => p.id).toList(),
          filteredBefore,
          reason: 'toggling the layout must not disturb the filtered/'
              'sorted product list');
      expect(afterToggle.selectedPriceFilter, '\$20k–\$50k');
      expect(afterToggle.selectedSort, SortOption.priceLow);
      expect(afterToggle.products.length, 4,
          reason: 'the full underlying product list must be untouched too');

      cubit.toggleViewMode();
      afterToggle = cubit.state as ProductListingLoaded;
      expect(afterToggle.viewMode, ViewMode.grid,
          reason: 'second tap switches back from list to grid');
      expect(afterToggle.filteredProducts.map((p) => p.id).toList(),
          filteredBefore);
      expect(afterToggle.selectedPriceFilter, '\$20k–\$50k');
      expect(afterToggle.selectedSort, SortOption.priceLow);
    },
  );

  test(
    'a category with a multi-subcategory tree and >20 total products is '
    'not capped at a single page — every subcategory paginates',
    () async {
      const rootUuid = 'root-cat';
      when(() => repository.resolveCategoryUuids(rootUuid))
          .thenAnswer((_) async => ['sub-a', 'sub-b', 'sub-c']);

      when(
        () => repository.fetchProducts(
          categoryUuid: 'sub-a',
          page: any(named: 'page'),
          limit: any(named: 'limit'),
        ),
      ).thenAnswer((invocation) async {
        final page = invocation.namedArguments[#page] as int;
        // Full page 1, short (exhausted) page 2.
        return page == 1
            ? _fakeProducts(20, prefix: 'a$page')
            : _fakeProducts(10, prefix: 'a$page');
      });
      when(
        () => repository.fetchProducts(
          categoryUuid: 'sub-b',
          page: any(named: 'page'),
          limit: any(named: 'limit'),
        ),
      ).thenAnswer((invocation) async {
        final page = invocation.namedArguments[#page] as int;
        return page == 1
            ? _fakeProducts(20, prefix: 'b$page')
            : _fakeProducts(5, prefix: 'b$page');
      });
      when(
        () => repository.fetchProducts(
          categoryUuid: 'sub-c',
          page: any(named: 'page'),
          limit: any(named: 'limit'),
        ),
      ).thenAnswer((_) async => _fakeProducts(15, prefix: 'c'));

      final cubit = ProductListingCubit(repository, cacheService);
      addTearDown(cubit.close);

      await cubit.loadCategory('Root Category', rootUuid);

      var loaded = cubit.state as ProductListingLoaded;
      expect(loaded.products.length, 55,
          reason: 'sub-a(20) + sub-b(20) + sub-c(15) = 55 on page 1 alone — '
              'well beyond the old single-request 20-item cap');
      expect(loaded.hasMorePages, isTrue,
          reason: 'sub-a and sub-b returned full pages, so more should be '
              'available for them even though sub-c is exhausted');

      await cubit.loadMoreProducts();

      loaded = cubit.state as ProductListingLoaded;
      expect(loaded.products.length, 70,
          reason: 'page 2 must fetch only the non-exhausted subcategories '
              '(sub-a +10, sub-b +5) and append them — sub-c is skipped');
      expect(loaded.currentPage, 2);
      expect(loaded.hasMorePages, isFalse,
          reason: 'all three subcategories are now exhausted');

      // A further call is a no-op since pagination is exhausted.
      await cubit.loadMoreProducts();
      expect(cubit.state, same(loaded));
    },
  );

  test(
    'retryLoadCategory() on a fresh cubit with no prior loadCategory call '
    'silently no-ops instead of throwing or getting stuck',
    () async {
      final cubit = ProductListingCubit(repository, cacheService);
      addTearDown(cubit.close);

      final initialState = cubit.state;
      expect(initialState, isA<ProductListingLoading>(),
          reason: 'a fresh cubit starts in the loading state, before any '
              'load has ever run');

      await expectLater(cubit.retryLoadCategory(), completes,
          reason: 'must not throw when _lastCategoryName/_lastCategoryUuid '
              'were never set');

      expect(cubit.state, same(initialState),
          reason: 'state must be untouched — no fetch was ever triggered');
      verifyNever(
        () => repository.fetchProducts(
          categoryUuid: any(named: 'categoryUuid'),
          page: any(named: 'page'),
          limit: any(named: 'limit'),
        ),
      );

      // The Retry button only ever renders when state is
      // ProductListingError, which is unreachable without a prior
      // loadCategory() call — so this can't leave a user stuck on a dead
      // Retry button in practice. Confirm loadCategory still works
      // normally afterwards (the no-op didn't corrupt cubit state).
      when(
        () => repository.fetchProducts(
          categoryUuid: any(named: 'categoryUuid'),
          page: any(named: 'page'),
          limit: any(named: 'limit'),
        ),
      ).thenAnswer((_) async => _fakeProducts(2, prefix: 'z'));
      await cubit.loadCategory('Category Z', 'cat-z');
      final loaded = cubit.state as ProductListingLoaded;
      expect(loaded.products.map((p) => p.id), ['z-0', 'z-1']);
    },
  );

  group('loadBrand (Tap a brand)', () {
    test(
      'tapping a brand chip filters products by brandUuid — not the old '
      'behavior of dumping the user on the generic All Products screen',
      () async {
        when(
          () => repository.fetchProducts(
            categoryUuid: '',
            brandUuid: 'brand-uuid-123',
            page: any(named: 'page'),
            limit: any(named: 'limit'),
          ),
        ).thenAnswer((_) async => _fakeProducts(3, prefix: 'nike'));

        final cubit = ProductListingCubit(repository, cacheService);
        addTearDown(cubit.close);

        await cubit.loadBrand('Nike', 'brand-uuid-123');

        final loaded = cubit.state as ProductListingLoaded;
        expect(loaded.categoryName, 'Nike');
        expect(loaded.products.map((p) => p.id), ['nike-0', 'nike-1', 'nike-2']);

        // resolveCategoryUuids must never be called for a brand filter —
        // that endpoint resolves a CATEGORY tree and would return wrong
        // (or garbage) uuids if fed a brand uuid.
        verifyNever(() => repository.resolveCategoryUuids(any()));
      },
    );

    test(
      'loadMoreProducts() paginates a brand listing the same way it does '
      'for categories',
      () async {
        when(
          () => repository.fetchProducts(
            categoryUuid: '',
            brandUuid: 'brand-uuid-123',
            page: any(named: 'page'),
            limit: any(named: 'limit'),
          ),
        ).thenAnswer((invocation) async {
          final page = invocation.namedArguments[#page] as int;
          return page == 1
              ? _fakeProducts(20, prefix: 'p1')
              : _fakeProducts(5, prefix: 'p2');
        });

        final cubit = ProductListingCubit(repository, cacheService);
        addTearDown(cubit.close);

        await cubit.loadBrand('Nike', 'brand-uuid-123');
        var loaded = cubit.state as ProductListingLoaded;
        expect(loaded.products.length, 20);
        expect(loaded.hasMorePages, isTrue);

        await cubit.loadMoreProducts();
        loaded = cubit.state as ProductListingLoaded;
        expect(loaded.products.length, 25);
        expect(loaded.hasMorePages, isFalse);
      },
    );
  });
}
