import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

class ProductMetrics {
  final bool isTablet;
  final bool isLandscape;

  // Page
  final double pageHPad;
  final double pageVPad;
  final double maxContentWidth;
  final double galleryWidth;

  // Top bar
  final double backIconSize;
  final double logoSize;
  final double topIconSize;
  final double badgeSize;
  final double badgeFontSize;

  // Gallery
  final double heroRadius;
  final double heroHeight;
  final double thumbSize;
  final double thumbRadius;
  final double thumbGap;
  final double pillHeight;
  final double pillFontSize;
  final double floatBtnSize;

  // Info
  final double brandSize;
  final double titleSize;
  final double ratingChipHeight;
  final double ratingFontSize;
  final double priceSize;
  final double strikeSize;
  final double discountSize;
  final double captionSize;

  // Cards
  final double cardRadius;
  final double cardPad;
  final double sectionTitleSize;
  final double linkSize;
  final double rowIconBox;
  final double rowIconSize;
  final double rowTitleSize;
  final double rowSubSize;

  final double railHeight;

  // Size chips
  final double sizeChipHeight;
  final double sizeChipMinWidth;
  final double sizeChipFontSize;
  final double sizeChipSubSize;

  // Policies
  final double policyIconBox;
  final double policyIconSize;
  final double policyTitleSize;
  final double policySubSize;

  final double gapXs;
  final double gapSm;
  final double gapMd;
  final double gapLg;

  const ProductMetrics({
    required this.isTablet,
    required this.isLandscape,
    required this.pageHPad,
    required this.pageVPad,
    required this.maxContentWidth,
    required this.galleryWidth,
    required this.backIconSize,
    required this.logoSize,
    required this.topIconSize,
    required this.badgeSize,
    required this.badgeFontSize,
    required this.heroRadius,
    required this.heroHeight,
    required this.thumbSize,
    required this.thumbRadius,
    required this.thumbGap,
    required this.pillHeight,
    required this.pillFontSize,
    required this.floatBtnSize,
    required this.brandSize,
    required this.titleSize,
    required this.ratingChipHeight,
    required this.ratingFontSize,
    required this.priceSize,
    required this.strikeSize,
    required this.discountSize,
    required this.captionSize,
    required this.cardRadius,
    required this.cardPad,
    required this.sectionTitleSize,
    required this.linkSize,
    required this.rowIconBox,
    required this.rowIconSize,
    required this.rowTitleSize,
    required this.rowSubSize,
    required this.sizeChipHeight,
    required this.sizeChipMinWidth,
    required this.sizeChipFontSize,
    required this.sizeChipSubSize,
    required this.policyIconBox,
    required this.policyIconSize,
    required this.policyTitleSize,
    required this.policySubSize,
    required this.gapXs,
    required this.gapSm,
    required this.gapMd,
    required this.gapLg,

    required this.railHeight,
  });

  static ProductMetrics of(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final isTablet = size.shortestSide >= 540;
    final isLandscape = size.width > size.height;
    if (!isTablet) return ProductMetrics.phone();
    return isLandscape
        ? ProductMetrics.tabletLandscape(size)
        : ProductMetrics.tabletPortrait(size);
  }

  // ── PHONE ───────────────────────────────────────────────────────────────
  factory ProductMetrics.phone() => ProductMetrics(
    isTablet: false,
    isLandscape: false,
    pageHPad: 4.w,
    pageVPad: 1.2.h,
    maxContentWidth: double.infinity,
    galleryWidth: 0,
    backIconSize: 20.sp,
    logoSize: 24.sp,
    topIconSize: 21.sp,
    badgeSize: 4.4.w,
    badgeFontSize: 8.sp,
    heroRadius: 16,
    heroHeight: 38.h,
    thumbSize: 20.w,
    thumbRadius: 12,
    thumbGap: 2.5.h,
    railHeight: 22.w,
    pillHeight: 5.2.h,
    pillFontSize: 13.sp,
    floatBtnSize: 11.w,
    brandSize: 14.sp,
    titleSize: 16.sp,
    ratingChipHeight: 4.2.h,
    ratingFontSize: 12.sp,
    priceSize: 22.sp,
    strikeSize: 14.sp,
    discountSize: 14.sp,
    captionSize: 12.sp,
    cardRadius: 14,
    cardPad: 4.w,
    sectionTitleSize: 15.sp,
    linkSize: 13.sp,
    rowIconBox: 11.w,
    rowIconSize: 18.sp,
    rowTitleSize: 13.sp,
    rowSubSize: 12.sp,
    sizeChipHeight: 8.h,
    sizeChipMinWidth: 19.w,
    sizeChipFontSize: 14.sp,
    sizeChipSubSize: 11.sp,
    policyIconBox: 10.w,
    policyIconSize: 18.sp,
    policyTitleSize: 12.sp,
    policySubSize: 10.sp,
    gapXs: 0.5.h,
    gapSm: 1.h,
    gapMd: 1.8.h,
    gapLg: 2.6.h,
  );

