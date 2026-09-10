import 'package:flutter/material.dart';

import '../../cubit/payment_state.dart';
import 'review_coupon_notes_card.dart';
import 'review_pay_metrics.dart';
import 'review_pay_widgets.dart';

// ── Portrait ───────────────────────────────────────────────────────────────
class ReviewPortraitBody extends StatelessWidget {
  final ReviewPayMetrics metrics;
  final PaymentMethodState state;
  final Widget? address;
  final Widget wallet;
  final Widget summary;
  final Widget secure;
  final Widget offers;

  const ReviewPortraitBody({
    super.key,
    required this.metrics,
    required this.state,
    required this.address,
    required this.wallet,
    required this.summary,
    required this.secure,
    required this.offers,
  });

  @override
  Widget build(BuildContext context) {
    final m = metrics;

    return SingleChildScrollView(
      padding: EdgeInsets.fromLTRB(m.pageHPad, m.gapSm, m.pageHPad, m.gapLg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(height: m.gapLg),

          if (address != null) ...[address!, SizedBox(height: m.gapMd)],

          wallet,
          SizedBox(height: m.gapLg),

          if (!state.isCartFlow) ...[
            ReviewCouponNotesCard(metrics: m),
            SizedBox(height: m.gapMd),
          ],

          ReviewSectionLabel(metrics: m, label: 'Order Summary'),
          SizedBox(height: m.gapSm),
          summary,

          SizedBox(height: m.gapMd),
          secure,

          SizedBox(height: m.gapMd),
          offers,
        ],
      ),
    );
  }
}

// ── Landscape ──────────────────────────────────────────────────────────────
class ReviewLandscapeBody extends StatelessWidget {
  final ReviewPayMetrics metrics;
  final PaymentMethodState state;
  final Widget? address;
  final Widget wallet;
  final Widget summary;
  final Widget secure;
  final Widget offers;
  final Widget payBar;

  const ReviewLandscapeBody({
    super.key,
    required this.metrics,
    required this.state,
    required this.address,
    required this.wallet,
    required this.summary,
    required this.secure,
    required this.offers,
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
                  SizedBox(height: m.gapLg),
                  if (address != null) ...[address!, SizedBox(height: m.gapMd)],
                  wallet,
                  if (!state.isCartFlow) ...[
                    SizedBox(height: m.gapMd),
                    ReviewCouponNotesCard(metrics: m),
                  ],
                  SizedBox(height: m.gapMd),
                  offers,
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
                  ReviewSectionLabel(metrics: m, label: 'Order Summary'),
                  SizedBox(height: m.gapSm),
                  summary,
                  SizedBox(height: m.gapMd),
                  secure,
                  SizedBox(height: m.gapMd),
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
