import 'package:bingo_pay/features/categories/domain/entities/brand_entity.dart';
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
  CategoryEntity(id: 'c2', uuid: 'c2', name: 'Fashion', slug: 'fashion'),
];

const _brands = [
  BrandEntity(id: 'b1', uuid: 'b1', name: 'Nova'),
  BrandEntity(id: 'b2', uuid: 'b2', name: 'Sonara'),
];

void main() {
  test(
    'loadData() populates both the categories grid and the brands grid '
    'when both fetches succeed',
    () async {
      final getCategories = MockGetCategoriesUseCase();
      final getBrands = MockGetBrandsUseCase();

      when(() => getCategories()).thenAnswer((_) async => const Right(_categories));
      when(() => getBrands()).thenAnswer((_) async => const Right(_brands));

      final cubit = CategoriesCubit(getCategories, getBrands);
      addTearDown(cubit.close);

      await cubit.loadData();

      expect(cubit.state.isLoading, isFalse);
      expect(cubit.state.isBrandsLoading, isFalse);
      expect(cubit.state.error, isNull);
      expect(cubit.state.brandsError, isNull);
      expect(cubit.state.categories, _categories,
          reason: 'the Categories grid must be populated');
      expect(cubit.state.brands, _brands,
          reason: 'the Top Brands grid must be populated');
    },
  );
}
