import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:bingo_pay/core/di/injection.dart';
import 'package:bingo_pay/core/router/app_routes.dart';
import 'package:bingo_pay/core/theme/app_theme_colors.dart';
import 'package:bingo_pay/core/theme/theme_colors.dart';

import '../../../../core/constants/image_constants.dart';
import '../../data/models/member_ship_model.dart';

import '../cubit/membership_cubit.dart';
import '../cubit/membership_state.dart';
import '../widgets/membership_metrices.dart';
import '../widgets/status_view.dart';

/// Account page se khulti hai — "My Membership"
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
  State<_MyMembershipView> createState() => _MyMembershipViewState();
}

class _MyMembershipViewState extends State<_MyMembershipView> {
  StreamSubscription<MembershipEvent>? _sub;

  @override
  void initState() {
    super.initState();
    _sub = context.read<MembershipCubit>().events.listen(_onEvent);
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
                  context.go(AppRoutes.account);
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
                fontSize: m.screenTitleSize,
                fontWeight: FontWeight.w700,
                color: c.textPrimary,
              ),
            ),
            actions: [
              IconButton(
                onPressed: () => context.push(AppRoutes.help),
                icon: Icon(
                  Icons.help_outline_rounded,
                  size: m.smallIcon * 1.2,
                  color: c.textPrimary,
                ),
              ),
              SizedBox(width: m.hPad * 0.3),
            ],
          ),
          body: SafeArea(
            top: false,
            child: BlocBuilder<MembershipCubit, MembershipState>(
              builder: (context, state) => switch (state) {
                MembershipInitial() ||
                MembershipLoading() =>
                    MembershipLoadingView(metrics: m),

                MembershipError(:final message) => MembershipErrorView(
                  metrics: m,
                  message: message,
                  onRetry: () => context.read<MembershipCubit>().load(),
                ),

                MembershipLoaded() => _stateView(state, m),
              },
            ),
          ),
        );
      },
    );
  }

  Widget _stateView(MembershipLoaded state, MembershipMetrics m) {
    final membership = state.membership;

    if (membership.subscription != null) {
      return _Loaded(state: state, metrics: m);
    }
    if (membership.pending != null) {
      return _PendingView(pending: membership.pending!, metrics: m);
    }
    return _NoMembershipView(metrics: m);
  }
}

// ---------------------------------------------------------------------------
// membership hai hi nahi -> plans par bhejo
// ---------------------------------------------------------------------------

class _NoMembershipView extends StatelessWidget {
  const _NoMembershipView({required this.metrics});

  final MembershipMetrics metrics;

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    final m = metrics;

