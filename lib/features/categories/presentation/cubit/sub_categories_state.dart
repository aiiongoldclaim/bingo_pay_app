import 'package:equatable/equatable.dart';

import '../../domain/entities/sub_category_entity.dart';

class SubCategoriesState extends Equatable {
  final bool isLoading;

  /// Path at the top, e.g. Categories › Electronics › watch.
  final List<CategoryBreadcrumbEntity> breadcrumb;

  /// Cards in the grid.
  final List<SubCategoryEntity> subCategories;

  /// Error message when loading failed, otherwise null.
  final String? error;

  const SubCategoriesState({
    this.isLoading = false,
    this.breadcrumb = const [],
    this.subCategories = const [],
    this.error,
  });

  @override
  List<Object?> get props => [isLoading, breadcrumb, subCategories, error];
}
