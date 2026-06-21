import 'package:bingo_pay/core/di/injection.dart';
import 'package:bingo_pay/features/transactions/data/datasources/order_remote_datasource.dart';
import 'package:bingo_pay/features/transactions/presentation/screens/transaction_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../helpers/mocks.dart';

void main() {
  late MockOrderRemoteDataSource dataSource;

  Map<String, dynamic> order({
    required String id,
    required String name,
    required String status,
    required Duration age,
  }) {
    return {
      'order_id': id,
      'customer_name': name,
      'customer_phone': '9999999999',
      'total_amount': 500,
      'payment_type': 'cod',
      'status': status,
      'created_at': DateTime.now().subtract(age).toIso8601String(),
      'items': [
        {'product_name': 'Cotton T-Shirt', 'quantity': 1, 'price': 500},
      ],
    };
  }

  setUp(() {
    dataSource = MockOrderRemoteDataSource();
    when(() => dataSource.getOrders()).thenAnswer(
      (_) async => [
        order(id: 'ORD1', name: 'Rashi Khurana', status: 'pending', age: const Duration(minutes: 12)),
        order(id: 'ORD2', name: 'Karan Mehta', status: 'delivered', age: const Duration(days: 3)),
        order(id: 'ORD3', name: 'Ishita Verma', status: 'delivered', age: const Duration(days: 12)),
        order(id: 'ORD4', name: 'Achal Sharma', status: 'delivered', age: const Duration(hours: 2)),
      ],
    );
    when(() => dataSource.updateOrderStatus(orderId: any(named: 'orderId'), status: any(named: 'status')))
        .thenAnswer((_) async {});
    getIt.registerSingleton<OrderRemoteDataSource>(dataSource);
  });

  tearDown(() => getIt.reset());

  testWidgets('status tab and date chip combine to filter the order list', (tester) async {
    // Wide+tall surface so every tab/chip/card is laid out without needing scroll gestures.
    tester.view.physicalSize = const Size(1200, 3200);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(const MaterialApp(home: TransactionScreen()));
    await tester.pumpAndSettle();

    // "Today" is selected by default; only today's orders should show.
    expect(find.text('Rashi Khurana'), findsOneWidget);
    expect(find.text('Karan Mehta'), findsNothing); // 3 days ago, not today

    await tester.tap(find.widgetWithText(ChoiceChip, 'This week'));
    await tester.pumpAndSettle();

    expect(find.text('Karan Mehta'), findsOneWidget);
    expect(find.text('Ishita Verma'), findsNothing); // 12 days ago, beyond this week

    await tester.tap(find.text('Delivered').first); // the status tab, not a card's status pill
    await tester.pumpAndSettle();

    expect(find.text('Achal Sharma'), findsOneWidget); // delivered, today
    expect(find.text('Rashi Khurana'), findsNothing); // pending, not delivered
    expect(tester.takeException(), isNull);
  });

  testWidgets('tapping an order card opens the status sheet and updates status', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: TransactionScreen()));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Rashi Khurana'));
    await tester.pumpAndSettle();

    expect(find.text('Update order status'), findsOneWidget);

    await tester.tap(find.widgetWithText(ListTile, 'Confirmed'));
    await tester.pumpAndSettle();

    verify(() => dataSource.updateOrderStatus(orderId: 'ORD1', status: 'confirmed')).called(1);
    expect(tester.takeException(), isNull);
  });
}
