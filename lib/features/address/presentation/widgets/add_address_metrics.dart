import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

class AddAddressMetrics {
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
  final double sectionTitleSize;
  final double sectionIconBox;
  final double sectionIconSize;

  final double fieldRadius;
  final double fieldLabelSize;
  final double fieldTextSize;
  final double fieldIconSize;
  final double fieldVPad;
  final double errorSize;

  final double switchTitleSize;
  final double switchSubSize;

  final double btnHeight;
  final double btnFontSize;

  final double gapXs;
  final double gapSm;
  final double gapMd;
  final double gapLg;

  const AddAddressMetrics({
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
    required this.sectionTitleSize,
    required this.sectionIconBox,
    required this.sectionIconSize,
    required this.fieldRadius,
    required this.fieldLabelSize,
    required this.fieldTextSize,
    required this.fieldIconSize,
    required this.fieldVPad,
    required this.errorSize,
    required this.switchTitleSize,
    required this.switchSubSize,
    required this.btnHeight,
    required this.btnFontSize,
    required this.gapXs,
    required this.gapSm,
    required this.gapMd,
    required this.gapLg,
  });

  static AddAddressMetrics of(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final isTablet = size.shortestSide >= 540;
    final isLandscape = size.width > size.height;
    if (!isTablet) return AddAddressMetrics.phone();
    return isLandscape
        ? AddAddressMetrics.tabletLandscape(size)
        : AddAddressMetrics.tabletPortrait(size);
  }

  factory AddAddressMetrics.phone() => AddAddressMetrics(
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
    sectionTitleSize: 15.sp,
    sectionIconBox: 11.w,
    sectionIconSize: 19.sp,
    fieldRadius: 12,
    fieldLabelSize: 12.sp,
    fieldTextSize: 14.sp,
    fieldIconSize: 18.sp,
    fieldVPad: 1.9.h,
    errorSize: 11.sp,
    switchTitleSize: 13.sp,
    switchSubSize: 11.sp,
    btnHeight: 6.4.h,
    btnFontSize: 14.sp,
    gapXs: 0.5.h,
    gapSm: 1.h,
    gapMd: 1.8.h,
    gapLg: 2.6.h,
  );

  factory AddAddressMetrics.tabletPortrait(Size size) => AddAddressMetrics(
    isTablet: true,
    isLandscape: false,
    pageHPad: (size.width * 0.06).clamp(24.0, 60.0),
    pageVPad: 12,
    maxContentWidth: 720,
    backIconSize: 22,
    titleSize: 26,
    subtitleSize: 15,
    cardRadius: 18,
    cardPad: 22,
    sectionTitleSize: 19,
    sectionIconBox: 52,
    sectionIconSize: 25,
    fieldRadius: 12,
    fieldLabelSize: 15,
    fieldTextSize: 17,
    fieldIconSize: 22,
    fieldVPad: 18,
    errorSize: 13,
    switchTitleSize: 17,
    switchSubSize: 14,
    btnHeight: 56,
    btnFontSize: 17,
    gapXs: 4,
    gapSm: 10,
    gapMd: 18,
    gapLg: 26,
  );

  factory AddAddressMetrics.tabletLandscape(Size size) => AddAddressMetrics(
    isTablet: true,
    isLandscape: true,
    pageHPad: (size.width * 0.04).clamp(20.0, 52.0),
    pageVPad: 10,
    maxContentWidth: 1000,
    backIconSize: 20,
    titleSize: 24,
    subtitleSize: 14,
    cardRadius: 18,
    cardPad: 18,
    sectionTitleSize: 18,
    sectionIconBox: 46,
    sectionIconSize: 23,
    fieldRadius: 12,
    fieldLabelSize: 14,
    fieldTextSize: 16,
    fieldIconSize: 20,
    fieldVPad: 15,
    errorSize: 12,
    switchTitleSize: 16,
    switchSubSize: 13,
    btnHeight: 52,
    btnFontSize: 16,
    gapXs: 3,
    gapSm: 8,
    gapMd: 14,
    gapLg: 22,
  );
}