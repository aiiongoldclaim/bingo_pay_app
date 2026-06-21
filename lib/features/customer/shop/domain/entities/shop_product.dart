import 'package:equatable/equatable.dart';

class ShopProduct extends Equatable {
  final String id;
  final String categorySlug;
  final String name;
  final String brand;
  final String description;
  final double price;
  final double? compareAtPrice;
  final double rating;
  final int reviewCount;
  final bool isFeatured;
  final bool isTrending;
  final bool inStock;
  final List<String> badges;
  final List<String> sizes;
  final List<String> colors;
  final List<String> specs;
  final String? vendorEmail;

  const ShopProduct({
    required this.id,
    required this.categorySlug,
    required this.name,
    required this.brand,
    required this.description,
    required this.price,
    required this.compareAtPrice,
    required this.rating,
    required this.reviewCount,
    required this.isFeatured,
    required this.isTrending,
    required this.inStock,
    required this.badges,
    required this.sizes,
    required this.colors,
    required this.specs,
    this.vendorEmail,
  });

  int? get discountPercent {
    final original = compareAtPrice;
    if (original == null || original <= price) return null;
    return (((original - price) / original) * 100).round();
  }

  factory ShopProduct.fromJson(Map<String, dynamic> json) {
    final stockQuantity = _toInt(json['stock_quantity']);
    final lowStockThreshold = _toInt(json['low_stock_threshold']);
    final featured = _toBool(json['featured']);
    final price = _toDouble(json['selling_price']);
    final mrp = _toDouble(json['mrp']);
    final categoryName = (json['sub_category'] as String?)?.trim() ?? '';

    final badges = <String>[
      if (featured) 'Featured',
      if (stockQuantity > 0 && stockQuantity <= lowStockThreshold) 'Low stock',
    ];

    final specs = <String>[
      if ((json['country_of_origin'] as String?)?.trim().isNotEmpty ?? false)
        'Origin: ${json['country_of_origin']}',
      if ((json['shipping_weight'] as String?)?.trim().isNotEmpty ?? false)
        'Weight: ${json['shipping_weight']}',
      if ((json['hsn_code'] as String?)?.trim().isNotEmpty ?? false)
        'HSN: ${json['hsn_code']}',
    ];

    return ShopProduct(
      id: (json['product_id'] ?? '').toString(),
      categorySlug: _slugify(categoryName),
      name: (json['product_name'] as String?)?.trim() ?? '',
      brand: categoryName,
      description: (json['short_description'] as String?)?.trim() ?? '',
      price: price,
      compareAtPrice: mrp > price ? mrp : null,
      rating: 4.5,
      reviewCount: _toInt(json['reviews_count']),
      isFeatured: featured,
      isTrending: false,
      inStock: stockQuantity > 0,
      badges: badges,
      sizes: const [],
      colors: const [],
      specs: specs,
      vendorEmail: (json['vendor_email'] as String?)?.trim().isEmpty ?? true
          ? null
          : (json['vendor_email'] as String).trim(),
    );
  }

  static String _slugify(String value) {
    if (value.isEmpty) return 'general';
    return value.toLowerCase().trim().replaceAll(RegExp(r'\s+'), '-');
  }

  static int _toInt(dynamic value) {
    if (value == null) return 0;
    if (value is num) return value.toInt();
    return int.tryParse(value.toString()) ?? 0;
  }

  static double _toDouble(dynamic value) {
    if (value == null) return 0;
    if (value is num) return value.toDouble();
    return double.tryParse(value.toString()) ?? 0;
  }

  static bool _toBool(dynamic value) {
    if (value is bool) return value;
    return value.toString().toLowerCase() == 'true';
  }

  @override
  List<Object?> get props => [
        id,
        categorySlug,
        name,
        brand,
        description,
        price,
        compareAtPrice,
        rating,
        reviewCount,
        isFeatured,
        isTrending,
        inStock,
        badges,
        sizes,
        colors,
        specs,
        vendorEmail,
      ];
}