  // ── TABLET PORTRAIT ─────────────────────────────────────────────────────
  factory ProductMetrics.tabletPortrait(Size size) => ProductMetrics(
    isTablet: true,
    isLandscape: false,
    pageHPad: (size.width * 0.05).clamp(24.0, 56.0),
    pageVPad: 12,
    maxContentWidth: 840,
    galleryWidth: 0,
    backIconSize: 22,
    logoSize: 30,
    topIconSize: 25,
    badgeSize: 18,
    badgeFontSize: 10,
    heroRadius: 20,
    heroHeight: 340,
    thumbSize: 100,
    thumbRadius: 14,
    thumbGap: 12,
    railHeight: 108,
    pillHeight: 46,
    pillFontSize: 16,
    floatBtnSize: 52,
    brandSize: 18,
    titleSize: 21,
    ratingChipHeight: 40,
    ratingFontSize: 15,
    priceSize: 30,
    strikeSize: 17,
    discountSize: 17,
    captionSize: 14,
    cardRadius: 16,
    cardPad: 20,
    sectionTitleSize: 19,
    linkSize: 16,
    rowIconBox: 52,
    rowIconSize: 24,
    rowTitleSize: 17,
    rowSubSize: 15,
    sizeChipHeight: 72,
    sizeChipMinWidth: 88,
    sizeChipFontSize: 18,
    sizeChipSubSize: 14,
    policyIconBox: 48,
    policyIconSize: 24,
    policyTitleSize: 15,
    policySubSize: 13,
    gapXs: 4,
    gapSm: 10,
    gapMd: 18,
    gapLg: 26,
  );

  // ── TABLET LANDSCAPE ────────────────────────────────────────────────────
  factory ProductMetrics.tabletLandscape(Size size) => ProductMetrics(
    isTablet: true,
    isLandscape: true,
    pageHPad: (size.width * 0.035).clamp(20.0, 48.0),
    pageVPad: 10,
    maxContentWidth: 1280,
    galleryWidth: (size.width * 0.42).clamp(340.0, 560.0),
    backIconSize: 20,
    logoSize: 28,
    topIconSize: 23,
    badgeSize: 17,
    badgeFontSize: 10,
    heroRadius: 20,
    heroHeight: 300,
    thumbSize: 84,
    thumbRadius: 14,
    thumbGap: 10,
    railHeight: 92,
    pillHeight: 42,
    pillFontSize: 15,
    floatBtnSize: 46,
    brandSize: 17,
    titleSize: 20,
    ratingChipHeight: 38,
    ratingFontSize: 14,
    priceSize: 28,
    strikeSize: 16,
    discountSize: 16,
    captionSize: 13,
    cardRadius: 16,
    cardPad: 16,
    sectionTitleSize: 18,
    linkSize: 15,
    rowIconBox: 46,
    rowIconSize: 22,
    rowTitleSize: 16,
    rowSubSize: 14,
    sizeChipHeight: 64,
    sizeChipMinWidth: 78,
    sizeChipFontSize: 17,
    sizeChipSubSize: 13,
    policyIconBox: 44,
    policyIconSize: 22,
    policyTitleSize: 14,
    policySubSize: 12,
    gapXs: 3,
    gapSm: 8,
    gapMd: 14,
    gapLg: 22,
  );
}