import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import 'package:bingo_pay/core/router/app_routes.dart';
import 'package:bingo_pay/core/theme/app_theme_colors.dart';
import 'package:bingo_pay/core/theme/theme_colors.dart';

import '../../data/models/member_ship_model.dart';
import '../cubit/membership_cubit.dart';
import '../cubit/membership_state.dart';
import 'membership_metrices.dart';

enum MembershipAction {
  cancel,
  resume,
  renew,
}

class MembershipActionBottomBar
    extends StatelessWidget {
  const MembershipActionBottomBar({
    super.key,
    required this.state,
    required this.metrics,
  });

  final MembershipLoaded state;
  final MembershipMetrics metrics;

  @override
  Widget build(BuildContext context) {
    final subscription =
        state.membership.subscription;

    if (subscription == null) {
      return const SizedBox.shrink();
    }

    final action =
    MembershipActionHelper.getAction(
      subscription,
      showRenewAfterResume:
      state.showRenewAfterResume,
    );

    return _MembershipActionBar(
      state: state,
      metrics: metrics,
      subscription: subscription,
      action: action,
    );
  }
}

class _MembershipActionBar
    extends StatelessWidget {
  const _MembershipActionBar({
    required this.state,
    required this.metrics,
    required this.subscription,
    required this.action,
  });

  final MembershipLoaded state;
  final MembershipMetrics metrics;
  final MembershipSubscription subscription;
  final MembershipAction action;

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    final m = metrics;
    final busy = state.isActionInProgress;

    final actionColor =
    MembershipActionHelper.getColor(
      context,
      action,
    );

    final isCancel =
        action == MembershipAction.cancel;

    final isResume =
        action == MembershipAction.resume;

    return Container(
      padding: EdgeInsets.fromLTRB(
        m.hPad,
        m.rowGap * 0.8,
        m.hPad,
        m.rowGap,
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
          constraints: BoxConstraints(
            maxWidth: m.maxContentWidth,
          ),
          child: SizedBox(
            width: double.infinity,
            height: m.buttonHeight,
            child: OutlinedButton.icon(
              onPressed: busy
                  ? null
                  : () => _handleAction(
                context,
                action,
                subscription,
                m,
              ),
              style: OutlinedButton.styleFrom(
                foregroundColor: actionColor,
                disabledForegroundColor:
                c.textMuted,
                side: BorderSide(
                  color: busy
                      ? c.border
                      : actionColor,
                ),
                minimumSize: Size.zero,
                padding: EdgeInsets.symmetric(
                  horizontal:
                  m.cardPad * 0.4,
                ),
                shape:
                RoundedRectangleBorder(
                  borderRadius:
                  BorderRadius.circular(
                    m.radiusMd,
                  ),
                ),
              ),
              icon: busy
                  ? SizedBox(
                width: m.smallIcon,
                height: m.smallIcon,
                child:
                CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor:
                  AlwaysStoppedAnimation<
                      Color>(
                    actionColor,
                  ),
                ),
              )
                  : Icon(
                MembershipActionHelper
                    .getIcon(action),
                size: m.smallIcon,
              ),
              label: FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  MembershipActionHelper
                      .getLabel(action),
                  style: TextStyle(
                    fontSize: m.labelSize,
                    fontWeight:
                    FontWeight.w700,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _handleAction(
      BuildContext context,
      MembershipAction action,
      MembershipSubscription sub,
      MembershipMetrics m,
      ) async {
    switch (action) {
      case MembershipAction.cancel:
        await MembershipActionHelper
            .confirmCancel(
          context,
          m,
          sub,
        );
        break;

      case MembershipAction.resume:
        await MembershipActionHelper
            .confirmResume(
          context,
          m,
          sub,
        );
        break;

      case MembershipAction.renew:
        context.push(
          AppRoutes.membershipPlans,
        );
        break;
    }
  }
}

class MembershipActionHelper {
  static bool isExpired(
      MembershipSubscription sub,
      ) {
    if (sub.endAt == null) {
      return false;
    }

    final now = DateTime.now();

    final today = DateTime(
      now.year,
      now.month,
      now.day,
    );

    final expiry = DateTime(
      sub.endAt!.toLocal().year,
      sub.endAt!.toLocal().month,
      sub.endAt!.toLocal().day,
    );

    return expiry.isBefore(today);
  }

  static bool isCancelled(
      MembershipSubscription sub,
      ) {
    return sub.status.toUpperCase() ==
        'CANCELLED';
  }

  static MembershipAction getAction(
      MembershipSubscription sub, {
        required bool showRenewAfterResume,
      }) {
    if (showRenewAfterResume) {
      return MembershipAction.renew;
    }

    final cancelled =
    isCancelled(sub);

    final expired =
    isExpired(sub);

    if (cancelled && !expired) {
      return MembershipAction.resume;
    }

    if (cancelled && expired) {
      return MembershipAction.renew;
    }

    return MembershipAction.cancel;
  }

  static String getLabel(
      MembershipAction action,
      ) {
    switch (action) {
      case MembershipAction.cancel:
        return 'Cancel Plan';

      case MembershipAction.resume:
        return 'Resume Plan';

      case MembershipAction.renew:
        return 'Renew Plan';
    }
  }

  static IconData getIcon(
      MembershipAction action,
      ) {
    switch (action) {
      case MembershipAction.cancel:
        return Icons.cancel_outlined;

      case MembershipAction.resume:
        return Icons.play_circle_outline;

      case MembershipAction.renew:
        return Icons.autorenew_rounded;
    }
  }

  static Color getColor(
      BuildContext context,
      MembershipAction action,
      ) {
    final c = context.c;

    switch (action) {
      case MembershipAction.cancel:
        return c.statusWarning;

      case MembershipAction.resume:
        return c.brand;

      case MembershipAction.renew:
        return c.statusSuccess;
    }
  }

  static Future<void> confirmCancel(
      BuildContext context,
      MembershipMetrics m,
      MembershipSubscription sub,
      ) async {
    final cubit =
    context.read<MembershipCubit>();

    final ok =
    await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor:
      Theme.of(context)
          .scaffoldBackgroundColor,
      shape: RoundedRectangleBorder(
        borderRadius:
        BorderRadius.vertical(
          top: Radius.circular(
            m.radiusLg,
          ),
        ),
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
              children: [
                _SheetHandle(metrics: m),
                SizedBox(
                  height:
                  m.sectionGap * 0.7,
                ),
                _ActionIcon(
                  metrics: m,
                  background:
                  c.statusWarningSoft,
                  icon:
                  Icons.cancel_outlined,
                  color:
                  c.statusWarning,
                ),
                SizedBox(
                  height: m.rowGap,
                ),
                _SheetTitle(
                  metrics: m,
                  title:
                  'Cancel membership?',
                ),
                SizedBox(
                  height: m.rowGap * 0.5,
                ),
                _SheetDescription(
                  metrics: m,
                  text:
                  'Your benefits stay active till the end of the term. After that you go back to the free plan.',
                ),
                SizedBox(
                  height:
                  m.sectionGap * 0.8,
                ),
                SizedBox(
                  height: m.buttonHeight,
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () =>
                        Navigator.of(
                          sheetContext,
                        ).pop(true),
                    style:
                    ElevatedButton.styleFrom(
                      backgroundColor:
                      c.statusWarning,
                      foregroundColor:
                      ThemeColors.white,
                      elevation: 0,
                      shape:
                      RoundedRectangleBorder(
                        borderRadius:
                        BorderRadius.circular(
                          m.radiusMd,
                        ),
                      ),
                    ),
                    child: Text(
                      'Yes, cancel',
                      style: TextStyle(
                        fontSize:
                        m.sectionTitleSize,
                        fontWeight:
                        FontWeight.w700,
                      ),
                    ),
                  ),
                ),
                SizedBox(
                  height: m.rowGap * 0.6,
                ),
                TextButton(
                  onPressed: () =>
                      Navigator.of(
                        sheetContext,
                      ).pop(false),
                  child: Text(
                    'Keep membership',
                    style: TextStyle(
                      fontSize: m.labelSize,
                      fontWeight:
                      FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );

    if (ok == true) {
      await cubit.cancel(sub.uuid);
    }
  }

  static Future<void> confirmResume(
      BuildContext context,
      MembershipMetrics m,
      MembershipSubscription sub,
      ) async {
    final cubit =
    context.read<MembershipCubit>();

    final ok =
    await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor:
      Theme.of(context)
          .scaffoldBackgroundColor,
      shape: RoundedRectangleBorder(
        borderRadius:
        BorderRadius.vertical(
          top: Radius.circular(
            m.radiusLg,
          ),
        ),
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
              children: [
                _SheetHandle(metrics: m),
                SizedBox(
                  height:
                  m.sectionGap * 0.7,
                ),
                _ActionIcon(
                  metrics: m,
                  background: c.brandSoft,
                  icon:
                  Icons.play_circle_outline,
                  color: c.brand,
                ),
                SizedBox(
                  height: m.rowGap,
                ),
                _SheetTitle(
                  metrics: m,
                  title:
                  'Resume membership?',
                ),
                SizedBox(
                  height: m.rowGap * 0.5,
                ),
                _SheetDescription(
                  metrics: m,
                  text:
                  'Your membership will be resumed and remain active until the current expiry date.',
                ),
                SizedBox(
                  height:
                  m.sectionGap * 0.8,
                ),
                SizedBox(
                  width: double.infinity,
                  height: m.buttonHeight,
                  child: ElevatedButton(
                    onPressed: () =>
                        Navigator.of(
                          sheetContext,
                        ).pop(true),
                    style:
                    ElevatedButton.styleFrom(
                      backgroundColor: c.brand,
                      foregroundColor:
                      ThemeColors.white,
                      elevation: 0,
                      shape:
                      RoundedRectangleBorder(
                        borderRadius:
                        BorderRadius.circular(
                          m.radiusMd,
                        ),
                      ),
                    ),
                    child: Text(
                      'Yes, Resume',
                      style: TextStyle(
                        fontSize: m.labelSize,
                        fontWeight:
                        FontWeight.w700,
                      ),
                    ),
                  ),
                ),
                SizedBox(
                  height: m.rowGap * 0.5,
                ),
                TextButton(
                  onPressed: () =>
                      Navigator.of(
                        sheetContext,
                      ).pop(false),
                  child: Text(
                    'Keep Cancelled',
                    style: TextStyle(
                      fontSize: m.labelSize,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );

    if (ok == true) {
      await cubit.resumeMembership(
        sub.uuid,
      );
    }
  }
}

class _SheetHandle extends StatelessWidget {
  const _SheetHandle({
    required this.metrics,
  });

  final MembershipMetrics metrics;

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    final m = metrics;

    return Container(
      width: m.iconBox,
      height: m.progressHeight * 0.6,
      decoration: BoxDecoration(
        color: c.border,
        borderRadius:
        BorderRadius.circular(99),
      ),
    );
  }
}

class _ActionIcon extends StatelessWidget {
  const _ActionIcon({
    required this.metrics,
    required this.background,
    required this.icon,
    required this.color,
  });

  final MembershipMetrics metrics;
  final Color background;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final m = metrics;

    return Container(
      width: m.iconCircle * 1.2,
      height: m.iconCircle * 1.2,
      decoration: BoxDecoration(
        color: background,
        shape: BoxShape.circle,
      ),
      child: Icon(
        icon,
        size: m.iconCircle * 0.6,
        color: color,
      ),
    );
  }
}

class _SheetTitle extends StatelessWidget {
  const _SheetTitle({
    required this.metrics,
    required this.title,
  });

  final MembershipMetrics metrics;
  final String title;

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    final m = metrics;

    return Text(
      title,
      textAlign: TextAlign.center,
      style: TextStyle(
        fontSize: m.sectionTitleSize,
        fontWeight: FontWeight.w700,
        color: c.textPrimary,
      ),
    );
  }
}

class _SheetDescription extends StatelessWidget {
  const _SheetDescription({
    required this.metrics,
    required this.text,
  });

  final MembershipMetrics metrics;
  final String text;

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    final m = metrics;

    return Text(
      text,
      textAlign: TextAlign.center,
      style: TextStyle(
        fontSize: m.labelSize,
        height: 1.45,
        color: c.textSecondary,
      ),
    );
  }
}