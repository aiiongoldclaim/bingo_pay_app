import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:bingo_pay/features/customer/dashboard/presentation/cubit/buyer_dashboard_cubit.dart';
import 'package:bingo_pay/features/customer/dashboard/presentation/cubit/buyer_dashboard_state.dart';

void main() {
  group('BuyerDashboardCubit', () {
    late BuyerDashboardCubit cubit;

    setUp(() {
      cubit = BuyerDashboardCubit();
    });

    tearDown(() {
      cubit.close();
    });

    test('initial state is correct', () {
      expect(cubit.state, const BuyerDashboardState.initial());
    });

    blocTest<BuyerDashboardCubit, BuyerDashboardState>(
      'emits loading then loaded state when loadDashboard succeeds',
      build: () => cubit,
      act: (cubit) => cubit.loadDashboard(),
      expect: () => [
        const BuyerDashboardState.loading(),
        isA<BuyerDashboardState>()
            .having((s) => s.isLoading, 'isLoading', false)
            .having((s) => s.data, 'data', isNotNull)
            .having((s) => s.errorMessage, 'errorMessage', null),
      ],
      wait: const Duration(milliseconds: 600),
    );

    blocTest<BuyerDashboardCubit, BuyerDashboardState>(
      'loaded state contains profile data',
      build: () => cubit,
      act: (cubit) => cubit.loadDashboard(),
      verify: (cubit) {
        final state = cubit.state;
        expect(state.data, isNotNull);
        expect(state.data!.profile.name, 'John Doe');
        expect(state.data!.profile.statusLabel, 'Verified Member');
      },
      wait: const Duration(milliseconds: 600),
    );

    blocTest<BuyerDashboardCubit, BuyerDashboardState>(
      'loaded state contains recent orders data',
      build: () => cubit,
      act: (cubit) => cubit.loadDashboard(),
      verify: (cubit) {
        final state = cubit.state;
        expect(state.data, isNotNull);
        expect(state.data!.recentOrders, isNotEmpty);
        expect(state.data!.recentOrders.length, 3);
        expect(state.data!.recentOrders[0].id, 'ORDER-001');
        expect(state.data!.recentOrders[0].title, 'Blue Denim Jacket');
        expect(state.data!.recentOrders[0].statusLabel, 'Delivered');
      },
      wait: const Duration(milliseconds: 600),
    );

    blocTest<BuyerDashboardCubit, BuyerDashboardState>(
      'loaded state contains active order data',
      build: () => cubit,
      act: (cubit) => cubit.loadDashboard(),
      verify: (cubit) {
        final state = cubit.state;
        expect(state.data, isNotNull);
        expect(state.data!.activeOrder, isNotNull);
        expect(state.data!.activeOrder!.id, 'ORDER-002');
        expect(state.data!.activeOrder!.statusLabel, 'Out for Delivery');
        expect(state.data!.activeOrder!.etaLabel, 'Today, 2-6 PM');
      },
      wait: const Duration(milliseconds: 600),
    );

    blocTest<BuyerDashboardCubit, BuyerDashboardState>(
      'loaded state contains saved items data',
      build: () => cubit,
      act: (cubit) => cubit.loadDashboard(),
      verify: (cubit) {
        final state = cubit.state;
        expect(state.data, isNotNull);
        expect(state.data!.savedItems, isNotEmpty);
        expect(state.data!.savedItems.length, 3);
        expect(state.data!.savedItems[0].title, 'Red Running Shoes');
      },
      wait: const Duration(milliseconds: 600),
    );

    blocTest<BuyerDashboardCubit, BuyerDashboardState>(
      'loaded state contains addresses data',
      build: () => cubit,
      act: (cubit) => cubit.loadDashboard(),
      verify: (cubit) {
        final state = cubit.state;
        expect(state.data, isNotNull);
        expect(state.data!.addresses, isNotEmpty);
        expect(state.data!.addresses.length, 2);
        expect(state.data!.addresses[0].line1, '123 Main Street, Apt 4B');
        expect(state.data!.addresses[0].city, 'New York, NY 10001');
      },
      wait: const Duration(milliseconds: 600),
    );

    blocTest<BuyerDashboardCubit, BuyerDashboardState>(
      'loaded state contains payment methods data',
      build: () => cubit,
      act: (cubit) => cubit.loadDashboard(),
      verify: (cubit) {
        final state = cubit.state;
        expect(state.data, isNotNull);
        expect(state.data!.paymentMethods, isNotEmpty);
        expect(state.data!.paymentMethods.length, 2);
        expect(state.data!.paymentMethods[0].label, 'Visa Card');
        expect(state.data!.paymentMethods[0].suffix, '**** 1234');
      },
      wait: const Duration(milliseconds: 600),
    );

    blocTest<BuyerDashboardCubit, BuyerDashboardState>(
      'loaded state contains rewards data',
      build: () => cubit,
      act: (cubit) => cubit.loadDashboard(),
      verify: (cubit) {
        final state = cubit.state;
        expect(state.data, isNotNull);
        expect(state.data!.rewards.walletBalance, 2500);
        expect(state.data!.rewards.rewardPoints, 1250);
      },
      wait: const Duration(milliseconds: 600),
    );

    blocTest<BuyerDashboardCubit, BuyerDashboardState>(
      'refreshDashboard reloads data',
      build: () => cubit,
      act: (cubit) async {
        await cubit.loadDashboard();
        await cubit.refreshDashboard();
      },
      expect: () => [
        const BuyerDashboardState.loading(),
        isA<BuyerDashboardState>()
            .having((s) => s.isLoading, 'isLoading', false)
            .having((s) => s.data, 'data', isNotNull),
        const BuyerDashboardState.loading(),
        isA<BuyerDashboardState>()
            .having((s) => s.isLoading, 'isLoading', false)
            .having((s) => s.data, 'data', isNotNull),
      ],
      wait: const Duration(milliseconds: 600),
    );

    test('BuyerProfile calculates initials correctly', () {
      expect(
        BuyerProfile.mock(name: 'John Doe', statusLabel: 'Verified').avatarInitials,
        'JD',
      );

      expect(
        BuyerProfile.mock(name: 'Alice', statusLabel: 'Verified').avatarInitials,
        'AL',
      );

      expect(
        BuyerProfile.mock(name: 'A B C', statusLabel: 'Verified').avatarInitials,
        'AC',
      );
    });

    test('BuyerDashboardState initial constructor works', () {
      final state = const BuyerDashboardState.initial();
      expect(state.isLoading, false);
      expect(state.data, null);
      expect(state.errorMessage, null);
    });

    test('BuyerDashboardState loading constructor works', () {
      final state = const BuyerDashboardState.loading();
      expect(state.isLoading, true);
      expect(state.data, null);
      expect(state.errorMessage, null);
    });

    test('BuyerDashboardState error constructor works', () {
      const errorMsg = 'Test error';
      final state = const BuyerDashboardState.error(errorMsg);
      expect(state.isLoading, false);
      expect(state.data, null);
      expect(state.errorMessage, errorMsg);
    });

    test('BuyerDashboardData empty constructor works', () {
      final data = const BuyerDashboardData.empty();
      expect(data.profile, BuyerProfile.mockEmpty());
      expect(data.recentOrders, isEmpty);
      expect(data.activeOrder, null);
      expect(data.savedItems, isEmpty);
      expect(data.addresses, isEmpty);
      expect(data.paymentMethods, isEmpty);
      expect(data.rewards, const RewardSummary.empty());
    });

    test('Equatable implementations work correctly', () {
      final data1 = BuyerDashboardData(
        profile: BuyerProfile.mock(name: 'John', statusLabel: 'Verified'),
        recentOrders: const [],
        activeOrder: null,
        savedItems: const [],
        addresses: const [],
        paymentMethods: const [],
        rewards: const RewardSummary.empty(),
      );

      final data2 = BuyerDashboardData(
        profile: BuyerProfile.mock(name: 'John', statusLabel: 'Verified'),
        recentOrders: const [],
        activeOrder: null,
        savedItems: const [],
        addresses: const [],
        paymentMethods: const [],
        rewards: const RewardSummary.empty(),
      );

      expect(data1, data2);
    });
  });
}
