import 'dart:async';

import 'package:bingo_pay/features/scanner/data/tvs_qr_datasource.dart';
import 'package:bingo_pay/features/scanner/presentation/cubit/payment_cubit.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class _MockApi extends Mock implements TvsQrDataSource {}

const _shop = {'shop': {'name': 'Chai Point'}, 'currency': 'INR', 'canPay': true};
Map<String, dynamic> _quote(String payable) =>
    {'payable': payable, 'sufficient': true, 'currency': 'INR'};

void main() {
  late _MockApi api;
  late PaymentCubit cubit;
  final keys = <String>[];

  Future<void> typeAndQuote(String amount, {String code = ''}) async {
    cubit.inputChanged(amount, code);
    await cubit.requote();
  }

  setUp(() async {
    api = _MockApi();
    keys.clear();
    when(() => api.resolve(any())).thenAnswer((_) async => Map.of(_shop));
    when(() => api.pay(
          token: any(named: 'token'),
          amount: any(named: 'amount'),
          code: any(named: 'code'),
          idempotencyKey: any(named: 'idempotencyKey'),
          expectedPayable: any(named: 'expectedPayable'),
          pin: any(named: 'pin'),
          note: any(named: 'note'),
        )).thenAnswer((inv) async {
      keys.add(inv.namedArguments[#idempotencyKey] as String);
      return {'transactionUuid': 't1'};
    });
    cubit = PaymentCubit(api);
    await cubit.resolve('shop-token');
  });

  tearDown(() => cubit.close());

  test('sends the quoted payable and reuses the key on retry', () async {
    when(() => api.quote('shop-token', '250', 'QAQR'))
        .thenAnswer((_) async => _quote('225.00'));
    await typeAndQuote('250', code: ' QAQR ');
    expect(cubit.state.canSubmit, isTrue);

    await cubit.pay();
    await cubit.pay(pin: '2580'); // e.g. after PIN_REQUIRED

    verify(() => api.pay(
          token: 'shop-token',
          amount: '250',
          code: 'QAQR',
          idempotencyKey: any(named: 'idempotencyKey'),
          expectedPayable: '225.00',
          pin: any(named: 'pin'),
          note: any(named: 'note'),
        )).called(2);
    expect(keys.toSet(), hasLength(1));
    expect(keys.first.length, lessThanOrEqualTo(100)); // API limit
  });

  test('a new amount is a new payment with a new key', () async {
    when(() => api.quote(any(), any(), any()))
        .thenAnswer((inv) async => _quote('${inv.positionalArguments[1]}.00'));
    await typeAndQuote('100');
    await cubit.pay();
    await typeAndQuote('200');
    await cubit.pay();

    expect(keys.toSet(), hasLength(2));
  });

  test('a slow quote for an old amount is dropped', () async {
    final slow = Completer<Map<String, dynamic>>();
    when(() => api.quote(any(), '1', any())).thenAnswer((_) => slow.future);
    when(() => api.quote(any(), '15', any()))
        .thenAnswer((_) async => _quote('15.00'));

    cubit.inputChanged('1', '');
    final old = cubit.requote();
    await typeAndQuote('15');
    slow.complete(_quote('1.00'));
    await old;

    expect(cubit.state.quote?['payable'], '15.00');
  });

  test('typing clears the quote so Pay waits for a fresh one', () async {
    when(() => api.quote(any(), any(), any()))
        .thenAnswer((_) async => _quote('50.00'));
    await typeAndQuote('50');
    cubit.inputChanged('500', '');

    expect(cubit.state.quote, isNull);
    expect(cubit.state.canSubmit, isFalse);
  });
}
