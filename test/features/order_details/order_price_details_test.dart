import 'package:bingo_pay/features/order_details/presentation/widgets/order_details_metrics.dart';
import 'package:bingo_pay/features/order_details/presentation/widgets/order_price_details.dart';
import 'package:bingo_pay/features/orders/data/models/order_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

Map<String, dynamic> _order({List<Map<String, dynamic>>? charges}) => {
  'uuid': 'o1',
  'orderNumber': 'ORD-1',
  'subtotal': '1',
  'discount': '0',
  'tax': '0.18',
  'shipping': '0',
  'fee': '10',
  'total': '11.18',
  'charges': ?charges,
};

Future<void> _pump(WidgetTester tester, OrderModel order) =>
    tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Builder(
            builder: (context) => OdPriceDetails(
              metrics: OrderDetailMetrics.of(context),
              order: order,
            ),
          ),
        ),
      ),
    );

void main() {
  test('charges are read from the order and survive copyWith', () {
    final order = OrderModel.fromJson(
      _order(
        charges: [
          {'code': 'gst', 'name': 'GST', 'bucket': 'TAX', 'amount': 0.18},
          {'code': 'pf', 'name': 'Platform Fee', 'bucket': 'FEE', 'amount': 10},
        ],
      ),
    );
    expect(order.charges.map((c) => c.name), ['GST', 'Platform Fee']);
    expect(order.charges.last.amount, 10);
    expect(order.copyWith(orderStatus: 'DELIVERED').charges, hasLength(2));
  });

  testWidgets('each charge gets its own line, so the total adds up', (
    tester,
  ) async {
    await _pump(
      tester,
      OrderModel.fromJson(
        _order(
          charges: [
            {'name': 'GST', 'bucket': 'TAX', 'amount': 0.18},
            {'name': 'Platform Fee', 'bucket': 'FEE', 'amount': 10},
          ],
        ),
      ),
    );
    expect(find.text('GST'), findsOneWidget);
    expect(find.text('Platform Fee'), findsOneWidget);
    expect(find.text('Tax'), findsNothing);
    expect(find.text('Shipping Fee'), findsOneWidget); // no shipping charge
  });

  testWidgets('a shipping charge replaces the Shipping Fee line', (
    tester,
  ) async {
    await _pump(
      tester,
      OrderModel.fromJson(
        _order(
          charges: [
            {'name': 'Delivery', 'bucket': 'SHIPPING', 'amount': 5},
          ],
        ),
      ),
    );
    expect(find.text('Delivery'), findsOneWidget);
    expect(find.text('Shipping Fee'), findsNothing);
  });

  testWidgets('an order without charges keeps the old Tax line', (
    tester,
  ) async {
    await _pump(tester, OrderModel.fromJson(_order()));
    expect(find.text('Tax'), findsOneWidget);
    expect(find.text('Shipping Fee'), findsOneWidget);
  });
}
