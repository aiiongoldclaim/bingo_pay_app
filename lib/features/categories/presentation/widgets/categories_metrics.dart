import 'package:flutter/widgets.dart';

enum CatDeviceClass { phone, tabletPortrait, tabletLandscape }

class CategoriesMetrics {
  final CatDeviceClass device;

  final double pagePadding;
  final double sectionGap;
  final double contentMaxWidth;

  // Header
  final double logoSize;
  final double taglineSize;
  final double headerIconSize;

  // Search
  final double searchHeight;
  final double searchRadius;
  final double searchFontSize;
  final double searchIconSize;

  // Section header
  final double sectionTitleSize;
  final double viewAllSize;

  // Category circles
  final int categoryColumns;
  final double categoryCircle;
  final double categoryIconSize;
  final double categoryNameSize;
  final double gridGap;

  // Brands
  final double brandTileWidth;
  final double brandTileHeight;
  final double brandRadius;
  final double brandNameSize;

  // Collections
  final double collectionWidth;
  final double collectionHeight;
  final double collectionRadius;
  final double collectionTitleSize;
  final double collectionBodySize;
  final double collectionCtaHeight;
  final double collectionCtaSize;

  // Promo banner
  final double promoAspectRatio;
  final double promoRadius;

  const CategoriesMetrics._({
    required this.device,
    required this.pagePadding,
    required this.sectionGap,
    required this.contentMaxWidth,
    required this.logoSize,
    required this.taglineSize,
    required this.headerIconSize,
    required this.searchHeight,
    required this.searchRadius,
    required this.searchFontSize,
    required this.searchIconSize,
    required this.sectionTitleSize,
    required this.viewAllSize,
    required this.categoryColumns,
    required this.categoryCircle,
    required this.categoryIconSize,
    required this.categoryNameSize,
    required this.gridGap,
    required this.brandTileWidth,
    required this.brandTileHeight,
    required this.brandRadius,
    required this.brandNameSize,
    required this.collectionWidth,
    required this.collectionHeight,
    required this.collectionRadius,
    required this.collectionTitleSize,
    required this.collectionBodySize,
    required this.collectionCtaHeight,
    required this.collectionCtaSize,
    required this.promoAspectRatio,
    required this.promoRadius,
  });

  bool get isPhone => device == CatDeviceClass.phone;
  bool get isTablet => device != CatDeviceClass.phone;

  double get categoryItemWidth => categoryCircle * 1.28;

  double get categoryRowHeight =>
      categoryCircle + pagePadding * 0.5 + categoryNameSize * 1.6 + 4;

  double get brandRowHeight =>
      brandTileHeight + pagePadding * 0.45 + brandNameSize * 1.6 + 4;

  static const double _tabletBreakpoint = 540;
  static const double _phoneReference = 390;

  factory CategoriesMetrics.of(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final isTablet = size.shortestSide >= _tabletBreakpoint;
    final landscape = size.width > size.height;
    if (!isTablet) return _phone(size.width);
    return landscape ? _tabletLandscape() : _tabletPortrait();
  }

  static CategoriesMetrics _phone(double w) {
    final s = (w / _phoneReference).clamp(0.85, 1.15);
    double v(double b, double lo, double hi) =>
        (b * s).clamp(lo, hi).toDouble();

    return CategoriesMetrics._(
      device: CatDeviceClass.phone,
      pagePadding: v(16, 14, 19),
      sectionGap: v(26, 22, 30),
      contentMaxWidth: double.infinity,
      logoSize: v(30, 26, 34),
      taglineSize: v(12, 11, 13),
      headerIconSize: v(24, 22, 27),
      searchHeight: v(50, 46, 56),
      searchRadius: 10,
      searchFontSize: v(14, 13, 15),
      searchIconSize: v(20, 18, 22),
      sectionTitleSize: v(19, 17, 21),
      viewAllSize: v(13, 12, 14),
      categoryColumns: 5,
      categoryCircle: v(58, 52, 65),
      categoryIconSize: v(28, 25, 31),
      categoryNameSize: v(12, 11, 13),
      gridGap: v(12, 10, 15),
      brandTileWidth: v(88, 80, 98),
      brandTileHeight: v(72, 65, 80),
      brandRadius: 8,
      brandNameSize: v(12, 11, 13),
      collectionWidth: v(150, 136, 168),
      collectionHeight: v(200, 182, 222),
      collectionRadius: 10,
      collectionTitleSize: v(17, 15, 19),
      collectionBodySize: v(12, 11, 13),
      collectionCtaHeight: v(32, 29, 36),
      collectionCtaSize: v(12, 11, 13),
      promoAspectRatio: 2.35,
      promoRadius: 10,
    );
  }

  static CategoriesMetrics _tabletPortrait() => const CategoriesMetrics._(
    device: CatDeviceClass.tabletPortrait,
    pagePadding: 28,
    sectionGap: 34,
    contentMaxWidth: 900,
    logoSize: 40,
    taglineSize: 15,
    headerIconSize: 28,
    searchHeight: 58,
    searchRadius: 12,
    searchFontSize: 16,
    searchIconSize: 24,
    sectionTitleSize: 23,
    viewAllSize: 15,
    categoryColumns: 6,
    categoryCircle: 78,
    categoryIconSize: 36,
    categoryNameSize: 14,
    gridGap: 18,
    brandTileWidth: 120,
    brandTileHeight: 96,
    brandRadius: 10,
    brandNameSize: 14,
    collectionWidth: 210,
    collectionHeight: 280,
    collectionRadius: 14,
    collectionTitleSize: 21,
    collectionBodySize: 14,
    collectionCtaHeight: 40,
    collectionCtaSize: 14,
    promoAspectRatio: 2.9,
    promoRadius: 14,
  );

  static CategoriesMetrics _tabletLandscape() => const CategoriesMetrics._(
    device: CatDeviceClass.tabletLandscape,
    pagePadding: 36,
    sectionGap: 36,
    contentMaxWidth: 1180,
    logoSize: 42,
    taglineSize: 15,
    headerIconSize: 28,
    searchHeight: 58,
    searchRadius: 12,
    searchFontSize: 16,
    searchIconSize: 24,
    sectionTitleSize: 24,
    viewAllSize: 15,
    categoryColumns: 8,
    categoryCircle: 82,
    categoryIconSize: 38,
    categoryNameSize: 14,
    gridGap: 20,
    brandTileWidth: 128,
    brandTileHeight: 100,
    brandRadius: 10,
    brandNameSize: 14,
    collectionWidth: 230,
    collectionHeight: 300,
    collectionRadius: 14,
    collectionTitleSize: 22,
    collectionBodySize: 14,
    collectionCtaHeight: 42,
    collectionCtaSize: 14,
    promoAspectRatio: 3.4,
    promoRadius: 14,
  );
}
