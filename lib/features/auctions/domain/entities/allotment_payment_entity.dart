class AllotmentPaymentEntity {
  final String allotmentUuid;
  final String auctionUuid;

  final String allotmentAmount;
  final String allotmentCurrency;

  final String paymentUuid;
  final String token;
  final String payUrl;

  final double amount;
  final String currency;
  final num? priceUsd;
  final num? tokenRate;
  final DateTime? expiresAt;

  const AllotmentPaymentEntity({
    required this.allotmentUuid,
    required this.auctionUuid,
    required this.allotmentAmount,
    required this.allotmentCurrency,
    required this.paymentUuid,
    required this.token,
    required this.payUrl,
    required this.amount,
    required this.currency,
    this.priceUsd,
    this.tokenRate,
    this.expiresAt,
  });

  bool get isExpired =>
      expiresAt != null && !expiresAt!.isAfter(DateTime.now());
}
