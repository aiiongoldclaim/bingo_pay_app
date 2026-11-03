import 'package:bingo_pay/features/membershipNew/data/models/membership_balance_model.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  BigodBalance parse(Map<String, dynamic> extra) => BigodBalance.fromJson({
    'bigodBalance': 5000,
    'balances': const [],
    ...extra,
  });

  test('reads the USD and local value of GET /payments/bigod/balance', () {
    final b = parse({
      'usdValue': 410.5,
      'local': {
        'currency': 'INR',
        'value': 34122.11,
        'perUsd': '83.1245',
        'source': 'WALLET_KYC',
      },
    });

    expect(b.usdValue, 410.5);
    expect(b.localCurrency, 'INR');
    expect(b.localValue, 34122.11);
    expect(b.valueLine, '≈ \$410.50 · ≈ ₹34,122.11');
  });

  test('USD only when the local rate is unknown or is USD', () {
    expect(parse({'usdValue': 410.5, 'local': null}).valueLine, '≈ \$410.50');
    expect(
      parse({
        'usdValue': 410.5,
        'local': {'currency': 'USD', 'value': 410.5},
      }).valueLine,
      '≈ \$410.50',
    );
  });

  test('nothing extra without a USD value (older server or no price)', () {
    expect(parse({}).valueLine, isNull);
    expect(
      parse({
        'usdValue': null,
        'local': {'currency': 'INR', 'value': 1},
      }).valueLine,
      isNull,
    );
  });

  test('sub-cent keeps four places; other dollars are named', () {
    expect(
      parse({
        'usdValue': '0.0041',
        'local': {'currency': 'SGD', 'value': 0.0055},
      }).valueLine,
      '≈ \$0.0041 · ≈ SGD 0.0055',
    );
  });
}
