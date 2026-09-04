import 'package:flutter/material.dart';

class ProductModel {
  final String? uuid;
  final String? variantUuid;
  /// `null` means the catalogue response did not include inventory data.
  /// It must not be treated as an out-of-stock result.
  final int? stock;
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
    this.variantUuid,
    this.stock,
  });

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    if (json.containsKey('_cached')) {
      // Deserialized from cache: toJson() already flattened/formatted this
      // model (price/oldPrice as display strings, no variants array to
      // re-derive them from) — reading it back through the API-shape logic
      // below would crash on `brand` (a String here, not {name: ...}) and
      // silently drop price/oldPrice/discount to their zero defaults.
      return ProductModel(
        uuid: json['uuid'] as String?,
        brand: json['brand'] as String? ?? '',
        name: json['name'] as String? ?? '',
        price: json['price'] as String? ?? 'N/A',
        oldPrice: json['oldPrice'] as String? ?? '',
        rating: json['rating'] as String? ?? '0.0',
        discount: _asInt(json['discount']) ?? 0,
        variantUuid: json['variantUuid'] as String?,
        stock: _asInt(json['stock']),
        icon: Icons.shopping_bag_outlined,
        images:
            (json['images'] as List<dynamic>?)?.cast<String>() ?? const [],
      );
    }

    final mediaList = (json['media'] as List<dynamic>?) ?? [];
    final images = mediaList
        .map((m) => (m as Map<String, dynamic>)['url'] as String? ?? '')
        .where((url) => url.isNotEmpty)
        .toList();

    final brand = json['brand'] as Map<String, dynamic>?;
    final variants = (json['variants'] as List<dynamic>?) ?? [];
    // Cached catalogue entries are stored in this model's flattened form,
    // while API responses keep inventory on the selected variant.
    // Previous code: int stock = _asInt(json['stock']) ?? 0;
    // Missing inventory was therefore converted to 0 (sold out).
    int? stock = _asInt(json['stock']) ??
        _asInt(json['availableStock']) ??
        _readInventoryStock(json['inventory']);

    double price = 0.0;
    double oldPrice = 0.0;
    int discount = 0;
    String? variantUuid = json['variantUuid'] as String?;
    if (variants.isNotEmpty) {
      final v = variants.first as Map<String, dynamic>;
      // API returns salePrice/basePrice as strings; fall back to numeric price/compareAtPrice
      variantUuid = v['uuid'] as String? ?? variantUuid;
      stock = _asInt(v['availableStock']) ??
          _readInventoryStock(v['inventory']) ??
          stock;
      price =
          double.tryParse(v['salePrice']?.toString() ?? '') ??
          (v['price'] as num?)?.toDouble() ??
          0.0;
      oldPrice =
          double.tryParse(v['basePrice']?.toString() ?? '') ??
          (v['compareAtPrice'] as num?)?.toDouble() ??
          0.0;
      if (oldPrice > 0 && price < oldPrice) {
        discount = (((oldPrice - price) / oldPrice) * 100).round();
      }
    }

    final averageRating = (json['averageRating'] as num?)?.toDouble() ?? 0.0;

    return ProductModel(
      uuid: json['uuid'] as String?,
      brand: brand?['name'] as String? ?? '',
      name: json['title'] as String? ?? '',
      price: price > 0 ? '\$${_fmt(price)}' : 'N/A',
      oldPrice: oldPrice > 0 ? '\$${_fmt(oldPrice)}' : '',
      rating: averageRating.toStringAsFixed(1),
      discount: discount,
      variantUuid: variantUuid,
      stock: stock,
      icon: Icons.shopping_bag_outlined,
      images: images,
    );
  }

  Map<String, dynamic> toJson() => {
    '_cached': true, // Flag to identify cached format
    'uuid': uuid,
    'brand': brand,
    'name': name,
    'price': price,
    'oldPrice': oldPrice,
    'rating': rating,
    'discount': discount,
    'images': images,
    'variantUuid': variantUuid,
    'stock': stock,
  };

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

  static int? _asInt(Object? value) => switch (value) {
    int value => value,
    num value => value.toInt(),
    _ => int.tryParse(value?.toString() ?? ''),
  };

  static int? _readInventoryStock(Object? inventory) {
    if (inventory is! Map) return null;
    return _asInt(
      inventory['availableStock'] ??
          inventory['available_stock'] ??
          inventory['stock'],
    );
  }

  // static List<ProductModel> flashDeals() => [
  //   ProductModel(
  //     brand: 'NOVA',
  //     name: 'Helios 5G Smartphone 256GB',
  //     price: '\$64,999',
  //     oldPrice: '\$72,999',
  //     rating: '4.6',
  //     discount: 11,
  //     icon: Icons.smartphone_outlined,
  //     images: ['https://images.unsplash.com/photo-1511707171634-5f897ff02aa9'],
  //   ),
  //   ProductModel(
  //     brand: 'SONARA',
  //     name: 'Aurora Pro Wireless Headphones',
  //     price: '\$18,990',
  //     oldPrice: '\$24,990',
  //     rating: '4.8',
  //     discount: 24,
  //     icon: Icons.headphones_outlined,
  //     images: ['https://images.unsplash.com/photo-1505740420928-5e560c06d30e'],
  //   ),
  // ];
  //
  // static List<ProductModel> recommended() => [
  //   ProductModel(
  //     brand: 'TYDE',
  //     name: 'Eclipse Smartwatch',
  //     price: '\$32,400',
  //     oldPrice: '\$38,000',
  //     rating: '4.7',
  //     discount: 15,
  //     icon: Icons.watch,
  //     images: ['https://images.unsplash.com/photo-1523275335684-37898b6baf30'],
  //   ),
  // ];
}
