import '../../../products/presentation/models/product_mock_data.dart';
import '../../../transactions/presentation/models/order_mock_data.dart';
import '../../data/models/dashboard_stats_model.dart';

abstract class DashboardState {}

class DashboardInitial extends DashboardState {}

class DashboardLoading extends DashboardState {}

class DashboardLoaded extends DashboardState {
  final DashboardStatsModel stats;
  final String vendorName;
  final String shopName;
  final List<Product> products;
  final List<Order> recentOrders;
  final bool hasUnreadNotifications;

  DashboardLoaded({
    required this.stats,
    required this.vendorName,
    required this.shopName,
    required this.products,
    required this.recentOrders,
    this.hasUnreadNotifications = false,
  });
}

class DashboardError extends DashboardState {
  final String message;
  DashboardError(this.message);
}
