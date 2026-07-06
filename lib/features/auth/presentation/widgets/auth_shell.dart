import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../../core/constants/app_sizes.dart';
import '../../../../core/constants/image_constants.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/theme/theme_colors.dart';

/// Shared branded header used across the auth screens — the BingoPay icon
/// mark on a soft blue tint, plus a title/subtitle pair.
class AuthBrandHeader extends StatelessWidget {
  final String title;
  final String subtitle;

  const AuthBrandHeader({super.key, required this.title, required this.subtitle});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 72,
          height: 72,
          decoration: const BoxDecoration(
            color: ThemeColors.blueSoft,
            shape: BoxShape.circle,
          ),
          padding: const EdgeInsets.all(16),
          child: Image.asset(AppImages.logoIcon, fit: BoxFit.contain),
        ),
        SizedBox(height: 2.2.h),
        Text(
          title,
          style: AppTextStyles.headlineMedium.copyWith(fontSize: 22.sp),
          textAlign: TextAlign.center,
        ),
        SizedBox(height: .6.h),
        Text(
          subtitle,
          style: AppTextStyles.bodyMedium,
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}

/// Shared floating card container for auth form fields.
class AuthCard extends StatelessWidget {
  final List<Widget> children;

  const AuthCard({super.key, required this.children});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(AppSizes.paddingLg),
      decoration: BoxDecoration(
        color: ThemeColors.surface,
        borderRadius: BorderRadius.circular(AppSizes.radius2Xl),
        boxShadow: [
          BoxShadow(
            color: ThemeColors.blueDeep.withValues(alpha: 0.08),
            blurRadius: AppSizes.shadowBlurLg,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: children,
      ),
    );
  }
}
