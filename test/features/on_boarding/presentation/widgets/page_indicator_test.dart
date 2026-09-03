import 'package:bingo_pay/features/on_boarding/presentation/widgets/onboarding_metrics.dart';
import 'package:bingo_pay/features/on_boarding/presentation/widgets/page_indicator.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

const _metrics = OnboardingMetrics(
  isRow: false,
  imageWidth: 200,
  imageHeight: 200,
  title: 24,
  subtitle: 14,
  buttonHeight: 44,
  buttonWidth: 112,
  buttonFont: 13,
  dotSize: 7,
  hPad: 20,
  gapImage: 18,
  gapTitle: 10,
  bottomGap: 12,
  skipFont: 14,
);

void main() {
  Future<void> pump(WidgetTester tester, {required int count, required int currentPage}) {
    return tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: PageIndicator(
            count: count,
            currentPage: currentPage,
            metrics: _metrics,
          ),
        ),
      ),
    );
  }

  testWidgets('renders one dot per page', (tester) async {
    await pump(tester, count: 3, currentPage: 0);

    expect(find.byType(AnimatedContainer), findsNWidgets(3));
  });

  testWidgets('the active dot is wider than idle dots', (tester) async {
    await pump(tester, count: 3, currentPage: 1);

    final containers = tester
        .widgetList<AnimatedContainer>(find.byType(AnimatedContainer))
        .toList();

    final widths = containers
        .map((c) => (c.constraints as BoxConstraints).maxWidth)
        .toList();

    expect(widths[1], greaterThan(widths[0]));
    expect(widths[1], greaterThan(widths[2]));
    expect(widths[0], widths[2]);
  });

  testWidgets('renders zero dots when count is 0', (tester) async {
    await pump(tester, count: 0, currentPage: 0);

    expect(find.byType(AnimatedContainer), findsNothing);
  });

  testWidgets(
    'currentPage outside the valid range still renders without throwing '
    '(no dot ends up marked active)',
    (tester) async {
      await pump(tester, count: 3, currentPage: 5);

      final containers = tester
          .widgetList<AnimatedContainer>(find.byType(AnimatedContainer))
          .toList();
      final widths = containers
          .map((c) => (c.constraints as BoxConstraints).maxWidth)
          .toSet();

      // No dot matched currentPage == index, so every dot is the idle width.
      expect(widths, hasLength(1));
    },
  );
}
