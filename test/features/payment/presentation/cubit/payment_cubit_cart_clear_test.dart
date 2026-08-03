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

CartItemEntity _cartItem() => const CartItemEntity(
      id: 1,
      quantity: 1,
      unitPrice: 50,
      totalPrice: 50,
      product: CartProductEntity(uuid: 'p1', title: 'Widget', slug: 'widget'),
      variant: CartVariantEntity(uuid: 'v1', sku: 'W-1', stock: 10),
      vendor: CartVendorEntity(uuid: 've1', shopName: 'Acme'),
    );

void main() {
  late MockBigodPaymentDataSource mockDataSource;
  late MockClearCartUseCase mockClearCart;

  setUp(() {
    mockDataSource = MockBigodPaymentDataSource();
    mockClearCart = MockClearCartUseCase();
    when(() => mockClearCart()).thenAnswer((_) async => const Right('cleared'));
    when(() => mockDataSource.createIntent(
          addressId: any(named: 'addressId'),
          variantUuid: any(named: 'variantUuid'),
          quantity: any(named: 'quantity'),
        )).thenAnswer(
      (_) async => const BigodIntentResponse(
        token: 'tok',
        amount: 50,
        breakdown: BigodIntentBreakdown(
          subtotal: 50,
          discount: 0,
          tax: 0,
          shipping: 0,
          total: 50,
        ),
        customerBalance: 500,
      ),
    );
    when(() => mockDataSource.confirmPayment('tok')).thenAnswer(
      (_) async => const BigodConfirmResponse(
        status: 'PAID',
        amount: 50,
        order: BigodOrderRef(uuid: 'o-uuid', orderNumber: 'ORD-1'),
        balance: 450,
      ),
    );
  });

  blocTest<PaymentMethodCubit, PaymentMethodState>(
    'clears the cart after a successful cart wallet purchase',
    build: () => PaymentMethodCubit(
      userEmail: 'buyer@example.com',
      vendorEmail: 'vendor@example.com',
      cartItems: [_cartItem()],
      bigodPaymentDataSource: mockDataSource,
      clearCartUseCase: mockClearCart,
    )..updateDeliveryAddress(
        name: 'Jane',
        phone: '555',
        address: '1 Road',
        city: 'City',
        postal: '00000',
        addressId: '12',
      ),
    act: (cubit) => cubit.makePayment(),
    expect: () => [
      isA<PaymentMethodState>().having((s) => s.status, 'status', PaymentStatus.loading),
      isA<PaymentMethodState>().having((s) => s.status, 'status', PaymentStatus.success),
    ],
    verify: (_) {
      verify(() => mockClearCart()).called(1);
    },
  );

  blocTest<PaymentMethodCubit, PaymentMethodState>(
    'does not attempt to clear the cart for a buy-now (non-cart) purchase',
    build: () => PaymentMethodCubit(
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
      ),
    act: (cubit) => cubit.makePayment(),
    expect: () => [
      isA<PaymentMethodState>().having((s) => s.status, 'status', PaymentStatus.loading),
      isA<PaymentMethodState>().having((s) => s.status, 'status', PaymentStatus.success),
    ],
    verify: (_) {
      verifyNever(() => mockClearCart());
    },
  );
}
