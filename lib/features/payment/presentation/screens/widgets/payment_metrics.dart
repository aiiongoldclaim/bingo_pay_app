import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

class PaymentMetrics {
  final bool isTablet;
  final bool isLandscape;

  final double pageHPad;
  final double pageVPad;
  final double maxContentWidth;
  final double railWidth;

  // Top bar
  final double backIconSize;
  final double logoSize;
  final double topIconSize;

  // Stepper
  final double stepCircle;
  final double stepNumSize;
  final double stepLabelSize;

  // Cards
  final double cardRadius;
  final double cardPad;
  final double sectionTitleSize;

  // Address
  final double addrRadius;
  final double addrPad;
  final double addrRadioSize;
  final double addrNameSize;
  final double addrBodySize;
  final double addrChipSize;
  final double addrActionIcon;

  // Summary / wallet
  final double summaryLabelSize;
  final double summaryValueSize;
  final double totalLabelSize;
  final double totalValueSize;
  final double walletIconBox;
  final double walletIconSize;

  // Bottom bar
  final double payHeight;
  final double payFontSize;
  final double payNoteSize;

  final double gapXs;
  final double gapSm;
  final double gapMd;
  final double gapLg;

  const PaymentMetrics({
    required this.isTablet,
    required this.isLandscape,
    required this.pageHPad,
    required this.pageVPad,
    required this.maxContentWidth,
    required this.railWidth,
    required this.backIconSize,
    required this.logoSize,
    required this.topIconSize,
    required this.stepCircle,
    required this.stepNumSize,
    required this.stepLabelSize,
    required this.cardRadius,
    required this.cardPad,
    required this.sectionTitleSize,
    required this.addrRadius,
    required this.addrPad,
    required this.addrRadioSize,
    required this.addrNameSize,
    required this.addrBodySize,
    required this.addrChipSize,
    required this.addrActionIcon,
    required this.summaryLabelSize,
    required this.summaryValueSize,
    required this.totalLabelSize,
    required this.totalValueSize,
    required this.walletIconBox,
    required this.walletIconSize,
    required this.payHeight,
    required this.payFontSize,
    required this.payNoteSize,
    required this.gapXs,
    required this.gapSm,
    required this.gapMd,
    required this.gapLg,
  });

  static PaymentMetrics of(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final isTablet = size.shortestSide >= 540;
    final isLandscape = size.width > size.height;
    if (!isTablet) return PaymentMetrics.phone();
    return isLandscape
        ? PaymentMetrics.tabletLandscape(size)
        : PaymentMetrics.tabletPortrait(size);
  }

  factory PaymentMetrics.phone() => PaymentMetrics(
    isTablet: false,
    isLandscape: false,
    pageHPad: 4.w,
    pageVPad: 1.2.h,
    maxContentWidth: double.infinity,
    railWidth: 0,
    backIconSize: 20.sp,
    logoSize: 24.sp,
    topIconSize: 20.sp,
    stepCircle: 8.w,
    stepNumSize: 12.sp,
    stepLabelSize: 12.sp,
    cardRadius: 16,
    cardPad: 4.w,
    sectionTitleSize: 16.sp,
    addrRadius: 14,
    addrPad: 3.5.w,
    addrRadioSize: 5.5.w,
    addrNameSize: 14.sp,
    addrBodySize: 12.sp,
    addrChipSize: 10.sp,
    addrActionIcon: 18.sp,
    summaryLabelSize: 13.sp,
    summaryValueSize: 13.sp,
    totalLabelSize: 15.sp,
    totalValueSize: 18.sp,
    walletIconBox: 11.w,
    walletIconSize: 20.sp,
    payHeight: 6.6.h,
    payFontSize: 14.sp,
    payNoteSize: 11.sp,
    gapXs: 0.5.h,
    gapSm: 1.h,
    gapMd: 1.8.h,
    gapLg: 2.6.h,
  );

  factory PaymentMetrics.tabletPortrait(Size size) => PaymentMetrics(
    isTablet: true,
    isLandscape: false,
    pageHPad: (size.width * 0.06).clamp(24.0, 60.0),
    pageVPad: 12,
    maxContentWidth: 760,
    railWidth: 0,
    backIconSize: 22,
    logoSize: 30,
    topIconSize: 24,
    stepCircle: 38,
    stepNumSize: 16,
    stepLabelSize: 15,
    cardRadius: 18,
    cardPad: 20,
    sectionTitleSize: 20,
    addrRadius: 16,
    addrPad: 18,
    addrRadioSize: 24,
    addrNameSize: 18,
    addrBodySize: 15,
    addrChipSize: 12,
    addrActionIcon: 22,
    summaryLabelSize: 16,
    summaryValueSize: 16,
    totalLabelSize: 19,
    totalValueSize: 25,
    walletIconBox: 52,
    walletIconSize: 26,
    payHeight: 58,
    payFontSize: 18,
    payNoteSize: 13,
    gapXs: 4,
    gapSm: 10,
    gapMd: 16,
    gapLg: 24,
  );

  factory PaymentMetrics.tabletLandscape(Size size) => PaymentMetrics(
    isTablet: true,
    isLandscape: true,
    pageHPad: (size.width * 0.035).clamp(20.0, 48.0),
    pageVPad: 10,
    maxContentWidth: 1240,
    railWidth: (size.width * 0.33).clamp(300.0, 400.0),
    backIconSize: 20,
    logoSize: 28,
    topIconSize: 22,
    stepCircle: 34,
    stepNumSize: 15,
    stepLabelSize: 14,
    cardRadius: 18,
    cardPad: 16,
    sectionTitleSize: 19,
    addrRadius: 16,
    addrPad: 14,
    addrRadioSize: 22,
    addrNameSize: 17,
    addrBodySize: 14,
    addrChipSize: 11,
    addrActionIcon: 20,
    summaryLabelSize: 15,
    summaryValueSize: 15,
    totalLabelSize: 18,
    totalValueSize: 23,
    walletIconBox: 46,
    walletIconSize: 24,
    payHeight: 54,
    payFontSize: 17,
    payNoteSize: 12,
    gapXs: 3,
    gapSm: 8,
    gapMd: 14,
    gapLg: 20,
  );
}
