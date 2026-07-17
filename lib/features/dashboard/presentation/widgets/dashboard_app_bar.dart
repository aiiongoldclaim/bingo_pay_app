import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../../core/widgets/glass/glass_card.dart';

/// Liquid Glass dashboard header: date + greeting on the left, frosted
/// notification / logout chips and the avatar on the right.
class DashboardAppBar extends StatelessWidget {
  final String greetingName;
  final String shopName;
  final String avatarInitial;
  final VoidCallback onNotificationsTap;
  final VoidCallback onLogoutTap;
  final bool hasUnreadNotifications;

  const DashboardAppBar({
    super.key,
    required this.greetingName,
    required this.shopName,
    required this.avatarInitial,
    required this.onNotificationsTap,
    required this.onLogoutTap,
    this.hasUnreadNotifications = false,
  });

  String get _greeting {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good morning';
    if (hour < 17) return 'Good afternoon';
    return 'Good evening';
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final dateLabel = DateFormat('EEEE, d MMMM').format(DateTime.now());

    return SliverToBoxAdapter(
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
            AppDimensions.md,
            AppDimensions.sm,
            AppDimensions.md,
            0,
          ),
          child: Row(
            children: [
              GlassCard(
                radius: 22,
                padding: EdgeInsets.zero,
                child: SizedBox(
                  width: 40,
                  height: 40,
                  child: Center(
                    child: Text(
                      avatarInitial,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: AppColors.info,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _greeting,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: colors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      greetingName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.4,
                        color: colors.textPrimary,
                      ),
                    ),
                  ],
                ),
              ),
              _GlassIconButton(
                icon: Icons.notifications_none,
                showDot: hasUnreadNotifications,
                onTap: onNotificationsTap,
              ),
              const SizedBox(width: 8),
            ],
          ),
        ),
      ),
    );
  }
}

class _GlassIconButton extends StatelessWidget {
  final IconData icon;
  final bool showDot;
  final VoidCallback onTap;

  const _GlassIconButton({
    required this.icon,
    required this.onTap,
    this.showDot = false,
  });

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      radius: 22,
      padding: EdgeInsets.zero,
      onTap: onTap,
      child: SizedBox(
        width: 40,
        height: 40,
        child: Stack(
          alignment: Alignment.center,
          children: [
            Icon(icon, size: 20, color: context.colors.textPrimary),
            if (showDot)
              Positioned(
                right: 10,
                top: 10,
                child: Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(
                    color: AppColors.error,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
