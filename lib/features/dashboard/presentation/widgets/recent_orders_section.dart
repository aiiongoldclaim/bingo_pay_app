import 'package:flutter/material.dart';

import '../../../../core/theme/app_dimensions.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../models/dashboard_mock_data.dart';

const List<Color> _avatarPalette = [
  Color(0xFF1A73E8),
  Color(0xFF34A853),
  Color(0xFF7C4DFF),
  Color(0xFFB36B00),
  Color(0xFFEA4335),
];

Color _avatarColorFor(String name) => _avatarPalette[name.hashCode.abs() % _avatarPalette.length];

class RecentOrdersSection extends StatelessWidget {
  final List<RecentOrder> orders;
  final VoidCallback onSeeAllTap;

  const RecentOrdersSection({super.key, required this.orders, required this.onSeeAllTap});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Recent orders', style: AppTextStyles.titleLarge),
            TextButton(
              onPressed: onSeeAllTap,
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('See all'),
                  SizedBox(width: 2),
                  Icon(Icons.chevron_right, size: 18),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: AppDimensions.sm),
        for (final order in orders) _RecentOrderTile(order: order),
      ],
    );
  }
}

class _RecentOrderTile extends StatelessWidget {
  final RecentOrder order;

  const _RecentOrderTile({required this.order});

  @override
  Widget build(BuildContext context) {
    final (bg, fg, label) = switch (order.status) {
      OrderStatus.pending => (const Color(0xFFFCEFD9), const Color(0xFFB36B00), 'Pending'),
      OrderStatus.confirmed => (const Color(0xFFDDEBFB), const Color(0xFF1A5DAB), 'Confirmed'),
      OrderStatus.delivered => (const Color(0xFFE2F0DA), const Color(0xFF4C7A2D), 'Delivered'),
    };
    final initial = order.customerName.isNotEmpty ? order.customerName[0].toUpperCase() : '?';

    return Container(
      margin: const EdgeInsets.only(bottom: AppDimensions.sm + 4),
      padding: const EdgeInsets.all(AppDimensions.md),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8, offset: const Offset(0, 2)),
        ],
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 18,
            backgroundColor: _avatarColorFor(order.customerName),
            child: Text(initial, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('#${order.orderId} · ${order.timeAgo}', style: TextStyle(fontSize: 12, color: Colors.grey[600])),
                const SizedBox(height: 4),
                Text(order.customerName, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(AppDimensions.radiusCircular)),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 6,
                  height: 6,
                  margin: const EdgeInsets.only(right: 6),
                  decoration: BoxDecoration(color: fg, shape: BoxShape.circle),
                ),
                Text(label, style: TextStyle(color: fg, fontWeight: FontWeight.w600, fontSize: 13)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
