import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';

import '../../../../core/api/api_client.dart';
import '../../../../core/api/api_endpoints.dart';
import '../../../../core/error/error_messages.dart';
import '../../../analytics/data/datasources/analytics_remote_datasource.dart';
import '../../../analytics/data/models/vendor_analytics_model.dart';
import '../../../more/data/datasources/profile_remote_datasource.dart';
import '../../../more/data/models/vendor_profile_model.dart';
import '../../../notifications/data/datasources/notification_remote_datasource.dart';
import '../../../products/data/datasources/product_remote_datasource.dart';
import '../../../products/presentation/models/product_mock_data.dart';
import '../../../transactions/data/datasources/order_remote_datasource.dart';
import '../../../transactions/presentation/models/order_mock_data.dart';
import '../../data/models/dashboard_stats_model.dart';
import 'dashboard_state.dart';

class DashboardCubit extends Cubit<DashboardState> {
  DashboardCubit() : super(DashboardInitial());

  Future<void> load() async {
    emit(DashboardLoading());
    try {
      final client = GetIt.I<ApiClient>();
      final profileDs = GetIt.I<ProfileRemoteDataSource>();
      final productsDs = GetIt.I<ProductRemoteDataSource>();

      final dashFuture = client.dio.get(ApiEndpoints.vendorDashboard);
      final profileFuture = profileDs.getProfile();
      final productsFuture = productsDs.getProducts();
      final recentOrdersFuture = _fetchRecentOrders();
      final hasUnreadFuture = _fetchHasUnreadNotifications();
      final salesTrendFuture = _fetchSalesTrend();

      final dashRes = await dashFuture;
      final VendorProfileModel profile = await profileFuture;
      final productRows = await productsFuture;
      final recentOrders = await recentOrdersFuture;
      final hasUnreadNotifications = await hasUnreadFuture;
      final salesTrend = await salesTrendFuture;

      final data = dashRes.data as Map<String, dynamic>;
      final inner = (data['data'] as Map<String, dynamic>)['data'] as Map<String, dynamic>;
      final stats = DashboardStatsModel.fromJson(inner);
      final products = productRows.map(Product.fromApi).toList();

      emit(DashboardLoaded(
        stats: stats,
        vendorName: profile.vendor.shopName,
        shopName: profile.vendor.businessName ?? profile.vendor.shopName,
        products: products,
        recentOrders: recentOrders,
        hasUnreadNotifications: hasUnreadNotifications,
        salesTrend: salesTrend,
      ));
    } catch (e) {
      emit(DashboardError(friendlyErrorMessage(e)));
    }
  }

  // Orders failing shouldn't take down the whole dashboard — the section
  // just hides when empty.
  Future<List<Order>> _fetchRecentOrders() async {
    try {
      final vendorOrders = await GetIt.I<OrderRemoteDataSource>().getVendorOrders();
      final orders = vendorOrders.map(Order.fromVendorOrder).toList()
        ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return orders.take(3).toList();
    } catch (_) {
      return const [];
    }
  }

  // Same non-fatal treatment as recent orders — the badge just stays hidden
  // if this fails, it shouldn't take down the whole dashboard.
  Future<bool> _fetchHasUnreadNotifications() async {
    try {
      final notifications =
          await GetIt.I<NotificationRemoteDataSource>().getNotifications();
      return notifications.any((n) => !n.isRead);
    } catch (_) {
      return false;
    }
  }

  // Same non-fatal treatment — the chart section just hides if this fails.
  Future<List<TimeseriesPoint>> _fetchSalesTrend() async {
    try {
      final rows = await GetIt.I<AnalyticsRemoteDataSource>().getTimeseries(
        period: '7d',
        groupBy: 'day',
      );
      return rows.map(TimeseriesPoint.fromJson).toList();
    } catch (_) {
      return const [];
    }
  }
}
