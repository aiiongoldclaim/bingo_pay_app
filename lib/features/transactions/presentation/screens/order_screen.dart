import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../core/di/injection.dart';
import '../../../../core/error/error_messages.dart';
import '../../../../core/router/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../../core/theme/app_glass.dart';
import '../../../../core/widgets/glass/glass_scaffold.dart';
import '../../../../core/widgets/toolbar_icon_button.dart';
import '../../../dashboard/presentation/widgets/stat_card.dart';
import '../../data/datasources/order_remote_datasource.dart';
import '../models/order_mock_data.dart';
import '../widgets/order_card.dart';
import '../widgets/order_filter_sheet.dart';
import '../widgets/orders_app_bar.dart';

class OrderScreen extends StatefulWidget {
  const OrderScreen({super.key});

  @override
  State<OrderScreen> createState() => _OrderScreenState();
}

class _OrderScreenState extends State<OrderScreen> {
  OrderStatus? _selectedStatus;
  DateRangeFilter _selectedDateRange = DateRangeFilter.all;
  DateTimeRange? _customRange;
  String _searchQuery = '';
  final _searchController = TextEditingController();
  late Future<List<Order>> _ordersFuture;

  @override
  void initState() {
    super.initState();
    _ordersFuture = _fetchOrders();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _clearSearch() {
    _searchController.clear();
    setState(() => _searchQuery = '');
  }

  List<Order> _applySearch(List<Order> orders) {
    final query = _searchQuery.trim().toLowerCase();
    if (query.isEmpty) return orders;
    return orders
        .where(
          (o) =>
              o.orderId.toLowerCase().contains(query) ||
              o.customerName.toLowerCase().contains(query) ||
              o.items.any((i) => i.productName.toLowerCase().contains(query)),
        )
        .toList();
  }

  Future<void> _openFilterSheet() async {
    final result = await showOrderFilterSheet(
      context,
      status: _selectedStatus,
      dateRange: _selectedDateRange,
      customRange: _customRange,
    );
    if (result == null || !mounted) return;

    final rangeChanged = result.dateRange == DateRangeFilter.custom &&
        result.customRange != _customRange;
    setState(() {
      _selectedStatus = result.status;
      _selectedDateRange = result.dateRange;
      _customRange = result.customRange;
    });
    // Custom range is sent to the API, so re-fetch when it changes.
    if (rangeChanged) {
      setState(() => _ordersFuture = _fetchOrders());
    }
  }

  Future<List<Order>> _fetchOrders() async {
    final useCustomRange =
        _selectedDateRange == DateRangeFilter.custom && _customRange != null;
    final vendorOrders = await getIt<OrderRemoteDataSource>().getVendorOrders(
      startDate: useCustomRange ? _customRange!.start : null,
      endDate: useCustomRange ? _customRange!.end : null,
    );
    return vendorOrders.map(Order.fromVendorOrder).toList();
  }

  Future<void> _refresh() async {
    final future = _fetchOrders();
    setState(() => _ordersFuture = future);
    await future;
  }

  @override
  Widget build(BuildContext context) {
    return GlassScaffold(
      appBar: const OrdersAppBar(),
      body: Column(
        children: [
          FutureBuilder<List<Order>>(
            future: _ordersFuture,
            builder: (context, snapshot) {
              final orders = snapshot.data;
              if (orders == null) return const SizedBox.shrink();
              final counts = <OrderStatus, int>{
                for (final s in OrderStatus.values) s: 0,
              };
              for (final o in orders) {
                counts[o.status] = (counts[o.status] ?? 0) + 1;
              }
              return Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppDimensions.md,
                  AppDimensions.md,
                  AppDimensions.md,
                  0,
                ),
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      for (final status in OrderStatus.values) ...[
                        StatCard(
                          title: status.label,
                          value: '${counts[status]}',
                          icon: _statusIcon(status),
                          iconColor: _statusColor(context, status).fg,
                          iconBackground: _statusColor(context, status).bg,
                        ),
                        const SizedBox(width: AppDimensions.sm + 4),
                      ],
                    ],
                  ),
                ),
              );
            },
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppDimensions.md,
              AppDimensions.md,
              AppDimensions.md,
              0,
            ),
            child: Row(
              children: [ 
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    onChanged: (value) => setState(() => _searchQuery = value),
                    textInputAction: TextInputAction.search,
                    style: const TextStyle(fontSize: 14),
                    decoration: InputDecoration(
                      hintText: 'Search orders…',
                      hintStyle: TextStyle(
                        fontSize: 14,
                        color: context.colors.textMuted,
                      ),
                      isDense: true,
                      filled: true,
                      fillColor: context.glass.fill,
                      contentPadding: const EdgeInsets.symmetric(vertical: 10),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(
                          AppDimensions.radiusXl,
                        ),
                        borderSide: BorderSide(color: context.glass.border),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(
                          AppDimensions.radiusXl,
                        ),
                        borderSide: BorderSide(color: context.glass.border),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(
                          AppDimensions.radiusXl,
                        ),
                        borderSide: const BorderSide(
                          color: AppColors.primary,
                          width: 1.5,
                        ),
                      ),
                      prefixIcon: Icon(
                        Icons.search,
                        size: 20,
                        color: context.colors.textSecondary,
                      ),
                      suffixIcon: _searchQuery.isEmpty
                          ? null
                          : IconButton(
                              icon: Icon(
                                Icons.close,
                                size: 18,
                                color: context.colors.textSecondary,
                              ),
                              onPressed: _clearSearch,
                            ),
                    ),
                  ),
                ),
                const SizedBox(width: AppDimensions.sm),
                ToolbarIconButton(
                  icon: Icons.tune,
                  tooltip: 'Filter',
                  showDot:
                      _selectedStatus != null ||
                      _selectedDateRange != DateRangeFilter.all,
                  onTap: _openFilterSheet,
                ),
              ],
            ),
          ),
          Expanded(
            child: FutureBuilder<List<Order>>(
              future: _ordersFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return _ErrorState(
                    message: friendlyErrorMessage(snapshot.error),
                    onRetry: _refresh,
                  );
                }

                final orders = _applySearch(
                  filterOrders(
                    snapshot.data ?? [],
                    status: _selectedStatus,
                    dateRange: _selectedDateRange,
                    customRange: _customRange,
                  ),
                );

                if (orders.isEmpty) {
                  return RefreshIndicator(
                    onRefresh: _refresh,
                    child: ListView(
                      children: const [
                        Padding(
                          padding: EdgeInsets.only(top: 120),
                          child: Center(child: Text('No orders found')),
                        ),
                      ],
                    ),
                  );
                }

                final entries = _groupByDay(orders);
                return RefreshIndicator(
                  onRefresh: _refresh,
                  child: ListView.builder(
                    padding: const EdgeInsets.fromLTRB(
                      AppDimensions.md,
                      AppDimensions.md,
                      AppDimensions.md,
                      96,
                    ),
                    itemCount: entries.length,
                    itemBuilder: (context, index) {
                      final entry = entries[index];
                      if (entry is _DayHeader) {
                        return Padding(
                          padding: EdgeInsets.only(
                            top: index == 0 ? 0 : AppDimensions.sm,
                            bottom: AppDimensions.sm,
                            left: 2,
                          ),
                          child: Text(
                            entry.label.toUpperCase(),
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 0.8,
                              color: context.colors.textSecondary,
                            ),
                          ),
                        );
                      }
                      final order = (entry as _OrderEntry).order;
                      return OrderCard(
                        order: order,
                        onTap: order.uuid.isEmpty
                            ? null
                            : () => context
                                  .push(
                                    AppRoutes.vendorTransactionPath(order.uuid),
                                  )
                                  .then((_) => _refresh()),
                      );
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

IconData _statusIcon(OrderStatus status) => switch (status) {
  OrderStatus.pending => Icons.hourglass_empty,
  OrderStatus.confirmed => Icons.thumb_up_alt_outlined,
  OrderStatus.processing => Icons.autorenew,
  OrderStatus.shipped => Icons.local_shipping_outlined,
  OrderStatus.delivered => Icons.check_circle_outline,
};

({Color bg, Color fg}) _statusColor(BuildContext context, OrderStatus status) {
  final colors = context.colors;
  return switch (status) {
    OrderStatus.pending => (bg: colors.warningTint, fg: colors.warningFg),
    OrderStatus.confirmed => (bg: colors.infoTint, fg: colors.infoFg),
    OrderStatus.processing => (bg: colors.infoTint, fg: colors.infoFg),
    OrderStatus.shipped => (bg: colors.purpleTint, fg: colors.purpleFg),
    OrderStatus.delivered => (bg: colors.successTint, fg: colors.successFg),
  };
}

/// Flattens orders into day headers + order rows, newest day first.
List<_TimelineEntry> _groupByDay(List<Order> orders) {
  orders = [...orders]..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);
  final entries = <_TimelineEntry>[];
  DateTime? currentDay;

  for (final order in orders) {
    final day = DateTime(
      order.createdAt.year,
      order.createdAt.month,
      order.createdAt.day,
    );
    if (day != currentDay) {
      currentDay = day;
      final diff = today.difference(day).inDays;
      final label = switch (diff) {
        0 => 'Today',
        1 => 'Yesterday',
        _ => DateFormat('EEEE, d MMM').format(day),
      };
      entries.add(_DayHeader(label));
    }
    entries.add(_OrderEntry(order));
  }
  return entries;
}

sealed class _TimelineEntry {}

class _DayHeader extends _TimelineEntry {
  final String label;
  _DayHeader(this.label);
}

class _OrderEntry extends _TimelineEntry {
  final Order order;
  _OrderEntry(this.order);
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
            const Text(
              'Failed to load orders',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 4),
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: context.colors.textSecondary,
                fontSize: 12,
              ),
            ),
            const SizedBox(height: AppDimensions.md),
            ElevatedButton(onPressed: onRetry, child: const Text('Retry')),
          ],
        ),
      ),
    );
  }
}
