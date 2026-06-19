import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../../core/router/app_routes.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_dimensions.dart';
import '../../../../../core/widgets/app_loader.dart';
import '../cubit/buyer_dashboard_cubit.dart';
import '../cubit/buyer_dashboard_state.dart';
import '../widgets/dashboard_active_order_section.dart';
import '../widgets/dashboard_header_card.dart';
import '../widgets/dashboard_quick_actions.dart';
import '../widgets/dashboard_recent_orders_section.dart';
import '../widgets/dashboard_saved_items_section.dart';
import '../widgets/dashboard_shortcuts_section.dart';

class BuyerDashboardScreen extends StatefulWidget {
  const BuyerDashboardScreen({super.key});

  @override
  State<BuyerDashboardScreen> createState() => _BuyerDashboardScreenState();
}

class _BuyerDashboardScreenState extends State<BuyerDashboardScreen> {
  late final BuyerDashboardCubit _cubit;

  @override
  void initState() {
    super.initState();
    _cubit = context.read<BuyerDashboardCubit>();
    if (_cubit.state == const BuyerDashboardState.initial()) {
      _cubit.loadDashboard();
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<BuyerDashboardCubit, BuyerDashboardState>(
      builder: (context, state) {
        return Scaffold(
          backgroundColor: Colors.white,
          body: SafeArea(
            child: state.isLoading
                ? const Center(child: AppLoader())
                : state.errorMessage != null
                ? _ErrorState(
                    message: state.errorMessage!,
                    onRetry: _cubit.refreshDashboard,
                  )
                : state.data != null
                ? _LoadedState(data: state.data!)
                : const SizedBox.shrink(),
          ),
        );
      },
    );
  }
}

class _LoadedState extends StatelessWidget {
  final BuyerDashboardData data;

  const _LoadedState({required this.data});

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: () async {
        await context.read<BuyerDashboardCubit>().refreshDashboard();
      },
      child: ListView(
        padding: const EdgeInsets.symmetric(
          horizontal: AppDimensions.lg,
          vertical: AppDimensions.md,
        ),
        children: [
          // Dashboard header with profile summary
          DashboardHeaderCard(profile: data.profile),
          const SizedBox(height: AppDimensions.lg),

          // Active order status (if present)
          if (data.activeOrder != null) ...[
            DashboardActiveOrderSection(
              activeOrder: data.activeOrder!,
              onTrackOrder: () => context.go(
                AppRoutes.buyerTransactionPath(data.activeOrder!.id),
              ),
            ),
            const SizedBox(height: AppDimensions.lg),
          ],

          // Quick actions
          DashboardQuickActions(
            onProfileTap: () => _navigateToProfile(context),
            onSettingsTap: () => _navigateToSettings(context),
            onNotificationsTap: () => _navigateToNotifications(context),
          ),
          const SizedBox(height: AppDimensions.lg),

          // Recent orders section
          DashboardRecentOrdersSection(
            recentOrders: data.recentOrders,
            onOrderTap: (id) => context.go(AppRoutes.buyerTransactionPath(id)),
          ),
          const SizedBox(height: AppDimensions.lg),

          // Saved items section
          DashboardSavedItemsSection(
            savedItems: data.savedItems,
            onViewAll: () => _navigateToWishlist(context),
          ),
          const SizedBox(height: AppDimensions.lg),

          // Shortcuts section (addresses, payments, rewards)
          DashboardShortcutsSection(
            addresses: data.addresses,
            paymentMethods: data.paymentMethods,
            rewards: data.rewards,
            onAddressEdit: () => _navigateToAddresses(context),
            onPaymentEdit: () => _navigateToPayments(context),
          ),
          const SizedBox(height: AppDimensions.xl),
        ],
      ),
    );
  }

  void _navigateToProfile(BuildContext context) =>
      context.go(AppRoutes.buyerProfile);

  void _navigateToSettings(BuildContext context) =>
      context.go(AppRoutes.buyerSettings);

  void _navigateToNotifications(BuildContext context) =>
      context.go(AppRoutes.buyerNotifications);

  void _navigateToWishlist(BuildContext context) =>
      context.go(AppRoutes.buyerWishlist);

  void _navigateToAddresses(BuildContext context) =>
      context.go(AppRoutes.buyerAddresses);

  void _navigateToPayments(BuildContext context) =>
      context.go(AppRoutes.buyerPayments);
}

class _ErrorState extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _ErrorState({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppDimensions.lg),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: AppColors.error),
            const SizedBox(height: AppDimensions.lg),
            Text(
              message,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: AppDimensions.lg),
            ElevatedButton(onPressed: onRetry, child: const Text('Retry')),
          ],
        ),
      ),
    );
  }
}
