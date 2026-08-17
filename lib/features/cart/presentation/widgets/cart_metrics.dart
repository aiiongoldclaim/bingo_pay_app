import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

/// Phone  -> Sizer units
/// Tablet -> fixed dp with clamp() (no Sizer oversizing)
class CartMetrics {
  final bool isTablet;
  final bool isLandscape;

  // Page
  final double pageHPad;
  final double pageVPad;
  final double maxContentWidth;
  final double railWidth;

  // Top bar
  final double backIconSize;
  final double logoSize;
  final double topIconSize;

  // Title block
  final double pageTitleSize;
  final double pageSubtitleSize;
  final double linkSize;

  // Banner
  final double bannerRadius;
  final double bannerPad;
  final double bannerIconBox;
  final double bannerIconSize;
  final double bannerTitleSize;
  final double bannerSubSize;
  final double progressHeight;

  // Item card
  final double cardRadius;
  final double cardPad;
  final double checkboxSize;
  final double thumbSize;
  final double thumbRadius;
  final double brandSize;
  final double titleSize;
  final double metaSize;
  final double priceSize;
  final double actionHeight;
  final double actionFontSize;
  final double actionIconSize;
  final double qtyBoxHeight;
  final double qtyBoxWidth;
  final double qtyIconSize;
  final double qtyFontSize;

  // Summary
  final double summaryTitleSize;
  final double summaryLabelSize;
  final double summaryValueSize;
  final double totalLabelSize;
  final double totalValueSize;

  // Pay bar
  final double payHeight;
  final double payFontSize;
  final double payNoteSize;

  // Empty state
  final double emptyIllustration;
  final double emptyTitleSize;
  final double emptySubSize;

  // Spacing
  final double gapXs;
  final double gapSm;
  final double gapMd;
  final double gapLg;

  const CartMetrics({
    required this.isTablet,
    required this.isLandscape,
    required this.pageHPad,
    required this.pageVPad,
    required this.maxContentWidth,
    required this.railWidth,
    required this.backIconSize,
    required this.logoSize,
    required this.topIconSize,
    required this.pageTitleSize,
    required this.pageSubtitleSize,
    required this.linkSize,
    required this.bannerRadius,
    required this.bannerPad,
    required this.bannerIconBox,
    required this.bannerIconSize,
    required this.bannerTitleSize,
    required this.bannerSubSize,
    required this.progressHeight,
    required this.cardRadius,
    required this.cardPad,
    required this.checkboxSize,
    required this.thumbSize,
    required this.thumbRadius,
    required this.brandSize,
    required this.titleSize,
    required this.metaSize,
    required this.priceSize,
    required this.actionHeight,
    required this.actionFontSize,
    required this.actionIconSize,
    required this.qtyBoxHeight,
    required this.qtyBoxWidth,
    required this.qtyIconSize,
    required this.qtyFontSize,
    required this.summaryTitleSize,
    required this.summaryLabelSize,
    required this.summaryValueSize,
    required this.totalLabelSize,
    required this.totalValueSize,
    required this.payHeight,
    required this.payFontSize,
    required this.payNoteSize,
    required this.emptyIllustration,
    required this.emptyTitleSize,
    required this.emptySubSize,
    required this.gapXs,
    required this.gapSm,
    required this.gapMd,
    required this.gapLg,
  });

  static CartMetrics of(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final isTablet = size.shortestSide >= 540;
    final isLandscape = size.width > size.height;
    if (!isTablet) return CartMetrics.phone();
    return isLandscape
        ? CartMetrics.tabletLandscape(size)
        : CartMetrics.tabletPortrait(size);
  }

