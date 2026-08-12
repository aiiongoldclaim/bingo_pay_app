import 'package:flutter/widgets.dart';

enum HomeDeviceClass { phone, tabletPortrait, tabletLandscape }

/// Centralised sizing for the Home screen.
///
/// Phone values scale off a 390dp reference width and are clamped so text
/// never grows or shrinks past a readable band. Tablet values are fixed dp —
/// scaling them would oversize badly on 7"–11" devices.
class HomeMetrics {
  final HomeDeviceClass device;

  // ── Layout ────────────────────────────────────────────
  final double pagePadding;
  final double sectionGap;
  final double contentMaxWidth;

  // ── Header ────────────────────────────────────────────
  final double logoSize;
  final double headerIconSize;
  final double headerHeight;

  // ── Search ────────────────────────────────────────────
  final double searchHeight;
  final double searchRadius;
  final double searchFontSize;
  final double searchIconSize;

  // ── Category tabs ─────────────────────────────────────
  final double tabFontSize;
  final double tabGap;
  final double tabBarHeight;

  // ── Hero banner ───────────────────────────────────────
  final double heroHeight;
  final double heroAspectRatio;
  final double heroRadius;
  final double heroEyebrowSize;
  final double heroTitleSize;
  final double heroBodySize;

  // ── Category shortcuts ────────────────────────────────
  final double categoryCircle;
  final double categoryIconSize;
  final double categoryLabelSize;
  final int categoryPerRow;

  // ── Book services ─────────────────────────────────────
  final double serviceTileSize;
  final double serviceTileMinWidth;
  final double serviceIconSize;
  final double serviceLabelSize;

  // ── Product card ──────────────────────────────────────
  final double productCardWidth;
  final double productImageHeight;
  final double productBrandSize;
  final double productNameSize;
  final double productPriceSize;

  // ── Section header ────────────────────────────────────
  final double sectionTitleSize;
  final double viewAllSize;

  // ── Benefits strip ────────────────────────────────────
  final double benefitIconSize;
  final double benefitTextSize;

  const HomeMetrics._({
    required this.device,
    required this.pagePadding,
    required this.sectionGap,
    required this.contentMaxWidth,
    required this.logoSize,
    required this.headerIconSize,
    required this.headerHeight,
    required this.searchHeight,
    required this.searchRadius,
    required this.searchFontSize,
    required this.searchIconSize,
    required this.tabFontSize,
    required this.tabGap,
    required this.tabBarHeight,
    required this.heroHeight,
    required this.heroAspectRatio,
    required this.heroRadius,
    required this.heroEyebrowSize,
    required this.heroTitleSize,
    required this.heroBodySize,
    required this.categoryCircle,
    required this.categoryIconSize,
    required this.categoryLabelSize,
    required this.categoryPerRow,
    required this.serviceTileSize,
    required this.serviceTileMinWidth,
    required this.serviceIconSize,
    required this.serviceLabelSize,
    required this.productCardWidth,
    required this.productImageHeight,
    required this.productBrandSize,
    required this.productNameSize,
    required this.productPriceSize,
    required this.sectionTitleSize,
    required this.viewAllSize,
    required this.benefitIconSize,
    required this.benefitTextSize,
  });

  // ── Device helpers ────────────────────────────────────
  bool get isPhone => device == HomeDeviceClass.phone;
  bool get isTablet => device != HomeDeviceClass.phone;
  bool get isTabletPortrait => device == HomeDeviceClass.tabletPortrait;
  bool get isLandscape => device == HomeDeviceClass.tabletLandscape;

  // ── Derived heights ───────────────────────────────────

  /// Category shortcut item width — label ko 2 lines ka room deta hai.
  double get categoryItemWidth => categoryCircle * 1.25;

  /// Circle + gap + 2-line label + safety buffer.
  double get categoryRowHeight =>
      categoryCircle + pagePadding * 0.45 + categoryLabelSize * 2.6 + 4;

  /// Image + brand + name + price + discount row + cart button + gaps.
  double get productCardHeight =>
      productImageHeight +
      productBrandSize * 1.5 +
      productNameSize * 1.6 +
      productPriceSize * 1.6 +
      productNameSize * 1.6 +
      searchIconSize +
      pagePadding * 2.2;

  /// Service tile ki intrinsic height (icon + label + vertical padding).
  double get serviceTileHeight =>
      serviceIconSize + serviceLabelSize * 1.4 + pagePadding * 1.3;

  /// Bottom nav ke peeche content chhupne se bachane ke liye trailing space.
  double get bottomSafeGap => sectionGap * 2 + searchHeight * 1.6;

  static const double _tabletBreakpoint = 540;
  static const double _phoneReferenceWidth = 390;

  factory HomeMetrics.of(BuildContext context) {
    // MediaQuery.sizeOf — orientation-independent, LayoutBuilder constraints
    // se nahi (wo scrollable ancestor ke andar galat aati hain).
    final size = MediaQuery.sizeOf(context);
    final isTablet = size.shortestSide >= _tabletBreakpoint;
    final landscape = size.width > size.height;

    if (!isTablet) return _phone(size.width);
    return landscape ? _tabletLandscape() : _tabletPortrait();
  }

