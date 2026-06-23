import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import 'package:bingo_pay/core/theme/theme_colors.dart';
import 'package:bingo_pay/core/theme/app_text_styles.dart';

class OrderStatusBadge extends StatelessWidget {
  final String status;

  const OrderStatusBadge({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    final config = _statusConfig(status);
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 0.5.h),
      decoration: BoxDecoration(
        color: config.bg,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        status,
        style: AppTextStyles.labelMedium.copyWith(
          fontSize: 15.sp,
          fontWeight: FontWeight.w600,
          color: config.text,
        ),
      ),
    );
  }

  _StatusConfig _statusConfig(String status) {
    switch (status) {
      case 'In Transit':
        return _StatusConfig(bg: ThemeColors.blueSoft, text: ThemeColors.blue);
      case 'Delivered':
        return _StatusConfig(
          bg: ThemeColors.greenSoft,
          text: ThemeColors.green,
        );
      case 'Cancelled':
        return _StatusConfig(bg: ThemeColors.white, text: ThemeColors.red);
      default:
        return _StatusConfig(bg: ThemeColors.white, text: ThemeColors.amber);
    }
  }
}

class _StatusConfig {
  final Color bg;
  final Color text;
  const _StatusConfig({required this.bg, required this.text});
}
