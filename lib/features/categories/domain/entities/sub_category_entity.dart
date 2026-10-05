import 'package:equatable/equatable.dart';

/// One step of a category's path, from the root down to the category itself
/// (`GET /api/v1/categories/{uuid}/breadcrumb`).
class CategoryBreadcrumbEntity extends Equatable {
  final String uuid;
  final String name;
  final String slug;

  const CategoryBreadcrumbEntity({
    required this.uuid,
    required this.name,
    required this.slug,
  });

  @override
  List<Object?> get props => [uuid, name, slug];
}

/// A direct child of a category (`GET /api/v1/categories/{uuid}/children`).
class SubCategoryEntity extends Equatable {
  final String uuid;
  final String name;
  final String slug;
  final String? image;
  final String? icon;
  final bool hasChildren;

  const SubCategoryEntity({
    required this.uuid,
    required this.name,
    required this.slug,
    this.image,
    this.icon,
    this.hasChildren = false,
  });

  @override
  List<Object?> get props => [uuid, name, slug, image, icon, hasChildren];
}
