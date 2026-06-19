import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimensions.dart';

class DashboardAppBar extends StatelessWidget {
  final String greetingName;
  final String shopName;
  final String avatarInitial;
  final VoidCallback onNotificationsTap;
  final bool hasUnreadNotifications;

  const DashboardAppBar({
    super.key,
    required this.greetingName,
    required this.shopName,
    required this.avatarInitial,
    required this.onNotificationsTap,
    this.hasUnreadNotifications = false,
  });

  @override
  Widget build(BuildContext context) {
    return SliverAppBar(
      automaticallyImplyLeading: false,
      pinned: true,
      expandedHeight: 116,
      toolbarHeight: 72,
      backgroundColor: const Color(0xFF1B2A6B),
      elevation: 0,
      flexibleSpace: ClipRRect(
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(24),
          bottomRight: Radius.circular(24),
        ),
        child: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFF1B2A6B), Color(0xFF2C3F8F)],
            ),
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppDimensions.lg,
                vertical: AppDimensions.sm,
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Text(
                          'Good morning, $greetingName!',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          shopName,
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                  _NotificationButton(
                    hasUnread: hasUnreadNotifications,
                    onTap: onNotificationsTap,
                  ),
                  const SizedBox(width: 8),
                  Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white24, width: 2),
                    ),
                    child: CircleAvatar(
                      backgroundColor: AppColors.info,
                      child: Text(
                        avatarInitial,
                        style: const TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _NotificationButton extends StatelessWidget {
  final bool hasUnread;
  final VoidCallback onTap;

  const _NotificationButton({required this.hasUnread, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(AppDimensions.radiusCircular),
      onTap: onTap,
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.1),
          shape: BoxShape.circle,
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            const Icon(Icons.notifications_none, color: Colors.white, size: 22),
            if (hasUnread)
              Positioned(
                right: 9,
                top: 9,
                child: Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(
                    color: Colors.red,
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
