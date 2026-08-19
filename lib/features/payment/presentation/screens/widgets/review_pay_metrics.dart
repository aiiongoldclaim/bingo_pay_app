import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

class ReviewPayMetrics {
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
  final double badgeSize;
  final double badgeFontSize;

  // Page title
  final double pageTitleSize;
  final double pageSubtitleSize;

  // Cards
  final double cardRadius;
  final double cardPad;
  final double sectionLabelSize;
  final double sectionTitleSize;

  // Address
  final double addrNameSize;
  final double addrBodySize;
  final double changeBtnHeight;
  final double changeBtnFontSize;

  // Wallet card
  final double walletIconBox;
  final double walletIconSize;
  final double walletTitleSize;
  final double walletSubSize;
  final double balanceLabelSize;
  final double balanceValueSize;
  final double coinBadgeSize;

  // Summary
  final double thumbSize;
  final double itemTitleSize;
  final double itemMetaSize;
  final double rowLabelSize;
  final double rowValueSize;
  final double totalLabelSize;
  final double totalValueSize;

  // Secure strip / offers
  final double stripIconBox;
  final double stripIconSize;
  final double stripTitleSize;
  final double stripSubSize;
  final double offerIconBox;
  final double offerIconSize;
  final double offerTitleSize;
  final double offerSubSize;
  final double linkSize;

  // Coupon / notes
  final double fieldHeight;
  final double fieldRadius;
  final double fieldTextSize;

  // Pay bar
  final double payHeight;
  final double payFontSize;

  final double gapXs;
  final double gapSm;
  final double gapMd;
  final double gapLg;

  const ReviewPayMetrics({
    required this.isTablet,
    required this.isLandscape,
    required this.pageHPad,
    required this.pageVPad,
    required this.maxContentWidth,
    required this.railWidth,
    required this.backIconSize,
    required this.logoSize,
    required this.topIconSize,
    required this.badgeSize,
    required this.badgeFontSize,
    required this.pageTitleSize,
    required this.pageSubtitleSize,
    required this.cardRadius,
    required this.cardPad,
    required this.sectionLabelSize,
    required this.sectionTitleSize,
    required this.addrNameSize,
    required this.addrBodySize,
    required this.changeBtnHeight,
    required this.changeBtnFontSize,
    required this.walletIconBox,
    required this.walletIconSize,
    required this.walletTitleSize,
    required this.walletSubSize,
    required this.balanceLabelSize,
    required this.balanceValueSize,
    required this.coinBadgeSize,
    required this.thumbSize,
    required this.itemTitleSize,
    required this.itemMetaSize,
    required this.rowLabelSize,
    required this.rowValueSize,
    required this.totalLabelSize,
    required this.totalValueSize,
    required this.stripIconBox,
    required this.stripIconSize,
    required this.stripTitleSize,
    required this.stripSubSize,
    required this.offerIconBox,
    required this.offerIconSize,
    required this.offerTitleSize,
    required this.offerSubSize,
    required this.linkSize,
    required this.fieldHeight,
    required this.fieldRadius,
    required this.fieldTextSize,
    required this.payHeight,
    required this.payFontSize,
    required this.gapXs,
    required this.gapSm,
    required this.gapMd,
    required this.gapLg,
  });

  static ReviewPayMetrics of(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final isTablet = size.shortestSide >= 540;
    final isLandscape = size.width > size.height;
    if (!isTablet) return ReviewPayMetrics.phone();
    return isLandscape
        ? ReviewPayMetrics.tabletLandscape(size)
        : ReviewPayMetrics.tabletPortrait(size);
  }

  // ── PHONE ───────────────────────────────────────────────────────────────
  factory ReviewPayMetrics.phone() => ReviewPayMetrics(
    isTablet: false,
    isLandscape: false,
    pageHPad: 4.w,
    pageVPad: 1.2.h,
    maxContentWidth: double.infinity,
    railWidth: 0,
    backIconSize: 20.sp,
    logoSize: 24.sp,
    topIconSize: 20.sp,
    badgeSize: 4.4.w,
    badgeFontSize: 8.sp,
    pageTitleSize: 21.sp,
    pageSubtitleSize: 12.sp,
    cardRadius: 16,
    cardPad: 4.w,
    sectionLabelSize: 12.sp,
    sectionTitleSize: 15.sp,
    addrNameSize: 15.sp,
    addrBodySize: 13.sp,
    changeBtnHeight: 4.6.h,
    changeBtnFontSize: 13.sp,
    walletIconBox: 12.w,
    walletIconSize: 21.sp,
    walletTitleSize: 16.sp,
    walletSubSize: 12.sp,
    balanceLabelSize: 11.sp,
    balanceValueSize: 15.sp,
    coinBadgeSize: 8.w,
    thumbSize: 17.w,
    itemTitleSize: 14.sp,
    itemMetaSize: 12.sp,
    rowLabelSize: 13.sp,
    rowValueSize: 13.sp,
    totalLabelSize: 15.sp,
    totalValueSize: 19.sp,
    stripIconBox: 12.w,
    stripIconSize: 21.sp,
    stripTitleSize: 12.sp,
    stripSubSize: 11.sp,
    offerIconBox: 10.w,
    offerIconSize: 17.sp,
    offerTitleSize: 13.sp,
    offerSubSize: 11.sp,
    linkSize: 13.sp,
    fieldHeight: 6.2.h,
    fieldRadius: 10,
    fieldTextSize: 13.sp,
    payHeight: 6.6.h,
    payFontSize: 14.sp,
    gapXs: 0.5.h,
    gapSm: 1.h,
    gapMd: 1.8.h,
    gapLg: 2.6.h,
  );

