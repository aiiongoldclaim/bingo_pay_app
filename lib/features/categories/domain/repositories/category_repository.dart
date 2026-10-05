import 'package:fpdart/fpdart.dart';

import '../../../../core/error/failures.dart';
import '../entities/category_entity.dart';
import '../entities/sub_category_entity.dart';

abstract interface class CategoryRepository {
  Future<Either<Failure, List<CategoryEntity>>> getCategories();

  Future<Either<Failure, List<CategoryBreadcrumbEntity>>> getBreadcrumb(
    String categoryUuid,
  );

  Future<Either<Failure, List<SubCategoryEntity>>> getSubCategories(
    String categoryUuid,
  );
}
