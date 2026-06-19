import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../models/order_mock_data.dart';

class OrderCard extends StatelessWidget {
  final Order order;
  final VoidCallback onTap;

  const OrderCard({super.key, required this.order, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: AppDimensions.sm + 4),
        padding: const EdgeInsets.all(AppDimensions.md),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8, offset: const Offset(0, 2)),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text('#${order.orderId}', style: TextStyle(fontSize: 13, color: Colors.grey[500])),
                const Spacer(),
                Text(order.timeAgo, style: TextStyle(fontSize: 13, color: Colors.grey[500])),
              ],
            ),
            const SizedBox(height: 4),
            Text(order.customerName, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
            const SizedBox(height: 2),
            Text(order.itemSummary, style: TextStyle(fontSize: 13, color: Colors.grey[600])),
            const SizedBox(height: 10),
            Row(
              children: [
                _PaymentPill(payment: order.payment),
                const SizedBox(width: 8),
                _StatusPill(status: order.status),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _PaymentPill extends StatelessWidget {
  final PaymentType payment;

  const _PaymentPill({required this.payment});

  @override
  Widget build(BuildContext context) {
    final (bg, fg, label) = switch (payment) {
      PaymentType.cod => (const Color(0xFFEDEEF0), Colors.grey[700]!, 'COD'),
      PaymentType.paid => (AppColors.successTint, const Color(0xFF4C7A2D), 'Paid'),
    };
    return _Pill(label: label, background: bg, foreground: fg);
  }
}

class _StatusPill extends StatelessWidget {
  final OrderStatus status;

  const _StatusPill({required this.status});

  @override
  Widget build(BuildContext context) {
    final (bg, fg) = switch (status) {
      OrderStatus.pending => (AppColors.warningTint, const Color(0xFFB36B00)),
      OrderStatus.confirmed => (const Color(0xFFDDEBFB), const Color(0xFF1A5DAB)),
      OrderStatus.processing => (const Color(0xFFDDEBFB), const Color(0xFF1A5DAB)),
      OrderStatus.shipped => (AppColors.accentPurpleTint, AppColors.accentPurple),
      OrderStatus.delivered => (AppColors.successTint, const Color(0xFF4C7A2D)),
    };
    return _Pill(label: status.label, background: bg, foreground: fg);
  }
}

class _Pill extends StatelessWidget {
  final String label;
  final Color background;
  final Color foreground;

  const _Pill({required this.label, required this.background, required this.foreground});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(color: background, borderRadius: BorderRadius.circular(AppDimensions.radiusCircular)),
      child: Text(label, style: TextStyle(color: foreground, fontWeight: FontWeight.w600, fontSize: 12)),
    );
  }
}
