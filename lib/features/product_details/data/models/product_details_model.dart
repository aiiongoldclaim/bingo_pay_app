import 'package:flutter/material.dart';

class ProductVariant {
  final String uuid;
  final String title;
  final String variantName;
  final String combinationKey;
  final double salePrice;
  final double basePrice;
  final int availableStock;
  final List<VariantAttribute> attributes;

  ProductVariant({
    required this.uuid,
    required this.title,
    required this.variantName,
    required this.combinationKey,
    required this.salePrice,
    required this.basePrice,
    required this.availableStock,
    required this.attributes,
  });

  factory ProductVariant.fromJson(Map<String, dynamic> json) {
    final salePrice = double.tryParse(json['salePrice']?.toString() ?? '') ?? 0.0;
    final basePrice = double.tryParse(json['basePrice']?.toString() ?? '') ?? 0.0;
    final inventory = json['inventory'] as Map<String, dynamic>?;
    final availableStock = (inventory?['availableStock'] as num?)?.toInt() ?? 0;
    final attrs = (json['attributes'] as List<dynamic>?) ?? [];

    return ProductVariant(
      uuid: json['uuid'] as String? ?? '',
      title: json['title'] as String? ?? '',
      variantName: json['variantName'] as String? ?? '',
      combinationKey: json['combinationKey'] as String? ?? '',
      salePrice: salePrice,
      basePrice: basePrice,
      availableStock: availableStock,
      attributes: attrs
          .map((a) => VariantAttribute.fromJson(a as Map<String, dynamic>))
          .toList(),
    );
  }
}

class VariantAttribute {
  final String attributeName;
  final String value;

  VariantAttribute({required this.attributeName, required this.value});

  factory VariantAttribute.fromJson(Map<String, dynamic> json) {
    return VariantAttribute(
      attributeName: json['attributeName'] as String? ?? '',
      value: json['value'] as String? ?? '',
    );
  }
}

class ProductDetailModel {
  final String id;
  final String? uuid;
  final String productName;
  final String brand;
  final String rating;
  final String reviewCount;
  final IconData icon;
  final List<String> images;
  final int coinsEarned;
  final List<String> highlights;
  final List<ProductColorOption> colorOptions;
  final List<RatingBreakdown> ratingBreakdown;
  final DeliveryInfo deliveryInfo;
  final String? vendorEmail;
  final List<ProductVariant> variants;
  final int selectedVariantIndex;

  ProductDetailModel({
    required this.id,
    this.uuid,
    required this.productName,
    required this.brand,
    required this.rating,
    required this.reviewCount,
    required this.icon,
    this.images = const [],
    this.coinsEarned = 0,
    this.highlights = const [],
    this.colorOptions = const [],
    this.ratingBreakdown = const [],
    required this.deliveryInfo,
    this.vendorEmail,
    this.variants = const [],
    this.selectedVariantIndex = 0,
  });

  // Getters for current selected variant
  ProductVariant? get selectedVariant =>
      selectedVariantIndex < variants.length
          ? variants[selectedVariantIndex]
          : null;

  String get price {
    final variant = selectedVariant;
    if (variant == null) return 'N/A';
    return '\$${_fmt(variant.salePrice)}';
  }

  String get oldPrice {
    final variant = selectedVariant;
    if (variant == null || variant.basePrice <= 0) return '';
    return '\$${_fmt(variant.basePrice)}';
  }

  int get discount {
    final variant = selectedVariant;
    if (variant == null || variant.basePrice <= 0) return 0;
    if (variant.salePrice < variant.basePrice) {
      return (((variant.basePrice - variant.salePrice) / variant.basePrice) * 100)
          .round();
    }
    return 0;
  }

  int get availableStock => selectedVariant?.availableStock ?? 0;

  String? get variantUuid => selectedVariant?.uuid;

