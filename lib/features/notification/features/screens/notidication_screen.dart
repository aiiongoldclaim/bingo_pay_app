import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/router/app_routes.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/theme/app_theme_colors.dart';
import '../../../../core/widgets/app_snackbar.dart';
import '../../../setting/features/widgets/settings_metrics.dart';
import '../../../setting/features/widgets/settings_widgets.dart';


enum NotificationKind { order, offer, wallet, system }

class AppNotification {
  final String id;
  final NotificationKind kind;
  final String title;
  final String body;
  final String time;
  final bool isRead;

  const AppNotification({
    required this.id,
    required this.kind,
    required this.title,
    required this.body,
    required this.time,
    this.isRead = false,
  });

  AppNotification copyWith({bool? isRead}) => AppNotification(
    id: id,
    kind: kind,
    title: title,
    body: body,
    time: time,
    isRead: isRead ?? this.isRead,
  );
}

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  /// Placeholder data — koi notifications API abhi nahi hai
  List<AppNotification> _items = const [];

  int _filterIndex = 0; // 0 = All, 1 = Unread

  List<AppNotification> get _visible => _filterIndex == 0
      ? _items
      : _items.where((n) => !n.isRead).toList();

  int get _unreadCount => _items.where((n) => !n.isRead).length;

  void _markAllRead() {
    if (_unreadCount == 0) return;
    setState(() {
      _items = _items.map((n) => n.copyWith(isRead: true)).toList();
    });
    AppSnackbar.showSuccess(context, 'All notifications marked as read');
  }

  void _openNotification(AppNotification n) {
    setState(() {
      _items = _items
          .map((e) => e.id == n.id ? e.copyWith(isRead: true) : e)
          .toList();
    });

    switch (n.kind) {
      case NotificationKind.order:
        context.push(AppRoutes.orders);
      case NotificationKind.wallet:
        context.push(AppRoutes.wallet);
      case NotificationKind.offer:
      case NotificationKind.system:
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final c = context.c;

    return Scaffold(
      backgroundColor: c.background,
      body: SafeArea(
        bottom: false,
        child: Builder(
          builder: (context) {
            final m = SettingsMetrics.of(context);
            final items = _visible;

            return Column(
              children: [
                SettingsTopBar(
                  metrics: m,
                  title: 'Notifications',
                  subtitle: _unreadCount > 0
                      ? '$_unreadCount unread'
                      : 'You are all caught up',
                  onBack: () => context.canPop()
                      ? context.pop()
                      : context.go(AppRoutes.account),
                  action: _items.isEmpty
                      ? null
                      : IconButton(
                    onPressed: _markAllRead,
                    splashRadius: m.topIconSize * 1.2,
                    tooltip: 'Mark all as read',
                    icon: Icon(
                      Icons.done_all_rounded,
                      size: m.topIconSize,
                      color: _unreadCount > 0 ? c.brand : c.textMuted,
                    ),
                  ),
                ),

                if (_items.isNotEmpty)
                  Padding(
                    padding: EdgeInsets.fromLTRB(
                      m.pageHPad,
                      m.gapSm,
                      m.pageHPad,
                      m.gapSm,
                    ),
                    child: Row(
                      children: [
                        _FilterChip(
                          metrics: m,
                          label: 'All (${_items.length})',
                          isSelected: _filterIndex == 0,
                          onTap: () => setState(() => _filterIndex = 0),
                        ),
                        SizedBox(width: m.gapSm),
                        _FilterChip(
                          metrics: m,
                          label: 'Unread ($_unreadCount)',
                          isSelected: _filterIndex == 1,
                          onTap: () => setState(() => _filterIndex = 1),
                        ),
                      ],
                    ),
                  ),

                Expanded(
                  child: items.isEmpty
                      ? SettingsEmptyView(
                    metrics: m,
                    icon: Icons.notifications_none_rounded,
                    title: _items.isEmpty
                        ? 'No notifications yet'
                        : 'Nothing unread',
                    subtitle: _items.isEmpty
                        ? 'Order updates, offers and wallet activity\nwill show up here.'
                        : 'You have read everything. Nice work.',
                    actionLabel: _items.isEmpty ? 'START SHOPPING' : null,
                    onAction: _items.isEmpty
                        ? () => context.go(AppRoutes.home)
                        : null,
                  )
                      : Center(
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        maxWidth: m.maxContentWidth,
                      ),
                      child: ListView.separated(
                        padding: EdgeInsets.fromLTRB(
                          m.pageHPad,
                          m.gapSm,
                          m.pageHPad,
                          m.gapLg * 2,
                        ),
                        itemCount: items.length,
                        separatorBuilder: (_, __) =>
                            SizedBox(height: m.gapSm),
                        itemBuilder: (context, index) => _NotificationTile(
                          metrics: m,
                          item: items[index],
                          onTap: () => _openNotification(items[index]),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

// ── Filter chip ────────────────────────────────────────────────────────────
class _FilterChip extends StatelessWidget {
  final SettingsMetrics metrics;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _FilterChip({
    required this.metrics,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    final m = metrics;

    return Material(
      color: isSelected ? c.brand : c.surface,
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
              color: isSelected ? c.brand : c.border,
              width: 1,
            ),
          ),
          alignment: Alignment.center,
          child: Text(
            label,
            style: AppTextStyles.labelMedium.copyWith(
              color: isSelected ? c.surface : c.textSecondary,
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
class _NotificationTile extends StatelessWidget {
  final SettingsMetrics metrics;
  final AppNotification item;
  final VoidCallback onTap;

  const _NotificationTile({
    required this.metrics,
    required this.item,
    required this.onTap,
  });

  IconData get _icon {
    switch (item.kind) {
      case NotificationKind.order:
        return Icons.local_shipping_outlined;
      case NotificationKind.offer:
        return Icons.local_offer_outlined;
      case NotificationKind.wallet:
        return Icons.account_balance_wallet_outlined;
      case NotificationKind.system:
        return Icons.info_outline_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    final m = metrics;

    return Material(
      color: item.isRead ? c.surface : c.brandSoft,
      borderRadius: BorderRadius.circular(m.cardRadius),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Container(
          padding: EdgeInsets.all(m.tileHPad * 0.9),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(m.cardRadius),
            border: Border.all(
              color: item.isRead ? c.border : c.brand.withValues(alpha: 0.3),
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
                      ? c.surfaceAlt
                      : c.surface.withValues(alpha: c.isDark ? 0.10 : 0.8),
                  shape: BoxShape.circle,
                ),
                alignment: Alignment.center,
                child: Icon(_icon, size: m.notifIconSize, color: c.brand),
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
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: AppTextStyles.labelLarge.copyWith(
                              color: c.textPrimary,
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
                              color: c.brand,
                              shape: BoxShape.circle,
                            ),
                          ),
                        ],
                      ],
                    ),

                    SizedBox(height: m.gapXs),

                    Text(
                      item.body,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: c.textSecondary,
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
                          color: c.textMuted,
                        ),
                        SizedBox(width: m.gapXs),
                        Text(
                          item.time,
                          style: AppTextStyles.bodySmall.copyWith(
                            color: c.textMuted,
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