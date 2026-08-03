import 'package:bingo_pay/core/api/api_client.dart';
import 'package:bingo_pay/core/api/api_endpoints.dart';
import 'package:bingo_pay/features/cart/domain/usecases/clear_cart_usecase.dart';
import 'package:bingo_pay/features/payment/data/bigod_payment_datasource.dart';
import 'package:bingo_pay/features/payment/presentation/cubit/payment_cubit.dart';
import 'package:bingo_pay/features/payment/presentation/cubit/payment_state.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:mocktail/mocktail.dart';

class MockApiClient extends Mock implements ApiClient {}

class MockDio extends Mock implements Dio {}

class MockBigodPaymentDataSource extends Mock implements BigodPaymentDataSource {}

class MockClearCartUseCase extends Mock implements ClearCartUseCase {}

void main() {
  late MockApiClient mockApiClient;
  late MockDio mockDio;

  setUp(() {
    mockDio = MockDio();
    mockApiClient = MockApiClient();
    when(() => mockApiClient.dio).thenReturn(mockDio);
    GetIt.I.registerSingleton<ApiClient>(mockApiClient);
  });

  tearDown(() {
    GetIt.I.unregister<ApiClient>();
  });

  // COD never touches BigodPaymentDataSource or ClearCartUseCase (buy-now,
  // not a cart purchase), but PaymentMethodCubit's constructor resolves both
  // unconditionally, so the cubit needs mocks even though neither is called.
  PaymentMethodCubit buildCubit() {
    return PaymentMethodCubit(
      productPrice: 100,
      userEmail: 'buyer@example.com',
      vendorEmail: 'vendor@example.com',
      variantUuid: 'variant-1',
      bigodPaymentDataSource: MockBigodPaymentDataSource(),
      clearCartUseCase: MockClearCartUseCase(),
    )
      ..updateDeliveryAddress(
        name: 'Jane',
        phone: '555',
        address: '1 Road',
        city: 'City',
        postal: '00000',
        addressId: '12',
      )
      ..selectPaymentMethod(PaymentMethod.cashOnDelivery);
  }

  // Note: Dart's Map has no structural `==`, so the stub below matches any
  // `data` map and the exact payload is asserted separately via `captureAny`
  // + `expect` (see Task 3's data source test for the same reasoning).
  blocTest<PaymentMethodCubit, PaymentMethodState>(
    'places a COD order via /api/v1/orders without ever calling the balance-operation endpoint',
    build: () {
      when(() => mockDio.post(
            ApiEndpoints.orders,
            data: any(named: 'data'),
          )).thenAnswer(
        (_) async => Response(
          requestOptions: RequestOptions(path: ApiEndpoints.orders),
          statusCode: 201,
          data: {
            'data': {'orderNumber': 'ORD-COD-1'},
          },
        ),
      );
      return buildCubit();
    },
    act: (cubit) => cubit.makePayment(),
    expect: () => [
      isA<PaymentMethodState>()
          .having((s) => s.status, 'status', PaymentStatus.loading)
          .having((s) => s.isProcessing, 'isProcessing', true),
      isA<PaymentMethodState>()
          .having((s) => s.status, 'status', PaymentStatus.success)
          .having((s) => s.orderId, 'orderId', 'ORD-COD-1')
          .having((s) => s.isProcessing, 'isProcessing', false),
    ],
    verify: (_) {
      verifyNever(
        () => mockDio.post('/api/v1/customers/bingopay/balance/operation',
            data: any(named: 'data')),
      );
      final captured = verify(() => mockDio.post(
            ApiEndpoints.orders,
            data: captureAny(named: 'data'),
          )).captured.single;
      expect(captured, {
        'addressId': '12',
        'paymentMethod': 'COD',
        'variantUuid': 'variant-1',
        'quantity': 1,
      });
    },
  );

  blocTest<PaymentMethodCubit, PaymentMethodState>(
    'surfaces a failure if the order request itself fails, with no fake order id',
    build: () {
      when(() => mockDio.post(
            ApiEndpoints.orders,
            data: any(named: 'data'),
          )).thenThrow(
        DioException(
          requestOptions: RequestOptions(path: ApiEndpoints.orders),
          response: Response(
            requestOptions: RequestOptions(path: ApiEndpoints.orders),
            statusCode: 400,
            data: {'message': 'Address not found'},
          ),
        ),
      );
      return buildCubit();
    },
    act: (cubit) => cubit.makePayment(),
    expect: () => [
      isA<PaymentMethodState>().having((s) => s.status, 'status', PaymentStatus.loading),
      isA<PaymentMethodState>()
          .having((s) => s.status, 'status', PaymentStatus.failure)
          .having((s) => s.orderId, 'orderId', 'BG-48231'), // untouched default — never fabricated
    ],
  );
}
