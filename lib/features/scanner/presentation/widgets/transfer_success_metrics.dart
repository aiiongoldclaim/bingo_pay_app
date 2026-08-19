import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

class TransferSuccessMetrics {
  final bool isTablet;
  final bool isLandscape;

  final double pageHPad;
  final double pageVPad;
  final double maxContentWidth;

  final double logoSize;

  final double tickOuter;
  final double tickInner;
  final double tickIconSize;

  final double titleSize;
  final double subtitleSize;
  final double amountSize;
  final double amountSubSize;

  final double cardRadius;
  final double cardPad;
  final double rowLabelSize;
  final double rowValueSize;
  final double copyIconSize;

  final double btnHeight;
  final double btnFontSize;

  final double gapXs;
  final double gapSm;
  final double gapMd;
  final double gapLg;

  const TransferSuccessMetrics({
    required this.isTablet,
    required this.isLandscape,
    required this.pageHPad,
    required this.pageVPad,
    required this.maxContentWidth,
    required this.logoSize,
    required this.tickOuter,
    required this.tickInner,
    required this.tickIconSize,
    required this.titleSize,
    required this.subtitleSize,
    required this.amountSize,
    required this.amountSubSize,
    required this.cardRadius,
    required this.cardPad,
    required this.rowLabelSize,
    required this.rowValueSize,
    required this.copyIconSize,
    required this.btnHeight,
    required this.btnFontSize,
    required this.gapXs,
    required this.gapSm,
    required this.gapMd,
    required this.gapLg,
  });

  static TransferSuccessMetrics of(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final isTablet = size.shortestSide >= 540;
    final isLandscape = size.width > size.height;
    if (!isTablet) return TransferSuccessMetrics.phone();
    return isLandscape
        ? TransferSuccessMetrics.tabletLandscape(size)
        : TransferSuccessMetrics.tabletPortrait(size);
  }

  factory TransferSuccessMetrics.phone() => TransferSuccessMetrics(
    isTablet: false,
    isLandscape: false,
    pageHPad: 5.w,
    pageVPad: 1.2.h,
    maxContentWidth: double.infinity,
    logoSize: 24.sp,
    tickOuter: 34.w,
    tickInner: 24.w,
    tickIconSize: 13.w,
    titleSize: 21.sp,
    subtitleSize: 13.sp,
    amountSize: 30.sp,
    amountSubSize: 12.sp,
    cardRadius: 16,
    cardPad: 4.w,
    rowLabelSize: 13.sp,
    rowValueSize: 13.sp,
    copyIconSize: 16.sp,
    btnHeight: 6.6.h,
    btnFontSize: 15.sp,
    gapXs: 0.5.h,
    gapSm: 1.h,
    gapMd: 1.8.h,
    gapLg: 2.8.h,
  );

  factory TransferSuccessMetrics.tabletPortrait(Size size) =>
      TransferSuccessMetrics(
        isTablet: true,
        isLandscape: false,
        pageHPad: (size.width * 0.08).clamp(28.0, 72.0),
        pageVPad: 12,
        maxContentWidth: 620,
        logoSize: 30,
        tickOuter: 190,
        tickInner: 134,
        tickIconSize: 72,
        titleSize: 30,
        subtitleSize: 16,
        amountSize: 42,
        amountSubSize: 15,
        cardRadius: 18,
        cardPad: 22,
        rowLabelSize: 16,
        rowValueSize: 16,
        copyIconSize: 20,
        btnHeight: 58,
        btnFontSize: 18,
        gapXs: 4,
        gapSm: 10,
        gapMd: 18,
        gapLg: 28,
      );

  factory TransferSuccessMetrics.tabletLandscape(Size size) =>
      TransferSuccessMetrics(
        isTablet: true,
        isLandscape: true,
        pageHPad: (size.width * 0.05).clamp(24.0, 60.0),
        pageVPad: 10,
        maxContentWidth: 1000,
        logoSize: 28,
        tickOuter: 150,
        tickInner: 106,
        tickIconSize: 58,
        titleSize: 27,
        subtitleSize: 15,
        amountSize: 36,
        amountSubSize: 14,
        cardRadius: 18,
        cardPad: 18,
        rowLabelSize: 15,
        rowValueSize: 15,
        copyIconSize: 19,
        btnHeight: 54,
        btnFontSize: 17,
        gapXs: 3,
        gapSm: 8,
        gapMd: 14,
        gapLg: 22,
      );
}