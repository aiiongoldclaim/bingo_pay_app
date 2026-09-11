import 'package:flutter/material.dart';

import 'review_payment_metrics.dart';

// ── Portrait ───────────────────────────────────────────────────────────────
class ReviewPaymentPortraitBody extends StatelessWidget {
  final ReviewPaymentMetrics metrics;
  final Widget banner;
  final Widget merchant;
  final Widget amount;
  final Widget convert;
  final Widget note;
  final Widget method;

  const ReviewPaymentPortraitBody({
    super.key,
    required this.metrics,
    required this.banner,
    required this.merchant,
    required this.amount,
    required this.convert,
    required this.note,
    required this.method,
  });

  @override
  Widget build(BuildContext context) {
    final m = metrics;

    return SingleChildScrollView(
      padding: EdgeInsets.fromLTRB(m.pageHPad, m.gapSm, m.pageHPad, m.gapLg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          banner,
          SizedBox(height: m.gapMd),
          merchant,
          SizedBox(height: m.gapLg),
          amount,
          SizedBox(height: m.gapMd),
          convert,
          SizedBox(height: m.gapLg),
          note,
          SizedBox(height: m.gapLg),
          method,
        ],
      ),
    );
  }
}

// ── Landscape ──────────────────────────────────────────────────────────────
class ReviewPaymentLandscapeBody extends StatelessWidget {
  final ReviewPaymentMetrics metrics;
  final Widget banner;
  final Widget merchant;
  final Widget amount;
  final Widget convert;
  final Widget note;
  final Widget method;
  final Widget payBar;

  const ReviewPaymentLandscapeBody({
    super.key,
    required this.metrics,
    required this.banner,
    required this.merchant,
    required this.amount,
    required this.convert,
    required this.note,
    required this.method,
    required this.payBar,
  });

  @override
  Widget build(BuildContext context) {
    final m = metrics;

    return Padding(
      padding: EdgeInsets.fromLTRB(m.pageHPad, m.gapSm, m.pageHPad, 0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.only(bottom: m.gapLg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  banner,
                  SizedBox(height: m.gapMd),
                  merchant,
                  SizedBox(height: m.gapLg),
                  amount,
                  SizedBox(height: m.gapMd),
                  convert,
                ],
              ),
            ),
          ),

          SizedBox(width: m.gapLg),

          SizedBox(
            width: m.railWidth,
            child: SingleChildScrollView(
              padding: EdgeInsets.only(bottom: m.gapLg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  note,
                  SizedBox(height: m.gapLg),
                  method,
                  SizedBox(height: m.gapLg),
                  payBar,
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
