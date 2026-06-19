import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/router/app_routes.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../models/order_mock_data.dart';
import '../widgets/order_card.dart';
import '../widgets/order_date_filter_chips.dart';
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

  @override
  Widget build(BuildContext context) {
    final orders = OrderMockData.filtered(status: _selectedStatus, dateRange: _selectedDateRange);

    return Scaffold(
      backgroundColor: const Color(0xFFF4F5F7),
      appBar: OrdersAppBar(onSearchTap: () {}, onFilterTap: () {}),
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
                return OrderCard(
                  order: order,
                  onTap: () => context.push(AppRoutes.vendorTransactionPath(order.orderId)),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
