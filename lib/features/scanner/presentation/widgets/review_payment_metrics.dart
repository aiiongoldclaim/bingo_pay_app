import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

class ReviewPaymentMetrics {
  final bool isTablet;
  final bool isLandscape;

  final double pageHPad;
  final double pageVPad;
  final double maxContentWidth;
  final double railWidth;

  final double backIconSize;
  final double logoSize;
  final double logoSubSize;
  final double topIconSize;

  final double cardRadius;
  final double cardPad;
  final double sectionLabelSize;

  final double bannerIconBox;
  final double bannerIconSize;
  final double bannerTitleSize;
  final double bannerSubSize;

  final double merchantAvatar;
  final double merchantInitialSize;
  final double merchantNameSize;
  final double merchantIdSize;
  final double chipHeight;
  final double chipFontSize;

  final double amountBoxHeight;
  final double amountPrefixWidth;
  final double currencySize;
  final double amountSize;
  final double helperSize;

  final double convertBoxHeight;
  final double convertLabelSize;
  final double convertValueSize;
  final double swapBtnSize;
  final double rateSize;
  final double coinBadge;

  final double noteBoxHeight;
  final double methodTileHeight;
  final double methodIconBox;
  final double methodIconSize;
  final double methodTitleSize;
  final double methodSubSize;
  final double radioSize;

  final double payHeight;
  final double payFontSize;
  final double payNoteSize;

  final double gapXs;
  final double gapSm;
  final double gapMd;
  final double gapLg;



  const ReviewPaymentMetrics({
    required this.isTablet,
    required this.isLandscape,
    required this.pageHPad,
    required this.pageVPad,
    required this.maxContentWidth,
    required this.railWidth,
    required this.backIconSize,
    required this.logoSize,
    required this.logoSubSize,
    required this.topIconSize,
    required this.cardRadius,
    required this.cardPad,
    required this.sectionLabelSize,
    required this.bannerIconBox,
    required this.bannerIconSize,
    required this.bannerTitleSize,
    required this.bannerSubSize,
    required this.merchantAvatar,
    required this.merchantInitialSize,
    required this.merchantNameSize,
    required this.merchantIdSize,
    required this.chipHeight,
    required this.chipFontSize,
    required this.amountBoxHeight,
    required this.amountPrefixWidth,
    required this.currencySize,
    required this.amountSize,
    required this.helperSize,
    required this.convertBoxHeight,
    required this.convertLabelSize,
    required this.convertValueSize,
    required this.swapBtnSize,
    required this.rateSize,
    required this.coinBadge,
    required this.noteBoxHeight,
    required this.methodTileHeight,
    required this.methodIconBox,
    required this.methodIconSize,
    required this.methodTitleSize,
    required this.methodSubSize,
    required this.radioSize,
    required this.payHeight,
    required this.payFontSize,
    required this.payNoteSize,
    required this.gapXs,
    required this.gapSm,
    required this.gapMd,
    required this.gapLg,
  });

  static ReviewPaymentMetrics of(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final isTablet = size.shortestSide >= 540;
    final isLandscape = size.width > size.height;
    if (!isTablet) return ReviewPaymentMetrics.phone();
    return isLandscape
        ? ReviewPaymentMetrics.tabletLandscape(size)
        : ReviewPaymentMetrics.tabletPortrait(size);
  }

  // ── PHONE ───────────────────────────────────────────────────────────────
  factory ReviewPaymentMetrics.phone() => ReviewPaymentMetrics(
    isTablet: false,
    isLandscape: false,
    pageHPad: 4.w,
    pageVPad: 1.2.h,
    maxContentWidth: double.infinity,
    railWidth: 0,
    backIconSize: 20.sp,
    logoSize: 24.sp,
    logoSubSize: 13.sp,
    topIconSize: 20.sp,
    cardRadius: 16,
    cardPad: 4.w,
    sectionLabelSize: 12.sp,
    bannerIconBox: 12.w,
    bannerIconSize: 21.sp,
    bannerTitleSize: 14.sp,
    bannerSubSize: 12.sp,
    merchantAvatar: 15.w,
    merchantInitialSize: 18.sp,
    merchantNameSize: 17.sp,
    merchantIdSize: 12.sp,
    chipHeight: 3.8.h,
    chipFontSize: 11.sp,
    amountBoxHeight: 9.h,
    amountPrefixWidth: 26.w,
    currencySize: 15.sp,
    amountSize: 26.sp,
    helperSize: 11.sp,
    convertBoxHeight: 9.h,
    convertLabelSize: 11.sp,
    convertValueSize: 16.sp,
    swapBtnSize: 11.w,
    rateSize: 11.sp,
    coinBadge: 8.w,
    noteBoxHeight: 7.h,
    methodTileHeight: 9.h,
    methodIconBox: 12.w,
    methodIconSize: 21.sp,
    methodTitleSize: 14.sp,
    methodSubSize: 11.sp,
    radioSize: 5.5.w,
    payHeight: 6.6.h,
    payFontSize: 15.sp,
    payNoteSize: 11.sp,
    gapXs: 0.5.h,
    gapSm: 1.h,
    gapMd: 1.8.h,
    gapLg: 2.6.h,
  );

