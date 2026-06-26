// lib/features/wishlist/model/wishlist_model.dart

import 'package:flutter/cupertino.dart';

class WishlistItem {
  final String id;
  final String brand;
  final String name;
  final double price;
  final double? originalPrice;
  final int? discountPercent;
  final String? imageUrl;
  final IconData? icon;
  final double rating;
  final int reviewCount;
  final bool inStock;
  final String? badge; // e.g. "BESTSELLER", "NEW"

  const WishlistItem({
    required this.id,
    required this.brand,
    required this.name,
    required this.price,
    this.originalPrice,
    this.discountPercent,
    this.imageUrl,
    this.icon,
    required this.rating,
    required this.reviewCount,
    this.inStock = true,
    this.badge,
  });

  String get formattedPrice => '₹${_fmt(price)}';
  String get formattedOriginal =>
      originalPrice != null ? '₹${_fmt(originalPrice!)}' : '';

  static String _fmt(double v) {
    final i = v.toInt();
    if (i >= 1000) {
      final t = i ~/ 1000;
      final r = i % 1000;
      return '$t,${r.toString().padLeft(3, '0')}';
    }
    return '$i';
  }
}
