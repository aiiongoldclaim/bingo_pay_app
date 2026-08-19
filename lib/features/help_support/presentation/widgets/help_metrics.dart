import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

class HelpMetrics {
  final bool isTablet;
  final bool isLandscape;

  // Page
  final double pageHPad;
  final double pageVPad;
  final double maxContentWidth;

  // Top bar
  final double backIconSize;
  final double titleSize;
  final double topIconSize;

  // Hero
  final double heroRadius;
  final double heroPad;
  final double heroTitleSize;
  final double heroBodySize;
  final double heroBtnHeight;
  final double heroBtnFontSize;
  final double heroArtSize;

  // Section heading
  final double sectionTitleSize;
  final double linkSize;

  // Support tiles
  final double tileRadius;
  final double tilePad;
  final double tileIconBox;
  final double tileIconSize;
  final double tileTitleSize;
  final double tileSubSize;
  final double tileGap;

  // FAQ
  final double faqRadius;
  final double faqHPad;
  final double faqVPad;
  final double faqQuestionSize;
  final double faqAnswerSize;
  final double faqIconSize;

  // Footer
  final double footerRadius;
  final double footerPad;
  final double footerIconBox;
  final double footerIconSize;
  final double footerTitleSize;
  final double footerBodySize;

  final double gapXs;
  final double gapSm;
  final double gapMd;
  final double gapLg;

  const HelpMetrics({
    required this.isTablet,
    required this.isLandscape,
    required this.pageHPad,
    required this.pageVPad,
    required this.maxContentWidth,
    required this.backIconSize,
    required this.titleSize,
    required this.topIconSize,
    required this.heroRadius,
    required this.heroPad,
    required this.heroTitleSize,
    required this.heroBodySize,
    required this.heroBtnHeight,
    required this.heroBtnFontSize,
    required this.heroArtSize,
    required this.sectionTitleSize,
    required this.linkSize,
    required this.tileRadius,
    required this.tilePad,
    required this.tileIconBox,
    required this.tileIconSize,
    required this.tileTitleSize,
    required this.tileSubSize,
    required this.tileGap,
    required this.faqRadius,
    required this.faqHPad,
    required this.faqVPad,
    required this.faqQuestionSize,
    required this.faqAnswerSize,
    required this.faqIconSize,
    required this.footerRadius,
    required this.footerPad,
    required this.footerIconBox,
    required this.footerIconSize,
    required this.footerTitleSize,
    required this.footerBodySize,
    required this.gapXs,
    required this.gapSm,
    required this.gapMd,
    required this.gapLg,
  });

  static HelpMetrics of(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final isTablet = size.shortestSide >= 540;
    final isLandscape = size.width > size.height;
    if (!isTablet) return HelpMetrics.phone();
    return isLandscape
        ? HelpMetrics.tabletLandscape(size)
        : HelpMetrics.tabletPortrait(size);
  }

  // ── PHONE ───────────────────────────────────────────────────────────────
  factory HelpMetrics.phone() => HelpMetrics(
    isTablet: false,
    isLandscape: false,
    pageHPad: 4.w,
    pageVPad: 1.2.h,
    maxContentWidth: double.infinity,
    backIconSize: 20.sp,
    titleSize: 20.sp,
    topIconSize: 21.sp,
    heroRadius: 18,
    heroPad: 5.w,
    heroTitleSize: 19.sp,
    heroBodySize: 13.sp,
    heroBtnHeight: 5.4.h,
    heroBtnFontSize: 14.sp,
    heroArtSize: 34.w,
    sectionTitleSize: 16.sp,
    linkSize: 13.sp,
    tileRadius: 14,
    tilePad: 3.w,
    tileIconBox: 13.w,
    tileIconSize: 20.sp,
    tileTitleSize: 13.sp,
    tileSubSize: 11.sp,
    tileGap: 2.5.w,
    faqRadius: 14,
    faqHPad: 4.w,
    faqVPad: 0.6.h,
    faqQuestionSize: 13.sp,
    faqAnswerSize: 12.sp,
    faqIconSize: 20.sp,
    footerRadius: 16,
    footerPad: 4.w,
    footerIconBox: 13.w,
    footerIconSize: 22.sp,
    footerTitleSize: 14.sp,
    footerBodySize: 12.sp,
    gapXs: 0.5.h,
    gapSm: 1.h,
    gapMd: 1.8.h,
    gapLg: 2.8.h,
  );

  // ── TABLET PORTRAIT ─────────────────────────────────────────────────────
  factory HelpMetrics.tabletPortrait(Size size) => HelpMetrics(
    isTablet: true,
    isLandscape: false,
    pageHPad: (size.width * 0.06).clamp(24.0, 60.0),
    pageVPad: 12,
    maxContentWidth: 780,
    backIconSize: 22,
    titleSize: 26,
    topIconSize: 25,
    heroRadius: 22,
    heroPad: 28,
    heroTitleSize: 28,
    heroBodySize: 16,
    heroBtnHeight: 50,
    heroBtnFontSize: 17,
    heroArtSize: 200,
    sectionTitleSize: 21,
    linkSize: 16,
    tileRadius: 16,
    tilePad: 18,
    tileIconBox: 62,
    tileIconSize: 28,
    tileTitleSize: 17,
    tileSubSize: 14,
    tileGap: 14,
    faqRadius: 16,
    faqHPad: 20,
    faqVPad: 6,
    faqQuestionSize: 17,
    faqAnswerSize: 15,
    faqIconSize: 26,
    footerRadius: 20,
    footerPad: 22,
    footerIconBox: 62,
    footerIconSize: 30,
    footerTitleSize: 18,
    footerBodySize: 15,
    gapXs: 4,
    gapSm: 10,
    gapMd: 18,
    gapLg: 28,
  );

  // ── TABLET LANDSCAPE ────────────────────────────────────────────────────
  factory HelpMetrics.tabletLandscape(Size size) => HelpMetrics(
    isTablet: true,
    isLandscape: true,
    pageHPad: (size.width * 0.04).clamp(20.0, 52.0),
    pageVPad: 10,
    maxContentWidth: 1240,
    backIconSize: 20,
    titleSize: 24,
    topIconSize: 23,
    heroRadius: 22,
    heroPad: 22,
    heroTitleSize: 25,
    heroBodySize: 15,
    heroBtnHeight: 46,
    heroBtnFontSize: 16,
    heroArtSize: 170,
    sectionTitleSize: 20,
    linkSize: 15,
    tileRadius: 16,
    tilePad: 16,
    tileIconBox: 56,
    tileIconSize: 26,
    tileTitleSize: 16,
    tileSubSize: 13,
    tileGap: 12,
    faqRadius: 16,
    faqHPad: 18,
    faqVPad: 4,
    faqQuestionSize: 16,
    faqAnswerSize: 14,
    faqIconSize: 24,
    footerRadius: 20,
    footerPad: 18,
    footerIconBox: 56,
    footerIconSize: 28,
    footerTitleSize: 17,
    footerBodySize: 14,
    gapXs: 3,
    gapSm: 8,
    gapMd: 14,
    gapLg: 22,
  );
}