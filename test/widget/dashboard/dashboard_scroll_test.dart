import 'package:bingo_pay/features/dashboard/presentation/screen/dashboard_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('dashboard app bar does not overflow when scrolled to collapsed state', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: DashboardScreen()));
    await tester.pumpAndSettle();

    await tester.drag(find.byType(CustomScrollView), const Offset(0, -500));
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
  });
}