    return Center(
      child: Padding(
        padding: EdgeInsets.all(m.hPad),
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: m.maxContentWidth),
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
                  fontWeight: FontWeight.w400,
                  height: 1.45,
                  color: c.textSecondary,
                ),
              ),
              SizedBox(height: m.sectionGap),
              SizedBox(
                width: m.isTablet ? m.iconCircle * 5 : double.infinity,
                height: m.buttonHeight,
                child: ElevatedButton.icon(
                  onPressed: () => context.push(AppRoutes.membershipPlans),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: c.brand,
                    foregroundColor: ThemeColors.white,
                    elevation: 0,
                    minimumSize: Size.zero,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(m.radiusMd),
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

// ---------------------------------------------------------------------------
// payment abhi confirm nahi hua
// ---------------------------------------------------------------------------

class _PendingView extends StatefulWidget {
  const _PendingView({required this.pending, required this.metrics});

  final MembershipPending pending;
  final MembershipMetrics metrics;

  @override
  State<_PendingView> createState() => _PendingViewState();
}

class _PendingViewState extends State<_PendingView> {
  Timer? _poll;

  @override
  void initState() {
    super.initState();
    _poll = Timer.periodic(const Duration(seconds: 10), (_) {
      if (!mounted) return;
      context.read<MembershipCubit>().refresh();
    });
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
      physics: const AlwaysScrollableScrollPhysics(),
      padding: EdgeInsets.all(m.hPad),
      child: Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: m.maxContentWidth),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(height: m.sectionGap * 1.6),
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
              SizedBox(height: m.rowGap * 0.5),
              Text(
                'Your membership will activate as soon as the payment clears on-chain.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: m.bodySize,
                  fontWeight: FontWeight.w400,
                  height: 1.45,
                  color: c.textSecondary,
                ),
              ),
              SizedBox(height: m.sectionGap),
              Container(
                padding: EdgeInsets.all(m.cardPad),
                decoration: BoxDecoration(
                  color: c.surface,
                  borderRadius: BorderRadius.circular(m.radiusLg),
                  border: Border.all(color: c.border),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.diamond_outlined,
                          size: m.smallIcon,
                          color: ThemeColors.gold1,
                        ),
                        SizedBox(width: m.cardPad * 0.4),
                        Expanded(
                          child: Text(
                            p.planName.isEmpty ? 'Membership' : p.planName,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: m.sectionTitleSize,
                              fontWeight: FontWeight.w700,
                              color: c.textPrimary,
                            ),
                          ),
                        ),
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: m.cardPad * 0.5,
                            vertical: m.cardPad * 0.22,
                          ),
                          decoration: BoxDecoration(
                            color: c.statusWarningSoft,
                            borderRadius: BorderRadius.circular(99),
                          ),
                          child: Text(
                            'PENDING',
                            style: TextStyle(
                              fontSize: m.captionSize * 0.9,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 0.5,
                              color: c.statusWarning,
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: m.rowGap * 0.6),
                    Divider(height: 1, color: c.border),
                    SizedBox(height: m.rowGap * 0.6),
                    _row(context, m, 'Amount', p.priceLabel),
                    SizedBox(height: m.rowGap * 0.5),
                    _row(context, m, 'Order ID', p.reference, copyable: true),
                    SizedBox(height: m.rowGap * 0.5),
                    _row(context, m, 'Created', _dateTime(p.createdAt)),
                  ],
                ),
              ),
              SizedBox(height: m.sectionGap),
              SizedBox(
                width: m.isTablet ? m.iconCircle * 5 : double.infinity,
                height: m.buttonHeight,
                child: ElevatedButton.icon(
                  onPressed: () => context.read<MembershipCubit>().refresh(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: c.brand,
                    foregroundColor: ThemeColors.white,
                    elevation: 0,
                    minimumSize: Size.zero,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(m.radiusMd),
                    ),
                  ),
                  icon: Icon(Icons.refresh_rounded, size: m.smallIcon),
                  label: Text(
                    'Check again',
                    style: TextStyle(
                      fontSize: m.bodySize,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
              SizedBox(height: m.rowGap * 0.8),
              Text(
                'Checking automatically every few seconds\u2026',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: m.captionSize,
                  fontWeight: FontWeight.w400,
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
        SizedBox(width: m.cardPad * 0.3),
        Flexible(
          child: InkWell(
            onTap: copyable
                ? () {
              Clipboard.setData(ClipboardData(text: value));
              ScaffoldMessenger.of(context)
                ..hideCurrentSnackBar()
                ..showSnackBar(
                  const SnackBar(
                    content: Text('Order ID copied'),
                    behavior: SnackBarBehavior.floating,
                  ),
                );
            }
                : null,
            borderRadius: BorderRadius.circular(m.radiusSm),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Flexible(
                  child: Text(
                    value,
                    textAlign: TextAlign.right,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: m.labelSize,
                      fontWeight: FontWeight.w700,
                      color: copyable ? c.brand : c.textPrimary,
                    ),
                  ),
                ),
                if (copyable) ...[
                  SizedBox(width: m.cardPad * 0.25),
                  Icon(
                    Icons.copy_rounded,
                    size: m.smallIcon * 0.75,
                    color: c.brand,
                  ),
                ],
              ],
            ),
          ),
        ),
      ],
    );
  }

  String _dateTime(DateTime? d) {
    if (d == null) return '--';
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];
    final hh = d.hour.toString().padLeft(2, '0');
    final mm = d.minute.toString().padLeft(2, '0');
    return '${months[d.month - 1]} ${d.day}, $hh:$mm';
  }
}

