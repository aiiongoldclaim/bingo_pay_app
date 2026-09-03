import 'package:bingo_pay/core/api/api_client.dart';
import 'package:bingo_pay/features/product_categories_details/presentation/product_categories_cubit/product_categories_cubit.dart';
import 'package:bingo_pay/features/product_categories_details/presentation/product_categories_cubit/product_categories_state.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_flavor/flutter_flavor.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MockApiClient extends Mock implements ApiClient {}

class MockDio extends Mock implements Dio {}

Map<String, dynamic> _fakeProduct(String id) => {
      'id': id,
      'uuid': id,
      'media': <dynamic>[],
      'variants': <dynamic>[],
      'brand': {'name': 'Brand'},
      'title': 'Product $id',
      'isFeatured': false,
    };

Response<dynamic> _productsResponse(int count, {required String prefix}) {
  return Response(
    requestOptions: RequestOptions(path: '/api/v1/products'),
    data: {
      'data': {
        'data': List.generate(count, (i) => _fakeProduct('$prefix-$i')),
      },
    },
  );
}

void main() {
  late MockApiClient apiClient;
  late MockDio dio;

  setUpAll(() {
    registerFallbackValue(<String, dynamic>{});
    // AppConfig.apiBaseUrl reads from FlavorConfig.instance, which is only
    // set up by the real app entrypoints (main_dev.dart etc). Without this,
    // fetching a page throws before dio.get is ever reached.
    FlavorConfig(
      name: 'test',
      color: Colors.green,
      variables: const {
        'apiBaseUrl': 'https://test.invalid',
        'apiKey': 'test-key',
      },
    );
  });

  setUp(() {
    SharedPreferences.setMockInitialValues({});
    apiClient = MockApiClient();
    dio = MockDio();
    when(() => apiClient.dio).thenReturn(dio);
    if (GetIt.I.isRegistered<ApiClient>()) {
      GetIt.I.unregister<ApiClient>();
    }
    GetIt.I.registerSingleton<ApiClient>(apiClient);
  });

  tearDown(() {
    if (GetIt.I.isRegistered<ApiClient>()) {
      GetIt.I.unregister<ApiClient>();
    }
  });

  test(
    'loadMoreProducts appends the next page and stops once a page is short',
    () async {
      // Page 1 is a full page (20) so more should be available; page 2
      // comes back short (5), which should mark that UUID exhausted.
      when(
        () => dio.get(any(), queryParameters: any(named: 'queryParameters')),
      ).thenAnswer((invocation) async {
        final params =
            invocation.namedArguments[#queryParameters] as Map<String, dynamic>;
        final page = params['page'] as int;
        if (page == 1) return _productsResponse(20, prefix: 'p1');
        if (page == 2) return _productsResponse(5, prefix: 'p2');
        return _productsResponse(0, prefix: 'p3');
      });

      final cubit = ProductListingCubit();
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
      () => dio.get(any(), queryParameters: any(named: 'queryParameters')),
    ).thenAnswer((_) async => _productsResponse(20, prefix: 'dup'));

    final cubit = ProductListingCubit();
    addTearDown(cubit.close);

    await cubit.loadCategory('Test Category', '');
    await cubit.loadMoreProducts();

    final state = cubit.state as ProductListingLoaded;
    expect(state.products.length, 20,
        reason: 'repeated ids from the next page must not duplicate entries');
  });
}
