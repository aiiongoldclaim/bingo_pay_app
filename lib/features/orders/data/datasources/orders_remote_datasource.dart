import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/api/api_client.dart';
import '../../../../core/api/api_endpoints.dart';
import '../models/order_model.dart';

class InvoiceDownload {
  final List<int> bytes;
  final String filename;

  const InvoiceDownload({required this.bytes, required this.filename});
}

abstract class OrdersRemoteDataSource {
  Future<List<OrderModel>> getOrders();

  Future<OrderModel> getOrderDetail(String id);

  Future<void> cancelOrder(String id);

  Future<InvoiceDownload> downloadInvoice(String orderUuid);
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

  @override
  Future<InvoiceDownload> downloadInvoice(String orderUuid) async {
    final response = await _client.dio.get<List<int>>(
      '${ApiEndpoints.orders}/$orderUuid/invoice',
      options: Options(responseType: ResponseType.bytes),
    );
    final disposition = response.headers.value('content-disposition');
    return InvoiceDownload(
      bytes: response.data ?? [],
      filename: _filenameFrom(disposition) ?? 'invoice-$orderUuid.pdf',
    );
  }

  String? _filenameFrom(String? contentDisposition) {
    if (contentDisposition == null) return null;
    final match = RegExp(
      r'filename\*?=(?:UTF-8\x27\x27)?"?([^";]+)"?',
      caseSensitive: false,
    ).firstMatch(contentDisposition);
    if (match == null) return null;
    return Uri.decodeComponent(match.group(1)!);
  }
}
