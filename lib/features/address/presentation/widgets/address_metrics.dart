import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

class AddressMetrics {
  final bool isTablet;
  final bool isLandscape;

  final double pageHPad;
  final double pageVPad;
  final double maxContentWidth;

  final double backIconSize;
  final double titleSize;
  final double subtitleSize;

  final double cardRadius;
  final double cardPad;
  final double radioSize;
  final double nameSize;
  final double tagFontSize;
  final double phoneSize;
  final double bodySize;
  final double actionFontSize;
  final double actionHeight;
  final double actionIconSize;

  final double addBtnHeight;
  final double addBtnFontSize;

  final double emptyIllustration;
  final double emptyTitleSize;
  final double emptySubSize;

  final double gapXs;
  final double gapSm;
  final double gapMd;
  final double gapLg;

  const AddressMetrics({
    required this.isTablet,
    required this.isLandscape,
    required this.pageHPad,
    required this.pageVPad,
    required this.maxContentWidth,
    required this.backIconSize,
    required this.titleSize,
    required this.subtitleSize,
    required this.cardRadius,
    required this.cardPad,
    required this.radioSize,
    required this.nameSize,
    required this.tagFontSize,
    required this.phoneSize,
    required this.bodySize,
    required this.actionFontSize,
    required this.actionHeight,
    required this.actionIconSize,
    required this.addBtnHeight,
    required this.addBtnFontSize,
    required this.emptyIllustration,
    required this.emptyTitleSize,
    required this.emptySubSize,
    required this.gapXs,
    required this.gapSm,
    required this.gapMd,
    required this.gapLg,
  });

  static AddressMetrics of(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final isTablet = size.shortestSide >= 540;
    final isLandscape = size.width > size.height;
    if (!isTablet) return AddressMetrics.phone();
    return isLandscape
        ? AddressMetrics.tabletLandscape(size)
        : AddressMetrics.tabletPortrait(size);
  }

  factory AddressMetrics.phone() => AddressMetrics(
    isTablet: false,
    isLandscape: false,
    pageHPad: 4.w,
    pageVPad: 1.2.h,
    maxContentWidth: double.infinity,
    backIconSize: 20.sp,
    titleSize: 19.sp,
    subtitleSize: 12.sp,
    cardRadius: 16,
    cardPad: 4.w,
    radioSize: 5.5.w,
    nameSize: 15.sp,
    tagFontSize: 10.sp,
    phoneSize: 13.sp,
    bodySize: 13.sp,
    actionFontSize: 12.sp,
    actionHeight: 4.4.h,
    actionIconSize: 14.sp,
    addBtnHeight: 6.2.h,
    addBtnFontSize: 14.sp,
    emptyIllustration: 34.w,
    emptyTitleSize: 17.sp,
    emptySubSize: 13.sp,
    gapXs: 0.5.h,
    gapSm: 1.h,
    gapMd: 1.8.h,
    gapLg: 2.6.h,
  );

  factory AddressMetrics.tabletPortrait(Size size) => AddressMetrics(
    isTablet: true,
    isLandscape: false,
    pageHPad: (size.width * 0.06).clamp(24.0, 60.0),
    pageVPad: 12,
    maxContentWidth: 760,
    backIconSize: 22,
    titleSize: 26,
    subtitleSize: 15,
    cardRadius: 18,
    cardPad: 20,
    radioSize: 24,
    nameSize: 19,
    tagFontSize: 12,
    phoneSize: 16,
    bodySize: 16,
    actionFontSize: 15,
    actionHeight: 42,
    actionIconSize: 18,
    addBtnHeight: 56,
    addBtnFontSize: 17,
    emptyIllustration: 180,
    emptyTitleSize: 22,
    emptySubSize: 16,
    gapXs: 4,
    gapSm: 10,
    gapMd: 18,
    gapLg: 26,
  );

  factory AddressMetrics.tabletLandscape(Size size) => AddressMetrics(
    isTablet: true,
    isLandscape: true,
    pageHPad: (size.width * 0.04).clamp(20.0, 52.0),
    pageVPad: 10,
    maxContentWidth: 1100,
    backIconSize: 20,
    titleSize: 24,
    subtitleSize: 14,
    cardRadius: 18,
    cardPad: 16,
    radioSize: 22,
    nameSize: 18,
    tagFontSize: 11,
    phoneSize: 15,
    bodySize: 15,
    actionFontSize: 14,
    actionHeight: 38,
    actionIconSize: 17,
    addBtnHeight: 52,
    addBtnFontSize: 16,
    emptyIllustration: 150,
    emptyTitleSize: 20,
    emptySubSize: 15,
    gapXs: 3,
    gapSm: 8,
    gapMd: 14,
    gapLg: 22,
  );
}