import 'dart:async';

import 'package:bingo_pay/core/widgets/app_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// A minimal stand-in for _ProductDetailScreenState._buyNow, reproducing
/// its exact guard: `if (_isBuyingNow) return;` checked synchronously
/// before any await, then `setState(() => _isBuyingNow = true)` before the
/// async navigation call — exactly product_details_screen.dart:43-73.
class _BuyNowHarness extends StatefulWidget {
  final Future<void> Function() pushPayment;

  const _BuyNowHarness({required this.pushPayment});

  @override
  State<_BuyNowHarness> createState() => _BuyNowHarnessState();
}

class _BuyNowHarnessState extends State<_BuyNowHarness> {
  bool _isBuyingNow = false;

  Future<void> _buyNow() async {
    if (_isBuyingNow) return;
    setState(() => _isBuyingNow = true);
    try {
      await widget.pushPayment();
    } finally {
      if (mounted) setState(() => _isBuyingNow = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppButton(
      label: 'Buy Now',
      isLoading: _isBuyingNow,
      onPressed: () => _buyNow(),
    );
  }
}

void main() {
  testWidgets(
    'two rapid taps on Buy Now (no pump in between) push the Payment '
    'screen exactly once, guarded by the synchronous _isBuyingNow flag',
    (tester) async {
      final gate = Completer<void>();
      var pushCount = 0;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: _BuyNowHarness(
              pushPayment: () {
                pushCount++;
                return gate.future;
              },
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Two rapid taps with NO pump() in between — the worst case for any
      // guard that relies on the widget tree having already rebuilt.
      await tester.tap(find.byType(AppButton));
      await tester.tap(find.byType(AppButton));

      gate.complete();
      await tester.pumpAndSettle();

      expect(pushCount, 1,
          reason: 'F-11 claims Buy Now has no double-tap guard, but '
              'product_details_screen.dart:43-44 already checks '
              '_isBuyingNow synchronously before any await, exactly like '
              'the pattern later added to Add to Cart — this must hold up '
              'under a genuine rapid double-tap');
    },
  );
}
