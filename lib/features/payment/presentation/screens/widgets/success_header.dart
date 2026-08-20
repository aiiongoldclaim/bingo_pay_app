// import 'dart:math';
//
// import 'package:flutter/material.dart';
// import 'package:sizer/sizer.dart';
//
// import '../../../../../core/theme/app_text_styles.dart';
// import '../../../../../core/theme/theme_colors.dart';
//
// class SuccessHeader extends StatefulWidget {
//   final String orderId;
//   final String amount;
//
//   const SuccessHeader({super.key, required this.orderId, required this.amount});
//
//   @override
//   State<SuccessHeader> createState() => _SuccessHeaderState();
// }
//
// class _SuccessHeaderState extends State<SuccessHeader>
//     with TickerProviderStateMixin {
//   // Circle bounces in
//   late final AnimationController _bounceCtrl;
//   late final Animation<double> _scaleAnim;
//
//   // Two ripple rings expand + fade, repeating
//   late final AnimationController _pulseCtrl;
//   late final Animation<double> _ring1;
//   late final Animation<double> _ring2;
//
//   // Particle burst fires once
//   late final AnimationController _burstCtrl;
//   late final Animation<double> _burst;
//
//   // Text slides up + fades in
//   late final AnimationController _textCtrl;
//   late final Animation<double> _textFade;
//   late final Animation<Offset> _textSlide;
//
//   @override
//   void initState() {
//     super.initState();
//
//     _bounceCtrl = AnimationController(
//       vsync: this,
//       duration: const Duration(milliseconds: 800),
//     );
//     _scaleAnim = Tween<double>(begin: 0.0, end: 1.0).animate(
//       CurvedAnimation(parent: _bounceCtrl, curve: Curves.elasticOut),
//     );
//
//     _pulseCtrl = AnimationController(
//       vsync: this,
//       duration: const Duration(milliseconds: 2200),
//     );
//     _ring1 = Tween<double>(begin: 0.0, end: 1.0).animate(
//       CurvedAnimation(
//         parent: _pulseCtrl,
//         curve: const Interval(0.0, 0.8, curve: Curves.easeOut),
//       ),
//     );
//     _ring2 = Tween<double>(begin: 0.0, end: 1.0).animate(
//       CurvedAnimation(
//         parent: _pulseCtrl,
//         curve: const Interval(0.3, 1.0, curve: Curves.easeOut),
//       ),
//     );
//
//     _burstCtrl = AnimationController(
//       vsync: this,
//       duration: const Duration(milliseconds: 900),
//     );
//     _burst = Tween<double>(begin: 0.0, end: 1.0).animate(
//       CurvedAnimation(parent: _burstCtrl, curve: Curves.easeOut),
//     );
//
//     _textCtrl = AnimationController(
//       vsync: this,
//       duration: const Duration(milliseconds: 550),
//     );
//     _textFade = Tween<double>(begin: 0.0, end: 1.0).animate(
//       CurvedAnimation(parent: _textCtrl, curve: Curves.easeOut),
//     );
//     _textSlide = Tween<Offset>(
//       begin: const Offset(0, 0.25),
//       end: Offset.zero,
//     ).animate(CurvedAnimation(parent: _textCtrl, curve: Curves.easeOut));
//
//     // Sequence: bounce → burst + text; pulse rings loop throughout
//     _bounceCtrl.forward().then((_) {
//       _burstCtrl.forward();
//       _textCtrl.forward();
//     });
//     Future.delayed(const Duration(milliseconds: 300), () {
//       if (mounted) _pulseCtrl.repeat();
//     });
//   }
//
//   @override
//   void dispose() {
//     _bounceCtrl.dispose();
//     _pulseCtrl.dispose();
//     _burstCtrl.dispose();
//     _textCtrl.dispose();
//     super.dispose();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Padding(
//       padding: const EdgeInsets.fromLTRB(24, 0, 24, 22),
//       child: Column(
//         children: [
//           // ── Animated check circle ──────────────────────────────────
//           SizedBox(
//             width: 180,
//             height: 180,
//             child: AnimatedBuilder(
//               animation: Listenable.merge(
//                   [_bounceCtrl, _pulseCtrl, _burstCtrl]),
//               builder: (_, _) => Stack(
//                 alignment: Alignment.center,
//                 children: [
//                   // Ripple ring 1
//                   _Ring(
//                     progress: _ring1.value,
//                     maxRadius: 88,
//                     color: ThemeColors.green,
//                     strokeWidth: 2.0,
//                   ),
//
//                   // Ripple ring 2
//                   _Ring(
//                     progress: _ring2.value,
//                     maxRadius: 88,
//                     color: ThemeColors.green.withValues(alpha: 0.5),
//                     strokeWidth: 1.5,
//                   ),
//
//                   // Burst particles
//                   ..._particles(_burst.value),
//
//                   // Bouncing circle
//                   Transform.scale(
//                     scale: _scaleAnim.value,
//                     child: Container(
//                       height: 100,
//                       width: 100,
//                       decoration: BoxDecoration(
//                         shape: BoxShape.circle,
//                         color: ThemeColors.white,
//                         boxShadow: [
//                           BoxShadow(
//                             color: ThemeColors.green
//                                 .withValues(alpha: 0.5),
//                             blurRadius: 40,
//                             spreadRadius: 8,
//                           ),
//                           BoxShadow(
//                             color: ThemeColors.white
//                                 .withValues(alpha: 0.18),
//                             blurRadius: 12,
//                             spreadRadius: 2,
//                           ),
//                         ],
//                       ),
//                       child: const Icon(
//                         Icons.check_rounded,
//                         size: 60,
//                         color: ThemeColors.green,
//                       ),
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           ),
//
//           const SizedBox(height: 30),
//
//           // ── Fade + slide text ──────────────────────────────────────
//           SlideTransition(
//             position: _textSlide,
//             child: FadeTransition(
//               opacity: _textFade,
//               child: Column(
//                 children: [
//                   Text(
//                     'Payment Successful',
//                     style: AppTextStyles.headlineMedium.copyWith(
//                       color: ThemeColors.black,
//                       fontWeight: FontWeight.w700,
//                       letterSpacing: 0.2,
//                     ),
//                   ),
//                   //
//                   // Container(
//                   //   padding: const EdgeInsets.symmetric(
//                   //       horizontal: 28, vertical: 12),
//                   //   decoration: BoxDecoration(
//                   //     color: ThemeColors.white.withValues(alpha: 0.15),
//                   //     borderRadius: BorderRadius.circular(40),
//                   //     border: Border.all(
//                   //       color: ThemeColors.white.withValues(alpha: 0.28),
//                   //     ),
//                   //   ),
//                   //   child: Text(
//                   //     widget.amount,
//                   //     style: AppTextStyles.titleLarge.copyWith(
//                   //       color: ThemeColors.white,
//                   //       fontWeight: FontWeight.w800,
//                   //       fontSize: 26,
//                   //     ),
//                   //   ),
//                   // ),
//                   //
//                   // const SizedBox(height: 10),
//
//                   Text(
//                     'Order #${widget.orderId}',
//                     style: AppTextStyles.bodyLarge.copyWith(
//                       color: ThemeColors.black.withValues(alpha: 0.65),
//                       letterSpacing: 0.3,
//                       fontWeight: FontWeight.w600,
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
//
//   static const _particleColors = [
//     Color(0xFFFFD700), // gold
//     Color(0xFF69F0AE), // mint green
//     Color(0xFFFFFFFF), // white
//     Color(0xFF82B1FF), // light blue
//     Color(0xFFFF80AB), // pink
//     Color(0xFFFFE57F), // yellow
//     Color(0xFF80D8FF), // sky
//     Color(0xFFCCFF90), // lime
//   ];
//
//   List<Widget> _particles(double progress) {
//     if (progress == 0) return [];
//     const count = 8;
//
//     return List.generate(count, (i) {
//       final angle = (i / count) * 2 * pi - pi / 2;
//       final distance = progress * 78.0;
//       final opacity = (1.0 - progress).clamp(0.0, 1.0);
//       final size = 7.0 + (i % 3) * 3.0;
//
//       // Center of the 180×180 box
//       final cx = 90.0;
//       final cy = 90.0;
//
//       return Positioned(
//         left: cx + distance * cos(angle) - size / 2,
//         top: cy + distance * sin(angle) - size / 2,
//         child: Opacity(
//           opacity: opacity,
//           child: Container(
//             width: size,
//             height: size,
//             decoration: BoxDecoration(
//               shape: i.isEven ? BoxShape.circle : BoxShape.rectangle,
//               borderRadius:
//                   i.isOdd ? BorderRadius.circular(2) : null,
//               color: _particleColors[i % _particleColors.length],
//             ),
//           ),
//         ),
//       );
//     });
//   }
// }
//
// // Expanding ring widget
// class _Ring extends StatelessWidget {
//   final double progress;
//   final double maxRadius;
//   final Color color;
//   final double strokeWidth;
//
//   const _Ring({
//     required this.progress,
//     required this.maxRadius,
//     required this.color,
//     required this.strokeWidth,
//   });
//
//   @override
//   Widget build(BuildContext context) {
//     if (progress == 0) return const SizedBox.shrink();
//     final opacity = (1.0 - progress).clamp(0.0, 1.0);
//     final radius = maxRadius * progress;
//     return Opacity(
//       opacity: opacity,
//       child: Container(
//         width: radius * 2,
//         height: radius * 2,
//         decoration: BoxDecoration(
//           shape: BoxShape.circle,
//           border: Border.all(color: color, width: strokeWidth),
//         ),
//       ),
//     );
//   }
// }
import 'dart:math' as math;

