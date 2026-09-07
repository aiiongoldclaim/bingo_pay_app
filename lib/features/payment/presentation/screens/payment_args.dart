import '../../../cart/domain/entities/cart_item_entity.dart';

class PaymentArgs {
  final String? vendorEmail;
  final String productName;
  final double productPrice;
  final String? variantUuid;
  final int quantity;
  final List<CartItemEntity> cartItems;
  final bool isCart;

  const PaymentArgs({
    required this.vendorEmail,
    required this.productName,
    required this.productPrice,
    required this.variantUuid,
    required this.quantity,
    this.cartItems = const [],
    this.isCart = false,
  });
}