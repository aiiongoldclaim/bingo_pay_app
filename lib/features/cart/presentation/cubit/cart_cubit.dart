import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import '../../domain/entities/cart_entity.dart';
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

  // Same idea as _itemVersion, but keyed by variantUuid instead of itemId —
  // a not-yet-added item has no itemId yet. Guards against two addItem()
  // calls for the SAME variant (e.g. tapped from a listing card, then
  // immediately from its own PDP) racing: if the server computes/returns
  // each response from a snapshot as of when IT started (not when it
  // finishes), the slower call's response can arrive last yet reflect an
  // earlier, less-complete cart, silently reverting a newer add.
  final Map<String, int> _addVersion = {};

  // Tracks the target quantity of the latest not-yet-settled +/- tap per
  // item. increaseQuantity()/decreaseQuantity() are handed a CartItemEntity
  // snapshot from the widget tree, which doesn't change between two rapid
  // taps until the first one's response rebuilds it — so two taps fired
  // before that rebuild would otherwise both compute the same "item.quantity
  // + 1" target instead of stacking. Reading/writing this map (synchronous,
  // no await in between) lets each tap build on the previous tap's intended
  // target rather than on the stale widget snapshot.
  final Map<int, int> _optimisticQuantity = {};

  int _bumpVersion(int itemId) {
    final version = (_itemVersion[itemId] ?? 0) + 1;
    _itemVersion[itemId] = version;
    return version;
  }

  bool _isCurrent(int itemId, int version) => _itemVersion[itemId] == version;

  int _bumpAddVersion(String variantUuid) {
    final version = (_addVersion[variantUuid] ?? 0) + 1;
    _addVersion[variantUuid] = version;
    return version;
  }

  bool _isCurrentAdd(String variantUuid, int version) =>
      _addVersion[variantUuid] == version;

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
    final version = _bumpAddVersion(variantUuid);
    emit(state.copyWith(isAddingItem: true, error: null));
    final result = await _addItem(variantUuid: variantUuid, quantity: quantity);
    final isCurrent = _isCurrentAdd(variantUuid, version);

    return result.fold(
      (failure) {
        // Still report this call's own outcome to its caller (so that
        // screen's snackbar is accurate) even if a newer add for the same
        // variant has since started and this response is otherwise stale.
        if (isCurrent) {
          emit(state.copyWith(isAddingItem: false, error: failure.message));
        }
        return CartActionResult.failure(failure.message);
      },
      (cart) {
        if (isCurrent) {
          emit(state.copyWith(
            isAddingItem: false,
            cart: _withVariantAtFront(cart, variantUuid),
            error: null,
          ));
        }
        return const CartActionResult.success();
      },
    );
  }

  // The server's own item order isn't guaranteed to put a just-added
  // variant first — the cart screen should always show the newest add at
  // the top, not wherever the backend happens to place it.
  CartEntity _withVariantAtFront(CartEntity cart, String variantUuid) {
    final items = List<CartItemEntity>.from(cart.items);
    final index = items.indexWhere((i) => i.variant.uuid == variantUuid);
    if (index <= 0) return cart;
    final justAdded = items.removeAt(index);
    items.insert(0, justAdded);
    return CartEntity(
      cartId: cart.cartId,
      cartUuid: cart.cartUuid,
      totalItems: cart.totalItems,
      totalAmount: cart.totalAmount,
      items: items,
    );
  }

  Future<void> increaseQuantity(CartItemEntity item) {
    final target = (_optimisticQuantity[item.id] ?? item.quantity) + 1;
    _optimisticQuantity[item.id] = target;
    return _changeQuantity(item.id, target);
  }

  Future<void> decreaseQuantity(CartItemEntity item) {
    final base = _optimisticQuantity[item.id] ?? item.quantity;
    if (base <= 1) {
      _optimisticQuantity.remove(item.id);
      return removeItem(item.id);
    }
    final target = base - 1;
    _optimisticQuantity[item.id] = target;
    return _changeQuantity(item.id, target);
  }

  Future<void> _changeQuantity(int itemId, int quantity) async {
    final version = _bumpVersion(itemId);
    emit(state.copyWith(pendingItemIds: {...state.pendingItemIds, itemId}));
    final result = await _updateQuantity(itemId: itemId, quantity: quantity);
    if (!_isCurrent(itemId, version)) return;
    // This is the latest tap for this item settling — the optimistic
    // target has either been confirmed (success) or reverted to whatever
    // the server actually holds (failure), so drop it and let the next
    // tap start fresh from the confirmed state.
    _optimisticQuantity.remove(itemId);
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
    _optimisticQuantity.remove(itemId);
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

  void clearForLogout() {
    _itemVersion.clear();
    emit(const CartState());
  }
}
