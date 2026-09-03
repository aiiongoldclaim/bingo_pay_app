import 'dart:math' as math;
import 'package:flutter/material.dart';

import '../../../../core/theme/theme_colors.dart';
import 'splash_metrics.dart';

class SplashBackground extends StatelessWidget {
  const SplashBackground({
    super.key,
    required this.metrics,
    required this.isDark,
  });

  final SplashMetrics metrics;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: isDark
                  ? const [
                      ThemeColors.scaffoldDarkTop,
                      ThemeColors.ink,
                      ThemeColors.heroGradBottom,
                    ]
                  : const [
                      ThemeColors.surface,
                      ThemeColors.background,
                      ThemeColors.blueSoft,
                    ],
            ),
          ),
        ),
        Positioned.fill(
          child: CustomPaint(
            painter: _OrbitPainter(isDark: isDark, radius: metrics.logoSize),
          ),
        ),
        Positioned(
          left: 0,
          right: 0,
          bottom: 0,
          child: CustomPaint(
            size: Size(double.infinity, metrics.isTablet ? 320 : 220),
            painter: _WavePainter(isDark: isDark),
          ),
        ),
      ],
    );
  }
}

class _OrbitPainter extends CustomPainter {
  _OrbitPainter({required this.isDark, required this.radius});

  final bool isDark;
  final double radius;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height * 0.36);

    final ringPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1
      ..color = (isDark ? ThemeColors.blue : ThemeColors.blueDeep).withValues(
        alpha: isDark ? 0.22 : 0.10,
      );

    for (var i = 1; i <= 3; i++) {
      canvas.drawCircle(center, radius * (0.85 + i * 0.32), ringPaint);
    }

    final dotPaint = Paint()
      ..color = (isDark ? ThemeColors.blue : ThemeColors.blueDeep).withValues(
        alpha: isDark ? 0.85 : 0.22,
      );

    const dotAngles = [-0.35, 0.6, 1.9, 2.7, 3.6, 4.8, 5.6];
    for (var i = 0; i < dotAngles.length; i++) {
      final r = radius * (0.9 + (i % 3) * 0.35);
      final a = dotAngles[i];
      canvas.drawCircle(
        Offset(center.dx + math.cos(a) * r, center.dy + math.sin(a) * r),
        i.isEven ? 3 : 2,
        dotPaint,
      );
    }
  }

  @override
  bool shouldRepaint(_OrbitPainter old) =>
      old.isDark != isDark || old.radius != radius;
}

class _WavePainter extends CustomPainter {
  _WavePainter({required this.isDark});

  final bool isDark;

  @override
  void paint(Canvas canvas, Size size) {
    void wave(double yFactor, Color color, double amp) {
      final path = Path()
        ..moveTo(0, size.height * yFactor)
        ..cubicTo(
          size.width * 0.25,
          size.height * yFactor - amp,
          size.width * 0.65,
          size.height * yFactor + amp,
          size.width,
          size.height * yFactor - amp * 0.4,
        )
        ..lineTo(size.width, size.height)
        ..lineTo(0, size.height)
        ..close();

      canvas.drawPath(path, Paint()..color = color);
    }

    if (isDark) {
      wave(0.35, ThemeColors.heroGradTop.withValues(alpha: 0.45), 40);
      wave(0.62, ThemeColors.blueDeep.withValues(alpha: 0.55), 34);
    } else {
      wave(0.35, ThemeColors.blueSoft.withValues(alpha: 0.75), 40);
      wave(0.62, ThemeColors.blueSoft, 34);
    }
  }

  @override
  bool shouldRepaint(_WavePainter old) => old.isDark != isDark;
}
