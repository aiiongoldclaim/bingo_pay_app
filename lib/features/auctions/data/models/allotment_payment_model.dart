import '../../domain/entities/allotment_payment_entity.dart';

class AllotmentPaymentModel {
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

  const AllotmentPaymentModel({
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

  factory AllotmentPaymentModel.fromJson(Map<String, dynamic> json) {
    final inner = json['data'] is Map<String, dynamic>
        ? json['data'] as Map<String, dynamic>
        : json;
    final allotment = inner['allotment'] is Map<String, dynamic>
        ? inner['allotment'] as Map<String, dynamic>
        : const <String, dynamic>{};
    final payment = inner['payment'] is Map<String, dynamic>
        ? inner['payment'] as Map<String, dynamic>
        : const <String, dynamic>{};

    return AllotmentPaymentModel(
      allotmentUuid: allotment['uuid']?.toString() ?? '',
      auctionUuid: allotment['auctionUuid']?.toString() ?? '',
      allotmentAmount: allotment['amount']?.toString() ?? '',
      allotmentCurrency: allotment['currency']?.toString() ?? '',
      paymentUuid: payment['paymentUuid']?.toString() ?? '',
      token: payment['token']?.toString() ?? '',
      payUrl: payment['payUrl']?.toString() ?? '',
      amount: _num(payment['amount'])?.toDouble() ?? 0,
      currency: payment['currency']?.toString() ?? '',
      priceUsd: _num(payment['priceUsd']),
      tokenRate: _num(payment['tokenRate']),
      expiresAt: DateTime.tryParse(payment['expiresAt']?.toString() ?? '')
          ?.toLocal(),
    );
  }

  static num? _num(dynamic value) =>
      value is num ? value : num.tryParse(value?.toString() ?? '');

  AllotmentPaymentEntity toEntity() {
    return AllotmentPaymentEntity(
      allotmentUuid: allotmentUuid,
      auctionUuid: auctionUuid,
      allotmentAmount: allotmentAmount,
      allotmentCurrency: allotmentCurrency,
      paymentUuid: paymentUuid,
      token: token,
      payUrl: payUrl,
      amount: amount,
      currency: currency,
      priceUsd: priceUsd,
      tokenRate: tokenRate,
      expiresAt: expiresAt,
    );
  }
}
