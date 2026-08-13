import 'package:flutter/widgets.dart';

enum CatDeviceClass { phone, tabletPortrait, tabletLandscape }

class CategoriesMetrics {
  final CatDeviceClass device;

  final double pagePadding;
  final double sectionGap;
  final double contentMaxWidth;

  final double searchHeight;
  final double searchRadius;
  final double searchFontSize;
  final double searchIconSize;

  final double sectionTitleSize;
  final double viewAllSize;

  final int categoryColumns;
  final double categoryTileRadius;
  final double categoryCircle;
  final double categoryIconSize;
  final double categoryNameSize;
  final double categoryCountSize;
  final double gridGap;

  final double brandTileWidth;
  final double brandLogoHeight;
  final double brandNameSize;

  final double collectionWidth;
  final double collectionHeight;
  final double collectionTitleSize;
  final double collectionBodySize;
  final double collectionFabSize;

  final double popularTileWidth;
  final double popularImageHeight;
  final double popularNameSize;
  final double popularCountSize;

  final double benefitIconSize;
  final double benefitTitleSize;
  final double benefitBodySize;

  const CategoriesMetrics._({
    required this.device,
    required this.pagePadding,
    required this.sectionGap,
    required this.contentMaxWidth,
    required this.searchHeight,
    required this.searchRadius,
    required this.searchFontSize,
    required this.searchIconSize,
    required this.sectionTitleSize,
    required this.viewAllSize,
    required this.categoryColumns,
    required this.categoryTileRadius,
    required this.categoryCircle,
    required this.categoryIconSize,
    required this.categoryNameSize,
    required this.categoryCountSize,
    required this.gridGap,
    required this.brandTileWidth,
    required this.brandLogoHeight,
    required this.brandNameSize,
    required this.collectionWidth,
    required this.collectionHeight,
    required this.collectionTitleSize,
    required this.collectionBodySize,
    required this.collectionFabSize,
    required this.popularTileWidth,
    required this.popularImageHeight,
    required this.popularNameSize,
    required this.popularCountSize,
    required this.benefitIconSize,
    required this.benefitTitleSize,
    required this.benefitBodySize,
  });

  bool get isPhone => device == CatDeviceClass.phone;
  bool get isTablet => device != CatDeviceClass.phone;

  double get categoryTileHeight =>
      categoryCircle +
      pagePadding * 1.6 +
      categoryNameSize * 2.6 +
      categoryCountSize * 1.6 +
      6;

  double get brandRowHeight =>
      brandLogoHeight + pagePadding * 1.4 + brandNameSize * 1.6 + 4;

  double get popularRowHeight =>
      popularImageHeight +
      pagePadding * 1.2 +
      popularNameSize * 1.6 +
      popularCountSize * 1.6 +
      6;

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
      searchHeight: v(50, 46, 56),
      searchRadius: 10,
      searchFontSize: v(14, 13, 15),
      searchIconSize: v(20, 18, 22),
      sectionTitleSize: v(17, 16, 19),
      viewAllSize: v(13, 12, 14),
      categoryColumns: 4,
      categoryTileRadius: 10,
      categoryCircle: v(52, 46, 58),
      categoryIconSize: v(26, 23, 29),
      categoryNameSize: v(12, 11, 13),
      categoryCountSize: v(11, 10, 12),
      gridGap: v(10, 8, 13),
      brandTileWidth: v(90, 82, 100),
      brandLogoHeight: v(46, 42, 52),
      brandNameSize: v(12, 11, 13),
      collectionWidth: v(215, 195, 240),
      collectionHeight: v(150, 138, 168),
      collectionTitleSize: v(15, 14, 17),
      collectionBodySize: v(12, 11, 13),
      collectionFabSize: v(34, 30, 38),
      popularTileWidth: v(102, 92, 114),
      popularImageHeight: v(96, 86, 108),
      popularNameSize: v(13, 12, 14),
      popularCountSize: v(11, 10, 12),
      benefitIconSize: v(24, 22, 27),
      benefitTitleSize: v(12, 11, 13),
      benefitBodySize: v(10, 9, 11),
    );
  }

  static CategoriesMetrics _tabletPortrait() => const CategoriesMetrics._(
    device: CatDeviceClass.tabletPortrait,
    pagePadding: 28,
    sectionGap: 34,
    contentMaxWidth: 900,
    searchHeight: 58,
    searchRadius: 12,
    searchFontSize: 16,
    searchIconSize: 24,
    sectionTitleSize: 21,
    viewAllSize: 15,
    categoryColumns: 5,
    categoryTileRadius: 14,
    categoryCircle: 70,
    categoryIconSize: 34,
    categoryNameSize: 15,
    categoryCountSize: 13,
    gridGap: 16,
    brandTileWidth: 124,
    brandLogoHeight: 62,
    brandNameSize: 14,
    collectionWidth: 290,
    collectionHeight: 200,
    collectionTitleSize: 19,
    collectionBodySize: 14,
    collectionFabSize: 44,
    popularTileWidth: 140,
    popularImageHeight: 130,
    popularNameSize: 15,
    popularCountSize: 13,
    benefitIconSize: 30,
    benefitTitleSize: 14,
    benefitBodySize: 12,
  );

  static CategoriesMetrics _tabletLandscape() => const CategoriesMetrics._(
    device: CatDeviceClass.tabletLandscape,
    pagePadding: 36,
    sectionGap: 36,
    contentMaxWidth: 1180,
    searchHeight: 58,
    searchRadius: 12,
    searchFontSize: 16,
    searchIconSize: 24,
    sectionTitleSize: 22,
    viewAllSize: 15,
    categoryColumns: 6,
    categoryTileRadius: 14,
    categoryCircle: 74,
    categoryIconSize: 36,
    categoryNameSize: 15,
    categoryCountSize: 13,
    gridGap: 18,
    brandTileWidth: 132,
    brandLogoHeight: 66,
    brandNameSize: 14,
    collectionWidth: 320,
    collectionHeight: 214,
    collectionTitleSize: 20,
    collectionBodySize: 14,
    collectionFabSize: 46,
    popularTileWidth: 150,
    popularImageHeight: 138,
    popularNameSize: 15,
    popularCountSize: 13,
    benefitIconSize: 32,
    benefitTitleSize: 14,
    benefitBodySize: 12,
  );
}
