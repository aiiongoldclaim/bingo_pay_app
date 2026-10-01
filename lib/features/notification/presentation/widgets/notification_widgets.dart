import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/theme/app_theme_colors.dart';
import '../../../../core/widgets/app_shimmer.dart';
import '../../../../core/widgets/shimmer_loading.dart';
import '../../../setting/features/widgets/settings_metrics.dart';
import '../../domain/entities/notification_entity.dart';

// ── Top bar (back + title + unread subtitle + mark-all action) ─────────────
class NotificationTopBar extends StatelessWidget {
  final SettingsMetrics metrics;
  final String title;
  final String? subtitle;
  final VoidCallback onBack;

  /// Hidden when null.
  final VoidCallback? onMarkAllRead;

  /// Highlights the mark-all icon in brand colour when true.
  final bool hasUnread;

  const NotificationTopBar({
    super.key,
    required this.metrics,
    this.title = 'Notifications',
    this.subtitle,
    required this.onBack,
    this.onMarkAllRead,
    this.hasUnread = false,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.c;
    final m = metrics;

    return Padding(
      padding: EdgeInsets.fromLTRB(
        m.pageHPad * 0.4,
        m.pageVPad * 0.5,
        m.pageHPad,
        m.pageVPad * 0.5,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          IconButton(
            onPressed: onBack,
            splashRadius: m.backIconSize * 1.2,
            icon: Icon(
              Icons.arrow_back_ios_rounded,
              size: m.backIconSize,
              color: colors.textPrimary,
            ),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  title,
                  style: AppTextStyles.titleLarge.copyWith(
                    color: colors.textPrimary,
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.w700,
                    fontSize: m.titleSize,
                    height: 1.2,
                  ),
                ),
                if (subtitle != null) ...[
                  SizedBox(height: m.gapXs * 0.6),
                  Text(
                    subtitle!,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: colors.textSecondary,
                      fontFamily: 'Inter',
                      fontSize: m.subtitleSize,
                      height: 1.2,
                    ),
                  ),
                ],
              ],
            ),
          ),
          if (onMarkAllRead != null)
            IconButton(
              onPressed: onMarkAllRead,
              splashRadius: m.topIconSize * 1.2,
              tooltip: 'Mark all as read',
              icon: Icon(
                Icons.done_all_rounded,
                size: m.topIconSize,
                color: hasUnread ? colors.brand : colors.textMuted,
              ),
            ),
        ],
      ),
    );
  }
}

// ── Filter chip ────────────────────────────────────────────────────────────
class NotificationFilterChip extends StatelessWidget {
  final SettingsMetrics metrics;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const NotificationFilterChip({
    super.key,
    required this.metrics,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.c;
    final m = metrics;

    return Material(
      color: isSelected ? colors.brand : colors.surface,
      borderRadius: BorderRadius.circular(m.chipHeight),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Container(
          height: m.chipHeight,
          padding: EdgeInsets.symmetric(horizontal: m.tileHPad * 0.9),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(m.chipHeight),
            border: Border.all(
              color: isSelected ? colors.brand : colors.border,
              width: 1,
            ),
          ),
          alignment: Alignment.center,
          child: Text(
            label,
            style: AppTextStyles.labelMedium.copyWith(
              color: isSelected ? colors.surface : colors.textSecondary,
              fontFamily: 'Inter',
              fontWeight: FontWeight.w600,
              fontSize: m.chipFontSize,
            ),
          ),
        ),
      ),
    );
  }
}

// ── Notification tile ──────────────────────────────────────────────────────
class NotificationTile extends StatelessWidget {
  final SettingsMetrics metrics;
  final NotificationEntity item;
  final VoidCallback onTap;

  const NotificationTile({
    super.key,
    required this.metrics,
    required this.item,
    required this.onTap,
  });

  IconData get _icon {
    final type = item.type.toUpperCase();
    if (type == 'AUCTION_WON') return Icons.emoji_events_outlined;
    if (type.startsWith('AUCTION')) return Icons.gavel_rounded;
    if (type.startsWith('BOOKING')) return Icons.event_available_outlined;
    if (type.startsWith('ORDER')) return Icons.local_shipping_outlined;
    if (type.contains('WALLET') || type.contains('PAYMENT')) {
      return Icons.account_balance_wallet_outlined;
    }
    if (type.contains('PASSWORD')) return Icons.lock_reset_rounded;
    return Icons.info_outline_rounded;
  }

