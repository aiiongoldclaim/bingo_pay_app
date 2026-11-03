import 'package:bingo_pay/features/membershipNew/presentation/cubit/tvs_membership_cubit.dart';
import 'package:bingo_pay/features/membershipNew/presentation/widgets/checkout_widgets.dart';
import 'package:bingo_pay/features/membershipNew/presentation/widgets/membership_metrices.dart';
import 'package:bingo_pay/features/scanner/data/tvs_qr_datasource.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class _MockTvs extends Mock implements TvsQrDataSource {}

void main() {
  late _MockTvs tvs;
  late TvsMembershipCubit cubit;

  setUp(() {
    tvs = _MockTvs();
    when(() => tvs.membershipQuote('plan-1')).thenAnswer(
      (_) async => {
        'canPay': true,
        'coins': {'total': '999.00', 'currency': 'INR'},
      },
    );
    cubit = TvsMembershipCubit(tvs, 'plan-1');
  });

  tearDown(() => cubit.close());

  test('TVS Wallet switched off is a quote with its code, to hide it', () async {
    when(() => tvs.membershipQuote(any())).thenThrow(
      const TvsQrException('FEATURE_DISABLED', 'Not on your account.'),
    );

    await cubit.load();

    expect(cubit.state?['canPay'], isFalse);
    expect(cubit.state?['reasonCode'], 'FEATURE_DISABLED');
  });

  test('pays the quoted coins once; a changed price is a new payment', () async {
    await cubit.load();
    final bodies = <Map<String, dynamic>>[];
    var calls = 0;
    when(() => tvs.membershipPay(any())).thenAnswer((inv) async {
      bodies.add(Map.of(inv.positionalArguments.first as Map<String, dynamic>));
      calls++;
      if (calls == 1) throw Exception('timeout'); // a retry follows
      if (calls == 2) throw const TvsQrException('QUOTE_CHANGED', 'New price');
      return {
        'subscription': {'uuid': 's-1', 'reference': 'MEM-1', 'status': 'ACTIVE'},
      };
    });

    await expectLater(cubit.pay(), throwsException);
    await expectLater(cubit.pay(), throwsA(isA<TvsQrException>()));
    final paid = await cubit.pay(pin: '4829');

    expect(bodies.first, {
      'planUuid': 'plan-1',
      'idempotencyKey': bodies.first['idempotencyKey'],
      'expectedCoins': '999.00',
    });
    expect(bodies[0]['idempotencyKey'], bodies[1]['idempotencyKey']);
    expect(bodies[2]['idempotencyKey'], isNot(bodies[1]['idempotencyKey']));
    expect(bodies[2]['pin'], '4829');
    expect((paid['subscription'] as Map)['status'], 'ACTIVE');
  });

  testWidgets('the TVS card shows the coins, and why it can’t pay', (
    tester,
  ) async {
    var tapped = false;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Builder(
            builder: (context) => TvsWalletPaymentCard(
              metrics: MembershipMetrics.of(context),
              quote: const {
                'canPay': false,
                'reasonCode': 'INSUFFICIENT_FUNDS',
                'reason': 'You need 99.00 more TVS Coins.',
                'price': {'currency': 'USD', 'amount': '12.00'},
                'coins': {
                  'total': '999.00',
                  'available': '900.00',
                  'currency': 'INR',
                  'rateText': '1 USD = 83.25 INR',
                },
              },
              selected: true,
              onTap: () => tapped = true,
              onBack: () {},
            ),
          ),
        ),
      ),
    );

    expect(find.text('₹999.00 · Balance ₹900.00'), findsOneWidget);
    expect(find.text('1 USD = 83.25 INR'), findsOneWidget);
    expect(find.text('You need 99.00 more TVS Coins.'), findsOneWidget);
    expect(find.text('Add money'), findsOneWidget);
    await tester.tap(find.text('TVS Wallet'));
    expect(tapped, isTrue);
  });
}
