import 'package:flutter/material.dart';

class ListingProductModel {
  final String id;
  final String? uuid;
  final String brand;
  final String name;
  final double price;
  final double? originalPrice;
  final double? rating;
  final int? ratingCount;
  final String? badge;
  final IconData icon;
  final String? imageUrl;
  final bool isFavourite;

  const ListingProductModel({
    required this.id,
    this.uuid,
    required this.brand,
    required this.name,
    required this.price,
    this.originalPrice,
    this.rating,
    this.ratingCount,
    this.badge,
    required this.icon,
    this.imageUrl,
    this.isFavourite = false,
  });

  factory ListingProductModel.fromJson(Map<String, dynamic> json) {
    // Handle both API response and cached JSON formats
    if (json.containsKey('_cached')) {
      // Deserialized from cache
      return ListingProductModel(
        id: json['id'] as String,
        uuid: json['uuid'] as String?,
        brand: json['brand'] as String? ?? '',
        name: json['name'] as String? ?? '',
        price: (json['price'] as num?)?.toDouble() ?? 0.0,
        originalPrice: (json['originalPrice'] as num?)?.toDouble(),
        rating: (json['rating'] as num?)?.toDouble(),
        ratingCount: json['ratingCount'] as int?,
        badge: json['badge'] as String?,
        icon: Icons.shopping_bag_outlined,
        imageUrl: json['imageUrl'] as String?,
        isFavourite: json['isFavourite'] as bool? ?? false,
      );
    }

    // Parse from API response
    final mediaList = (json['media'] as List<dynamic>?) ?? [];
    final primary = mediaList.cast<Map<String, dynamic>>().firstWhere(
          (m) => m['isPrimary'] == true,
          orElse: () => mediaList.isNotEmpty
              ? mediaList.first as Map<String, dynamic>
              : <String, dynamic>{},
        );

    final variants = (json['variants'] as List<dynamic>?) ?? [];
    double price = 0.0;
    double? originalPrice;
    if (variants.isNotEmpty) {
      final v = variants.first as Map<String, dynamic>;
      price = double.tryParse(v['salePrice']?.toString() ?? '') ??
          (v['price'] as num?)?.toDouble() ??
          0.0;
      originalPrice = double.tryParse(v['basePrice']?.toString() ?? '') ??
          (v['compareAtPrice'] as num?)?.toDouble();
    }

    final brand = json['brand'] as Map<String, dynamic>?;
    final isFeatured = json['isFeatured'] as bool? ?? false;

    return ListingProductModel(
      id: json['id'] as String,
      uuid: json['uuid'] as String?,
      brand: brand?['name'] as String? ?? '',
      name: json['title'] as String? ?? '',
      price: price,
      originalPrice: originalPrice,
      rating: (json['averageRating'] as num?)?.toDouble(),
      ratingCount: json['totalReviews'] as int?,
      badge: isFeatured ? 'FEATURED' : null,
      icon: Icons.shopping_bag_outlined,
      imageUrl: primary['url'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
    '_cached': true, // Flag to identify cached format
    'id': id,
    'uuid': uuid,
    'brand': brand,
    'name': name,
    'price': price,
    'originalPrice': originalPrice,
    'rating': rating,
    'ratingCount': ratingCount,
    'badge': badge,
    'imageUrl': imageUrl,
    'isFavourite': isFavourite,
  };

  int? get discountPercent {
    if (originalPrice == null || originalPrice == 0) return null;
    return (((originalPrice! - price) / originalPrice!) * 100).round();
  }

  ListingProductModel copyWith({bool? isFavourite}) => ListingProductModel(
        id: id,
        uuid: uuid,
        brand: brand,
        name: name,
        price: price,
        originalPrice: originalPrice,
        rating: rating,
        ratingCount: ratingCount,
        badge: badge,
        icon: icon,
        imageUrl: imageUrl,
        isFavourite: isFavourite ?? this.isFavourite,
      );
}
