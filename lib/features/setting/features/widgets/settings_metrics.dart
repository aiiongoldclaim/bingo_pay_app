import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

class SettingsMetrics {
  final bool isTablet;
  final bool isLandscape;

  final double pageHPad;
  final double pageVPad;
  final double maxContentWidth;

  final double backIconSize;
  final double titleSize;
  final double subtitleSize;
  final double topIconSize;

  final double sectionHeadingSize;
  final double sectionGap;

  final double cardRadius;
  final double tileVPad;
  final double tileHPad;
  final double iconBox;
  final double iconSize;
  final double tileTitleSize;
  final double tileSubSize;
  final double chevronSize;

  // Notifications
  final double notifIconBox;
  final double notifIconSize;
  final double notifTitleSize;
  final double notifBodySize;
  final double notifTimeSize;
  final double dotSize;
  final double chipHeight;
  final double chipFontSize;

  final double emptyIllustration;
  final double emptyTitleSize;
  final double emptySubSize;

  final double btnHeight;
  final double btnFontSize;

  final double gapXs;
  final double gapSm;
  final double gapMd;
  final double gapLg;

  const SettingsMetrics({
    required this.isTablet,
    required this.isLandscape,
    required this.pageHPad,
    required this.pageVPad,
    required this.maxContentWidth,
    required this.backIconSize,
    required this.titleSize,
    required this.subtitleSize,
    required this.topIconSize,
    required this.sectionHeadingSize,
    required this.sectionGap,
    required this.cardRadius,
    required this.tileVPad,
    required this.tileHPad,
    required this.iconBox,
    required this.iconSize,
    required this.tileTitleSize,
    required this.tileSubSize,
    required this.chevronSize,
    required this.notifIconBox,
    required this.notifIconSize,
    required this.notifTitleSize,
    required this.notifBodySize,
    required this.notifTimeSize,
    required this.dotSize,
    required this.chipHeight,
    required this.chipFontSize,
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

  static SettingsMetrics of(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final isTablet = size.shortestSide >= 540;
    final isLandscape = size.width > size.height;
    if (!isTablet) return SettingsMetrics.phone();
    return isLandscape
        ? SettingsMetrics.tabletLandscape(size)
        : SettingsMetrics.tabletPortrait(size);
  }

  factory SettingsMetrics.phone() => SettingsMetrics(
    isTablet: false,
    isLandscape: false,
    pageHPad: 4.w,
    pageVPad: 1.2.h,
    maxContentWidth: double.infinity,
    backIconSize: 20.sp,
    titleSize: 20.sp,
    subtitleSize: 12.sp,
    topIconSize: 20.sp,
    sectionHeadingSize: 15.sp,
    sectionGap: 1.4.h,
    cardRadius: 16,
    tileVPad: 1.8.h,
    tileHPad: 4.w,
    iconBox: 12.w,
    iconSize: 20.sp,
    tileTitleSize: 14.sp,
    tileSubSize: 12.sp,
    chevronSize: 16.sp,
    notifIconBox: 12.w,
    notifIconSize: 20.sp,
    notifTitleSize: 14.sp,
    notifBodySize: 12.sp,
    notifTimeSize: 11.sp,
    dotSize: 2.w,
    chipHeight: 4.2.h,
    chipFontSize: 12.sp,
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

  factory SettingsMetrics.tabletPortrait(Size size) => SettingsMetrics(
    isTablet: true,
    isLandscape: false,
    pageHPad: (size.width * 0.06).clamp(24.0, 60.0),
    pageVPad: 12,
    maxContentWidth: 760,
    backIconSize: 22,
    titleSize: 27,
    subtitleSize: 15,
    topIconSize: 24,
    sectionHeadingSize: 19,
    sectionGap: 14,
    cardRadius: 18,
    tileVPad: 18,
    tileHPad: 20,
    iconBox: 54,
    iconSize: 25,
    tileTitleSize: 18,
    tileSubSize: 15,
    chevronSize: 20,
    notifIconBox: 54,
    notifIconSize: 25,
    notifTitleSize: 18,
    notifBodySize: 15,
    notifTimeSize: 13,
    dotSize: 9,
    chipHeight: 40,
    chipFontSize: 15,
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

  factory SettingsMetrics.tabletLandscape(Size size) => SettingsMetrics(
    isTablet: true,
    isLandscape: true,
    pageHPad: (size.width * 0.04).clamp(20.0, 52.0),
    pageVPad: 10,
    maxContentWidth: 1100,
    backIconSize: 20,
    titleSize: 25,
    subtitleSize: 14,
    topIconSize: 22,
    sectionHeadingSize: 18,
    sectionGap: 12,
    cardRadius: 18,
    tileVPad: 15,
    tileHPad: 18,
    iconBox: 48,
    iconSize: 23,
    tileTitleSize: 17,
    tileSubSize: 14,
    chevronSize: 19,
    notifIconBox: 48,
    notifIconSize: 23,
    notifTitleSize: 17,
    notifBodySize: 14,
    notifTimeSize: 12,
    dotSize: 8,
    chipHeight: 36,
    chipFontSize: 14,
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