import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../../core/utils/responsive_utils.dart';

/// Responsive sizing for the Profile / Account screen.
/// Phone  -> Sizer units
/// Tablet -> fixed dp with clamp() (no Sizer oversizing)
class AccountMetrics {
  // Page
  final double pageHPad;
  final double maxContentWidth;

  // AppBar
  final double appBarHPad;
  final double appBarVPad;
  final double titleSize;
  final double appBarIconSize;

  // Avatar row
  final double avatarSize;
  final double avatarRadius;
  final double avatarInitialSize;
  final double avatarGap;
  final double nameSize;
  final double emailSize;
  final double cameraBadgeSize;
  final double cameraIconSize;

  // Wallet card
  final double walletHPad;
  final double walletVPad;
  final double walletRadius;
  final double walletIconSize;
  final double walletGap;
  final double walletLabelSize;
  final double walletBalanceSize;

  // Menu
  final double menuRadius;
  final double menuItemHPad;
  final double menuItemVPad;
  final double menuIconSize;
  final double menuIconGap;
  final double menuIconBox;
  final double sectionHeadingSize;
  final double sectionHeadingGap;
  final double menuTitleSize;
  final double menuSubtitleSize;
  final double chevronSize;
  final double dividerIndent;

  // Benefits strip
  final double benefitIconSize;
  final double benefitTitleSize;
  final double benefitSubtitleSize;
  final double benefitVPad;

  // Spacing
  final double gapXs;
  final double gapSm;
  final double gapMd;
  final double gapLg;
  final double bottomPad;

  const AccountMetrics({
    required this.pageHPad,
    required this.maxContentWidth,
    required this.appBarHPad,
    required this.appBarVPad,
    required this.titleSize,
    required this.appBarIconSize,
    required this.avatarSize,
    required this.avatarRadius,
    required this.avatarInitialSize,
    required this.avatarGap,
    required this.nameSize,
    required this.emailSize,
    required this.cameraBadgeSize,
    required this.cameraIconSize,
    required this.walletHPad,
    required this.walletVPad,
    required this.walletRadius,
    required this.walletIconSize,
    required this.walletGap,
    required this.walletLabelSize,
    required this.walletBalanceSize,
    required this.menuRadius,
    required this.menuItemHPad,
    required this.menuItemVPad,
    required this.menuIconSize,
    required this.menuIconGap,
    required this.menuTitleSize,
    required this.menuSubtitleSize,
    required this.chevronSize,
    required this.dividerIndent,
    required this.benefitIconSize,
    required this.benefitTitleSize,
    required this.benefitSubtitleSize,
    required this.benefitVPad,
    required this.gapXs,
    required this.gapSm,
    required this.gapMd,
    required this.gapLg,
    required this.bottomPad,

    required this.menuIconBox,
    required this.sectionHeadingSize,
    required this.sectionHeadingGap,
  });

  static AccountMetrics of(BuildContext context) {
    final shortest = MediaQuery.sizeOf(context).shortestSide;
    final size = MediaQuery.sizeOf(context);
    final isTablet = shortest >= 540;
    final isLandscape = size.width > size.height;

    if (!isTablet) return AccountMetrics.phone();
    return isLandscape
        ? AccountMetrics.tabletLandscape(size)
        : AccountMetrics.tabletPortrait(size);
  }

