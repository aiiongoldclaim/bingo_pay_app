import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:bingo_pay/core/theme/app_theme_colors.dart';
import 'package:bingo_pay/core/theme/theme_colors.dart';
import '../../data/models/membership_plan_model.dart';
import '../../data/models/membership_subscribe_model.dart';
import 'landing_widgets.dart';
import 'membership_metrices.dart';


class CheckoutStepper extends StatelessWidget {
  const CheckoutStepper({
    super.key,
    required this.metrics,
    this.currentStep = 2,
  });

  final MembershipMetrics metrics;

  /// 1-based
  final int currentStep;

  static const List<String> _labels = [
    'Choose Plan',
    'Review & Pay',
    'Confirmation',
  ];

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    final m = metrics;
    final dotSize = m.iconCircle * 0.56;

    Widget dot(int step) {
      final done = step < currentStep;
      final active = step == currentStep;
      final filled = done || active;

      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: dotSize,
            height: dotSize,
            decoration: BoxDecoration(
              color: filled ? c.brand : c.surfaceAlt,
              shape: BoxShape.circle,
              border: filled ? null : Border.all(color: c.border),
            ),
            child: Center(
              child: done
                  ? Icon(
                Icons.check_rounded,
                size: m.smallIcon,
                color: ThemeColors.white,
              )
                  : Text(
                '$step',
                style: TextStyle(
                  fontSize: m.labelSize,
                  fontWeight: FontWeight.w700,
                  color: active ? ThemeColors.white : c.textSecondary,
                ),
              ),
            ),
          ),
          SizedBox(height: m.rowGap * 0.35),
          Text(
            _labels[step - 1],
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: m.captionSize,
              fontWeight: active ? FontWeight.w700 : FontWeight.w400,
              color: active ? c.textPrimary : c.textSecondary,
            ),
          ),
        ],
      );
    }

    Widget line(bool filled) => Expanded(
      child: Container(
        height: 1.5,
        margin: EdgeInsets.only(
          bottom: m.rowGap * 1.5,
          left: m.cardPad * 0.2,
          right: m.cardPad * 0.2,
        ),
        color: filled ? c.brand : c.border,
      ),
    );

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        dot(1),
        line(currentStep > 1),
        dot(2),
        line(currentStep > 2),
        dot(3),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// HERO — plan ka purple banner (text dynamic, isliye gradient)
// ---------------------------------------------------------------------------

class CheckoutHeroCard extends StatelessWidget {
  const CheckoutHeroCard({
    super.key,
    required this.plan,
    required this.metrics,
    this.renewsOn,
    this.artworkAsset,
  });

  final MembershipPlanOption plan;
  final MembershipMetrics metrics;
  final String? renewsOn;
  final String? artworkAsset;

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    final m = metrics;
    final version = plan.version;

