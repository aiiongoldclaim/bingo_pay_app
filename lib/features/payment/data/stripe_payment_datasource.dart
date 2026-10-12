import 'package:injectable/injectable.dart';
import '../../../core/api/api_client.dart';
import '../../../core/api/api_envelope.dart';
import '../../../core/api/api_endpoints.dart';
import 'models/bigod_intent_response.dart';
import 'models/stripe_intent_response.dart';
import 'models/stripe_status_response.dart';

@singleton
class StripePaymentDataSource {
  final ApiClient _client;

  const StripePaymentDataSource(this._client);

  // The server only offers the card rail when Stripe is switched on and
  // configured, so the option is asked for rather than hardcoded.
  Future<bool> isCardAvailable() async {
    final response = await _client.dio.get(ApiEndpoints.paymentMethods);
    final inner = unwrapEnvelope(response.data);
    final methods = inner['methods'] as List<dynamic>? ?? const [];
    return methods.any(
      (m) => m is Map && m['code'] == 'STRIPE' && m['available'] == true,
    );
  }

  // What the server would charge for this basket. Tax and delivery are the
  // server's to decide; the app never works them out itself.
  Future<BigodIntentBreakdown> getQuote({
    required String addressId,
    String? variantUuid,
    int? quantity,
    String? offeringUuid,
    String? slotUuid,
    int? participants,
  }) async {
    final response = await _client.dio.post(
      ApiEndpoints.paymentQuote,
      data: {
        'addressId': addressId,
        'variantUuid': ?variantUuid,
        'quantity': ?quantity,
        'offeringUuid': ?offeringUuid,
        'slotUuid': ?slotUuid,
        'participants': ?participants,
      },
    );
    return BigodIntentBreakdown.fromJson(
      unwrapEnvelope(response.data)['breakdown'] as Map<String, dynamic>,
    );
  }

  // Same body as the BIGOD intent: no amount or currency leaves the app, the
  // server prices the basket.
  Future<StripeIntentResponse> createIntent({
    required String addressId,
    String? variantUuid,
    int? quantity,
    String? offeringUuid,
    String? slotUuid,
    int? participants,
  }) async {
    final response = await _client.dio.post(
      ApiEndpoints.stripeIntent,
      data: {
        'addressId': addressId,
        'variantUuid': ?variantUuid,
        'quantity': ?quantity,
        'offeringUuid': ?offeringUuid,
        'slotUuid': ?slotUuid,
        'participants': ?participants,
      },
    );
    return StripeIntentResponse.fromJson(response.data as Map<String, dynamic>);
  }

  Future<StripeStatusResponse> getStatus(String paymentUuid) async {
    final response = await _client.dio.get(
      ApiEndpoints.stripeStatus(paymentUuid),
    );
    return StripeStatusResponse.fromJson(response.data as Map<String, dynamic>);
  }

  // Returns the same body as getStatus. If the card had in fact been charged,
  // the server settles the order instead of cancelling it.
  Future<StripeStatusResponse> cancel(String paymentUuid) async {
    final response = await _client.dio.post(
      ApiEndpoints.stripeCancel(paymentUuid),
    );
    return StripeStatusResponse.fromJson(response.data as Map<String, dynamic>);
  }
}
