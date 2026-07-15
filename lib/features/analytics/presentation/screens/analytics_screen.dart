import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/router/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../../core/theme/app_glass.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/glass/glass_scaffold.dart';
import '../bloc/analytics_cubit.dart';
import '../bloc/analytics_state.dart';
import '../widgets/analytics_recent_orders_card.dart';
import '../widgets/analytics_summary_grid.dart';
import '../widgets/analytics_trend_chart.dart';
import '../widgets/catalog_card.dart';
import '../widgets/inventory_health_card.dart';
import '../widgets/orders_status_donut.dart';
import '../widgets/revenue_breakdown_card.dart';
import '../widgets/top_products_card.dart';

class AnalyticsScreen extends StatelessWidget {
  const AnalyticsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => AnalyticsCubit()..load(),
      child: GlassScaffold(
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          centerTitle: false,
          title: Builder(
            builder: (context) => Text(
              'Analytics',
              style: TextStyle(
                color: context.colors.textPrimary,
                fontSize: 24,
                fontWeight: FontWeight.w800,
                letterSpacing: -0.4,
              ),
            ),
          ),
        ),
        body: BlocBuilder<AnalyticsCubit, AnalyticsState>(
          builder: (context, state) {
            return switch (state) {
              AnalyticsInitial() ||
              AnalyticsLoading() => const Center(
                child: CircularProgressIndicator(color: AppColors.primary),
              ),
              AnalyticsError(:final message, :final period) => _ErrorView(
                message: message,
                onRetry: () => context.read<AnalyticsCubit>().load(period),
              ),
              AnalyticsLoaded() => _AnalyticsBody(state: state),
            };
          },
        ),
      ),
    );
  }
}

class _AnalyticsBody extends StatelessWidget {
  final AnalyticsLoaded state;

  const _AnalyticsBody({required this.state});

  @override
  Widget build(BuildContext context) {
    final analytics = state.analytics;
    final periodLabel = switch (state.period) {
      AnalyticsPeriod.week => '7 days',
      AnalyticsPeriod.month => '30 days',
      AnalyticsPeriod.quarter => '90 days',
    };

    return RefreshIndicator(
      color: AppColors.primary,
      onRefresh: () => context.read<AnalyticsCubit>().load(state.period),
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(
          AppDimensions.md,
          AppDimensions.md,
          AppDimensions.md,
          96,
        ),
        children: [
          _PeriodSelector(
            selected: state.period,
            onChanged: (p) => context.read<AnalyticsCubit>().load(p),
          ),
          const SizedBox(height: AppDimensions.sm),
          SizedBox(
            height: 2,
            child: state.refreshing
                ? const LinearProgressIndicator(
                    color: AppColors.primary,
                    minHeight: 2,
                  )
                : null,
          ),
          const SizedBox(height: AppDimensions.sm),
          // On refetch the old data stays visible, just dimmed — no
          // skeleton flash / layout jump.
          AnimatedOpacity(
            opacity: state.refreshing ? 0.55 : 1,
            duration: const Duration(milliseconds: 150),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                AnalyticsSummaryGrid(summary: analytics.summary),
                const SizedBox(height: AppDimensions.md),
                AnalyticsTrendChart(
                  points: analytics.timeseries,
                  periodLabel: periodLabel,
                ),
                const SizedBox(height: AppDimensions.md),
                OrdersStatusDonut(
                  orders: analytics.orders,
                  periodLabel: periodLabel,
                ),
                const SizedBox(height: AppDimensions.md),
                RevenueBreakdownCard(revenue: analytics.revenue),
                const SizedBox(height: AppDimensions.md),
                InventoryHealthCard(inventory: analytics.inventory),
                const SizedBox(height: AppDimensions.md),
                CatalogCard(catalog: analytics.catalog),
                if (analytics.topProducts.isNotEmpty) ...[
                  const SizedBox(height: AppDimensions.md),
                  TopProductsCard(
                    products: analytics.topProducts,
                    periodLabel: periodLabel,
                  ),
                ],
                if (analytics.recentOrders.isNotEmpty) ...[
                  const SizedBox(height: AppDimensions.md),
                  AnalyticsRecentOrdersCard(
                    orders: analytics.recentOrders,
                    onSeeAllTap: () =>
                        context.go(AppRoutes.vendorTransactions),
                  ),
                ],
                const SizedBox(height: AppDimensions.lg),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _PeriodSelector extends StatelessWidget {
  final AnalyticsPeriod selected;
  final ValueChanged<AnalyticsPeriod> onChanged;

  const _PeriodSelector({required this.selected, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Row(
      children: [
        for (final period in AnalyticsPeriod.values) ...[
          GestureDetector(
            onTap: () {
              if (period != selected) onChanged(period);
            },
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppDimensions.md,
                vertical: 6,
              ),
              decoration: BoxDecoration(
                color: period == selected
                    ? AppColors.primary
                    : context.glass.fill,
                borderRadius: BorderRadius.circular(
                  AppDimensions.radiusCircular,
                ),
                border: Border.all(
                  color: period == selected
                      ? AppColors.primary
                      : context.glass.border,
                ),
              ),
              child: Text(
                period.label,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: period == selected
                      ? Colors.white
                      : colors.textSecondary,
                ),
              ),
            ),
          ),
          const SizedBox(width: AppDimensions.sm),
        ],
      ],
    );
  }
}

class _ErrorView extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _ErrorView({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppDimensions.lg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.error_outline_rounded,
              size: 40,
              color: context.colors.textSecondary,
            ),
            const SizedBox(height: 12),
            Text(
              message,
              textAlign: TextAlign.center,
              style: AppTextStyles.bodyMedium.copyWith(
                color: context.colors.textSecondary,
              ),
            ),
            const SizedBox(height: 12),
            OutlinedButton(onPressed: onRetry, child: const Text('Retry')),
          ],
        ),
      ),
    );
  }
}
