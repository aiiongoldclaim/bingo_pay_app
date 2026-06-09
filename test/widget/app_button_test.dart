import 'package:bingo_pay/core/widgets/app_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  Widget buildSubject({
    VoidCallback? onPressed,
    bool isLoading = false,
  }) {
    return MaterialApp(
      home: Scaffold(
        body: AppButton(
          label: 'Test Button',
          onPressed: onPressed,
          isLoading: isLoading,
        ),
      ),
    );
  }

  group('AppButton', () {
    testWidgets('shows label when not loading', (tester) async {
      await tester.pumpWidget(buildSubject(onPressed: () {}));
      expect(find.text('Test Button'), findsOneWidget);
    });

    testWidgets('shows loading indicator when isLoading is true', (tester) async {
      await tester.pumpWidget(buildSubject(isLoading: true));
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.text('Test Button'), findsNothing);
    });

    testWidgets('calls onPressed when tapped', (tester) async {
      var tapped = false;
      await tester.pumpWidget(buildSubject(onPressed: () => tapped = true));
      await tester.tap(find.text('Test Button'));
      expect(tapped, isTrue);
    });
  });
}
