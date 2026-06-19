import 'package:bingo_pay/core/router/app_routes.dart';
import 'package:bingo_pay/features/transactions/presentation/screens/transaction_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

void main() {
  Widget buildApp() {
    final router = GoRouter(
      initialLocation: AppRoutes.vendorTransactions,
      routes: [
        GoRoute(path: AppRoutes.vendorTransactions, builder: (_, _) => const TransactionScreen()),
        GoRoute(
          path: AppRoutes.vendorTransactionDetail,
          builder: (context, state) => Text('Detail ${state.pathParameters['id']}'),
        ),
      ],
    );
    return MaterialApp.router(routerConfig: router);
  }

  testWidgets('status tab and date chip combine to filter the order list', (tester) async {
    // Wide+tall surface so every tab/chip/card is laid out without needing scroll gestures.
    tester.view.physicalSize = const Size(1200, 3200);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(buildApp());
    await tester.pumpAndSettle();

    // "Today" is selected by default; all 5 "today" orders should show.
    expect(find.text('Rashi Khurana'), findsOneWidget);
    expect(find.text('Karan Mehta'), findsNothing); // daysAgo: 3, not today

    await tester.tap(find.widgetWithText(ChoiceChip, 'This week'));
    await tester.pumpAndSettle();

    expect(find.text('Karan Mehta'), findsOneWidget);
    expect(find.text('Ishita Verma'), findsNothing); // daysAgo: 12, beyond this week

    await tester.tap(find.text('Delivered').first); // the status tab, not a card's status pill
    await tester.pumpAndSettle();

    expect(find.text('Achal Sharma'), findsOneWidget); // delivered, today
    expect(find.text('Rashi Khurana'), findsNothing); // pending, not delivered
    expect(tester.takeException(), isNull);
  });

  testWidgets('tapping an order card navigates to its detail route', (tester) async {
    await tester.pumpWidget(buildApp());
    await tester.pumpAndSettle();

    await tester.tap(find.text('Rashi Khurana'));
    await tester.pumpAndSettle();

    expect(find.text('Detail ORD12390'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