  // ── PHONE ────────────────────────────────────────────────────────────────
  factory AccountMetrics.phone() => AccountMetrics(
    pageHPad: 4.w,
    maxContentWidth: double.infinity,
    appBarHPad: 5.w,
    appBarVPad: 1.2.h,
    titleSize: 26.sp,
    appBarIconSize: 22.sp,
    avatarSize: 20.w,
    avatarRadius: 20.w,
    avatarInitialSize: 26.sp,
    avatarGap: 4.w,
    nameSize: 17.sp,
    emailSize: 13.sp,
    cameraBadgeSize: 6.5.w,
    cameraIconSize: 3.5.w,
    walletHPad: 4.w,
    walletVPad: 2.h,
    walletRadius: 14,
    walletIconSize: 30.sp,
    walletGap: 4.w,
    walletLabelSize: 15.sp,
    walletBalanceSize: 19.sp,
    menuRadius: 16,
    menuItemHPad: 4.5.w,
    menuItemVPad: 1.8.h,
    menuIconSize: 22.sp,
    menuIconGap: 4.5.w,
    menuTitleSize: 15.sp,
    menuSubtitleSize: 12.sp,
    chevronSize: 16.sp,
    dividerIndent: 16.w,
    benefitIconSize: 20.sp,
    benefitTitleSize: 12.sp,
    benefitSubtitleSize: 10.sp,
    benefitVPad: 1.6.h,
    gapXs: 0.4.h,
    gapSm: 1.2.h,
    gapMd: 2.2.h,
    gapLg: 3.h,
    bottomPad: 4.h,

    menuIconBox: 12.w,
    sectionHeadingSize: 16.sp,
    sectionHeadingGap: 1.4.h,
  );

  // ── TABLET PORTRAIT ──────────────────────────────────────────────────────
  factory AccountMetrics.tabletPortrait(Size size) {
    final w = size.width;
    return AccountMetrics(
      pageHPad: (w * 0.06).clamp(24.0, 56.0),
      maxContentWidth: 720,
      appBarHPad: (w * 0.06).clamp(24.0, 56.0),
      appBarVPad: 12,
      titleSize: 34,
      appBarIconSize: 24,
      avatarSize: 104,
      avatarRadius: 104,
      avatarInitialSize: 40,
      avatarGap: 20,
      nameSize: 22,
      emailSize: 15,
      cameraBadgeSize: 30,
      cameraIconSize: 15,
      walletHPad: 20,
      walletVPad: 18,
      walletRadius: 16,
      walletIconSize: 40,
      walletGap: 18,
      walletLabelSize: 17,
      walletBalanceSize: 24,
      menuRadius: 18,
      menuItemHPad: 20,
      menuItemVPad: 16,
      menuIconSize: 26,
      menuIconGap: 18,
      menuTitleSize: 18,
      menuSubtitleSize: 14,
      chevronSize: 18,
      dividerIndent: 64,
      benefitIconSize: 24,
      benefitTitleSize: 14,
      benefitSubtitleSize: 12,
      benefitVPad: 16,
      gapXs: 4,
      gapSm: 12,
      gapMd: 22,
      gapLg: 30,
      bottomPad: 40,

      menuIconBox: 56,
      sectionHeadingSize: 20,
      sectionHeadingGap: 14,
    );
  }

  // ── TABLET LANDSCAPE ─────────────────────────────────────────────────────
  factory AccountMetrics.tabletLandscape(Size size) {
    final w = size.width;
    return AccountMetrics(
      pageHPad: (w * 0.04).clamp(20.0, 48.0),
      maxContentWidth: 1100,
      appBarHPad: (w * 0.04).clamp(20.0, 48.0),
      appBarVPad: 8,
      titleSize: 30,
      appBarIconSize: 22,
      avatarSize: 88,
      avatarRadius: 88,
      avatarInitialSize: 34,
      avatarGap: 18,
      nameSize: 20,
      emailSize: 14,
      cameraBadgeSize: 26,
      cameraIconSize: 13,
      walletHPad: 18,
      walletVPad: 14,
      walletRadius: 16,
      walletIconSize: 34,
      walletGap: 16,
      walletLabelSize: 16,
      walletBalanceSize: 22,
      menuRadius: 18,
      menuItemHPad: 18,
      menuItemVPad: 13,
      menuIconSize: 24,
      menuIconGap: 16,
      menuTitleSize: 17,
      menuSubtitleSize: 13,
      chevronSize: 17,
      dividerIndent: 58,
      benefitIconSize: 22,
      benefitTitleSize: 13,
      benefitSubtitleSize: 11,
      benefitVPad: 12,
      gapXs: 3,
      gapSm: 10,
      gapMd: 16,
      gapLg: 22,
      bottomPad: 28,
      menuIconBox: 50,
      sectionHeadingSize: 19,
      sectionHeadingGap: 12,
    );
  }

  bool get isTablet => maxContentWidth != double.infinity;
  bool get isLandscape => maxContentWidth == 1100;
}
