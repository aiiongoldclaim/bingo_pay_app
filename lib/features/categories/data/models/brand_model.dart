class BrandModel {
  final String id;
  final String uuid;
  final String name;
  final String? logo;
  final String? description;
  final bool isActive;

  const BrandModel({
    required this.id,
    required this.uuid,
    required this.name,
    this.logo,
    this.description,
    this.isActive = true,
  });

  factory BrandModel.fromJson(Map<String, dynamic> json) => BrandModel(
        id: json['id'] as String? ?? '',
        uuid: json['uuid'] as String? ?? '',
        name: json['name'] as String,
        logo: json['logo'] as String?,
        description: json['description'] as String?,
        isActive: json['isActive'] as bool? ?? true,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'uuid': uuid,
        'name': name,
        'logo': logo,
        'description': description,
        'isActive': isActive,
      };
}
