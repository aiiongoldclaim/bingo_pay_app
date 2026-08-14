// import 'package:flutter/material.dart';
// import 'package:sizer/sizer.dart';
// import 'package:bingo_pay/core/theme/theme_colors.dart';
// import 'package:bingo_pay/core/theme/app_text_styles.dart';
//
// enum TrackingStatus { completed, current, pending }
//
// class TrackingStep {
//   final String title;
//   final String subtitle;
//   final TrackingStatus stepStatus;
//   final bool isError;
//
//   const TrackingStep({
//     required this.title,
//     required this.subtitle,
//     required this.stepStatus,
//     this.isError = false,
//   });
// }
//
// class TrackingTimeline extends StatelessWidget {
//   final List<TrackingStep> steps;
//
//   const TrackingTimeline({super.key, required this.steps});
//
//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       padding: EdgeInsets.all(4.w),
//       decoration: BoxDecoration(
//         color: ThemeColors.surface,
//         borderRadius: BorderRadius.circular(18),
//         border: Border.all(color: ThemeColors.line),
//       ),
//       child: Column(
//         children: List.generate(steps.length, (index) {
//           final step = steps[index];
//           final isLast = index == steps.length - 1;
//           return _TrackingStepRow(step: step, isLast: isLast);
//         }),
//       ),
//     );
//   }
// }
//
// class _TrackingStepRow extends StatelessWidget {
//   final TrackingStep step;
//   final bool isLast;
//
//   const _TrackingStepRow({required this.step, required this.isLast});
//
//   @override
//   Widget build(BuildContext context) {
//     final isDone = step.stepStatus == TrackingStatus.completed;
//     final isCurrent = step.stepStatus == TrackingStatus.current;
//     final isPending = step.stepStatus == TrackingStatus.pending;
//
//     final dotColor = step.isError
//         ? ThemeColors.red
//         : isDone
//         ? ThemeColors.green
//         : isCurrent
//         ? ThemeColors.blue
//         : ThemeColors.line;
//
//     final lineColor = step.isError
//         ? ThemeColors.red
//         : isDone
//         ? ThemeColors.green
//         : ThemeColors.line;
//
//     return IntrinsicHeight(
//       child: Row(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           /// ── Dot + Line ──
//           SizedBox(
//             width: 6.w,
//             child: Column(
//               children: [
//                 /// Dot
//                 Container(
//                   width: 4.w,
//                   height: 4.w,
//                   decoration: BoxDecoration(
//                     shape: BoxShape.circle,
//                     color: (isDone || isCurrent || step.isError)
//                         ? dotColor
//                         : Colors.transparent,
//                     border: isPending && !step.isError
//                         ? Border.all(color: ThemeColors.line, width: 1.5)
//                         : null,
//                   ),
//                   child: step.isError
//                       ? const Icon(Icons.close, size: 10, color: ThemeColors.white)
//                       : null,
//                 ),
//
//                 /// Line below dot
//                 if (!isLast)
//                   Expanded(
//                     child: Container(
//                       width: 2,
//                       color: lineColor,
//                       margin: EdgeInsets.symmetric(vertical: 0.4.h),
//                     ),
//                   ),
//               ],
//             ),
//           ),
//
//           SizedBox(width: 3.w),
//
//           /// ── Text ──
//           Expanded(
//             child: Padding(
//               padding: EdgeInsets.only(bottom: isLast ? 0 : 2.h),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Text(
//                     step.title,
//                     style: AppTextStyles.bodyMedium.copyWith(
//                       fontSize: 15.sp,
//                       fontWeight: isCurrent ? FontWeight.bold : FontWeight.w600,
//                       color: step.isError
//                           ? ThemeColors.red
//                           : isPending
//                           ? ThemeColors.inkDim
//                           : ThemeColors.ink,
//                     ),
//                   ),
//                   Text(
//                     step.subtitle,
//                     style: AppTextStyles.bodySmall.copyWith(
//                       fontSize: 14.sp,
//                       color: ThemeColors.inkDim,
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
// }
import 'package:flutter/material.dart';

import '../../../../core/theme/app_theme_colors.dart';
import 'order_details_metrics.dart';

class OdTrackingCard extends StatelessWidget {
  const OdTrackingCard({
    super.key,
    required this.metrics,
    required this.steps,
    required this.illustrationAsset,
  });

