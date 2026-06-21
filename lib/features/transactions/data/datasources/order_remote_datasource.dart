import 'package:injectable/injectable.dart';

import '../../../../core/api/apps_script_client.dart';

abstract interface class OrderRemoteDataSource {
  Future<List<Map<String, dynamic>>> getOrders();
  Future<void> addOrder(Map<String, dynamic> payload);
  Future<void> updateOrderStatus({required String orderId, required String status});
}

@Injectable(as: OrderRemoteDataSource)
class OrderRemoteDataSourceImpl implements OrderRemoteDataSource {
  final AppsScriptClient _client;

  OrderRemoteDataSourceImpl(this._client);

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
}
