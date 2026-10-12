import 'package:bingo_pay/features/cart/domain/entities/cart_item_entity.dart';
import 'package:bingo_pay/features/cart/domain/usecases/clear_cart_usecase.dart';
import 'package:bingo_pay/features/payment/data/bigod_payment_datasource.dart';
import 'package:bingo_pay/features/payment/data/models/bigod_intent_response.dart';
import 'package:bingo_pay/features/payment/data/models/stripe_intent_response.dart';
import 'package:bingo_pay/features/payment/data/stripe_payment_datasource.dart';
import 'package:bingo_pay/features/payment/presentation/cubit/payment_cubit.dart';
import 'package:bingo_pay/features/payment/presentation/cubit/payment_state.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:mocktail/mocktail.dart';

class MockBigodPaymentDataSource extends Mock implements BigodPaymentDataSource {}

class MockStripePaymentDataSource extends Mock
    implements StripePaymentDataSource {}

class MockClearCartUseCase extends Mock implements ClearCartUseCase {}

const _intent = StripeIntentResponse(
  paymentUuid: 'p-1',
  checkoutUrl: 'https://checkout.stripe.com/c/pay/cs_test_123',
  amount: 118,
  breakdown: BigodIntentBreakdown(
    subtotal: 100,
    discount: 0,
    tax: 18,
    shipping: 0,
    total: 118,
  ),
);

