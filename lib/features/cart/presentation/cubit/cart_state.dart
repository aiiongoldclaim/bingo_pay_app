import 'package:equatable/equatable.dart';

import '../../domain/entities/cart_entity.dart';
import '../../domain/entities/cart_item_entity.dart';

class CartState extends Equatable {
  final bool isLoading;
  final bool isAddingItem;
  final CartEntity cart;
  final String? error;

  const CartState({
    this.isLoading = false,
    this.isAddingItem = false,
    this.cart = const CartEntity.empty(),
    this.error,
  });

  List<CartItemEntity> get items => cart.items;

  int get totalItems => cart.totalItems;

  double get totalAmount => cart.totalAmount;

  CartState copyWith({
    bool? isLoading,
    bool? isAddingItem,
    CartEntity? cart,
    String? error,
  }) {
    return CartState(
      isLoading: isLoading ?? this.isLoading,
      isAddingItem: isAddingItem ?? this.isAddingItem,
      cart: cart ?? this.cart,
      error: error,
    );
  }

  @override
  List<Object?> get props => [isLoading, isAddingItem, cart, error];
}
