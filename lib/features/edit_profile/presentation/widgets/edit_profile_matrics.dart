import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

class EditProfileMetrics {
  final bool isTablet;
  final bool isLandscape;

  final double pageHPad;
  final double pageVPad;
  final double maxContentWidth;
  final double avatarPaneWidth;

  final double backIconSize;
  final double titleSize;

  final double avatarSize;
  final double avatarInitialSize;
  final double cameraBadgeSize;
  final double cameraIconSize;
  final double avatarNameSize;
  final double avatarHintSize;

  final double cardRadius;
  final double cardPad;
  final double sectionTitleSize;

  final double fieldHeight;
  final double fieldRadius;
  final double fieldLabelSize;
  final double fieldTextSize;
  final double fieldIconSize;
  final double errorSize;

  final double btnHeight;
  final double btnFontSize;

  final double gapXs;
  final double gapSm;
  final double gapMd;
  final double gapLg;

  const EditProfileMetrics({
    required this.isTablet,
    required this.isLandscape,
    required this.pageHPad,
    required this.pageVPad,
    required this.maxContentWidth,
    required this.avatarPaneWidth,
    required this.backIconSize,
    required this.titleSize,
    required this.avatarSize,
    required this.avatarInitialSize,
    required this.cameraBadgeSize,
    required this.cameraIconSize,
    required this.avatarNameSize,
    required this.avatarHintSize,
    required this.cardRadius,
    required this.cardPad,
    required this.sectionTitleSize,
    required this.fieldHeight,
    required this.fieldRadius,
    required this.fieldLabelSize,
    required this.fieldTextSize,
    required this.fieldIconSize,
    required this.errorSize,
    required this.btnHeight,
    required this.btnFontSize,
    required this.gapXs,
    required this.gapSm,
    required this.gapMd,
    required this.gapLg,
  });

  static EditProfileMetrics of(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final isTablet = size.shortestSide >= 540;
    final isLandscape = size.width > size.height;
    if (!isTablet) return EditProfileMetrics.phone();
    return isLandscape
        ? EditProfileMetrics.tabletLandscape(size)
        : EditProfileMetrics.tabletPortrait(size);
  }

  factory EditProfileMetrics.phone() => EditProfileMetrics(
    isTablet: false,
    isLandscape: false,
    pageHPad: 4.w,
    pageVPad: 1.2.h,
    maxContentWidth: double.infinity,
    avatarPaneWidth: 0,
    backIconSize: 20.sp,
    titleSize: 19.sp,
    avatarSize: 28.w,
    avatarInitialSize: 26.sp,
    cameraBadgeSize: 9.w,
    cameraIconSize: 4.5.w,
    avatarNameSize: 16.sp,
    avatarHintSize: 12.sp,
    cardRadius: 16,
    cardPad: 4.w,
    sectionTitleSize: 15.sp,
    fieldHeight: 6.4.h,
    fieldRadius: 12,
    fieldLabelSize: 12.sp,
    fieldTextSize: 14.sp,
    fieldIconSize: 18.sp,
    errorSize: 11.sp,
    btnHeight: 6.4.h,
    btnFontSize: 14.sp,
    gapXs: 0.5.h,
    gapSm: 1.h,
    gapMd: 1.8.h,
    gapLg: 2.8.h,
  );

  factory EditProfileMetrics.tabletPortrait(Size size) => EditProfileMetrics(
    isTablet: true,
    isLandscape: false,
    pageHPad: (size.width * 0.06).clamp(24.0, 60.0),
    pageVPad: 12,
    maxContentWidth: 720,
    avatarPaneWidth: 0,
    backIconSize: 22,
    titleSize: 26,
    avatarSize: 132,
    avatarInitialSize: 46,
    cameraBadgeSize: 42,
    cameraIconSize: 20,
    avatarNameSize: 21,
    avatarHintSize: 15,
    cardRadius: 18,
    cardPad: 22,
    sectionTitleSize: 19,
    fieldHeight: 56,
    fieldRadius: 12,
    fieldLabelSize: 15,
    fieldTextSize: 17,
    fieldIconSize: 22,
    errorSize: 13,
    btnHeight: 56,
    btnFontSize: 17,
    gapXs: 4,
    gapSm: 10,
    gapMd: 18,
    gapLg: 28,
  );

  factory EditProfileMetrics.tabletLandscape(Size size) => EditProfileMetrics(
    isTablet: true,
    isLandscape: true,
    pageHPad: (size.width * 0.04).clamp(20.0, 52.0),
    pageVPad: 10,
    maxContentWidth: 1100,
    avatarPaneWidth: (size.width * 0.28).clamp(260.0, 360.0),
    backIconSize: 20,
    titleSize: 24,
    avatarSize: 116,
    avatarInitialSize: 40,
    cameraBadgeSize: 38,
    cameraIconSize: 18,
    avatarNameSize: 19,
    avatarHintSize: 14,
    cardRadius: 18,
    cardPad: 18,
    sectionTitleSize: 18,
    fieldHeight: 52,
    fieldRadius: 12,
    fieldLabelSize: 14,
    fieldTextSize: 16,
    fieldIconSize: 20,
    errorSize: 12,
    btnHeight: 52,
    btnFontSize: 16,
    gapXs: 3,
    gapSm: 8,
    gapMd: 14,
    gapLg: 22,
  );
}