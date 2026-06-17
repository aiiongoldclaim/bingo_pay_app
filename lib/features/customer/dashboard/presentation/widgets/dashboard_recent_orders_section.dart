import 'package:flutter/material.dart';

import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_dimensions.dart';
import '../cubit/buyer_dashboard_state.dart';

/// Section displaying recent orders.
/// 
/// Shows a list of recent orders with:
/// - Order title
/// - Order status
/// - Tappable rows for order details
class DashboardRecentOrdersSection extends StatelessWidget {
  final List<RecentOrder> recentOrders;
  final void Function(String orderId) onOrderTap;

  const DashboardRecentOrdersSection({
    super.key,
    required this.recentOrders,
    required this.onOrderTap,
  });

  @override
  Widget build(BuildContext context) {
    if (recentOrders.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Recent Orders',
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: AppDimensions.md),
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: recentOrders.length,
          separatorBuilder: (_, __) => const SizedBox(height: AppDimensions.sm),
          itemBuilder: (context, index) {
            final order = recentOrders[index];
            return _RecentOrderTile(order: order, onTap: () => onOrderTap(order.id));
          },
        ),
      ],
    );
  }
}

class _RecentOrderTile extends StatelessWidget {
  final RecentOrder order;
  final VoidCallback onTap;

  const _RecentOrderTile({required this.order, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
      child: Container(
        padding: const EdgeInsets.all(AppDimensions.md),
        decoration: BoxDecoration(
          border: Border.all(color: AppColors.divider),
          borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
          color: AppColors.backgroundLight,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    order.title,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: AppDimensions.xs),
                  Text(
                    'Order #${order.id}',
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: AppColors.textSecondary,
                        ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: AppDimensions.md),
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppDimensions.sm,
                vertical: AppDimensions.xs,
              ),
              decoration: BoxDecoration(
                color: _getStatusColor(order.statusLabel).withAlpha(20),
                borderRadius: BorderRadius.circular(AppDimensions.radiusSm),
              ),
              child: Text(
                order.statusLabel,
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: _getStatusColor(order.statusLabel),
                      fontWeight: FontWeight.w600,
                    ),
              ),
            ),
            const SizedBox(width: AppDimensions.sm),
            Icon(
              Icons.chevron_right,
              color: AppColors.textSecondary,
            ),
          ],
        ),
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'delivered':
        return AppColors.success;
      case 'in transit':
        return AppColors.primary;
      case 'processing':
        return AppColors.warning;
      case 'cancelled':
        return AppColors.error;
      default:
        return AppColors.textSecondary;
    }
  }
}
