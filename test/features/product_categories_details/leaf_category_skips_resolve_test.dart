import 'package:bingo_pay/features/product_categories_details/data/models/product_categories_model.dart';
import 'package:bingo_pay/features/product_categories_details/data/services/product_cache_service.dart';
import 'package:bingo_pay/features/product_categories_details/domain/repositories/product_listing_repository.dart';
import 'package:bingo_pay/features/product_categories_details/presentation/product_categories_cubit/product_categories_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MockProductListingRepository extends Mock
    implements ProductListingRepository {}

const _electronics = 'electronics-uuid';
const _watch = 'watch-uuid';
const _tws = 'tws-uuid';

void main() {
  late MockProductListingRepository repository;
  late ProductCacheService cacheService;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    cacheService = ProductCacheService(await SharedPreferences.getInstance());
    repository = MockProductListingRepository();
    // Electronics has two children; anything else is a leaf.
    when(() => repository.resolveCategoryUuids(any())).thenAnswer((inv) async {
      final uuid = inv.positionalArguments[0] as String;
      return uuid == _electronics ? [_electronics, _watch, _tws] : [uuid];
    });
    when(
      () => repository.fetchProducts(
        categoryUuid: any(named: 'categoryUuid'),
        page: any(named: 'page'),
        limit: any(named: 'limit'),
      ),
    ).thenAnswer(
      (inv) async => [
        ListingProductModel(
          id: inv.namedArguments[#categoryUuid] as String,
          uuid: inv.namedArguments[#categoryUuid] as String,
          brand: 'Brand',
          name: 'Product',
          price: 100,
          icon: Icons.shopping_cart_outlined,
        ),
      ],
    );
  });

  List<String> fetchedUuids() => verify(
    () => repository.fetchProducts(
      categoryUuid: captureAny(named: 'categoryUuid'),
      page: any(named: 'page'),
      limit: any(named: 'limit'),
    ),
  ).captured.cast<String>();

  test('a leaf sub-category (Electronics › watch) fetches products by its own '
      'uuid only and never calls the category list', () async {
    final cubit = ProductListingCubit(repository, cacheService);
    addTearDown(cubit.close);

    await cubit.loadCategory('watch', _watch, isLeaf: true);

    verifyNever(() => repository.resolveCategoryUuids(any()));
    expect(fetchedUuids(), [_watch]);
  });

  test('a parent category ("All Electronics products") still includes its '
      'sub-categories', () async {
    final cubit = ProductListingCubit(repository, cacheService);
    addTearDown(cubit.close);

    await cubit.loadCategory('Electronics', _electronics);

    verify(() => repository.resolveCategoryUuids(_electronics)).called(1);
    expect(fetchedUuids(), unorderedEquals([_electronics, _watch, _tws]));
  });
}
