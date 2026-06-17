import 'package:flutter/material.dart';

import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_dimensions.dart';

class DashboardQuickActions extends StatelessWidget {
  final VoidCallback onProfileTap;
  final VoidCallback onSettingsTap;
  final VoidCallback onNotificationsTap;

  const DashboardQuickActions({
    super.key,
    required this.onProfileTap,
    required this.onSettingsTap,
    required this.onNotificationsTap,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _QuickActionCard(
            icon: Icons.person_outline,
            label: 'Profile',
            onTap: onProfileTap,
          ),
        ),
        const SizedBox(width: AppDimensions.sm),
        Expanded(
          child: _QuickActionCard(
            icon: Icons.notifications_outlined,
            label: 'Notifications',
            onTap: onNotificationsTap,
          ),
        ),
        const SizedBox(width: AppDimensions.sm),
        Expanded(
          child: _QuickActionCard(
            icon: Icons.settings_outlined,
            label: 'Settings',
            onTap: onSettingsTap,
          ),
        ),
      ],
    );
  }
}

class _QuickActionCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _QuickActionCard({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppDimensions.sm,
          vertical: AppDimensions.md,
        ),
        decoration: BoxDecoration(
          border: Border.all(color: AppColors.divider),
          borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
          color: AppColors.backgroundLight,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: AppColors.primary, size: 24),
            const SizedBox(height: AppDimensions.xs),
            Text(
              label,
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.w500,
                  ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
