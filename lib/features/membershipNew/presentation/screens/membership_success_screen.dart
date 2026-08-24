import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:bingo_pay/core/theme/app_theme_colors.dart';
import 'package:bingo_pay/core/theme/theme_colors.dart';

import '../../../../core/constants/image_constants.dart';
import '../../../../core/router/app_routes.dart';
import '../../data/models/membership_plan_model.dart';
import '../../data/models/membership_subscribe_model.dart';
import '../widgets/membership_checkout_args.dart';
import '../widgets/membership_metrices.dart';

/// Pay Now ke baad — "Membership Activated"
/// Koi API nahi, saara data checkout ke args se aata hai.
class MembershipActivatedScreen extends StatelessWidget {
  const MembershipActivatedScreen({super.key, required this.args});

  final MembershipCheckoutArgs args;

  MembershipPlanOption get plan => args.plan;

  CheckoutSubscriptionRef get subscription => args.quote.subscription;

  @override
  Widget build(BuildContext context) {
    final c = context.c;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) context.go(AppRoutes.home);
      },
      child: LayoutBuilder(
        builder: (context, _) {
          final m = MembershipMetrics.of(context);

          return Scaffold(
            backgroundColor: c.background,
            appBar: AppBar(
              backgroundColor: c.background,
              leading: IconButton(
                onPressed: () => context.go(AppRoutes.home),
                icon: Icon(
                  Icons.arrow_back_ios_new_rounded,
                  size: m.smallIcon,
                  color: c.textPrimary,
                ),
              ),
              title: Text(
                'Membership Activated',
                style: TextStyle(
                  fontSize: m.screenTitleSize,
                  fontWeight: FontWeight.w700,
                  color: c.textPrimary,
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => context.go(AppRoutes.home),
                  style: TextButton.styleFrom(foregroundColor: c.brand),
                  child: Text(
                    'Done',
                    style: TextStyle(
                      fontSize: m.labelSize,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                SizedBox(width: m.hPad * 0.3),
              ],
            ),
            body: SafeArea(
              top: false,
              child: Column(
                children: [
                  Expanded(
                    child: SingleChildScrollView(
                      padding: EdgeInsets.only(bottom: m.sectionGap * 0.6),
                      child: Center(
                        child: ConstrainedBox(
                          constraints:
                          BoxConstraints(maxWidth: m.maxContentWidth),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              _WelcomeHeader(plan: plan, metrics: m),
                              Padding(
                                padding: EdgeInsets.symmetric(
                                  horizontal: m.hPad,
                                ),
                                child: Column(
                                  crossAxisAlignment:
                                  CrossAxisAlignment.stretch,
                                  children: [
                                    SizedBox(height: m.sectionGap * 0.8),
                                    _SummaryCard(plan: plan, metrics: m),
                                    SizedBox(height: m.sectionGap * 0.8),
                                    _BenefitsBanner(metrics: m),
                                    SizedBox(height: m.sectionGap * 0.8),
                                    _OrderSummary(
                                      reference: subscription.reference,
                                      metrics: m,
                                    ),
                                    SizedBox(height: m.sectionGap * 0.8),
                                    _WhatsNext(metrics: m),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  _BottomBar(metrics: m),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// header — Welcome to The Vaults!
// ---------------------------------------------------------------------------

class _WelcomeHeader extends StatelessWidget {
  const _WelcomeHeader({required this.plan, required this.metrics});

  final MembershipPlanOption plan;
  final MembershipMetrics metrics;

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    final m = metrics;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(
        m.hPad,
        m.sectionGap * 0.8,
        m.hPad,
        m.sectionGap,
      ),
      decoration: BoxDecoration(
        color: c.brandSoft.withValues(alpha: c.isDark ? 0.25 : 0.5),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Stack(
            clipBehavior: Clip.none,
            children: [
              Container(
                width: m.iconCircle * 1.7,
                height: m.iconCircle * 1.7,
                decoration: BoxDecoration(
                  color: c.brand,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.diamond_outlined,
                  size: m.iconCircle * 0.8,
                  color: ThemeColors.gold1,
                ),
              ),
              Positioned(
                right: -m.cardPad * 0.15,
                top: -m.cardPad * 0.15,
                child: Container(
                  width: m.iconCircle * 0.6,
                  height: m.iconCircle * 0.6,
                  decoration: BoxDecoration(
                    color: ThemeColors.gold1,
                    shape: BoxShape.circle,
                    border: Border.all(color: c.background, width: 2),
                  ),
                  child: Icon(
                    Icons.check_rounded,
                    size: m.iconSize * 0.7,
                    color: ThemeColors.white,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: m.rowGap),
          Text(
            'Welcome to The Vaults!',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: m.heroTitleSize * 0.68,
              fontWeight: FontWeight.w700,
              color: c.textPrimary,
              fontFamily: 'CormorantGaramond',
            ),
          ),
          SizedBox(height: m.rowGap * 0.5),
          Text(
            'Your ${plan.name} is now active.\nEnjoy exclusive benefits and a premium shopping experience.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: m.bodySize,
              fontWeight: FontWeight.w400,
              height: 1.5,
              color: c.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// plan / amount / renewal / payment method
// ---------------------------------------------------------------------------

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({required this.plan, required this.metrics});

  final MembershipPlanOption plan;
  final MembershipMetrics metrics;

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    final m = metrics;

    final cell = <Widget>[
      _tile(
        context,
        icon: Icons.calendar_month_outlined,
        label: 'Plan',
        value: '${plan.name} (${_durationLabel(plan)})',
      ),
      _tile(
        context,
        icon: Icons.payments_outlined,
        label: 'Amount Paid',
        value: plan.version?.priceLabel ?? '--',
        emphasise: true,
      ),
      _tile(
        context,
        icon: Icons.event_repeat_outlined,
        label: 'Next Renewal',
        value: _renewsOn(plan),
      ),
      _tile(
        context,
        icon: Icons.account_balance_wallet_outlined,
        label: 'Payment Method',
        value: 'BIGOD',
      ),
    ];

    return Container(
      padding: EdgeInsets.all(m.cardPad),
      decoration: BoxDecoration(
        color: c.surface,
        borderRadius: BorderRadius.circular(m.radiusLg),
        border: Border.all(color: c.border),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final columns = m.isPhone && !m.isLandscape ? 2 : 4;
          final itemWidth =
              (constraints.maxWidth - m.tileGap * (columns - 1)) / columns;

          return Wrap(
            spacing: m.tileGap,
            runSpacing: m.rowGap,
            children: [
              for (final w in cell) SizedBox(width: itemWidth, child: w),
            ],
          );
        },
      ),
    );
  }

  Widget _tile(
      BuildContext context, {
        required IconData icon,
        required String label,
        required String value,
        bool emphasise = false,
      }) {
    final c = context.c;
    final m = metrics;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: m.iconCircle * 0.62,
          height: m.iconCircle * 0.62,
          decoration: BoxDecoration(
            color: c.brandSoft,
            borderRadius: BorderRadius.circular(m.radiusSm),
          ),
          child: Icon(icon, size: m.iconSize * 0.7, color: c.brand),
        ),
        SizedBox(width: m.cardPad * 0.4),
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
                  fontSize: m.captionSize,
                  fontWeight: FontWeight.w400,
                  color: c.textSecondary,
                ),
              ),
              SizedBox(height: m.rowGap * 0.18),
              Text(
                value,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: emphasise ? m.sectionTitleSize : m.labelSize,
                  fontWeight: FontWeight.w700,
                  height: 1.25,
                  color: emphasise ? c.brand : c.textPrimary,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// 365 -> "1 Year", 90 -> "3 Months", 30 -> "1 Month"
  String _durationLabel(MembershipPlanOption plan) {
    final days = plan.version?.durationDays ?? 0;
    if (days <= 0) return plan.version?.billingCycleLabel ?? '--';
    if (days % 365 == 0) {
      final y = days ~/ 365;
      return y == 1 ? '1 Year' : '$y Years';
    }
    final months = (days / 30).round();
    if (months <= 0) return '$days Days';
    return months == 1 ? '1 Month' : '$months Months';
  }

  String _renewsOn(MembershipPlanOption plan) {
    final days = plan.version?.durationDays ?? 0;
    if (days <= 0) return '--';

    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];
    final d = DateTime.now().add(Duration(days: days));
    return '${months[d.month - 1]} ${d.day}, ${d.year}';
  }
}

// ---------------------------------------------------------------------------
// MEMBER BENEFITS — pura image asset
// ---------------------------------------------------------------------------

class _BenefitsBanner extends StatelessWidget {
  const _BenefitsBanner({required this.metrics});

  final MembershipMetrics metrics;

  @override
  Widget build(BuildContext context) {
    final m = metrics;

    return ClipRRect(
      borderRadius: BorderRadius.circular(m.radiusLg),
      child: Image.asset(
        AppImages.membershipCard,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => const SizedBox.shrink(),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// order summary
// ---------------------------------------------------------------------------

class _OrderSummary extends StatelessWidget {
  const _OrderSummary({required this.reference, required this.metrics});

  final String reference;
  final MembershipMetrics metrics;

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    final m = metrics;

    return Column(
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
        SizedBox(height: m.rowGap),
        InkWell(
          onTap: reference.isEmpty
              ? null
              : () {
            Clipboard.setData(ClipboardData(text: reference));
            ScaffoldMessenger.of(context)
              ..hideCurrentSnackBar()
              ..showSnackBar(
                const SnackBar(
                  content: Text('Order ID copied'),
                  behavior: SnackBarBehavior.floating,
                ),
              );
          },
          borderRadius: BorderRadius.circular(m.radiusLg),
          child: Container(
            padding: EdgeInsets.all(m.cardPad * 0.8),
            decoration: BoxDecoration(
              color: c.surface,
              borderRadius: BorderRadius.circular(m.radiusLg),
              border: Border.all(color: c.border),
            ),
            child: Row(
              children: [
                Container(
                  width: m.iconCircle * 0.7,
                  height: m.iconCircle * 0.7,
                  decoration: BoxDecoration(
                    color: c.brandSoft,
                    borderRadius: BorderRadius.circular(m.radiusSm),
                  ),
                  child: Icon(
                    Icons.receipt_long_outlined,
                    size: m.iconSize * 0.75,
                    color: c.brand,
                  ),
                ),
                SizedBox(width: m.cardPad * 0.5),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Order ID',
                        style: TextStyle(
                          fontSize: m.captionSize,
                          fontWeight: FontWeight.w400,
                          color: c.textSecondary,
                        ),
                      ),
                      SizedBox(height: m.rowGap * 0.18),
                      Text(
                        reference.isEmpty ? '--' : reference,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: m.labelSize,
                          fontWeight: FontWeight.w700,
                          color: c.textPrimary,
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(width: m.cardPad * 0.3),
                Icon(
                  Icons.copy_rounded,
                  size: m.smallIcon * 0.85,
                  color: c.brand,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// what's next — hardcoded
// ---------------------------------------------------------------------------

class _WhatsNext extends StatelessWidget {
  const _WhatsNext({required this.metrics});

  final MembershipMetrics metrics;

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    final m = metrics;

    final items = <_NextItem>[
      _NextItem(
        icon: Icons.shopping_bag_outlined,
        title: 'Start Shopping',
        subtitle: 'Shop now and enjoy exclusive offers',
        route: AppRoutes.home,
      ),
      _NextItem(
        icon: Icons.local_offer_outlined,
        title: 'Exclusive Deals',
        subtitle: 'Access member-only deals & discounts',
        route: AppRoutes.allProducts,
      ),
      _NextItem(
        icon: Icons.inventory_2_outlined,
        title: 'Track Orders',
        subtitle: 'Track your orders and returns',
        route: AppRoutes.orders,
      ),
      _NextItem(
        icon: Icons.headset_mic_outlined,
        title: 'Need Help?',
        subtitle: 'We\u2019re here for you 24/7',
        route: AppRoutes.help,
      ),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'What\u2019s Next?',
          style: TextStyle(
            fontSize: m.sectionTitleSize,
            fontWeight: FontWeight.w700,
            color: c.textPrimary,
          ),
        ),
        SizedBox(height: m.rowGap),
        LayoutBuilder(
          builder: (context, constraints) {
            final columns = m.isPhone && !m.isLandscape ? 2 : 4;
            final itemWidth =
                (constraints.maxWidth - m.tileGap * (columns - 1)) / columns;

            return Wrap(
              spacing: m.tileGap,
              runSpacing: m.tileGap,
              children: [
                for (final item in items)
                  SizedBox(
                    width: itemWidth,
                    child: _NextTile(item: item, metrics: m),
                  ),
              ],
            );
          },
        ),
      ],
    );
  }
}

class _NextItem {
  const _NextItem({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.route,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final String route;
}

class _NextTile extends StatelessWidget {
  const _NextTile({required this.item, required this.metrics});

  final _NextItem item;
  final MembershipMetrics metrics;

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    final m = metrics;

    return InkWell(
      onTap: () => context.go(item.route),
      borderRadius: BorderRadius.circular(m.radiusMd),
      child: Container(
        padding: EdgeInsets.all(m.cardPad * 0.7),
        decoration: BoxDecoration(
          color: c.surface,
          borderRadius: BorderRadius.circular(m.radiusMd),
          border: Border.all(color: c.border),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: m.iconCircle * 0.75,
              height: m.iconCircle * 0.75,
              decoration: BoxDecoration(
                color: c.brandSoft,
                shape: BoxShape.circle,
              ),
              child: Icon(item.icon, size: m.iconSize * 0.85, color: c.brand),
            ),
            SizedBox(height: m.rowGap * 0.5),
            Text(
              item.title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: m.captionSize * 1.05,
                fontWeight: FontWeight.w700,
                color: c.textPrimary,
              ),
            ),
            SizedBox(height: m.rowGap * 0.25),
            Text(
              item.subtitle,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: m.captionSize * 0.88,
                fontWeight: FontWeight.w400,
                height: 1.3,
                color: c.textSecondary,
              ),
            ),
            SizedBox(height: m.rowGap * 0.4),
            Icon(
              Icons.chevron_right_rounded,
              size: m.smallIcon * 0.9,
              color: c.brand,
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------

class _BottomBar extends StatelessWidget {
  const _BottomBar({required this.metrics});

  final MembershipMetrics metrics;

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    final m = metrics;

    return Container(
      padding: EdgeInsets.fromLTRB(m.hPad, m.rowGap * 0.7, m.hPad, m.rowGap),
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
            child: ElevatedButton(
              onPressed: () => context.go(AppRoutes.home),
              style: ElevatedButton.styleFrom(
                backgroundColor: c.brand,
                foregroundColor: ThemeColors.white,
                elevation: 0,
                minimumSize: Size.zero,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(m.radiusMd),
                ),
              ),
              child: Text(
                'Continue Shopping',
                style: TextStyle(
                  fontSize: m.sectionTitleSize,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}