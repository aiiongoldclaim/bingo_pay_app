import 'package:injectable/injectable.dart';
import '../../../core/api/api_client.dart';
import '../../../core/api/api_endpoints.dart';
import 'models/stripe_intent_response.dart';
import 'models/stripe_status_response.dart';

// Crypto payments through NOWPayments' hosted invoice. The replies have the
// same shape as the card rail's, so they are read with the same models.
//
// There is no cancel call: an invoice cannot be taken back once issued, and
// an unpaid one expires on the server by itself.
@singleton
class NowPaymentsDataSource {
  final ApiClient _client;

  const NowPaymentsDataSource(this._client);

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
      ApiEndpoints.nowPaymentsIntent,
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
      ApiEndpoints.nowPaymentsStatus(paymentUuid),
    );
    return StripeStatusResponse.fromJson(response.data as Map<String, dynamic>);
  }
}
