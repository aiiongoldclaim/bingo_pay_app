import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/di/injection.dart';
import '../../../../core/router/app_routes.dart';
import '../../../../core/theme/app_theme_colors.dart';
import '../../../../core/widgets/app_snackbar.dart';
import '../../../setting/features/widgets/settings_metrics.dart';
import '../../../setting/features/widgets/settings_widgets.dart';
import '../../domain/entities/notification_entity.dart';
import '../cubit/notification_cubit.dart';
import '../cubit/notification_state.dart';
import '../widgets/notification_widgets.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<NotificationCubit>(
      create: (_) => getIt<NotificationCubit>()..loadNotifications(),
      child: const _NotificationsView(),
    );
  }
}

class _NotificationsView extends StatefulWidget {
  const _NotificationsView();

  @override
  State<_NotificationsView> createState() => _NotificationsViewState();
}

class _NotificationsViewState extends State<_NotificationsView> {
  int _filterIndex = 0; // 0 = All, 1 = Unread

  Future<void> _markAllRead(int unreadCount) async {
    if (unreadCount == 0) return;
    final error = await context.read<NotificationCubit>().markAllAsRead();
    if (!mounted) return;
    if (error != null) {
      AppSnackbar.showError(context, error);
    } else {
      AppSnackbar.showSuccess(context, 'All notifications marked as read');
    }
  }

  void _openNotification(NotificationEntity n) {
    context.read<NotificationCubit>().markAsRead(n.uuid).then((error) {
      if (error != null && mounted) AppSnackbar.showError(context, error);
    });

    final type = n.type.toUpperCase();
    if (type.startsWith('BOOKING')) {
      context.push(AppRoutes.myBookings);
    } else if (type.startsWith('AUCTION')) {
      context.push(AppRoutes.myBids);
    } else if (type.startsWith('ORDER')) {
      context.push(AppRoutes.orders);
    } else if (type.contains('WALLET')) {
      context.push(AppRoutes.wallet);
    }
  }

  Future<void> _refresh() =>
      context.read<NotificationCubit>().loadNotifications(silent: true);

  @override
  Widget build(BuildContext context) {
    final colors = context.c;

    return BlocBuilder<NotificationCubit, NotificationState>(
      builder: (context, state) {
        final all = state is NotificationLoaded
            ? state.items
            : const <NotificationEntity>[];
        final unreadCount =
            state is NotificationLoaded ? state.unreadCount : 0;
        final items = _filterIndex == 0
            ? all
            : all.where((n) => !n.isRead).toList();

        return Scaffold(
          backgroundColor: colors.background,
          body: SafeArea(
            bottom: false,
            child: Builder(
              builder: (context) {
                final m = SettingsMetrics.of(context);

                return Column(
                  children: [
                    NotificationTopBar(
                      metrics: m,
                      subtitle: state is! NotificationLoaded
                          ? null
                          : unreadCount > 0
                              ? '$unreadCount unread'
                              : 'You are all caught up',
                      onBack: () => context.canPop()
                          ? context.pop()
                          : context.go(AppRoutes.profile),
                      onMarkAllRead: all.isEmpty
                          ? null
                          : () => _markAllRead(unreadCount),
                      hasUnread: unreadCount > 0,
                    ),

                    if (all.isNotEmpty)
                      Padding(
                        padding: EdgeInsets.fromLTRB(
                          m.pageHPad,
                          m.gapSm,
                          m.pageHPad,
                          m.gapSm,
                        ),
                        child: Row(
                          children: [
                            NotificationFilterChip(
                              metrics: m,
                              label: 'All (${all.length})',
                              isSelected: _filterIndex == 0,
                              onTap: () => setState(() => _filterIndex = 0),
                            ),
                            SizedBox(width: m.gapSm),
                            NotificationFilterChip(
                              metrics: m,
                              label: 'Unread ($unreadCount)',
                              isSelected: _filterIndex == 1,
                              onTap: () => setState(() => _filterIndex = 1),
                            ),
                          ],
                        ),
                      ),

                    Expanded(child: _buildBody(m, state, all, items)),
                  ],
                );
              },
            ),
          ),
        );
      },
    );
  }

  Widget _buildBody(
    SettingsMetrics m,
    NotificationState state,
    List<NotificationEntity> all,
    List<NotificationEntity> items,
  ) {
    if (state is NotificationError) {
      return SettingsEmptyView(
        metrics: m,
        icon: Icons.cloud_off_rounded,
        title: 'Could not load notifications',
        subtitle: state.errorMessage,
        actionLabel: 'RETRY',
        onAction: () => context.read<NotificationCubit>().loadNotifications(),
      );
    }

    if (state is! NotificationLoaded) {
      return NotificationListShimmer(metrics: m);
    }

    if (items.isEmpty) {
      return RefreshIndicator(
        onRefresh: _refresh,
        child: LayoutBuilder(
          builder: (context, constraints) => SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: SizedBox(
              height: constraints.maxHeight,
              child: SettingsEmptyView(
                metrics: m,
                icon: Icons.notifications_none_rounded,
                title: all.isEmpty ? 'No notifications yet' : 'Nothing unread',
                subtitle: all.isEmpty
                    ? 'Order updates, bookings and auction activity\nwill show up here.'
                    : 'You have read everything. Nice work.',
                actionLabel: all.isEmpty ? 'START SHOPPING' : null,
                onAction:
                    all.isEmpty ? () => context.go(AppRoutes.home) : null,
              ),
            ),
          ),
        ),
      );
    }

    return ConstrainedBox(
      constraints: BoxConstraints(maxWidth: m.maxContentWidth),
      child: RefreshIndicator(
        onRefresh: _refresh,
        child: ListView.separated(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: EdgeInsets.fromLTRB(
            m.pageHPad,
            m.gapSm,
            m.pageHPad,
            m.gapLg * 2,
          ),
          itemCount: items.length,
          separatorBuilder: (_, _) => SizedBox(height: m.gapSm),
          itemBuilder: (context, index) => NotificationTile(
            metrics: m,
            item: items[index],
            onTap: () => _openNotification(items[index]),
          ),
        ),
      ),
    );
  }
}

