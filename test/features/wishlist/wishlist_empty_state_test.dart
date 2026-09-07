import 'package:bingo_pay/features/wishlist/presentation/screens/wishlist_screen.dart';
import 'package:bingo_pay/features/wishlist/presentation/widgets/wishlist_metrics.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sizer/sizer.dart';

void main() {
  testWidgets(
    'an empty wishlist renders a proper empty-state UI (icon, title, '
    'helpful subtitle), not a blank screen',
    (tester) async {
      await tester.pumpWidget(
        Sizer(
          builder: (context, orientation, deviceType) => MaterialApp(
            home: Scaffold(
              body: Builder(
                builder: (context) => WishlistEmptyView(
                  metrics: WishlistMetrics.of(context),
                ),
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull,
          reason: 'the empty state must render without crashing');

      expect(find.text('Your wishlist is empty'), findsOneWidget);
      expect(
        find.textContaining('Tap the heart icon'),
        findsOneWidget,
        reason: 'a helpful subtitle, not just a bare title on a blank '
            'screen',
      );
      expect(find.byIcon(Icons.favorite_border_rounded), findsOneWidget);
    },
  );
}
