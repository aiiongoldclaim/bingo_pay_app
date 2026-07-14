import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:sizer/sizer.dart';
import 'package:bingo_pay/core/theme/theme_colors.dart';
import 'package:bingo_pay/core/theme/app_text_styles.dart';

import '../../../../core/di/injection.dart';
import '../../../../core/router/app_routes.dart';
import '../../../orders/data/models/order_model.dart';
import '../../cubit/transactions_cubit.dart';
import '../../cubit/transactions_state.dart';
import '../../data/models/transaction_model.dart';
import '../widgets/transaction_card.dart';
import '../widgets/transaction_filter_tabs.dart';

class TransactionsScreen extends StatelessWidget {
  const TransactionsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<TransactionsCubit>()..loadTransactions(),
      child: const _TransactionsView(),
    );
  }
}

class _TransactionsView extends StatelessWidget {
  const _TransactionsView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ThemeColors.background,
      appBar: _buildAppBar(context),
      body: BlocBuilder<TransactionsCubit, TransactionsState>(
        builder: (context, state) {
          if (state is TransactionsLoading || state is TransactionsInitial) {
            return const Center(
              child: CircularProgressIndicator(color: ThemeColors.blue),
            );
          }

          if (state is TransactionsError) {
            return _buildError(context, state.message);
          }

          if (state is TransactionsLoaded) {
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
        'Transactions',
        style: AppTextStyles.headlineMedium.copyWith(
          fontSize: 20.sp,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }

  Widget _buildBody(BuildContext context, TransactionsLoaded state) {
    return RefreshIndicator(
      onRefresh: context.read<TransactionsCubit>().loadTransactions,
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
                '${state.all.length} ${state.all.length == 1 ? 'transaction' : 'transactions'}',
                style: AppTextStyles.bodyMedium.copyWith(
                  fontSize: 15.sp,
                  color: ThemeColors.inkMid,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),

          /// ── Filter Tabs ──
          Padding(
            padding: EdgeInsets.fromLTRB(4.w, 1.h, 4.w, 1.5.h),
            child: TransactionFilterTabs(
              activeFilter: state.activeFilter,
              onFilterChanged: (f) =>
                  context.read<TransactionsCubit>().filterTransactions(f),
            ),
          ),

          /// ── List ──
          Expanded(
            child: state.filtered.isEmpty
                ? _buildEmpty()
                : ListView.separated(
                    padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
                    physics: const AlwaysScrollableScrollPhysics(),
                    itemCount: state.filtered.length,
                    separatorBuilder: (_, _) => SizedBox(height: 2.h),
                    itemBuilder: (context, index) {
                      final transaction = state.filtered[index];
                      return TransactionCard(
                        transaction: transaction,
                        onTap: () => _goToOrder(context, transaction),
                      );
                    },
                  ),
          ),
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
                  'No transactions found',
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
        onRefresh: context.read<TransactionsCubit>().loadTransactions,
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
                      onPressed: () =>
                          context.read<TransactionsCubit>().loadTransactions(),
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

  // Transactions only carry a light-weight order reference (uuid, number,
  // statuses) — pushing this placeholder lets OrderDetailScreen fetch the
  // full order (with line items) by uuid, same as tapping from My Orders.
  void _goToOrder(BuildContext context, TransactionModel transaction) {
    final ref = transaction.order;
    if (ref == null) return;

    final placeholderOrder = OrderModel(
      id: '',
      uuid: ref.uuid,
      orderNumber: ref.orderNumber,
      paymentStatus: ref.paymentStatus,
      paymentMethod: transaction.gateway,
      orderStatus: ref.orderStatus,
      totalItems: 0,
      subtotalAmount: 0,
      discountAmount: 0,
      taxAmount: 0,
      shippingAmount: 0,
      totalAmount: transaction.amount,
      placedAt: transaction.createdAt,
    );

    context.push(AppRoutes.orderDetail, extra: placeholderOrder);
  }
}
