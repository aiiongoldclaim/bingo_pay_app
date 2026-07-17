import 'package:injectable/injectable.dart';

import '../../../../core/api/api_client.dart';
import '../../../../core/api/api_endpoints.dart';
import '../models/order_model.dart';

abstract class OrdersRemoteDataSource {
  Future<List<OrderModel>> getOrders();

  Future<OrderModel> getOrderDetail(String id);

  Future<void> cancelOrder(String id);
}

@Injectable(as: OrdersRemoteDataSource)
class OrdersRemoteDataSourceImpl implements OrdersRemoteDataSource {
  final ApiClient _client;

  const OrdersRemoteDataSourceImpl(this._client);

  @override
  Future<List<OrderModel>> getOrders() async {
    final response = await _client.dio.get(ApiEndpoints.orders);
    final envelope = response.data as Map<String, dynamic>;
    final data = envelope['data'];
    if (data is! List) return const [];
    return data
        .map((e) => OrderModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<OrderModel> getOrderDetail(String id) async {
    final response = await _client.dio.get('${ApiEndpoints.orders}/$id');
    final envelope = response.data as Map<String, dynamic>;
    final data = envelope['data'] as Map<String, dynamic>;
    return OrderModel.fromJson(data);
  }

  @override
  Future<void> cancelOrder(String id) async {
    await _client.dio.patch('${ApiEndpoints.orders}/$id/cancel');
  }
}
