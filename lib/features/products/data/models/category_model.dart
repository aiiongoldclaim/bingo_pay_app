class CategoryModel {
  final String id;
  final String uuid;
  final String name;
  final String slug;
  final String? parentId;
  final int depth;
  final List<CategoryModel> children;

  const CategoryModel({
    required this.id,
    required this.uuid,
    required this.name,
    required this.slug,
    this.parentId,
    this.depth = 0,
    this.children = const [],
  });

  factory CategoryModel.fromJson(Map<String, dynamic> json) {
    final childrenJson = json['children'] as List?;
    return CategoryModel(
      id: json['id'].toString(),
      uuid: json['uuid'] as String? ?? '',
      name: json['name'] as String? ?? '',
      slug: json['slug'] as String? ?? '',
      parentId: json['parentId']?.toString(),
      depth: json['depth'] as int? ?? 0,
      children: childrenJson
              ?.whereType<Map>()
              .map((e) => CategoryModel.fromJson(e.map((k, v) => MapEntry(k.toString(), v))))
              .toList() ??
          [],
    );
  }
}
