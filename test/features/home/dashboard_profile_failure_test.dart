import 'package:bingo_pay/core/error/failures.dart';
import 'package:bingo_pay/features/account/domain/usecase/get_account_usecase.dart';
import 'package:bingo_pay/features/categories/data/datasources/category_remote_datasource.dart';
import 'package:bingo_pay/features/categories/data/models/categories_response_model.dart';
import 'package:bingo_pay/features/home/data/models/product_model.dart';
import 'package:bingo_pay/features/home/data/repositories/all_products_repo.dart';
import 'package:bingo_pay/features/home/presentation/cubit/dashboard_cubit.dart';
import 'package:bingo_pay/features/home/presentation/cubit/dashboard_state.dart';
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

void main() {
  test(
    'profile endpoint 500s while categories and products succeed → '
    'userName/balance silently default to \'\'/0.0, dashboard still loads, '
    'no dashboard-wide error',
    () async {
      final categoryDataSource = MockCategoryRemoteDataSource();
      final getProfile = MockGetProfileUseCase();
      final productRepository = MockProductRepository();

      when(() => categoryDataSource.getCategories()).thenAnswer(
        (_) async => const CategoryResponseModel(success: true, data: []),
      );
      // Profile endpoint 500s.
      when(() => getProfile()).thenAnswer(
        (_) async => const Left(
          ServerFailure(message: 'Internal server error', statusCode: 500),
        ),
      );
      when(() => productRepository.getAllProducts(page: 1, limit: 20))
          .thenAnswer(
        (_) async => [ProductModel.fromJson(_fakeProductJson('p1'))],
      );

      final cubit =
          HomeCubit(categoryDataSource, getProfile, productRepository);
      addTearDown(cubit.close);

      await cubit.loadHome();

      expect(cubit.state.status, HomeStatus.loaded,
          reason: 'products/categories succeeded, so this must stay a '
              'graceful partial load, not the all-three-failed error state');
      expect(cubit.state.userName, '',
          reason: 'no profile data — name silently defaults to empty');
      expect(cubit.state.bigoldBalance, 0.0,
          reason: 'no profile data — balance silently defaults to zero');
      expect(cubit.state.errorMessage, isNull,
          reason: 'a profile-only failure must not surface as a visible '
              'dashboard error');
      // The rest of the dashboard still renders normally.
      expect(cubit.state.recommended, isNotEmpty);
    },
  );
}
