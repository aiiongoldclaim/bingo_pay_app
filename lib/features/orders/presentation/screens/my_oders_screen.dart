import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:sizer/sizer.dart';
import 'package:bingo_pay/core/theme/theme_colors.dart';
import 'package:bingo_pay/core/theme/app_text_styles.dart';
import '../../../../core/di/injection.dart';
import '../../../../core/router/app_routes.dart';
import '../../cubit/orders_cubit.dart';
import '../../cubit/orders_state.dart';
import '../../data/models/order_model.dart';
import '../widgets/order_card.dart';
import '../widgets/order_filter_table.dart';

class OrdersScreen extends StatelessWidget {
  const OrdersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<OrdersCubit>()..loadOrders(),
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
            return _buildError(context, state.message);
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

      leading: Row(
        children: [
          const Spacer(),
          Container(
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
        ],
      ),

      title: Text(
        'My Orders',
        style: AppTextStyles.headlineMedium.copyWith(
          fontSize: 20.sp,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }

  Widget _buildBody(BuildContext context, OrdersLoaded state) {
    return RefreshIndicator(
      onRefresh: context.read<OrdersCubit>().loadOrders,
      color: ThemeColors.blue,
      backgroundColor: ThemeColors.white,
      child: Column(
        children: [
          /// ── Summary ──
          Padding(
            padding: EdgeInsets.fromLTRB(4.w, 1.h, 4.w, 0),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                '${state.all.length} ${state.all.length == 1 ? 'order' : 'orders'}',
                style: AppTextStyles.bodyMedium.copyWith(
                  fontSize: 15.sp,
                  color: ThemeColors.inkMid,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),

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
                    physics: const AlwaysScrollableScrollPhysics(),
                    itemCount: state.filtered.length,
                    separatorBuilder: (_, _) => SizedBox(height: 2.h),
                    itemBuilder: (context, index) {
                      final order = state.filtered[index];
                      return OrderCard(
                        order: order,
                        onDetails: () => _goToDetail(context, order),
                      );
                    },
                  ),
          ),

          SizedBox(height: 10.h),
        ],
      ),
    );
  }

  Widget _buildEmpty() {
    return LayoutBuilder(
      builder: (context, constraints) => SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: ConstrainedBox(
          constraints: BoxConstraints(minHeight: constraints.maxHeight),
          child: Center(
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
          ),
        ),
      ),
    );
  }

  Widget _buildError(BuildContext context, String message) {
    return LayoutBuilder(
      builder: (context, constraints) => RefreshIndicator(
        onRefresh: context.read<OrdersCubit>().loadOrders,
        color: ThemeColors.blue,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: constraints.maxHeight),
            child: Center(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 8.w),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.error_outline_rounded,
                      size: 40.sp,
                      color: ThemeColors.inkDim,
                    ),
                    SizedBox(height: 2.h),
                    Text(
                      message,
                      textAlign: TextAlign.center,
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: ThemeColors.inkMid,
                        fontSize: 15.sp,
                      ),
                    ),
                    SizedBox(height: 2.h),
                    OutlinedButton(
                      onPressed: () => context.read<OrdersCubit>().loadOrders(),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: ThemeColors.blue,
                        side: const BorderSide(color: ThemeColors.blue),
                        padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 1.5.h),
                      ),
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _goToDetail(BuildContext context, OrderModel order) {
    context.push(AppRoutes.orderDetail, extra: order);
  }
}