import 'package:bingo_pay/features/payment/presentation/screens/widgets/payment_success_matrics.dart';
import 'package:flutter/material.dart';

import '../../../../../core/theme/app_text_styles.dart';
import '../../../../../core/theme/app_theme_colors.dart';


class SuccessHeader extends StatelessWidget {
  final String orderId;
  final String amount;

  const SuccessHeader({super.key, required this.orderId, required this.amount});

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    final m = PaymentSuccessMetrics.of(context);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          height: m.heroField,
          child: Stack(
            alignment: Alignment.center,
            children: [
              // outer glow rings
              _Ring(size: m.badgeSize * 1.85, color: c.brand.withValues(alpha: 0.06)),
              _Ring(size: m.badgeSize * 1.45, color: c.brand.withValues(alpha: 0.10)),

              _Confetti(metrics: m),

              // white badge
              Container(
                width: m.badgeSize,
                height: m.badgeSize,
                decoration: BoxDecoration(
                  color: c.surface,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: c.brand.withValues(alpha: c.isDark ? 0.30 : 0.16),
                      blurRadius: 28,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                alignment: Alignment.center,
                child: Icon(
                  Icons.check_rounded,
                  size: m.checkSize,
                  color: c.success,
                ),
              ),
            ],
          ),
        ),

