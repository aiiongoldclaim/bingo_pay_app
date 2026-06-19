import 'package:bingo_pay/features/products/presentation/screens/products_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('tapping "Out of stock" chip filters the product list', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: ProductsScreen()));
    await tester.pumpAndSettle();

    expect(find.text('Leather wallet — brown'), findsOneWidget);
    expect(find.text("Men's cotton t-shirt — navy"), findsOneWidget);

    await tester.tap(find.widgetWithText(ChoiceChip, 'Out of stock'));
    await tester.pumpAndSettle();

    expect(find.text('Leather wallet — brown'), findsOneWidget);
    expect(find.text("Men's cotton t-shirt — navy"), findsNothing);
    expect(tester.takeException(), isNull);
  });
}
