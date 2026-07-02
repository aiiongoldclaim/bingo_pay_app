import 'package:equatable/equatable.dart';

import '../../domain/entities/cart_entity.dart';
import '../../domain/entities/cart_item_entity.dart';

class CartState extends Equatable {
  final bool isLoading;
  final CartEntity cart;
  final String? error;

  const CartState({
    this.isLoading = false,
    this.cart = const CartEntity.empty(),
    this.error,
  });

  List<CartItemEntity> get items => cart.items;

  int get totalItems => cart.totalItems;

  double get totalAmount => cart.totalAmount;

  CartState copyWith({bool? isLoading, CartEntity? cart, String? error}) {
    return CartState(
      isLoading: isLoading ?? this.isLoading,
      cart: cart ?? this.cart,
      error: error,
    );
  }

  @override
  List<Object?> get props => [isLoading, cart, error];
}