  // ────────────────────────────────────────────────────────
  // PHONE — Sizer-style scaling, clamped
  // ────────────────────────────────────────────────────────
  static HomeMetrics _phone(double screenWidth) {
    final s = (screenWidth / _phoneReferenceWidth).clamp(0.85, 1.15);
    double v(double base, double lo, double hi) =>
        (base * s).clamp(lo, hi).toDouble();

    return HomeMetrics._(
      device: HomeDeviceClass.phone,

      pagePadding: v(16, 14, 19),
      sectionGap: v(22, 18, 26),
      contentMaxWidth: double.infinity,

      logoSize: v(30, 26, 34),
      headerIconSize: v(24, 22, 27),
      headerHeight: v(52, 48, 58),

      searchHeight: v(48, 44, 54),
      searchRadius: 10,
      searchFontSize: v(14, 13, 15),
      searchIconSize: v(20, 18, 22),

      tabFontSize: v(13, 12, 14),
      tabGap: v(22, 18, 26),
      tabBarHeight: v(42, 38, 48),

      heroHeight: v(230, 210, 260),
      heroAspectRatio: 1.55,
      heroRadius: 14,
      heroEyebrowSize: v(11, 10, 12),
      heroTitleSize: v(22, 19, 25),
      heroBodySize: v(13, 12, 14),

      categoryCircle: v(60, 54, 66),
      categoryIconSize: v(28, 25, 31),
      categoryLabelSize: v(11, 10, 12),
      categoryPerRow: 5,

      serviceTileSize: v(62, 56, 70),
      serviceTileMinWidth: v(58, 52, 64),
      serviceIconSize: v(26, 23, 29),
      serviceLabelSize: v(10, 9, 11),

      productCardWidth: v(142, 130, 158),
      productImageHeight: v(168, 150, 185),
      productBrandSize: v(12, 11, 13),
      productNameSize: v(11, 10, 12),
      productPriceSize: v(14, 13, 15),

      sectionTitleSize: v(16, 15, 18),
      viewAllSize: v(12, 11, 13),

      benefitIconSize: v(20, 18, 22),
      benefitTextSize: v(10, 9, 11),
    );
  }

  // ────────────────────────────────────────────────────────
  // TABLET PORTRAIT — fixed dp
  // ────────────────────────────────────────────────────────
  static HomeMetrics _tabletPortrait() => const HomeMetrics._(
    device: HomeDeviceClass.tabletPortrait,

    pagePadding: 28,
    sectionGap: 30,
    contentMaxWidth: 900,

    logoSize: 40,
    headerIconSize: 28,
    headerHeight: 64,

    searchHeight: 56,
    searchRadius: 12,
    searchFontSize: 16,
    searchIconSize: 24,

    tabFontSize: 15,
    tabGap: 32,
    tabBarHeight: 52,

    heroHeight: 320,
    heroAspectRatio: 2.2,
    heroRadius: 18,
    heroEyebrowSize: 13,
    heroTitleSize: 32,
    heroBodySize: 16,

    categoryCircle: 82,
    categoryIconSize: 38,
    categoryLabelSize: 13,
    categoryPerRow: 7,

    serviceTileSize: 86,
    serviceTileMinWidth: 78,
    serviceIconSize: 34,
    serviceLabelSize: 12,

    productCardWidth: 200,
    productImageHeight: 240,
    productBrandSize: 14,
    productNameSize: 13,
    productPriceSize: 17,

    sectionTitleSize: 20,
    viewAllSize: 14,

    benefitIconSize: 26,
    benefitTextSize: 13,
  );

  // ────────────────────────────────────────────────────────
  // TABLET LANDSCAPE — fixed dp
  // ────────────────────────────────────────────────────────
  static HomeMetrics _tabletLandscape() => const HomeMetrics._(
    device: HomeDeviceClass.tabletLandscape,

    pagePadding: 36,
    sectionGap: 32,
    contentMaxWidth: 1180,

    logoSize: 42,
    headerIconSize: 28,
    headerHeight: 66,

    searchHeight: 56,
    searchRadius: 12,
    searchFontSize: 16,
    searchIconSize: 24,

    tabFontSize: 15,
    tabGap: 38,
    tabBarHeight: 54,

    heroHeight: 340,
    heroAspectRatio: 2.8,
    heroRadius: 20,
    heroEyebrowSize: 13,
    heroTitleSize: 34,
    heroBodySize: 16,

    categoryCircle: 88,
    categoryIconSize: 40,
    categoryLabelSize: 13,
    categoryPerRow: 7,

    serviceTileSize: 92,
    serviceTileMinWidth: 84,
    serviceIconSize: 36,
    serviceLabelSize: 12,

    productCardWidth: 216,
    productImageHeight: 250,
    productBrandSize: 14,
    productNameSize: 13,
    productPriceSize: 17,

    sectionTitleSize: 21,
    viewAllSize: 14,

    benefitIconSize: 28,
    benefitTextSize: 13,
  );
}
