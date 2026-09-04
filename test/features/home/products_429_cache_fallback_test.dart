import 'package:bingo_pay/core/api/api_client.dart';
import 'package:bingo_pay/core/services/product_cache_service.dart';
import 'package:bingo_pay/features/account/domain/enities/account_entity.dart';
import 'package:bingo_pay/features/account/domain/usecase/get_account_usecase.dart';
import 'package:bingo_pay/features/categories/data/datasources/category_remote_datasource.dart';
import 'package:bingo_pay/features/categories/data/models/categories_model.dart';
import 'package:bingo_pay/features/categories/data/models/categories_response_model.dart';
import 'package:bingo_pay/features/home/data/models/product_model.dart';
import 'package:bingo_pay/features/home/data/repositories/all_products_repo.dart';
import 'package:bingo_pay/features/home/domain/repositories/product_repository_impl.dart';
import 'package:bingo_pay/features/home/presentation/cubit/dashboard_cubit.dart';
import 'package:bingo_pay/features/home/presentation/cubit/dashboard_state.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MockApiClient extends Mock implements ApiClient {}

class MockDio extends Mock implements Dio {}

class MockCategoryRemoteDataSource extends Mock
    implements CategoryRemoteDataSource {}

class MockGetProfileUseCase extends Mock implements GetProfileUseCase {}

class MockProductRepository extends Mock implements ProductRepository {}

Map<String, dynamic> _fakeProductJson(String id) => {
      'uuid': id,
      'brand': {'name': 'Brand'},
      'title': 'Product $id',
      'media': <dynamic>[],
      'variants': <dynamic>[],
      'isFeatured': false,
    };

DioException _throttled() => DioException(
      requestOptions: RequestOptions(path: '/api/v1/products'),
      response: Response(
        requestOptions: RequestOptions(path: '/api/v1/products'),
        statusCode: 429,
      ),
      type: DioExceptionType.badResponse,
    );

