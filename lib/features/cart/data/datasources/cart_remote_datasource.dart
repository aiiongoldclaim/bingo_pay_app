import 'package:injectable/injectable.dart';

import '../../../../core/api/api_client.dart';
import '../../../../core/api/api_endpoints.dart';
import '../models/cart_model.dart';

abstract class CartRemoteDataSource {
  Future<CartModel> getCart();

  Future<CartModel> addItem({
    required String variantUuid,
    required int quantity,
  });

  Future<CartModel> updateItemQuantity({
    required int itemId,
    required int quantity,
  });

  Future<String> removeItem({required int itemId});

  Future<String> clearCart();
}

@Injectable(as: CartRemoteDataSource)
class CartRemoteDataSourceImpl implements CartRemoteDataSource {
  final ApiClient _client;

  const CartRemoteDataSourceImpl(this._client);

  @override
  Future<CartModel> getCart() async {
    final response = await _client.dio.get(ApiEndpoints.cart);
    return CartModel.fromJson(_unwrap(response.data));
  }

  @override
  Future<CartModel> addItem({
    required String variantUuid,
    required int quantity,
  }) async {
    final response = await _client.dio.post(
      ApiEndpoints.cartItems,
      data: {'variantUuid': variantUuid, 'quantity': quantity},
    );
    return CartModel.fromJson(_unwrap(response.data));
  }

  @override
  Future<CartModel> updateItemQuantity({
    required int itemId,
    required int quantity,
  }) async {
    final response = await _client.dio.patch(
      '${ApiEndpoints.cartItems}/$itemId',
      data: {'quantity': quantity},
    );
    return CartModel.fromJson(_unwrap(response.data));
  }

  @override
  Future<String> removeItem({required int itemId}) async {
    final response = await _client.dio.delete(
      '${ApiEndpoints.cartItems}/$itemId',
    );
    return _extractMessage(response.data) ?? 'Item removed successfully';
  }

  @override
  Future<String> clearCart() async {
    final response = await _client.dio.delete(ApiEndpoints.cartClear);
    return _extractMessage(response.data) ?? 'Cart cleared successfully';
  }

  // The API wraps every payload as {success, statusCode, message, data, timestamp};
  // the shapes documented for the cart endpoints are the inner `data` object.
  Map<String, dynamic> _unwrap(dynamic raw) {
    final envelope = raw as Map<String, dynamic>;
    final data = envelope['data'];
    if (data is Map<String, dynamic>) return data;
    return envelope;
  }

  String? _extractMessage(dynamic raw) {
    if (raw is! Map<String, dynamic>) return null;
    final data = raw['data'];
    if (data is Map<String, dynamic> && data['message'] is String) {
      return data['message'] as String;
    }
    return raw['message'] as String?;
  }
}
