// import 'package:bingo_pay/features/splash/presentaion/widgets/splash_metrics.dart';
// import 'package:flutter/material.dart';
// import '../../../../core/theme/theme_colors.dart';
//
// class SplashProgressBar extends StatefulWidget {
//   const SplashProgressBar({
//     super.key,
//     required this.metrics,
//     required this.isDark,
//   });
//
//   final SplashMetrics metrics;
//   final bool isDark;
//
//   @override
//   State<SplashProgressBar> createState() => _SplashProgressBarState();
// }
//
// class _SplashProgressBarState extends State<SplashProgressBar>
//     with SingleTickerProviderStateMixin {
//   late final AnimationController _controller = AnimationController(
//     vsync: this,
//     duration: const Duration(milliseconds: 2200),
//   )..repeat(reverse: true);
//
//   @override
//   void dispose() {
//     _controller.dispose();
//     super.dispose();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     final m = widget.metrics;
//
//     return ClipRRect(
//       borderRadius: BorderRadius.circular(m.progressHeight),
//       child: SizedBox(
//         width: m.progressWidth,
//         height: m.progressHeight,
//         child: Stack(
//           children: [
//             Container(
//               color: (widget.isDark ? ThemeColors.white : ThemeColors.ink)
//                   .withValues(alpha: widget.isDark ? 0.16 : 0.10),
//             ),
//             AnimatedBuilder(
//               animation: _controller,
//               builder: (context, _) {
//                 return FractionallySizedBox(
//                   alignment: Alignment.centerLeft,
//                   widthFactor: 0.25 + _controller.value * 0.45,
//                   child: DecoratedBox(
//                     decoration: BoxDecoration(
//                       gradient: ThemeColors.primaryGradient,
//                       borderRadius: BorderRadius.circular(m.progressHeight),
//                     ),
//                   ),
//                 );
//               },
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
