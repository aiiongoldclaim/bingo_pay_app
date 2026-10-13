import 'package:bingo_pay/core/api/api_client.dart';
import 'package:bingo_pay/core/api/api_endpoints.dart';
import 'package:bingo_pay/features/payment/data/models/stripe_status_response.dart';
import 'package:bingo_pay/features/payment/data/nowpayments_payment_datasource.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockApiClient extends Mock implements ApiClient {}

class MockDio extends Mock implements Dio {}

const _invoiceUrl = 'https://nowpayments.io/payment/?iid=4977544823';

// The API wraps every reply twice: the global envelope, then the handler's
// own { message, data }.
Response<dynamic> _reply(String path, Map<String, dynamic> data) {
  return Response(
    requestOptions: RequestOptions(path: path),
    statusCode: 200,
    data: {
      'success': true,
      'statusCode': 200,
      'message': 'Success',
      'data': {'message': 'ok', 'data': data},
      'timestamp': '2026-10-01T10:30:00.000Z',
    },
  );
}

void main() {
  late MockApiClient mockApiClient;
  late MockDio mockDio;
  late NowPaymentsDataSource dataSource;

  setUp(() {
    mockDio = MockDio();
    mockApiClient = MockApiClient();
    when(() => mockApiClient.dio).thenReturn(mockDio);
    dataSource = NowPaymentsDataSource(mockApiClient);
  });

  test('createIntent posts to ApiEndpoints.nowPaymentsIntent and reads the invoice page', () async {
    when(() => mockDio.post(
          ApiEndpoints.nowPaymentsIntent,
          data: any(named: 'data'),
        )).thenAnswer(
      (_) async => _reply(ApiEndpoints.nowPaymentsIntent, {
        'paymentUuid': 'c-1',
        'provider': 'NOWPAYMENTS',
        'invoiceUrl': _invoiceUrl,
        'invoiceId': '4977544823',
        'amount': 1532.82,
        'currency': 'USD',
        'reference': 'NOWPAY-abc',
        'breakdown': {
          'subtotal': 1299,
          'discount': 0,
          'tax': 233.82,
          'shipping': 0,
          'total': 1532.82,
        },
        'order': null,
        'bookings': [],
        'expiresAt': '2026-10-01T11:30:00.000Z',
        'expiresInSeconds': 3600,
      }),
    );

    final result = await dataSource.createIntent(
      addressId: '12',
      variantUuid: 'v1',
      quantity: 2,
    );

    expect(result.paymentUuid, 'c-1');
    expect(result.checkoutUrl, _invoiceUrl);
    expect(result.amount, 1532.82);
    expect(result.breakdown?.tax, 233.82);

    // No amount, currency or price ever leaves the app.
    final captured = verify(() => mockDio.post(
          ApiEndpoints.nowPaymentsIntent,
          data: captureAny(named: 'data'),
        )).captured.single;
    expect(captured, {'addressId': '12', 'variantUuid': 'v1', 'quantity': 2});
  });

  test('getStatus parses a payment still on the network, whose amount arrives as a string', () async {
    when(() => mockDio.get(ApiEndpoints.nowPaymentsStatus('c-1'))).thenAnswer(
      (_) async => _reply(ApiEndpoints.nowPaymentsStatus('c-1'), {
        'paymentUuid': 'c-1',
        'provider': 'NOWPAYMENTS',
        'status': 'PENDING',
        'gatewayStatus': 'confirming',
        'amount': '1532.82',
        'currency': 'USD',
        'invoiceUrl': _invoiceUrl,
        'paidAt': null,
        'expiresAt': '2026-10-01T11:30:00.000Z',
        'order': null,
      }),
    );

    final result = await dataSource.getStatus('c-1');

    expect(result.status, StripePaymentStatus.pending);
    expect(result.gatewayStatus, 'confirming');
    expect(result.amount, 1532.82);
    expect(result.currency, 'USD');
    // This rail never reports a refund of its own.
    expect(result.refunded, isFalse);
    expect(result.order, isNull);
  });

  test('getStatus parses a paid payment with the order the server placed', () async {
    when(() => mockDio.get(ApiEndpoints.nowPaymentsStatus('c-1'))).thenAnswer(
      (_) async => _reply(ApiEndpoints.nowPaymentsStatus('c-1'), {
        'paymentUuid': 'c-1',
        'provider': 'NOWPAYMENTS',
        'status': 'PAID',
        'gatewayStatus': 'finished',
        'amount': '1532.82',
        'currency': 'USD',
        'invoiceUrl': _invoiceUrl,
        'paidAt': '2026-10-01T10:41:12.000Z',
        'order': {
          'uuid': 'o-uuid',
          'orderNumber': 'ORD-123',
          'paymentStatus': 'PAID',
        },
      }),
    );

    final result = await dataSource.getStatus('c-1');

    expect(result.status, StripePaymentStatus.paid);
    expect(result.gatewayStatus, 'finished');
    expect(result.order?.uuid, 'o-uuid');
    expect(result.order?.orderNumber, 'ORD-123');
  });
}
