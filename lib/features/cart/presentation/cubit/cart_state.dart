import 'package:equatable/equatable.dart';

import '../../domain/entities/cart_entity.dart';
import '../../domain/entities/cart_item_entity.dart';

/// Outcome of a single `CartCubit.addItem` call, returned directly to the
/// caller instead of being read back off the shared `CartState.error` —
/// that field reflects whichever cart operation last settled app-wide, so
/// a concurrent add/remove elsewhere can overwrite it before this call's
/// own caller gets a chance to read it.
class CartActionResult {
  final bool success;
  final String? errorMessage;

  const CartActionResult.success()
      : success = true,
        errorMessage = null;

  const CartActionResult.failure(this.errorMessage) : success = false;
}

class CartState extends Equatable {
  final bool isLoading;
  final bool isAddingItem;
  final CartEntity cart;
  final String? error;
  final Set<int> pendingItemIds;

  const CartState({
    this.isLoading = false,
    this.isAddingItem = false,
    this.cart = const CartEntity.empty(),
    this.error,
    this.pendingItemIds = const {},
  });

  List<CartItemEntity> get items => cart.items;

  int get totalItems => cart.totalItems;

  /// Kitne alag-alag products cart mein hain (quantity ignore)
  int get uniqueItems => items.length;

  double get totalAmount => cart.totalAmount;

  bool isItemPending(int itemId) => pendingItemIds.contains(itemId);

  CartState copyWith({
    bool? isLoading,
    bool? isAddingItem,
    CartEntity? cart,
    String? error,
    Set<int>? pendingItemIds,
  }) {
    return CartState(
      isLoading: isLoading ?? this.isLoading,
      isAddingItem: isAddingItem ?? this.isAddingItem,
      cart: cart ?? this.cart,
      error: error,
      pendingItemIds: pendingItemIds ?? this.pendingItemIds,
    );
  }

  @override
  List<Object?> get props => [
    isLoading,
    isAddingItem,
    cart,
    error,
    pendingItemIds,
  ];
}