// ---------------------------------------------------------------------------
// member — Image 4
// ---------------------------------------------------------------------------

class _Loaded extends StatelessWidget {
  const _Loaded({required this.state, required this.metrics});

  final MembershipLoaded state;
  final MembershipMetrics metrics;

  MembershipModel get membership => state.membership;

  MembershipSubscription get sub => membership.subscription!;

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    final m = metrics;

    return Column(
      children: [
        Expanded(
          child: RefreshIndicator(
            color: c.brand,
            backgroundColor: c.surface,
            onRefresh: () => context.read<MembershipCubit>().refresh(),
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: EdgeInsets.fromLTRB(
                m.hPad,
                m.vPad,
                m.hPad,
                m.sectionGap * 0.6,
              ),
              child: Center(
                child: ConstrainedBox(
                  constraints: BoxConstraints(maxWidth: m.maxContentWidth),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _HeroCard(
                        plan: membership.plan,
                        subscription: sub,
                        metrics: m,
                      ),
                      SizedBox(height: m.sectionGap * 0.8),
                      _BenefitsCard(
                        entitlements: membership.entitlements.values.toList(),
                        metrics: m,
                      ),
                      SizedBox(height: m.sectionGap * 0.8),
                      _DetailsCard(
                        plan: membership.plan,
                        subscription: sub,
                        metrics: m,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
        _BottomBar(state: state, metrics: m),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// HERO
// ---------------------------------------------------------------------------

class _HeroCard extends StatelessWidget {
  const _HeroCard({
    required this.plan,
    required this.subscription,
    required this.metrics,
  });

  final MembershipPlan? plan;
  final MembershipSubscription subscription;
  final MembershipMetrics metrics;

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    final m = metrics;

    const onHero = ThemeColors.white;
    final onHeroMuted = onHero.withValues(alpha: 0.78);
    final hairline = onHero.withValues(alpha: 0.14);

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
          Positioned(
            right: -m.cardPad * 0.5,
            top: 0,
            width: m.iconCircle * 3.4,
            height: m.iconCircle * 3.4,
            child: Image.asset(
              AppImages.membership,
              fit: BoxFit.contain,
              alignment: Alignment.topRight,
              errorBuilder: (_, __, ___) => const SizedBox.shrink(),
            ),
          ),
          Padding(
            padding: EdgeInsets.all(m.cardPad),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.diamond_outlined,
                      size: m.brandWordSize * 1.3,
                      color: ThemeColors.gold1,
                    ),
                    SizedBox(width: m.cardPad * 0.35),
                    Text(
                      'THE VAULTS',
                      style: TextStyle(
                        fontSize: m.brandWordSize,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 1.6,
                        color: ThemeColors.gold1,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: m.rowGap),
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: m.cardPad * 0.55,
                    vertical: m.cardPad * 0.26,
                  ),
                  decoration: BoxDecoration(
                    color: subscription.isActive
                        ? c.statusSuccess
                        : c.statusWarning,
                    borderRadius: BorderRadius.circular(99),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        subscription.isActive
                            ? Icons.check_circle_rounded
                            : Icons.info_rounded,
                        size: m.captionSize * 1.25,
                        color: ThemeColors.white,
                      ),
                      SizedBox(width: m.cardPad * 0.25),
                      Text(
                        subscription.statusLabel.toUpperCase(),
                        style: TextStyle(
                          fontSize: m.captionSize,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.5,
                          color: ThemeColors.white,
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: m.rowGap * 0.8),
                SizedBox(
                  width: m.isTablet
                      ? double.infinity
                      : MediaQuery.sizeOf(context).width * 0.55,
                  child: Text(
                    plan?.name ?? 'Membership',
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: m.heroTitleSize * 0.72,
                      fontWeight: FontWeight.w700,
                      height: 1.2,
                      color: onHero,
                    ),
                  ),
                ),
                SizedBox(height: m.rowGap * 0.35),
                SizedBox(
                  width: m.isTablet
                      ? double.infinity
                      : MediaQuery.sizeOf(context).width * 0.55,
                  child: Text(
                    'You\u2019re enjoying premium benefits with The Vaults.',
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: m.heroBodySize,
                      fontWeight: FontWeight.w400,
                      height: 1.4,
                      color: onHeroMuted,
                    ),
                  ),
                ),
                SizedBox(height: m.rowGap * 1.2),
                Divider(height: 1, color: hairline),
                SizedBox(height: m.rowGap),
                _stats(context, m, onHero, onHeroMuted, hairline),
                SizedBox(height: m.rowGap),
                _autoRenewBar(context, m, onHero, onHeroMuted),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _stats(
      BuildContext context,
      MembershipMetrics m,
      Color onHero,
      Color onHeroMuted,
      Color hairline,
      ) {
    final c = context.c;

    Widget cell({
      required IconData icon,
      required String label,
      required String value,
      String? extra,
    }) =>
        Expanded(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: m.iconCircle * 0.62,
                height: m.iconCircle * 0.62,
                decoration: BoxDecoration(
                  color: onHero.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(m.radiusSm),
                ),
                child: Icon(icon, size: m.iconSize * 0.72, color: onHero),
              ),
              SizedBox(width: m.cardPad * 0.35),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      label,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: m.captionSize * 0.92,
                        fontWeight: FontWeight.w400,
                        color: onHeroMuted,
                      ),
                    ),
                    SizedBox(height: m.rowGap * 0.15),
                    Text(
                      value,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: m.labelSize,
                        fontWeight: FontWeight.w700,
                        color: onHero,
                      ),
                    ),
                    if (extra != null) ...[
                      SizedBox(height: m.rowGap * 0.15),
                      Text(
                        extra,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: m.captionSize * 0.92,
                          fontWeight: FontWeight.w600,
                          color: c.statusSuccess,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        );

    Widget divider() => Container(
      width: 1,
      height: m.iconCircle * 0.9,
      margin: EdgeInsets.symmetric(horizontal: m.cardPad * 0.3),
      color: hairline,
    );

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          cell(
            icon: Icons.event_available_outlined,
            label: 'Started On',
            value: _date(subscription.startAt),
          ),
          divider(),
          cell(
            icon: Icons.event_busy_outlined,
            label: 'Expires On',
            value: _date(subscription.endAt),
            extra: '${subscription.daysRemaining} days left',
          ),
          divider(),
          cell(
            icon: Icons.autorenew_rounded,
            label: 'Billing Cycle',
            value: subscription.billingCycleLabel,
          ),
        ],
      ),
    );
  }

  Widget _autoRenewBar(
      BuildContext context,
      MembershipMetrics m,
      Color onHero,
      Color onHeroMuted,
      ) {
    final c = context.c;
    final on = subscription.autoRenew;

    return Container(
      padding: EdgeInsets.all(m.cardPad * 0.6),
      decoration: BoxDecoration(
        color: onHero.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(m.radiusMd),
        border: Border.all(color: onHero.withValues(alpha: 0.14)),
      ),
      child: Row(
        children: [
          Container(
            width: m.iconCircle * 0.66,
            height: m.iconCircle * 0.66,
            decoration: BoxDecoration(
              color: ThemeColors.gold1.withValues(alpha: 0.16),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.bolt_rounded,
              size: m.iconSize * 0.78,
              color: ThemeColors.gold1,
            ),
          ),
          SizedBox(width: m.cardPad * 0.5),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Auto Renewal is ${on ? 'ON' : 'OFF'}',
                  style: TextStyle(
                    fontSize: m.labelSize,
                    fontWeight: FontWeight.w700,
                    color: ThemeColors.gold1,
                  ),
                ),
                SizedBox(height: m.rowGap * 0.15),
                Text(
                  on
                      ? 'Your membership will renew automatically.'
                      : 'Your membership will not renew automatically.',
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: m.captionSize * 0.94,
                    fontWeight: FontWeight.w400,
                    height: 1.3,
                    color: onHeroMuted,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(width: m.cardPad * 0.35),
          // API me toggle ka endpoint nahi hai -> abhi display-only
          Switch(
            value: on,
            onChanged: null,
            activeThumbColor: ThemeColors.white,
            activeTrackColor: c.statusSuccess,
            inactiveThumbColor: ThemeColors.white,
            inactiveTrackColor: onHero.withValues(alpha: 0.25),
          ),
        ],
      ),
    );
  }

  String _date(DateTime? d) {
    if (d == null) return '--';
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];
    return '${months[d.month - 1]} ${d.day}, ${d.year}';
  }
}

// ---------------------------------------------------------------------------
// BENEFITS
// ---------------------------------------------------------------------------

class _BenefitsCard extends StatelessWidget {
  const _BenefitsCard({required this.entitlements, required this.metrics});

