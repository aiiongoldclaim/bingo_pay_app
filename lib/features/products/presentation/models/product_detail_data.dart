import 'product_mock_data.dart';

class ProductMedia {
  final String url;
  final String? altText;
  final bool isPrimary;

  const ProductMedia({required this.url, this.altText, this.isPrimary = false});

  factory ProductMedia.fromApi(Map<String, dynamic> json) {
    return ProductMedia(
      url: json['url']?.toString() ?? '',
      altText: json['altText']?.toString(),
      isPrimary: json['isPrimary'] == true,
    );
  }
}

class ProductBrandInfo {
  final String uuid;
  final String name;
  final String? logo;

  const ProductBrandInfo({required this.uuid, required this.name, this.logo});

  factory ProductBrandInfo.fromApi(Map<String, dynamic> json) {
    return ProductBrandInfo(
      uuid: json['uuid']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      logo: json['logo']?.toString(),
    );
  }
}

class ProductCategoryInfo {
  final String uuid;
  final String name;

  const ProductCategoryInfo({required this.uuid, required this.name});

  factory ProductCategoryInfo.fromApi(Map<String, dynamic> json) {
    return ProductCategoryInfo(
      uuid: json['uuid']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
    );
  }
}

class ProductVendorInfo {
  final String shopName;
  final String? shopSlug;

  const ProductVendorInfo({required this.shopName, this.shopSlug});

  factory ProductVendorInfo.fromApi(Map<String, dynamic> json) {
    return ProductVendorInfo(
      shopName: json['shopName']?.toString() ?? '',
      shopSlug: json['shopSlug']?.toString(),
    );
  }
}

class ProductDetail {
  final String uuid;
  final String title;
  final String? shortDescription;
  final String? description;
  final String? condition;
  final ProductStatus status;
  final String rawStatus;
  final bool isFeatured;
  final double averageRating;
  final int totalReviews;
  final List<String> tags;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final ProductVendorInfo? vendor;
  final ProductBrandInfo? brand;
  final ProductCategoryInfo? category;
  final List<ProductMedia> media;
  final List<Map<String, dynamic>> attributes;
  final List<Map<String, dynamic>> variants;
  final List<Map<String, dynamic>> specifications;

  const ProductDetail({
    required this.uuid,
    required this.title,
    required this.status,
    this.rawStatus = '',
    this.shortDescription,
    this.description,
    this.condition,
    this.isFeatured = false,
    this.averageRating = 0,
    this.totalReviews = 0,
    this.tags = const [],
    this.createdAt,
    this.updatedAt,
    this.vendor,
    this.brand,
    this.category,
    this.media = const [],
    this.attributes = const [],
    this.variants = const [],
    this.specifications = const [],
  });

  String? get primaryImageUrl {
    if (media.isEmpty) return null;
    final primary = media.where((m) => m.isPrimary);
    return primary.isNotEmpty ? primary.first.url : media.first.url;
  }

  factory ProductDetail.fromApi(Map<String, dynamic> json) {
    final status = switch ((json['status'] as String?)?.toUpperCase()) {
      'DRAFT' => ProductStatus.draft,
      'ARCHIVED' => ProductStatus.archived,
      _ =>
        json['isPublished'] == true
            ? ProductStatus.active
            : ProductStatus.draft,
    };

    final vendorJson = json['vendor'] as Map<String, dynamic>?;
    final brandJson = json['brand'] as Map<String, dynamic>?;
    final categoryJson = json['category'] as Map<String, dynamic>?;
    final mediaJson = json['media'] as List?;
    final tagsJson = json['tags'];

    return ProductDetail(
      uuid: json['uuid']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      rawStatus: json['status']?.toString() ?? '',
      shortDescription: json['shortDescription']?.toString(),
      description: json['description']?.toString(),
      condition: json['condition']?.toString(),
      status: status,
      isFeatured: json['isFeatured'] == true,
      averageRating: (json['averageRating'] as num?)?.toDouble() ?? 0,
      totalReviews: (json['totalReviews'] as num?)?.toInt() ?? 0,
      tags: tagsJson is List
          ? tagsJson.map((e) => e.toString()).toList()
          : const [],
      createdAt: DateTime.tryParse(json['createdAt']?.toString() ?? ''),
      updatedAt: DateTime.tryParse(json['updatedAt']?.toString() ?? ''),
      vendor: vendorJson != null ? ProductVendorInfo.fromApi(vendorJson) : null,
      brand: brandJson != null ? ProductBrandInfo.fromApi(brandJson) : null,
      category: categoryJson != null
          ? ProductCategoryInfo.fromApi(categoryJson)
          : null,
      media:
          mediaJson
              ?.whereType<Map<String, dynamic>>()
              .map(ProductMedia.fromApi)
              .toList() ??
          const [],
      attributes:
          (json['productAttributes'] as List?)
              ?.whereType<Map<String, dynamic>>()
              .toList() ??
          const [],
      variants:
          (json['variants'] as List?)
              ?.whereType<Map<String, dynamic>>()
              .toList() ??
          const [],
      specifications:
          (json['specifications'] as List?)
              ?.whereType<Map<String, dynamic>>()
              .toList() ??
          const [],
    );
  }
}
