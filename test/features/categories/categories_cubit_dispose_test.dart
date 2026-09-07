import 'dart:async';

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

void main() {
  test(
    'navigating away (closing the cubit) while loadData() is still in '
    'flight must not throw when the delayed response finally arrives',
    () async {
      final getCategories = MockGetCategoriesUseCase();
      final getBrands = MockGetBrandsUseCase();

      final categoriesCompleter =
          Completer<Either<Failure, List<CategoryEntity>>>();
      when(() => getCategories()).thenAnswer((_) => categoriesCompleter.future);
      when(() => getBrands()).thenAnswer((_) async => const Right([]));

      final cubit = CategoriesCubit(getCategories, getBrands);

      // Screen opens, loadData() starts and blocks on the slow categories
      // call — exactly like a real network request still in flight.
      final loadFuture = cubit.loadData();

      // User leaves the screen quickly: BlocProvider disposes and closes
      // the cubit while that call is still pending.
      await cubit.close();

      // The network response finally arrives after the screen (and cubit)
      // are already gone.
      categoriesCompleter.complete(const Right(<CategoryEntity>[]));

      // This must resolve quietly — no uncaught "Cannot emit new states
      // after calling close" StateError from the late emit().
      await expectLater(loadFuture, completes);
    },
  );
}
