import 'package:flutter/material.dart';

class ProductModel {
  final String? uuid;
  final String brand;
  final String name;
  final String price;
  final String oldPrice;
  final String rating;
  final int discount;
  final IconData icon;
  final List<String> images;

  ProductModel({
    this.uuid,
    required this.brand,
    required this.name,
    required this.price,
    required this.oldPrice,
    required this.rating,
    required this.discount,
    required this.icon,
    required this.images,
  });

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    final mediaList = (json['media'] as List<dynamic>?) ?? [];
    final images = mediaList
        .map((m) => (m as Map<String, dynamic>)['url'] as String? ?? '')
        .where((url) => url.isNotEmpty)
        .toList();

    final brand = json['brand'] as Map<String, dynamic>?;
    final variants = (json['variants'] as List<dynamic>?) ?? [];

    double price = 0.0;
    double oldPrice = 0.0;
    int discount = 0;
    if (variants.isNotEmpty) {
      final v = variants.first as Map<String, dynamic>;
      // API returns salePrice/basePrice as strings; fall back to numeric price/compareAtPrice
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

    final averageRating =
        (json['averageRating'] as num?)?.toDouble() ?? 0.0;

    return ProductModel(
      uuid: json['uuid'] as String?,
      brand: brand?['name'] as String? ?? '',
      name: json['title'] as String? ?? '',
      price: price > 0 ? '\$${_fmt(price)}' : 'N/A',
      oldPrice: oldPrice > 0 ? '\$${_fmt(oldPrice)}' : '',
      rating: averageRating.toStringAsFixed(1),
      discount: discount,
      icon: Icons.shopping_bag_outlined,
      images: images,
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

  static List<ProductModel> flashDeals() => [
        ProductModel(
          brand: 'NOVA',
          name: 'Helios 5G Smartphone 256GB',
          price: '\$64,999',
          oldPrice: '\$72,999',
          rating: '4.6',
          discount: 11,
          icon: Icons.smartphone_outlined,
          images: [
            'https://images.unsplash.com/photo-1511707171634-5f897ff02aa9',
          ],
        ),
        ProductModel(
          brand: 'SONARA',
          name: 'Aurora Pro Wireless Headphones',
          price: '\$18,990',
          oldPrice: '\$24,990',
          rating: '4.8',
          discount: 24,
          icon: Icons.headphones_outlined,
          images: [
            'https://images.unsplash.com/photo-1505740420928-5e560c06d30e',
          ],
        ),
      ];

  static List<ProductModel> recommended() => [
        ProductModel(
          brand: 'TYDE',
          name: 'Eclipse Smartwatch',
          price: '\$32,400',
          oldPrice: '\$38,000',
          rating: '4.7',
          discount: 15,
          icon: Icons.watch,
          images: [
            'https://images.unsplash.com/photo-1523275335684-37898b6baf30',
          ],
        ),
      ];
}
