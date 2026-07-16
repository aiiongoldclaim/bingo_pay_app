import 'package:flutter/material.dart';

import '../../../../core/di/injection.dart';
import '../../../../core/error/error_messages.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../../core/widgets/glass/glass_scaffold.dart';
import '../../data/datasources/notification_remote_datasource.dart';
import '../../data/models/notification_model.dart';
import '../widgets/notification_tile.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  late Future<List<NotificationModel>> _notificationsFuture;
  List<NotificationModel>? _notifications;

  @override
  void initState() {
    super.initState();
    _notificationsFuture = _fetch();
  }

  Future<List<NotificationModel>> _fetch() async {
    final list = await getIt<NotificationRemoteDataSource>().getNotifications();
    if (mounted) setState(() => _notifications = list);
    return list;
  }

  Future<void> _refresh() async {
    final future = _fetch();
    setState(() => _notificationsFuture = future);
    await future;
  }

  Future<void> _markAsRead(NotificationModel notification) async {
    if (notification.isRead) return;
    final current = _notifications;
    if (current == null) return;

    setState(() {
      _notifications = [
        for (final n in current)
          if (n.uuid == notification.uuid) n.copyWith(isRead: true) else n,
      ];
    });

    try {
      await getIt<NotificationRemoteDataSource>().markAsRead(notification.uuid);
    } catch (_) {
      // Optimistic update stays; a stale isRead flag is harmless and will
      // correct itself on the next refresh.
    }
  }

  Future<void> _markAllAsRead() async {
    final current = _notifications;
    if (current == null || current.every((n) => n.isRead)) return;

    setState(() {
      _notifications = [for (final n in current) n.copyWith(isRead: true)];
    });

    try {
      await getIt<NotificationRemoteDataSource>().markAllAsRead();
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    final hasUnread = _notifications?.any((n) => !n.isRead) ?? false;

    return GlassScaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
        title: Text(
          'Notifications',
          style: TextStyle(
            color: context.colors.textPrimary,
            fontSize: 22,
            fontWeight: FontWeight.w800,
            letterSpacing: -0.4,
          ),
        ),
        actions: [
          TextButton(
            onPressed: hasUnread ? _markAllAsRead : null,
            child: const Text('Mark all read'),
          ),
          const SizedBox(width: AppDimensions.xs),
        ],
      ),
      body: FutureBuilder<List<NotificationModel>>(
        future: _notificationsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return _ErrorState(
                message: friendlyErrorMessage(snapshot.error), onRetry: _refresh);
          }

          final notifications = _notifications ?? snapshot.data ?? [];
          if (notifications.isEmpty) {
            return RefreshIndicator(
              onRefresh: _refresh,
              child: ListView(
                children: [
                  Padding(
                    padding: const EdgeInsets.only(top: 120),
                    child: Center(
                      child: Column(
                        children: [
                          Icon(Icons.notifications_none,
                              size: 48, color: context.colors.textMuted),
                          const SizedBox(height: AppDimensions.sm),
                          const Text('No notifications yet'),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: _refresh,
            child: ListView.builder(
              padding: const EdgeInsets.fromLTRB(
                AppDimensions.md,
                AppDimensions.sm,
                AppDimensions.md,
                AppDimensions.md,
              ),
              itemCount: notifications.length,
              itemBuilder: (context, index) {
                final notification = notifications[index];
                return NotificationTile(
                  notification: notification,
                  onTap: () => _markAsRead(notification),
                );
              },
            ),
          );
        },
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  final String message;
  final Future<void> Function() onRetry;

  const _ErrorState({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppDimensions.lg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Failed to load notifications',
                style: TextStyle(fontWeight: FontWeight.w600)),
            const SizedBox(height: 4),
            Text(message,
                textAlign: TextAlign.center,
                style: TextStyle(color: context.colors.textSecondary, fontSize: 12)),
            const SizedBox(height: AppDimensions.md),
            ElevatedButton(onPressed: onRetry, child: const Text('Retry')),
          ],
        ),
      ),
    );
  }
}
