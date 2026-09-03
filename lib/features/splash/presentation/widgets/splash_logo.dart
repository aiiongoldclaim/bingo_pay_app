import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../../core/theme/theme_colors.dart';
import 'splash_metrics.dart';

class SplashLogo extends StatelessWidget {
  const SplashLogo({
    super.key,
    required this.metrics,
    required this.isDark,
    this.stacked = true,
  });

  final SplashMetrics metrics;
  final bool isDark;
  final bool stacked;

  @override
  Widget build(BuildContext context) {
    final mark = SizedBox(
      height: metrics.logoSize,
      width: metrics.logoSize,
      child: CustomPaint(painter: _VaultMarkPainter(isDark: isDark)),
    );

    if (stacked) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          mark,
          SizedBox(height: metrics.gapMd),
          _Wordmark(metrics: metrics, isDark: isDark, center: true),
        ],
      );
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        mark,
        SizedBox(width: metrics.gapXl * 0.7),
        Container(
          width: 1,
          height: metrics.dividerHeight,
          color: ThemeColors.gold1.withValues(alpha: isDark ? 0.55 : 0.45),
        ),
        SizedBox(width: metrics.gapXl * 0.7),
        Flexible(
          child: _Wordmark(metrics: metrics, isDark: isDark, center: false),
        ),
      ],
    );
  }
}

class _Wordmark extends StatelessWidget {
  const _Wordmark({
    required this.metrics,
    required this.isDark,
    required this.center,
  });

  final SplashMetrics metrics;
  final bool isDark;
  final bool center;

  @override
  Widget build(BuildContext context) {
    final gold = isDark ? ThemeColors.gold1 : ThemeColors.gold500;

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: center
          ? CrossAxisAlignment.center
          : CrossAxisAlignment.start,
      children: [
        FittedBox(
          fit: BoxFit.scaleDown,
          child: RichText(
            text: TextSpan(
              style: TextStyle(
                fontSize: metrics.wordmarkSize,
                fontWeight: FontWeight.w400,
                height: 1.05,
                letterSpacing: -0.5,
              ),
              children: [
                TextSpan(
                  text: 'The',
                  style: TextStyle(
                    color: isDark ? ThemeColors.white : ThemeColors.navyDark,
                  ),
                ),
                TextSpan(
                  text: 'Vaults',
                  style: TextStyle(color: gold),
                ),
              ],
            ),
          ),
        ),
        SizedBox(height: metrics.gapMd * 0.5),
        Text(
          'SECURE. GROW. PROSPER.',
          textAlign: center ? TextAlign.center : TextAlign.left,
          style: TextStyle(
            fontSize: metrics.taglineSize,
            letterSpacing: metrics.taglineSpacing,
            fontWeight: FontWeight.w500,
            color: isDark ? ThemeColors.white : ThemeColors.navyDark,
          ),
        ),
      ],
    );
  }
}

/// Gold vault door — half circle + dial + door edge with hinges.
class _VaultMarkPainter extends CustomPainter {
  _VaultMarkPainter({required this.isDark});

  final bool isDark;

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final stroke = w * 0.035;

    final gold = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: isDark
            ? const [ThemeColors.goldLight, ThemeColors.gold1]
            : const [ThemeColors.goldLight, ThemeColors.gold500],
      ).createShader(Offset.zero & size)
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke
      ..strokeCap = StrokeCap.round;

    final center = Offset(w * 0.42, h * 0.5);
    final radius = w * 0.36;

    // outer half-circle (left side open arc)
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      1.5708,
      3.1416,
      false,
      gold,
    );

    // dial ring
    canvas.drawCircle(center, radius * 0.42, gold..strokeWidth = stroke);

    // dial spokes
    final spoke = Paint()
      ..color = isDark ? ThemeColors.gold1 : ThemeColors.gold500
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke * 0.7
      ..strokeCap = StrokeCap.round;

    for (var i = 0; i < 8; i++) {
      final a = i * 0.7854;
      canvas.drawLine(
        Offset(
          center.dx + radius * 0.14 * _cos(a),
          center.dy + radius * 0.14 * _sin(a),
        ),
        Offset(
          center.dx + radius * 0.40 * _cos(a),
          center.dy + radius * 0.40 * _sin(a),
        ),
        spoke,
      );
    }

    // dial hub
    canvas.drawCircle(
      center,
      stroke * 0.9,
      Paint()..color = isDark ? ThemeColors.gold1 : ThemeColors.gold500,
    );

    // door edge (vertical bar)
    final barLeft = w * 0.62;
    final barRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(barLeft, h * 0.14, w * 0.085, h * 0.72),
      Radius.circular(w * 0.012),
    );
    canvas.drawRRect(
      barRect,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: isDark
              ? const [ThemeColors.gold100, ThemeColors.gold1]
              : const [ThemeColors.goldLight, ThemeColors.gold500],
        ).createShader(barRect.outerRect),
    );

    // hinges
    final hinge = Paint()
      ..color = isDark ? ThemeColors.gold1 : ThemeColors.gold500;
    for (final f in [0.30, 0.50, 0.70]) {
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(barLeft + w * 0.085, h * f, w * 0.055, h * 0.055),
          Radius.circular(w * 0.008),
        ),
        hinge,
      );
    }
  }

  double _cos(double a) => math.cos(a);
  double _sin(double a) => math.sin(a);

  @override
  bool shouldRepaint(_VaultMarkPainter old) => old.isDark != isDark;
}