  factory ProductDetailModel.fromJson(Map<String, dynamic> json) {
    final outer = json['data'] as Map<String, dynamic>;
    final data = outer['data'] as Map<String, dynamic>;

    final mediaList = (data['media'] as List<dynamic>?) ?? [];
    final images = mediaList
        .map((m) => (m as Map<String, dynamic>)['url'] as String? ?? '')
        .where((url) => url.isNotEmpty)
        .toList();

    final brand = data['brand'] as Map<String, dynamic>?;
    final vendor = data['vendor'] as Map<String, dynamic>?;
    final variantsList = (data['variants'] as List<dynamic>?) ?? [];
    final variants = variantsList
        .map((v) => ProductVariant.fromJson(v as Map<String, dynamic>))
        .toList();

    final avgRating =
        (data['averageRating'] as num?)?.toDouble() ?? 0.0;
    final totalReviews = (data['totalReviews'] as int?) ?? 0;

    final List<String> highlights = [
      if (data['shortDescription'] != null &&
          (data['shortDescription'] as String).isNotEmpty)
        data['shortDescription'] as String,
      if (data['description'] != null &&
          (data['description'] as String).isNotEmpty)
        data['description'] as String,
    ];

    return ProductDetailModel(
      id: data['id'] as String? ?? '',
      uuid: data['uuid'] as String?,
      productName: data['title'] as String? ?? '',
      brand: brand?['name'] as String? ?? '',
      rating: avgRating.toStringAsFixed(1),
      reviewCount: totalReviews >= 1000
          ? '${(totalReviews / 1000).toStringAsFixed(1)}k'
          : '$totalReviews',
      icon: Icons.shopping_bag_outlined,
      images: images,
      coinsEarned: 0,
      highlights: highlights,
      colorOptions: const [],
      ratingBreakdown: const [],
      vendorEmail: vendor?['email'] as String?,
      variants: variants,
      selectedVariantIndex: 0,
      deliveryInfo: const DeliveryInfo(
        deliveryLabel: 'Free Delivery',
        deliverySubtitle: 'Estimated 2–5 business days',
        returnLabel: '7 Day Returns',
        returnSubtitle: 'Easy no-hassle returns',
        warrantyLabel: 'Warranty',
        warrantySubtitle: 'As per brand policy',
      ),
    );
  }

  /// Create a copy with modified variant index
  ProductDetailModel copyWith({
    int? selectedVariantIndex,
  }) {
    return ProductDetailModel(
      id: id,
      uuid: uuid,
      productName: productName,
      brand: brand,
      rating: rating,
      reviewCount: reviewCount,
      icon: icon,
      images: images,
      coinsEarned: coinsEarned,
      highlights: highlights,
      colorOptions: colorOptions,
      ratingBreakdown: ratingBreakdown,
      deliveryInfo: deliveryInfo,
      vendorEmail: vendorEmail,
      variants: variants,
      selectedVariantIndex: selectedVariantIndex ?? this.selectedVariantIndex,
    );
  }

  static String _fmt(double v) {
    final s = v.truncate().toString();
    final buf = StringBuffer();
    for (int i = 0; i < s.length; i++) {
      final fromEnd = s.length - i;
      buf.write(s[i]);
      final rem = fromEnd - 1;
      if (rem == 3 || (rem > 3 && (rem - 3) % 2 == 0)) buf.write(',');
    }
    return buf.toString();
  }
}

class ProductColorOption {
  final Color color;
  final String name;
  const ProductColorOption({required this.color, required this.name});
}

class RatingBreakdown {
  final int stars;
  final double percentage;
  const RatingBreakdown({required this.stars, required this.percentage});
}

class DeliveryInfo {
  final String deliveryLabel;
  final String deliverySubtitle;
  final String returnLabel;
  final String returnSubtitle;
  final String warrantyLabel;
  final String warrantySubtitle;

  const DeliveryInfo({
    required this.deliveryLabel,
    required this.deliverySubtitle,
    required this.returnLabel,
    required this.returnSubtitle,
    required this.warrantyLabel,
    required this.warrantySubtitle,
  });
}
