/// Lightweight product preview shown in the "Popular right now" horizontal strip.
class SearchProductPreview {
  final String id;
  final String brand;
  final String name;
  final double rating;
  final int reviewCount;
  final double price;
  final double? originalPrice;
  final int? discountPercent;
  final String? badge; // e.g. "BESTSELLER"
  final String? imageUrl;
  final bool isFavourite;

  const SearchProductPreview({
    required this.id,
    required this.brand,
    required this.name,
    required this.rating,
    required this.reviewCount,
    required this.price,
    this.originalPrice,
    this.discountPercent,
    this.badge,
    this.imageUrl,
    this.isFavourite = false,
  });

  SearchProductPreview copyWith({bool? isFavourite}) => SearchProductPreview(
    id: id,
    brand: brand,
    name: name,
    rating: rating,
    reviewCount: reviewCount,
    price: price,
    originalPrice: originalPrice,
    discountPercent: discountPercent,
    badge: badge,
    imageUrl: imageUrl,
    isFavourite: isFavourite ?? this.isFavourite,
  );
}