  // ── TABLET PORTRAIT ─────────────────────────────────────────────────────
  factory ReviewPayMetrics.tabletPortrait(Size size) => ReviewPayMetrics(
    isTablet: true,
    isLandscape: false,
    pageHPad: (size.width * 0.06).clamp(24.0, 60.0),
    pageVPad: 12,
    maxContentWidth: 780,
    railWidth: 0,
    backIconSize: 22,
    logoSize: 30,
    topIconSize: 24,
    badgeSize: 18,
    badgeFontSize: 10,
    pageTitleSize: 30,
    pageSubtitleSize: 15,
    cardRadius: 18,
    cardPad: 20,
    sectionLabelSize: 14,
    sectionTitleSize: 19,
    addrNameSize: 19,
    addrBodySize: 15,
    changeBtnHeight: 44,
    changeBtnFontSize: 15,
    walletIconBox: 54,
    walletIconSize: 26,
    walletTitleSize: 21,
    walletSubSize: 15,
    balanceLabelSize: 13,
    balanceValueSize: 19,
    coinBadgeSize: 36,
    thumbSize: 72,
    itemTitleSize: 17,
    itemMetaSize: 14,
    rowLabelSize: 16,
    rowValueSize: 16,
    totalLabelSize: 19,
    totalValueSize: 25,
    stripIconBox: 54,
    stripIconSize: 26,
    stripTitleSize: 15,
    stripSubSize: 14,
    offerIconBox: 46,
    offerIconSize: 22,
    offerTitleSize: 16,
    offerSubSize: 14,
    linkSize: 16,
    fieldHeight: 54,
    fieldRadius: 12,
    fieldTextSize: 16,
    payHeight: 58,
    payFontSize: 18,
    gapXs: 4,
    gapSm: 10,
    gapMd: 18,
    gapLg: 26,
  );

  // ── TABLET LANDSCAPE ────────────────────────────────────────────────────
  factory ReviewPayMetrics.tabletLandscape(Size size) => ReviewPayMetrics(
    isTablet: true,
    isLandscape: true,
    pageHPad: (size.width * 0.035).clamp(20.0, 48.0),
    pageVPad: 10,
    maxContentWidth: 1240,
    railWidth: (size.width * 0.34).clamp(320.0, 420.0),
    backIconSize: 20,
    logoSize: 28,
    topIconSize: 22,
    badgeSize: 17,
    badgeFontSize: 10,
    pageTitleSize: 26,
    pageSubtitleSize: 14,
    cardRadius: 18,
    cardPad: 16,
    sectionLabelSize: 13,
    sectionTitleSize: 18,
    addrNameSize: 18,
    addrBodySize: 14,
    changeBtnHeight: 40,
    changeBtnFontSize: 14,
    walletIconBox: 48,
    walletIconSize: 24,
    walletTitleSize: 19,
    walletSubSize: 14,
    balanceLabelSize: 12,
    balanceValueSize: 18,
    coinBadgeSize: 32,
    thumbSize: 64,
    itemTitleSize: 16,
    itemMetaSize: 13,
    rowLabelSize: 15,
    rowValueSize: 15,
    totalLabelSize: 18,
    totalValueSize: 23,
    stripIconBox: 48,
    stripIconSize: 24,
    stripTitleSize: 14,
    stripSubSize: 13,
    offerIconBox: 42,
    offerIconSize: 20,
    offerTitleSize: 15,
    offerSubSize: 13,
    linkSize: 15,
    fieldHeight: 50,
    fieldRadius: 12,
    fieldTextSize: 15,
    payHeight: 54,
    payFontSize: 17,
    gapXs: 3,
    gapSm: 8,
    gapMd: 14,
    gapLg: 22,
  );
}
