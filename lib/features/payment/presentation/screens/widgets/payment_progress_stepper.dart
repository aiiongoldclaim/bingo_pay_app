import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_text_styles.dart';
import '../../../../../core/theme/theme_colors.dart';


class PaymentProgressStepper extends StatelessWidget {
  final int currentStep;

  const PaymentProgressStepper({
    super.key,
    required this.currentStep,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _buildStep(1, currentStep >= 1),
        Expanded(child: _buildLine(currentStep >= 2)),
        _buildStep(2, currentStep >= 2),
        Expanded(child: _buildLine(currentStep >= 3)),
        _buildStep(3, currentStep >= 3, isActive: currentStep == 3),
      ],
    );
  }

  Widget _buildStep(int step, bool completed, {bool isActive = false}) {
    return Container(
      width: 7.w,
      height: 7.w,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: completed ? ThemeColors.green : AppColors.surface2,
        border: isActive 
            ? Border.all(color: ThemeColors.blue, width: 2) 
            : null,
      ),
      child: Center(
        child: Text(
          step.toString(),
          style: AppTextStyles.labelLarge.copyWith(
            color: completed ? AppColors.white : ThemeColors.inkMid,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildLine(bool completed) {
    return Container(
      height: 2,
      color: completed ? ThemeColors.green : AppColors.line,
    );
  }
}