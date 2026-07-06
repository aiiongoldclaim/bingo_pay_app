// lib/features/wishlist/model/wishlist_model.dart

/// A saved product. Price/rating are pre-formatted display strings (as
/// produced by the product's origin screen) rather than raw numbers, so no
/// lossy re-parsing/re-formatting is needed when rendering the wishlist.
class WishlistItem {
  final String id; // product uuid — used to open ProductDetailsScreen
  final String brand;
  final String name;
  final String price;
  final String? originalPrice;
  final int? discountPercent;
  final String? imageUrl;
  final String rating;
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
    this.rating = '0.0',
    this.reviewCount = 0,
    this.inStock = true,
    this.badge,
  });

  @override
  bool operator ==(Object other) => other is WishlistItem && other.id == id;

  @override
  int get hashCode => id.hashCode;
}
