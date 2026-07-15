class BrandModel {
  final String id;
  final String uuid;
  final String name;
  final String slug;

  const BrandModel({
    required this.id,
    required this.uuid,
    required this.name,
    required this.slug,
  });

  factory BrandModel.fromJson(Map<String, dynamic> json) {
    return BrandModel(
      id: json['id'].toString(),
      uuid: json['uuid'] as String? ?? '',
      name: json['name'] as String? ?? '',
      slug: json['slug'] as String? ?? '',
    );
  }
}
