import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

class AppProductCardMetrics {
  final bool isTablet;
  final bool isLandscape;

  final double radius;
  final double pad;

  final double heartBox;
  final double heartIcon;

  final double brandSize;
  final double nameSize;
  final double priceSize;
  final double metaSize;

  final double btnHeight;
  final double btnFont;
  final double btnIcon;

  final double gapXs;
  final double gapSm;

  const AppProductCardMetrics({
    required this.isTablet,
    required this.isLandscape,
    required this.radius,
    required this.pad,
    required this.heartBox,
    required this.heartIcon,
    required this.brandSize,
    required this.nameSize,
    required this.priceSize,
    required this.metaSize,
    required this.btnHeight,
    required this.btnFont,
    required this.btnIcon,
    required this.gapXs,
    required this.gapSm,
  });

  factory AppProductCardMetrics.of(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final isTablet = size.shortestSide >= 540;
    final isLandscape = size.width > size.height;

    if (!isTablet) return AppProductCardMetrics.phone();
    return isLandscape
        ? AppProductCardMetrics.tabletLandscape()
        : AppProductCardMetrics.tabletPortrait();
  }

  // ────────────────────────────────────────────────────────
  // PHONE
  // ────────────────────────────────────────────────────────
  factory AppProductCardMetrics.phone() => AppProductCardMetrics(
    isTablet: false,
    isLandscape: false,
    radius: 16,
    pad: 3.w,
    heartBox: 9.5.w,
    heartIcon: 17.sp,
    brandSize: 13.sp,
    nameSize: 15.5.sp,
    priceSize: 17.sp,
    metaSize: 13.sp,
    btnHeight: 4.8.h,
    btnFont: 13.sp,
    btnIcon: 15.sp,
    gapXs: 0.5.h,
    gapSm: 0.9.h,
  );

  // ────────────────────────────────────────────────────────
  // TABLET PORTRAIT — fixed dp
  // ────────────────────────────────────────────────────────
  factory AppProductCardMetrics.tabletPortrait() =>
      const AppProductCardMetrics(
        isTablet: true,
        isLandscape: false,
        radius: 18,
        pad: 14,
        heartBox: 42,
        heartIcon: 21,
        brandSize: 15,
        nameSize: 18.5,
        priceSize: 21,
        metaSize: 15.5,
        btnHeight: 42,
        btnFont: 15,
        btnIcon: 18,
        gapXs: 4,
        gapSm: 8,
      );

  // ────────────────────────────────────────────────────────
  // TABLET LANDSCAPE — fixed dp
  // ────────────────────────────────────────────────────────
  factory AppProductCardMetrics.tabletLandscape() =>
      const AppProductCardMetrics(
        isTablet: true,
        isLandscape: true,
        radius: 18,
        pad: 12,
        heartBox: 38,
        heartIcon: 19,
        brandSize: 14,
        nameSize: 17.5,
        priceSize: 20,
        metaSize: 14.5,
        btnHeight: 38,
        btnFont: 14,
        btnIcon: 17,
        gapXs: 4,
        gapSm: 8,
      );
}
