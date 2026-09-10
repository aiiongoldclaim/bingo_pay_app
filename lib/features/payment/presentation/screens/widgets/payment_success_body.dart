import 'package:flutter/material.dart';

import 'payment_success_matrics.dart';

// ── Portrait ───────────────────────────────────────────────────────────────
class PaymentSuccessPortraitBody extends StatelessWidget {
  final PaymentSuccessMetrics metrics;
  final Widget header;
  final Widget card;

  const PaymentSuccessPortraitBody({
    super.key,
    required this.metrics,
    required this.header,
    required this.card,
  });

  @override
  Widget build(BuildContext context) {
    final m = metrics;

    return SingleChildScrollView(
      padding: EdgeInsets.fromLTRB(m.pageHPad, m.pageVPad, m.pageHPad, m.gapLg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          header,
          SizedBox(height: m.gapLg),
          card,
        ],
      ),
    );
  }
}

// ── Landscape: hero left, invoice rail right ───────────────────────────────
class PaymentSuccessLandscapeBody extends StatelessWidget {
  final PaymentSuccessMetrics metrics;
  final Widget header;
  final Widget card;

  const PaymentSuccessLandscapeBody({
    super.key,
    required this.metrics,
    required this.header,
    required this.card,
  });

  @override
  Widget build(BuildContext context) {
    final m = metrics;

    return Padding(
      padding: EdgeInsets.fromLTRB(m.pageHPad, m.pageVPad, m.pageHPad, 0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            flex: 5,
            child: SingleChildScrollView(
              padding: EdgeInsets.only(bottom: m.gapLg),
              child: header,
            ),
          ),
          SizedBox(width: m.gapLg),
          Expanded(
            flex: 5,
            child: SingleChildScrollView(
              padding: EdgeInsets.only(bottom: m.gapLg),
              child: card,
            ),
          ),
        ],
      ),
    );
  }
}
