import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../core/api/api_client.dart';
import '../../../../core/api/api_endpoints.dart';
import '../../../../core/di/injection.dart';
import '../../../../core/error/error_messages.dart';
import '../../../../core/router/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../../core/theme/app_glass.dart';
import '../../../../core/widgets/glass/glass_scaffold.dart';
import '../../../../core/widgets/toolbar_icon_button.dart';
import '../../../dashboard/data/models/dashboard_stats_model.dart';
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
  String _searchQuery = '';
  final _searchController = TextEditingController();
  late Future<List<Order>> _ordersFuture;
  late Future<DashboardStatsModel?> _statsFuture;

  @override
  void initState() {
    super.initState();
    _ordersFuture = _fetchOrders();
    _statsFuture = _fetchStats();
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
    );
    if (result != null && mounted) {
      setState(() {
        _selectedStatus = result.status;
        _selectedDateRange = result.dateRange;
      });
    }
  }

  Future<List<Order>> _fetchOrders() async {
    final vendorOrders = await getIt<OrderRemoteDataSource>().getVendorOrders();
    return vendorOrders.map(Order.fromVendorOrder).toList();
  }

  Future<DashboardStatsModel?> _fetchStats() async {
    try {
      final response = await getIt<ApiClient>().dio.get(
        ApiEndpoints.vendorDashboard,
      );
      final data = response.data as Map<String, dynamic>;
      final inner =
          (data['data'] as Map<String, dynamic>)['data']
              as Map<String, dynamic>;
      return DashboardStatsModel.fromJson(inner);
    } catch (_) {
      return null;
    }
  }

  Future<void> _refresh() async {
    final future = _fetchOrders();
    setState(() {
      _ordersFuture = future;
      _statsFuture = _fetchStats();
    });
    await future;
  }

  @override
  Widget build(BuildContext context) {
    return GlassScaffold(
      appBar: const OrdersAppBar(),
      body: Column(
        children: [
          FutureBuilder<DashboardStatsModel?>(
            future: _statsFuture,
            builder: (context, snapshot) {
              final stats = snapshot.data;
              if (stats == null) return const SizedBox.shrink();
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
                      StatCard(
                        title: 'Pending',
                        value: '${stats.pendingOrders}',
                        icon: Icons.hourglass_empty,
                        iconColor: context.colors.warningFg,
                        iconBackground: context.colors.warningTint,
                      ),
                      const SizedBox(width: AppDimensions.sm + 4),
                      StatCard(
                        title: 'Delivered',
                        value: '${stats.deliveredOrders}',
                        icon: Icons.check_circle_outline,
                        iconColor: context.colors.successFg,
                        iconBackground: context.colors.successTint,
                      ),
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
