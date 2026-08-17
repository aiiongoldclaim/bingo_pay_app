import 'package:flutter/cupertino.dart';

class SplashMetrics {
  const SplashMetrics({
    required this.isTablet,
    required this.isLandscape,
    required this.maxContentWidth,
    required this.hPadding,
    required this.logoSize,
    required this.wordmarkSize,
    required this.taglineSize,
    required this.taglineSpacing,
    required this.dividerHeight,
    required this.gapMd,
    required this.gapXl,
    required this.bottomGap,
  });

  final bool isTablet;
  final bool isLandscape;
  final double maxContentWidth;
  final double hPadding;
  final double logoSize;
  final double wordmarkSize;
  final double taglineSize;
  final double taglineSpacing;
  final double dividerHeight;
  final double gapMd;
  final double gapXl;
  final double bottomGap;

  factory SplashMetrics.of(BuildContext context, BoxConstraints c) {
    final size = MediaQuery.sizeOf(context);
    final isTablet = size.shortestSide >= 540;
    final isLandscape = c.maxWidth > c.maxHeight;

    if (isTablet) {
      return SplashMetrics(
        isTablet: true,
        isLandscape: isLandscape,
        maxContentWidth: isLandscape ? 860 : 560,
        hPadding: 48,
        logoSize: isLandscape ? 190 : 220,
        wordmarkSize: isLandscape ? 60 : 56,
        taglineSize: isLandscape ? 17 : 16,
        taglineSpacing: 4.5,
        dividerHeight: 96,
        gapMd: 22,
        gapXl: 40,
        bottomGap: 48,
      );
    }

    return SplashMetrics(
      isTablet: false,
      isLandscape: isLandscape,
      maxContentWidth: 420,
      hPadding: 24,
      logoSize: isLandscape ? 120 : 160,
      wordmarkSize: isLandscape ? 38 : 42,
      taglineSize: 12,
      taglineSpacing: 3.5,
      dividerHeight: 64,
      gapMd: 16,
      gapXl: 28,
      bottomGap: 28,
    );
  }
}