    const onHero = ThemeColors.white;
    final onHeroMuted = onHero.withValues(alpha: 0.82);

    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        gradient: c.isDark
            ? ThemeColors.heroBannerDark
            : ThemeColors.primaryGradient1,
        borderRadius: BorderRadius.circular(m.radiusLg),
        border: c.isDark ? Border.all(color: c.border) : null,
      ),
      child: Stack(
        children: [
          if (artworkAsset != null)
            Positioned(
              right: 0,
              top: 0,
              bottom: 0,
              width: m.heroHeight * 0.9,
              child: Image.asset(
                artworkAsset!,
                fit: BoxFit.contain,
                alignment: Alignment.centerRight,
                errorBuilder: (_, __, ___) => const SizedBox.shrink(),
              ),
            ),

          Padding(
            padding: EdgeInsets.all(m.cardPad),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                // "Premium Plan" pill
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: m.cardPad * 0.6,
                    vertical: m.cardPad * 0.26,
                  ),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(99),
                    border: Border.all(color: ThemeColors.gold1),
                  ),
                  child: Text(
                    '${plan.name} Plan',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: m.captionSize,
                      fontWeight: FontWeight.w600,
                      color: ThemeColors.gold1,
                    ),
                  ),
                ),

                SizedBox(height: m.rowGap),

                Text(
                  '${plan.name} Membership',
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: m.heroTitleSize * 0.78,
                    fontWeight: FontWeight.w700,
                    height: 1.15,
                    color: onHero,
                  ),
                ),

                SizedBox(height: m.rowGap * 0.3),

                Text(
                  version?.durationLabel.isNotEmpty ?? false
                      ? version!.billingCycleLabel
                      : '',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: m.heroTitleSize * 0.7,
                    fontWeight: FontWeight.w700,
                    height: 1.2,
                    color: ThemeColors.gold1,
                  ),
                ),

                if (renewsOn != null) ...[
                  SizedBox(height: m.rowGap),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.calendar_today_outlined,
                        size: m.smallIcon,
                        color: onHeroMuted,
                      ),
                      SizedBox(width: m.cardPad * 0.3),
                      Flexible(
                        child: Text(
                          'Renews on $renewsOn',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: m.heroBodySize,
                            fontWeight: FontWeight.w500,
                            color: onHeroMuted,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// ORDER SUMMARY
// ---------------------------------------------------------------------------

class CheckoutSummaryCard extends StatelessWidget {
  const CheckoutSummaryCard({
    super.key,
    required this.plan,
    required this.metrics,
  });

  final MembershipPlanOption plan;
  final MembershipMetrics metrics;

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    final m = metrics;
    final version = plan.version;
    final price = version?.priceLabel ?? '--';
    final cycle = version?.billingCycleLabel ?? '';

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(m.cardPad),
      decoration: BoxDecoration(
        color: c.surface,
        borderRadius: BorderRadius.circular(m.radiusMd),
        border: Border.all(color: c.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Order Summary',
            style: TextStyle(
              fontSize: m.sectionTitleSize,
              fontWeight: FontWeight.w700,
              color: c.textPrimary,
            ),
          ),
          SizedBox(height: m.rowGap * 0.7),
          CheckoutSummaryRow(
            label: 'Plan',
            value: cycle.isEmpty ? plan.name : '${plan.name} ($cycle)',
            metrics: m,
          ),
          CheckoutSummaryRow(label: 'Price', value: price, metrics: m),
          CheckoutSummaryRow(
            label: 'Tax (0%)',
            value: '${version?.currencySymbol ?? ''}0',
            metrics: m,
          ),
          Padding(
            padding: EdgeInsets.symmetric(vertical: m.rowGap * 0.55),
            child: Divider(height: 1, color: c.border),
          ),
          CheckoutSummaryRow(
            label: 'Total Amount',
            value: price,
            metrics: m,
            emphasize: true,
          ),
        ],
      ),
    );
  }
}

class CheckoutSummaryRow extends StatelessWidget {
  const CheckoutSummaryRow({
    super.key,
    required this.label,
    required this.value,
    required this.metrics,
    this.emphasize = false,
  });

  final String label;
  final String value;
  final MembershipMetrics metrics;
  final bool emphasize;

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    final m = metrics;

    return Padding(
      padding: EdgeInsets.symmetric(vertical: m.rowGap * 0.4),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                fontSize: emphasize ? m.sectionTitleSize : m.bodySize,
                fontWeight: emphasize ? FontWeight.w700 : FontWeight.w500,
                color: emphasize ? c.textPrimary : c.textSecondary,
              ),
            ),
          ),
          SizedBox(width: m.cardPad * 0.4),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.right,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: emphasize ? m.sectionTitleSize : m.bodySize,
                fontWeight: emphasize ? FontWeight.w700 : FontWeight.w600,
                color: emphasize ? c.brand : c.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// PAYMENT METHOD — sirf BIGOD wallet
// ---------------------------------------------------------------------------

class BigodPaymentCard extends StatelessWidget {
  const BigodPaymentCard({
    super.key,
    required this.metrics,
    this.payment,
    this.timerLabel,
    this.expired = false,
  });

  final MembershipMetrics metrics;

