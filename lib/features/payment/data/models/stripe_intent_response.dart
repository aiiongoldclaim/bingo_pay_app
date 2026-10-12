import '../../../../core/api/api_envelope.dart';
import 'bigod_intent_response.dart';

class StripeIntentResponse {
  final String paymentUuid;
  final String checkoutUrl;
  final double amount;
  final BigodIntentBreakdown? breakdown;

  const StripeIntentResponse({
    required this.paymentUuid,
    required this.checkoutUrl,
    required this.amount,
    this.breakdown,
  });

  // API shape: { success, statusCode, message, data: { message, data: {
  //   paymentUuid, checkoutUrl, amount, breakdown: {...},
  //   order: null, expiresAt, ... } }, timestamp }
  // `order` is always null here — it is placed only once the card is charged.
  factory StripeIntentResponse.fromJson(Map<String, dynamic> json) {
    final inner = unwrapEnvelope(json);
    final breakdown = inner['breakdown'];
    return StripeIntentResponse(
      paymentUuid: inner['paymentUuid'] as String,
      checkoutUrl: inner['checkoutUrl'] as String,
      amount: (inner['amount'] as num).toDouble(),
      breakdown: breakdown is Map<String, dynamic>
          ? BigodIntentBreakdown.fromJson(breakdown)
          : null,
    );
  }
}