  final List<MembershipEntitlement> entitlements;
  final MembershipMetrics metrics;

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    final m = metrics;

    if (entitlements.isEmpty) return const SizedBox.shrink();

    final items = [...entitlements]..sort((a, b) {
      if (a.enabled == b.enabled) return 0;
      return a.enabled ? -1 : 1;
    });

    return Container(
      padding: EdgeInsets.all(m.cardPad),
      decoration: BoxDecoration(
        color: c.surface,
        borderRadius: BorderRadius.circular(m.radiusLg),
        border: Border.all(color: c.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  'Your Membership Benefits',
                  style: TextStyle(
                    fontSize: m.sectionTitleSize,
                    fontWeight: FontWeight.w700,
                    color: c.textPrimary,
                  ),
                ),
              ),
              SizedBox(width: m.cardPad * 0.4),
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: m.cardPad * 0.5,
                  vertical: m.cardPad * 0.25,
                ),
                decoration: BoxDecoration(
                  color: ThemeColors.gold1.withValues(alpha: 0.16),
                  borderRadius: BorderRadius.circular(99),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.workspace_premium_outlined,
                      size: m.captionSize * 1.3,
                      color: ThemeColors.gold500,
                    ),
                    SizedBox(width: m.cardPad * 0.25),
                    Text(
                      'Powered by Your Plan',
                      style: TextStyle(
                        fontSize: m.captionSize * 0.92,
                        fontWeight: FontWeight.w600,
                        color: ThemeColors.gold500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: m.rowGap),
          LayoutBuilder(
            builder: (context, constraints) {
              final columns = m.isTablet ? 4 : 3;
              final itemWidth =
                  (constraints.maxWidth - m.tileGap * (columns - 1)) / columns;

              return Wrap(
                spacing: m.tileGap,
                runSpacing: m.tileGap,
                children: [
                  for (final e in items)
                    SizedBox(
                      width: itemWidth,
                      child: _BenefitTile(entitlement: e, metrics: m),
                    ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}

class _BenefitTile extends StatelessWidget {
  const _BenefitTile({required this.entitlement, required this.metrics});

  final MembershipEntitlement entitlement;
  final MembershipMetrics metrics;

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    final m = metrics;
    final on = entitlement.enabled;

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: m.cardPad * 0.4,
        vertical: m.cardPad * 0.7,
      ),
      decoration: BoxDecoration(
        color: on ? c.surfaceAlt : c.surface,
        borderRadius: BorderRadius.circular(m.radiusMd),
        border: Border.all(color: c.border),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: m.iconCircle * 0.78,
            height: m.iconCircle * 0.78,
            decoration: BoxDecoration(
              color: on ? c.brandSoft : c.surfaceAlt,
              shape: BoxShape.circle,
            ),
            child: Icon(
              _icon(entitlement.key),
              size: m.iconSize * 0.9,
              color: on ? c.brand : c.textMuted,
            ),
          ),
          SizedBox(height: m.rowGap * 0.5),
          Text(
            entitlement.name,
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: m.captionSize * 1.05,
              fontWeight: FontWeight.w700,
              height: 1.25,
              color: on ? c.textPrimary : c.textSecondary,
            ),
          ),
          SizedBox(height: m.rowGap * 0.35),
          Container(
            padding: EdgeInsets.symmetric(
              horizontal: m.cardPad * 0.35,
              vertical: m.cardPad * 0.18,
            ),
            decoration: BoxDecoration(
              color: on ? c.statusSuccessSoft : c.surfaceAlt,
              borderRadius: BorderRadius.circular(99),
            ),
            child: Text(
              _chipLabel(),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: m.captionSize * 0.88,
                fontWeight: FontWeight.w700,
                color: on ? c.statusSuccess : c.textMuted,
              ),
            ),
          ),
          SizedBox(height: m.rowGap * 0.35),
          Text(
            _subtitle(),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: m.captionSize * 0.85,
              fontWeight: FontWeight.w400,
              height: 1.3,
              color: c.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  String _chipLabel() {
    if (!entitlement.enabled) return 'Not Included';

    switch (entitlement.type.toUpperCase()) {
      case 'PERCENTAGE':
        final n = entitlement.numeric;
        if (n == null) return 'Enabled';
        return '${_trim(n)}${entitlement.unitLabel ?? '%'} OFF';
      case 'DURATION':
        final n = entitlement.numeric;
        if (n == null) return 'Enabled';
        return '${_trim(n)} ${entitlement.unitLabel ?? ''}'.trim();
      default:
        return 'Enabled';
    }
  }

  String _subtitle() {
    if (!entitlement.enabled) return 'Available on higher plans';

    switch (entitlement.key.toUpperCase()) {
      case 'AUCTION_BUYER_ACCESS':
        return 'Access to exclusive auctions';
      case 'DISCOUNT_PERCENT':
        return 'On eligible products';
      case 'LUXE_EARLY_ACCESS':
        return 'Be the first to shop';
      case 'ULTRA_LUXE_EARLY_ACCESS':
        return 'Earliest access to drops';
      case 'EXCLUSIVE_ACCESS':
        return 'Access to member-only items';
      case 'EARLY_ACCESS_DURATION':
        final n = entitlement.numeric;
        return n == null
            ? 'Shop before others'
            : 'Shop ${_trim(n)} ${entitlement.unitLabel ?? ''} before others'
            .trim();
      case 'FREE_DELIVERY':
        return 'On every eligible order';
      default:
        return 'Included in your plan';
    }
  }

  String _trim(num v) => v % 1 == 0 ? v.toInt().toString() : v.toString();

  IconData _icon(String key) => switch (key.toUpperCase()) {
    'AUCTION_BUYER_ACCESS' => Icons.gavel_rounded,
    'FREE_DELIVERY' => Icons.local_shipping_outlined,
    'DISCOUNT_PERCENT' => Icons.local_offer_outlined,
    'LUXE_EARLY_ACCESS' => Icons.access_time_rounded,
    'ULTRA_LUXE_EARLY_ACCESS' => Icons.diamond_outlined,
    'EXCLUSIVE_ACCESS' => Icons.workspace_premium_outlined,
    'EARLY_ACCESS_DURATION' => Icons.timer_outlined,
    _ => Icons.card_giftcard_rounded,
  };
}

// ---------------------------------------------------------------------------
// DETAILS
// ---------------------------------------------------------------------------

class _DetailsCard extends StatelessWidget {
  const _DetailsCard({
    required this.plan,
    required this.subscription,
    required this.metrics,
  });

  final MembershipPlan? plan;
  final MembershipSubscription subscription;
  final MembershipMetrics metrics;

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    final m = metrics;

    return Container(
      padding: EdgeInsets.all(m.cardPad),
      decoration: BoxDecoration(
        color: c.surface,
        borderRadius: BorderRadius.circular(m.radiusLg),
        border: Border.all(color: c.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Wrap(
            alignment: WrapAlignment.spaceBetween,
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: m.cardPad * 0.4,
            runSpacing: m.rowGap * 0.4,
            children: [
              Text(
                'Membership Details',
                style: TextStyle(
                  fontSize: m.sectionTitleSize,
                  fontWeight: FontWeight.w700,
                  color: c.textPrimary,
                ),
              ),
              InkWell(
                onTap: () {
                  Clipboard.setData(
                    ClipboardData(text: subscription.reference),
                  );
                  ScaffoldMessenger.of(context)
                    ..hideCurrentSnackBar()
                    ..showSnackBar(
                      const SnackBar(
                        content: Text('Reference copied'),
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                },
                borderRadius: BorderRadius.circular(m.radiusSm),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Reference: ',
                      style: TextStyle(
                        fontSize: m.captionSize,
                        fontWeight: FontWeight.w400,
                        color: c.textSecondary,
                      ),
                    ),
                    Text(
                      subscription.reference,
                      style: TextStyle(
                        fontSize: m.captionSize,
                        fontWeight: FontWeight.w700,
                        color: c.brand,
                      ),
                    ),
                    SizedBox(width: m.cardPad * 0.25),
                    Icon(
                      Icons.copy_rounded,
                      size: m.smallIcon * 0.8,
                      color: c.brand,
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: m.rowGap * 0.6),
          _row(
            context,
            icon: Icons.calendar_month_outlined,
            label: 'Plan Name',
            value: plan?.name ?? '--',
          ),
          Divider(height: 1, color: c.border),
          _row(
            context,
            icon: Icons.receipt_long_outlined,
            label: 'Billing Cycle',
            value: subscription.billingCycleLabel,
          ),
          Divider(height: 1, color: c.border),
          _row(
            context,
            icon: Icons.attach_money_rounded,
            label: 'Amount Paid',
            value:
            '${subscription.priceLabel}  (${subscription.currency.toUpperCase()})',
          ),
          Divider(height: 1, color: c.border),
          _row(
            context,
            icon: Icons.account_balance_wallet_outlined,
            label: 'Payment Method',
            value: 'BIGOD',
          ),
          Divider(height: 1, color: c.border),
          _row(
            context,
            icon: Icons.verified_outlined,
            label: 'Plan Version',
            value: 'v${subscription.planVersion}',
          ),
        ],
      ),
    );
  }

  Widget _row(
      BuildContext context, {
        required IconData icon,
        required String label,
        required String value,
      }) {
    final c = context.c;
    final m = metrics;

    return Padding(
      padding: EdgeInsets.symmetric(vertical: m.rowGap * 0.55),
      child: Row(
        children: [
          Container(
            width: m.iconCircle * 0.6,
            height: m.iconCircle * 0.6,
            decoration: BoxDecoration(
              color: c.brandSoft,
              borderRadius: BorderRadius.circular(m.radiusSm),
            ),
            child: Icon(icon, size: m.iconSize * 0.7, color: c.brand),
          ),
          SizedBox(width: m.cardPad * 0.5),
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                fontSize: m.labelSize,
                fontWeight: FontWeight.w500,
                color: c.textPrimary,
              ),
            ),
          ),
          SizedBox(width: m.cardPad * 0.3),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.right,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: m.labelSize,
                fontWeight: FontWeight.w600,
                color: c.textSecondary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// BOTTOM BAR — Cancel Plan
// ---------------------------------------------------------------------------

class _BottomBar extends StatelessWidget {
  const _BottomBar({required this.state, required this.metrics});

  final MembershipLoaded state;
  final MembershipMetrics metrics;

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    final m = metrics;
    final sub = state.membership.subscription!;
    final busy = state.isCancelling;
    final active = sub.isActive;

    return Container(
      padding: EdgeInsets.fromLTRB(m.hPad, m.rowGap * 0.8, m.hPad, m.rowGap),
      decoration: BoxDecoration(
        color: c.background,
        border: Border(top: BorderSide(color: c.border)),
      ),
      child: Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: m.maxContentWidth),
          child: SizedBox(
            width: double.infinity,
            height: m.buttonHeight,
            child: OutlinedButton.icon(
              onPressed: busy || !active
                  ? null
                  : () => _confirmCancel(context, m, sub),
              style: OutlinedButton.styleFrom(
                foregroundColor: c.statusWarning,
                disabledForegroundColor: c.textMuted,
                side: BorderSide(color: active ? c.statusWarning : c.border),
                minimumSize: Size.zero,
                padding: EdgeInsets.symmetric(horizontal: m.cardPad * 0.4),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(m.radiusMd),
                ),
              ),
              icon: busy
                  ? SizedBox(
                width: m.smallIcon,
                height: m.smallIcon,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    c.statusWarning,
                  ),
                ),
              )
                  : Icon(Icons.cancel_outlined, size: m.smallIcon),
              label: FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  active ? 'Cancel Plan' : 'Plan cancelled',
                  style: TextStyle(
                    fontSize: m.labelSize,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _confirmCancel(
      BuildContext context,
      MembershipMetrics m,
      MembershipSubscription sub,
      ) async {
    final cubit = context.read<MembershipCubit>();

    final ok = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(m.radiusLg)),
      ),
      builder: (sheetContext) {
        final c = sheetContext.c;

        return SafeArea(
          top: false,
          child: Padding(
            padding: EdgeInsets.fromLTRB(
              m.hPad,
              m.cardPad,
              m.hPad,
              m.sectionGap * 0.7,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Center(
                  child: Container(
                    width: m.iconBox,
                    height: m.progressHeight * 0.6,
                    decoration: BoxDecoration(
                      color: c.border,
                      borderRadius: BorderRadius.circular(99),
                    ),
                  ),
                ),
                SizedBox(height: m.sectionGap * 0.7),
                Center(
                  child: Container(
                    width: m.iconCircle * 1.2,
                    height: m.iconCircle * 1.2,
                    decoration: BoxDecoration(
                      color: c.statusWarningSoft,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.cancel_outlined,
                      size: m.iconCircle * 0.6,
                      color: c.statusWarning,
                    ),
                  ),
                ),
                SizedBox(height: m.rowGap),
                Text(
                  'Cancel membership?',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: m.sectionTitleSize,
                    fontWeight: FontWeight.w700,
                    color: c.textPrimary,
                  ),
                ),
                SizedBox(height: m.rowGap * 0.5),
                Text(
                  'Your benefits stay active till the end of the term. After that you go back to the free plan.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: m.labelSize,
                    fontWeight: FontWeight.w400,
                    height: 1.45,
                    color: c.textSecondary,
                  ),
                ),
                SizedBox(height: m.sectionGap * 0.8),
                SizedBox(
                  height: m.buttonHeight,
                  child: ElevatedButton(
                    onPressed: () => Navigator.of(sheetContext).pop(true),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: c.statusWarning,
                      foregroundColor: ThemeColors.white,
                      elevation: 0,
                      minimumSize: Size.zero,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(m.radiusMd),
                      ),
                    ),
                    child: Text(
                      'Yes, cancel',
                      style: TextStyle(
                        fontSize: m.sectionTitleSize,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
                SizedBox(height: m.rowGap * 0.6),
                SizedBox(
                  height: m.buttonHeight,
                  child: TextButton(
                    onPressed: () => Navigator.of(sheetContext).pop(false),
                    style: TextButton.styleFrom(
                      foregroundColor: c.textSecondary,
                      minimumSize: Size.zero,
                    ),
                    child: Text(
                      'Keep membership',
                      style: TextStyle(
                        fontSize: m.labelSize,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );

    if (ok == true) cubit.cancel(sub.uuid);
  }
}