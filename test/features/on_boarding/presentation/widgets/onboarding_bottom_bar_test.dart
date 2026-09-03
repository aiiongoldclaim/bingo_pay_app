import 'package:bingo_pay/features/on_boarding/presentation/widgets/onboarding_bottom_bar.dart';
import 'package:bingo_pay/features/on_boarding/presentation/widgets/onboarding_metrics.dart';
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
  Future<void> pump(
    WidgetTester tester, {
    required int currentPage,
    required int total,
    required VoidCallback onBack,
    required VoidCallback onNext,
  }) {
    return tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: OnboardingBottomBar(
            metrics: _metrics,
            currentPage: currentPage,
            total: total,
            onBack: onBack,
            onNext: onNext,
          ),
        ),
      ),
    );
  }

  testWidgets('shows "Next" and an arrow icon on a middle page', (
    tester,
  ) async {
    await pump(
      tester,
      currentPage: 1,
      total: 3,
      onBack: () {},
      onNext: () {},
    );

    expect(find.text('Next'), findsOneWidget);
    expect(find.text('Get Started'), findsNothing);
  });

  testWidgets('shows "Get Started" with no arrow icon on the last page', (
    tester,
  ) async {
    await pump(
      tester,
      currentPage: 2,
      total: 3,
      onBack: () {},
      onNext: () {},
    );

    expect(find.text('Get Started'), findsOneWidget);
    expect(find.text('Next'), findsNothing);
  });

  testWidgets('back button is present but not tappable on the first page', (
    tester,
  ) async {
    var backTapped = false;

    await pump(
      tester,
      currentPage: 0,
      total: 3,
      onBack: () => backTapped = true,
      onNext: () {},
    );

    final ignorePointer = tester.widget<IgnorePointer>(
      find.descendant(
        of: find.byType(OnboardingBottomBar),
        matching: find.byType(IgnorePointer),
      ),
    );
    expect(ignorePointer.ignoring, isTrue);

    final opacity = tester.widget<Opacity>(
      find.descendant(
        of: find.byType(OnboardingBottomBar),
        matching: find.byType(Opacity),
      ),
    );
    expect(opacity.opacity, 0);

    // Tapping through the ignored region must not invoke the callback.
    await tester.tap(
      find.descendant(
        of: find.byType(OnboardingBottomBar),
        matching: find.byType(IgnorePointer),
      ),
      warnIfMissed: false,
    );
    expect(backTapped, isFalse);
  });

  testWidgets('back button is tappable and enabled after the first page', (
    tester,
  ) async {
    var backTapped = false;

    await pump(
      tester,
      currentPage: 1,
      total: 3,
      onBack: () => backTapped = true,
      onNext: () {},
    );

    final ignorePointer = tester.widget<IgnorePointer>(
      find.descendant(
        of: find.byType(OnboardingBottomBar),
        matching: find.byType(IgnorePointer),
      ),
    );
    expect(ignorePointer.ignoring, isFalse);

    final opacity = tester.widget<Opacity>(
      find.descendant(
        of: find.byType(OnboardingBottomBar),
        matching: find.byType(Opacity),
      ),
    );
    expect(opacity.opacity, 1);

    await tester.tap(find.text('back'));
    expect(backTapped, isTrue);
  });

  testWidgets('tapping next invokes onNext', (tester) async {
    var nextTapped = false;

    await pump(
      tester,
      currentPage: 0,
      total: 3,
      onBack: () {},
      onNext: () => nextTapped = true,
    );

    await tester.tap(find.text('Next'));
    expect(nextTapped, isTrue);
  });
}
