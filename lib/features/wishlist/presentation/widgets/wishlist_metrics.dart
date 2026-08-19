import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

class WishlistMetrics {
  final bool isTablet;
  final bool isLandscape;

  // Page
  final double pageHPad;
  final double pageVPad;
  final double maxContentWidth;

  // Top bar
  final double titleSize;
  final double subtitleSize;
  final double topIconSize;

  // Filter chips
  // final double chipHeight;
  // final double chipHPad;
  // final double chipFontSize;
  // final double chipRadius;

  // Grid
  final int crossAxisCount;
  final double gridSpacing;
  final double cardAspectRatio;



  // Card
  final double cardRadius;
  final double cardPad;
  final double imageRatio;
  final double heartBox;
  final double heartIcon;
  final double brandSize;
  final double nameSize;
  final double priceSize;
  final double sizeChipSize;
  final double actionHeight;
  final double actionFontSize;
  final double actionIconSize;
  final double moreBoxWidth;

  // Promo banner
  final double promoRadius;
  final double promoPad;
  final double promoTitleSize;
  final double promoSubSize;
  final double promoBtnHeight;
  final double promoBtnFontSize;
  final double promoArtSize;

  // Empty
  final double emptyIllustration;
  final double emptyTitleSize;
  final double emptySubSize;

  final double gapXs;
  final double gapSm;
  final double gapMd;
  final double gapLg;

  const WishlistMetrics({
    required this.isTablet,
    required this.isLandscape,
    required this.pageHPad,
    required this.pageVPad,
    required this.maxContentWidth,
    required this.titleSize,
    required this.subtitleSize,
    required this.topIconSize,
    // required this.chipHeight,
    // required this.chipHPad,
    // required this.chipFontSize,
    // required this.chipRadius,
    required this.crossAxisCount,
    required this.gridSpacing,
    required this.cardAspectRatio,
    required this.cardRadius,
    required this.cardPad,
    required this.imageRatio,
    required this.heartBox,
    required this.heartIcon,
    required this.brandSize,
    required this.nameSize,
    required this.priceSize,
    required this.sizeChipSize,
    required this.actionHeight,
    required this.actionFontSize,
    required this.actionIconSize,
    required this.moreBoxWidth,
    required this.promoRadius,
    required this.promoPad,
    required this.promoTitleSize,
    required this.promoSubSize,
    required this.promoBtnHeight,
    required this.promoBtnFontSize,
    required this.promoArtSize,
    required this.emptyIllustration,
    required this.emptyTitleSize,
    required this.emptySubSize,
    required this.gapXs,
    required this.gapSm,
    required this.gapMd,
    required this.gapLg,
  });

  static WishlistMetrics of(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final isTablet = size.shortestSide >= 540;
    final isLandscape = size.width > size.height;
    if (!isTablet) return WishlistMetrics.phone();
    return isLandscape
        ? WishlistMetrics.tabletLandscape(size)
        : WishlistMetrics.tabletPortrait(size);
  }

  // ── PHONE ───────────────────────────────────────────────────────────────
  factory WishlistMetrics.phone() => WishlistMetrics(
    isTablet: false,
    isLandscape: false,
    pageHPad: 4.w,
    pageVPad: 1.2.h,
    maxContentWidth: double.infinity,
    titleSize: 22.sp,
    subtitleSize: 12.sp,
    topIconSize: 21.sp,
    // chipHeight: 4.6.h,
    // chipHPad: 4.w,
    // chipFontSize: 12.sp,
    // chipRadius: 24,
    crossAxisCount: 2,
    gridSpacing: 3.w,
    cardAspectRatio: 0.60,
    cardRadius: 16,
    cardPad: 3.w,
    imageRatio: 1.0,
    heartBox: 9.w,
    heartIcon: 16.sp,
    brandSize: 11.sp,
    nameSize: 13.sp,
    priceSize: 14.sp,
    sizeChipSize: 11.sp,
    actionHeight: 4.4.h,
    actionFontSize: 12.sp,
    actionIconSize: 14.sp,
    moreBoxWidth: 12.w,
    promoRadius: 16,
    promoPad: 4.w,
    promoTitleSize: 18.sp,
    promoSubSize: 12.sp,
    promoBtnHeight: 5.2.h,
    promoBtnFontSize: 13.sp,
    promoArtSize: 30.w,
    emptyIllustration: 34.w,
    emptyTitleSize: 17.sp,
    emptySubSize: 13.sp,
    gapXs: 0.5.h,
    gapSm: 1.h,
    gapMd: 1.8.h,
    gapLg: 2.6.h,
  );

  // ── TABLET PORTRAIT ─────────────────────────────────────────────────────
  factory WishlistMetrics.tabletPortrait(Size size) => WishlistMetrics(
    isTablet: true,
    isLandscape: false,
    pageHPad: (size.width * 0.05).clamp(24.0, 56.0),
    pageVPad: 12,
    maxContentWidth: 900,
    titleSize: 30,
    subtitleSize: 15,
    topIconSize: 26,
    // chipHeight: 44,
    // chipHPad: 20,
    // chipFontSize: 15,
    // chipRadius: 24,
    crossAxisCount: 3,
    gridSpacing: 16,
    cardAspectRatio: 0.66,
    cardRadius: 18,
    cardPad: 14,
    imageRatio: 1.0,
    heartBox: 40,
    heartIcon: 20,
    brandSize: 13,
    nameSize: 16,
    priceSize: 17,
    sizeChipSize: 13,
    actionHeight: 40,
    actionFontSize: 14,
    actionIconSize: 17,
    moreBoxWidth: 52,
    promoRadius: 20,
    promoPad: 24,
    promoTitleSize: 26,
    promoSubSize: 16,
    promoBtnHeight: 48,
    promoBtnFontSize: 16,
    promoArtSize: 170,
    emptyIllustration: 180,
    emptyTitleSize: 22,
    emptySubSize: 16,
    gapXs: 4,
    gapSm: 10,
    gapMd: 16,
    gapLg: 24,
  );

  // ── TABLET LANDSCAPE ────────────────────────────────────────────────────
  factory WishlistMetrics.tabletLandscape(Size size) => WishlistMetrics(
    isTablet: true,
    isLandscape: true,
    pageHPad: (size.width * 0.035).clamp(20.0, 48.0),
    pageVPad: 10,
    maxContentWidth: 1280,
    titleSize: 27,
    subtitleSize: 14,
    topIconSize: 24,
    // chipHeight: 40,
    // chipHPad: 18,
    // chipFontSize: 14,
    // chipRadius: 22,
    crossAxisCount: 4,
    gridSpacing: 14,
    cardAspectRatio: 0.68,
    cardRadius: 18,
    cardPad: 12,
    imageRatio: 1.0,
    heartBox: 36,
    heartIcon: 18,
    brandSize: 12,
    nameSize: 15,
    priceSize: 16,
    sizeChipSize: 12,
    actionHeight: 36,
    actionFontSize: 13,
    actionIconSize: 16,
    moreBoxWidth: 46,
    promoRadius: 20,
    promoPad: 20,
    promoTitleSize: 24,
    promoSubSize: 15,
    promoBtnHeight: 44,
    promoBtnFontSize: 15,
    promoArtSize: 150,
    emptyIllustration: 150,
    emptyTitleSize: 20,
    emptySubSize: 15,
    gapXs: 3,
    gapSm: 8,
    gapMd: 14,
    gapLg: 20,
  );
}