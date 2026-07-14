import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import 'package:bingo_pay/core/theme/theme_colors.dart';
import 'package:bingo_pay/core/theme/app_text_styles.dart';

import '../../data/models/order_model.dart';

class OrderStatusBadge extends StatelessWidget {
  final String status;

  const OrderStatusBadge({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    final config = statusColors(status);
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 0.7.h),
      decoration: BoxDecoration(
        color: config.bg,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        titleCaseStatus(status),
        style: AppTextStyles.labelMedium.copyWith(
          fontSize: 14.sp,
          fontWeight: FontWeight.w700,
          color: config.text,
        ),
      ),
    );
  }
}

class StatusColorConfig {
  final Color bg;
  final Color text;
  const StatusColorConfig({required this.bg, required this.text});
}

// Shared color lookup for both the order-status badge and the payment-status
// chip, and the order-detail hero banner — keeps every "status" pill in the
// orders feature visually consistent.
StatusColorConfig statusColors(String status) {
  switch (status.toUpperCase()) {
    case 'DELIVERED':
    case 'PAID':
    case 'CONFIRMED':
    case 'COMPLETED':
      return const StatusColorConfig(
        bg: ThemeColors.greenSoft,
        text: ThemeColors.green,
      );
    case 'SHIPPED':
    case 'OUT_FOR_DELIVERY':
    case 'PROCESSING':
      return const StatusColorConfig(
        bg: ThemeColors.blueSoft,
        text: ThemeColors.blue,
      );
    case 'CANCELLED':
    case 'FAILED':
    case 'REFUNDED':
      return const StatusColorConfig(
        bg: Color(0xFFFBE7E3),
        text: ThemeColors.red,
      );
    case 'PENDING':
    default:
      return const StatusColorConfig(
        bg: Color(0xFFFFF0E0),
        text: ThemeColors.amber,
      );
  }
}