void main() {
  late MockBigodPaymentDataSource mockBigod;
  late MockStripePaymentDataSource mockStripe;
  late MockClearCartUseCase mockClearCart;

  setUp(() {
    mockBigod = MockBigodPaymentDataSource();
    mockStripe = MockStripePaymentDataSource();
    mockClearCart = MockClearCartUseCase();
    when(() => mockClearCart()).thenAnswer((_) async => const Right('cleared'));
  });

  PaymentMethodCubit buildCubit({List<CartItemEntity> cartItems = const []}) {
    return PaymentMethodCubit(
      productPrice: 100,
      userEmail: 'buyer@example.com',
      vendorEmail: 'vendor@example.com',
      variantUuid: cartItems.isEmpty ? 'variant-1' : null,
      cartItems: cartItems,
      bigodPaymentDataSource: mockBigod,
      stripePaymentDataSource: mockStripe,
      clearCartUseCase: mockClearCart,
    )
      ..selectPaymentMethod(PaymentMethod.card)
      ..updateDeliveryAddress(
        name: 'Jane',
        phone: '555',
        address: '1 Road',
        city: 'City',
        postal: '00000',
        addressId: '12',
      );
  }

  void stubIntent(StripeIntentResponse intent) {
    when(() => mockStripe.createIntent(
          addressId: '12',
          variantUuid: 'variant-1',
          quantity: 1,
        )).thenAnswer((_) async => intent);
  }

  test('knows only the item total until the server has priced the basket', () {
    final cubit = buildCubit();
    addTearDown(cubit.close);

    // No tax or delivery worked out in the app.
    expect(cubit.state.isQuoted, isFalse);
    expect(cubit.state.itemTotal, 100);
    expect(cubit.state.taxes, 0);
    expect(cubit.state.deliveryCharge, 0);
  });

  blocTest<PaymentMethodCubit, PaymentMethodState>(
    'loadQuote takes tax, delivery and the total from the server',
    build: () {
      when(() => mockStripe.getQuote(
            addressId: '12',
            variantUuid: 'variant-1',
            quantity: 1,
          )).thenAnswer(
        (_) async => const BigodIntentBreakdown(
          subtotal: 100,
          discount: 0,
          tax: 7.5,
          shipping: 12,
          total: 119.5,
        ),
      );
      return buildCubit();
    },
    act: (cubit) => cubit.loadQuote(),
    expect: () => [
      isA<PaymentMethodState>()
          .having((s) => s.isQuoted, 'isQuoted', true)
          .having((s) => s.taxes, 'taxes', 7.5)
          .having((s) => s.deliveryCharge, 'deliveryCharge', 12)
          .having((s) => s.totalAmount, 'totalAmount', 119.5),
    ],
  );

  blocTest<PaymentMethodCubit, PaymentMethodState>(
    'loadQuote leaves the basket unpriced when the server cannot be asked',
    build: () {
      when(() => mockStripe.getQuote(
            addressId: '12',
            variantUuid: 'variant-1',
            quantity: 1,
          )).thenThrow(Exception('offline'));
      return buildCubit();
    },
    act: (cubit) => cubit.loadQuote(),
    expect: () => <PaymentMethodState>[],
    verify: (cubit) => expect(cubit.state.isQuoted, isFalse),
  );

  blocTest<PaymentMethodCubit, PaymentMethodState>(
    'startCardPayment adopts the server quote and leaves the order unplaced',
    build: () {
      stubIntent(_intent);
      return buildCubit();
    },
    act: (cubit) => cubit.startCardPayment(),
    expect: () => [
      isA<PaymentMethodState>()
          .having((s) => s.status, 'status', PaymentStatus.loading)
          .having((s) => s.isProcessing, 'isProcessing', true),
      isA<PaymentMethodState>()
          // Not success: nothing is paid until the server says so.
          .having((s) => s.status, 'status', PaymentStatus.initial)
          .having((s) => s.isProcessing, 'isProcessing', false)
          .having((s) => s.totalAmount, 'totalAmount', 118)
          .having((s) => s.taxes, 'taxes', 18)
          .having((s) => s.isQuoted, 'isQuoted', true),
    ],
    verify: (_) {
      // The card rail never touches the wallet rail or the cart.
      verifyNever(() => mockBigod.confirmPayment(any()));
      verifyNever(() => mockClearCart());
    },
  );

  test('startCardPayment hands back the intent to open', () async {
    stubIntent(_intent);
    final cubit = buildCubit();
    addTearDown(cubit.close);

    final intent = await cubit.startCardPayment();

    expect(intent?.paymentUuid, 'p-1');
    expect(intent?.checkoutUrl, _intent.checkoutUrl);
  });

  test('startCardPayment refuses a checkout url that is not Stripe\'s', () async {
    stubIntent(
      const StripeIntentResponse(
        paymentUuid: 'p-1',
        checkoutUrl: 'https://evil.example.com/pay',
        amount: 118,
      ),
    );
    final cubit = buildCubit();
    addTearDown(cubit.close);

    final intent = await cubit.startCardPayment();

    expect(intent, isNull);
    expect(cubit.state.status, PaymentStatus.failure);
    expect(cubit.state.isProcessing, isFalse);
  });

  blocTest<PaymentMethodCubit, PaymentMethodState>(
    'completeCardPayment reports the order the server placed and leaves the cart to it',
    build: () {
      final cartItem = CartItemEntity(
        id: 1,
        quantity: 2,
        unitPrice: 100,
        totalPrice: 200,
        product: const CartProductEntity(uuid: 'p1', title: 'Widget', slug: 'widget'),
        variant: const CartVariantEntity(uuid: 'v1', sku: 'W-1', stock: 10),
        vendor: const CartVendorEntity(uuid: 've1', shopName: 'Acme'),
      );
      return buildCubit(cartItems: [cartItem]);
    },
    act: (cubit) => cubit.completeCardPayment(
      orderNumber: 'ORD-9',
      orderUuid: 'o-uuid',
    ),
    expect: () => [
      isA<PaymentMethodState>()
          .having((s) => s.status, 'status', PaymentStatus.success)
          .having((s) => s.orderId, 'orderId', 'ORD-9')
          .having((s) => s.orderUuid, 'orderUuid', 'o-uuid'),
    ],
    verify: (_) {
      // The server closed that cart when it placed the order; clearing here
      // could only empty a newer one.
      verifyNever(() => mockClearCart());
    },
  );

  blocTest<PaymentMethodCubit, PaymentMethodState>(
    'loadPaymentMethods offers the card option when the server does',
    build: () {
      when(() => mockStripe.isCardAvailable()).thenAnswer((_) async => true);
      return buildCubit();
    },
    act: (cubit) => cubit.loadPaymentMethods(),
    expect: () => [
      isA<PaymentMethodState>()
          .having((s) => s.cardAvailable, 'cardAvailable', true),
    ],
  );

  blocTest<PaymentMethodCubit, PaymentMethodState>(
    'loadPaymentMethods keeps the card option hidden when the request fails',
    build: () {
      when(() => mockStripe.isCardAvailable()).thenThrow(Exception('offline'));
      return buildCubit();
    },
    act: (cubit) => cubit.loadPaymentMethods(),
    expect: () => <PaymentMethodState>[],
    verify: (cubit) => expect(cubit.state.cardAvailable, isFalse),
  );
}
