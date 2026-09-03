import 'package:bingo_pay/features/splash/presentation/screens/splash_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  Future<void> pump(WidgetTester tester, {required Brightness brightness}) {
    return tester.pumpWidget(
      MaterialApp(
        theme: ThemeData(brightness: brightness),
        home: const SplashScreen(),
      ),
    );
  }

  testWidgets('renders the wordmark and tagline in light mode', (
    tester,
  ) async {
    await pump(tester, brightness: Brightness.light);
    await tester.pump(const Duration(milliseconds: 1500));

    expect(find.text('SECURE. GROW. PROSPER.'), findsOneWidget);
    expect(find.byType(RichText), findsWidgets);
  });

  testWidgets('renders the wordmark and tagline in dark mode', (
    tester,
  ) async {
    await pump(tester, brightness: Brightness.dark);
    await tester.pump(const Duration(milliseconds: 1500));

    expect(find.text('SECURE. GROW. PROSPER.'), findsOneWidget);
  });

  testWidgets('wordmark reads the correct brand spelling "Vaults"', (
    tester,
  ) async {
    await pump(tester, brightness: Brightness.light);
    await tester.pump(const Duration(milliseconds: 1500));

    final richTexts = tester
        .widgetList<RichText>(find.byType(RichText))
        .map((w) => w.text.toPlainText())
        .join();

    expect(richTexts, contains('Vaults'));
    expect(richTexts, isNot(contains('Valuts')));
  });

  testWidgets('animation runs to completion and disposes without error', (
    tester,
  ) async {
    await pump(tester, brightness: Brightness.light);

    await tester.pump();
    await tester.pump(const Duration(milliseconds: 750));
    await tester.pump(const Duration(milliseconds: 750));

    // Rebuilding with a different tree disposes the SplashScreen state;
    // this must not throw a disposed-controller error.
    await tester.pumpWidget(const SizedBox.shrink());
  });

  testWidgets('renders the stacked (portrait) layout on a narrow window', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(375, 812);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await pump(tester, brightness: Brightness.light);
    await tester.pump(const Duration(milliseconds: 1500));

    expect(find.byType(Column), findsWidgets);
  });

  testWidgets('renders the side-by-side (landscape/tablet) layout on a wide window', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1200, 800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await pump(tester, brightness: Brightness.light);
    await tester.pump(const Duration(milliseconds: 1500));

    expect(find.byType(Row), findsWidgets);
  });
}
