import 'package:bingo_pay/core/error/failures.dart';
import 'package:bingo_pay/features/categories/domain/entities/brand_entity.dart';
import 'package:bingo_pay/features/categories/domain/usecases/get_brands_usecase.dart';
import 'package:bingo_pay/features/categories/domain/usecases/get_categories_usecase.dart';
import 'package:bingo_pay/features/categories/presentation/cubit/categories_cubit.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:mocktail/mocktail.dart';

class MockGetCategoriesUseCase extends Mock implements GetCategoriesUseCase {}

class MockGetBrandsUseCase extends Mock implements GetBrandsUseCase {}

const _brands = [BrandEntity(id: 'b1', uuid: 'b1', name: 'Nova')];

void main() {
  test(
    'categories API failing (backend down) surfaces the failure via '
    'state.error, without getting stuck loading or wiped out by the '
    'brands fetch that runs alongside it',
    () async {
      final getCategories = MockGetCategoriesUseCase();
      final getBrands = MockGetBrandsUseCase();

      when(() => getCategories()).thenAnswer(
        (_) async => const Left(
          ServerFailure(message: 'Backend unavailable', statusCode: 503),
        ),
      );
      when(() => getBrands()).thenAnswer((_) async => const Right(_brands));

      final cubit = CategoriesCubit(getCategories, getBrands);
      addTearDown(cubit.close);

      await cubit.loadData();

      expect(cubit.state.isLoading, isFalse);
      expect(cubit.state.error, 'Backend unavailable',
          reason: 'the categories failure must be surfaced via state.error');
      expect(cubit.state.categories, isEmpty,
          reason: 'no categories were returned, the grid stays empty');

      // The brands fetch ran independently and succeeded — its own
      // isBrandsLoading flag must resolve too, not get stuck true because
      // categories failed.
      expect(cubit.state.isBrandsLoading, isFalse);
      expect(cubit.state.brands, _brands);
      expect(cubit.state.brandsError, isNull);
    },
  );
}