  String get _time {
    final diff = DateTime.now().difference(item.createdAt);
    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    if (diff.inDays < 7) return '${diff.inDays}d ago';
    return DateFormat('dd MMM yyyy, hh:mm a').format(item.createdAt);
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.c;
    final m = metrics;

    return Material(
      color: item.isRead ? colors.surface : colors.brandSoft,
      borderRadius: BorderRadius.circular(m.cardRadius),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Container(
          padding: EdgeInsets.all(m.tileHPad * 0.9),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(m.cardRadius),
            border: Border.all(
              color: item.isRead ? colors.border : colors.brand.withValues(alpha: 0.3),
              width: 1,
            ),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: m.notifIconBox,
                height: m.notifIconBox,
                decoration: BoxDecoration(
                  color: item.isRead
                      ? colors.surfaceAlt
                      : colors.surface.withValues(alpha: colors.isDark ? 0.10 : 0.8),
                  shape: BoxShape.circle,
                ),
                alignment: Alignment.center,
                child: Icon(_icon, size: m.notifIconSize, color: colors.brand),
              ),

              SizedBox(width: m.tileHPad * 0.8),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            item.title,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: AppTextStyles.labelLarge.copyWith(
                              color: colors.textPrimary,
                              fontFamily: 'Inter',
                              fontWeight: item.isRead
                                  ? FontWeight.w600
                                  : FontWeight.w700,
                              fontSize: m.notifTitleSize,
                              height: 1.3,
                            ),
                          ),
                        ),
                        if (!item.isRead) ...[
                          SizedBox(width: m.gapSm),
                          Container(
                            width: m.dotSize,
                            height: m.dotSize,
                            decoration: BoxDecoration(
                              color: colors.brand,
                              shape: BoxShape.circle,
                            ),
                          ),
                        ],
                      ],
                    ),

                    SizedBox(height: m.gapXs),

                    Text(
                      item.message,
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: colors.textSecondary,
                        fontFamily: 'Inter',
                        fontSize: m.notifBodySize,
                        height: 1.4,
                      ),
                    ),

                    SizedBox(height: m.gapSm * 0.8),

                    Row(
                      children: [
                        Icon(
                          Icons.schedule_rounded,
                          size: m.notifTimeSize + 3,
                          color: colors.textMuted,
                        ),
                        SizedBox(width: m.gapXs),
                        Text(
                          _time,
                          style: AppTextStyles.bodySmall.copyWith(
                            color: colors.textMuted,
                            fontFamily: 'Inter',
                            fontSize: m.notifTimeSize,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Loading shimmer (filter chips + tiles shaped like NotificationTile) ─────
class NotificationListShimmer extends StatelessWidget {
  final SettingsMetrics metrics;
  final int itemCount;

  const NotificationListShimmer({
    super.key,
    required this.metrics,
    this.itemCount = 6,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.c;
    final m = metrics;

    return AppShimmer(
      backgroundColor: colors.background,
      child: Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: m.maxContentWidth),
          child: ListView(
            physics: const NeverScrollableScrollPhysics(),
            padding: EdgeInsets.fromLTRB(
              m.pageHPad,
              m.gapSm,
              m.pageHPad,
              m.gapLg * 2,
            ),
            children: [
              Row(
                children: [
                  ShimmerBox(
                    width: m.chipHeight * 2.4,
                    height: m.chipHeight,
                    borderRadius: BorderRadius.circular(m.chipHeight),
                  ),
                  SizedBox(width: m.gapSm),
                  ShimmerBox(
                    width: m.chipHeight * 2.8,
                    height: m.chipHeight,
                    borderRadius: BorderRadius.circular(m.chipHeight),
                  ),
                ],
              ),
              SizedBox(height: m.gapMd),
              for (var i = 0; i < itemCount; i++) ...[
                _NotificationTileShimmer(metrics: m),
                SizedBox(height: m.gapSm),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _NotificationTileShimmer extends StatelessWidget {
  final SettingsMetrics metrics;

  const _NotificationTileShimmer({required this.metrics});

  @override
  Widget build(BuildContext context) {
    final colors = context.c;
    final m = metrics;
    final line = BorderRadius.circular(6);

    return Container(
      padding: EdgeInsets.all(m.tileHPad * 0.9),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(m.cardRadius),
        border: Border.all(color: colors.border),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ShimmerBox(
            width: m.notifIconBox,
            height: m.notifIconBox,
            borderRadius: BorderRadius.circular(m.notifIconBox),
          ),
          SizedBox(width: m.tileHPad * 0.8),
          Expanded(
            child: LayoutBuilder(
              builder: (context, constraints) {
                final w = constraints.maxWidth;
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ShimmerBox(
                      width: w * 0.6,
                      height: m.notifTitleSize,
                      borderRadius: line,
                    ),
                    SizedBox(height: m.gapSm),
                    ShimmerBox(
                      width: w,
                      height: m.notifBodySize,
                      borderRadius: line,
                    ),
                    SizedBox(height: m.gapXs),
                    ShimmerBox(
                      width: w * 0.8,
                      height: m.notifBodySize,
                      borderRadius: line,
                    ),
                    SizedBox(height: m.gapSm),
                    ShimmerBox(
                      width: w * 0.3,
                      height: m.notifTimeSize,
                      borderRadius: line,
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
