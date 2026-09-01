import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:bingo_pay/core/di/injection.dart';
import 'package:bingo_pay/core/router/app_routes.dart';
import 'package:bingo_pay/core/theme/app_theme_colors.dart';
import 'package:bingo_pay/core/theme/theme_colors.dart';

import '../cubit/membership_cubit.dart';
import '../cubit/membership_state.dart';
import '../widgets/membership_checkout_args.dart';
import '../widgets/membership_metrices.dart';
import '../widgets/membership_plan_widgets.dart';
import '../widgets/status_view.dart';

class MembershipPlansScreen extends StatelessWidget {
  const MembershipPlansScreen({super.key, this.preselectPlanUuid});

  final String? preselectPlanUuid;

  @override
  Widget build(BuildContext context) {
    return BlocProvider<MembershipCubit>(
      create: (_) =>
      getIt<MembershipCubit>()..load(preselectPlanUuid: preselectPlanUuid),
      child: const _MembershipPlansView(),
    );
  }
}

class _MembershipPlansView extends StatefulWidget {
  const _MembershipPlansView();

  @override
  State<_MembershipPlansView> createState() => _MembershipPlansViewState();
}

class _MembershipPlansViewState extends State<_MembershipPlansView> {
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

  Future<void> _onEvent(MembershipEvent event) async {
    if (!mounted) return;
    final colors = context.c;

    switch (event) {
      case MembershipMessage(
          :final text,
          :final isError,
      ):
        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(
            SnackBar(
              content: Text(text),
              backgroundColor:
              isError
                  ? colors.statusWarning
                  : colors.statusSuccess,
              behavior:
              SnackBarBehavior.floating,
            ),
          );

      case MembershipQuoteCreated(
          :final quote,
          :final plan,
      ):
        final cubit =
        context.read<MembershipCubit>();

        await context.push(
          AppRoutes.membershipCheckout,
          extra: MembershipCheckoutArgs(
            plan: plan,
            quote: quote,
          ),
        );

        cubit.clearQuote();

      case MembershipCancelled():
        break;

      case MembershipPaymentConfirmed():
        break;

      case MembershipResumed():
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.c;

    return LayoutBuilder(
      builder: (context, _) {
        final m = MembershipMetrics.of(context);

        return Scaffold(
          backgroundColor: colors.background,
          appBar: AppBar(
            backgroundColor: colors.background,
            toolbarHeight: m.buttonHeight * 1.3,
            leading: IconButton(
              onPressed: () {
                if (context.canPop()) context.pop();
              },
              icon: Icon(
                Icons.arrow_back_ios_new_rounded,
                size: m.smallIcon,
                color: colors.textPrimary,
              ),
            ),
            title: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Choose Your Plan',
                  style: TextStyle(
                    fontSize: m.screenTitleSize * 1,
                    fontWeight: FontWeight.w700,
                    color: colors.textPrimary,
                    fontFamily: "CormorantGaramond",
                  ),
                ),
                SizedBox(height: m.rowGap * 0.2),
                Text(
                  'Select the perfect membership for you',
                  style: TextStyle(
                    fontSize: m.captionSize * 1.5,
                    fontWeight: FontWeight.w400,
                    color: colors.textSecondary,
                  ),
                ),
              ],
            ),
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

              MembershipRefreshing(:final previous) => _loadedView(
                context,
                previous,
                m,
                isRefreshing: true,
              ),

              MembershipLoaded() => _loadedView(
                context,
                state,
                m,
                isRefreshing: false,
              ),
            },
          ),
        ),
        );
      },
    );
  }
  Widget _loadedView(
      BuildContext context,
      MembershipLoaded state,
      MembershipMetrics m, {
        required bool isRefreshing,
      }) {
    if (state.plans.isEmpty) {
      if (state.plansError != null) {
        return MembershipErrorView(
          metrics: m,
          message: state.plansError!,
          onRetry: () => context.read<MembershipCubit>().load(),
        );
      }

      return MembershipEmptyView(metrics: m);
    }

    return _Loaded(
      state: state,
      metrics: m,
      isRefreshing: isRefreshing,
    );
  }
}


