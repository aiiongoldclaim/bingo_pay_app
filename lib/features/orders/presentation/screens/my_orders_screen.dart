// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:go_router/go_router.dart';
// import 'package:sizer/sizer.dart';
// import 'package:bingo_pay/core/theme/theme_colors.dart';
// import 'package:bingo_pay/core/theme/app_text_styles.dart';
// import '../../../../core/di/injection.dart';
// import '../../../../core/router/app_routes.dart';
// import '../../cubit/orders_cubit.dart';
// import '../../cubit/orders_state.dart';
// import '../../data/models/order_model.dart';
// import '../widgets/order_card.dart';
// import '../widgets/order_filter_table.dart';
//
// class OrdersScreen extends StatelessWidget {
//   const OrdersScreen({super.key});
//
//   @override
//   Widget build(BuildContext context) {
//     return BlocProvider(
//       create: (_) => getIt<OrdersCubit>()..loadOrders(),
//       child: const _OrdersView(),
//     );
//   }
// }
//
// class _OrdersView extends StatelessWidget {
//   const _OrdersView();
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: ThemeColors.background,
//       appBar: _buildAppBar(context),
//       body: BlocBuilder<OrdersCubit, OrdersState>(
//         builder: (context, state) {
//           if (state is OrdersLoading || state is OrdersInitial) {
//             return const Center(
//               child: CircularProgressIndicator(color: ThemeColors.blue),
//             );
//           }
//
//           if (state is OrdersError) {
//             return _buildError(context, state.message);
//           }
//
//           if (state is OrdersLoaded) {
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
//       leading: Row(
//         children: [
//           const Spacer(),
//           Container(
//             decoration: BoxDecoration(
//               color: ThemeColors.surface,
//               borderRadius: BorderRadius.circular(12),
//               border: Border.all(color: ThemeColors.line),
//             ),
//             child: IconButton(
//               icon: Icon(
//                 Icons.arrow_back_ios_new_rounded,
//                 size: 18.sp,
//                 color: ThemeColors.ink,
//               ),
//               onPressed: () => context.pop(),
//             ),
//           ),
//         ],
//       ),
//
//       title: Text(
//         'My Orders',
//         style: AppTextStyles.headlineMedium.copyWith(
//           fontSize: 20.sp,
//           fontWeight: FontWeight.w700,
//         ),
//       ),
//     );
//   }
//
//   Widget _buildBody(BuildContext context, OrdersLoaded state) {
//     return RefreshIndicator(
//       onRefresh: context.read<OrdersCubit>().loadOrders,
//       color: ThemeColors.blue,
//       backgroundColor: ThemeColors.white,
//       child: Column(
//         children: [
//           /// ── Summary ──
//           Padding(
//             padding: EdgeInsets.fromLTRB(4.w, 1.h, 4.w, 0),
//             child: Align(
//               alignment: Alignment.centerLeft,
//               child: Text(
//                 '${state.all.length} ${state.all.length == 1 ? 'order' : 'orders'}',
//                 style: AppTextStyles.bodyMedium.copyWith(
//                   fontSize: 15.sp,
//                   color: ThemeColors.inkMid,
//                   fontWeight: FontWeight.w700,
//                 ),
//               ),
//             ),
//           ),
//
//           /// ── Filter Tabs ──
//           Padding(
//             padding: EdgeInsets.fromLTRB(4.w, 1.h, 4.w, 1.5.h),
//             child: OrderFilterTabs(
//               activeFilter: state.activeFilter,
//               onFilterChanged: (f) => context.read<OrdersCubit>().filterOrders(f),
//             ),
//           ),
//
//           /// ── Orders List ──
//           Expanded(
//             child: state.filtered.isEmpty
//                 ? _buildEmpty()
//                 : ListView.separated(
//                     padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
//                     physics: const AlwaysScrollableScrollPhysics(),
//                     itemCount: state.filtered.length,
//                     separatorBuilder: (_, _) => SizedBox(height: 2.h),
//                     itemBuilder: (context, index) {
//                       final order = state.filtered[index];
//                       return OrderCard(
//                         order: order,
//                         onDetails: () => _goToDetail(context, order),
//                       );
//                     },
//                   ),
//           ),
//
//           SizedBox(height: 10.h),
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
//                   'No orders found',
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
//         onRefresh: context.read<OrdersCubit>().loadOrders,
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
//                       onPressed: () => context.read<OrdersCubit>().loadOrders(),
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
//   void _goToDetail(BuildContext context, OrderModel order) {
//     context.push(AppRoutes.orderDetail, extra: order);
//   }
// }
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/di/injection.dart';
import '../../../../core/router/app_routes.dart';
import '../../../../core/theme/app_theme_colors.dart';
import '../../cubit/orders_cubit.dart';
import '../../cubit/orders_state.dart';
import '../../data/models/order_model.dart';
import '../widgets/order_card.dart';
import '../widgets/order_filter_table.dart';
import '../widgets/order_status_style.dart';
import '../widgets/orders_header.dart';
import '../widgets/orders_metrics.dart';

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
    final m = OrdersMetrics.of(context);
    final c = context.c;

    return Scaffold(
      backgroundColor: c.background,
      body: SafeArea(
        bottom: false,
        child: Center(
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: m.contentMaxWidth),
            child: Column(
              children: [
                OrdersHeader(
                  metrics: m,
                  title: 'My Orders',
                  subtitle: 'Track and manage all your orders',
                  onBack: () => context.pop(),
                  onSearch: () => context.push(AppRoutes.search),
                ),
                SizedBox(height: m.sectionGap * 0.9),
                Expanded(
                  child: BlocBuilder<OrdersCubit, OrdersState>(
                    builder: (context, state) {
                      if (state is OrdersLoading || state is OrdersInitial) {
                        return Center(
                          child: CircularProgressIndicator(color: c.brand),
                        );
                      }
                      if (state is OrdersError) {
                        return _ErrorView(metrics: m, message: state.message);
                      }
                      if (state is OrdersLoaded) {
                        return _LoadedView(metrics: m, state: state);
                      }
                      return const SizedBox.shrink();
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────

class _LoadedView extends StatelessWidget {
  const _LoadedView({required this.metrics, required this.state});

  final OrdersMetrics metrics;
  final OrdersLoaded state;

  /// Tab badges — `state.all` se derive, cubit ko touch kiye bina
  Map<String, int> _counts() {
    final map = <String, int>{'All': state.all.length};
    for (final filter in OrderFilterTabs.defaultFilters.skip(1)) {
      map[filter] = state.all
          .where((o) => OrderStatusStyle.matchesFilter(filter, o.orderStatus))
          .length;
    }
    return map;
  }

  void _openDetail(BuildContext context, OrderModel order) {
    context.push(AppRoutes.orderDetail, extra: order);
  }

  List<OrderModel> _visibleOrders() {
    if (state.activeFilter == 'All') return state.all;
    return state.all
        .where(
          (o) =>
              OrderStatusStyle.matchesFilter(state.activeFilter, o.orderStatus),
        )
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final m = metrics;
    final c = context.c;
    final orders = _visibleOrders(); // NEW

    return RefreshIndicator(
      onRefresh: context.read<OrdersCubit>().loadOrders,
      color: c.brand,
      backgroundColor: c.surface,
      child: Column(
        children: [
          OrderFilterTabs(
            metrics: m,
            activeFilter: state.activeFilter,
            counts: _counts(),
            onFilterChanged: (f) => context.read<OrdersCubit>().filterOrders(f),
          ),
          SizedBox(height: m.sectionGap),
          Expanded(
            child:
                orders
                    .isEmpty // CHANGED
                ? _EmptyView(metrics: m)
                : ListView.separated(
                    padding: EdgeInsets.fromLTRB(
                      m.pagePadding,
                      0,
                      m.pagePadding,
                      m.sectionGap * 3 + MediaQuery.paddingOf(context).bottom,
                    ),
                    physics: const AlwaysScrollableScrollPhysics(),
                    itemCount: orders.length, // CHANGED
                    separatorBuilder: (_, __) => SizedBox(height: m.sectionGap),
                    itemBuilder: (context, index) {
                      final order = orders[index]; // CHANGED
                      return OrderCard(
                        metrics: m,
                        order: order,
                        onDetails: () => _openDetail(context, order),
                        onCta: () => _openDetail(context, order),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────

class _EmptyView extends StatelessWidget {
  const _EmptyView({required this.metrics});
  final OrdersMetrics metrics;

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    final m = metrics;

    return LayoutBuilder(
      builder: (context, constraints) => SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: ConstrainedBox(
          constraints: BoxConstraints(minHeight: constraints.maxHeight),
          child: Center(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: m.pagePadding * 2),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: m.thumbSize * 1.5,
                    height: m.thumbSize * 1.5,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: c.surfaceAlt,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.receipt_long_outlined,
                      size: m.thumbSize * 0.62,
                      color: c.brand,
                    ),
                  ),
                  SizedBox(height: m.sectionGap),
                  Text(
                    'No orders found',
                    style: TextStyle(
                      fontSize: m.productNameSize * 1.2,
                      fontWeight: FontWeight.w700,
                      color: c.textPrimary,
                    ),
                  ),
                  SizedBox(height: m.sectionGap * 0.4),
                  Text(
                    'Your orders will appear here once you place one.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: m.productMetaSize * 1.15,
                      height: 1.5,
                      color: c.textSecondary,
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

class _ErrorView extends StatelessWidget {
  const _ErrorView({required this.metrics, required this.message});

  final OrdersMetrics metrics;
  final String message;

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    final m = metrics;

    return LayoutBuilder(
      builder: (context, constraints) => RefreshIndicator(
        onRefresh: context.read<OrdersCubit>().loadOrders,
        color: c.brand,
        backgroundColor: c.surface,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: constraints.maxHeight),
            child: Center(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: m.pagePadding * 2),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.error_outline_rounded,
                      size: m.thumbSize * 0.7,
                      color: c.textMuted,
                    ),
                    SizedBox(height: m.sectionGap),
                    Text(
                      message,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: m.productMetaSize * 1.15,
                        height: 1.5,
                        color: c.textSecondary,
                      ),
                    ),
                    SizedBox(height: m.sectionGap),
                    SizedBox(
                      height: m.ctaHeight * 1.2,
                      child: OutlinedButton(
                        onPressed: () =>
                            context.read<OrdersCubit>().loadOrders(),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: c.brand,
                          side: BorderSide(color: c.brand, width: 1.3),
                          padding: EdgeInsets.symmetric(
                            horizontal: m.pagePadding * 2,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: Text(
                          'Retry',
                          style: TextStyle(
                            fontSize: m.ctaFontSize,
                            fontWeight: FontWeight.w600,
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
