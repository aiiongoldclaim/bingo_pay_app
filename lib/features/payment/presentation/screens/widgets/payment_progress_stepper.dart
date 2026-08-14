// import 'package:flutter/material.dart';
// import '../../../../../core/theme/app_text_styles.dart';
// import '../../../../../core/theme/theme_colors.dart';
//
// class PaymentProgressStepper extends StatelessWidget {
//   const PaymentProgressStepper({super.key, required this.currentStep});
//
//   final int currentStep;
//
//   @override
//   Widget build(BuildContext context) {
//     return Row(
//       children: [
//         _buildStep(
//           title: 'Cart',
//           step: 1,
//           isCompleted: currentStep > 1,
//           isCurrent: currentStep == 1,
//         ),
//
//         Expanded(child: _buildLine(currentStep > 1)),
//
//         _buildStep(
//           title: 'Address',
//           step: 2,
//           isCompleted: currentStep > 2,
//           isCurrent: currentStep == 2,
//         ),
//
//         Expanded(child: _buildLine(currentStep > 2)),
//
//         _buildStep(
//           title: 'Payment',
//           step: 3,
//           isCompleted: false,
//           isCurrent: currentStep == 3,
//         ),
//       ],
//     );
//   }
//
//   Widget _buildStep({
//     required String title,
//     required int step,
//     required bool isCompleted,
//     required bool isCurrent,
//   }) {
//     return Row(
//       children: [
//         Container(
//           width: 32,
//           height: 32,
//           decoration: BoxDecoration(
//             shape: BoxShape.circle,
//             color: isCompleted
//                 ? ThemeColors.green
//                 : isCurrent
//                 ? ThemeColors.blue
//                 : Colors.grey.shade300,
//           ),
//           child: Center(
//             child: isCompleted
//                 ? const Icon(Icons.check, color: Colors.white, size: 18)
//                 : Text(
//                     '$step',
//                     style: AppTextStyles.labelLarge.copyWith(
//                       color: Colors.white,
//                       fontWeight: FontWeight.w700,
//                     ),
//                   ),
//           ),
//         ),
//         const SizedBox(width: 8),
//         Text(title, style: AppTextStyles.titleMedium),
//       ],
//     );
//   }
//
//   Widget _buildLine(bool completed) {
//     return Container(
//       margin: const EdgeInsets.symmetric(horizontal: 8),
//       height: 2,
//       color: completed ? ThemeColors.green : Colors.grey.shade300,
//     );
//   }
// }
import 'package:bingo_pay/features/payment/presentation/screens/widgets/payment_metrics.dart';
import 'package:flutter/material.dart';

import '../../../../../core/theme/app_text_styles.dart';
import '../../../../../core/theme/app_theme_colors.dart';

class PaymentProgressStepper extends StatelessWidget {
  const PaymentProgressStepper({super.key, required this.currentStep});

  final int currentStep;

  @override
  Widget build(BuildContext context) {
    final m = PaymentMetrics.of(context);

    return Row(
      children: [
        _Step(
          title: 'Cart',
          step: 1,
          isCompleted: currentStep > 1,
          isCurrent: currentStep == 1,
          metrics: m,
        ),
        Expanded(
          child: _Line(completed: currentStep > 1, metrics: m),
        ),
        _Step(
          title: 'Address',
          step: 2,
          isCompleted: currentStep > 2,
          isCurrent: currentStep == 2,
          metrics: m,
        ),
        Expanded(
          child: _Line(completed: currentStep > 2, metrics: m),
        ),
        _Step(
          title: 'Payment',
          step: 3,
          isCompleted: false,
          isCurrent: currentStep == 3,
          metrics: m,
        ),
      ],
    );
  }
}

class _Step extends StatelessWidget {
  final String title;
  final int step;
  final bool isCompleted;
  final bool isCurrent;
  final PaymentMetrics metrics;

  const _Step({
    required this.title,
    required this.step,
    required this.isCompleted,
    required this.isCurrent,
    required this.metrics,
  });

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    final m = metrics;

    final bg = isCompleted
        ? c.statusSuccess
        : isCurrent
        ? c.brand
        : c.border;
    final fg = (isCompleted || isCurrent) ? c.surface : c.textMuted;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: m.stepCircle,
          height: m.stepCircle,
          decoration: BoxDecoration(color: bg, shape: BoxShape.circle),
          alignment: Alignment.center,
          child: isCompleted
              ? Icon(Icons.check_rounded, color: fg, size: m.stepCircle * 0.55)
              : Text(
                  '$step',
                  style: AppTextStyles.labelLarge.copyWith(
                    color: fg,
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.w700,
                    fontSize: m.stepNumSize,
                  ),
                ),
        ),
        SizedBox(width: m.gapSm * 0.7),
        Text(
          title,
          style: AppTextStyles.labelMedium.copyWith(
            color: isCurrent || isCompleted ? c.textPrimary : c.textMuted,
            fontFamily: 'Inter',
            fontWeight: isCurrent ? FontWeight.w700 : FontWeight.w500,
            fontSize: m.stepLabelSize,
          ),
        ),
      ],
    );
  }
}

class _Line extends StatelessWidget {
  final bool completed;
  final PaymentMetrics metrics;

  const _Line({required this.completed, required this.metrics});

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    return Container(
      margin: EdgeInsets.symmetric(horizontal: metrics.gapSm * 0.7),
      height: 2,
      color: completed ? c.statusSuccess : c.border,
    );
  }
}
