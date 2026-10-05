import 'package:fpdart/fpdart.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/error/failures.dart';
import '../entities/sub_category_entity.dart';
import '../repositories/category_repository.dart';

@injectable
class GetCategoryBreadcrumbUseCase {
  final CategoryRepository repository;

  const GetCategoryBreadcrumbUseCase(this.repository);

  Future<Either<Failure, List<CategoryBreadcrumbEntity>>> call(
    String categoryUuid,
  ) {
    return repository.getBreadcrumb(categoryUuid);
  }
}

@injectable
class GetSubCategoriesUseCase {
  final CategoryRepository repository;

  const GetSubCategoriesUseCase(this.repository);

  Future<Either<Failure, List<SubCategoryEntity>>> call(String categoryUuid) {
    return repository.getSubCategories(categoryUuid);
  }
}
