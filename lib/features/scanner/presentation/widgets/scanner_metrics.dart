import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

class ScannerMetrics {
  final bool isTablet;
  final bool isLandscape;

  // Page
  final double pageHPad;
  final double pageVPad;
  final double maxContentWidth;

  // Top bar
  final double backIconSize;
  final double titleSize;
  final double chipHeight;
  final double chipHPad;
  final double chipFontSize;

  // Banner
  final double bannerRadius;
  final double bannerPad;
  final double bannerIconBox;
  final double bannerIconSize;
  final double bannerTitleSize;
  final double bannerSubSize;

  // Camera area
  final double cameraRadius;
  final double cameraHeight;
  final double frameSize;
  final double frameCorner;
  final double frameStroke;
  final double hintFontSize;
  final double overlayBtnSize;
  final double overlayIconSize;
  final double pillHeight;
  final double pillFontSize;

  // Help card
  final double helpRadius;
  final double helpPad;
  final double helpIconBox;
  final double helpIconSize;
  final double helpTitleSize;
  final double helpBodySize;

  // Action bar
  final double actionBtnSize;
  final double actionIconSize;
  final double actionLabelSize;
  final double scanBtnSize;
  final double scanIconSize;

  final double gapXs;
  final double gapSm;
  final double gapMd;
  final double gapLg;

  const ScannerMetrics({
    required this.isTablet,
    required this.isLandscape,
    required this.pageHPad,
    required this.pageVPad,
    required this.maxContentWidth,
    required this.backIconSize,
    required this.titleSize,
    required this.chipHeight,
    required this.chipHPad,
    required this.chipFontSize,
    required this.bannerRadius,
    required this.bannerPad,
    required this.bannerIconBox,
    required this.bannerIconSize,
    required this.bannerTitleSize,
    required this.bannerSubSize,
    required this.cameraRadius,
    required this.cameraHeight,
    required this.frameSize,
    required this.frameCorner,
    required this.frameStroke,
    required this.hintFontSize,
    required this.overlayBtnSize,
    required this.overlayIconSize,
    required this.pillHeight,
    required this.pillFontSize,
    required this.helpRadius,
    required this.helpPad,
    required this.helpIconBox,
    required this.helpIconSize,
    required this.helpTitleSize,
    required this.helpBodySize,
    required this.actionBtnSize,
    required this.actionIconSize,
    required this.actionLabelSize,
    required this.scanBtnSize,
    required this.scanIconSize,
    required this.gapXs,
    required this.gapSm,
    required this.gapMd,
    required this.gapLg,
  });

  static ScannerMetrics of(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final isTablet = size.shortestSide >= 540;
    final isLandscape = size.width > size.height;
    if (!isTablet) return ScannerMetrics.phone();
    return isLandscape
        ? ScannerMetrics.tabletLandscape(size)
        : ScannerMetrics.tabletPortrait(size);
  }

  // ── PHONE ───────────────────────────────────────────────────────────────
  factory ScannerMetrics.phone() => ScannerMetrics(
    isTablet: false,
    isLandscape: false,
    pageHPad: 4.w,
    pageVPad: 1.2.h,
    maxContentWidth: double.infinity,
    backIconSize: 20.sp,
    titleSize: 18.sp,
    chipHeight: 4.6.h,
    chipHPad: 4.w,
    chipFontSize: 13.sp,
    bannerRadius: 14,
    bannerPad: 3.5.w,
    bannerIconBox: 12.w,
    bannerIconSize: 20.sp,
    bannerTitleSize: 14.sp,
    bannerSubSize: 12.sp,
    cameraRadius: 20,
    cameraHeight: 46.h,
    frameSize: 62.w,
    frameCorner: 7.w,
    frameStroke: 3,
    hintFontSize: 13.sp,
    overlayBtnSize: 10.w,
    overlayIconSize: 20.sp,
    pillHeight: 5.h,
    pillFontSize: 12.sp,
    helpRadius: 14,
    helpPad: 3.5.w,
    helpIconBox: 12.w,
    helpIconSize: 20.sp,
    helpTitleSize: 14.sp,
    helpBodySize: 12.sp,
    actionBtnSize: 15.w,
    actionIconSize: 22.sp,
    actionLabelSize: 12.sp,
    scanBtnSize: 19.w,
    scanIconSize: 26.sp,
    gapXs: 0.5.h,
    gapSm: 1.h,
    gapMd: 1.8.h,
    gapLg: 2.6.h,
  );

  // ── TABLET PORTRAIT ─────────────────────────────────────────────────────
  factory ScannerMetrics.tabletPortrait(Size size) => ScannerMetrics(
    isTablet: true,
    isLandscape: false,
    pageHPad: (size.width * 0.06).clamp(24.0, 60.0),
    pageVPad: 12,
    maxContentWidth: 720,
    backIconSize: 22,
    titleSize: 24,
    chipHeight: 44,
    chipHPad: 20,
    chipFontSize: 16,
    bannerRadius: 16,
    bannerPad: 18,
    bannerIconBox: 56,
    bannerIconSize: 26,
    bannerTitleSize: 18,
    bannerSubSize: 15,
    cameraRadius: 24,
    cameraHeight: 460,
    frameSize: 340,
    frameCorner: 40,
    frameStroke: 4,
    hintFontSize: 16,
    overlayBtnSize: 48,
    overlayIconSize: 24,
    pillHeight: 46,
    pillFontSize: 15,
    helpRadius: 16,
    helpPad: 18,
    helpIconBox: 56,
    helpIconSize: 26,
    helpTitleSize: 18,
    helpBodySize: 15,
    actionBtnSize: 68,
    actionIconSize: 28,
    actionLabelSize: 14,
    scanBtnSize: 84,
    scanIconSize: 34,
    gapXs: 4,
    gapSm: 10,
    gapMd: 18,
    gapLg: 26,
  );

  // ── TABLET LANDSCAPE ────────────────────────────────────────────────────
  factory ScannerMetrics.tabletLandscape(Size size) => ScannerMetrics(
    isTablet: true,
    isLandscape: true,
    pageHPad: (size.width * 0.035).clamp(20.0, 48.0),
    pageVPad: 10,
    maxContentWidth: 1240,
    backIconSize: 20,
    titleSize: 22,
    chipHeight: 40,
    chipHPad: 18,
    chipFontSize: 15,
    bannerRadius: 16,
    bannerPad: 14,
    bannerIconBox: 48,
    bannerIconSize: 24,
    bannerTitleSize: 17,
    bannerSubSize: 14,
    cameraRadius: 24,
    cameraHeight: 380,
    frameSize: 280,
    frameCorner: 34,
    frameStroke: 4,
    hintFontSize: 15,
    overlayBtnSize: 44,
    overlayIconSize: 22,
    pillHeight: 42,
    pillFontSize: 14,
    helpRadius: 16,
    helpPad: 14,
    helpIconBox: 48,
    helpIconSize: 24,
    helpTitleSize: 17,
    helpBodySize: 14,
    actionBtnSize: 60,
    actionIconSize: 26,
    actionLabelSize: 13,
    scanBtnSize: 74,
    scanIconSize: 30,
    gapXs: 3,
    gapSm: 8,
    gapMd: 14,
    gapLg: 20,
  );
}