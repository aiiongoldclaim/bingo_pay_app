// ==================== payment_state.dart ====================

part of 'payment_cubit.dart';

enum PaymentStatus { initial, loading, success, failure }

enum PaymentMethod {
  bingoldWallet,
  upi,
  creditDebit,
  payLater,
  cashOnDelivery,
}

/// Payment methods that actually process a payment today. The rest are
/// shown as "Coming soon" until they're implemented.
const Set<PaymentMethod> enabledPaymentMethods = {
  PaymentMethod.bingoldWallet,
  PaymentMethod.cashOnDelivery,
};

class PaymentState {
  final PaymentMethod selectedMethod;
  final PaymentStatus status;
  final bool isProcessing;
  final String? errorMessage;

  // Order details, snapshotted from the cart at checkout time.
  final List<CartItem> cartItems;
  final String? vendorEmail;
  final String reference;
  final double itemTotal;
  final double savings;
  final double deliveryCharge;
  final double taxes;
  final double totalAmount;

  // Success screen data
  final String orderId;

  PaymentState({
    required this.selectedMethod,
    this.status = PaymentStatus.initial,
    this.isProcessing = false,
    this.errorMessage,
    this.cartItems = const [],
    this.vendorEmail,
    this.reference = '',
    this.itemTotal = 0,
    this.savings = 0,
    this.deliveryCharge = 0,
    this.taxes = 0,
    this.totalAmount = 0,
    this.orderId = '',
  });

  PaymentState copyWith({
    PaymentMethod? selectedMethod,
    PaymentStatus? status,
    bool? isProcessing,
    String? errorMessage,
    List<CartItem>? cartItems,
    String? vendorEmail,
    String? reference,
    double? itemTotal,
    double? savings,
    double? deliveryCharge,
    double? taxes,
    double? totalAmount,
    String? orderId,
  }) {
    return PaymentState(
      selectedMethod: selectedMethod ?? this.selectedMethod,
      status: status ?? this.status,
      isProcessing: isProcessing ?? this.isProcessing,
      errorMessage: errorMessage,
      cartItems: cartItems ?? this.cartItems,
      vendorEmail: vendorEmail ?? this.vendorEmail,
      reference: reference ?? this.reference,
      itemTotal: itemTotal ?? this.itemTotal,
      savings: savings ?? this.savings,
      deliveryCharge: deliveryCharge ?? this.deliveryCharge,
      taxes: taxes ?? this.taxes,
      totalAmount: totalAmount ?? this.totalAmount,
      orderId: orderId ?? this.orderId,
    );
  }

  int get itemCount =>
      cartItems.fold<int>(0, (total, item) => total + item.quantity);

  String get formattedTotal => '₹${totalAmount.toStringAsFixed(0)}';
}
