import 'package:flutter/widgets.dart';

enum OdDeviceClass { phone, tabletPortrait, tabletLandscape }

class OrderDetailMetrics {
  final OdDeviceClass device;

  final double pagePadding;
  final double sectionGap;
  final double contentMaxWidth;

  // Header
  final double logoSize;
  final double headerIconSize;
  final double helpFontSize;

  // Title block
  final double screenTitleSize;
  final double orderIdSize;
  final double placedAtSize;

  // Card
  final double cardRadius;
  final double cardPadding;
  final double sectionLabelSize;

  // Banner
  final double bannerIconBadge;
  final double bannerIconSize;
  final double bannerTitleSize;
  final double bannerBodySize;

  // Timeline
  final double dotSize;
  final double dotInnerSize;
  final double railWidth;
  final double stepGap;
  final double stepTitleSize;
  final double stepBodySize;
  final double illustrationWidth;

  // Address
  final double addressIconBadge;
  final double addressIconSize;
  final double addressNameSize;
  final double addressBodySize;

  // Item
  final double itemThumbWidth;
  final double itemThumbHeight;
  final double itemThumbRadius;
  final double itemBrandSize;
  final double itemNameSize;
  final double itemMetaSize;
  final double itemPriceSize;

  // Price
  final double priceRowSize;
  final double priceTotalSize;
  final double priceRowGap;

  // CTA
  final double ctaHeight;
  final double ctaFontSize;

  const OrderDetailMetrics._({
    required this.device,
    required this.pagePadding,
    required this.sectionGap,
    required this.contentMaxWidth,
    required this.logoSize,
    required this.headerIconSize,
    required this.helpFontSize,
    required this.screenTitleSize,
    required this.orderIdSize,
    required this.placedAtSize,
    required this.cardRadius,
    required this.cardPadding,
    required this.sectionLabelSize,
    required this.bannerIconBadge,
    required this.bannerIconSize,
    required this.bannerTitleSize,
    required this.bannerBodySize,
    required this.dotSize,
    required this.dotInnerSize,
    required this.railWidth,
    required this.stepGap,
    required this.stepTitleSize,
    required this.stepBodySize,
    required this.illustrationWidth,
    required this.addressIconBadge,
    required this.addressIconSize,
    required this.addressNameSize,
    required this.addressBodySize,
    required this.itemThumbWidth,
    required this.itemThumbHeight,
    required this.itemThumbRadius,
    required this.itemBrandSize,
    required this.itemNameSize,
    required this.itemMetaSize,
    required this.itemPriceSize,
    required this.priceRowSize,
    required this.priceTotalSize,
    required this.priceRowGap,
    required this.ctaHeight,
    required this.ctaFontSize,
  });

  bool get isPhone => device == OdDeviceClass.phone;
  bool get isTablet => device != OdDeviceClass.phone;
  bool get isLandscape => device == OdDeviceClass.tabletLandscape;

  /// Landscape tablet pe do-column layout
  bool get useTwoColumns => isLandscape;

  static const double _tabletBreakpoint = 540;
  static const double _phoneReference = 390;

  factory OrderDetailMetrics.of(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final isTablet = size.shortestSide >= _tabletBreakpoint;
    final landscape = size.width > size.height;
    if (!isTablet) return _phone(size.width);
    return landscape ? _tabletLandscape() : _tabletPortrait();
  }