  // ── TABLET PORTRAIT ─────────────────────────────────────────────────────
  factory ReviewPaymentMetrics.tabletPortrait(Size size) =>
      ReviewPaymentMetrics(
        isTablet: true,
        isLandscape: false,
        pageHPad: (size.width * 0.06).clamp(24.0, 60.0),
        pageVPad: 12,
        maxContentWidth: 760,
        railWidth: 0,
        backIconSize: 22,
        logoSize: 30,
        logoSubSize: 16,
        topIconSize: 24,
        cardRadius: 18,
        cardPad: 20,
        sectionLabelSize: 14,
        bannerIconBox: 56,
        bannerIconSize: 27,
        bannerTitleSize: 18,
        bannerSubSize: 15,
        merchantAvatar: 72,
        merchantInitialSize: 26,
        merchantNameSize: 22,
        merchantIdSize: 15,
        chipHeight: 34,
        chipFontSize: 13,
        amountBoxHeight: 82,
        amountPrefixWidth: 130,
        currencySize: 19,
        amountSize: 36,
        helperSize: 14,
        convertBoxHeight: 84,
        convertLabelSize: 13,
        convertValueSize: 21,
        swapBtnSize: 52,
        rateSize: 14,
        coinBadge: 38,
        noteBoxHeight: 64,
        methodTileHeight: 84,
        methodIconBox: 54,
        methodIconSize: 26,
        methodTitleSize: 18,
        methodSubSize: 14,
        radioSize: 24,
        payHeight: 58,
        payFontSize: 18,
        payNoteSize: 13,
        gapXs: 4,
        gapSm: 10,
        gapMd: 18,
        gapLg: 26,
      );

  // ── TABLET LANDSCAPE ────────────────────────────────────────────────────
  factory ReviewPaymentMetrics.tabletLandscape(Size size) =>
      ReviewPaymentMetrics(
        isTablet: true,
        isLandscape: true,
        pageHPad: (size.width * 0.035).clamp(20.0, 48.0),
        pageVPad: 10,
        maxContentWidth: 1240,
        railWidth: (size.width * 0.36).clamp(340.0, 460.0),
        backIconSize: 20,
        logoSize: 28,
        logoSubSize: 15,
        topIconSize: 22,
        cardRadius: 18,
        cardPad: 16,
        sectionLabelSize: 13,
        bannerIconBox: 48,
        bannerIconSize: 25,
        bannerTitleSize: 17,
        bannerSubSize: 14,
        merchantAvatar: 62,
        merchantInitialSize: 23,
        merchantNameSize: 20,
        merchantIdSize: 14,
        chipHeight: 32,
        chipFontSize: 12,
        amountBoxHeight: 74,
        amountPrefixWidth: 118,
        currencySize: 18,
        amountSize: 32,
        helperSize: 13,
        convertBoxHeight: 76,
        convertLabelSize: 12,
        convertValueSize: 19,
        swapBtnSize: 46,
        rateSize: 13,
        coinBadge: 34,
        noteBoxHeight: 58,
        methodTileHeight: 76,
        methodIconBox: 48,
        methodIconSize: 24,
        methodTitleSize: 17,
        methodSubSize: 13,
        radioSize: 22,
        payHeight: 54,
        payFontSize: 17,
        payNoteSize: 12,
        gapXs: 3,
        gapSm: 8,
        gapMd: 14,
        gapLg: 22,
      );
}