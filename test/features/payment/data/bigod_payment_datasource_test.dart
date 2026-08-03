import 'package:bingo_pay/core/api/api_client.dart';
import 'package:bingo_pay/core/api/api_endpoints.dart';
import 'package:bingo_pay/features/payment/data/bigod_payment_datasource.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockApiClient extends Mock implements ApiClient {}

class MockDio extends Mock implements Dio {}

void main() {
  late MockApiClient mockApiClient;
  late MockDio mockDio;
  late BigodPaymentDataSource dataSource;

  setUp(() {
    mockDio = MockDio();
    mockApiClient = MockApiClient();
    when(() => mockApiClient.dio).thenReturn(mockDio);
    dataSource = BigodPaymentDataSource(mockApiClient);
  });

  // Note: Dart's Map has no structural `==`, so `when()`/`verify()` cannot
  // match a literal map like `data: {'addressId': '12'}` against the real
  // call's map instance — they'd be different objects and never match. Stub
  // with `any(named: 'data')` and assert the exact payload separately via
  // `captureAny` + `expect` (whose default matcher does deep-compare Maps).
  test('createIntent posts to ApiEndpoints.bigodIntent and parses the nested envelope', () async {
    when(() => mockDio.post(
          ApiEndpoints.bigodIntent,
          data: any(named: 'data'),
        )).thenAnswer(
      (_) async => Response(
        requestOptions: RequestOptions(path: ApiEndpoints.bigodIntent),
        statusCode: 201,
        data: {
          'success': true,
          'statusCode': 201,
          'message': 'Success',
          'data': {
            'message': 'Payment intent created',
            'data': {
              'token': 'a' * 64,
              'amount': 1532.82,
              'breakdown': {
                'subtotal': 1299,
                'discount': 0,
                'tax': 233.82,
                'shipping': 0,
                'total': 1532.82,
                'tokenRate': 1,
              },
              'customerBalance': 5000,
            },
          },
          'timestamp': '2026-07-15T10:30:00.000Z',
        },
      ),
    );

    final result = await dataSource.createIntent(
      addressId: '12',
      variantUuid: 'v1',
      quantity: 1,
    );

    expect(result.token, 'a' * 64);
    expect(result.amount, 1532.82);
    expect(result.breakdown.total, 1532.82);
    expect(result.customerBalance, 5000);

    final captured = verify(() => mockDio.post(
          ApiEndpoints.bigodIntent,
          data: captureAny(named: 'data'),
        )).captured.single;
    expect(captured, {'addressId': '12', 'variantUuid': 'v1', 'quantity': 1});
  });

  test('confirmPayment posts to ApiEndpoints.bigodConfirm and parses the nested envelope', () async {
    when(() => mockDio.post(
          ApiEndpoints.bigodConfirm,
          data: any(named: 'data'),
        )).thenAnswer(
      (_) async => Response(
        requestOptions: RequestOptions(path: ApiEndpoints.bigodConfirm),
        statusCode: 201,
        data: {
          'success': true,
          'statusCode': 201,
          'message': 'Success',
          'data': {
            'message': 'Payment successful',
            'data': {
              'status': 'PAID',
              'amount': 1532.82,
              'order': {'uuid': 'd4e5f6a7', 'orderNumber': 'ORD-123'},
              'balance': 3467.18,
            },
          },
          'timestamp': '2026-07-15T10:33:12.000Z',
        },
      ),
    );

    final result = await dataSource.confirmPayment('a' * 64);

    expect(result.status, 'PAID');
    expect(result.order.orderNumber, 'ORD-123');
    expect(result.balance, 3467.18);

    final captured = verify(() => mockDio.post(
          ApiEndpoints.bigodConfirm,
          data: captureAny(named: 'data'),
        )).captured.single;
    expect(captured, {'token': 'a' * 64});
  });
}
