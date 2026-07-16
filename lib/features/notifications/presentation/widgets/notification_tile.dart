import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../../core/widgets/glass/glass_card.dart';
import '../../data/models/notification_model.dart';
import 'notification_type_style.dart';

class NotificationTile extends StatelessWidget {
  final NotificationModel notification;
  final VoidCallback onTap;

  const NotificationTile({super.key, required this.notification, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final (icon, iconColor, iconBackground) =
        notificationTypeStyle(context, notification.type);
    final unread = !notification.isRead;

    return Padding(
      padding: const EdgeInsets.only(bottom: AppDimensions.sm),
      child: GlassCard(
        radius: AppDimensions.radiusXl,
        padding: const EdgeInsets.all(AppDimensions.sm + 4),
        tint: unread ? iconBackground.withValues(alpha: 0.35) : null,
        onTap: onTap,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: iconBackground,
                borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
              ),
              child: Icon(icon, size: 20, color: iconColor),
            ),
            const SizedBox(width: AppDimensions.sm + 4),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          notification.title,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: unread ? FontWeight.w700 : FontWeight.w600,
                            color: context.colors.textPrimary,
                          ),
                        ),
                      ),
                      if (unread) ...[
                        const SizedBox(width: AppDimensions.xs),
                        Container(
                          width: 8,
                          height: 8,
                          decoration: const BoxDecoration(
                            color: AppColors.info,
                            shape: BoxShape.circle,
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    notification.message,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(fontSize: 13, color: context.colors.textSecondary),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    notification.timeAgo,
                    style: TextStyle(fontSize: 11, color: context.colors.textMuted),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