        Text(
          'Payment Successful!',
          textAlign: TextAlign.center,
          style: AppTextStyles.titleLarge.copyWith(
            color: c.textPrimary,
            fontFamily: 'Inter',
            fontWeight: FontWeight.w800,
            fontSize: m.titleSize,
            height: 1.2,
          ),
        ),

        SizedBox(height: m.gapSm),

        Text(
          'Thank you! Your payment has been received.',
          textAlign: TextAlign.center,
          style: AppTextStyles.bodyMedium.copyWith(
            color: c.textSecondary,
            fontFamily: 'Inter',
            fontSize: m.subtitleSize,
            height: 1.4,
          ),
        ),

        SizedBox(height: m.gapMd),

        if (orderId.isNotEmpty) _OrderChip(orderId: orderId, metrics: m),
      ],
    );
  }
}

class _Ring extends StatelessWidget {
  final double size;
  final Color color;

  const _Ring({required this.size, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: color, width: 1.2),
      ),
    );
  }
}

/// Light confetti scatter around the badge (theme colours only).
class _Confetti extends StatelessWidget {
  final PaymentSuccessMetrics metrics;

  const _Confetti({required this.metrics});

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    final m = metrics;
    final field = m.heroField;

    // dx, dy (fraction of field, from centre), size factor, angle, colour index
    const specs = <List<double>>[
      [-0.34, -0.30, 0.030, 0.6, 0],
      [0.30, -0.36, 0.026, -0.4, 1],
      [-0.40, 0.02, 0.030, 0.9, 1],
      [0.40, 0.06, 0.026, 0.3, 2],
      [-0.28, 0.28, 0.028, -0.8, 0],
      [0.33, 0.30, 0.026, 1.1, 3],
      [0.16, -0.44, 0.022, 0.2, 3],
      [-0.14, 0.42, 0.022, -0.5, 2],
    ];

    final palette = <Color>[
      c.brand,
      c.success,
      c.brand.withValues(alpha: 0.55),
      c.warning,
    ];

    return SizedBox(
      width: field,
      height: field,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // sparkles
          _sparkle(context, -0.30, -0.22, field * 0.055),
          _sparkle(context, 0.33, -0.18, field * 0.045),
          _sparkle(context, 0.26, 0.30, field * 0.040),
          _sparkle(context, -0.24, 0.34, field * 0.035),

          // confetti chips
          ...specs.map((s) {
            return Transform.translate(
              offset: Offset(field * s[0], field * s[1]),
              child: Transform.rotate(
                angle: s[3] * math.pi,
                child: Container(
                  width: field * s[2],
                  height: field * s[2] * 0.62,
                  decoration: BoxDecoration(
                    color: palette[s[4].toInt()].withValues(alpha: 0.85),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _sparkle(BuildContext context, double dx, double dy, double size) {
    final c = context.c;
    final field = metrics.heroField;
    return Transform.translate(
      offset: Offset(field * dx, field * dy),
      child: Icon(
        Icons.auto_awesome,
        size: size,
        color: c.surface.withValues(alpha: c.isDark ? 0.35 : 0.95),
      ),
    );
  }
}

class _OrderChip extends StatelessWidget {
  final String orderId;
  final PaymentSuccessMetrics metrics;

  const _OrderChip({required this.orderId, required this.metrics});

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    final m = metrics;

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: m.gapMd,
        vertical: m.gapSm * 0.9,
      ),
      decoration: BoxDecoration(
        color: c.surface.withValues(alpha: c.isDark ? 0.10 : 0.75),
        borderRadius: BorderRadius.circular(m.chipRadius),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.receipt_long_outlined, size: m.chipIconSize, color: c.brand),
          SizedBox(width: m.gapSm * 0.8),
          Flexible(
            child: RichText(
              textAlign: TextAlign.center,
              text: TextSpan(
                style: AppTextStyles.bodyMedium.copyWith(
                  color: c.textSecondary,
                  fontFamily: 'Inter',
                  fontSize: m.chipTextSize,
                  height: 1.3,
                ),
                children: [
                  const TextSpan(text: 'Order '),
                  TextSpan(
                    text: '#$orderId',
                    style: TextStyle(
                      color: c.brand,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}