import 'package:injectable/injectable.dart';
import '../../../core/api/api_client.dart';
import '../../../core/api/api_endpoints.dart';
import '../../../core/api/api_envelope.dart';
import '../../membershipNew/data/models/membership_balance_model.dart';
import 'models/bigod_confirm_response.dart';
import 'models/bigod_intent_response.dart';

@singleton
class BigodPaymentDataSource {
  final ApiClient _client;

  const BigodPaymentDataSource(this._client);

  Future<BigodIntentResponse> createIntent({
    required String addressId,
    String? variantUuid,
    int? quantity,
    String? offeringUuid,
    String? slotUuid,
    int? participants,
  }) async {
    final response = await _client.dio.post(
      ApiEndpoints.bigodIntent,
      data: {
        'addressId': addressId,
        'variantUuid': ?variantUuid,
        'quantity': ?quantity,
        'offeringUuid': ?offeringUuid,
        'slotUuid': ?slotUuid,
        'participants': ?participants,
      },
    );
    return BigodIntentResponse.fromJson(response.data as Map<String, dynamic>);
  }

  Future<BigodConfirmResponse> confirmPayment(String token) async {
    final response = await _client.dio.post(
      ApiEndpoints.bigodConfirm,
      data: {'token': token},
    );
    return BigodConfirmResponse.fromJson(response.data as Map<String, dynamic>);
  }

  // The caller's live BIGOD balance with its USD and local-currency value.
  Future<BigodBalance> balance() async {
    final response = await _client.dio.get(ApiEndpoints.bigodBalance);
    return BigodBalance.fromJson(unwrapEnvelope(response.data));
  }

  // A scanned checkout QR: {type: PAYMENT_INTENT, amount (BIGOD), status,
  // expiresAt, usd: {total, ...}, local: {currency, total} | null, items,
  // vendors[]}. Read-only; 403 when it was made for another account.
  Future<Map<String, dynamic>> resolveToken(String token) async {
    final response = await _client.dio.post(
      ApiEndpoints.bigodResolveToken,
      data: {'token': token},
    );
    return unwrapEnvelope(response.data);
  }

  // Pays a scanned checkout QR (single use). Unlike confirmPayment, doesn't
  // insist on an order: a subscription or auction payment has none.
  Future<Map<String, dynamic>> payToken(String token) async {
    final response = await _client.dio.post(
      ApiEndpoints.bigodConfirm,
      data: {'token': token},
    );
    return unwrapEnvelope(response.data);
  }
}
