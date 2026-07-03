import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import 'package:bingo_pay/core/theme/theme_colors.dart';
import 'package:bingo_pay/core/theme/app_text_styles.dart';

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

class TrackingTimeline extends StatelessWidget {
  final List<TrackingStep> steps;

  const TrackingTimeline({super.key, required this.steps});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: ThemeColors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: ThemeColors.line),
      ),
      child: Column(
        children: List.generate(steps.length, (index) {
          final step = steps[index];
          final isLast = index == steps.length - 1;
          return _TrackingStepRow(step: step, isLast: isLast);
        }),
      ),
    );
  }
}

class _TrackingStepRow extends StatelessWidget {
  final TrackingStep step;
  final bool isLast;

  const _TrackingStepRow({required this.step, required this.isLast});

  @override
  Widget build(BuildContext context) {
    final isDone = step.stepStatus == TrackingStatus.completed;
    final isCurrent = step.stepStatus == TrackingStatus.current;
    final isPending = step.stepStatus == TrackingStatus.pending;

    final dotColor = step.isError
        ? ThemeColors.red
        : isDone
        ? ThemeColors.green
        : isCurrent
        ? ThemeColors.blue
        : ThemeColors.line;

    final lineColor = step.isError
        ? ThemeColors.red
        : isDone
        ? ThemeColors.green
        : ThemeColors.line;

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /// ── Dot + Line ──
          SizedBox(
            width: 6.w,
            child: Column(
              children: [
                /// Dot
                Container(
                  width: 4.w,
                  height: 4.w,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: (isDone || isCurrent || step.isError)
                        ? dotColor
                        : Colors.transparent,
                    border: isPending && !step.isError
                        ? Border.all(color: ThemeColors.line, width: 1.5)
                        : null,
                  ),
                  child: step.isError
                      ? const Icon(Icons.close, size: 10, color: ThemeColors.white)
                      : null,
                ),

                /// Line below dot
                if (!isLast)
                  Expanded(
                    child: Container(
                      width: 2,
                      color: lineColor,
                      margin: EdgeInsets.symmetric(vertical: 0.4.h),
                    ),
                  ),
              ],
            ),
          ),

          SizedBox(width: 3.w),

          /// ── Text ──
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(bottom: isLast ? 0 : 2.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    step.title,
                    style: AppTextStyles.bodyMedium.copyWith(
                      fontSize: 15.sp,
                      fontWeight: isCurrent ? FontWeight.bold : FontWeight.w600,
                      color: step.isError
                          ? ThemeColors.red
                          : isPending
                          ? ThemeColors.inkDim
                          : ThemeColors.ink,
                    ),
                  ),
                  Text(
                    step.subtitle,
                    style: AppTextStyles.bodySmall.copyWith(
                      fontSize: 13.sp,
                      color: ThemeColors.inkDim,
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
