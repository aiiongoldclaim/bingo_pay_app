import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:bingo_pay/core/di/injection.dart';
import 'package:bingo_pay/core/router/app_routes.dart';
import 'package:bingo_pay/core/theme/app_theme_colors.dart';
import 'package:bingo_pay/core/theme/theme_colors.dart';
import '../../data/models/member_ship_model.dart';
import '../cubit/membership_cubit.dart';
import '../cubit/membership_state.dart';
import '../widgets/bottom_bar.dart';
import '../widgets/details_card.dart';
import '../widgets/hero_card.dart';
import '../widgets/membership_benefits_card.dart';
import '../widgets/membership_metrices.dart';
import '../widgets/status_view.dart';

class MembershipScreen extends StatelessWidget {
  const MembershipScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<MembershipCubit>(
      create: (_) => getIt<MembershipCubit>()..load(),
      child: const _MyMembershipView(),
    );
  }
}

class _MyMembershipView extends StatefulWidget {
  const _MyMembershipView();

  @override
  State<_MyMembershipView> createState() =>
      _MyMembershipViewState();
}

class _MyMembershipViewState
    extends State<_MyMembershipView> {
  StreamSubscription<MembershipEvent>? _sub;

  @override
  void initState() {
    super.initState();

    _sub = context
        .read<MembershipCubit>()
        .events
        .listen(_onEvent);
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }

  void _onEvent(MembershipEvent event) {
    if (!mounted) return;

    final c = context.c;

    final (String text, Color bg) = switch (event) {
      MembershipMessage(
          :final text,
          :final isError,
      ) => (
      text,
      isError
          ? c.statusWarning
          : c.statusSuccess,
      ),

      MembershipCancelled() => (
      'Membership cancelled',
      c.statusSuccess,
      ),

      MembershipResumed() => (
      'Membership resumed',
      c.statusSuccess,
      ),

      MembershipQuoteCreated() => (
      '',
      Colors.transparent,
      ),

      MembershipPaymentConfirmed() => (
      '',
      Colors.transparent,
      ),
    };

    if (text.isEmpty) return;

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(text),
          backgroundColor: bg,
          behavior: SnackBarBehavior.floating,
        ),
      );
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
                if (context.canPop()) {
                  context.pop();
                } else {
                  context.go(
                    AppRoutes.account,
                  );
                }
              },
              icon: Icon(
                Icons.arrow_back_ios_new_rounded,
                size: m.smallIcon,
                color: c.textPrimary,
              ),
            ),
            title: Text(
              'My Membership',
              style: TextStyle(
                fontSize: m.screenTitleSize*1.5,
                fontWeight: FontWeight.w700,
                color: c.textPrimary,
                fontFamily: "CormorantGaramond"
              ),
            ),
          ),
          body: SafeArea(
            top: false,
            child:
            BlocBuilder<MembershipCubit, MembershipState>(
              builder: (context, state) =>
              switch (state) {
                MembershipInitial() ||
                MembershipLoading() =>
                    MembershipLoadingView(
                      metrics: m,
                    ),

                MembershipError(:final message) =>
                    MembershipErrorView(
                      metrics: m,
                      message: message,
                      onRetry: () => context
                          .read<MembershipCubit>()
                          .load(),
                    ),

                MembershipLoaded() =>
                    _stateView(state, m),
              },
            ),
          ),
        );
      },
    );
  }

  Widget _stateView(
      MembershipLoaded state,
      MembershipMetrics m,
      ) {
    final membership = state.membership;

    if (membership.subscription != null) {
      return _Loaded(
        state: state,
        metrics: m,
      );
    }

    if (membership.pending != null) {
      return _PendingView(
        pending: membership.pending!,
        metrics: m,
      );
    }

    return _NoMembershipView(
      metrics: m,
    );
  }
}


class _NoMembershipView extends StatelessWidget {
  const _NoMembershipView({
    required this.metrics,
  });

  final MembershipMetrics metrics;

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    final m = metrics;

