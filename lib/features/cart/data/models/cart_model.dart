import 'cart_item_model.dart';

class CartModel {
  final int? cartId;
  final String? cartUuid;
  final int totalItems;
  final double totalAmount;
  final List<CartItemModel> items;

  const CartModel({
    this.cartId,
    this.cartUuid,
    required this.totalItems,
    required this.totalAmount,
    this.items = const [],
  });

  const CartModel.empty()
    : cartId = null,
      cartUuid = null,
      totalItems = 0,
      totalAmount = 0,
      items = const [];

  factory CartModel.fromJson(Map<String, dynamic> json) {
    final rawItems = json['items'] as List<dynamic>? ?? const [];
    return CartModel(
      cartId: _asInt(json['cartId']),
      cartUuid: json['cartUuid'] as String?,
      totalItems: _asInt(json['totalItems']) ?? 0,
      totalAmount: (json['totalAmount'] as num?)?.toDouble() ?? 0.0,
      items: rawItems
          .map((e) => CartItemModel.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}

// The API sometimes returns numeric ids as JSON numbers and sometimes as
// strings (e.g. "cartId": "1"), so ids are parsed defensively either way.
int? _asInt(dynamic value) {
  if (value == null) return null;
  if (value is num) return value.toInt();
  return int.tryParse(value.toString());
}