void main() {
  setUpAll(() {
    registerFallbackValue(<String, dynamic>{});
  });

  group('ProductRepositoryImpl 429 handling', () {
    late MockApiClient apiClient;
    late MockDio dio;
    late ProductCacheService cacheService;
    late ProductRepositoryImpl repository;

    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      cacheService = ProductCacheService(await SharedPreferences.getInstance());
      apiClient = MockApiClient();
      dio = MockDio();
      when(() => apiClient.dio).thenReturn(dio);
      repository =
          ProductRepositoryImpl(apiClient: apiClient, cacheService: cacheService);
    });

    test('falls back to cached products on a 429 without throwing', () async {
      final cached = [
        ProductModel.fromJson(_fakeProductJson('cached-1')),
        ProductModel.fromJson(_fakeProductJson('cached-2')),
      ];
      await cacheService.cacheHomeProducts(cached);

      when(
        () => dio.get(any(), queryParameters: any(named: 'queryParameters')),
      ).thenThrow(_throttled());

      final result = await repository.getAllProducts(page: 1, limit: 20);

      expect(result.length, 2);
      expect(result.map((p) => p.uuid), containsAll(['cached-1', 'cached-2']));
    });

    test('rethrows the 429 when no cache is available', () async {
      when(
        () => dio.get(any(), queryParameters: any(named: 'queryParameters')),
      ).thenThrow(_throttled());

      await expectLater(
        repository.getAllProducts(page: 1, limit: 20),
        throwsA(isA<DioException>()),
      );
    });

    test(
      'a 200 with an empty page-1 list returns empty, not stale cache',
      () async {
        // A prior successful load left products in the cache — a genuinely
        // empty catalogue response must not fall back to this stale data.
        await cacheService.cacheHomeProducts([
          ProductModel.fromJson(_fakeProductJson('stale-1')),
        ]);

        when(
          () =>
              dio.get(any(), queryParameters: any(named: 'queryParameters')),
        ).thenAnswer(
          (_) async => Response(
            requestOptions: RequestOptions(path: '/api/v1/products'),
            statusCode: 200,
            data: {
              'data': {'data': <dynamic>[]},
            },
          ),
        );

        final result = await repository.getAllProducts(page: 1, limit: 20);

        expect(result, isEmpty,
            reason: 'an empty 200 response is not an error — it must not '
                'be masked by whatever is sitting in the cache');
      },
    );
  });

  group('HomeCubit surfaces the 429 cache fallback without a hard error', () {
    test(
      'products API throttled but cache has data → loaded, not error, products shown',
      () async {
        final categoryDataSource = MockCategoryRemoteDataSource();
        final getProfile = MockGetProfileUseCase();
        final productRepository = MockProductRepository();

        when(() => categoryDataSource.getCategories()).thenAnswer(
          (_) async => const CategoryResponseModel(success: true, data: []),
        );
        when(() => getProfile()).thenAnswer(
          (_) async => const Right(
            AccountEntity(
              id: 'u1',
              uuid: 'u1',
              fullName: 'Test User',
              email: 'test@example.com',
              phone: '',
              kycStatus: KycStatus.approved,
              emailVerified: true,
              phoneVerified: true,
            ),
          ),
        );
        // The repository itself already resolved the 429 via cache — from
        // HomeCubit's perspective this call just succeeds with cached data.
        final cachedProducts = [
          ProductModel.fromJson(_fakeProductJson('cached-1')),
        ];
        when(() => productRepository.getAllProducts(page: 1, limit: 20))
            .thenAnswer((_) async => cachedProducts);

        final cubit =
            HomeCubit(categoryDataSource, getProfile, productRepository);
        addTearDown(cubit.close);

        await cubit.loadHome();

        expect(cubit.state.status, HomeStatus.loaded,
            reason: 'a 429 the repository already recovered from cache '
                'must not surface as a dashboard error');
        expect(cubit.state.recommended.length, 1);
      },
    );

    test(
      'products API returns an empty page-1 list → empty state, not stale cache',
      () async {
        final categoryDataSource = MockCategoryRemoteDataSource();
        final getProfile = MockGetProfileUseCase();
        final productRepository = MockProductRepository();

        when(() => categoryDataSource.getCategories()).thenAnswer(
          (_) async => const CategoryResponseModel(success: true, data: []),
        );
        when(() => getProfile()).thenAnswer(
          (_) async => const Right(
            AccountEntity(
              id: 'u1',
              uuid: 'u1',
              fullName: 'Test User',
              email: 'test@example.com',
              phone: '',
              kycStatus: KycStatus.approved,
              emailVerified: true,
              phoneVerified: true,
            ),
          ),
        );
        // The repository already resolved a genuinely empty 200 to [] —
        // HomeCubit must render that as the empty state, not go hunting
        // for stale data anywhere itself.
        when(() => productRepository.getAllProducts(page: 1, limit: 20))
            .thenAnswer((_) async => <ProductModel>[]);

        final cubit =
            HomeCubit(categoryDataSource, getProfile, productRepository);
        addTearDown(cubit.close);

        await cubit.loadHome();

        expect(cubit.state.status, HomeStatus.loaded);
        expect(cubit.state.flashDeals, isEmpty);
        expect(cubit.state.recommended, isEmpty);
      },
    );

    test(
      'products API fails and cache is also empty (fresh install, offline) '
      '→ empty product list, HomeStatus.loaded, no failure messaging',
      () async {
        final categoryDataSource = MockCategoryRemoteDataSource();
        final getProfile = MockGetProfileUseCase();
        final productRepository = MockProductRepository();

        // Categories and profile succeed — only the products fetch (with
        // an exhausted cache fallback) is down, so this must stay a
        // graceful partial-content load, not the all-three-failed error
        // state.
        when(() => categoryDataSource.getCategories()).thenAnswer(
          (_) async => const CategoryResponseModel(success: true, data: []),
        );
        when(() => getProfile()).thenAnswer(
          (_) async => const Right(
            AccountEntity(
              id: 'u1',
              uuid: 'u1',
              fullName: 'Test User',
              email: 'test@example.com',
              phone: '',
              kycStatus: KycStatus.approved,
              emailVerified: true,
              phoneVerified: true,
            ),
          ),
        );
        // Mirrors ProductRepositoryImpl on a fresh install: API call fails
        // and there's no cache to fall back to, so it rethrows.
        when(() => productRepository.getAllProducts(page: 1, limit: 20))
            .thenThrow(Exception('Network unreachable'));

        final cubit =
            HomeCubit(categoryDataSource, getProfile, productRepository);
        addTearDown(cubit.close);

        await cubit.loadHome();

        expect(cubit.state.status, HomeStatus.loaded,
            reason: 'products alone failing with nothing to fall back to '
                'must not surface as a dashboard-wide error');
        expect(cubit.state.flashDeals, isEmpty);
        expect(cubit.state.recommended, isEmpty);
        expect(cubit.state.errorMessage, isNull,
            reason: 'no explicit failure messaging should be attached');
      },
    );
  });
}
