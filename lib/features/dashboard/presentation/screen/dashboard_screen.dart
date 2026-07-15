import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/router/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/email_qr_sheet.dart';
import '../../../../core/widgets/glass/glass_scaffold.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_event.dart';
import '../../../auth/presentation/bloc/auth_state.dart';
import '../../../products/presentation/widgets/product_card.dart';
import '../bloc/dashboard_cubit.dart';
import '../bloc/dashboard_state.dart';
import '../models/dashboard_mock_data.dart';
import '../widgets/dashboard_app_bar.dart';
import '../widgets/quick_action_row.dart';
import '../widgets/recent_orders_section.dart';
import '../widgets/sales_trend_chart.dart';
import '../widgets/stat_card.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => DashboardCubit()..load(),
      child: BlocBuilder<DashboardCubit, DashboardState>(
        builder: (context, state) {
          final greetingName = state is DashboardLoaded
              ? state.vendorName
              : '...';
          final avatarInitial = greetingName.isNotEmpty ? greetingName[0] : 'V';

          return GlassScaffold(
            body: CustomScrollView(
              slivers: [
                DashboardAppBar(
                  greetingName: greetingName,
                  shopName: state is DashboardLoaded ? state.shopName : '',
                  avatarInitial: avatarInitial,
                  hasUnreadNotifications: true,
                  onNotificationsTap: () {},
                  onLogoutTap: () {
                    context.read<AuthBloc>().add(const LogoutRequested());
                  },
                ),
                if (state is DashboardLoading || state is DashboardInitial)
                  const SliverFillRemaining(
                    child: Center(
                      child: CircularProgressIndicator(color: AppColors.primary),
                    ),
                  )
                else if (state is DashboardError)
                  SliverFillRemaining(
                    child: Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.error_outline_rounded,
                              size: 40, color: context.colors.textSecondary),
                          const SizedBox(height: 12),
                          Text(state.message,
                              textAlign: TextAlign.center,
                              style: AppTextStyles.bodyMedium
                                  .copyWith(color: context.colors.textSecondary)),
                          const SizedBox(height: 12),
                          OutlinedButton(
                            onPressed: () =>
                                context.read<DashboardCubit>().load(),
                            child: const Text('Retry'),
                          ),
                        ],
                      ),
                    ),
                  )
                else if (state is DashboardLoaded)
                  SliverToBoxAdapter(
                    child: _DashboardBody(state: state),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _DashboardBody extends StatelessWidget {
  final DashboardLoaded state;

  const _DashboardBody({required this.state});

  @override
  Widget build(BuildContext context) {
    final stats = state.stats;
    final colors = context.colors;

    return Padding(
      // Extra bottom padding keeps content clear of the floating tab bar.
      padding: const EdgeInsets.fromLTRB(
        AppDimensions.md,
        0,
        AppDimensions.md,
        88,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // const SizedBox(height: AppDimensions.md),
          // Align(
          //   alignment: Alignment.centerRight,
          //   child: Text(dateLabel,
          //       style: TextStyle(color: Colors.grey[500], fontSize: 13)),
          // ),
          const SizedBox(height: AppDimensions.md),

          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  StatCard(
                    title: 'Total Products',
                    value: '${stats.totalProducts}',
                    icon: Icons.inventory_2_outlined,
                    iconColor: AppColors.info,
                    iconBackground: colors.infoTint,
                  ),
                  const SizedBox(width: AppDimensions.sm + 4),
                  StatCard(
                    title: 'Total Orders',
                    value: '${stats.totalOrders}',
                    icon: Icons.shopping_bag_outlined,
                    iconColor: colors.purpleFg,
                    iconBackground: colors.purpleTint,
                  ),
                  const SizedBox(width: AppDimensions.sm + 4),
                  StatCard(
                    title: 'Pending Orders',
                    value: '${stats.pendingOrders}',
                    icon: Icons.hourglass_empty,
                    iconColor: colors.warningFg,
                    iconBackground: colors.warningTint,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: AppDimensions.lg - 4),

          SalesTrendChart(points: DashboardMockData.salesTrend),
          const SizedBox(height: AppDimensions.lg - 4),

          // LowStockBanner(count: DashboardMockData.lowStockCount, onManageTap: () {}),
          // const SizedBox(height: AppDimensions.lg - 4),

          Text('Quick Actions', style: AppTextStyles.titleLarge),
          const SizedBox(height: AppDimensions.sm),
          QuickActionRow(
            actions: [
              QuickAction(
                icon: Icons.add_box_outlined,
                label: 'Add product',
                iconColor: AppColors.info,
                iconBackground: colors.infoTint,
                onTap: () => context.push(AppRoutes.vendorProductCreate),
              ),
              QuickAction(
                icon: Icons.list_alt,
                label: 'View orders',
                iconColor: colors.purpleFg,
                iconBackground: colors.purpleTint,
                onTap: () => context.go(AppRoutes.vendorTransactions),
              ),
              QuickAction(
                icon: Icons.qr_code,
                label: 'My QR code',
                iconColor: colors.successFg,
                iconBackground: colors.successTint,
                onTap: () {
                  final authState = context.read<AuthBloc>().state;
                  if (authState is AuthAuthenticated) {
                    showEmailQrSheet(context, email: authState.user.email);
                  }
                },
              ),
              QuickAction(
                icon: Icons.bar_chart,
                label: 'Reports',
                iconColor: colors.warningFg,
                iconBackground: colors.warningTint,
                onTap: () => context.go(AppRoutes.vendorAnalytics),
              ),
            ],
          ),
          const SizedBox(height: AppDimensions.sm),

          if (state.recentOrders.isNotEmpty) ...[
            RecentOrdersSection(
              orders: state.recentOrders,
              productImages: {
                for (final p in state.products)
                  if (p.imageUrl != null) p.name.toLowerCase(): p.imageUrl!,
              },
              onSeeAllTap: () => context.go(AppRoutes.vendorTransactions),
            ),
            // const SizedBox(height: AppDimensions.lg),
          ],

          if (state.products.isNotEmpty) ...[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Your Products', style: AppTextStyles.titleLarge),
                TextButton(
                  onPressed: () => context.go(AppRoutes.vendorProducts),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text('See all'),
                      SizedBox(width: 2),
                      Icon(Icons.chevron_right, size: 18),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppDimensions.sm),
            for (final product in state.products)
              ProductCard(product: product),
            const SizedBox(height: AppDimensions.lg),
          ],
        ],
      ),
    );
  }
}
