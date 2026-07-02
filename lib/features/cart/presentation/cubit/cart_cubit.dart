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

  Future<void> loadCart() async {
    emit(state.copyWith(isLoading: true, error: null));
    final result = await _getCart();
    result.fold(
      (failure) => emit(state.copyWith(isLoading: false, error: failure.message)),
      (cart) => emit(state.copyWith(isLoading: false, cart: cart)),
    );
  }

  Future<void> addItem({required String variantUuid, int quantity = 1}) async {
    final result = await _addItem(variantUuid: variantUuid, quantity: quantity);
    result.fold(
      (failure) => emit(state.copyWith(error: failure.message)),
      (cart) => emit(state.copyWith(cart: cart, error: null)),
    );
  }

  Future<void> increaseQuantity(CartItemEntity item) =>
      _changeQuantity(item.id, item.quantity + 1);

  Future<void> decreaseQuantity(CartItemEntity item) {
    if (item.quantity <= 1) return removeItem(item.id);
    return _changeQuantity(item.id, item.quantity - 1);
  }

  Future<void> _changeQuantity(int itemId, int quantity) async {
    final result = await _updateQuantity(itemId: itemId, quantity: quantity);
    result.fold(
      (failure) => emit(state.copyWith(error: failure.message)),
      (cart) => emit(state.copyWith(cart: cart, error: null)),
    );
  }

  Future<void> removeItem(int itemId) async {
    final result = await _removeItem(itemId: itemId);
    await result.fold(
      (failure) async => emit(state.copyWith(error: failure.message)),
      (_) => loadCart(),
    );
  }

  Future<void> clearCart() async {
    final result = await _clearCart();
    await result.fold(
      (failure) async => emit(state.copyWith(error: failure.message)),
      (_) => loadCart(),
    );
  }
}
