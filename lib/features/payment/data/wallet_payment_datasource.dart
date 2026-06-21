import 'package:dio/dio.dart';

import '../../../core/api/api_client.dart';
import '../../../core/api/api_endpoints.dart';
import '../../../core/di/injection.dart';

/// Pays a vendor out of the logged-in user's BINGOLD wallet.
///
/// This calls our own backend, not the BingoPay balance API directly: the
/// backend identifies the paying user from the auth token attached by
/// [ApiClient]'s interceptor and holds the BingoPay secret key, so the
/// static key never ships inside the app.
class WalletPaymentDataSource {
  final ApiClient _apiClient;

  WalletPaymentDataSource({ApiClient? apiClient})
      : _apiClient = apiClient ?? getIt<ApiClient>();

  Future<String> pay({
    required double amount,
    required String vendorEmail,
    required String reference,
    required String description,
  }) async {
    try {
      final response = await _apiClient.dio.post(
        ApiEndpoints.bingoldWalletPay,
        data: {
          'amount': amount,
          'vendorEmail': vendorEmail,
          'reference': reference,
          'description': description,
        },
      );
      final body = response.data as Map<String, dynamic>;
      if (body['success'] != true) {
        throw Exception(body['message'] ?? 'Wallet payment failed');
      }
      return (body['transactionId'] ?? '').toString();
    } on DioException catch (e) {
      final message = (e.response?.data is Map)
          ? (e.response?.data['message'] ?? e.message)
          : e.message;
      throw Exception(message ?? 'Wallet payment failed');
    }
  }
}
