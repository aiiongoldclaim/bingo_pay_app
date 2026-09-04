import 'dart:async';

import 'package:bingo_pay/features/account/domain/enities/account_entity.dart';
import 'package:bingo_pay/features/account/domain/usecase/get_account_usecase.dart';
import 'package:bingo_pay/features/categories/data/datasources/category_remote_datasource.dart';
import 'package:bingo_pay/features/categories/data/models/categories_response_model.dart';
import 'package:bingo_pay/features/home/data/models/product_model.dart';
import 'package:bingo_pay/features/home/data/repositories/all_products_repo.dart';
import 'package:bingo_pay/features/home/presentation/cubit/dashboard_cubit.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:mocktail/mocktail.dart';

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

const _account = AccountEntity(
  id: 'u1',
  uuid: 'u1',
  fullName: 'Test User',
  email: 'test@example.com',
  phone: '',
  kycStatus: KycStatus.approved,
  emailVerified: true,
  phoneVerified: true,
);

void main() {
  test(
    'a stale loadHome() response (slow network) cannot overwrite a newer '
    'pull-to-refresh that started after it and finished first',
    () async {
      final categoryDataSource = MockCategoryRemoteDataSource();
      final getProfile = MockGetProfileUseCase();
      final productRepository = MockProductRepository();

      when(() => categoryDataSource.getCategories()).thenAnswer(
        (_) async => const CategoryResponseModel(success: true, data: []),
      );
      when(() => getProfile()).thenAnswer((_) async => const Right(_account));

      // First loadHome()'s products fetch hangs on a slow network — held
      // open until the test manually completes it, well after the second
      // call has already finished.
      final firstCallCompleter = Completer<List<ProductModel>>();
      var callCount = 0;
      when(() => productRepository.getAllProducts(page: 1, limit: 20))
          .thenAnswer((_) {
        callCount++;
        if (callCount == 1) return firstCallCompleter.future;
        return Future.value([
          ProductModel.fromJson(_fakeProductJson('fresh-from-second-call')),
        ]);
      });

      final cubit = HomeCubit(categoryDataSource, getProfile, productRepository);
      addTearDown(cubit.close);

      // Trigger refresh twice quickly, exactly like a user double-pulling
      // pull-to-refresh before the first request has come back.
      final firstLoad = cubit.loadHome();
      final secondLoad = cubit.loadHome();

      // The second (fast) call resolves completely first.
      await secondLoad;
      expect(
        cubit.state.recommended.map((p) => p.uuid),
        ['fresh-from-second-call'],
      );

      // Only now does the first (slow, stale) call's network response
      // finally arrive.
      firstCallCompleter.complete([
        ProductModel.fromJson(_fakeProductJson('stale-from-first-call')),
      ]);
      await firstLoad;

      // The stale response must not have clobbered the newer state.
      expect(
        cubit.state.recommended.map((p) => p.uuid),
        ['fresh-from-second-call'],
        reason: 'a request-id guard must drop the first call\'s late, '
            'superseded response instead of letting it overwrite the '
            'second (later-triggered) call\'s already-rendered result',
      );
    },
  );
}
