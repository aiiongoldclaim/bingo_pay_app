import 'package:bingo_pay/features/cart/domain/usecases/clear_cart_usecase.dart';
import 'package:bingo_pay/features/payment/data/bigod_payment_datasource.dart';
import 'package:bingo_pay/features/payment/presentation/cubit/payment_cubit.dart';
import 'package:bingo_pay/features/payment/presentation/cubit/payment_state.dart';
import 'package:bingo_pay/features/scanner/data/tvs_qr_datasource.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class _MockTvs extends Mock implements TvsQrDataSource {}

class _MockBigod extends Mock implements BigodPaymentDataSource {}

class _MockClearCart extends Mock implements ClearCartUseCase {}

const _quote = {
  'canPay': true,
  'coins': {'total': '450.00', 'currency': 'INR'},
};

void main() {
  late _MockTvs tvs;
  late PaymentMethodCubit cubit;
  final bodies = <Map<String, dynamic>>[];

  setUp(() {
    tvs = _MockTvs();
    bodies.clear();
    when(() => tvs.checkoutQuote(any())).thenAnswer((_) async => Map.of(_quote));
    cubit = PaymentMethodCubit(
      productPrice: 450,
      variantUuid: 'variant-1',
      quantity: 2,
      bigodPaymentDataSource: _MockBigod(),
      clearCartUseCase: _MockClearCart(),
      tvsDataSource: tvs,
    )..updateDeliveryAddress(
        name: 'Asha',
        phone: '555',
        address: '1 Road',
        city: 'City',
        postal: '00000',
        addressId: '12',
      );
  });

  tearDown(() => cubit.close());

  test('quotes the buy-now line for the chosen address', () async {
    await cubit.loadTvsQuote();

    expect(cubit.state.tvsQuote?['canPay'], isTrue);
    final basket =
        verify(() => tvs.checkoutQuote(captureAny())).captured.single as Map;
    expect(basket, {
      'variantUuid': 'variant-1',
      'quantity': 2,
      'addressId': '12',
      'method': 'TVS_WALLET',
    });
  });

  test('TVS Wallet switched off for the account hides it, off the choice too', () async {
    cubit.selectPaymentMethod(PaymentMethod.tvsWallet);
    when(() => tvs.checkoutQuote(any())).thenThrow(
      const TvsQrException('FEATURE_DISABLED', 'TVS Wallet isn’t available on your account.'),
    );

    await cubit.loadTvsQuote();

    expect(cubit.state.tvsAvailable, isFalse);
    expect(cubit.state.selectedMethod, PaymentMethod.wallet);
  });

  test('any other failure keeps TVS Wallet, with the reason', () async {
    when(() => tvs.checkoutQuote(any())).thenThrow(
      const TvsQrException('RATE_UNAVAILABLE', 'Exchange rates are unavailable right now.'),
    );

    await cubit.loadTvsQuote();

    expect(cubit.state.tvsAvailable, isTrue);
    expect(cubit.state.tvsQuote, {
      'canPay': false,
      'reason': 'Exchange rates are unavailable right now.',
    });
  });

  test('pays the quoted coins once; a changed price is a new payment', () async {
    await cubit.loadTvsQuote();
    var calls = 0;
    when(() => tvs.checkoutPay(any())).thenAnswer((inv) async {
      bodies.add(Map.of(inv.positionalArguments.first as Map<String, dynamic>));
      calls++;
      if (calls == 1) throw Exception('timeout'); // a retry follows
      if (calls == 2) throw const TvsQrException('QUOTE_CHANGED', 'New price');
      return {
        'order': {'uuid': 'o-1', 'orderNumber': 'ORD-1'},
      };
    });

    await expectLater(cubit.payWithTvs(), throwsException);
    await expectLater(cubit.payWithTvs(), throwsA(isA<TvsQrException>()));
    await cubit.payWithTvs(pin: '4829');

    expect(bodies.first['expectedCoins'], '450.00');
    expect(bodies.first['addressId'], '12');
    expect(bodies[0]['idempotencyKey'], bodies[1]['idempotencyKey']);
    expect(bodies[2]['idempotencyKey'], isNot(bodies[1]['idempotencyKey']));
    expect(bodies[2]['pin'], '4829');
    expect(cubit.state.status, PaymentStatus.success);
    expect(cubit.state.orderId, 'ORD-1');
    expect(cubit.state.orderUuid, 'o-1');
  });
}