    return Center(
      child: Padding(
        padding: EdgeInsets.all(m.hPad),
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: m.maxContentWidth,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: m.iconCircle * 1.6,
                height: m.iconCircle * 1.6,
                decoration: BoxDecoration(
                  color: c.brandSoft,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.diamond_outlined,
                  size: m.iconCircle * 0.75,
                  color: c.brand,
                ),
              ),
              SizedBox(height: m.rowGap),
              Text(
                "You're not a member yet",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: m.sectionTitleSize,
                  fontWeight: FontWeight.w700,
                  color: c.textPrimary,
                ),
              ),
              SizedBox(height: m.rowGap * 0.5),
              Text(
                'Join The Vaults Membership and enjoy premium shopping benefits every day.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: m.bodySize,
                  height: 1.45,
                  color: c.textSecondary,
                ),
              ),
              SizedBox(height: m.sectionGap),
              SizedBox(
                width: m.isTablet
                    ? m.iconCircle * 5
                    : double.infinity,
                height: m.buttonHeight,
                child: ElevatedButton.icon(
                  onPressed: () => context.push(
                    AppRoutes.membershipPlans,
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: c.brand,
                    foregroundColor: ThemeColors.white,
                    elevation: 0,
                    minimumSize: Size.zero,
                    shape: RoundedRectangleBorder(
                      borderRadius:
                      BorderRadius.circular(
                        m.radiusMd,
                      ),
                    ),
                  ),
                  icon: Icon(
                    Icons.diamond_outlined,
                    size: m.smallIcon,
                    color: ThemeColors.gold1,
                  ),
                  label: Text(
                    'View plans',
                    style: TextStyle(
                      fontSize: m.bodySize,
                      fontWeight: FontWeight.w700,
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
}


class _PendingView extends StatefulWidget {
  const _PendingView({
    required this.pending,
    required this.metrics,
  });

  final MembershipPending pending;
  final MembershipMetrics metrics;

  @override
  State<_PendingView> createState() =>
      _PendingViewState();
}

class _PendingViewState extends State<_PendingView> {
  Timer? _poll;

  @override
  void initState() {
    super.initState();

    _poll = Timer.periodic(
      const Duration(seconds: 10),
          (_) {
        if (!mounted) return;

        context
            .read<MembershipCubit>()
            .refresh();
      },
    );
  }

  @override
  void dispose() {
    _poll?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    final m = widget.metrics;
    final p = widget.pending;

    return SingleChildScrollView(
      physics:
      const AlwaysScrollableScrollPhysics(),
      padding: EdgeInsets.all(m.hPad),
      child: Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: m.maxContentWidth,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                height: m.sectionGap * 1.6,
              ),
              Container(
                width: m.iconCircle * 1.6,
                height: m.iconCircle * 1.6,
                decoration: BoxDecoration(
                  color: c.statusWarningSoft,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.hourglass_bottom_rounded,
                  size: m.iconCircle * 0.75,
                  color: c.statusWarning,
                ),
              ),
              SizedBox(height: m.rowGap),
              Text(
                'Payment is being confirmed',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: m.sectionTitleSize,
                  fontWeight: FontWeight.w700,
                  color: c.textPrimary,
                ),
              ),
              SizedBox(
                height: m.rowGap * 0.5,
              ),
              Text(
                'Your membership will activate as soon as the payment clears on-chain.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: m.bodySize,
                  height: 1.45,
                  color: c.textSecondary,
                ),
              ),
              SizedBox(height: m.sectionGap),
              Container(
                padding: EdgeInsets.all(
                  m.cardPad,
                ),
                decoration: BoxDecoration(
                  color: c.surface,
                  borderRadius:
                  BorderRadius.circular(
                    m.radiusLg,
                  ),
                  border: Border.all(
                    color: c.border,
                  ),
                ),
                child: Column(
                  crossAxisAlignment:
                  CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.diamond_outlined,
                          size: m.smallIcon,
                          color: ThemeColors.gold1,
                        ),
                        SizedBox(
                          width: m.cardPad * 0.4,
                        ),
                        Expanded(
                          child: Text(
                            p.planName.isEmpty
                                ? 'Membership'
                                : p.planName,
                            maxLines: 1,
                            overflow:
                            TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize:
                              m.sectionTitleSize,
                              fontWeight:
                              FontWeight.w700,
                              color: c.textPrimary,
                            ),
                          ),
                        ),
                        Container(
                          padding:
                          EdgeInsets.symmetric(
                            horizontal:
                            m.cardPad * 0.5,
                            vertical:
                            m.cardPad * 0.22,
                          ),
                          decoration:
                          BoxDecoration(
                            color:
                            c.statusWarningSoft,
                            borderRadius:
                            BorderRadius.circular(
                              99,
                            ),
                          ),
                          child: Text(
                            'PENDING',
                            style: TextStyle(
                              fontSize:
                              m.captionSize *
                                  0.9,
                              fontWeight:
                              FontWeight.w700,
                              color:
                              c.statusWarning,
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(
                      height: m.rowGap * 0.6,
                    ),
                    Divider(
                      height: 1,
                      color: c.border,
                    ),
                    SizedBox(
                      height: m.rowGap * 0.6,
                    ),
                    _row(
                      context,
                      m,
                      'Amount',
                      p.priceLabel,
                    ),
                    SizedBox(
                      height: m.rowGap * 0.5,
                    ),
                    _row(
                      context,
                      m,
                      'Order ID',
                      p.reference,
                      copyable: true,
                    ),
                    SizedBox(
                      height: m.rowGap * 0.5,
                    ),
                    _row(
                      context,
                      m,
                      'Created',
                      _dateTime(p.createdAt),
                    ),
                  ],
                ),
              ),
              SizedBox(height: m.sectionGap),
              SizedBox(
                width: m.isTablet
                    ? m.iconCircle * 5
                    : double.infinity,
                height: m.buttonHeight,
                child: ElevatedButton.icon(
                  onPressed: () => context
                      .read<MembershipCubit>()
                      .refresh(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: c.brand,
                    foregroundColor:
                    ThemeColors.white,
                    elevation: 0,
                    minimumSize: Size.zero,
                    shape:
                    RoundedRectangleBorder(
                      borderRadius:
                      BorderRadius.circular(
                        m.radiusMd,
                      ),
                    ),
                  ),
                  icon: Icon(
                    Icons.refresh_rounded,
                    size: m.smallIcon,
                  ),
                  label: Text(
                    'Check again',
                    style: TextStyle(
                      fontSize: m.bodySize,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
              SizedBox(
                height: m.rowGap * 0.8,
              ),
              Text(
                'Checking automatically every few seconds…',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: m.captionSize,
                  color: c.textMuted,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _row(
      BuildContext context,
      MembershipMetrics m,
      String label,
      String value, {
        bool copyable = false,
      }) {
    final c = context.c;

    return Row(
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
        SizedBox(
          width: m.cardPad * 0.3,
        ),
        Flexible(
          child: InkWell(
            onTap: copyable
                ? () {
              Clipboard.setData(
                ClipboardData(text: value),
              );

              ScaffoldMessenger.of(context)
                ..hideCurrentSnackBar()
                ..showSnackBar(
                  const SnackBar(
                    content: Text(
                      'Order ID copied',
                    ),
                  ),
                );
            }
                : null,
            child: Text(
              value,
              textAlign: TextAlign.right,
              maxLines: 1,
              overflow:
              TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: m.labelSize,
                fontWeight: FontWeight.w700,
                color: copyable
                    ? c.brand
                    : c.textPrimary,
              ),
            ),
          ),
        ),
      ],
    );
  }

  String _dateTime(DateTime? d) {
    if (d == null) return '--';

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

    final hh =
    d.hour.toString().padLeft(2, '0');
    final mm =
    d.minute.toString().padLeft(2, '0');

    return '${months[d.month - 1]} '
        '${d.day}, $hh:$mm';
  }
}


class _Loaded extends StatelessWidget {
  const _Loaded({
    required this.state,
    required this.metrics,
  });

  final MembershipLoaded state;
  final MembershipMetrics metrics;

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    final m = metrics;

    final membership =
        state.membership;

    final sub =
    membership.subscription!;

    return Column(
      children: [
        Expanded(
          child: RefreshIndicator(
            color: c.brand,
            backgroundColor: c.surface,
            onRefresh: () => context
                .read<MembershipCubit>()
                .refresh(),
            child: SingleChildScrollView(
              physics:
              const AlwaysScrollableScrollPhysics(),
              padding: EdgeInsets.fromLTRB(
                m.hPad,
                m.vPad,
                m.hPad,
                m.sectionGap * 0.6,
              ),
              child: Center(
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    maxWidth: m.maxContentWidth,
                  ),
                  child: Column(
                    crossAxisAlignment:
                    CrossAxisAlignment.stretch,
                    children: [
                      MembershipHeroCard(
                        metrics: m,
                        title: membership.plan?.name ??
                            'Membership',
                        status: sub.statusLabel,
                        isActive: sub.isActive,
                        startDate: sub.startAt,
                        endDate: sub.endAt,
                        billingCycle:
                        sub.billingCycleLabel,
                        daysRemaining:
                        sub.daysRemaining,
                      ),
                      SizedBox(
                        height: m.sectionGap * 0.8,
                      ),
                      MembershipBenefitsCard(
                        entitlements: membership
                            .entitlements
                            .values
                            .toList(),
                        metrics: m,
                      ),
                      SizedBox(
                        height: m.sectionGap * 0.8,
                      ),
                      MembershipDetailsCard(
                        metrics: m,
                        items: [
                          MembershipDetailItem(
                            icon: Icons.card_membership_outlined,
                            label: 'Plan Name',
                            value: membership.plan?.name ?? '--',
                          ),
                          MembershipDetailItem(
                            icon: Icons.event_available_outlined,
                            label: 'Starting Date',
                            value: formatMembershipDate(
                              sub.startAt,
                            ),
                          ),
                          MembershipDetailItem(
                            icon: Icons.event_busy_outlined,
                            label: 'Expiry Date',
                            value: formatMembershipDate(
                              sub.endAt,
                            ),
                          ),
                          MembershipDetailItem(
                            icon: Icons.autorenew_rounded,
                            label: 'Billing Cycle',
                            value: sub.billingCycleLabel,
                          ),
                          MembershipDetailItem(
                            icon: Icons.attach_money_rounded,
                            label: 'Amount Paid',
                            value:
                            '${sub.priceLabel} (${sub.currency.toUpperCase()})',
                          ),
                          MembershipDetailItem(
                            icon: Icons.account_balance_wallet_outlined,
                            label: 'Payment Method',
                            value: 'BIGOD',
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),

        // IMPORTANT
        MembershipActionBottomBar(
          state: state,
          metrics: m,
        ),
      ],
    );
  }
}


