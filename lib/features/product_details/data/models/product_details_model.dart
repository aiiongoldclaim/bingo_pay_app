import 'package:flutter/material.dart';

class ProductDetailModel {
  final String id;
  final String? uuid;
  final String productName;
  final String brand;
  final String price;
  final String oldPrice;
  final int discount;
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
  final String? variantUuid;

  const ProductDetailModel({
    required this.id,
    this.uuid,
    required this.productName,
    required this.brand,
    required this.price,
    required this.oldPrice,
    required this.discount,
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
    this.variantUuid,
  });

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
    final variants = (data['variants'] as List<dynamic>?) ?? [];

    double price = 0.0;
    double oldPrice = 0.0;
    int discount = 0;
    if (variants.isNotEmpty) {
      final v = variants.first as Map<String, dynamic>;
      price = double.tryParse(v['salePrice']?.toString() ?? '') ??
          (v['price'] as num?)?.toDouble() ??
          0.0;
      oldPrice = double.tryParse(v['basePrice']?.toString() ?? '') ??
          (v['compareAtPrice'] as num?)?.toDouble() ??
          0.0;
      if (oldPrice > 0 && price < oldPrice) {
        discount = (((oldPrice - price) / oldPrice) * 100).round();
      }
    }

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
      price: price > 0 ? '\$${_fmt(price)}' : 'N/A',
      oldPrice: oldPrice > 0 ? '\$${_fmt(oldPrice)}' : '',
      discount: discount,
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
      variantUuid: variants.isNotEmpty
          ? (variants.first as Map<String, dynamic>)['uuid'] as String?
          : null,
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
