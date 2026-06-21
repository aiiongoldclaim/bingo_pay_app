import 'dart:convert';

import 'package:dio/dio.dart';

import '../domain/entities/cart_item.dart';
import '../domain/entities/shop_product.dart';

class ShopRemoteDataSource {
  static const String _baseUrl =
      'https://script.google.com/macros/s/AKfycby85LjaGj4jqGPw57UxEWCU6ppaVJdy-uAdN69elibmNer_Y0lK1otUj8HqMFAzk5P3kA/exec';

  final Dio _dio;

  ShopRemoteDataSource({Dio? dio}) : _dio = dio ?? Dio();

  Future<List<ShopProduct>> getProducts() async {
    final response = await _dio.get(
      _baseUrl,
      queryParameters: {'action': 'getProducts'},
    );
    final body = _decode(response.data);
    if (body['success'] != true) {
      throw Exception(body['message'] ?? 'Failed to load products');
    }
    final rows = (body['data'] as List<dynamic>?) ?? const [];
    return rows
        .map((row) => ShopProduct.fromJson(row as Map<String, dynamic>))
        .toList();
  }

  Future<String> placeOrder({
    required String customerName,
    required String customerPhone,
    required double totalAmount,
    required List<CartItem> items,
    String paymentType = 'cod',
  }) async {
    final response = await _postAndFollowRedirect(
      queryParameters: {'action': 'addOrder'},
      data: {
        'customer_name': customerName,
        'customer_phone': customerPhone,
        'total_amount': totalAmount,
        'payment_type': paymentType,
        'status': 'pending',
        'items': items
            .map(
              (item) => {
                'product_name': item.product.name,
                'quantity': item.quantity,
                'price': item.product.price,
              },
            )
            .toList(),
      },
    );
    final body = _decode(response.data);
    if (body['success'] != true) {
      throw Exception(body['message'] ?? 'Failed to place order');
    }
    return (body['order_id'] ?? '').toString();
  }

  // Apps Script executes doPost (and its side effects, e.g. appendRow) on
  // this first request, then responds with a 302 to an "echo" URL that only
  // serves the response body — it only accepts GET/HEAD, so the redirect
  // must be followed with GET, not re-posted.
  Future<Response> _postAndFollowRedirect({
    required Map<String, dynamic> queryParameters,
    required Map<String, dynamic> data,
  }) async {
    final response = await _dio.post(
      _baseUrl,
      queryParameters: queryParameters,
      data: data,
      options: Options(
        contentType: Headers.jsonContentType,
        followRedirects: false,
        validateStatus: (status) => status != null && status < 400,
      ),
    );

    final location = response.headers.value('location');
    if (response.statusCode == 302 && location != null) {
      return _dio.get(location);
    }

    return response;
  }

  Map<String, dynamic> _decode(dynamic data) {
    if (data is Map<String, dynamic>) return data;
    if (data is String) return jsonDecode(data) as Map<String, dynamic>;
    throw Exception('Unexpected response shape: $data');
  }
}
