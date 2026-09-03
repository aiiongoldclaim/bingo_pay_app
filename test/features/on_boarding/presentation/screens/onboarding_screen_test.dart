import 'package:bingo_pay/core/di/injection.dart';
import 'package:bingo_pay/features/on_boarding/data/model/on_boarding_feature.dart';
import 'package:bingo_pay/features/on_boarding/presentation/cubit/onboarding_cubit.dart';
import 'package:bingo_pay/features/on_boarding/presentation/screens/onboarding_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final totalPages = OnBoardingContent.contents.length;

  setUp(() {
    // OnboardingScreen resolves its cubit via getIt; the cubit itself has no
    // external dependencies, so a plain factory registration is enough.
    getIt.registerFactory<OnboardingCubit>(OnboardingCubit.new);
  });

  tearDown(() {
    getIt.reset();
  });

  Future<void> pump(WidgetTester tester, {required VoidCallback onFinish}) {
    return tester.pumpWidget(
      MaterialApp(home: OnboardingScreen(onFinish: onFinish)),
    );
  }

  testWidgets('renders the first page title and subtitle on initial load', (
    tester,
  ) async {
    await pump(tester, onFinish: () {});
    await tester.pumpAndSettle();

    final first = OnBoardingContent.contents[0];
    expect(find.text(first.title), findsOneWidget);
    expect(find.text(first.titleHighlight), findsOneWidget);
    expect(find.text(first.subTitle), findsOneWidget);
    expect(find.text('Next'), findsOneWidget);
  });

  testWidgets('tapping Next advances to the next page', (tester) async {
    await pump(tester, onFinish: () {});
    await tester.pumpAndSettle();

    await tester.tap(find.text('Next'));
    await tester.pumpAndSettle();

    final second = OnBoardingContent.contents[1];
    expect(find.text(second.title), findsOneWidget);
  });

  testWidgets('the button reads "Get Started" once the last page is reached', (
    tester,
  ) async {
    await pump(tester, onFinish: () {});
    await tester.pumpAndSettle();

    for (var i = 0; i < totalPages - 1; i++) {
      await tester.tap(find.text('Next'));
      await tester.pumpAndSettle();
    }

    expect(find.text('Get Started'), findsOneWidget);
    expect(find.text('Next'), findsNothing);
  });

  testWidgets('tapping "Get Started" on the last page calls onFinish once', (
    tester,
  ) async {
    var finishCalls = 0;

    await pump(tester, onFinish: () => finishCalls++);
    await tester.pumpAndSettle();

    for (var i = 0; i < totalPages - 1; i++) {
      await tester.tap(find.text('Next'));
      await tester.pumpAndSettle();
    }

    await tester.tap(find.text('Get Started'));
    await tester.pumpAndSettle();

    expect(finishCalls, 1);
  });

  testWidgets('tapping "skip" calls onFinish immediately from the first page', (
    tester,
  ) async {
    var finishCalls = 0;

    await pump(tester, onFinish: () => finishCalls++);
    await tester.pumpAndSettle();

    await tester.tap(find.text('skip'));
    await tester.pumpAndSettle();

    expect(finishCalls, 1);
  });

  testWidgets('swiping the PageView directly advances the page indicator', (
    tester,
  ) async {
    await pump(tester, onFinish: () {});
    await tester.pumpAndSettle();

    await tester.fling(find.byType(PageView), const Offset(-400, 0), 1000);
    await tester.pumpAndSettle();

    final second = OnBoardingContent.contents[1];
    expect(find.text(second.title), findsOneWidget);
  });
}
