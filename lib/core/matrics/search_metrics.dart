import 'package:flutter/widgets.dart';

enum SearchDeviceClass { phone, tabletPortrait, tabletLandscape }

class SearchMetrics {
  final SearchDeviceClass device;

  final double pagePadding;
  final double sectionGap;
  final double contentMaxWidth;

  // Input bar
  final double inputHeight;
  final double inputRadius;
  final double inputFontSize;
  final double inputIconSize;
  final double backIconSize;
  final double cancelFontSize;

  // Section header
  final double sectionTitleSize;
  final double viewAllSize;

  // Trending
  final double trendingTileWidth;
  final double trendingImageHeight;
  final double trendingLabelSize;
  final double trendingRadius;

  // Recent
  final double recentRowHeight;
  final double recentIconSize;
  final double recentIconBadge;
  final double recentFontSize;

  // Suggested chips
  final double chipHeight;
  final double chipFontSize;
  final double chipIconSize;
  final double chipGap;

  // Brands
  final double brandCircle;
  final double brandLabelSize;
  final double brandLogoInset;

  const SearchMetrics._({
    required this.device,
    required this.pagePadding,
    required this.sectionGap,
    required this.contentMaxWidth,
    required this.inputHeight,
    required this.inputRadius,
    required this.inputFontSize,
    required this.inputIconSize,
    required this.backIconSize,
    required this.cancelFontSize,
    required this.sectionTitleSize,
    required this.viewAllSize,
    required this.trendingTileWidth,
    required this.trendingImageHeight,
    required this.trendingLabelSize,
    required this.trendingRadius,
    required this.recentRowHeight,
    required this.recentIconSize,
    required this.recentIconBadge,
    required this.recentFontSize,
    required this.chipHeight,
    required this.chipFontSize,
    required this.chipIconSize,
    required this.chipGap,
    required this.brandCircle,
    required this.brandLabelSize,
    required this.brandLogoInset,
  });

  bool get isPhone => device == SearchDeviceClass.phone;
  bool get isTablet => device != SearchDeviceClass.phone;

  double get trendingRowHeight =>
      trendingImageHeight + pagePadding * 0.55 + trendingLabelSize * 1.6 + 4;

  double get brandRowHeight =>
      brandCircle + pagePadding * 0.5 + brandLabelSize * 1.6 + 4;

  static const double _tabletBreakpoint = 540;
  static const double _phoneReferenceWidth = 390;

  factory SearchMetrics.of(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final isTablet = size.shortestSide >= _tabletBreakpoint;
    final landscape = size.width > size.height;

    if (!isTablet) return _phone(size.width);
    return landscape ? _tabletLandscape() : _tabletPortrait();
  }

  static SearchMetrics _phone(double screenWidth) {
    final s = (screenWidth / _phoneReferenceWidth).clamp(0.85, 1.15);
    double v(double base, double lo, double hi) =>
        (base * s).clamp(lo, hi).toDouble();

    return SearchMetrics._(
      device: SearchDeviceClass.phone,
      pagePadding: v(16, 14, 19),
      sectionGap: v(26, 22, 30),
      contentMaxWidth: double.infinity,
      inputHeight: v(46, 42, 52),
      inputRadius: 999,
      inputFontSize: v(14, 13, 15),
      inputIconSize: v(20, 18, 22),
      backIconSize: v(24, 22, 27),
      cancelFontSize: v(15, 14, 16),
      sectionTitleSize: v(13, 12, 14),
      viewAllSize: v(12, 11, 13),
      trendingTileWidth: v(84, 76, 94),
      trendingImageHeight: v(84, 76, 94),
      trendingLabelSize: v(12, 11, 13),
      trendingRadius: 8,
      recentRowHeight: v(52, 48, 58),
      recentIconSize: v(16, 14, 18),
      recentIconBadge: v(30, 27, 34),
      recentFontSize: v(14, 13, 15),
      chipHeight: v(40, 36, 45),
      chipFontSize: v(13, 12, 14),
      chipIconSize: v(15, 13, 17),
      chipGap: v(10, 8, 12),
      brandCircle: v(62, 56, 70),
      brandLabelSize: v(11, 10, 12),
      brandLogoInset: v(12, 10, 14),
    );
  }

  static SearchMetrics _tabletPortrait() => const SearchMetrics._(
    device: SearchDeviceClass.tabletPortrait,
    pagePadding: 28,
    sectionGap: 34,
    contentMaxWidth: 860,
    inputHeight: 56,
    inputRadius: 999,
    inputFontSize: 16,
    inputIconSize: 24,
    backIconSize: 28,
    cancelFontSize: 17,
    sectionTitleSize: 15,
    viewAllSize: 14,
    trendingTileWidth: 118,
    trendingImageHeight: 118,
    trendingLabelSize: 14,
    trendingRadius: 10,
    recentRowHeight: 62,
    recentIconSize: 19,
    recentIconBadge: 38,
    recentFontSize: 16,
    chipHeight: 46,
    chipFontSize: 15,
    chipIconSize: 17,
    chipGap: 12,
    brandCircle: 84,
    brandLabelSize: 13,
    brandLogoInset: 16,
  );

  static SearchMetrics _tabletLandscape() => const SearchMetrics._(
    device: SearchDeviceClass.tabletLandscape,
    pagePadding: 36,
    sectionGap: 34,
    contentMaxWidth: 1080,
    inputHeight: 56,
    inputRadius: 999,
    inputFontSize: 16,
    inputIconSize: 24,
    backIconSize: 28,
    cancelFontSize: 17,
    sectionTitleSize: 15,
    viewAllSize: 14,
    trendingTileWidth: 126,
    trendingImageHeight: 126,
    trendingLabelSize: 14,
    trendingRadius: 10,
    recentRowHeight: 62,
    recentIconSize: 19,
    recentIconBadge: 38,
    recentFontSize: 16,
    chipHeight: 46,
    chipFontSize: 15,
    chipIconSize: 17,
    chipGap: 12,
    brandCircle: 88,
    brandLabelSize: 13,
    brandLogoInset: 16,
  );
}
