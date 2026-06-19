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

class PaymentState {
  final PaymentMethod selectedMethod;
  final PaymentStatus status;
  final bool isProcessing;
  final String? errorMessage;

  // Order & Wallet Details
  final double walletBalance;
  final double itemTotal;
  final double savings;
  final double deliveryCharge;
  final double taxes;
  final double totalAmount;

  // Success Screen Data
  final String orderId;
  final int coinsEarned;

  PaymentState({
    required this.selectedMethod,
    this.status = PaymentStatus.initial,
    this.isProcessing = false,
    this.errorMessage,
    this.walletBalance = 12480.0,
    this.itemTotal = 28980.0,
    this.savings = 6338.0,
    this.deliveryCharge = 0.0,
    this.taxes = 0.0,
    this.totalAmount = 22642.0,
    this.orderId = "BG-48231",
    this.coinsEarned = 380,
  });

  factory PaymentState.initial() => PaymentState(
        selectedMethod: PaymentMethod.bingoldWallet,
      );

  PaymentState copyWith({
    PaymentMethod? selectedMethod,
    PaymentStatus? status,
    bool? isProcessing,
    String? errorMessage,
    double? walletBalance,
    double? itemTotal,
    double? savings,
    double? deliveryCharge,
    double? taxes,
    double? totalAmount,
    String? orderId,
    int? coinsEarned,
  }) {
    return PaymentState(
      selectedMethod: selectedMethod ?? this.selectedMethod,
      status: status ?? this.status,
      isProcessing: isProcessing ?? this.isProcessing,
      errorMessage: errorMessage ?? this.errorMessage,
      walletBalance: walletBalance ?? this.walletBalance,
      itemTotal: itemTotal ?? this.itemTotal,
      savings: savings ?? this.savings,
      deliveryCharge: deliveryCharge ?? this.deliveryCharge,
      taxes: taxes ?? this.taxes,
      totalAmount: totalAmount ?? this.totalAmount,
      orderId: orderId ?? this.orderId,
      coinsEarned: coinsEarned ?? this.coinsEarned,
    );
  }

  // Helper Getters
  double get remainingAmount => totalAmount - walletBalance;

  String get formattedTotal => '₹${totalAmount.toStringAsFixed(0)}';
  String get formattedWalletBalance => '₹${walletBalance.toStringAsFixed(0)}';
  String get formattedRemaining => '₹${remainingAmount.toStringAsFixed(0)}';
}