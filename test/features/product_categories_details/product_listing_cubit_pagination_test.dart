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
}
