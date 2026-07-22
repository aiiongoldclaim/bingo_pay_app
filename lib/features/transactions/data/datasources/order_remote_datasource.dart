import 'package:injectable/injectable.dart';
import 'package:intl/intl.dart';

import '../../../../core/api/api_client.dart';
import '../../../../core/api/api_endpoints.dart';
import '../../../../core/api/apps_script_client.dart';
import '../models/vendor_order_model.dart';

abstract interface class OrderRemoteDataSource {
  Future<List<Map<String, dynamic>>> getOrders();
  Future<void> addOrder(Map<String, dynamic> payload);
  Future<void> updateOrderStatus({required String orderId, required String status});
  Future<List<VendorOrderModel>> getVendorOrders({DateTime? startDate, DateTime? endDate});
  Future<VendorOrderDetailModel?> getVendorOrderDetail(String uuid);
  Future<void> updateVendorOrderStatus({required String uuid, required String action});
}

@Injectable(as: OrderRemoteDataSource)
class OrderRemoteDataSourceImpl implements OrderRemoteDataSource {
  final AppsScriptClient _client;
  final ApiClient _apiClient;

  OrderRemoteDataSourceImpl(this._client, this._apiClient);

  @override
  Future<List<Map<String, dynamic>>> getOrders() async {
    final data = await _client.get('getOrders');
    final list = data['data'];
    if (list is! List) return [];
    return list.whereType<Map>().map((e) => e.map((k, v) => MapEntry(k.toString(), v))).toList();
  }

  @override
  Future<void> addOrder(Map<String, dynamic> payload) async {
    await _client.post('addOrder', payload);
  }

  @override
  Future<void> updateOrderStatus({required String orderId, required String status}) async {
    await _client.post('updateOrderStatus', {'order_id': orderId, 'status': status});
  }

  @override
  Future<List<VendorOrderModel>> getVendorOrders({
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    final dateFormat = DateFormat('yyyy-MM-dd');
    final response = await _apiClient.dio.get(
      ApiEndpoints.vendorOrders,
      queryParameters: {
        if (startDate != null) 'startDate': dateFormat.format(startDate),
        if (endDate != null) 'endDate': dateFormat.format(endDate),
      },
    );
    return VendorOrderModel.listFromResponse(response.data as Map<String, dynamic>);
  }

  @override
  Future<VendorOrderDetailModel?> getVendorOrderDetail(String uuid) async {
    final response = await _apiClient.dio.get(ApiEndpoints.vendorOrderDetail(uuid));
    return VendorOrderDetailModel.fromResponse(response.data as Map<String, dynamic>);
  }

  @override
  Future<void> updateVendorOrderStatus({required String uuid, required String action}) async {
    await _apiClient.dio.patch(ApiEndpoints.vendorOrderStatus(uuid), data: {'action': action});
  }
}
