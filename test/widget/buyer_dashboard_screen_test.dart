import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import 'package:bingo_pay/features/customer/dashboard/presentation/cubit/buyer_dashboard_cubit.dart';
import 'package:bingo_pay/features/customer/dashboard/presentation/cubit/buyer_dashboard_state.dart';
import 'package:bingo_pay/features/customer/dashboard/presentation/screens/buyer_dashboard_screen.dart';

GoRouter _buildRouter(BuyerDashboardCubit cubit) {
  return GoRouter(
    initialLocation: '/dashboard',
    routes: [
      GoRoute(
        path: '/dashboard',
        builder: (_, _) => BlocProvider<BuyerDashboardCubit>.value(
          value: cubit,
          child: const BuyerDashboardScreen(),
        ),
      ),
      GoRoute(path: '/buyer/profile', builder: (_, _) => const _Stub('profile')),
      GoRoute(path: '/buyer/settings', builder: (_, _) => const _Stub('settings')),
      GoRoute(path: '/buyer/notifications', builder: (_, _) => const _Stub('notifications')),
      GoRoute(path: '/buyer/wishlist', builder: (_, _) => const _Stub('wishlist')),
      GoRoute(path: '/buyer/addresses', builder: (_, _) => const _Stub('addresses')),
      GoRoute(path: '/buyer/payments', builder: (_, _) => const _Stub('payments')),
      GoRoute(
        path: '/buyer/transactions/:id',
        builder: (_, state) => _Stub('order-${state.pathParameters['id']}'),
      ),
    ],
  );
}

Widget _buildTestApp(BuyerDashboardCubit cubit) =>
    MaterialApp.router(routerConfig: _buildRouter(cubit));

class _Stub extends StatelessWidget {
  final String label;
  const _Stub(this.label);
  @override
  Widget build(BuildContext context) => Scaffold(body: Text(label));
}

BuyerDashboardData _loadedData({
  List<RecentOrder> recentOrders = const [],
  ActiveOrder? activeOrder,
  List<SavedItem> savedItems = const [],
  List<Address> addresses = const [],
  List<PaymentMethod> paymentMethods = const [],
  RewardSummary rewards = const RewardSummary.empty(),
}) {
  return BuyerDashboardData(
    profile: BuyerProfile.mock(name: 'John Doe', statusLabel: 'Verified'),
    recentOrders: recentOrders,
    activeOrder: activeOrder,
    savedItems: savedItems,
    addresses: addresses,
    paymentMethods: paymentMethods,
    rewards: rewards,
  );
}

