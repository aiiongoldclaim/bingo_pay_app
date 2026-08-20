import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

class TransactionsMetrics {
  final bool isTablet;
  final bool isLandscape;

  final double pageHPad;
  final double pageVPad;
  final double maxContentWidth;

  final double backIconSize;
  final double titleSize;
  final double subtitleSize;

  final double chipHeight;
  final double chipHPad;
  final double chipFontSize;
  final double chipRadius;

  final double cardRadius;
  final double cardPad;
  final double iconBox;
  final double iconSize;
  final double gatewaySize;
  final double metaSize;
  final double amountSize;
  final double badgeHeight;
  final double badgeFontSize;

  final int crossAxisCount;
  final double gridSpacing;

  final double emptyIllustration;
  final double emptyTitleSize;
  final double emptySubSize;
  final double btnHeight;
  final double btnFontSize;

  final double gapXs;
  final double gapSm;
  final double gapMd;
  final double gapLg;

  const TransactionsMetrics({
    required this.isTablet,
    required this.isLandscape,
    required this.pageHPad,
    required this.pageVPad,
    required this.maxContentWidth,
    required this.backIconSize,
    required this.titleSize,
    required this.subtitleSize,
    required this.chipHeight,
    required this.chipHPad,
    required this.chipFontSize,
    required this.chipRadius,
    required this.cardRadius,
    required this.cardPad,
    required this.iconBox,
    required this.iconSize,
    required this.gatewaySize,
    required this.metaSize,
    required this.amountSize,
    required this.badgeHeight,
    required this.badgeFontSize,
    required this.crossAxisCount,
    required this.gridSpacing,
    required this.emptyIllustration,
    required this.emptyTitleSize,
    required this.emptySubSize,
    required this.btnHeight,
    required this.btnFontSize,
    required this.gapXs,
    required this.gapSm,
    required this.gapMd,
    required this.gapLg,
  });

  static TransactionsMetrics of(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final isTablet = size.shortestSide >= 540;
    final isLandscape = size.width > size.height;
    if (!isTablet) return TransactionsMetrics.phone();
    return isLandscape
        ? TransactionsMetrics.tabletLandscape(size)
        : TransactionsMetrics.tabletPortrait(size);
  }

  factory TransactionsMetrics.phone() => TransactionsMetrics(
    isTablet: false,
    isLandscape: false,
    pageHPad: 4.w,
    pageVPad: 1.2.h,
    maxContentWidth: double.infinity,
    backIconSize: 20.sp,
    titleSize: 20.sp,
    subtitleSize: 12.sp,
    chipHeight: 4.4.h,
    chipHPad: 4.w,
    chipFontSize: 12.sp,
    chipRadius: 24,
    cardRadius: 16,
    cardPad: 4.w,
    iconBox: 12.w,
    iconSize: 20.sp,
    gatewaySize: 14.sp,
    metaSize: 12.sp,
    amountSize: 15.sp,
    badgeHeight: 3.2.h,
    badgeFontSize: 10.sp,
    crossAxisCount: 1,
    gridSpacing: 1.4.h,
    emptyIllustration: 34.w,
    emptyTitleSize: 17.sp,
    emptySubSize: 13.sp,
    btnHeight: 6.2.h,
    btnFontSize: 14.sp,
    gapXs: 0.5.h,
    gapSm: 1.h,
    gapMd: 1.8.h,
    gapLg: 2.6.h,
  );

  factory TransactionsMetrics.tabletPortrait(Size size) => TransactionsMetrics(
    isTablet: true,
    isLandscape: false,
    pageHPad: (size.width * 0.06).clamp(24.0, 60.0),
    pageVPad: 12,
    maxContentWidth: 800,
    backIconSize: 22,
    titleSize: 27,
    subtitleSize: 15,
    chipHeight: 42,
    chipHPad: 20,
    chipFontSize: 15,
    chipRadius: 24,
    cardRadius: 18,
    cardPad: 20,
    iconBox: 54,
    iconSize: 25,
    gatewaySize: 18,
    metaSize: 15,
    amountSize: 19,
    badgeHeight: 30,
    badgeFontSize: 12,
    crossAxisCount: 1,
    gridSpacing: 14,
    emptyIllustration: 180,
    emptyTitleSize: 22,
    emptySubSize: 16,
    btnHeight: 54,
    btnFontSize: 17,
    gapXs: 4,
    gapSm: 10,
    gapMd: 18,
    gapLg: 26,
  );

  factory TransactionsMetrics.tabletLandscape(Size size) => TransactionsMetrics(
    isTablet: true,
    isLandscape: true,
    pageHPad: (size.width * 0.035).clamp(20.0, 48.0),
    pageVPad: 10,
    maxContentWidth: 1240,
    backIconSize: 20,
    titleSize: 25,
    subtitleSize: 14,
    chipHeight: 38,
    chipHPad: 18,
    chipFontSize: 14,
    chipRadius: 22,
    cardRadius: 18,
    cardPad: 16,
    iconBox: 48,
    iconSize: 23,
    gatewaySize: 17,
    metaSize: 14,
    amountSize: 18,
    badgeHeight: 28,
    badgeFontSize: 11,
    crossAxisCount: 2,
    gridSpacing: 12,
    emptyIllustration: 150,
    emptyTitleSize: 20,
    emptySubSize: 15,
    btnHeight: 50,
    btnFontSize: 16,
    gapXs: 3,
    gapSm: 8,
    gapMd: 14,
    gapLg: 22,
  );
}