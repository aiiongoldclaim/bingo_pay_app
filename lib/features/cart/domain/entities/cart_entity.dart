import 'package:equatable/equatable.dart';

import 'cart_item_entity.dart';

class CartEntity extends Equatable {
  final int? cartId;
  final String? cartUuid;
  final int totalItems;
  final double totalAmount;
  final List<CartItemEntity> items;

  const CartEntity({
    this.cartId,
    this.cartUuid,
    required this.totalItems,
    required this.totalAmount,
    this.items = const [],
  });

  const CartEntity.empty()
    : cartId = null,
      cartUuid = null,
      totalItems = 0,
      totalAmount = 0,
      items = const [];

  @override
  List<Object?> get props => [cartId, cartUuid, totalItems, totalAmount, items];
}
