import 'package:bingo_pay/core/api/api_client.dart';
import 'package:bingo_pay/core/api/api_endpoints.dart';
import 'package:bingo_pay/features/payment/data/models/stripe_status_response.dart';
import 'package:bingo_pay/features/payment/data/stripe_payment_datasource.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockApiClient extends Mock implements ApiClient {}

class MockDio extends Mock implements Dio {}

const _checkoutUrl = 'https://checkout.stripe.com/c/pay/cs_test_123';

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
  late StripePaymentDataSource dataSource;

  setUp(() {
    mockDio = MockDio();
    mockApiClient = MockApiClient();
    when(() => mockApiClient.dio).thenReturn(mockDio);
    dataSource = StripePaymentDataSource(mockApiClient);
  });

  test('createIntent posts to ApiEndpoints.stripeIntent and parses the nested envelope', () async {
    when(() => mockDio.post(
          ApiEndpoints.stripeIntent,
          data: any(named: 'data'),
        )).thenAnswer(
      (_) async => _reply(ApiEndpoints.stripeIntent, {
        'paymentUuid': 'p-1',
        'provider': 'STRIPE',
        'checkoutUrl': _checkoutUrl,
        'sessionId': 'cs_test_123',
        'amount': 1532.82,
        'currency': 'USD',
        'reference': 'STRIPE-abc',
        'breakdown': {
          'subtotal': 1299,
          'discount': 0,
          'tax': 233.82,
          'shipping': 0,
          'total': 1532.82,
        },
        'order': null,
        'expiresAt': '2026-10-01T11:30:00.000Z',
        'expiresInSeconds': 3600,
      }),
    );

    final result = await dataSource.createIntent(
      addressId: '12',
      variantUuid: 'v1',
      quantity: 2,
    );

    expect(result.paymentUuid, 'p-1');
    expect(result.checkoutUrl, _checkoutUrl);
    expect(result.amount, 1532.82);
    expect(result.breakdown?.tax, 233.82);

    // No amount, currency or price ever leaves the app.
    final captured = verify(() => mockDio.post(
          ApiEndpoints.stripeIntent,
          data: captureAny(named: 'data'),
        )).captured.single;
    expect(captured, {'addressId': '12', 'variantUuid': 'v1', 'quantity': 2});
  });

  test('getQuote posts the basket to ApiEndpoints.paymentQuote and parses the breakdown', () async {
    when(() => mockDio.post(
          ApiEndpoints.paymentQuote,
          data: any(named: 'data'),
        )).thenAnswer(
      (_) async => _reply(ApiEndpoints.paymentQuote, {
        'currency': 'USD',
        'breakdown': {
          'subtotal': 23,
          'discount': 0,
          'tax': 4.14,
          'shipping': 50,
          'total': 77.14,
        },
      }),
    );

    final result = await dataSource.getQuote(
      addressId: '12',
      variantUuid: 'v1',
      quantity: 1,
    );

    expect(result.subtotal, 23);
    expect(result.tax, 4.14);
    expect(result.shipping, 50);
    expect(result.total, 77.14);

    final captured = verify(() => mockDio.post(
          ApiEndpoints.paymentQuote,
          data: captureAny(named: 'data'),
        )).captured.single;
    expect(captured, {'addressId': '12', 'variantUuid': 'v1', 'quantity': 1});
  });

  test('getStatus parses a pending payment, whose amount arrives as a string', () async {
    when(() => mockDio.get(ApiEndpoints.stripeStatus('p-1'))).thenAnswer(
      (_) async => _reply(ApiEndpoints.stripeStatus('p-1'), {
        'paymentUuid': 'p-1',
        'provider': 'STRIPE',
        'status': 'PENDING',
        'gatewayStatus': 'open',
        'refunded': false,
        'amount': '1532.82',
        'currency': 'USD',
        'checkoutUrl': _checkoutUrl,
        'paidAt': null,
        'expiresAt': '2026-10-01T11:30:00.000Z',
        'order': null,
      }),
    );

    final result = await dataSource.getStatus('p-1');

    expect(result.status, StripePaymentStatus.pending);
    expect(result.amount, 1532.82);
    expect(result.currency, 'USD');
    expect(result.refunded, isFalse);
    expect(result.order, isNull);
  });

  test('getStatus parses a paid payment with the order the server placed', () async {
    when(() => mockDio.get(ApiEndpoints.stripeStatus('p-1'))).thenAnswer(
      (_) async => _reply(ApiEndpoints.stripeStatus('p-1'), {
        'paymentUuid': 'p-1',
        'status': 'PAID',
        'gatewayStatus': 'paid',
        'refunded': false,
        'amount': '1532.82',
        'currency': 'USD',
        'checkoutUrl': null,
        'order': {
          'uuid': 'o-uuid',
          'orderNumber': 'ORD-123',
          'paymentStatus': 'PAID',
        },
      }),
    );

    final result = await dataSource.getStatus('p-1');

    expect(result.status, StripePaymentStatus.paid);
    expect(result.order?.uuid, 'o-uuid');
    expect(result.order?.orderNumber, 'ORD-123');
  });

  test('getStatus reports a charge that was refunded because no order could be placed', () async {
    when(() => mockDio.get(ApiEndpoints.stripeStatus('p-1'))).thenAnswer(
      (_) async => _reply(ApiEndpoints.stripeStatus('p-1'), {
        'paymentUuid': 'p-1',
        'status': 'FAILED',
        'gatewayStatus': 'refunded',
        'refunded': true,
        'amount': '50',
        'currency': 'USD',
        'checkoutUrl': null,
        'order': null,
      }),
    );

    final result = await dataSource.getStatus('p-1');

    expect(result.status, StripePaymentStatus.failed);
    expect(result.refunded, isTrue);
  });

  test('an unrecognised status reads as pending rather than as an outcome', () {
    expect(StripePaymentStatus.parse('SOMETHING_NEW'), StripePaymentStatus.pending);
    expect(StripePaymentStatus.parse(null), StripePaymentStatus.pending);
    expect(StripePaymentStatus.parse('RECONCILING'), StripePaymentStatus.reconciling);
  });

  test('cancel posts to ApiEndpoints.stripeCancel and parses the status body', () async {
    when(() => mockDio.post(ApiEndpoints.stripeCancel('p-1'))).thenAnswer(
      (_) async => _reply(ApiEndpoints.stripeCancel('p-1'), {
        'paymentUuid': 'p-1',
        'status': 'CANCELLED',
        'refunded': false,
        'amount': '1532.82',
        'currency': 'USD',
        'checkoutUrl': null,
        'order': null,
      }),
    );

    final result = await dataSource.cancel('p-1');

    expect(result.status, StripePaymentStatus.cancelled);
    verify(() => mockDio.post(ApiEndpoints.stripeCancel('p-1'))).called(1);
  });

  group('isCardAvailable', () {
    void stubMethods(bool stripeAvailable) {
      when(() => mockDio.get(ApiEndpoints.paymentMethods)).thenAnswer(
        (_) async => _reply(ApiEndpoints.paymentMethods, {
          'currency': 'USD',
          'methods': [
            {'code': 'BIGOD', 'flow': 'SYNCHRONOUS', 'available': true},
            {'code': 'NOWPAYMENTS', 'flow': 'REDIRECT', 'available': true},
            {'code': 'STRIPE', 'flow': 'REDIRECT', 'available': stripeAvailable},
          ],
        }),
      );
    }

    test('is true when the server offers the STRIPE rail', () async {
      stubMethods(true);
      expect(await dataSource.isCardAvailable(), isTrue);
    });

    test('is false when Stripe is switched off or not configured', () async {
      stubMethods(false);
      expect(await dataSource.isCardAvailable(), isFalse);
    });
  });
}
