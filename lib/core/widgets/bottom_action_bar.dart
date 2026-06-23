import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../constants/app_sizes.dart';
import '../theme/app_text_styles.dart';
import '../theme/theme_colors.dart';

class BottomActionBar extends StatelessWidget {
  const BottomActionBar({
    super.key,
    required this.primaryText,
    required this.primaryOnTap,
    this.secondaryText,
    this.secondaryOnTap,
    this.primaryFlex = 2,
    this.secondaryFlex = 1,
  });

  final String primaryText;
  final VoidCallback primaryOnTap;

  final String? secondaryText;
  final VoidCallback? secondaryOnTap;

  final int primaryFlex;
  final int secondaryFlex;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Container(
        padding: EdgeInsets.fromLTRB(4.w, 1.5.h, 4.w, 2.h),
        decoration: BoxDecoration(
          color: ThemeColors.surface,
          border: Border(top: BorderSide(color: ThemeColors.line)),
        ),
        child: Row(
          children: [
            if (secondaryText != null) ...[
              Expanded(
                flex: secondaryFlex,
                child: _SecondaryButton(
                  text: secondaryText!,
                  onTap: secondaryOnTap,
                ),
              ),

              SizedBox(width: 3.w),
            ],

            Expanded(
              flex: primaryFlex,
              child: _PrimaryButton(text: primaryText, onTap: primaryOnTap),
            ),
          ],
        ),
      ),
    );
  }
}

class _PrimaryButton extends StatelessWidget {
  const _PrimaryButton({required this.text, required this.onTap});

  final String text;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 6.h,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: ThemeColors.blue,
          borderRadius: BorderRadius.circular(AppSizes.radiusXl),
        ),
        child: Text(
          text,
          style: AppTextStyles.buttonText.copyWith(
            fontSize: AppSizes.iconSm,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}

class _SecondaryButton extends StatelessWidget {
  const _SecondaryButton({required this.text, this.onTap});

  final String text;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 6.h,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: ThemeColors.surface,
          borderRadius: BorderRadius.circular(AppSizes.radiusXl),
          border: Border.all(color: ThemeColors.line),
        ),
        child: Text(
          text,
          style: AppTextStyles.labelLarge.copyWith(
            fontSize: AppSizes.iconSm,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}
