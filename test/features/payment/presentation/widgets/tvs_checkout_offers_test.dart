import 'package:bingo_pay/features/cart/domain/usecases/clear_cart_usecase.dart';
import 'package:bingo_pay/features/payment/data/bigod_payment_datasource.dart';
import 'package:bingo_pay/features/payment/presentation/cubit/payment_cubit.dart';
import 'package:bingo_pay/features/payment/presentation/widgets/tvs_checkout_offers.dart';
import 'package:bingo_pay/features/scanner/data/tvs_qr_datasource.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class _MockTvs extends Mock implements TvsQrDataSource {}

class _MockBigod extends Mock implements BigodPaymentDataSource {}

class _MockClearCart extends Mock implements ClearCartUseCase {}

const _quote = <String, dynamic>{
  'canPay': true,
  'coins': {'total': '400.00', 'currency': 'INR'},
  'offers': [
    {
      'uuid': 'o1',
      'name': 'Diwali 10% off',
      'code': null,
      'discount': '50.00',
      'applied': true,
      'best': true,
    },
    {
      'uuid': 'o2',
      'name': 'Flat ₹20',
      'code': 'FLAT20',
      'discount': '20.00',
      'applied': false,
      'best': false,
    },
  ],
  'rewards': [
    {'amount': '12.00', 'when': 'AFTER_DAYS'},
  ],
  'almost': [
    {'uuid': 'o3', 'name': 'Big basket', 'hint': 'Add ₹100 more'},
  ],
  'code': null,
  'pin': {
    'limit': '200.00',
    'currency': 'INR',
    'required': true,
    'isSet': true,
    'lockedUntil': null,
  },
};

void main() {
  testWidgets('shows the applied offer, cashback and hint; Change opens the '
      'coupon sheet and picking an offer re-quotes with it', (tester) async {
    final tvs = _MockTvs();
    when(() => tvs.checkoutQuote(any())).thenAnswer((_) async => Map.of(_quote));
    final cubit = PaymentMethodCubit(
      variantUuid: 'v1',
      bigodPaymentDataSource: _MockBigod(),
      clearCartUseCase: _MockClearCart(),
      tvsDataSource: tvs,
    );
    addTearDown(cubit.close);
    await cubit.loadTvsQuote();

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: BlocProvider.value(
            value: cubit,
            child: const SingleChildScrollView(
              child: TvsCheckoutOffers(quote: _quote),
            ),
          ),
        ),
      ),
    );

    expect(find.text('Diwali 10% off'), findsOneWidget);
    expect(find.text('−₹50'), findsOneWidget);
    expect(find.text('+₹12'), findsOneWidget);
    expect(find.text('Add ₹100 more'), findsOneWidget);
    expect(
      find.text('Over ₹200.00 — you’ll confirm with your MPIN'),
      findsOneWidget,
    );

    await tester.tap(find.text('Change'));
    await tester.pumpAndSettle();
    expect(find.text('Apply coupon'), findsOneWidget);
    await tester.tap(find.text('Flat ₹20'));
    await tester.pumpAndSettle();

    final sent = verify(() => tvs.checkoutQuote(captureAny())).captured.last;
    expect(sent, containsPair('offer', 'o2'));
  });
}
