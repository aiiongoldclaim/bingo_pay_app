import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

class PaymentSuccessMetrics {
  final bool isTablet;
  final bool isLandscape;

  final double pageHPad;
  final double pageVPad;
  final double maxContentWidth;

  final double gapXs;
  final double gapSm;
  final double gapMd;
  final double gapLg;

  // hero
  final double heroField;
  final double badgeSize;
  final double checkSize;
  final double titleSize;
  final double subtitleSize;
  final double chipTextSize;
  final double chipIconSize;
  final double chipRadius;

  // invoice card
  final double cardRadius;
  final double headerPad;
  final double bodyPad;
  final double merchantAvatar;
  final double merchantIconSize;
  final double merchantNameSize;
  final double invoiceNoSize;
  final double metaSize;

  final double rowIconBox;
  final double rowIconSize;
  final double rowIconRadius;
  final double rowLabelSize;
  final double rowTitleSize;
  final double rowSubSize;
  final double rowAmountSize;
  final double paidAmountSize;

  // action bar
  final double barHPad;
  final double barVPad;
  final double btnHeight;
  final double btnRadius;
  final double btnFontSize;
  final double btnIconSize;

  const PaymentSuccessMetrics._({
    required this.isTablet,
    required this.isLandscape,
    required this.pageHPad,
    required this.pageVPad,
    required this.maxContentWidth,
    required this.gapXs,
    required this.gapSm,
    required this.gapMd,
    required this.gapLg,
    required this.heroField,
    required this.badgeSize,
    required this.checkSize,
    required this.titleSize,
    required this.subtitleSize,
    required this.chipTextSize,
    required this.chipIconSize,
    required this.chipRadius,
    required this.cardRadius,
    required this.headerPad,
    required this.bodyPad,
    required this.merchantAvatar,
    required this.merchantIconSize,
    required this.merchantNameSize,
    required this.invoiceNoSize,
    required this.metaSize,
    required this.rowIconBox,
    required this.rowIconSize,
    required this.rowIconRadius,
    required this.rowLabelSize,
    required this.rowTitleSize,
    required this.rowSubSize,
    required this.rowAmountSize,
    required this.paidAmountSize,
    required this.barHPad,
    required this.barVPad,
    required this.btnHeight,
    required this.btnRadius,
    required this.btnFontSize,
    required this.btnIconSize,
  });

  factory PaymentSuccessMetrics.of(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final isTablet = size.shortestSide >= 540;
    final isLandscape = size.width > size.height;

    double t(double v, double min, double max) => v.clamp(min, max);

    if (isTablet) {
      final short = size.shortestSide;
      return PaymentSuccessMetrics._(
        isTablet: true,
        isLandscape: isLandscape,
        pageHPad: t(short * 0.055, 22, 40),
        pageVPad: t(short * 0.030, 14, 26),
        maxContentWidth: isLandscape ? 1080 : 720,
        gapXs: 5,
        gapSm: 10,
        gapMd: 16,
        gapLg: 26,
        heroField: isLandscape ? 200 : 230,
        badgeSize: isLandscape ? 104 : 122,
        checkSize: isLandscape ? 52 : 62,
        titleSize: 26,
        subtitleSize: 15,
        chipTextSize: 14,
        chipIconSize: 17,
        chipRadius: 14,
        cardRadius: 20,
        headerPad: 20,
        bodyPad: 20,
        merchantAvatar: 52,
        merchantIconSize: 25,
        merchantNameSize: 19,
        invoiceNoSize: 14,
        metaSize: 13,
        rowIconBox: 42,
        rowIconSize: 20,
        rowIconRadius: 12,
        rowLabelSize: 11.5,
        rowTitleSize: 17,
        rowSubSize: 14,
        rowAmountSize: 18,
        paidAmountSize: 22,
        barHPad: t(short * 0.055, 22, 40),
        barVPad: 14,
        btnHeight: 54,
        btnRadius: 14,
        btnFontSize: 16,
        btnIconSize: 20,
      );
    }

    return PaymentSuccessMetrics._(
      isTablet: false,
      isLandscape: isLandscape,
      pageHPad: 4.5.w,
      pageVPad: 1.4.h,
      maxContentWidth: 560,
      gapXs: 0.5.h,
      gapSm: 1.0.h,
      gapMd: 1.6.h,
      gapLg: 2.6.h,
      heroField: isLandscape ? 24.h : 26.h,
      badgeSize: isLandscape ? 14.h : 13.h,
      checkSize: isLandscape ? 7.h : 6.5.h,
      titleSize: 22.sp,
      subtitleSize: 13.sp,
      chipTextSize: 12.5.sp,
      chipIconSize: 15.sp,
      chipRadius: 12,
      cardRadius: 18,
      headerPad: 4.w,
      bodyPad: 4.w,
      merchantAvatar: 12.w,
      merchantIconSize: 5.5.w,
      merchantNameSize: 16.sp,
      invoiceNoSize: 12.sp,
      metaSize: 11.5.sp,
      rowIconBox: 10.w,
      rowIconSize: 4.8.w,
      rowIconRadius: 10,
      rowLabelSize: 10.sp,
      rowTitleSize: 14.5.sp,
      rowSubSize: 12.sp,
      rowAmountSize: 15.sp,
      paidAmountSize: 18.sp,
      barHPad: 4.5.w,
      barVPad: 1.2.h,
      btnHeight: 6.2.h,
      btnRadius: 12,
      btnFontSize: 14.sp,
      btnIconSize: 17.sp,
    );
  }
}