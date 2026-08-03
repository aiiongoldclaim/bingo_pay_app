import 'package:bingo_pay/core/error/exceptions.dart';
import 'package:bingo_pay/features/scanner/data/datasource/payment_remote_datasource.dart';
import 'package:bingo_pay/features/scanner/data/models/payment_request_model.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('processPayment always throws — scan-to-pay has no safe backend endpoint until Spec 2 ships', () async {
    const dataSource = PaymentRemoteDataSourceImpl();

    await expectLater(
      () => dataSource.processPayment(
        const PaymentRequestModel(
          email: 'buyer@example.com',
          amount: 10,
          operation: 'deduct',
          reference: 'ref-1',
          description: 'desc',
        ),
      ),
      throwsA(isA<ServerException>()),
    );
  });
}
