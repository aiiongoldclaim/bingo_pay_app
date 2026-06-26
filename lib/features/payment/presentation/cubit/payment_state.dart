import '../../../cart/data/models/cart_model.dart';

enum PaymentStatus { initial, loading, success, failure }

enum PaymentMethod {
  bingoldWallet,
  upi,
  creditDebit,
  payLater,
  cashOnDelivery,
  card,
  wallet,
}

class PaymentMethodState {
  final PaymentMethod? selectedMethod; // null = not yet chosen
  final PaymentStatus status;
  final bool isProcessing;
  final String? errorMessage;

  // Parties involved
  final String userEmail;
  final String vendorEmail;

  // Product being purchased (single-item flow)
  final String productName;
  final double productPriceValue;

  // Cart flow: non-empty = cart checkout
  final List<CartItemModel> cartItems;

  // Wallet & financials (from profile API)
  final double walletBalance;   // kept for remaining-amount calc (usdtBalance)
  final double usdtBalance;
  final double bigoldBalance;   // displayBigoldBalance (already divided by 1e8)
  final double itemTotal;
  final double savings;
  final double deliveryCharge;
  final double taxes;
  final double totalAmount;

  // Delivery address (set after user fills the form)
  final String deliveryName;
  final String deliveryPhone;
  final String deliveryAddress;
  final String deliveryCity;
  final String deliveryPostal;

  // Success Screen Data
  final String orderId;
  final int coinsEarned;

  PaymentMethodState({
    this.selectedMethod,
    this.status = PaymentStatus.initial,
    this.isProcessing = false,
    this.errorMessage,
    this.userEmail = '',
    this.vendorEmail = '',
    this.productName = '',
    this.productPriceValue = 0.0,
    this.cartItems = const [],
    this.walletBalance = 0.0,
    this.usdtBalance = 0.0,
    this.bigoldBalance = 0.0,
    double? itemTotal,
    this.savings = 0.0,
    this.deliveryCharge = 0.0,
    this.taxes = 0.0,
    double? totalAmount,
    this.deliveryName = '',
    this.deliveryPhone = '',
    this.deliveryAddress = '',
    this.deliveryCity = '',
    this.deliveryPostal = '',
    this.orderId = 'BG-48231',
    this.coinsEarned = 380,
  })  : itemTotal = itemTotal ?? productPriceValue,
        totalAmount = totalAmount ?? productPriceValue;

  factory PaymentMethodState.initial({
    double productPrice = 0.0,
    String productName = '',
    String userEmail = '',
    String vendorEmail = '',
    List<CartItemModel> cartItems = const [],
  }) =>
      PaymentMethodState(
        selectedMethod: PaymentMethod.wallet,
        userEmail: userEmail,
        vendorEmail: vendorEmail,
        productName: productName,
        productPriceValue: productPrice,
        cartItems: cartItems,
        totalAmount: cartItems.isNotEmpty
            ? cartItems.fold<double>(
                0.0, (s, i) => s + i.priceValue * i.quantity)
            : productPrice,
        itemTotal: cartItems.isNotEmpty
            ? cartItems.fold<double>(
                0.0, (s, i) => s + i.priceValue * i.quantity)
            : productPrice,
      );

  PaymentMethodState copyWith({
    PaymentMethod? selectedMethod,
    bool clearSelectedMethod = false,
    PaymentStatus? status,
    bool? isProcessing,
    String? errorMessage,
    String? userEmail,
    String? vendorEmail,
    String? productName,
    double? productPriceValue,
    List<CartItemModel>? cartItems,
    double? walletBalance,
    double? usdtBalance,
    double? bigoldBalance,
    double? itemTotal,
    double? savings,
    double? deliveryCharge,
    double? taxes,
    double? totalAmount,
    String? deliveryName,
    String? deliveryPhone,
    String? deliveryAddress,
    String? deliveryCity,
    String? deliveryPostal,
    String? orderId,
    int? coinsEarned,
  }) {
    return PaymentMethodState(
      selectedMethod:
          clearSelectedMethod ? null : (selectedMethod ?? this.selectedMethod),
      status: status ?? this.status,
      isProcessing: isProcessing ?? this.isProcessing,
      errorMessage: errorMessage ?? this.errorMessage,
      userEmail: userEmail ?? this.userEmail,
      vendorEmail: vendorEmail ?? this.vendorEmail,
      productName: productName ?? this.productName,
      productPriceValue: productPriceValue ?? this.productPriceValue,
      cartItems: cartItems ?? this.cartItems,
      walletBalance: walletBalance ?? this.walletBalance,
      usdtBalance: usdtBalance ?? this.usdtBalance,
      bigoldBalance: bigoldBalance ?? this.bigoldBalance,
      itemTotal: itemTotal ?? this.itemTotal,
      savings: savings ?? this.savings,
      deliveryCharge: deliveryCharge ?? this.deliveryCharge,
      taxes: taxes ?? this.taxes,
      totalAmount: totalAmount ?? this.totalAmount,
      deliveryName: deliveryName ?? this.deliveryName,
      deliveryPhone: deliveryPhone ?? this.deliveryPhone,
      deliveryAddress: deliveryAddress ?? this.deliveryAddress,
      deliveryCity: deliveryCity ?? this.deliveryCity,
      deliveryPostal: deliveryPostal ?? this.deliveryPostal,
      orderId: orderId ?? this.orderId,
      coinsEarned: coinsEarned ?? this.coinsEarned,
    );
  }

  // ── Helpers ──────────────────────────────────────────────────────────────

  bool get isCartFlow => cartItems.isNotEmpty;

  bool get hasSelectedMethod => selectedMethod != null;

  double get remainingAmount => totalAmount - walletBalance;

  String get formattedTotal =>
      totalAmount > 0 ? '\$${totalAmount.toStringAsFixed(0)}' : 'N/A';

  String get formattedWalletBalance =>
      usdtBalance > 0 ? usdtBalance.toStringAsFixed(2) : '—';

  String get formattedBigoldBalance {
    if (bigoldBalance <= 0) return '—';
    final fixed8 = bigoldBalance.toStringAsFixed(8);
    final decimals = fixed8.split('.').last;
    final allZero = decimals.split('').every((c) => c == '0');
    final amount = allZero ? bigoldBalance.toStringAsFixed(2) : fixed8;
    return '$amount USDT';
  }

  String get formattedRemaining => '\$${remainingAmount.toStringAsFixed(0)}';

  String get methodDisplayName {
    switch (selectedMethod) {
      case PaymentMethod.wallet:
      case PaymentMethod.bingoldWallet:
        return 'Bingold Wallet';
      case PaymentMethod.card:
      case PaymentMethod.creditDebit:
        return 'Credit / Debit Card';
      case PaymentMethod.upi:
        return 'UPI';
      case PaymentMethod.payLater:
        return 'Pay Later';
      case PaymentMethod.cashOnDelivery:
        return 'Cash on Delivery';
      case null:
        return 'Not selected';
    }
  }

}
