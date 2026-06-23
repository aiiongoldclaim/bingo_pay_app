import 'package:flutter/material.dart';
import '../../../../../core/theme/app_text_styles.dart';
import '../../../../../core/theme/theme_colors.dart';

class PaymentProgressStepper extends StatelessWidget {
  const PaymentProgressStepper({super.key, required this.currentStep});

  final int currentStep;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _buildStep(
          title: 'Cart',
          step: 1,
          isCompleted: currentStep > 1,
          isCurrent: currentStep == 1,
        ),

        Expanded(child: _buildLine(currentStep > 1)),

        _buildStep(
          title: 'Address',
          step: 2,
          isCompleted: currentStep > 2,
          isCurrent: currentStep == 2,
        ),

        Expanded(child: _buildLine(currentStep > 2)),

        _buildStep(
          title: 'Payment',
          step: 3,
          isCompleted: false,
          isCurrent: currentStep == 3,
        ),
      ],
    );
  }

  Widget _buildStep({
    required String title,
    required int step,
    required bool isCompleted,
    required bool isCurrent,
  }) {
    return Row(
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isCompleted
                ? ThemeColors.green
                : isCurrent
                ? ThemeColors.blue
                : Colors.grey.shade300,
          ),
          child: Center(
            child: isCompleted
                ? const Icon(Icons.check, color: Colors.white, size: 18)
                : Text(
                    '$step',
                    style: AppTextStyles.labelLarge.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
          ),
        ),
        const SizedBox(width: 8),
        Text(title, style: AppTextStyles.titleMedium),
      ],
    );
  }

  Widget _buildLine(bool completed) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8),
      height: 2,
      color: completed ? ThemeColors.green : Colors.grey.shade300,
    );
  }
}
