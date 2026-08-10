import 'package:bingo_pay/features/splash/presentaion/widgets/splash_metrics.dart';
import 'package:flutter/material.dart';
import '../../../../core/theme/theme_colors.dart';

class SplashLogo extends StatelessWidget {
  const SplashLogo({super.key, required this.metrics, required this.isDark});

  final SplashMetrics metrics;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          height: metrics.logoSize,
          width: metrics.logoSize,
          child: CustomPaint(painter: _BingoMarkPainter()),
        ),
        SizedBox(height: metrics.gapMd),
        _Wordmark(metrics: metrics, isDark: isDark),
        SizedBox(height: metrics.gapMd * 0.6),
        Text(
          'PAYMENTS MADE SIMPLE',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: metrics.taglineSize,
            letterSpacing: metrics.taglineSpacing,
            fontWeight: FontWeight.w500,
            color: isDark ? ThemeColors.gold1 : ThemeColors.ink,
          ),
        ),
      ],
    );
  }
}

class _Wordmark extends StatelessWidget {
  const _Wordmark({required this.metrics, required this.isDark});

  final SplashMetrics metrics;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return FittedBox(
      fit: BoxFit.scaleDown,
      child: RichText(
        text: TextSpan(
          style: TextStyle(
            fontSize: metrics.wordmarkSize,
            fontWeight: FontWeight.w700,
            height: 1.05,
            letterSpacing: -0.5,
          ),
          children: [
            TextSpan(
              text: 'the ',
              style: TextStyle(
                color: isDark ? ThemeColors.white : ThemeColors.textDark,
              ),
            ),
            const TextSpan(
              text: 'vaults',
              style: TextStyle(color: ThemeColors.blue),
            ),
          ],
        ),
      ),
    );
  }
}

class _BingoMarkPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final stroke = size.width * 0.185;

    final paint = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [Color(0xFF2B8BF2), ThemeColors.blue, Color(0xFF3B1FD6)],
      ).createShader(rect)
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = stroke;

    // vertical stem of "b"
    canvas.drawLine(
      Offset(size.width * 0.20, size.height * 0.08),
      Offset(size.width * 0.20, size.height * 0.86),
      paint,
    );

    // bowl of "b"
    final bowl = Rect.fromCircle(
      center: Offset(size.width * 0.545, size.height * 0.60),
      radius: size.width * 0.345,
    );
    canvas.drawArc(bowl, -1.75, 5.6, false, paint);

    // play triangle
    final tri = Path()
      ..moveTo(size.width * 0.475, size.height * 0.46)
      ..lineTo(size.width * 0.755, size.height * 0.605)
      ..lineTo(size.width * 0.475, size.height * 0.755)
      ..close();

    canvas.drawPath(
      tri,
      Paint()
        ..shader = const LinearGradient(
          colors: [Color(0xFF3AA0FF), ThemeColors.blue],
        ).createShader(rect)
        ..style = PaintingStyle.stroke
        ..strokeWidth = stroke * 0.62
        ..strokeJoin = StrokeJoin.round,
    );
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
