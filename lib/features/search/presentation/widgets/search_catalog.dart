import 'package:flutter/foundation.dart';

@immutable
class TrendingSearchData {
  final String label;
  final String imageAsset;
  final String query;

  const TrendingSearchData({
    required this.label,
    required this.imageAsset,
    required this.query,
  });
}

@immutable
class BrandData {
  final String name;
  final String logoAsset;
  final String slug;

  const BrandData({
    required this.name,
    required this.logoAsset,
    required this.slug,
  });
}

/// Local catalog for search discovery sections.
///
/// `SearchState` me abhi trending/suggested/brands nahi hain. Jab in teeno
/// ke liye API aa jaye, `SearchIdle` me fields add karke wahan se feed
/// kar dena — widget layer me koi change nahi lagega.
class SearchCatalog {
  const SearchCatalog._();

  static const String _trendingDir = 'assets/images/trending';
  static const String _brandDir = 'assets/images/brands';

  static const List<TrendingSearchData> trending = [
    TrendingSearchData(
      label: 'Dresses',
      query: 'dresses',
      imageAsset: '$_trendingDir/dresses.png',
    ),
    TrendingSearchData(
      label: 'Men Shirts',
      query: 'men shirts',
      imageAsset: '$_trendingDir/men_shirts.png',
    ),
    TrendingSearchData(
      label: 'Sneakers',
      query: 'sneakers',
      imageAsset: '$_trendingDir/sneakers.png',
    ),
    TrendingSearchData(
      label: 'Bags',
      query: 'bags',
      imageAsset: '$_trendingDir/bags.png',
    ),
    TrendingSearchData(
      label: 'Sunglasses',
      query: 'sunglasses',
      imageAsset: '$_trendingDir/sunglasses.png',
    ),
  ];

  static const List<String> suggested = [
    'Party Wear Dresses',
    'Men Casual Shirts',
    'Women Heels',
    'Backpacks',
    'Watches',
  ];

  static const List<BrandData> brands = [
    BrandData(name: 'Aldo', slug: 'aldo', logoAsset: '$_brandDir/aldo.png'),
    BrandData(name: 'Only', slug: 'only', logoAsset: '$_brandDir/only.png'),
    BrandData(
      name: 'Vero Moda',
      slug: 'vero-moda',
      logoAsset: '$_brandDir/vero_moda.png',
    ),
    BrandData(
      name: 'Rare Rabbit',
      slug: 'rare-rabbit',
      logoAsset: '$_brandDir/rare_rabbit.png',
    ),
    BrandData(name: 'Mango', slug: 'mango', logoAsset: '$_brandDir/mango.png'),
  ];

  /// "+20 More" tile ke liye — total brands minus dikhaye gaye
  static const int totalBrandCount = 25;
}
