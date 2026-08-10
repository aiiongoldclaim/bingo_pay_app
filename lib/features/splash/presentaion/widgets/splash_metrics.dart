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
    required this.iconBoxSize,
    required this.iconSize,
    required this.iconGap,
    required this.dividerHeight,
    required this.progressWidth,
    required this.progressHeight,
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
  final double iconBoxSize;
  final double iconSize;
  final double iconGap;
  final double dividerHeight;
  final double progressWidth;
  final double progressHeight;
  final double gapMd;
  final double gapXl;
  final double bottomGap;

  factory SplashMetrics.of(BuildContext context, BoxConstraints c) {
    final size = MediaQuery.sizeOf(context);
    final shortest = size.shortestSide;
    final isTablet = shortest >= 540;
    final isLandscape = c.maxWidth > c.maxHeight;

    if (isTablet) {
      return SplashMetrics(
        isTablet: true,
        isLandscape: isLandscape,
        maxContentWidth: isLandscape ? 900 : 620,
        hPadding: 48,
        logoSize: 220,
        wordmarkSize: 64,
        taglineSize: 18,
        taglineSpacing: 5,
        iconBoxSize: 64,
        iconSize: 32,
        iconGap: 20,
        dividerHeight: 40,
        progressWidth: 220,
        progressHeight: 5,
        gapMd: 20,
        gapXl: 40,
        bottomGap: 48,
      );
    }

    return SplashMetrics(
      isTablet: false,
      isLandscape: isLandscape,
      maxContentWidth: 480,
      hPadding: 24,
      logoSize: 140,
      wordmarkSize: 40,
      taglineSize: 12,
      taglineSpacing: 3.5,
      iconBoxSize: 44,
      iconSize: 22,
      iconGap: 12,
      dividerHeight: 28,
      progressWidth: 140,
      progressHeight: 4,
      gapMd: 12,
      gapXl: 28,
      bottomGap: 28,
    );
  }
}
