import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:bingo_pay/core/di/injection.dart';
import 'package:bingo_pay/core/theme/app_theme_colors.dart';
import 'package:bingo_pay/core/theme/theme_colors.dart';

import '../../../../core/router/app_routes.dart';
import '../../data/models/membership_plan_model.dart';
import '../../data/models/membership_subscribe_model.dart';
import '../cubit/member_ship_cubit.dart';
import '../cubit/member_ship_state.dart';
import '../widgets/checkout_widgets.dart';
import '../widgets/feature_strip.dart';
import '../widgets/membership_checkout_args.dart';
import '../widgets/membership_metrices.dart';


class MembershipCheckoutScreen extends StatelessWidget {
  const MembershipCheckoutScreen({super.key, required this.args});

  final MembershipCheckoutArgs args;

  @override
  Widget build(BuildContext context) => _CheckoutView(args: args);
}

class _CheckoutView extends StatefulWidget {
  const _CheckoutView({required this.args});

  final MembershipCheckoutArgs args;

  @override
  State<_CheckoutView> createState() => _CheckoutViewState();
}

class _CheckoutViewState extends State<_CheckoutView> {
  Timer? _ticker;
  late Duration _timeLeft;

  MembershipPlanOption get plan => widget.args.plan;
  CheckoutPayment get payment => widget.args.quote.payment;

