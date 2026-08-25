import 'package:flutter/material.dart';
import '../../../../core/theme/theme_colors.dart';
import '../../../../core/utils/responsive_utils.dart';

class OnboardingMetrics {
  const OnboardingMetrics({
    required this.isRow,
    required this.showFeatures,
    required this.logoHeight,
    required this.logoFont,
    required this.imageWidth,
    required this.imageHeight,
    required this.title,
    required this.subtitle,
    required this.featureTitle,
    required this.featureBody,
    required this.featureIconBox,
    required this.buttonHeight,
    required this.buttonWidth,
    required this.buttonFont,
    required this.dotSize,
    required this.hPad,
    required this.gapImage,
    required this.gapTitle,
    required this.gapFeature,
    required this.bottomGap,
    required this.skipFont,
  });

  /// true = text left + image right (landscape)
  final bool isRow;

  /// feature list sirf tablet landscape me
  final bool showFeatures;

  final double logoHeight;
  final double logoFont;
  final double imageWidth;
  final double imageHeight;
  final double title;
  final double subtitle;
  final double featureTitle;
  final double featureBody;
  final double featureIconBox;
  final double buttonHeight;
  final double buttonWidth;
  final double buttonFont;
  final double dotSize;
  final double hPad;
  final double gapImage;
  final double gapTitle;
  final double gapFeature;
  final double bottomGap;
  final double skipFont;

  factory OnboardingMetrics.of(BuildContext context, BoxConstraints b) {
    final w = b.maxWidth;
    final h = b.maxHeight;

    // orientation constraints se — split-screen me reliable
    final isLandscape = w > h;
    final isTablet = ResponsiveUtils.isTablet;

    // ── Tablet landscape ──
    if (isTablet && isLandscape) {
      return OnboardingMetrics(
        isRow: true,
        showFeatures: true,
        logoHeight: 32,
        logoFont: (w * 0.017).clamp(16, 24),
        imageWidth: w * 0.42,
        imageHeight: h * 0.62,
        title: (w * 0.032).clamp(28, 46),
        subtitle: (w * 0.012).clamp(13, 18),
        featureTitle: (w * 0.011).clamp(12, 16),
        featureBody: (w * 0.0095).clamp(11, 14),
        featureIconBox: 38,
        buttonHeight: 46,
        buttonWidth: 130,
        buttonFont: 14,
        dotSize: 8,
        hPad: w * 0.045,
        gapImage: 24,
        gapTitle: 14,
        gapFeature: 18,
        bottomGap: 14,
        skipFont: (w * 0.016).clamp(16, 22),
      );
    }

    // ── Tablet portrait ──
    if (isTablet) {
      return OnboardingMetrics(
        isRow: false,
        showFeatures: false,
        logoHeight: 32,
        logoFont: (w * 0.032).clamp(18, 26),
        imageWidth: w * 0.72,
        imageHeight: h * 0.42,
        title: (w * 0.052).clamp(26, 40),
        subtitle: (w * 0.022).clamp(13, 18),
        featureTitle: 15,
        featureBody: 13,
        featureIconBox: 38,
        buttonHeight: 46,
        buttonWidth: 120,
        buttonFont: 14,
        dotSize: 8,
        hPad: w * 0.07,
        gapImage: 26,
        gapTitle: 14,
        gapFeature: 16,
        bottomGap: 18,
        skipFont: (w * 0.026).clamp(16, 22),
      );
    }

    // ── Phone landscape ──
    if (isLandscape) {
      return OnboardingMetrics(
        isRow: true,
        showFeatures: false,
        logoHeight: 24,
        logoFont: 16,
        imageWidth: w * 0.40,
        imageHeight: h * 0.60,
        title: (w * 0.038).clamp(20, 30),
        subtitle: (w * 0.018).clamp(11, 14),
        featureTitle: 13,
        featureBody: 11,
        featureIconBox: 32,
        buttonHeight: 40,
        buttonWidth: 108,
        buttonFont: 13,
        dotSize: 7,
        hPad: w * 0.05,
        gapImage: 16,
        gapTitle: 8,
        gapFeature: 12,
        bottomGap: 8,
        skipFont: 14,
      );
    }

    // ── Phone portrait ──
    return OnboardingMetrics(
      isRow: false,
      showFeatures: false,
      logoHeight: 26,
      logoFont: (w * 0.052).clamp(18, 24),
      imageWidth: w * 0.82,
      imageHeight: h * 0.38,
      title: (w * 0.068).clamp(22, 30),
      subtitle: (w * 0.033).clamp(12, 15),
      featureTitle: 14,
      featureBody: 12,
      featureIconBox: 34,
      buttonHeight: 44,
      buttonWidth: 112,
      buttonFont: 13,
      dotSize: 7,
      hPad: 20,
      gapImage: 18,
      gapTitle: 10,
      gapFeature: 14,
      bottomGap: 12,
      skipFont: 14,
    );
  }
}

/// Onboarding ke saare colors — sirf ThemeColors constants se.
class OnboardingPalette {
  const OnboardingPalette({
    required this.isDark,
    required this.title,
    required this.body,
    required this.logoText,
    required this.logoAccent,
    required this.iconRing,
    required this.iconTint,
    required this.dotActive,
    required this.dotIdle,
    required this.backBorder,
    required this.backText,
    required this.nextFill,
    required this.nextGradient,
    required this.nextText,
    required this.skip,
  });

  final bool isDark;
  final Color title;
  final Color body;
  final Color logoText;
  final Color logoAccent;
  final Color iconRing;
  final Color iconTint;
  final Color dotActive;
  final Color dotIdle;
  final Color backBorder;
  final Color backText;

  /// light: solid navy | dark: null (gradient use hota hai)
  final Color? nextFill;
  final Gradient? nextGradient;
  final Color nextText;
  final Color skip;

  factory OnboardingPalette.of(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final border = isDark
        ? ThemeColors.white.withValues(alpha: 0.14)
        : ThemeColors.line;

    return OnboardingPalette(
      isDark: isDark,
      title: isDark ? ThemeColors.white : ThemeColors.textDark,
      body: isDark ? ThemeColors.inkDim : ThemeColors.inkMid,
      logoText: isDark ? ThemeColors.white : ThemeColors.textDark,
      logoAccent: ThemeColors.gold,
      iconRing: border,
      iconTint: ThemeColors.gold,
      dotActive: ThemeColors.gold,
      dotIdle: isDark
          ? ThemeColors.white.withValues(alpha: 0.22)
          : ThemeColors.ink.withValues(alpha: 0.16),
      backBorder: border,
      backText: isDark ? ThemeColors.white : ThemeColors.textDark,

      nextFill: null,
      nextGradient: ThemeColors.bottomSection,
      nextText: ThemeColors.white,

      skip: isDark ? ThemeColors.inkDim : ThemeColors.inkMid,
    );
  }
}
