import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import 'package:bingo_pay/core/di/injection.dart';
import 'package:bingo_pay/core/router/app_routes.dart';
import 'package:bingo_pay/core/theme/app_theme_colors.dart';
import 'package:bingo_pay/core/theme/theme_colors.dart';

import '../../data/models/membership_plan_model.dart';
import '../../data/models/membership_subscribe_model.dart';

import '../cubit/membership_cubit.dart';
import '../cubit/membership_state.dart';

import '../widgets/checkout_widgets.dart';
import '../widgets/feature_strip.dart';
import '../widgets/membership_checkout_args.dart';
import '../widgets/membership_metrices.dart';

class MembershipCheckoutScreen extends StatelessWidget {
  const MembershipCheckoutScreen({
    super.key,
    required this.args,
  });

  final MembershipCheckoutArgs args;

  @override
  Widget build(BuildContext context) {
    return BlocProvider<MembershipCubit>(
      create: (_) => getIt<MembershipCubit>(),
      child: _CheckoutView(
        args: args,
      ),
    );
  }
}

class _CheckoutView extends StatefulWidget {
  const _CheckoutView({
    required this.args,
  });

  final MembershipCheckoutArgs args;

  @override
  State<_CheckoutView> createState() =>
      _CheckoutViewState();
}

class _CheckoutViewState
    extends State<_CheckoutView> {
  Timer? _ticker;

  StreamSubscription<MembershipEvent>?
  _eventSubscription;

  late Duration _timeLeft;

  bool _paying = false;

  bool _cancelling = false;

  MembershipPlanOption get plan =>
      widget.args.plan;

  CheckoutPayment get payment =>
      widget.args.quote.payment;

  String get subscriptionUuid =>
      widget.args.quote.subscription.uuid;

  @override
  void initState() {
    super.initState();

    _timeLeft = payment.timeLeft;

    _startTimer();

    _listenToEvents();
  }

  void _startTimer() {
    _ticker = Timer.periodic(
      const Duration(seconds: 1),
          (_) {
        if (!mounted) return;

        final newTimeLeft =
            payment.timeLeft;

        setState(() {
          _timeLeft = newTimeLeft;
        });
      },
    );
  }

  bool get _expired =>
      _timeLeft.inSeconds <= 0;

  String get _timerLabel {
    if (_expired) {
      return '00:00';
    }

    final minutes =
    _timeLeft.inMinutes
        .toString()
        .padLeft(2, '0');

    final seconds =
    (_timeLeft.inSeconds % 60)
        .toString()
        .padLeft(2, '0');

    return '$minutes:$seconds';
  }

  void _listenToEvents() {
    final cubit =
    context.read<MembershipCubit>();

    _eventSubscription =
        cubit.events.listen(
          _handleEvent,
        );
  }

  void _handleEvent(
      MembershipEvent event,
      ) {
    if (!mounted) return;

    switch (event) {
      case MembershipPaymentConfirmed(
          :final result,
      ):
        _handlePaymentSuccess(result);

      case MembershipMessage(
          :final text,
          :final isError,
      ):
        _showMessage(
          text,
          isError: isError,
        );

      case MembershipQuoteCreated():
        break;

      case MembershipCancelled():
        break;

      case MembershipResumed():
        break;
    }
  }

  // ===========================================================================
  // PAYMENT SUCCESS
  // ===========================================================================

  void _handlePaymentSuccess(
      dynamic result,
      ) {
    if (!mounted) return;

    final status =
    result.subscriptionStatus
        .toUpperCase();

    if (status == 'ACTIVE') {
      context.go(
        AppRoutes.membershipActivated,
        extra: widget.args,
      );

      return;
    }

    _showMessage(
      status.isEmpty
          ? 'Payment is being processed'
          : 'Payment status: $status',
      isError: false,
    );
  }


  void _showMessage(
      String message, {
        required bool isError,
      }) {
    if (!mounted) return;

    final c = context.c;

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor:
          isError
              ? c.statusWarning
              : c.statusSuccess,
          behavior:
          SnackBarBehavior.floating,
        ),
      );
  }

  Future<void> _payNow() async {
    if (_paying || _cancelling) {
      return;
    }

    if (_expired) {
      await _cancelNow();
      return;
    }

    final token =
    payment.token.trim();

    if (token.isEmpty) {
      _showMessage(
        'Payment token is missing',
        isError: true,
      );
      return;
    }

    final amount =
        payment.amount;

    if (amount == null ||
        amount <= 0) {
      _showMessage(
        'Invalid payment amount',
        isError: true,
      );
      return;
    }

    setState(() {
      _paying = true;
    });

    try {
      print(
        '========== PAY NOW CLICKED ==========',
      );

      print(
        'Payment UUID: '
            '${payment.paymentUuid}',
      );

      print(
        'Required BIGOD: $amount',
      );

      final cubit =
      context.read<MembershipCubit>();

      await cubit.payNow(
        token: token,
        requiredAmount:
        amount.toDouble(),
      );
    } catch (e) {
      if (!mounted) return;

      _showMessage(
        e.toString(),
        isError: true,
      );
    } finally {
      if (!mounted) return;

      setState(() {
        _paying = false;
      });
    }
  }

  Future<void> _cancelNow() async {
    if (_cancelling || _paying) {
      return;
    }

    if (subscriptionUuid.isEmpty) {
      _showMessage(
        'Subscription ID is missing',
        isError: true,
      );
      return;
    }

    setState(() {
      _cancelling = true;
    });

    try {
      print(
        '========== CANCEL NOW CLICKED ==========',
      );

      print(
        'Subscription UUID: '
            '$subscriptionUuid',
      );

      final cubit =
      context.read<MembershipCubit>();

      final success =
      await cubit.cancelPending(
        subscriptionUuid,
      );

      if (!mounted) return;

      if (success) {
        _showMessage(
          'Payment cancelled successfully',
          isError: false,
        );

        // Give snackbar a moment to show.
        await Future.delayed(
          const Duration(
            milliseconds: 500,
          ),
        );

        if (!mounted) return;

        // Go back to membership screen.
        context.go(
          AppRoutes.membership,
        );
      }
    } catch (e) {
      if (!mounted) return;

      _showMessage(
        e.toString(),
        isError: true,
      );
    } finally {
      if (!mounted) return;

      setState(() {
        _cancelling = false;
      });
    }
  }

  // ===========================================================================
  // DISPOSE
  // ===========================================================================

  @override
  void dispose() {
    _ticker?.cancel();
    _eventSubscription?.cancel();

    super.dispose();
  }

  // ===========================================================================
  // BUILD
  // ===========================================================================

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, _) {
        final metrics =
        MembershipMetrics.of(context);

        return Scaffold(
          backgroundColor:
          context.c.background,

          appBar:
          _buildAppBar(
            context,
            metrics,
          ),

          body: SafeArea(
            top: false,
            child: Column(
              children: [
                Expanded(
                  child:
                  SingleChildScrollView(
                    padding:
                    EdgeInsets.fromLTRB(
                      metrics.hPad,
                      metrics.vPad,
                      metrics.hPad,
                      metrics.sectionGap *
                          0.6,
                    ),
                    child: Center(
                      child:
                      ConstrainedBox(
                        constraints:
                        BoxConstraints(
                          maxWidth: metrics
                              .maxContentWidth,
                        ),
                        child:
                        _buildContent(
                          context,
                          metrics,
                        ),
                      ),
                    ),
                  ),
                ),

                _buildBottomBar(
                  context,
                  metrics,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // ===========================================================================
  // APP BAR
  // ===========================================================================

  PreferredSizeWidget _buildAppBar(
      BuildContext context,
      MembershipMetrics metrics,
      ) {
    final c = context.c;

    return AppBar(
      backgroundColor:
      c.background,

      leading: IconButton(
        onPressed: () {
          if (context.canPop()) {
            context.pop();
          }
        },
        icon: Icon(
          Icons
              .arrow_back_ios_new_rounded,
          size: metrics.smallIcon,
          color: c.textPrimary,
        ),
      ),

      title: Text(
        'Membership Checkout',
        style: TextStyle(
          fontSize:
          metrics.screenTitleSize,
          fontWeight:
          FontWeight.w700,
          color: c.textPrimary,
        ),
      ),

      actions: [
        Padding(
          padding: EdgeInsets.only(
            right: metrics.hPad * 0.6,
          ),
          child: Row(
            children: [
              Icon(
                Icons
                    .verified_user_outlined,
                size:
                metrics.smallIcon,
                color: c.brand,
              ),
              SizedBox(
                width:
                metrics.cardPad *
                    0.25,
              ),
              Text(
                'Secure',
                style: TextStyle(
                  fontSize:
                  metrics.captionSize,
                  fontWeight:
                  FontWeight.w500,
                  color:
                  c.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ===========================================================================
  // CONTENT
  // ===========================================================================

  Widget _buildContent(
      BuildContext context,
      MembershipMetrics metrics,
      ) {
    final summary =
    CheckoutSummaryCard(
      plan: plan,
      metrics: metrics,
    );

    final paymentSection =
    _buildPaymentSection(
      context,
      metrics,
    );

    return Column(
      crossAxisAlignment:
      CrossAxisAlignment.stretch,
      children: [
        CheckoutStepper(
          metrics: metrics,
          currentStep: 2,
        ),

        SizedBox(
          height:
          metrics.sectionGap *
              0.8,
        ),

        CheckoutHeroCard(
          plan: plan,
          metrics: metrics,
          renewsOn:
          _renewsOn(plan),
        ),

        SizedBox(
          height:
          metrics.sectionGap *
              0.8,
        ),

        if (metrics.isTabletLandscape)
          IntrinsicHeight(
            child: Row(
              crossAxisAlignment:
              CrossAxisAlignment.start,
              children: [
                Expanded(
                  flex: 6,
                  child: summary,
                ),
                SizedBox(
                  width:
                  metrics.sectionGap,
                ),
                Expanded(
                  flex: 5,
                  child:
                  paymentSection,
                ),
              ],
            ),
          )
        else ...[
          summary,

          SizedBox(
            height:
            metrics.sectionGap *
                0.8,
          ),

          paymentSection,
        ],

        if (plan.features.isNotEmpty) ...[
          SizedBox(
            height:
            metrics.sectionGap *
                0.8,
          ),

          Text(
            "You'll Get With ${plan.name}",
            style: TextStyle(
              fontSize:
              metrics.sectionTitleSize,
              fontWeight:
              FontWeight.w700,
              color:
              context.c.textPrimary,
            ),
          ),

          SizedBox(
            height:
            metrics.rowGap,
          ),

          MembershipFeatureStrip(
            features: plan
                .includedFeatures
                .take(4)
                .toList(),
            metrics: metrics,
            filled: true,
          ),
        ],
      ],
    );
  }

  // ===========================================================================
  // PAYMENT SECTION
  // ===========================================================================

  Widget _buildPaymentSection(
      BuildContext context,
      MembershipMetrics metrics,
      ) {
    final c = context.c;

    return Column(
      crossAxisAlignment:
      CrossAxisAlignment.stretch,
      children: [
        Text(
          'Payment Method',
          style: TextStyle(
            fontSize:
            metrics.sectionTitleSize,
            fontWeight:
            FontWeight.w700,
            color:
            c.textPrimary,
          ),
        ),

        SizedBox(
          height:
          metrics.rowGap,
        ),

        BigodPaymentCard(
          metrics: metrics,
          payment: payment,
          timerLabel:
          _timerLabel,
          expired:
          _expired,
        ),
      ],
    );
  }

  // ===========================================================================
  // RENEW DATE
  // ===========================================================================

  String? _renewsOn(
      MembershipPlanOption plan,
      ) {
    final days =
        plan.version?.durationDays ??
            0;

    if (days <= 0) {
      return null;
    }

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

    final date =
    DateTime.now().add(
      Duration(
        days: days,
      ),
    );

    return '${months[date.month - 1]} '
        '${date.day}, '
        '${date.year}';
  }

  // ===========================================================================
  // BOTTOM BAR
  // ===========================================================================

  Widget _buildBottomBar(
      BuildContext context,
      MembershipMetrics metrics,
      ) {
    final c = context.c;

    return Container(
      padding: EdgeInsets.fromLTRB(
        metrics.hPad,
        metrics.rowGap * 0.7,
        metrics.hPad,
        metrics.rowGap,
      ),
      decoration: BoxDecoration(
        color: c.background,
        border: Border(
          top: BorderSide(
            color: c.border,
          ),
        ),
      ),
      child: Center(
        child: ConstrainedBox(
          constraints:
          BoxConstraints(
            maxWidth:
            metrics.maxContentWidth,
          ),
          child: Row(
            children: [
              // -------------------------------------------------------------
              // TOTAL AMOUNT
              // -------------------------------------------------------------

              Column(
                crossAxisAlignment:
                CrossAxisAlignment.start,
                mainAxisSize:
                MainAxisSize.min,
                children: [
                  Text(
                    'Total Amount',
                    style: TextStyle(
                      fontSize:
                      metrics.labelSize,
                      fontWeight:
                      FontWeight.w500,
                      color:
                      c.textSecondary,
                    ),
                  ),

                  SizedBox(
                    width:
                    metrics.iconCircle *
                        2.6,
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      alignment:
                      Alignment.centerLeft,
                      child: Text(
                        plan.version
                            ?.priceLabel ??
                            '--',
                        style: TextStyle(
                          fontSize:
                          metrics.priceSize *
                              0.85,
                          fontWeight:
                          FontWeight.w700,
                          color:
                          c.textPrimary,
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              SizedBox(
                width:
                metrics.cardPad * 0.7,
              ),

              // -------------------------------------------------------------
              // BUTTON
              // -------------------------------------------------------------

              Expanded(
                child: SizedBox(
                  height:
                  metrics.buttonHeight,
                  child:
                  ElevatedButton(
                    // IMPORTANT:
                    //
                    // Timer active:
                    //     Pay Now
                    //
                    // Timer expired:
                    //     Cancel Now
                    //
                    // Only loading states disable button.
                    onPressed:
                    _paying ||
                        _cancelling
                        ? null
                        : (_expired
                        ? _cancelNow
                        : _payNow),

                    style:
                    ElevatedButton
                        .styleFrom(
                      backgroundColor:
                      c.brand,
                      foregroundColor:
                      ThemeColors.white,

                      disabledBackgroundColor:
                      c.brand.withValues(
                        alpha: 0.5,
                      ),

                      disabledForegroundColor:
                      ThemeColors.white,

                      elevation: 0,

                      minimumSize:
                      Size.zero,

                      padding:
                      EdgeInsets
                          .symmetric(
                        horizontal:
                        metrics
                            .cardPad *
                            0.5,
                      ),

                      shape:
                      RoundedRectangleBorder(
                        borderRadius:
                        BorderRadius
                            .circular(
                          metrics.radiusMd,
                        ),
                      ),
                    ),

                    child:
                    _paying
                        ? _loadingButton(
                      metrics,
                      'Processing...',
                    )
                        : _cancelling
                        ? _loadingButton(
                      metrics,
                      'Cancelling...',
                    )
                        : _normalButton(
                      metrics,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ===========================================================================
  // LOADING BUTTON
  // ===========================================================================

  Widget _loadingButton(
      MembershipMetrics metrics,
      String text,
      ) {
    return Row(
      mainAxisAlignment:
      MainAxisAlignment.center,
      children: [
        SizedBox(
          width:
          metrics.smallIcon,
          height:
          metrics.smallIcon,
          child:
          const CircularProgressIndicator(
            strokeWidth: 2,
            valueColor:
            AlwaysStoppedAnimation<Color>(
              ThemeColors.white,
            ),
          ),
        ),

        SizedBox(
          width:
          metrics.cardPad * 0.4,
        ),

        Text(
          text,
          style: TextStyle(
            fontSize:
            metrics.bodySize,
            fontWeight:
            FontWeight.w700,
          ),
        ),
      ],
    );
  }

  // ===========================================================================
  // NORMAL BUTTON
  // ===========================================================================

  Widget _normalButton(
      MembershipMetrics metrics,
      ) {
    final isCancel =
        _expired;

    return Row(
      mainAxisAlignment:
      MainAxisAlignment.center,
      children: [
        Icon(
          isCancel
              ? Icons.cancel_outlined
              : Icons.lock_outline_rounded,
          size:
          metrics.smallIcon,
        ),

        SizedBox(
          width:
          metrics.cardPad * 0.4,
        ),

        Flexible(
          child: Text(
            isCancel
                ? 'Cancel Now'
                : 'Pay ${plan.version?.priceLabel ?? ''} Now',
            maxLines: 1,
            overflow:
            TextOverflow.ellipsis,
            style: TextStyle(
              fontSize:
              metrics.bodySize,
              fontWeight:
              FontWeight.w700,
            ),
          ),
        ),
      ],
    );
  }
}