import 'package:flutter_bloc/flutter_bloc.dart';

import '../../data/models/cart_model.dart';
import '../../data/services/cart_service.dart';
import 'cart_state.dart';

class CartCubit extends Cubit<CartState> {
  final CartService _service;

  CartCubit(this._service) : super(const CartState());

  Future<void> loadCart() async {
    emit(state.copyWith(isLoading: true));
    final items = await _service.getItems();
    emit(state.copyWith(items: items, isLoading: false));
  }

  Future<void> addItem(CartItemModel item) async {
    final items = await _service.addItem(item);
    emit(state.copyWith(items: items));
  }

  Future<void> increaseQuantity(String productUuid) async {
    final items = await _service.increaseQuantity(productUuid);
    emit(state.copyWith(items: items));
  }

  Future<void> decreaseQuantity(String productUuid) async {
    final items = await _service.decreaseQuantity(productUuid);
    emit(state.copyWith(items: items));
  }

  Future<void> removeItem(String productUuid) async {
    final items = await _service.removeItem(productUuid);
    emit(state.copyWith(items: items));
  }

  Future<void> clearCart() async {
    await _service.clearCart();
    emit(state.copyWith(items: []));
  }
}
