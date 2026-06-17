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
  });

  int? get discountPercent {
    final original = compareAtPrice;
    if (original == null || original <= price) return null;
    return (((original - price) / original) * 100).round();
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
      ];
}
