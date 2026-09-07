import 'package:bingo_pay/features/categories/presentation/widgets/categories_grid.dart';
import 'package:bingo_pay/features/categories/presentation/widgets/categories_metrics.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets(
    'an empty categories list shows a "No categories available" message '
    'instead of rendering nothing',
    (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) => CategoriesGrid(
                metrics: CategoriesMetrics.of(context),
                categories: const [],
              ),
            ),
          ),
        ),
      );

      expect(find.text('No categories available'), findsOneWidget);
    },
  );
}