  // ── PHONE ───────────────────────────────────────────────────────────────
  factory CartMetrics.phone() => CartMetrics(
    isTablet: false,
    isLandscape: false,
    pageHPad: 4.w,
    pageVPad: 1.2.h,
    maxContentWidth: double.infinity,
    railWidth: 0,
    backIconSize: 20.sp,
    logoSize: 24.sp,
    topIconSize: 20.sp,
    pageTitleSize: 19.sp,
    pageSubtitleSize: 13.sp,
    linkSize: 13.sp,
    bannerRadius: 14,
    bannerPad: 3.5.w,
    bannerIconBox: 11.w,
    bannerIconSize: 21.sp,
    bannerTitleSize: 14.sp,
    bannerSubSize: 12.sp,
    progressHeight: 5,
    cardRadius: 16,
    cardPad: 3.5.w,
    checkboxSize: 5.5.w,
    thumbSize: 22.w,
    thumbRadius: 12,
    brandSize: 14.sp,
    titleSize: 13.sp,
    metaSize: 12.sp,
    priceSize: 16.sp,
    actionHeight: 4.4.h,
    actionFontSize: 12.sp,
    actionIconSize: 14.sp,
    qtyBoxHeight: 4.4.h,
    qtyBoxWidth: 29.w,
    qtyIconSize: 16.sp,
    qtyFontSize: 14.sp,
    summaryTitleSize: 16.sp,
    summaryLabelSize: 13.sp,
    summaryValueSize: 13.sp,
    totalLabelSize: 15.sp,
    totalValueSize: 18.sp,
    payHeight: 6.6.h,
    payFontSize: 14.sp,
    payNoteSize: 11.sp,
    emptyIllustration: 34.w,
    emptyTitleSize: 17.sp,
    emptySubSize: 13.sp,
    gapXs: 0.5.h,
    gapSm: 1.h,
    gapMd: 1.8.h,
    gapLg: 2.6.h,
  );

  // ── TABLET PORTRAIT ─────────────────────────────────────────────────────
  factory CartMetrics.tabletPortrait(Size size) => CartMetrics(
    isTablet: true,
    isLandscape: false,
    pageHPad: (size.width * 0.06).clamp(24.0, 60.0),
    pageVPad: 12,
    maxContentWidth: 760,
    railWidth: 0,
    backIconSize: 22,
    logoSize: 30,
    topIconSize: 24,
    pageTitleSize: 27,
    pageSubtitleSize: 16,
    linkSize: 16,
    bannerRadius: 16,
    bannerPad: 18,
    bannerIconBox: 52,
    bannerIconSize: 27,
    bannerTitleSize: 18,
    bannerSubSize: 15,
    progressHeight: 6,
    cardRadius: 18,
    cardPad: 18,
    checkboxSize: 24,
    thumbSize: 110,
    thumbRadius: 14,
    brandSize: 18,
    titleSize: 16,
    metaSize: 15,
    priceSize: 21,
    actionHeight: 40,
    actionFontSize: 15,
    actionIconSize: 17,
    qtyBoxHeight: 42,
    qtyBoxWidth: 134,
    qtyIconSize: 21,
    qtyFontSize: 17,
    summaryTitleSize: 20,
    summaryLabelSize: 16,
    summaryValueSize: 16,
    totalLabelSize: 19,
    totalValueSize: 25,
    payHeight: 58,
    payFontSize: 18,
    payNoteSize: 13,
    emptyIllustration: 180,
    emptyTitleSize: 22,
    emptySubSize: 16,
    gapXs: 4,
    gapSm: 10,
    gapMd: 16,
    gapLg: 24,
  );

  // ── TABLET LANDSCAPE ────────────────────────────────────────────────────
  factory CartMetrics.tabletLandscape(Size size) => CartMetrics(
    isTablet: true,
    isLandscape: true,
    pageHPad: (size.width * 0.035).clamp(20.0, 48.0),
    pageVPad: 10,
    maxContentWidth: 1240,
    railWidth: (size.width * 0.33).clamp(300.0, 400.0),
    backIconSize: 20,
    logoSize: 28,
    topIconSize: 22,
    pageTitleSize: 24,
    pageSubtitleSize: 15,
    linkSize: 15,
    bannerRadius: 16,
    bannerPad: 14,
    bannerIconBox: 46,
    bannerIconSize: 25,
    bannerTitleSize: 17,
    bannerSubSize: 14,
    progressHeight: 6,
    cardRadius: 18,
    cardPad: 14,
    checkboxSize: 22,
    thumbSize: 96,
    thumbRadius: 14,
    brandSize: 17,
    titleSize: 15,
    metaSize: 14,
    priceSize: 20,
    actionHeight: 36,
    actionFontSize: 14,
    actionIconSize: 16,
    qtyBoxHeight: 38,
    qtyBoxWidth: 122,
    qtyIconSize: 19,
    qtyFontSize: 16,
    summaryTitleSize: 19,
    summaryLabelSize: 15,
    summaryValueSize: 15,
    totalLabelSize: 18,
    totalValueSize: 23,
    payHeight: 54,
    payFontSize: 17,
    payNoteSize: 12,
    emptyIllustration: 150,
    emptyTitleSize: 20,
    emptySubSize: 15,
    gapXs: 3,
    gapSm: 8,
    gapMd: 14,
    gapLg: 20,
  );
}
