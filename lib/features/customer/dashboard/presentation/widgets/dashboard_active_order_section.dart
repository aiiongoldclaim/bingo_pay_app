import 'package:flutter/material.dart';

import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_dimensions.dart';
import '../cubit/buyer_dashboard_state.dart';

/// Section displaying the current active order status.
/// 
/// Shows real-time order tracking information including:
/// - Order ID
/// - Current status
/// - Estimated delivery time
class DashboardActiveOrderSection extends StatelessWidget {
  final ActiveOrder activeOrder;
  final VoidCallback onTrackOrder;

  const DashboardActiveOrderSection({
    super.key,
    required this.activeOrder,
    required this.onTrackOrder,
  });

  @override
  
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.divider),
        borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
        color: AppColors.success.withAlpha(10),
      ),
      padding: const EdgeInsets.all(AppDimensions.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Active Order',
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppDimensions.sm,
                  vertical: AppDimensions.xs,
                ),
                decoration: BoxDecoration(
                  color: AppColors.success,
                  borderRadius: BorderRadius.circular(AppDimensions.radiusSm),
                ),
                child: Text(
                  activeOrder.statusLabel,
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppDimensions.md),
          Text(
            'Order #${activeOrder.id}',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppColors.textSecondary,
                ),
          ),
          const SizedBox(height: AppDimensions.sm),
          Text(
            activeOrder.etaLabel,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: AppColors.success,
                ),
          ),
          const SizedBox(height: AppDimensions.md),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: onTrackOrder,
              child: const Text('Track Order'),
            ),
          ),
        ],
      ),
    );
  }
}
