import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import 'buyer_dashboard_state.dart';

@injectable
class BuyerDashboardCubit extends Cubit<BuyerDashboardState> {
  BuyerDashboardCubit() : super(const BuyerDashboardState.initial());

  Future<void> loadDashboard() async {
    emit(const BuyerDashboardState.loading());

    try {
      await Future.delayed(const Duration(milliseconds: 500));

      final data = BuyerDashboardData(
        profile: BuyerProfile.mock(
          name: 'John Doe',
          statusLabel: 'Verified Member',
        ),
        recentOrders: const [
          RecentOrder(id: 'ORDER-001', title: 'Blue Denim Jacket', statusLabel: 'Delivered'),
          RecentOrder(id: 'ORDER-002', title: 'White Sneakers', statusLabel: 'In Transit'),
          RecentOrder(id: 'ORDER-003', title: 'Wool Sweater', statusLabel: 'Processing'),
        ],
        activeOrder: const ActiveOrder(
          id: 'ORDER-002',
          statusLabel: 'Out for Delivery',
          etaLabel: 'Today, 2-6 PM',
        ),
        savedItems: const [
          SavedItem(id: 'ITEM-001', title: 'Red Running Shoes'),
          SavedItem(id: 'ITEM-002', title: 'Black Winter Coat'),
          SavedItem(id: 'ITEM-003', title: 'Casual T-Shirt'),
        ],
        addresses: const [
          Address(id: 'ADDR-001', line1: '123 Main Street, Apt 4B', city: 'New York, NY 10001'),
          Address(id: 'ADDR-002', line1: '456 Oak Avenue', city: 'Los Angeles, CA 90001'),
        ],
        paymentMethods: const [
          PaymentMethod(id: 'PM-001', label: 'Visa Card', suffix: '**** 1234'),
          PaymentMethod(id: 'PM-002', label: 'Mastercard', suffix: '**** 5678'),
        ],
        rewards: const RewardSummary(walletBalance: 2500, rewardPoints: 1250),
      );

      emit(BuyerDashboardState.loaded(data));
    } catch (e) {
      emit(BuyerDashboardState.error('Failed to load dashboard: $e'));
    }
  }

  Future<void> refreshDashboard() async {
    await loadDashboard();
  }
}
