import 'dart:async';

import 'package:bingo_pay/features/cart/domain/usecases/clear_cart_usecase.dart';
import 'package:bingo_pay/features/payment/data/bigod_payment_datasource.dart';
import 'package:bingo_pay/features/payment/presentation/cubit/payment_cubit.dart';
import 'package:bingo_pay/features/payment/presentation/cubit/payment_state.dart';
import 'package:bingo_pay/features/setting/data/datasources/settings_remote_datasource.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class _MockSettings extends Mock implements SettingsRemoteDataSource {}

class _MockBigod extends Mock implements BigodPaymentDataSource {}

class _MockClearCart extends Mock implements ClearCartUseCase {}

// 18% tax, ₹10 delivery, and a ₹2 fee on card payments only.
const _rules = [
  {'bucket': 'TAX', 'calcType': 'PERCENTAGE', 'value': 18, 'appliesTo': 'ALL'},
  {'bucket': 'SHIPPING', 'calcType': 'FLAT', 'value': 10, 'appliesTo': 'ALL'},
  {
    'bucket': 'FEE',
    'calcType': 'FLAT',
    'value': 2,
    'appliesTo': 'ALL',
    'paymentMethods': ['STRIPE'],
  },
];

void main() {
  late _MockSettings settings;
  late PaymentMethodCubit cubit;

  setUp(() {
    settings = _MockSettings();
    when(() => settings.getCharges()).thenAnswer((_) async => _rules);
    cubit = PaymentMethodCubit(
      productPrice: 100,
      variantUuid: 'v1',
      bigodPaymentDataSource: _MockBigod(),
      settingsDataSource: settings,
      clearCartUseCase: _MockClearCart(),
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

  test('priced for the selected method, fees under "Taxes & Fees"', () async {
    await cubit.loadQuote(); // Bingold Wallet: no card fee
    expect(cubit.state.isQuoted, isTrue);
    expect(cubit.state.taxes, 18);
    expect(cubit.state.deliveryCharge, 10);
    expect(cubit.state.totalAmount, 128);

    cubit.selectPaymentMethod(PaymentMethod.card);
    await Future<void>.delayed(Duration.zero);
    expect(cubit.state.taxes, 20);
    expect(cubit.state.totalAmount, 130);
    verify(() => settings.getCharges()).called(1); // the rules are fetched once
  });

  test('an answer for an earlier method is dropped', () async {
    final slow = Completer<List<Map<String, dynamic>>>();
    when(() => settings.getCharges()).thenAnswer((_) => slow.future);

    final first = cubit.loadQuote(); // still fetching the rules
    cubit.selectPaymentMethod(PaymentMethod.cashOnDelivery);
    slow.complete(_rules);
    await first;

    expect(cubit.state.taxes, 0);
    expect(cubit.state.totalAmount, 100);
  });

  test('cash on delivery is charged its item total, with no tax or delivery', () async {
    await cubit.loadQuote();
    cubit.selectPaymentMethod(PaymentMethod.cashOnDelivery);

    expect(cubit.state.isQuoted, isTrue);
    expect(cubit.state.taxes, 0);
    expect(cubit.state.deliveryCharge, 0);
    expect(cubit.state.totalAmount, 100);
  });
}
