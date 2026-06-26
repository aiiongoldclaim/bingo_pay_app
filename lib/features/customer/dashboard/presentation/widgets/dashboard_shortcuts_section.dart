import 'package:flutter/material.dart';

import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_dimensions.dart';
import '../cubit/buyer_dashboard_state.dart';

/// Section displaying shortcuts to common account resources.
///
/// Shows:
/// - Saved addresses
/// - Payment methods
/// - Rewards / wallet balance
class DashboardShortcutsSection extends StatelessWidget {
  final List<Address> addresses;
  final List<PaymentMethod> paymentMethods;
  final RewardSummary rewards;
  final VoidCallback onAddressEdit;
  final VoidCallback onPaymentEdit;

  const DashboardShortcutsSection({
    super.key,
    required this.addresses,
    required this.paymentMethods,
    required this.rewards,
    required this.onAddressEdit,
    required this.onPaymentEdit,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Account Shortcuts',
          style: Theme.of(
            context,
          ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: AppDimensions.md),
        // Addresses
        if (addresses.isNotEmpty)
          _ShortcutCard(
            icon: Icons.location_on_outlined,
            title: 'Addresses',
            subtitle:
                '${addresses.length} saved address${addresses.length > 1 ? 'es' : ''}',
            onTap: onAddressEdit,
          ),
        if (addresses.isNotEmpty) const SizedBox(height: AppDimensions.md),
        // Payment Methods
        if (paymentMethods.isNotEmpty)
          _ShortcutCard(
            icon: Icons.credit_card_outlined,
            title: 'Payment Methods',
            subtitle:
                '${paymentMethods.length} saved method${paymentMethods.length > 1 ? 's' : ''}',
            onTap: onPaymentEdit,
          ),
        if (paymentMethods.isNotEmpty) const SizedBox(height: AppDimensions.md),
        // Rewards
        _RewardsCard(rewards: rewards),
      ],
    );
  }
}

class _ShortcutCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _ShortcutCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
      child: Container(
        padding: const EdgeInsets.all(AppDimensions.lg),
        decoration: BoxDecoration(
          border: Border.all(color: AppColors.divider),
          borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
          color: AppColors.backgroundLight,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(AppDimensions.md),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withAlpha(20),
                    borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
                  ),
                  child: Icon(icon, color: AppColors.primary, size: 24),
                ),
                const SizedBox(width: AppDimensions.lg),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: AppDimensions.xs),
                    Text(
                      subtitle,
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            Icon(Icons.chevron_right, color: AppColors.textSecondary),
          ],
        ),
      ),
    );
  }
}

class _RewardsCard extends StatelessWidget {
  final RewardSummary rewards;

  const _RewardsCard({required this.rewards});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppDimensions.lg),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            // AppColors.secondary.withAlpha(200),
            // AppColors.secondary.withAlpha(150),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
        boxShadow: [
          BoxShadow(
            // color: AppColors.secondary.withAlpha(50),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Your Rewards',
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: AppDimensions.lg),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _RewardItem(
                label: 'Wallet Balance',
                value: '\$${rewards.walletBalance.toStringAsFixed(0)}',
              ),
              _RewardItem(
                label: 'Reward Points',
                value: '${rewards.rewardPoints}',
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _RewardItem extends StatelessWidget {
  final String label;
  final String value;

  const _RewardItem({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: Theme.of(
            context,
          ).textTheme.labelSmall?.copyWith(color: Colors.white.withAlpha(200)),
        ),
        const SizedBox(height: AppDimensions.sm),
        Text(
          value,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ],
    );
  }
}
