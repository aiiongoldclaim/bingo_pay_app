import 'package:bingo_pay/features/payment/domain/checkout_charges.dart';
import 'package:flutter_test/flutter_test.dart';

// The cases the server's charge-calculator.ts prices, run through the port.
void main() {
  const product = ChargeLine(subtotal: 400, quantity: 2, vendor: 'a');
  const service = ChargeLine(subtotal: 100, isService: true, vendor: 'b');

  test('percentage tax and flat delivery, product-only rules', () {
    final c = computeCharges(
      [
        {'bucket': 'TAX', 'calcType': 'PERCENTAGE', 'value': 18, 'appliesTo': 'ALL'},
        {'bucket': 'SHIPPING', 'calcType': 'FLAT', 'value': 50, 'appliesTo': 'PRODUCT'},
      ],
      [product, service],
    );
    expect(c.tax, 90); // 18% of 500
    expect(c.shipping, 50);
    expect(c.fee, 0);
  });

  test('free above and minimum order value', () {
    final rules = [
      {'bucket': 'SHIPPING', 'calcType': 'FLAT', 'value': 50, 'appliesTo': 'ALL', 'freeAbove': 500},
      {'bucket': 'FEE', 'calcType': 'FLAT', 'value': 5, 'appliesTo': 'ALL', 'minOrderValue': 1000},
    ];
    expect(computeCharges(rules, [product]).shipping, 50);
    expect(computeCharges(rules, [product, service]).shipping, 0); // 500 is free
    expect(computeCharges(rules, [product]).fee, 0); // under the minimum
  });

  test('method-only rules apply to that method, and not when none is known', () {
    final rules = [
      {
        'bucket': 'FEE',
        'calcType': 'FLAT',
        'value': 3,
        'appliesTo': 'ALL',
        'paymentMethods': ['STRIPE'],
      },
    ];
    expect(computeCharges(rules, [product], method: 'STRIPE').fee, 3);
    expect(computeCharges(rules, [product], method: 'BIGOD').fee, 0);
    expect(computeCharges(rules, [product]).fee, 0);
  });

  test('per item, per vendor, charges on charges, and caps when given', () {
    final c = computeCharges(
      [
        {'bucket': 'SHIPPING', 'calcType': 'PER_VENDOR', 'value': 20, 'appliesTo': 'ALL'},
        {'bucket': 'FEE', 'calcType': 'PER_ITEM', 'value': 1.5, 'appliesTo': 'ALL'},
        {
          'bucket': 'TAX',
          'calcType': 'PERCENTAGE',
          'value': 10,
          'appliesTo': 'ALL',
          'base': 'SUBTOTAL_WITH_CHARGES',
        },
        {'bucket': 'FEE', 'calcType': 'PERCENTAGE', 'value': 50, 'appliesTo': 'ALL', 'maxAmount': 7},
      ],
      [product, service],
    );
    expect(c.shipping, 40); // 2 vendors
    expect(c.tax, 54.45); // 10% of (500 + 40 + 4.5)
    expect(c.fee, 11.5); // 1.5 × 3 items + capped 7
  });
}
