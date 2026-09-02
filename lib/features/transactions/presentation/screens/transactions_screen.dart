// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:go_router/go_router.dart';
// import 'package:sizer/sizer.dart';
// import 'package:bingo_pay/core/theme/theme_colors.dart';
// import 'package:bingo_pay/core/theme/app_text_styles.dart';
//
// import '../../../../core/di/injection.dart';
// import '../../../../core/router/app_routes.dart';
// import '../../../orders/data/models/order_model.dart';
// import '../../cubit/transactions_cubit.dart';
// import '../../cubit/transactions_state.dart';
// import '../../data/models/transaction_model.dart';
// import '../widgets/transaction_card.dart';
// import '../widgets/transaction_filter_tabs.dart';
//
// class TransactionsScreen extends StatelessWidget {
//   const TransactionsScreen({super.key});
//
//   @override
//   Widget build(BuildContext context) {
//     return BlocProvider(
//       create: (_) => getIt<TransactionsCubit>()..loadTransactions(),
//       child: const _TransactionsView(),
//     );
//   }
// }
//
// class _TransactionsView extends StatelessWidget {
//   const _TransactionsView();
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: ThemeColors.background,
//       appBar: _buildAppBar(context),
//       body: BlocBuilder<TransactionsCubit, TransactionsState>(
//         builder: (context, state) {
//           if (state is TransactionsLoading || state is TransactionsInitial) {
//             return const Center(
//               child: CircularProgressIndicator(color: ThemeColors.blue),
//             );
//           }
//
//           if (state is TransactionsError) {
//             return _buildError(context, state.message);
//           }
//
//           if (state is TransactionsLoaded) {
//             return _buildBody(context, state);
//           }
//
//           return const SizedBox.shrink();
//         },
//       ),
//     );
//   }
//
//   PreferredSizeWidget _buildAppBar(BuildContext context) {
//     return AppBar(
//       backgroundColor: ThemeColors.background,
//       elevation: 0,
//       scrolledUnderElevation: 0,
//       centerTitle: false,
//
//       leading: IconButton(
//         icon: Icon(
//           Icons.arrow_back_ios_new_rounded,
//           size: 18.sp,
//           color: ThemeColors.black,
//         ),
//         onPressed: () => context.pop(),
//       ),
//
//       title: Text(
//         'Transactions',
//         style: AppTextStyles.headlineMedium.copyWith(
//           fontSize: 20.sp,
//           fontWeight: FontWeight.w700,
//         ),
//       ),
//     );
//   }
//
//   Widget _buildBody(BuildContext context, TransactionsLoaded state) {
//     return RefreshIndicator(
//       onRefresh: context.read<TransactionsCubit>().loadTransactions,
//       color: ThemeColors.primaryPurple,
//       backgroundColor: ThemeColors.white,
//       child: Column(
//         children: [
//           /// ── Summary ──
//           Padding(
//             padding: EdgeInsets.fromLTRB(4.w, 1.h, 4.w, 0),
//             child: Align(
//               alignment: Alignment.centerLeft,
//               child: Text(
//                 '${state.all.length} ${state.all.length == 1 ? 'transaction' : 'transactions'}',
//                 style: AppTextStyles.bodyMedium.copyWith(
//                   fontSize: 15.sp,
//                   color: ThemeColors.inkMid,
//                   fontWeight: FontWeight.w600,
//                 ),
//               ),
//             ),
//           ),
//
//           /// ── Filter Tabs ──
//           Padding(
//             padding: EdgeInsets.fromLTRB(4.w, 1.h, 4.w, 1.5.h),
//             child: TransactionFilterTabs(
//               activeFilter: state.activeFilter,
//               onFilterChanged: (f) =>
//                   context.read<TransactionsCubit>().filterTransactions(f),
//             ),
//           ),
//
//           /// ── List ──
//           Expanded(
//             child: state.filtered.isEmpty
//                 ? _buildEmpty()
//                 : ListView.separated(
//                     padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
//                     physics: const AlwaysScrollableScrollPhysics(),
//                     itemCount: state.filtered.length,
//                     separatorBuilder: (_, _) => SizedBox(height: 2.h),
//                     itemBuilder: (context, index) {
//                       final transaction = state.filtered[index];
//                       return TransactionCard(
//                         transaction: transaction,
//                         onTap: () => _goToOrder(context, transaction),
//                       );
//                     },
//                   ),
//           ),
//         ],
//       ),
//     );
//   }
//
//   Widget _buildEmpty() {
//     return LayoutBuilder(
//       builder: (context, constraints) => SingleChildScrollView(
//         physics: const AlwaysScrollableScrollPhysics(),
//         child: ConstrainedBox(
//           constraints: BoxConstraints(minHeight: constraints.maxHeight),
//           child: Center(
//             child: Column(
//               mainAxisAlignment: MainAxisAlignment.center,
//               children: [
//                 Icon(
//                   Icons.receipt_long_outlined,
//                   size: 40.sp,
//                   color: ThemeColors.inkDim,
//                 ),
//                 SizedBox(height: 2.h),
//                 Text(
//                   'No transactions found',
//                   style: AppTextStyles.titleMedium.copyWith(
//                     color: ThemeColors.inkMid,
//                     fontSize: 15.sp,
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }
//
//   Widget _buildError(BuildContext context, String message) {
//     return LayoutBuilder(
//       builder: (context, constraints) => RefreshIndicator(
//         onRefresh: context.read<TransactionsCubit>().loadTransactions,
//         color: ThemeColors.blue,
//         child: SingleChildScrollView(
//           physics: const AlwaysScrollableScrollPhysics(),
//           child: ConstrainedBox(
//             constraints: BoxConstraints(minHeight: constraints.maxHeight),
//             child: Center(
//               child: Padding(
//                 padding: EdgeInsets.symmetric(horizontal: 8.w),
//                 child: Column(
//                   mainAxisAlignment: MainAxisAlignment.center,
//                   children: [
//                     Icon(
//                       Icons.error_outline_rounded,
//                       size: 40.sp,
//                       color: ThemeColors.inkDim,
//                     ),
//                     SizedBox(height: 2.h),
//                     Text(
//                       message,
//                       textAlign: TextAlign.center,
//                       style: AppTextStyles.bodyMedium.copyWith(
//                         color: ThemeColors.inkMid,
//                         fontSize: 15.sp,
//                       ),
//                     ),
//                     SizedBox(height: 2.h),
//                     OutlinedButton(
//                       onPressed: () =>
//                           context.read<TransactionsCubit>().loadTransactions(),
//                       style: OutlinedButton.styleFrom(
//                         foregroundColor: ThemeColors.blue,
//                         side: const BorderSide(color: ThemeColors.blue),
//                         padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 1.5.h),
//                       ),
//                       child: const Text('Retry'),
//                     ),
//                   ],
//                 ),
//               ),
//             ),
//           ),
//         ),
//       ),
//     );
//   }
//
//   // Transactions only carry a light-weight order reference (uuid, number,
//   // statuses) — pushing this placeholder lets OrderDetailScreen fetch the
//   // full order (with line items) by uuid, same as tapping from My Orders.
//   void _goToOrder(BuildContext context, TransactionModel transaction) {
//     final ref = transaction.order;
//     if (ref == null) return;
//
//     final placeholderOrder = OrderModel(
//       id: '',
//       uuid: ref.uuid,
//       orderNumber: ref.orderNumber,
//       paymentStatus: ref.paymentStatus,
//       paymentMethod: transaction.gateway,
//       orderStatus: ref.orderStatus,
//       totalItems: 0,
//       subtotalAmount: 0,
//       discountAmount: 0,
//       taxAmount: 0,
//       shippingAmount: 0,
//       totalAmount: transaction.amount,
//       placedAt: transaction.createdAt,
//     );
//
//     context.push(AppRoutes.orderDetail, extra: placeholderOrder);
//   }
// }
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/di/injection.dart';
import '../../../../core/router/app_routes.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/theme/app_theme_colors.dart';
import '../../../orders/data/models/order_model.dart';
import '../../cubit/transactions_cubit.dart';
import '../../cubit/transactions_state.dart';
import '../../data/models/transaction_model.dart';
import '../widgets/transaction_card.dart';
import '../widgets/transaction_filter_tabs.dart';
import '../widgets/transactions_metrics.dart';

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
    final c = context.c;

    return Scaffold(
      backgroundColor: c.background,
      body: SafeArea(
        bottom: false,
        child: BlocBuilder<TransactionsCubit, TransactionsState>(
          builder: (context, state) {
            final m = TransactionsMetrics.of(context);

            final count = state is TransactionsLoaded ? state.all.length : null;

            return Column(
              children: [
                _TransactionsTopBar(metrics: m, count: count),

                Expanded(
                  child:
                  state is TransactionsLoading ||
                      state is TransactionsInitial
                      ? Center(child: CircularProgressIndicator(color: c.brand))
                      : state is TransactionsError
                      ? _ErrorView(metrics: m, message: state.message)
                      : state is TransactionsLoaded
                      ? _LoadedView(metrics: m, state: state)
                      : const SizedBox.shrink(),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

// ── Top bar ────────────────────────────────────────────────────────────────
class _TransactionsTopBar extends StatelessWidget {
  final TransactionsMetrics metrics;
  final int? count;

  const _TransactionsTopBar({required this.metrics, required this.count});

  @override
  Widget build(BuildContext context) {
    final colors = context.c;
    final m = metrics;

    return Padding(
      padding: EdgeInsets.fromLTRB(
        m.pageHPad * 0.4,
        m.pageVPad * 0.5,
        m.pageHPad,
        m.pageVPad * 0.5,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          IconButton(
            onPressed: () => context.canPop()
                ? context.pop()
                : context.go(AppRoutes.account),
            splashRadius: m.backIconSize * 1.2,
            icon: Icon(
              Icons.arrow_back_ios_rounded,
              size: m.backIconSize,
              color: colors.textPrimary,
            ),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Transactions',
                  style: AppTextStyles.titleLarge.copyWith(
                    color: colors.textPrimary,
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.w700,
                    fontSize: m.titleSize,
                    height: 1.2,
                  ),
                ),
                if (count != null) ...[
                  SizedBox(height: m.gapXs * 0.6),
                  Text(
                    '$count ${count == 1 ? 'transaction' : 'transactions'}',
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: colors.textSecondary,
                      fontFamily: 'Inter',
                      fontSize: m.subtitleSize,
                      height: 1.2,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Loaded ─────────────────────────────────────────────────────────────────
class _LoadedView extends StatelessWidget {
  final TransactionsMetrics metrics;
  final TransactionsLoaded state;

  const _LoadedView({required this.metrics, required this.state});

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

  @override
  Widget build(BuildContext context) {
    final colors = context.c;
    final m = metrics;

    return RefreshIndicator(
      onRefresh: context.read<TransactionsCubit>().loadTransactions,
      color: colors.brand,
      backgroundColor: colors.surface,
      child: Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: m.maxContentWidth),
          child: Column(
            children: [
              Padding(
                padding: EdgeInsets.fromLTRB(
                  m.pageHPad,
                  m.gapSm,
                  m.pageHPad,
                  m.gapMd,
                ),
                child: TransactionFilterTabs(
                  activeFilter: state.activeFilter,
                  onFilterChanged: (f) =>
                      context.read<TransactionsCubit>().filterTransactions(f),
                ),
              ),

              Expanded(
                child: state.filtered.isEmpty
                    ? _EmptyView(metrics: m, filter: state.activeFilter)
                    : m.crossAxisCount > 1
                    ? GridView.builder(
                  padding: EdgeInsets.fromLTRB(
                    m.pageHPad,
                    0,
                    m.pageHPad,
                    m.gapLg * 2,
                  ),
                  physics: const AlwaysScrollableScrollPhysics(),
                  gridDelegate:
                  SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: m.crossAxisCount,
                    crossAxisSpacing: m.gridSpacing,
                    mainAxisSpacing: m.gridSpacing,
                    mainAxisExtent: m.iconBox + m.cardPad * 2.6,
                  ),
                  itemCount: state.filtered.length,
                  itemBuilder: (context, index) {
                    final transaction = state.filtered[index];
                    return TransactionCard(
                      transaction: transaction,
                      onTap: () => _goToOrder(context, transaction),
                    );
                  },
                )
                    : ListView.separated(
                  padding: EdgeInsets.fromLTRB(
                    m.pageHPad,
                    0,
                    m.pageHPad,
                    m.gapLg * 2,
                  ),
                  physics: const AlwaysScrollableScrollPhysics(),
                  itemCount: state.filtered.length,
                  separatorBuilder: (_, __) =>
                      SizedBox(height: m.gridSpacing),
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
        ),
      ),
    );
  }
}

// ── Empty ──────────────────────────────────────────────────────────────────
class _EmptyView extends StatelessWidget {
  final TransactionsMetrics metrics;
  final String filter;

  const _EmptyView({required this.metrics, required this.filter});

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    final m = metrics;
    final isFiltered = filter != 'All';

    return LayoutBuilder(
      builder: (context, constraints) => SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: ConstrainedBox(
          constraints: BoxConstraints(minHeight: constraints.maxHeight),
          child: Center(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: m.pageHPad),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: m.emptyIllustration,
                    height: m.emptyIllustration,
                    decoration: BoxDecoration(
                      color: c.brandSoft,
                      shape: BoxShape.circle,
                    ),
                    alignment: Alignment.center,
                    child: Icon(
                      Icons.receipt_long_outlined,
                      size: m.emptyIllustration * 0.42,
                      color: c.brand,
                    ),
                  ),

                  SizedBox(height: m.gapLg),

                  Text(
                    isFiltered
                        ? 'No $filter transactions'
                        : 'No transactions yet',
                    textAlign: TextAlign.center,
                    style: AppTextStyles.titleLarge.copyWith(
                      color: c.textPrimary,
                      fontFamily: 'Inter',
                      fontWeight: FontWeight.w700,
                      fontSize: m.emptyTitleSize,
                    ),
                  ),

                  SizedBox(height: m.gapSm),

                  Text(
                    isFiltered
                        ? 'Try a different filter to see more.'
                        : 'Your payments and refunds will\nappear here.',
                    textAlign: TextAlign.center,
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: c.textSecondary,
                      fontFamily: 'Inter',
                      fontSize: m.emptySubSize,
                      height: 1.45,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ── Error ──────────────────────────────────────────────────────────────────
class _ErrorView extends StatelessWidget {
  final TransactionsMetrics metrics;
  final String message;

  const _ErrorView({required this.metrics, required this.message});

  @override
  Widget build(BuildContext context) {
    final colors = context.c;
    final m = metrics;

    return LayoutBuilder(
      builder: (context, constraints) => RefreshIndicator(
        onRefresh: context.read<TransactionsCubit>().loadTransactions,
        color: colors.brand,
        backgroundColor: colors.surface,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: constraints.maxHeight),
            child: Center(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: m.pageHPad),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: m.emptyIllustration,
                      height: m.emptyIllustration,
                      decoration: BoxDecoration(
                        color: colors.brandSoft,
                        shape: BoxShape.circle,
                      ),
                      alignment: Alignment.center,
                      child: Icon(
                        Icons.wifi_off_rounded,
                        size: m.emptyIllustration * 0.42,
                        color: colors.brand,
                      ),
                    ),

                    SizedBox(height: m.gapLg),

                    Text(
                      'Could not load transactions',
                      textAlign: TextAlign.center,
                      style: AppTextStyles.titleLarge.copyWith(
                        color: colors.textPrimary,
                        fontFamily: 'Inter',
                        fontWeight: FontWeight.w700,
                        fontSize: m.emptyTitleSize,
                      ),
                    ),

                    SizedBox(height: m.gapSm),

                    Text(
                      message,
                      textAlign: TextAlign.center,
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: colors.textSecondary,
                        fontFamily: 'Inter',
                        fontSize: m.emptySubSize,
                        height: 1.45,
                      ),
                    ),

                    SizedBox(height: m.gapLg),

                    SizedBox(
                      width: m.isTablet ? 240 : null,
                      height: m.btnHeight,
                      child: Material(
                        color: colors.brand,
                        borderRadius: BorderRadius.circular(12),
                        clipBehavior: Clip.antiAlias,
                        child: InkWell(
                          onTap: () => context
                              .read<TransactionsCubit>()
                              .loadTransactions(),
                          child: Padding(
                            padding: EdgeInsets.symmetric(
                              horizontal: m.pageHPad,
                            ),
                            child: Center(
                              child: Text(
                                'RETRY',
                                style: AppTextStyles.buttonText.copyWith(
                                  color: colors.surface,
                                  fontFamily: 'Inter',
                                  fontWeight: FontWeight.w700,
                                  fontSize: m.btnFontSize,
                                  letterSpacing: 0.4,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
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
}