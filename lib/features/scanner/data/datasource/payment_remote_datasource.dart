import 'package:injectable/injectable.dart';
import '../../../../core/api/api_client.dart';
import '../../../../core/api/api_endpoints.dart';
import '../models/payment_request_model.dart';
import '../models/payment_response_model.dart';

abstract class PaymentRemoteDataSource {
  Future<PaymentResponseModel> processPayment(PaymentRequestModel request);
}

@Injectable(as: PaymentRemoteDataSource)
class PaymentRemoteDataSourceImpl implements PaymentRemoteDataSource {
  final ApiClient _client;

  const PaymentRemoteDataSourceImpl(this._client);

  @override
  Future<PaymentResponseModel> processPayment(
    PaymentRequestModel request,
  ) async {
    try {
      print('================ PAYMENT API REQUEST ================');
      print('URL: ${ApiEndpoints.scanner}');
      print('REQUEST BODY: ${request.toJson()}');

      final response = await _client.dio.post(
        ApiEndpoints.scanner,
        data: request.toJson(),
      );

      print('================ PAYMENT API RESPONSE ================');
      print('STATUS CODE: ${response.statusCode}');
      print('STATUS MESSAGE: ${response.statusMessage}');
      print('RESPONSE DATA: ${response.data}');
      print('=====================================================');

      return PaymentResponseModel.fromJson(response.data);
    } catch (e, stackTrace) {
      print('================ PAYMENT API ERROR ==================');
      print('ERROR: $e');
      print('STACKTRACE: $stackTrace');
      print('=====================================================');

      rethrow;
    }
  }
}
