class VendorProductMedia {
  final String url;
  final bool isPrimary;

  const VendorProductMedia({required this.url, required this.isPrimary});

  factory VendorProductMedia.fromJson(Map<String, dynamic> json) {
    return VendorProductMedia(
      url: json['url'] as String? ?? '',
      isPrimary: json['isPrimary'] as bool? ?? false,
    );
  }
}

class VendorProductCategory {
  final String name;
  final String slug;

  const VendorProductCategory({required this.name, required this.slug});

  factory VendorProductCategory.fromJson(Map<String, dynamic> json) {
    return VendorProductCategory(
      name: json['name'] as String? ?? '',
      slug: json['slug'] as String? ?? '',
    );
  }
}

class VendorProductModel {
  final String id;
  final String uuid;
  final String title;
  final String shortDescription;
  final String status;
  final bool isPublished;
  final VendorProductCategory? category;
  final List<VendorProductMedia> media;

  const VendorProductModel({
    required this.id,
    required this.uuid,
    required this.title,
    required this.shortDescription,
    required this.status,
    required this.isPublished,
    required this.category,
    required this.media,
  });

  String get primaryImageUrl {
    final primary = media.where((m) => m.isPrimary).firstOrNull;
    return primary?.url ?? media.firstOrNull?.url ?? '';
  }

  factory VendorProductModel.fromJson(Map<String, dynamic> json) {
    final categoryJson = json['category'];
    VendorProductCategory? category;
    if (categoryJson is Map<String, dynamic>) {
      category = VendorProductCategory.fromJson(categoryJson);
    }

    final mediaList = (json['media'] as List<dynamic>? ?? [])
        .map((m) => VendorProductMedia.fromJson(m as Map<String, dynamic>))
        .toList();

    return VendorProductModel(
      id: json['id']?.toString() ?? '',
      uuid: json['uuid'] as String? ?? '',
      title: json['title'] as String? ?? '',
      shortDescription: json['shortDescription'] as String? ?? '',
      status: json['status'] as String? ?? '',
      isPublished: json['isPublished'] as bool? ?? false,
      category: category,
      media: mediaList,
    );
  }

  static List<VendorProductModel> listFromResponse(Map<String, dynamic> json) {
    final data = json['data'];
    List<dynamic> items = [];
    if (data is Map<String, dynamic>) {
      final inner = data['data'];
      if (inner is List) items = inner;
    } else if (data is List) {
      items = data;
    }
    return items
        .map((e) => VendorProductModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }
}
