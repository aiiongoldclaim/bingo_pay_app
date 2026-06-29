// lib/features/wishlist/model/wishlist_item.dart

/// All fields are String to match ProductCard exactly — no type conversion needed.
class WishlistItem {
  final String id;
  final String brand;
  final String productName; // matches widget.productName
  final String price; // already formatted e.g. "₹18,990"
  final String imageUrl;
  final String rating; // matches widget.rating (String)

  const WishlistItem({
    required this.id,
    required this.brand,
    required this.productName,
    required this.price,
    required this.imageUrl,
    required this.rating,
  });

  @override
  bool operator ==(Object other) => other is WishlistItem && other.id == id;

  @override
  int get hashCode => id.hashCode;
}
