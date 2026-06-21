import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../models/dashboard_mock_data.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../widgets/dashboard_app_bar.dart';
import '../widgets/low_stock_banner.dart';
import '../widgets/quick_action_row.dart';
import '../widgets/recent_orders_section.dart';
import '../widgets/sales_trend_chart.dart';
import '../widgets/stat_card.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_event.dart';
import '../../../auth/presentation/bloc/auth_state.dart';
import '../../../../core/widgets/email_qr_sheet.dart';



class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F5F7),
      body: CustomScrollView(
        slivers: [
          DashboardAppBar(
            greetingName: DashboardMockData.vendorName,
            shopName: DashboardMockData.shopName,
            avatarInitial: DashboardMockData.vendorName[0],
            hasUnreadNotifications: true,
            onNotificationsTap: () {},
            onLogoutTap: () {
              context.read<AuthBloc>().add(const LogoutRequested());
            },
          ),
          const SliverToBoxAdapter(child: _DashboardBody()),
        ],
      ),
    );
  }
}

class _DashboardBody extends StatelessWidget {
  const _DashboardBody();

  @override
  Widget build(BuildContext context) {
    final currency = NumberFormat.currency(locale: 'en_IN', symbol: '₹', decimalDigits: 0);
    final dateLabel = DateFormat('d MMM yyyy').format(DateTime.now());

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppDimensions.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: AppDimensions.md),
          Align(
            alignment: Alignment.centerRight,
            child: Text(dateLabel, style: TextStyle(color: Colors.grey[500], fontSize: 13)),
          ),
          const SizedBox(height: AppDimensions.sm),

          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  StatCard(
                    title: "Today's revenue",
                    value: currency.format(DashboardMockData.todaysRevenue),
                    icon: Icons.payments_outlined,
                    iconColor: AppColors.info,
                    iconBackground: AppColors.infoTint,
                    // trailing: Container(
                    //   padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    //   decoration: BoxDecoration(
                    //     color: AppColors.successTint,
                    //     borderRadius: BorderRadius.circular(AppDimensions.radiusCircular),
                    //   ),
                    //   child: Text(
                    //     '↑ ${DashboardMockData.revenueChangePercent.toInt()}% vs yesterday',
                    //     style: const TextStyle(fontSize: 11, color: Color(0xFF4C7A2D)),
                    //   ),
                    // ),
                  ),
                  const SizedBox(width: AppDimensions.sm + 4),
                  StatCard(
                    title: 'Total orders',
                    value: '${DashboardMockData.pendingOrders} pending',
                    icon: Icons.shopping_bag_outlined,
                    iconColor: AppColors.accentPurple,
                    iconBackground: AppColors.accentPurpleTint,
                  ),
                  const SizedBox(width: AppDimensions.sm + 4),
                  StatCard(
                    title: 'Pending payouts',
                    value: 'Explore',
                    icon: Icons.account_balance_wallet_outlined,
                    iconColor: const Color(0xFFB36B00),
                    iconBackground: AppColors.warningTint,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: AppDimensions.lg - 4),

          SalesTrendChart(points: DashboardMockData.salesTrend),
          const SizedBox(height: AppDimensions.lg - 4),

          LowStockBanner(count: DashboardMockData.lowStockCount, onManageTap: () {}),
          const SizedBox(height: AppDimensions.lg - 4),

          Text('Quick Actions', style: AppTextStyles.titleLarge),
          const SizedBox(height: AppDimensions.sm),
          QuickActionRow(
            actions: [
              QuickAction(
                icon: Icons.add_box_outlined,
                label: 'Add product',
                iconColor: AppColors.info,
                iconBackground: AppColors.infoTint,
                onTap: () {},
              ),
              QuickAction(
                icon: Icons.list_alt,
                label: 'View orders',
                iconColor: AppColors.accentPurple,
                iconBackground: AppColors.accentPurpleTint,
                onTap: () {},
              ),
              QuickAction(
                icon: Icons.qr_code,
                label: 'My QR code',
                iconColor: const Color(0xFF4C7A2D),
                iconBackground: AppColors.successTint,
                onTap: () {
                  final state = context.read<AuthBloc>().state;
                  if (state is AuthAuthenticated) {
                    showEmailQrSheet(context, email: state.user.email);
                  }
                },
              ),
              QuickAction(
                icon: Icons.bar_chart,
                label: 'Reports',
                iconColor: const Color(0xFFB36B00),
                iconBackground: AppColors.warningTint,
                onTap: () {},
              ),
            ],
          ),
          const SizedBox(height: AppDimensions.lg),

          RecentOrdersSection(orders: DashboardMockData.recentOrders, onSeeAllTap: () {}),
          const SizedBox(height: AppDimensions.lg),
        ],
      ),
    );
  }
}
