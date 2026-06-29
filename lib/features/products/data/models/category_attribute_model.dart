class CategoryAttributeModel {
  final String id;
  final String uuid;
  final String name;
  final String slug;
  final String fieldType;
  final bool isRequired;
  final bool isVariant;
  final String categoryUuid;
  final int sortOrder;

  const CategoryAttributeModel({
    required this.id,
    required this.uuid,
    required this.name,
    required this.slug,
    required this.fieldType,
    required this.isRequired,
    required this.isVariant,
    required this.categoryUuid,
    required this.sortOrder,
  });

  factory CategoryAttributeModel.fromJson(Map<String, dynamic> json) {
    final category = json['category'] as Map<String, dynamic>?;
    return CategoryAttributeModel(
      id: json['id'].toString(),
      uuid: json['uuid'] as String? ?? '',
      name: json['name'] as String? ?? '',
      slug: json['slug'] as String? ?? '',
      fieldType: json['fieldType'] as String? ?? 'TEXT',
      isRequired: json['isRequired'] as bool? ?? false,
      isVariant: json['isVariant'] as bool? ?? false,
      categoryUuid: category?['uuid'] as String? ?? '',
      sortOrder: json['sortOrder'] as int? ?? 0,
    );
  }
}
