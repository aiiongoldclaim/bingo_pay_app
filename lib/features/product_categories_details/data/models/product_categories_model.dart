import 'package:flutter/material.dart';

class ListingProductModel {
  final String id;
  final String brand;
  final String name;
  final double price;
  final double? originalPrice;
  final double? rating;
  final int? ratingCount;
  final String? badge; // "-11%", "BESTSELLER", "NEW", "PRO"
  final IconData icon;
  final String? imageUrl;
  final bool isFavourite;

  const ListingProductModel({
    required this.id,
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

  int? get discountPercent {
    if (originalPrice == null || originalPrice == 0) return null;
    return (((originalPrice! - price) / originalPrice!) * 100).round();
  }

  ListingProductModel copyWith({bool? isFavourite}) => ListingProductModel(
    id: id,
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
