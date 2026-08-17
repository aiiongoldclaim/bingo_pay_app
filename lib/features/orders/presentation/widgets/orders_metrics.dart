import 'package:flutter/widgets.dart';

enum OrdersDeviceClass { phone, tabletPortrait, tabletLandscape }

class OrdersMetrics {
  final OrdersDeviceClass device;

  final double pagePadding;
  final double sectionGap;
  final double contentMaxWidth;

  // Header
  final double titleSize;
  final double subtitleSize;
  final double headerIconSize;

  // Filter tabs
  final double tabBarHeight;
  final double tabRadius;
  final double tabFontSize;
  final double tabBadgeSize;
  final double tabBadgeFontSize;
  final double tabGap;

  // Card
  final double cardRadius;
  final double cardGap;
  final double orderIdSize;
  final double orderDateSize;
  final double statusSize;

  // Product row
  final double thumbSize;
  final double thumbRadius;
  final double productNameSize;
  final double productMetaSize;
  final double priceSize;

  // Footer strip
  final double footerHeight;
  final double footerIconSize;
  final double footerTextSize;
  final double ctaHeight;
  final double ctaFontSize;

  const OrdersMetrics._({
    required this.device,
    required this.pagePadding,
    required this.sectionGap,
    required this.contentMaxWidth,
    required this.titleSize,
    required this.subtitleSize,
    required this.headerIconSize,
    required this.tabBarHeight,
    required this.tabRadius,
    required this.tabFontSize,
    required this.tabBadgeSize,
    required this.tabBadgeFontSize,
    required this.tabGap,
    required this.cardRadius,
    required this.cardGap,
    required this.orderIdSize,
    required this.orderDateSize,
    required this.statusSize,
    required this.thumbSize,
    required this.thumbRadius,
    required this.productNameSize,
    required this.productMetaSize,
    required this.priceSize,
    required this.footerHeight,
    required this.footerIconSize,
    required this.footerTextSize,
    required this.ctaHeight,
    required this.ctaFontSize,
  });

  bool get isPhone => device == OrdersDeviceClass.phone;
  bool get isTablet => device != OrdersDeviceClass.phone;
  bool get isLandscape => device == OrdersDeviceClass.tabletLandscape;

  /// Landscape tablet pe 2-column grid — warna single column
  int get columns => isLandscape ? 2 : 1;

  static const double _tabletBreakpoint = 540;
  static const double _phoneReference = 390;

  factory OrdersMetrics.of(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final isTablet = size.shortestSide >= _tabletBreakpoint;
    final landscape = size.width > size.height;
    if (!isTablet) return _phone(size.width);
    return landscape ? _tabletLandscape() : _tabletPortrait();
  }

  static OrdersMetrics _phone(double w) {
    final s = (w / _phoneReference).clamp(0.85, 1.15);
    double v(double b, double lo, double hi) =>
        (b * s).clamp(lo, hi).toDouble();

    return OrdersMetrics._(
      device: OrdersDeviceClass.phone,
      pagePadding: v(16, 14, 19),
      sectionGap: v(18, 15, 21),
      contentMaxWidth: double.infinity,
      titleSize: v(24, 21, 27),
      subtitleSize: v(13, 12, 14),
      headerIconSize: v(24, 22, 27),
      tabBarHeight: v(52, 47, 58),
      tabRadius: 10,
      tabFontSize: v(14, 13, 15),
      tabBadgeSize: v(22, 20, 25),
      tabBadgeFontSize: v(11, 10, 12),
      tabGap: v(4, 3, 6),
      cardRadius: 12,
      cardGap: v(14, 12, 17),
      orderIdSize: v(15, 14, 16),
      orderDateSize: v(12, 11, 13),
      statusSize: v(13, 12, 14),
      thumbSize: v(72, 65, 80),
      thumbRadius: 8,
      productNameSize: v(15, 14, 16),
      productMetaSize: v(12, 11, 13),
      priceSize: v(15, 14, 16),
      footerHeight: v(56, 51, 62),
      footerIconSize: v(18, 16, 20),
      footerTextSize: v(12, 11, 13),
      ctaHeight: v(36, 33, 40),
      ctaFontSize: v(13, 12, 14),
    );
  }

  static OrdersMetrics _tabletPortrait() => const OrdersMetrics._(
    device: OrdersDeviceClass.tabletPortrait,
    pagePadding: 28,
    sectionGap: 22,
    contentMaxWidth: 820,
    titleSize: 30,
    subtitleSize: 16,
    headerIconSize: 28,
    tabBarHeight: 62,
    tabRadius: 12,
    tabFontSize: 16,
    tabBadgeSize: 27,
    tabBadgeFontSize: 13,
    tabGap: 6,
    cardRadius: 16,
    cardGap: 18,
    orderIdSize: 18,
    orderDateSize: 14,
    statusSize: 15,
    thumbSize: 96,
    thumbRadius: 10,
    productNameSize: 18,
    productMetaSize: 14,
    priceSize: 18,
    footerHeight: 68,
    footerIconSize: 22,
    footerTextSize: 14,
    ctaHeight: 44,
    ctaFontSize: 15,
  );

  static OrdersMetrics _tabletLandscape() => const OrdersMetrics._(
    device: OrdersDeviceClass.tabletLandscape,
    pagePadding: 32,
    sectionGap: 22,
    contentMaxWidth: 1180,
    titleSize: 30,
    subtitleSize: 16,
    headerIconSize: 28,
    tabBarHeight: 62,
    tabRadius: 12,
    tabFontSize: 16,
    tabBadgeSize: 27,
    tabBadgeFontSize: 13,
    tabGap: 6,
    cardRadius: 16,
    cardGap: 18,
    orderIdSize: 17,
    orderDateSize: 14,
    statusSize: 15,
    thumbSize: 88,
    thumbRadius: 10,
    productNameSize: 17,
    productMetaSize: 13,
    priceSize: 17,
    footerHeight: 66,
    footerIconSize: 21,
    footerTextSize: 13,
    ctaHeight: 42,
    ctaFontSize: 14,
  );
}
