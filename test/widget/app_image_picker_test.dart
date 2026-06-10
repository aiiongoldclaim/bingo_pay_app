import 'package:bingo_pay/core/widgets/app_image_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

Widget buildSubject({String? imagePath, required VoidCallback onTap}) =>
    MaterialApp(
      home: Scaffold(
        body: AppImagePicker(
          label: 'Test Label',
          onTap: onTap,
          imagePath: imagePath,
        ),
      ),
    );

void main() {
  group('AppImagePicker', () {
    testWidgets('shows label', (tester) async {
      await tester.pumpWidget(buildSubject(onTap: () {}));
      expect(find.text('Test Label'), findsOneWidget);
    });

    testWidgets('shows placeholder when no image', (tester) async {
      await tester.pumpWidget(buildSubject(onTap: () {}));
      expect(find.text('Tap to upload'), findsOneWidget);
    });

    testWidgets('calls onTap when tapped', (tester) async {
      var tapped = false;
      await tester.pumpWidget(buildSubject(onTap: () => tapped = true));
      await tester.tap(find.byType(GestureDetector));
      expect(tapped, isTrue);
    });
  });
}
