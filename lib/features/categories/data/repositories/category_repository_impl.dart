import 'package:fpdart/fpdart.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/error/error_handler.dart';
import '../../../../core/error/failures.dart';

import '../../domain/entities/category_entity.dart';
import '../../domain/entities/sub_category_entity.dart';
import '../../domain/repositories/category_repository.dart';

import '../datasources/category_remote_datasource.dart';

@Injectable(as: CategoryRepository)
class CategoryRepositoryImpl implements CategoryRepository {
  final CategoryRemoteDataSource _remote;

  const CategoryRepositoryImpl(this._remote);

  @override
  Future<Either<Failure, List<CategoryEntity>>> getCategories() async {
    try {
      final response = await _remote.getCategories();

      final categories = response.data
          .where((e) => e.parentId == null && e.isActive)
          .map(
            (e) => CategoryEntity(
              id: e.id,
              uuid: e.uuid,
              name: e.name,
              slug: e.slug,
              description: e.description,
              image: e.image,
            ),
          )
          .toList();

      return Right(categories);
    } on Exception catch (e) {
      return Left(ErrorHandler.mapExceptionToFailure(e));
    }
  }

  @override
  Future<Either<Failure, List<CategoryBreadcrumbEntity>>> getBreadcrumb(
    String categoryUuid,
  ) async {
    try {
      return Right(await _remote.getBreadcrumb(categoryUuid));
    } on Exception catch (e) {
      return Left(ErrorHandler.mapExceptionToFailure(e));
    }
  }

  @override
  Future<Either<Failure, List<SubCategoryEntity>>> getSubCategories(
    String categoryUuid,
  ) async {
    try {
      return Right(await _remote.getSubCategories(categoryUuid));
    } on Exception catch (e) {
      return Left(ErrorHandler.mapExceptionToFailure(e));
    }
  }
}