  @override
  void initState() {
    super.initState();
    _timeLeft = payment.timeLeft;
    _ticker = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) return;
      setState(() => _timeLeft = payment.timeLeft);
    });
  }

  @override
  void dispose() {
    _ticker?.cancel();
    super.dispose();
  }

  bool get _expired => _timeLeft == Duration.zero;

  String get _timerLabel {
    final mm = _timeLeft.inMinutes.toString().padLeft(2, '0');
    final ss = (_timeLeft.inSeconds % 60).toString().padLeft(2, '0');
    return '$mm:$ss';
  }

  @override
  Widget build(BuildContext context) {
    final c = context.c;


    return LayoutBuilder(
      builder: (context, _) {
        final m = MembershipMetrics.of(context);

        return Scaffold(
          backgroundColor: c.background,
          appBar: AppBar(
            backgroundColor: c.background,
            leading: IconButton(
              onPressed: () {
                if (context.canPop()) context.pop();
              },
              icon: Icon(
                Icons.arrow_back_ios_new_rounded,
                size: m.smallIcon,
                color: c.textPrimary,
              ),
            ),
            title: Text(
              'Membership Checkout',
              style: TextStyle(
                fontSize: m.screenTitleSize,
                fontWeight: FontWeight.w700,
                color: c.textPrimary,
              ),
            ),
            actions: [
              Padding(
                padding: EdgeInsets.only(right: m.hPad * 0.6),
                child: Row(
                  children: [
                    Icon(
                      Icons.verified_user_outlined,
                      size: m.smallIcon,
                      color: c.brand,
                    ),
                    SizedBox(width: m.cardPad * 0.25),
                    Text(
                      'Secure',
                      style: TextStyle(
                        fontSize: m.captionSize,
                        fontWeight: FontWeight.w500,
                        color: c.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          body: SafeArea(
            top: false,
            child: Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    padding: EdgeInsets.fromLTRB(
                      m.hPad, m.vPad, m.hPad, m.sectionGap * 0.6,
                    ),
                    child: Center(
                      child: ConstrainedBox(
                        constraints:
                        BoxConstraints(maxWidth: m.maxContentWidth),
                        child: _content(context, m),
                      ),
                    ),
                  ),
                ),
                _bottomBar(context, m),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _content(BuildContext context, MembershipMetrics m) {
    final summary = CheckoutSummaryCard(plan: plan, metrics: m);
    final paymentSection = _paymentSection(context, m);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        CheckoutStepper(metrics: m, currentStep: 2),
        SizedBox(height: m.sectionGap * 0.8),

        CheckoutHeroCard(
          plan: plan,
          metrics: m,
          renewsOn: _renewsOn(plan),
        ),
        SizedBox(height: m.sectionGap * 0.8),

        if (m.isTabletLandscape)
          IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(flex: 6, child: summary),
                SizedBox(width: m.sectionGap),
                Expanded(flex: 5, child: paymentSection),
              ],
            ),
          )
        else ...[
          summary,
          SizedBox(height: m.sectionGap * 0.8),
          paymentSection,
        ],

        if (plan.features.isNotEmpty) ...[
          SizedBox(height: m.sectionGap * 0.8),
          Text(
            'You\u2019ll Get With ${plan.name}',
            style: TextStyle(
              fontSize: m.sectionTitleSize,
              fontWeight: FontWeight.w700,
              color: context.c.textPrimary,
            ),
          ),
          SizedBox(height: m.rowGap),
          MembershipFeatureStrip(
            features: plan.includedFeatures.take(4).toList(),
            metrics: m,
            filled: true,
          ),
        ],
      ],
    );
  }

  Widget _paymentSection(BuildContext context, MembershipMetrics m) {
    final c = context.c;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'Payment Method',
          style: TextStyle(
            fontSize: m.sectionTitleSize,
            fontWeight: FontWeight.w700,
            color: c.textPrimary,
          ),
        ),
        SizedBox(height: m.rowGap),
        BigodPaymentCard(
          metrics: m,
          payment: payment,
          timerLabel: _timerLabel,
          expired: _expired,
        ),
      ],
    );
  }


  String? _renewsOn(MembershipPlanOption plan) {
    final days = plan.version?.durationDays ?? 0;
    if (days <= 0) return null;

    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    final d = DateTime.now().add(Duration(days: days));
    return '${months[d.month - 1]} ${d.day}, ${d.year}';
  }

  Widget _bottomBar(BuildContext context, MembershipMetrics m) {
    final c = context.c;

    return Container(
      padding: EdgeInsets.fromLTRB(m.hPad, m.rowGap * 0.7, m.hPad, m.rowGap),
      decoration: BoxDecoration(
        color: c.background,
        border: Border(top: BorderSide(color: c.border)),
      ),
      child: Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: m.maxContentWidth),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Total Amount',
                        style: TextStyle(
                          fontSize: m.labelSize,
                          fontWeight: FontWeight.w500,
                          color: c.textSecondary,
                        ),
                      ),
                      SizedBox(
                        width: m.iconCircle * 2.6,
                        child: FittedBox(
                          fit: BoxFit.scaleDown,
                          alignment: Alignment.centerLeft,
                          child: Text(
                            plan.version?.priceLabel ?? '--',   // ← $29
                            style: TextStyle(
                              fontSize: m.priceSize * 0.85,
                              fontWeight: FontWeight.w700,
                              color: c.textPrimary,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(width: m.cardPad * 0.7),
                  Expanded(
                    child: SizedBox(
                      height: m.buttonHeight,
                      child: ElevatedButton(
                        onPressed: _expired
                            ? null
                            : () => context.push(
                          AppRoutes.membershipSuccess,
                          extra: widget.args,
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: c.brand,
                          foregroundColor: ThemeColors.white,
                          disabledBackgroundColor:
                          c.brand.withValues(alpha: 0.5),
                          elevation: 0,
                          padding:
                          EdgeInsets.symmetric(horizontal: m.cardPad * 0.5),
                          minimumSize: Size.zero,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(m.radiusMd),
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.lock_outline_rounded, size: m.smallIcon),
                            SizedBox(width: m.cardPad * 0.4),
                            Flexible(
                              child: Text(
                                _expired
                                    ? 'Price expired'
                                    : 'Pay ${plan.version?.priceLabel ?? ''} Now',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontSize: m.bodySize,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: m.rowGap * 0.6),

            ],
          ),
        ),
      ),
    );
  }
}