void main() {
  group('BuyerDashboardScreen', () {
    testWidgets('renders loading state correctly', (tester) async {
      final cubit = BuyerDashboardCubit();
      cubit.emit(const BuyerDashboardState.loading());

      await tester.pumpWidget(_buildTestApp(cubit));

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('renders error state with retry button', (tester) async {
      final cubit = BuyerDashboardCubit();
      cubit.emit(const BuyerDashboardState.error('Failed to load dashboard: test error'));

      await tester.pumpWidget(_buildTestApp(cubit));

      expect(find.text('Failed to load dashboard: test error'), findsOneWidget);
      expect(find.text('Retry'), findsOneWidget);
      expect(find.byIcon(Icons.error_outline), findsOneWidget);
    });

    testWidgets('renders dashboard header when data is loaded', (tester) async {
      final cubit = BuyerDashboardCubit();
      cubit.emit(BuyerDashboardState.loaded(_loadedData()));

      await tester.pumpWidget(_buildTestApp(cubit));

      expect(find.text('John Doe'), findsOneWidget);
      expect(find.text('Verified'), findsOneWidget);
      expect(find.text('JD'), findsOneWidget);
    });

    testWidgets('renders quick actions buttons', (tester) async {
      final cubit = BuyerDashboardCubit();
      cubit.emit(BuyerDashboardState.loaded(_loadedData()));

      await tester.pumpWidget(_buildTestApp(cubit));

      expect(find.text('Quick Actions'), findsOneWidget);
      expect(find.text('Profile'), findsOneWidget);
      expect(find.text('Settings'), findsOneWidget);
      expect(find.text('Notifications'), findsOneWidget);
    });

    testWidgets('renders recent orders section', (tester) async {
      final cubit = BuyerDashboardCubit();
      cubit.emit(BuyerDashboardState.loaded(_loadedData(
        recentOrders: [
          const RecentOrder(id: 'ORD-001', title: 'Blue Jacket', statusLabel: 'Delivered'),
          const RecentOrder(id: 'ORD-002', title: 'White Shoes', statusLabel: 'In Transit'),
        ],
      )));

      await tester.pumpWidget(_buildTestApp(cubit));

      expect(find.text('Recent Orders'), findsOneWidget);
      expect(find.text('Blue Jacket'), findsOneWidget);
      expect(find.text('White Shoes'), findsOneWidget);
      expect(find.text('Delivered'), findsOneWidget);
      expect(find.text('In Transit'), findsOneWidget);
    });

    testWidgets('renders active order section when present', (tester) async {
      final cubit = BuyerDashboardCubit();
      cubit.emit(BuyerDashboardState.loaded(_loadedData(
        activeOrder: const ActiveOrder(
          id: 'ORD-ACTIVE',
          statusLabel: 'Out for Delivery',
          etaLabel: 'Today, 2-6 PM',
        ),
      )));

      await tester.pumpWidget(_buildTestApp(cubit));

      expect(find.text('Active Order'), findsOneWidget);
      expect(find.text('Out for Delivery'), findsOneWidget);
      expect(find.text('Today, 2-6 PM'), findsOneWidget);
      expect(find.text('Track Order'), findsOneWidget);
    });

    testWidgets('renders saved items section', (tester) async {
      final cubit = BuyerDashboardCubit();
      cubit.emit(BuyerDashboardState.loaded(_loadedData(
        savedItems: [
          const SavedItem(id: 'ITEM-001', title: 'Red Shoes'),
          const SavedItem(id: 'ITEM-002', title: 'Blue Shirt'),
        ],
      )));

      await tester.pumpWidget(_buildTestApp(cubit));

      expect(find.text('Saved Items'), findsOneWidget);
      expect(find.text('Red Shoes'), findsOneWidget);
      expect(find.text('Blue Shirt'), findsOneWidget);
      expect(find.text('View all'), findsOneWidget);
    });

    testWidgets('renders account shortcuts section', (tester) async {
      final cubit = BuyerDashboardCubit();
      cubit.emit(BuyerDashboardState.loaded(_loadedData(
        addresses: [const Address(id: 'ADDR-001', line1: '123 Main St', city: 'New York, NY')],
        paymentMethods: [const PaymentMethod(id: 'PM-001', label: 'Visa', suffix: '**** 1234')],
        rewards: const RewardSummary(walletBalance: 500, rewardPoints: 100),
      )));

      await tester.pumpWidget(_buildTestApp(cubit));

      expect(find.text('Account Shortcuts'), findsOneWidget);
      expect(find.text('Addresses'), findsOneWidget);
      expect(find.text('1 saved address'), findsOneWidget);
      expect(find.text('Payment Methods'), findsOneWidget);
      expect(find.text('1 saved method'), findsOneWidget);
      expect(find.text('Your Rewards'), findsOneWidget);
      expect(find.text('₹500'), findsOneWidget);
      expect(find.text('100'), findsOneWidget);
    });

    testWidgets('Profile quick action is tappable and navigates', (tester) async {
      final cubit = BuyerDashboardCubit();
      cubit.emit(BuyerDashboardState.loaded(_loadedData()));

      await tester.pumpWidget(_buildTestApp(cubit));
      await tester.tap(find.text('Profile'));
      await tester.pumpAndSettle();

      expect(find.text('profile'), findsOneWidget);
    });

    testWidgets('Settings quick action is tappable and navigates', (tester) async {
      final cubit = BuyerDashboardCubit();
      cubit.emit(BuyerDashboardState.loaded(_loadedData()));

      await tester.pumpWidget(_buildTestApp(cubit));
      await tester.tap(find.text('Settings'));
      await tester.pumpAndSettle();

      expect(find.text('settings'), findsOneWidget);
    });

    testWidgets('Notifications quick action is tappable and navigates', (tester) async {
      final cubit = BuyerDashboardCubit();
      cubit.emit(BuyerDashboardState.loaded(_loadedData()));

      await tester.pumpWidget(_buildTestApp(cubit));
      await tester.tap(find.text('Notifications'));
      await tester.pumpAndSettle();

      expect(find.text('notifications'), findsOneWidget);
    });

    testWidgets('refresh indicator is present', (tester) async {
      final cubit = BuyerDashboardCubit();
      cubit.emit(BuyerDashboardState.loaded(_loadedData()));

      await tester.pumpWidget(_buildTestApp(cubit));

      expect(find.byType(RefreshIndicator), findsOneWidget);
    });

    testWidgets('empty dashboard sections are not shown', (tester) async {
      final cubit = BuyerDashboardCubit();
      cubit.emit(BuyerDashboardState.loaded(_loadedData()));

      await tester.pumpWidget(_buildTestApp(cubit));

      expect(find.text('Recent Orders'), findsNothing);
      expect(find.text('Saved Items'), findsNothing);
    });
  });
}
