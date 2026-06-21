import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/di/injection.dart';
import '../../../../core/router/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../data/datasources/order_remote_datasource.dart';
import '../models/order_mock_data.dart';
import '../widgets/order_card.dart';
import '../widgets/order_date_filter_chips.dart';
import '../widgets/order_status_sheet.dart';
import '../widgets/order_status_tabs.dart';
import '../widgets/orders_app_bar.dart';

class TransactionScreen extends StatefulWidget {
  const TransactionScreen({super.key});

  @override
  State<TransactionScreen> createState() => _TransactionScreenState();
}

class _TransactionScreenState extends State<TransactionScreen> {
  OrderStatus? _selectedStatus;
  DateRangeFilter _selectedDateRange = DateRangeFilter.today;
  late Future<List<Order>> _ordersFuture;

  @override
  void initState() {
    super.initState();
    _ordersFuture = _fetchOrders();
  }

  Future<List<Order>> _fetchOrders() async {
    final rows = await getIt<OrderRemoteDataSource>().getOrders();
    return rows.map(Order.fromApi).toList();
  }

  Future<void> _refresh() async {
    final future = _fetchOrders();
    setState(() {
      _ordersFuture = future;
    });
    await future;
  }

  Future<void> _openAddOrder() async {
    await context.push(AppRoutes.vendorOrderCreate);
    _refresh();
  }

  Future<void> _changeStatus(Order order) async {
    final newStatus = await showOrderStatusSheet(context, current: order.status);
    if (newStatus == null || newStatus == order.status) return;
    try {
      await getIt<OrderRemoteDataSource>().updateOrderStatus(orderId: order.orderId, status: newStatus.name);
      _refresh();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to update status: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F5F7),
      appBar: OrdersAppBar(onSearchTap: () {}, onFilterTap: () {}),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.primary,
        onPressed: _openAddOrder,
        child: const Icon(Icons.add, color: Colors.white),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppDimensions.md),
            child: OrderStatusTabs(
              selected: _selectedStatus,
              onSelected: (status) => setState(() => _selectedStatus = status),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppDimensions.md,
              AppDimensions.sm,
              AppDimensions.md,
              0,
            ),
            child: OrderDateFilterChips(
              selected: _selectedDateRange,
              onSelected: (range) => setState(() => _selectedDateRange = range),
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
                  return _ErrorState(message: '${snapshot.error}', onRetry: _refresh);
                }

                final orders = filterOrders(
                  snapshot.data ?? [],
                  status: _selectedStatus,
                  dateRange: _selectedDateRange,
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

                return RefreshIndicator(
                  onRefresh: _refresh,
                  child: ListView.builder(
                    padding: const EdgeInsets.fromLTRB(
                      AppDimensions.md,
                      AppDimensions.md,
                      AppDimensions.md,
                      AppDimensions.lg,
                    ),
                    itemCount: orders.length,
                    itemBuilder: (context, index) {
                      final order = orders[index];
                      return OrderCard(order: order, onTap: () => _changeStatus(order));
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
            const Text('Failed to load orders', style: TextStyle(fontWeight: FontWeight.w600)),
            const SizedBox(height: 4),
            Text(message, textAlign: TextAlign.center, style: TextStyle(color: Colors.grey[600], fontSize: 12)),
            const SizedBox(height: AppDimensions.md),
            ElevatedButton(onPressed: onRetry, child: const Text('Retry')),
          ],
        ),
      ),
    );
  }
}