class _Loaded extends StatelessWidget {
  const _Loaded({required this.state, required this.metrics,this.isRefreshing = false,});

  final MembershipLoaded state;
  final MembershipMetrics metrics;
  final bool isRefreshing;

  @override
  Widget build(BuildContext context) {
    final m = metrics;

    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            padding: EdgeInsets.only(bottom: m.sectionGap * 0.6),
            child: Center(
              child: ConstrainedBox(
                constraints: BoxConstraints(maxWidth: m.maxContentWidth),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [

                    Padding(
                      padding: EdgeInsets.fromLTRB(m.hPad, m.vPad, m.hPad, 0),
                      child: MembershipPlansHero(metrics: m),
                    ),

                    SizedBox(height: m.sectionGap * 0.8),

                    // 3D ring carousel
                    MembershipPlanRingCarousel(
                      plans: state.plans,
                      selectedUuid: state.selectedPlan?.uuid,
                      metrics: m,
                      onPlanChanged: (uuid) =>
                          context.read<MembershipCubit>().selectPlan(uuid),
                    ),

                    SizedBox(height: m.rowGap * 1.2),

                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: m.hPad),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Text(
                            'Compare Plan Features',
                            style: TextStyle(
                              fontSize: m.sectionTitleSize,
                              fontWeight: FontWeight.w700,
                              color: context.c.textPrimary,
                            ),
                          ),
                          SizedBox(height: m.rowGap),
                          MembershipCompareTable(
                            plans: state.plans,
                            featureKeys: state.comparableFeatureKeys,
                            featureNameFor: state.featureNameFor,
                            highlightPlanUuid: state.selectedPlan?.uuid,
                            metrics: m,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        _BottomBar(state: state, metrics: m, isRefreshing: isRefreshing,),
      ],
    );
  }
}


class _BottomBar extends StatelessWidget {
  const _BottomBar({required this.state, required this.metrics, this.isRefreshing = false,});

  final MembershipLoaded state;
  final MembershipMetrics metrics;
  final bool isRefreshing;

  @override
  Widget build(BuildContext context) {
    final colors = context.c;
    final m = metrics;
    final plan = state.selectedPlan;
    final busy = state.isSubscribing;

    return Container(
      padding: EdgeInsets.fromLTRB(m.hPad, m.rowGap * 0.7, m.hPad, m.rowGap),
      decoration: BoxDecoration(
        color: colors.background,
        border: Border(top: BorderSide(color: colors.border)),
      ),
      child: Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: m.maxContentWidth),
          child: SizedBox(
            width: double.infinity,
            height: m.buttonHeight,
            child: ElevatedButton(
              onPressed: plan == null || busy
                  ? null
                  : () => context.read<MembershipCubit>().subscribe(),
              style: ElevatedButton.styleFrom(
                backgroundColor: colors.brand,
                foregroundColor: ThemeColors.white,
                disabledBackgroundColor: colors.brand.withValues(alpha: 0.45),
                elevation: 0,
                minimumSize: Size.zero,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(m.radiusMd),
                ),
              ),
              child: busy
                  ? Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    width: m.smallIcon,
                    height: m.smallIcon,
                    child: const CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor:
                      AlwaysStoppedAnimation<Color>(ThemeColors.white),
                    ),
                  ),
                  SizedBox(width: m.cardPad * 0.45),
                  Text(
                    'Creating order\u2026',
                    style: TextStyle(
                      fontSize: m.sectionTitleSize,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              )
                  : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.diamond_outlined,
                    size: m.smallIcon,
                    color: ThemeColors.gold1,
                  ),
                  SizedBox(width: m.cardPad * 0.45),
                  Flexible(
                    child: Text(
                      plan == null
                          ? 'Continue'
                          : 'Continue with ${plan.name}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: m.sectionTitleSize,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  SizedBox(width: m.cardPad * 0.45),
                  Icon(Icons.chevron_right_rounded, size: m.smallIcon),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}