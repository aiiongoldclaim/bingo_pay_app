import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

class ProductsMetrics {
  final bool isTablet;
  final bool isLandscape;

  final double pageHPad;
  final double pageVPad;
  final double maxContentWidth;

  final double backIconSize;
  final double titleSize;
  final double subtitleSize;
  final double topIconSize;

  final int crossAxisCount;
  final double gridSpacing;
  final double cardAspectRatio;

  final double emptyIllustration;
  final double emptyTitleSize;
  final double emptySubSize;
  final double btnHeight;
  final double btnFontSize;

  final double gapXs;
  final double gapSm;
  final double gapMd;
  final double gapLg;

  const ProductsMetrics({
    required this.isTablet,
    required this.isLandscape,
    required this.pageHPad,
    required this.pageVPad,
    required this.maxContentWidth,
    required this.backIconSize,
    required this.titleSize,
    required this.subtitleSize,
    required this.topIconSize,
    required this.crossAxisCount,
    required this.gridSpacing,
    required this.cardAspectRatio,
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

  static ProductsMetrics of(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final isTablet = size.shortestSide >= 540;
    final isLandscape = size.width > size.height;
    if (!isTablet) return ProductsMetrics.phone();
    return isLandscape
        ? ProductsMetrics.tabletLandscape(size)
        : ProductsMetrics.tabletPortrait(size);
  }

  factory ProductsMetrics.phone() => ProductsMetrics(
    isTablet: false,
    isLandscape: false,
    pageHPad: 4.w,
    pageVPad: 1.2.h,
    maxContentWidth: double.infinity,
    backIconSize: 20.sp,
    titleSize: 20.sp,
    subtitleSize: 12.sp,
    topIconSize: 21.sp,
    crossAxisCount: 2,
    gridSpacing: 3.w,
    cardAspectRatio: 0.54,
    emptyIllustration: 34.w,
    emptyTitleSize: 17.sp,
    emptySubSize: 13.sp,
    btnHeight: 5.6.h,
    btnFontSize: 14.sp,
    gapXs: 0.5.h,
    gapSm: 1.h,
    gapMd: 1.8.h,
    gapLg: 2.6.h,
  );

  factory ProductsMetrics.tabletPortrait(Size size) => ProductsMetrics(
    isTablet: true,
    isLandscape: false,
    pageHPad: (size.width * 0.05).clamp(24.0, 56.0),
    pageVPad: 12,
    maxContentWidth: 900,
    backIconSize: 22,
    titleSize: 26,
    subtitleSize: 15,
    topIconSize: 25,
    crossAxisCount: 3,
    gridSpacing: 16,
    cardAspectRatio: 0.60,
    emptyIllustration: 180,
    emptyTitleSize: 22,
    emptySubSize: 16,
    btnHeight: 50,
    btnFontSize: 16,
    gapXs: 4,
    gapSm: 10,
    gapMd: 16,
    gapLg: 24,
  );

  factory ProductsMetrics.tabletLandscape(Size size) => ProductsMetrics(
    isTablet: true,
    isLandscape: true,
    pageHPad: (size.width * 0.035).clamp(20.0, 48.0),
    pageVPad: 10,
    maxContentWidth: 1280,
    backIconSize: 20,
    titleSize: 24,
    subtitleSize: 14,
    topIconSize: 23,
    crossAxisCount: 4,
    gridSpacing: 14,
    cardAspectRatio: 0.62,
    emptyIllustration: 150,
    emptyTitleSize: 20,
    emptySubSize: 15,
    btnHeight: 46,
    btnFontSize: 15,
    gapXs: 3,
    gapSm: 8,
    gapMd: 14,
    gapLg: 20,
  );
}
