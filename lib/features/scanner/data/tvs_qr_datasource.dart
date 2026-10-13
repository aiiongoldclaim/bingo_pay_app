import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';

import '../../../core/api/api_client.dart';
import '../../../core/api/api_endpoints.dart';
import '../../../core/api/api_envelope.dart';

// A refusal from the TVS Wallet API. `message` is already written for the
// customer; `code` (PIN_REQUIRED, QUOTE_CHANGED…) says what the app should do.
class TvsQrException implements Exception {
  final String code;
  final String message;
  const TvsQrException(this.code, this.message);

  @override
  String toString() => message;
}

// TVS Wallet: pay a shop by scanning its QR, the wallet PIN, and the KYC that
// activates the wallet. Payloads stay as the API sends them: amounts
// are strings with 2 decimals, never parsed to doubles.
@singleton
class TvsQrDataSource {
  final ApiClient _client;

  const TvsQrDataSource(this._client);

  Future<Map<String, dynamic>> resolve(String token) =>
      _post(ApiEndpoints.tvsQrResolve, {'token': token});

  // Moves no money.
  Future<Map<String, dynamic>> quote(
    String token,
    String amount,
    String code,
  ) => _post(ApiEndpoints.tvsQrQuote, {
    'token': token,
    'amount': amount,
    if (code.isNotEmpty) 'code': code,
  });

  Future<Map<String, dynamic>> pay({
    required String token,
    required String amount,
    required String code,
    required String idempotencyKey,
    required String expectedPayable,
    String? pin,
    String note = '',
  }) => _post(ApiEndpoints.tvsQrPay, {
    'token': token,
    'amount': amount,
    if (code.isNotEmpty) 'code': code,
    'idempotencyKey': idempotencyKey,
    'expectedPayable': expectedPayable,
    'pin': ?pin,
    if (note.isNotEmpty) 'note': note,
  });

  Future<bool> pinIsSet() async {
    final response = await _client.dio.get(ApiEndpoints.tvsPin);
    return unwrapEnvelope(response.data)['isSet'] == true;
  }

  Future<void> setPin(String pin) => _post(ApiEndpoints.tvsPin, {'pin': pin});

  // KYC activates the wallet: the user submits, an admin approves.
  // Each country: {country, name, documents: [{code, label, files}], rule}.
  Future<List<dynamic>> kycRequirements() async {
    final response = await _client.dio.get(ApiEndpoints.tvsKycRequirements);
    return response.data['data']['data'] as List<dynamic>;
  }

  // {status, canSubmit, attemptsLeft, legalName, latest: {status, reason…}}
  Future<Map<String, dynamic>> kycStatus() async {
    final response = await _client.dio.get(ApiEndpoints.tvsKyc);
    return unwrapEnvelope(response.data);
  }

  Future<Map<String, dynamic>> submitKyc(FormData form) =>
      _post(ApiEndpoints.tvsKyc, form);

  Future<Map<String, dynamic>> _post(String path, Object body) async {
    try {
      final response = await _client.dio.post(path, data: body);
      return unwrapEnvelope(response.data);
    } on DioException catch (e) {
      // ErrorInterceptor keeps only the message; the app needs the code too.
      final data = e.response?.data;
      if (data is Map && data['code'] is String) {
        throw TvsQrException(data['code'] as String, '${data['message']}');
      }
      rethrow;
    }
  }
}
