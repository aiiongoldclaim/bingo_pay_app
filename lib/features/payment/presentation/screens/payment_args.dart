class PaymentArgs {
  final String? vendorEmail;
  final String productName;
  final double productPrice;
  final String variantUuid;
  final int quantity;
  final bool isCart;

  const PaymentArgs({
    required this.vendorEmail,
    required this.productName,
    required this.productPrice,
    required this.variantUuid,
    required this.quantity,
    this.isCart = false,
  });
}