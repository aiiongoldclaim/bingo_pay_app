import 'package:injectable/injectable.dart';

import '../../../../core/api/api_client.dart';
import '../../../../core/api/api_endpoints.dart';
import '../models/vendor_analytics_model.dart';

abstract interface class AnalyticsRemoteDataSource {
  /// Full analytics payload — summary, orders, revenue, inventory, catalog,
  /// timeseries, top products and recent orders in one call.
  Future<VendorAnalytics> getAnalytics({
    String period = '30d',
    String groupBy = 'day',
  });

  Future<Map<String, dynamic>> getInventoryAnalytics();
  Future<Map<String, dynamic>> getOrderAnalytics({
    String period = '30d',
    String groupBy = 'day',
  });
  Future<Map<String, dynamic>> getProductAnalytics();
  Future<Map<String, dynamic>> getRevenueAnalytics({
    String period = '30d',
    String groupBy = 'day',
  });
  Future<List<Map<String, dynamic>>> getTimeseries({
    String period = '30d',
    String groupBy = 'day',
  });
}

@Injectable(as: AnalyticsRemoteDataSource)
class AnalyticsRemoteDataSourceImpl implements AnalyticsRemoteDataSource {
  final ApiClient _apiClient;

  AnalyticsRemoteDataSourceImpl(this._apiClient);

  @override
  Future<VendorAnalytics> getAnalytics({
    String period = '30d',
    String groupBy = 'day',
  }) async {
    final data = await _getData(
      ApiEndpoints.vendorAnalytics,
      query: {'period': period, 'groupBy': groupBy},
    );
    return VendorAnalytics.fromJson(data as Map<String, dynamic>);
  }

  @override
  Future<Map<String, dynamic>> getInventoryAnalytics() async {
    final data = await _getData(ApiEndpoints.vendorAnalyticsInventory);
    return data as Map<String, dynamic>;
  }

  @override
  Future<Map<String, dynamic>> getOrderAnalytics({
    String period = '30d',
    String groupBy = 'day',
  }) async {
    final data = await _getData(
      ApiEndpoints.vendorAnalyticsOrders,
      query: {'period': period, 'groupBy': groupBy},
    );
    return data as Map<String, dynamic>;
  }

  @override
  Future<Map<String, dynamic>> getProductAnalytics() async {
    final data = await _getData(ApiEndpoints.vendorAnalyticsProducts);
    return data as Map<String, dynamic>;
  }

  @override
  Future<Map<String, dynamic>> getRevenueAnalytics({
    String period = '30d',
    String groupBy = 'day',
  }) async {
    final data = await _getData(
      ApiEndpoints.vendorAnalyticsRevenue,
      query: {'period': period, 'groupBy': groupBy},
    );
    return data as Map<String, dynamic>;
  }

  @override
  Future<List<Map<String, dynamic>>> getTimeseries({
    String period = '30d',
    String groupBy = 'day',
  }) async {
    final data = await _getData(
      ApiEndpoints.vendorAnalyticsTimeseries,
      query: {'period': period, 'groupBy': groupBy},
    );
    return (data as List).whereType<Map<String, dynamic>>().toList();
  }

  Future<Object?> _getData(String path, {Map<String, dynamic>? query}) async {
    final res = await _apiClient.dio.get(path, queryParameters: query);
    final body = res.data as Map<String, dynamic>;
    return body['data'];
  }
}
