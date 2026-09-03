import 'package:flutter/material.dart';

class OnboardingMetrics {
  const OnboardingMetrics({
    required this.isRow,
    required this.imageWidth,
    required this.imageHeight,
    required this.title,
    required this.subtitle,
    required this.buttonHeight,
    required this.buttonWidth,
    required this.buttonFont,
    required this.dotSize,
    required this.hPad,
    required this.gapImage,
    required this.gapTitle,
    required this.bottomGap,
    required this.skipFont,
  });

  /// true = text left + image right (landscape)
  final bool isRow;

  final double imageWidth;
  final double imageHeight;
  final double title;
  final double subtitle;
  final double buttonHeight;
  final double buttonWidth;
  final double buttonFont;
  final double dotSize;
  final double hPad;
  final double gapImage;
  final double gapTitle;
  final double bottomGap;
  final double skipFont;

  /// Tablet breakpoint, in logical pixels of the shortest side — matches
  /// SplashMetrics so the two features agree on what counts as a tablet.
  static const double _tabletBreakpoint = 540;

  factory OnboardingMetrics.of(BuildContext context, BoxConstraints b) {
    final w = b.maxWidth;
    final h = b.maxHeight;

    // Derived from the live constraints/MediaQuery on every call, so this
    // stays correct across rotation, resize and split-screen — no reliance
    // on ResponsiveUtils' process-global state.
    final isLandscape = w > h;
    final isTablet =
        MediaQuery.sizeOf(context).shortestSide >= _tabletBreakpoint;

    // ── Tablet landscape ──
    if (isTablet && isLandscape) {
      return OnboardingMetrics(
        isRow: true,
        imageWidth: w * 0.42,
        imageHeight: h * 0.62,
        title: (w * 0.032).clamp(28, 46),
        subtitle: (w * 0.012).clamp(13, 18),
        buttonHeight: 46,
        buttonWidth: 130,
        buttonFont: 14,
        dotSize: 8,
        hPad: w * 0.045,
        gapImage: 24,
        gapTitle: 14,
        bottomGap: 14,
        skipFont: (w * 0.016).clamp(16, 22),
      );
    }

    // ── Tablet portrait ──
    if (isTablet) {
      return OnboardingMetrics(
        isRow: false,
        imageWidth: w * 0.72,
        imageHeight: h * 0.42,
        title: (w * 0.052).clamp(26, 40),
        subtitle: (w * 0.022).clamp(13, 18),
        buttonHeight: 46,
        buttonWidth: 120,
        buttonFont: 14,
        dotSize: 8,
        hPad: w * 0.07,
        gapImage: 26,
        gapTitle: 14,
        bottomGap: 18,
        skipFont: (w * 0.026).clamp(16, 22),
      );
    }

    // ── Phone landscape ──
    if (isLandscape) {
      return OnboardingMetrics(
        isRow: true,
        imageWidth: w * 0.40,
        imageHeight: h * 0.60,
        title: (w * 0.038).clamp(20, 30),
        subtitle: (w * 0.018).clamp(11, 14),
        buttonHeight: 40,
        buttonWidth: 108,
        buttonFont: 13,
        dotSize: 7,
        hPad: w * 0.05,
        gapImage: 16,
        gapTitle: 8,
        bottomGap: 8,
        skipFont: 14,
      );
    }

    // ── Phone portrait ──
    return OnboardingMetrics(
      isRow: false,
      imageWidth: w * 0.82,
      imageHeight: h * 0.38,
      title: (w * 0.068).clamp(22, 30),
      subtitle: (w * 0.033).clamp(12, 15),
      buttonHeight: 44,
      buttonWidth: 112,
      buttonFont: 13,
      dotSize: 7,
      hPad: 20,
      gapImage: 18,
      gapTitle: 10,
      bottomGap: 12,
      skipFont: 14,
    );
  }
}
