// ─────────────────────────────────────────────────────────────────────────
// ORIGINAL — the Auctions-screen hero's plain text-row countdown ("colon
// separated" DAY : HRS : MIN : SEC), kept for reference. The redesigned
// hero card renders the same live countdown as four boxed tiles instead —
// see the active HeroCountdown implementation below.
// ─────────────────────────────────────────────────────────────────────────
//
// import 'dart:async';
//
// import 'package:flutter/material.dart';
//
// import '../../../../core/theme/app_theme_colors.dart';
//
// class HeroCountdown extends StatefulWidget {
//   final int secondsRemaining;
//
//   const HeroCountdown({
//     super.key,
//     required this.secondsRemaining,
//   });
//
//   @override
//   State<HeroCountdown> createState() => _HeroCountdownState();
// }
//
// class _HeroCountdownState extends State<HeroCountdown> {
//   Timer? _timer;
//
//   late int _remaining;
//
//   @override
//   void initState() {
//     super.initState();
//
//     _remaining = widget.secondsRemaining;
//
//     _startTimer();
//   }
//
//   @override
//   void didUpdateWidget(covariant HeroCountdown oldWidget) {
//     super.didUpdateWidget(oldWidget);
//
//     if (oldWidget.secondsRemaining != widget.secondsRemaining) {
//       _remaining = widget.secondsRemaining;
//
//       _startTimer();
//     }
//   }
//
//   void _startTimer() {
//     _timer?.cancel();
//
//     _timer = Timer.periodic(
//       const Duration(seconds: 1),
//       (_) {
//         if (!mounted) return;
//
//         if (_remaining <= 0) {
//           _timer?.cancel();
//
//           setState(() {
//             _remaining = 0;
//           });
//
//           return;
//         }
//
//         setState(() {
//           _remaining--;
//         });
//       },
//     );
//   }
//
//   @override
//   void dispose() {
//     _timer?.cancel();
//
//     super.dispose();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     final colors = context.colors;
//     final duration = Duration(seconds: _remaining);
//
//     final days = duration.inDays;
//     final hours = duration.inHours % 24;
//     final minutes = duration.inMinutes % 60;
//     final seconds = duration.inSeconds % 60;
//
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Text(
//           'CLOSES IN',
//           style: TextStyle(
//             color: colors.onHeroBanner.withValues(alpha: 0.54),
//             fontSize: 10,
//             letterSpacing: 1.5,
//             fontWeight: FontWeight.w600,
//           ),
//         ),
//
//         const SizedBox(height: 6),
//
//         Row(
//           children: [
//             _TimeValue(
//               value: days,
//               label: 'DAY',
//             ),
//             const _Colon(),
//             _TimeValue(
//               value: hours,
//               label: 'HRS',
//             ),
//             const _Colon(),
//             _TimeValue(
//               value: minutes,
//               label: 'MIN',
//             ),
//             const _Colon(),
//             _TimeValue(
//               value: seconds,
//               label: 'SEC',
//             ),
//           ],
//         ),
//       ],
//     );
//   }
// }
//
// class _TimeValue extends StatelessWidget {
//   final int value;
//   final String label;
//
//   const _TimeValue({
//     required this.value,
//     required this.label,
//   });
//
//   @override
//   Widget build(BuildContext context) {
//     final colors = context.colors;
//
//     return Column(
//       children: [
//         Text(
//           value.toString().padLeft(2, '0'),
//           style: TextStyle(
//             color: colors.onHeroBanner,
//             fontSize: 24,
//             fontWeight: FontWeight.w600,
//           ),
//         ),
//         Text(
//           label,
//           style: TextStyle(
//             color: colors.onHeroBanner.withValues(alpha: 0.54),
//             fontSize: 8,
//             letterSpacing: 1,
//           ),
//         ),
//       ],
//     );
//   }
// }
//
// class _Colon extends StatelessWidget {
//   const _Colon();
//
//   @override
//   Widget build(BuildContext context) {
//     final colors = context.colors;
//
//     return Padding(
//       padding: const EdgeInsets.symmetric(horizontal: 5),
//       child: Text(
//         ':',
//         style: TextStyle(
//           color: colors.onHeroBanner.withValues(alpha: 0.38),
//           fontSize: 22,
//         ),
//       ),
//     );
//   }
// }

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../../core/theme/app_theme_colors.dart';

class HeroCountdown extends StatefulWidget {
  final int secondsRemaining;

  const HeroCountdown({
    super.key,
    required this.secondsRemaining,
  });

  @override
  State<HeroCountdown> createState() => _HeroCountdownState();
}

class _HeroCountdownState extends State<HeroCountdown> {
  Timer? _timer;

  late int _remaining;

  @override
  void initState() {
    super.initState();

    _remaining = widget.secondsRemaining;

    _startTimer();
  }

  @override
  void didUpdateWidget(covariant HeroCountdown oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.secondsRemaining != widget.secondsRemaining) {
      _remaining = widget.secondsRemaining;

      _startTimer();
    }
  }

  void _startTimer() {
    _timer?.cancel();

    _timer = Timer.periodic(
      const Duration(seconds: 1),
      (_) {
        if (!mounted) return;

        if (_remaining <= 0) {
          _timer?.cancel();

          setState(() {
            _remaining = 0;
          });

          return;
        }

        setState(() {
          _remaining--;
        });
      },
    );
  }

  @override
  void dispose() {
    _timer?.cancel();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final duration = Duration(seconds: _remaining);

    final days = duration.inDays;
    final hours = duration.inHours % 24;
    final minutes = duration.inMinutes % 60;
    final seconds = duration.inSeconds % 60;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Closes in',
          style: TextStyle(
            color: colors.textSecondary,
            fontSize: 13.sp,
            fontWeight: FontWeight.w600,
          ),
        ),

        SizedBox(height: 0.71.h),

        Row(
          children: [
            Expanded(child: _CountdownTile(value: days, label: 'DAY')),
            SizedBox(width: 1.03.w),
            Expanded(child: _CountdownTile(value: hours, label: 'HRS')),
            SizedBox(width: 1.03.w),
            Expanded(child: _CountdownTile(value: minutes, label: 'MIN')),
            SizedBox(width: 1.03.w),
            Expanded(child: _CountdownTile(value: seconds, label: 'SEC')),
          ],
        ),
      ],
    );
  }
}

class _CountdownTile extends StatelessWidget {
  final int value;
  final String label;

  const _CountdownTile({
    required this.value,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Container(
      padding: EdgeInsets.symmetric(vertical: 0.71.h),
      decoration: BoxDecoration(
        color: colors.brandSoft,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              value.toString().padLeft(2, '0'),
              style: TextStyle(
                color: colors.textPrimary,
                fontSize: 17.sp,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              label,
              style: TextStyle(
                color: colors.textMuted,
                fontSize: 11.sp,
                letterSpacing: 0.5,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
