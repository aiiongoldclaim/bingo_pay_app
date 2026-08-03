import 'package:bingo_pay/features/cart/domain/entities/cart_item_entity.dart';
import 'package:bingo_pay/features/cart/domain/usecases/clear_cart_usecase.dart';
import 'package:bingo_pay/features/payment/data/bigod_payment_datasource.dart';
import 'package:bingo_pay/features/payment/data/models/bigod_confirm_response.dart';
import 'package:bingo_pay/features/payment/data/models/bigod_intent_response.dart';
import 'package:bingo_pay/features/payment/presentation/cubit/payment_cubit.dart';
import 'package:bingo_pay/features/payment/presentation/cubit/payment_state.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:mocktail/mocktail.dart';

class MockBigodPaymentDataSource extends Mock implements BigodPaymentDataSource {}

class MockClearCartUseCase extends Mock implements ClearCartUseCase {}

void main() {
  late MockBigodPaymentDataSource mockDataSource;
  late MockClearCartUseCase mockClearCart;

  setUp(() {
    mockDataSource = MockBigodPaymentDataSource();
    mockClearCart = MockClearCartUseCase();
    when(() => mockClearCart()).thenAnswer((_) async => const Right('cleared'));
  });

  PaymentMethodCubit buildCubit() {
    return PaymentMethodCubit(
      productPrice: 100,
      userEmail: 'buyer@example.com',
      vendorEmail: 'vendor@example.com',
      variantUuid: 'variant-1',
      bigodPaymentDataSource: mockDataSource,
      clearCartUseCase: mockClearCart,
    )..updateDeliveryAddress(
        name: 'Jane',
        phone: '555',
        address: '1 Road',
        city: 'City',
        postal: '00000',
        addressId: '12',
      );
  }

  blocTest<PaymentMethodCubit, PaymentMethodState>(
    'creates an intent, confirms it, and emits success with the real order number',
    build: () {
      when(() => mockDataSource.createIntent(
            addressId: '12',
            variantUuid: 'variant-1',
            quantity: 1,
          )).thenAnswer(
        (_) async => const BigodIntentResponse(
          token: 'tok-123',
          amount: 100,
          breakdown: BigodIntentBreakdown(
            subtotal: 100,
            discount: 0,
            tax: 0,
            shipping: 0,
            total: 100,
          ),
          customerBalance: 500,
        ),
      );
      when(() => mockDataSource.confirmPayment('tok-123')).thenAnswer(
        (_) async => const BigodConfirmResponse(
          status: 'PAID',
          amount: 100,
          order: BigodOrderRef(uuid: 'o-uuid', orderNumber: 'ORD-1'),
          balance: 400,
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
          .having((s) => s.orderId, 'orderId', 'ORD-1')
          .having((s) => s.isProcessing, 'isProcessing', false),
    ],
  );

  blocTest<PaymentMethodCubit, PaymentMethodState>(
    'fails fast without confirming when the intent reports insufficient balance',
    build: () {
      when(() => mockDataSource.createIntent(
            addressId: '12',
            variantUuid: 'variant-1',
            quantity: 1,
          )).thenAnswer(
        (_) async => const BigodIntentResponse(
          token: 'tok-123',
          amount: 100,
          breakdown: BigodIntentBreakdown(
            subtotal: 100,
            discount: 0,
            tax: 0,
            shipping: 0,
            total: 100,
          ),
          customerBalance: 10,
        ),
      );
      return buildCubit();
    },
    act: (cubit) => cubit.makePayment(),
    expect: () => [
      isA<PaymentMethodState>().having((s) => s.status, 'status', PaymentStatus.loading),
      isA<PaymentMethodState>()
          .having((s) => s.status, 'status', PaymentStatus.failure)
          .having((s) => s.errorMessage, 'errorMessage', contains('Insufficient')),
    ],
    verify: (_) {
      verifyNever(() => mockDataSource.confirmPayment(any()));
    },
  );

  blocTest<PaymentMethodCubit, PaymentMethodState>(
    'omits variantUuid and quantity from the intent request for a cart checkout',
    build: () {
      when(() => mockDataSource.createIntent(
            addressId: '12',
            variantUuid: null,
            quantity: null,
          )).thenAnswer(
        (_) async => const BigodIntentResponse(
          token: 'tok-cart',
          amount: 200,
          breakdown: BigodIntentBreakdown(
            subtotal: 200,
            discount: 0,
            tax: 0,
            shipping: 0,
            total: 200,
          ),
          customerBalance: 500,
        ),
      );
      when(() => mockDataSource.confirmPayment('tok-cart')).thenAnswer(
        (_) async => const BigodConfirmResponse(
          status: 'PAID',
          amount: 200,
          order: BigodOrderRef(uuid: 'o-uuid-2', orderNumber: 'ORD-2'),
          balance: 300,
        ),
      );
      final cartItem = CartItemEntity(
        id: 1,
        quantity: 2,
        unitPrice: 100,
        totalPrice: 200,
        product: const CartProductEntity(uuid: 'p1', title: 'Widget', slug: 'widget'),
        variant: const CartVariantEntity(uuid: 'v1', sku: 'W-1', stock: 10),
        vendor: const CartVendorEntity(uuid: 've1', shopName: 'Acme'),
      );
      return PaymentMethodCubit(
        userEmail: 'buyer@example.com',
        vendorEmail: 'vendor@example.com',
        bigodPaymentDataSource: mockDataSource,
        clearCartUseCase: mockClearCart,
        cartItems: [cartItem],
      )..updateDeliveryAddress(
          name: 'Jane',
          phone: '555',
          address: '1 Road',
          city: 'City',
          postal: '00000',
          addressId: '12',
        );
    },
    act: (cubit) => cubit.makePayment(),
    expect: () => [
      isA<PaymentMethodState>().having((s) => s.status, 'status', PaymentStatus.loading),
      isA<PaymentMethodState>()
          .having((s) => s.status, 'status', PaymentStatus.success)
          .having((s) => s.orderId, 'orderId', 'ORD-2'),
    ],
  );
}
