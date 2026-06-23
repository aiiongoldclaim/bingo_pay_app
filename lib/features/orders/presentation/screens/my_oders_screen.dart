import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:sizer/sizer.dart';
import 'package:bingo_pay/core/theme/theme_colors.dart';
import 'package:bingo_pay/core/theme/app_text_styles.dart';
import '../../../../core/router/app_routes.dart';
import '../../cubit/orders_cubit.dart';
import '../../cubit/orders_state.dart';
import '../widgets/order_card.dart';
import '../widgets/order_filter_table.dart';
import 'order_details_screen.dart';

class OrdersScreen extends StatelessWidget {
  const OrdersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => OrdersCubit()..loadOrders(),
      child: const _OrdersView(),
    );
  }
}

class _OrdersView extends StatelessWidget {
  const _OrdersView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ThemeColors.background,
      appBar: _buildAppBar(context),
      body: BlocBuilder<OrdersCubit, OrdersState>(
        builder: (context, state) {
          if (state is OrdersLoading || state is OrdersInitial) {
            return const Center(
              child: CircularProgressIndicator(color: ThemeColors.blue),
            );
          }

          if (state is OrdersError) {
            return Center(
              child: Text(state.message, style: AppTextStyles.bodyMedium),
            );
          }

          if (state is OrdersLoaded) {
            return _buildBody(context, state);
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: ThemeColors.background,
      elevation: 0,
      scrolledUnderElevation: 0,
      centerTitle: false,

      leading: Container(
        // margin: EdgeInsets.only(right: 10.w),
        decoration: BoxDecoration(
          color: ThemeColors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: ThemeColors.line),
        ),
        child: IconButton(
          icon: Icon(
            Icons.arrow_back_ios_new_rounded,
            size: 18.sp,
            color: ThemeColors.ink,
          ),
          onPressed: () => context.pop(),
        ),
      ),

      title: Text(
        'My Orders',
        style: AppTextStyles.headlineMedium.copyWith(
          fontSize: 20.sp,
          fontWeight: FontWeight.w700,
        ),
      ),

      actions: [
        Container(
          margin: EdgeInsets.only(right: 4.w),
          width: 11.w,
          height: 11.w,
          decoration: BoxDecoration(
            color: ThemeColors.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: ThemeColors.line),
          ),
          child: IconButton(
            padding: EdgeInsets.zero,
            icon: Icon(
              Icons.search_rounded,
              size: 18.sp,
              color: ThemeColors.ink,
            ),
            onPressed: () {},
          ),
        ),
      ],
    );
  }

  Widget _buildBody(BuildContext context, OrdersLoaded state) {
    return Column(
      children: [
        /// ── Filter Tabs ──
        Padding(
          padding: EdgeInsets.fromLTRB(4.w, 1.h, 4.w, 1.5.h),
          child: OrderFilterTabs(
            activeFilter: state.activeFilter,
            onFilterChanged: (f) => context.read<OrdersCubit>().filterOrders(f),
          ),
        ),

        /// ── Orders List ──
        Expanded(
          child: state.filtered.isEmpty
              ? _buildEmpty()
              : ListView.separated(
                  padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
                  itemCount: state.filtered.length,
                  separatorBuilder: (_, __) => SizedBox(height: 2.h),
                  itemBuilder: (context, index) {
                    final order = state.filtered[index];
                    return OrderCard(
                      order: order,
                      onTrack: () => _goToDetail(context, order),
                      onDetails: () => _goToDetail(context, order),
                      onReorder: () {},
                      onRate: () {},
                    );
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildEmpty() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.receipt_long_outlined,
            size: 40.sp,
            color: ThemeColors.inkDim,
          ),
          SizedBox(height: 2.h),
          Text(
            'No orders found',
            style: AppTextStyles.titleMedium.copyWith(
              color: ThemeColors.inkMid,
              fontSize: 15.sp,
            ),
          ),
        ],
      ),
    );
  }

  void _goToDetail(BuildContext context, order) {
    debugPrint('Clicked order: ${order.orderId}');

    context.push(AppRoutes.orderDetail, extra: order);
  }
}
