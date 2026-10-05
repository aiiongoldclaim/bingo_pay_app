import '../../domain/entities/sub_category_entity.dart';

/// Unwraps the `{ data: { data: [...] } }` envelope shared by the breadcrumb
/// and children endpoints.
List<Map<String, dynamic>> _unwrapList(Map<String, dynamic> json) {
  final outer = json['data'];
  final list = outer is Map<String, dynamic> ? outer['data'] : null;
  if (list is! List) {
    throw const FormatException('Invalid category list in response');
  }
  return list.whereType<Map<String, dynamic>>().toList();
}

class CategoryBreadcrumbModel extends CategoryBreadcrumbEntity {
  const CategoryBreadcrumbModel({
    required super.uuid,
    required super.name,
    required super.slug,
  });

  factory CategoryBreadcrumbModel.fromJson(Map<String, dynamic> json) =>
      CategoryBreadcrumbModel(
        uuid: json['uuid']?.toString() ?? '',
        name: json['name']?.toString() ?? '',
        slug: json['slug']?.toString() ?? '',
      );

  static List<CategoryBreadcrumbModel> listFromResponse(
    Map<String, dynamic> json,
  ) => _unwrapList(json).map(CategoryBreadcrumbModel.fromJson).toList();
}

class SubCategoryModel extends SubCategoryEntity {
  const SubCategoryModel({
    required super.uuid,
    required super.name,
    required super.slug,
    super.image,
    super.icon,
    super.hasChildren,
  });

  factory SubCategoryModel.fromJson(Map<String, dynamic> json) =>
      SubCategoryModel(
        uuid: json['uuid']?.toString() ?? '',
        name: json['name']?.toString() ?? '',
        slug: json['slug']?.toString() ?? '',
        image: json['image'] as String?,
        icon: json['icon'] as String?,
        hasChildren: json['hasChildren'] == true,
      );

  static List<SubCategoryModel> listFromResponse(Map<String, dynamic> json) =>
      _unwrapList(json).map(SubCategoryModel.fromJson).toList();
}
