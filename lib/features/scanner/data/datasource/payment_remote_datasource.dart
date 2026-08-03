import 'package:injectable/injectable.dart';

import '../../../../core/error/exceptions.dart';
import '../models/payment_request_model.dart';
import '../models/payment_response_model.dart';

abstract class PaymentRemoteDataSource {
  Future<PaymentResponseModel> processPayment(PaymentRequestModel request);
}

@Injectable(as: PaymentRemoteDataSource)
class PaymentRemoteDataSourceImpl implements PaymentRemoteDataSource {
  const PaymentRemoteDataSourceImpl();

  @override
  Future<PaymentResponseModel> processPayment(
    PaymentRequestModel request,
  ) async {
    throw const ServerException(
      message: 'Scan-to-pay is being upgraded and is temporarily '
          'unavailable. Please use Buy Now or Cart checkout instead.',
    );
  }
}