  final CheckoutPayment? payment;
  final String? timerLabel;
  final bool expired;

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    final m = metrics;
    final p = payment;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(m.cardPad),
      decoration: BoxDecoration(
        color: c.surface,
        borderRadius: BorderRadius.circular(m.radiusMd),
        border: Border.all(color: c.brand, width: 1.4),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              MembershipIconCircle(
                icon: Icons.account_balance_wallet_outlined,
                metrics: m,
                size: m.iconCircle * 0.66,
              ),
              SizedBox(width: m.cardPad * 0.55),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'BIGOD wallet',
                      style: TextStyle(
                        fontSize: m.bodySize,
                        fontWeight: FontWeight.w700,
                        color: c.textPrimary,
                      ),
                    ),
                    SizedBox(height: m.rowGap * 0.15),
                    Text(
                      'Pay securely from your BIGOD balance',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: m.captionSize,
                        fontWeight: FontWeight.w400,
                        color: c.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.check_circle_rounded,
                size: m.smallIcon * 1.1,
                color: c.brand,
              ),
            ],
          ),

          if (p != null) ...[
            SizedBox(height: m.rowGap * 0.9),
            Divider(height: 1, color: c.border),
            SizedBox(height: m.rowGap * 0.7),

            _row(context, 'Rate', p.rateLabel),
            _row(context, 'You pay', p.amountLabel, bold: true),

            SizedBox(height: m.rowGap * 0.7),
            Container(
              padding: EdgeInsets.all(m.cardPad * 0.55),
              decoration: BoxDecoration(
                color: expired ? c.statusWarningSoft : c.surfaceAlt,
                borderRadius: BorderRadius.circular(m.radiusSm),
              ),
              child: Row(
                children: [
                  Icon(
                    expired
                        ? Icons.timer_off_outlined
                        : Icons.timer_outlined,
                    size: m.smallIcon,
                    color: expired ? c.statusWarning : c.brand,
                  ),
                  SizedBox(width: m.cardPad * 0.4),
                  Expanded(
                    child: Text(
                      expired
                          ? 'This price has expired'
                          : 'This price is held for ${timerLabel ?? '--:--'}',
                      style: TextStyle(
                        fontSize: m.captionSize,
                        fontWeight: FontWeight.w600,
                        color: expired ? c.statusWarning : c.textPrimary,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            if (p.hasQr) ...[
              SizedBox(height: m.rowGap * 0.5),
              _QrExpansion(payment: p, metrics: m),
            ],
          ],
        ],
      ),
    );
  }

  Widget _row(
      BuildContext context,
      String label,
      String value, {
        bool bold = false,
      }) {
    final c = context.c;
    final m = metrics;

    return Padding(
      padding: EdgeInsets.symmetric(vertical: m.rowGap * 0.3),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                fontSize: m.labelSize,
                fontWeight: FontWeight.w500,
                color: c.textSecondary,
              ),
            ),
          ),
          SizedBox(width: m.cardPad * 0.4),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.right,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: bold ? m.bodySize : m.labelSize,
                fontWeight: bold ? FontWeight.w700 : FontWeight.w600,
                color: bold ? c.brand : c.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _QrExpansion extends StatelessWidget {
  const _QrExpansion({required this.payment, required this.metrics});

  final CheckoutPayment payment;
  final MembershipMetrics metrics;

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    final m = metrics;

    return Theme(
      data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
      child: Material(
        color: Colors.transparent,
        child: ExpansionTile(
          tilePadding: EdgeInsets.zero,
          childrenPadding: EdgeInsets.only(bottom: m.rowGap * 0.5),
          iconColor: c.brand,
          collapsedIconColor: c.textSecondary,
          title: Text(
            'Or scan with your wallet',
            style: TextStyle(
              fontSize: m.labelSize,
              fontWeight: FontWeight.w600,
              color: c.textPrimary,
            ),
          ),
          children: [
            Container(
              padding: EdgeInsets.all(m.cardPad * 0.6),
              decoration: BoxDecoration(
                color: ThemeColors.white,
                borderRadius: BorderRadius.circular(m.radiusSm),
              ),
              child: Image.memory(
                base64Decode(payment.qrBase64),
                width: m.iconCircle * 3,
                height: m.iconCircle * 3,
                fit: BoxFit.contain,
                gaplessPlayback: true,
                errorBuilder: (_, __, ___) => Icon(
                  Icons.qr_code_2_rounded,
                  size: m.iconCircle * 1.6,
                  color: ThemeColors.textMuted,
                ),
              ),
            ),

          ],
        ),
      ),
    );
  }
}