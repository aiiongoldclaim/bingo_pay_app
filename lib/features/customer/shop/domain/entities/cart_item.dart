import 'package:equatable/equatable.dart';
import 'shop_product.dart';

class CartItem extends Equatable {
  final ShopProduct product;
  final int quantity;

  const CartItem({
    required this.product,
    required this.quantity,
  });

  double get lineTotal => product.price * quantity;

  CartItem copyWith({
    ShopProduct? product,
    int? quantity,
  }) {
    return CartItem(
      product: product ?? this.product,
      quantity: quantity ?? this.quantity,
    );
  }

  @override
  List<Object> get props => [product, quantity];
}
