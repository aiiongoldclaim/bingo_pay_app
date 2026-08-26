import 'package:injectable/injectable.dart';

import '../../../core/api/api_client.dart';
import '../../../core/api/api_endpoints.dart';
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
    String? offeringUuid, // NEW
    String? slotUuid, // NEW
    int? participants, // NEW
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
}
