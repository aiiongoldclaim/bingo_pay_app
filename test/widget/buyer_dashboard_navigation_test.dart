import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import 'package:bingo_pay/core/router/app_routes.dart';
import 'package:bingo_pay/features/customer/dashboard/presentation/cubit/buyer_dashboard_cubit.dart';
import 'package:bingo_pay/features/customer/dashboard/presentation/cubit/buyer_dashboard_state.dart';
import 'package:bingo_pay/features/customer/dashboard/presentation/screens/buyer_dashboard_screen.dart';
import 'package:bingo_pay/features/customer/shop/presentation/screens/buyer_shell_screen.dart';

class _StubScreen extends StatelessWidget {
  final String label;
  const _StubScreen(this.label);
  @override
  Widget build(BuildContext context) => Scaffold(body: Text(label));
}

/// Builds a GoRouter starting at [initialLocation].
///
/// Injects [cubit] via [BlocProvider.value] so tests can pre-seed state and
/// avoid the 500 ms loadDashboard timer.
GoRouter _buildRouter({
  required BuyerDashboardCubit cubit,
  String initialLocation = AppRoutes.buyerHome,
}) {
  return GoRouter(
    initialLocation: initialLocation,
    routes: [
      ShellRoute(
        builder: (context, state, child) =>
            BuyerShellScreen(location: state.uri.path, child: child),
        routes: [
          GoRoute(
            path: AppRoutes.buyerHome,
            builder: (_, _) => const _StubScreen('home'),
          ),
          GoRoute(
            path: AppRoutes.buyerDashboard,
            builder: (_, _) => BlocProvider<BuyerDashboardCubit>.value(
              value: cubit,
              child: const BuyerDashboardScreen(),
            ),
          ),
          GoRoute(
            path: AppRoutes.buyerSettings,
            builder: (_, _) => const _StubScreen('settings-screen'),
          ),
          GoRoute(
            path: AppRoutes.buyerProfile,
            builder: (_, _) => const _StubScreen('profile-screen'),
          ),
          GoRoute(
            path: AppRoutes.buyerNotifications,
            builder: (_, _) => const _StubScreen('notifications-screen'),
          ),
          GoRoute(
            path: AppRoutes.buyerAddresses,
            builder: (_, _) => const _StubScreen('addresses-screen'),
          ),
          GoRoute(
            path: AppRoutes.buyerPayments,
            builder: (_, _) => const _StubScreen('payments-screen'),
          ),
          GoRoute(
            path: AppRoutes.buyerTransactionDetail,
            builder: (context, state) =>
                _StubScreen('order-${state.pathParameters['id']}'),
          ),
        ],
      ),
    ],
  );
}

BuyerDashboardData _dashboardData({
  List<RecentOrder> recentOrders = const [],
  ActiveOrder? activeOrder,
  List<Address> addresses = const [],
  List<PaymentMethod> paymentMethods = const [],
}) {
  return BuyerDashboardData(
    profile: BuyerProfile.mock(name: 'Jane Doe', statusLabel: 'Verified'),
    recentOrders: recentOrders,
    activeOrder: activeOrder,
    savedItems: const [],
    addresses: addresses,
    paymentMethods: paymentMethods,
    rewards: const RewardSummary.empty(),
  );
}

/// Builds the test app starting directly at the dashboard route with [data]
/// already loaded. No async timer involved.
Future<void> pumpDashboard(
  WidgetTester tester,
  BuyerDashboardData data,
) async {
  final cubit = BuyerDashboardCubit();
  cubit.emit(BuyerDashboardState.loaded(data));

  await tester.pumpWidget(
    MaterialApp.router(
      routerConfig: _buildRouter(
        cubit: cubit,
        initialLocation: AppRoutes.buyerDashboard,
      ),
    ),
  );
  await tester.pump();
  addTearDown(cubit.close);
}

void main() {
  group('Buyer shell navigation', () {
    testWidgets('Account tab navigates to buyer dashboard', (tester) async {
      final cubit = BuyerDashboardCubit();
      cubit.emit(BuyerDashboardState.loaded(_dashboardData()));

      await tester.pumpWidget(
        MaterialApp.router(
          routerConfig: _buildRouter(cubit: cubit),
        ),
      );
      await tester.pump();

      await tester.tap(find.text('Account'));
      await tester.pumpAndSettle();

      expect(find.byType(BuyerDashboardScreen), findsOneWidget);
      addTearDown(cubit.close);
    });
  });

  group('Dashboard outbound navigation', () {
    testWidgets('Settings quick action navigates to settings', (tester) async {
      await pumpDashboard(tester, _dashboardData());

      await tester.tap(find.text('Settings'));
      await tester.pumpAndSettle();

      expect(find.text('settings-screen'), findsOneWidget);
    });

    testWidgets('Profile quick action navigates to profile', (tester) async {
      await pumpDashboard(tester, _dashboardData());

      await tester.tap(find.text('Profile'));
      await tester.pumpAndSettle();

      expect(find.text('profile-screen'), findsOneWidget);
    });

    testWidgets('Notifications quick action navigates to notifications',
        (tester) async {
      await pumpDashboard(tester, _dashboardData());

      await tester.tap(find.text('Notifications'));
      await tester.pumpAndSettle();

      expect(find.text('notifications-screen'), findsOneWidget);
    });

    testWidgets('Addresses shortcut navigates to addresses', (tester) async {
      await pumpDashboard(
        tester,
        _dashboardData(
          addresses: [const Address(id: 'A1', line1: '1 Main St', city: 'NY')],
        ),
      );

      await tester.tap(find.text('Addresses'));
      await tester.pumpAndSettle();

      expect(find.text('addresses-screen'), findsOneWidget);
    });

    testWidgets('Payment methods shortcut navigates to payments',
        (tester) async {
      await pumpDashboard(
        tester,
        _dashboardData(
          paymentMethods: [
            const PaymentMethod(id: 'P1', label: 'Visa', suffix: '**** 0001'),
          ],
        ),
      );

      await tester.tap(find.text('Payment Methods'));
      await tester.pumpAndSettle();

      expect(find.text('payments-screen'), findsOneWidget);
    });

    testWidgets('Track Order button navigates to order detail', (tester) async {
      await pumpDashboard(
        tester,
        _dashboardData(
          activeOrder: const ActiveOrder(
            id: 'ORD-99',
            statusLabel: 'Out for Delivery',
            etaLabel: 'Today',
          ),
        ),
      );

      await tester.tap(find.text('Track Order'));
      await tester.pumpAndSettle();

      expect(find.text('order-ORD-99'), findsOneWidget);
    });

    testWidgets('Tapping a recent order navigates to order detail',
        (tester) async {
      await pumpDashboard(
        tester,
        _dashboardData(
          recentOrders: [
            const RecentOrder(
              id: 'ORD-42',
              title: 'Blue Jacket',
              statusLabel: 'Delivered',
            ),
          ],
        ),
      );

      await tester.tap(find.text('Blue Jacket'));
      await tester.pumpAndSettle();

      expect(find.text('order-ORD-42'), findsOneWidget);
    });
  });
}
