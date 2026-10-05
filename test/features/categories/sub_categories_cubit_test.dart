import 'dart:async';

import 'package:bingo_pay/core/error/failures.dart';
import 'package:bingo_pay/features/categories/domain/entities/sub_category_entity.dart';
import 'package:bingo_pay/features/categories/domain/usecases/get_sub_categories_usecase.dart';
import 'package:bingo_pay/features/categories/presentation/cubit/sub_categories_cubit.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:mocktail/mocktail.dart';

class MockBreadcrumb extends Mock implements GetCategoryBreadcrumbUseCase {}

class MockChildren extends Mock implements GetSubCategoriesUseCase {}

const _crumbs = [
  CategoryBreadcrumbEntity(uuid: 'e', name: 'Electronics', slug: 'electronics'),
];
const _watch = SubCategoryEntity(uuid: 'w', name: 'watch', slug: 'watch');
const _tws = SubCategoryEntity(uuid: 't', name: 'tws', slug: 'tws');

void main() {
  late MockBreadcrumb breadcrumb;
  late MockChildren children;
  late SubCategoriesCubit cubit;

  setUp(() {
    breadcrumb = MockBreadcrumb();
    children = MockChildren();
    cubit = SubCategoriesCubit(breadcrumb, children);
    when(() => breadcrumb(any())).thenAnswer((_) async => const Right(_crumbs));
  });

  tearDown(() => cubit.close());

  test('success fills breadcrumb and sub-categories', () async {
    when(
      () => children(any()),
    ).thenAnswer((_) async => const Right([_watch, _tws]));

    final load = cubit.load('e');
    expect(cubit.state.isLoading, isTrue);
    await load;

    expect(cubit.state.isLoading, isFalse);
    expect(cubit.state.breadcrumb, _crumbs);
    expect(cubit.state.subCategories, [_watch, _tws]);
    expect(cubit.state.error, isNull);
  });

  test('a failed refresh shows the error but keeps the cards', () async {
    when(() => children(any())).thenAnswer((_) async => const Right([_watch]));
    await cubit.load('e');

    when(
      () => children(any()),
    ).thenAnswer((_) async => Left(ServerFailure(message: 'Server down')));
    await cubit.load('e');

    expect(cubit.state.error, 'Server down');
    expect(cubit.state.subCategories, [_watch]);
  });

  test('a failed breadcrumb does not hide the sub-categories', () async {
    when(
      () => breadcrumb(any()),
    ).thenAnswer((_) async => Left(ServerFailure(message: 'x')));
    when(() => children(any())).thenAnswer((_) async => const Right([_watch]));

    await cubit.load('e');

    expect(cubit.state.error, isNull);
    expect(cubit.state.subCategories, [_watch]);
  });

  test('an older response arriving late is ignored', () async {
    final slow = Completer<Either<Failure, List<SubCategoryEntity>>>();
    when(() => children('old')).thenAnswer((_) => slow.future);
    when(() => children('new')).thenAnswer((_) async => const Right([_tws]));

    final oldLoad = cubit.load('old');
    await cubit.load('new');
    slow.complete(const Right([_watch]));
    await oldLoad;

    expect(cubit.state.subCategories, [_tws]);
  });
}