  static OrderDetailMetrics _phone(double w) {
    final s = (w / _phoneReference).clamp(0.85, 1.15);
    double v(double b, double lo, double hi) =>
        (b * s).clamp(lo, hi).toDouble();

    return OrderDetailMetrics._(
      device: OdDeviceClass.phone,
      pagePadding: v(16, 14, 19),
      sectionGap: v(20, 17, 24),
      contentMaxWidth: double.infinity,
      logoSize: v(26, 23, 30),
      headerIconSize: v(24, 22, 27),
      helpFontSize: v(14, 13, 15),
      screenTitleSize: v(22, 19, 25),
      orderIdSize: v(14, 13, 15),
      placedAtSize: v(13, 12, 14),
      cardRadius: 12,
      cardPadding: v(16, 14, 19),
      sectionLabelSize: v(16, 15, 18),
      bannerIconBadge: v(46, 41, 52),
      bannerIconSize: v(22, 20, 25),
      bannerTitleSize: v(15, 14, 16),
      bannerBodySize: v(13, 12, 14),
      dotSize: v(22, 20, 25),
      dotInnerSize: v(10, 9, 12),
      railWidth: 2,
      stepGap: v(26, 23, 30),
      stepTitleSize: v(15, 14, 16),
      stepBodySize: v(13, 12, 14),
      illustrationWidth: v(150, 130, 175),
      addressIconBadge: v(42, 38, 48),
      addressIconSize: v(20, 18, 22),
      addressNameSize: v(15, 14, 16),
      addressBodySize: v(13, 12, 14),
      itemThumbWidth: v(78, 70, 88),
      itemThumbHeight: v(96, 86, 108),
      itemThumbRadius: 8,
      itemBrandSize: v(15, 14, 16),
      itemNameSize: v(13, 12, 14),
      itemMetaSize: v(13, 12, 14),
      itemPriceSize: v(15, 14, 16),
      priceRowSize: v(14, 13, 15),
      priceTotalSize: v(18, 16, 20),
      priceRowGap: v(11, 9, 13),
      ctaHeight: v(36, 33, 40),
      ctaFontSize: v(13, 12, 14),
    );
  }

  static OrderDetailMetrics _tabletPortrait() => const OrderDetailMetrics._(
    device: OdDeviceClass.tabletPortrait,
    pagePadding: 28,
    sectionGap: 26,
    contentMaxWidth: 820,
    logoSize: 34,
    headerIconSize: 28,
    helpFontSize: 17,
    screenTitleSize: 28,
    orderIdSize: 17,
    placedAtSize: 15,
    cardRadius: 16,
    cardPadding: 24,
    sectionLabelSize: 20,
    bannerIconBadge: 58,
    bannerIconSize: 28,
    bannerTitleSize: 18,
    bannerBodySize: 15,
    dotSize: 28,
    dotInnerSize: 13,
    railWidth: 2.5,
    stepGap: 34,
    stepTitleSize: 18,
    stepBodySize: 15,
    illustrationWidth: 210,
    addressIconBadge: 54,
    addressIconSize: 25,
    addressNameSize: 18,
    addressBodySize: 15,
    itemThumbWidth: 104,
    itemThumbHeight: 128,
    itemThumbRadius: 10,
    itemBrandSize: 18,
    itemNameSize: 15,
    itemMetaSize: 15,
    itemPriceSize: 18,
    priceRowSize: 16,
    priceTotalSize: 22,
    priceRowGap: 14,
    ctaHeight: 44,
    ctaFontSize: 15,
  );

  static OrderDetailMetrics _tabletLandscape() => const OrderDetailMetrics._(
    device: OdDeviceClass.tabletLandscape,
    pagePadding: 32,
    sectionGap: 24,
    contentMaxWidth: 1180,
    logoSize: 34,
    headerIconSize: 28,
    helpFontSize: 17,
    screenTitleSize: 28,
    orderIdSize: 16,
    placedAtSize: 14,
    cardRadius: 16,
    cardPadding: 22,
    sectionLabelSize: 19,
    bannerIconBadge: 56,
    bannerIconSize: 27,
    bannerTitleSize: 17,
    bannerBodySize: 14,
    dotSize: 26,
    dotInnerSize: 12,
    railWidth: 2.5,
    stepGap: 30,
    stepTitleSize: 17,
    stepBodySize: 14,
    illustrationWidth: 190,
    addressIconBadge: 52,
    addressIconSize: 24,
    addressNameSize: 17,
    addressBodySize: 14,
    itemThumbWidth: 96,
    itemThumbHeight: 118,
    itemThumbRadius: 10,
    itemBrandSize: 17,
    itemNameSize: 14,
    itemMetaSize: 14,
    itemPriceSize: 17,
    priceRowSize: 15,
    priceTotalSize: 21,
    priceRowGap: 13,
    ctaHeight: 42,
    ctaFontSize: 14,
  );
}
