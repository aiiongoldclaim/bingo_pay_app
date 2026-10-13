import '../../../../core/api/api_envelope.dart';

enum StripePaymentStatus {
  pending,
  // Card charged, order being placed.
  processing,
  paid,
  failed,
  expired,
  cancelled,
  // Paid, but held for a manual check before the order is confirmed.
  reconciling;

  // An unrecognised value reads as pending: the server is the only thing
  // that may call a payment finished, so the app keeps asking.
  static StripePaymentStatus parse(String? raw) {
    final value = raw?.toLowerCase();
    return StripePaymentStatus.values.firstWhere(
      (s) => s.name == value,
      orElse: () => StripePaymentStatus.pending,
    );
  }
}

class StripeOrderRef {
  final String uuid;
  final String orderNumber;

  const StripeOrderRef({required this.uuid, required this.orderNumber});

  factory StripeOrderRef.fromJson(Map<String, dynamic> json) {
    return StripeOrderRef(
      uuid: json['uuid'] as String,
      orderNumber: json['orderNumber'] as String,
    );
  }
}

class StripeStatusResponse {
  final StripePaymentStatus status;
  // The card was charged but no order could be placed, so the money went back.
  final bool refunded;
  final double amount;
  final String currency;
  // Null until the payment is settled.
  final StripeOrderRef? order;
  // The gateway's own word for where the payment is. Only read on the crypto
  // rail: `waiting`, `confirming`, `confirmed`, `sending`, `partially_paid`…
  final String? gatewayStatus;

  const StripeStatusResponse({
    required this.status,
    required this.refunded,
    required this.amount,
    required this.currency,
    this.order,
    this.gatewayStatus,
  });

  // API shape: { success, statusCode, message, data: { message, data: {
  //   status, refunded, amount, currency,
  //   order: { uuid, orderNumber } | null, ... } }, timestamp }
  factory StripeStatusResponse.fromJson(Map<String, dynamic> json) {
    final inner = unwrapEnvelope(json);
    final order = inner['order'];
    // `amount` is a decimal column here, which the API sends as a string.
    final amount = inner['amount'];
    return StripeStatusResponse(
      status: StripePaymentStatus.parse(inner['status'] as String?),
      refunded: inner['refunded'] == true,
      amount: amount is num
          ? amount.toDouble()
          : double.tryParse('$amount') ?? 0,
      currency: inner['currency'] as String? ?? 'USD',
      order: order is Map<String, dynamic>
          ? StripeOrderRef.fromJson(order)
          : null,
      gatewayStatus: inner['gatewayStatus'] as String?,
    );
  }
}
