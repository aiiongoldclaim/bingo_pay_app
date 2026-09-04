import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import '../../domain/entities/cart_item_entity.dart';
import '../../domain/usecases/add_cart_item_usecase.dart';
import '../../domain/usecases/clear_cart_usecase.dart';
import '../../domain/usecases/get_cart_usecase.dart';
import '../../domain/usecases/remove_cart_item_usecase.dart';
import '../../domain/usecases/update_cart_item_quantity_usecase.dart';
import 'cart_state.dart';

@injectable
class CartCubit extends Cubit<CartState> {
  final GetCartUseCase _getCart;
  final AddCartItemUseCase _addItem;
  final UpdateCartItemQuantityUseCase _updateQuantity;
  final RemoveCartItemUseCase _removeItem;
  final ClearCartUseCase _clearCart;

  CartCubit(
    this._getCart,
    this._addItem,
    this._updateQuantity,
    this._removeItem,
    this._clearCart,
  ) : super(const CartState());

  // Per-item monotonic counter. If a quantity-update and a removal (or two
  // quantity-updates) race for the same item, only the response belonging
  // to the most recently started operation for that item is applied —
  // an older, slower response can no longer clobber newer state (e.g.
  // resurrecting a just-removed item once its stale update arrives).
  final Map<int, int> _itemVersion = {};

  int _bumpVersion(int itemId) {
    final version = (_itemVersion[itemId] ?? 0) + 1;
    _itemVersion[itemId] = version;
    return version;
  }

  bool _isCurrent(int itemId, int version) => _itemVersion[itemId] == version;

  Future<void> loadCart() async {
    emit(state.copyWith(isLoading: true, error: null));
    final result = await _getCart();
    result.fold(
      (failure) => emit(state.copyWith(isLoading: false, error: failure.message)),
      (cart) => emit(state.copyWith(isLoading: false, cart: cart)),
    );
  }

  Future<CartActionResult> addItem({
    required String variantUuid,
    int quantity = 1,
  }) async {
    emit(state.copyWith(isAddingItem: true, error: null));
    final result = await _addItem(variantUuid: variantUuid, quantity: quantity);
    return result.fold(
      (failure) {
        emit(state.copyWith(isAddingItem: false, error: failure.message));
        return CartActionResult.failure(failure.message);
      },
      (cart) {
        emit(state.copyWith(isAddingItem: false, cart: cart, error: null));
        return const CartActionResult.success();
      },
    );
  }

  Future<void> increaseQuantity(CartItemEntity item) =>
      _changeQuantity(item.id, item.quantity + 1);

  Future<void> decreaseQuantity(CartItemEntity item) {
    if (item.quantity <= 1) return removeItem(item.id);
    return _changeQuantity(item.id, item.quantity - 1);
  }

  Future<void> _changeQuantity(int itemId, int quantity) async {
    final version = _bumpVersion(itemId);
    emit(state.copyWith(pendingItemIds: {...state.pendingItemIds, itemId}));
    final result = await _updateQuantity(itemId: itemId, quantity: quantity);
    if (!_isCurrent(itemId, version)) return;
    result.fold(
      (failure) => emit(state.copyWith(
        error: failure.message,
        pendingItemIds: _withoutPending(itemId),
      )),
      (cart) => emit(state.copyWith(
        cart: cart,
        error: null,
        pendingItemIds: _withoutPending(itemId),
      )),
    );
  }

  Future<void> removeItem(int itemId) async {
    final version = _bumpVersion(itemId);
    emit(state.copyWith(pendingItemIds: {...state.pendingItemIds, itemId}));
    final result = await _removeItem(itemId: itemId);
    if (!_isCurrent(itemId, version)) return;
    await result.fold(
      (failure) async => emit(state.copyWith(
        error: failure.message,
        pendingItemIds: _withoutPending(itemId),
      )),
      (_) => _refreshCartSilently(settledItemId: itemId),
    );
  }

  // Re-fetches the cart without flipping `isLoading`, so a single item
  // update/removal doesn't blow away the whole list with a full-screen
  // spinner — only that item's row shows a busy state while in flight.
  Future<void> _refreshCartSilently({int? settledItemId}) async {
    final result = await _getCart();
    final pendingItemIds = settledItemId == null
        ? state.pendingItemIds
        : _withoutPending(settledItemId);
    result.fold(
      (failure) => emit(state.copyWith(
        error: failure.message,
        pendingItemIds: pendingItemIds,
      )),
      (cart) => emit(state.copyWith(
        cart: cart,
        error: null,
        pendingItemIds: pendingItemIds,
      )),
    );
  }

  Set<int> _withoutPending(int itemId) =>
      {...state.pendingItemIds}..remove(itemId);

  Future<void> clearCart() async {
    final result = await _clearCart();
    await result.fold(
      (failure) async => emit(state.copyWith(error: failure.message)),
      (_) => loadCart(),
    );
  }
}