  final OrderDetailMetrics metrics;
  final List<TrackingStep> steps;
  final String illustrationAsset;

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    final m = metrics;
    if (steps.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: m.pagePadding),
      child: Container(
        padding: EdgeInsets.all(m.cardPadding),
        decoration: BoxDecoration(
          color: c.surface,
          borderRadius: BorderRadius.circular(m.cardRadius),
          border: Border.all(color: c.border),
        ),
        clipBehavior: Clip.antiAlias,
        child: Stack(
          children: [
            // Illustration — timeline ke peeche, right-bottom
            Positioned(
              right: -m.cardPadding * 0.5,
              bottom: -m.cardPadding * 0.5,
              child: SizedBox(
                width: m.illustrationWidth,
                child: Opacity(
                  opacity: c.isDark ? 0.65 : 1,
                  child: Image.asset(
                    illustrationAsset,
                    fit: BoxFit.contain,
                    errorBuilder: (_, __, ___) => const SizedBox.shrink(),
                  ),
                ),
              ),
            ),
            ConstrainedBox(
              // Illustration ke upar text na chade
              constraints: BoxConstraints(
                maxWidth: m.isPhone ? double.infinity : 520,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: List.generate(steps.length, (i) {
                  return _TimelineRow(
                    metrics: m,
                    step: steps[i],
                    isFirst: i == 0,
                    isLast: i == steps.length - 1,
                    nextStep: i + 1 < steps.length ? steps[i + 1] : null,
                  );
                }),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TimelineRow extends StatelessWidget {
  const _TimelineRow({
    required this.metrics,
    required this.step,
    required this.isFirst,
    required this.isLast,
    this.nextStep,
  });

  final OrderDetailMetrics metrics;
  final TrackingStep step;
  final bool isFirst;
  final bool isLast;
  final TrackingStep? nextStep;

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    final m = metrics;

    final errorColor = const Color(0xFFE0533B);
    final done = step.stepStatus == TrackingStatus.completed;
    final current = step.stepStatus == TrackingStatus.current;

    final Color dotColor = step.isError
        ? errorColor
        : done
        ? c.brand
        : current
        ? c.brand
        : c.border;

    // Rail ka rang next step ki state se — pending tak pahunchte hi grey
    final railColor = (nextStep?.stepStatus == TrackingStatus.pending)
        ? c.border
        : c.brand;

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            children: [
              _Dot(
                metrics: m,
                color: dotColor,
                filled: done || step.isError,
                ring: current,
                isError: step.isError,
              ),
              if (!isLast)
                Expanded(
                  child: Container(width: m.railWidth, color: railColor),
                ),
            ],
          ),
          SizedBox(width: m.cardPadding * 0.7),
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(bottom: isLast ? 0 : m.stepGap * 0.55),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    step.title,
                    style: TextStyle(
                      fontSize: m.stepTitleSize,
                      fontWeight: FontWeight.w700,
                      height: 1.25,
                      color: step.isError
                          ? errorColor
                          : (done || current)
                          ? c.textPrimary
                          : c.textSecondary,
                    ),
                  ),
                  SizedBox(height: m.cardPadding * 0.15),
                  Text(
                    step.subtitle,
                    style: TextStyle(
                      fontSize: m.stepBodySize,
                      height: 1.35,
                      fontWeight: current ? FontWeight.w600 : FontWeight.w400,
                      color: step.isError
                          ? errorColor
                          : current
                          ? c.brand
                          : c.textSecondary,
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

class _Dot extends StatelessWidget {
  const _Dot({
    required this.metrics,
    required this.color,
    required this.filled,
    required this.ring,
    required this.isError,
  });

  final OrderDetailMetrics metrics;
  final Color color;
  final bool filled;
  final bool ring;
  final bool isError;

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    final m = metrics;

    return Container(
      width: m.dotSize,
      height: m.dotSize,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: filled ? color : c.surface,
        shape: BoxShape.circle,
        border: Border.all(color: color, width: filled ? 0 : 2),
      ),
      child: filled
          ? Icon(
              isError ? Icons.close_rounded : Icons.check_rounded,
              size: m.dotSize * 0.6,
              color: Colors.white,
            )
          : ring
          ? Container(
              width: m.dotInnerSize,
              height: m.dotInnerSize,
              decoration: BoxDecoration(color: color, shape: BoxShape.circle),
            )
          : null,
    );
  }
}

enum TrackingStatus { completed, current, pending }

class TrackingStep {
  final String title;
  final String subtitle;
  final TrackingStatus stepStatus;
  final bool isError;

  const TrackingStep({
    required this.title,
    required this.subtitle,
    required this.stepStatus,
    this.isError = false,
  });
}
