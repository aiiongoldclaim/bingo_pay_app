import 'package:bingo_pay/core/error/failures.dart';
import 'package:bingo_pay/features/categories/domain/entities/category_entity.dart';
import 'package:bingo_pay/features/categories/domain/usecases/get_brands_usecase.dart';
import 'package:bingo_pay/features/categories/domain/usecases/get_categories_usecase.dart';
import 'package:bingo_pay/features/categories/presentation/cubit/categories_cubit.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:mocktail/mocktail.dart';

class MockGetCategoriesUseCase extends Mock implements GetCategoriesUseCase {}

class MockGetBrandsUseCase extends Mock implements GetBrandsUseCase {}

const _categories = [
  CategoryEntity(id: 'c1', uuid: 'c1', name: 'Electronics', slug: 'electronics'),
];

void main() {
  test(
    'brands API fails while categories succeed (partial failure) → '
    'categories still populate, brands surface an error/empty state',
    () async {
      final getCategories = MockGetCategoriesUseCase();
      final getBrands = MockGetBrandsUseCase();

      when(() => getCategories()).thenAnswer((_) async => const Right(_categories));
      when(() => getBrands()).thenAnswer(
        (_) async => const Left(
          ServerFailure(message: 'Failed to load brands', statusCode: 503),
        ),
      );

      final cubit = CategoriesCubit(getCategories, getBrands);
      addTearDown(cubit.close);

      await cubit.loadData();

      expect(cubit.state.isLoading, isFalse);
      expect(cubit.state.isBrandsLoading, isFalse);

      // Categories still render.
      expect(cubit.state.error, isNull,
          reason: 'categories succeeded — no dashboard-wide error');
      expect(cubit.state.categories, _categories,
          reason: 'the Categories grid must still populate');

      // Brands show error/empty, isolated from the categories success.
      expect(cubit.state.brands, isEmpty);
      expect(cubit.state.brandsError, 'Failed to load brands',
          reason: 'BrandsGrid renders its "Failed to load brands" message '
              'whenever brandsError is set');
    },
  );
}
