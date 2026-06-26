import '../../data/models/cart_model.dart';

class CartState {
  final List<CartItemModel> items;
  final bool isLoading;

  const CartState({this.items = const [], this.isLoading = false});

  int get totalItems =>
      items.fold(0, (sum, item) => sum + item.quantity);

  double get subtotal =>
      items.fold(0.0, (sum, item) => sum + item.priceValue * item.quantity);

  CartState copyWith({List<CartItemModel>? items, bool? isLoading}) =>
      CartState(
        items: items ?? this.items,
        isLoading: isLoading ?? this.isLoading,
      );
}
