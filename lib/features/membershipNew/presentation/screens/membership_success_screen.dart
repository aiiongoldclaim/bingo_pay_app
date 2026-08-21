import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:bingo_pay/core/router/app_routes.dart';
import 'package:bingo_pay/core/theme/app_theme_colors.dart';
import 'package:bingo_pay/core/theme/theme_colors.dart';

import '../../data/models/membership_plan_model.dart';
import '../../data/models/membership_subscribe_model.dart';
import '../widgets/membership_checkout_args.dart';
import '../widgets/membership_metrices.dart';

/// Pay dabane ke baad — payment successful
class MembershipSuccessScreen extends StatelessWidget {
  const MembershipSuccessScreen({super.key, required this.args});

  final MembershipCheckoutArgs args;

  MembershipPlanOption get plan => args.plan;
  CheckoutSubscriptionRef get subscription => args.quote.subscription;
  CheckoutPayment get payment => args.quote.payment;

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
            body: Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    child: Center(
                      child: ConstrainedBox(
                        constraints:
                        BoxConstraints(maxWidth: m.maxContentWidth),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            _header(context, m),
                            Padding(
                              padding: EdgeInsets.fromLTRB(
                                m.hPad,
                                m.sectionGap * 0.8,
                                m.hPad,
                                m.sectionGap * 0.6,
                              ),
                              child: _invoiceCard(context, m),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                _bottomBar(context, m),
              ],
            ),
          );
        },
      ),
    );
  }

  // ---------------- header ----------------

  Widget _header(BuildContext context, MembershipMetrics m) {
    final c = context.c;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(
        m.hPad,
        m.sectionGap*2,
        m.hPad,
        m.sectionGap * 0.8,
      ),
      decoration: BoxDecoration(gradient: c.heroBanner),
      child: Column(
        children: [
          Container(
            width: m.iconCircle * 2.2,
            height: m.iconCircle * 2.2,
            decoration: BoxDecoration(
              color: c.surface,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: c.brand.withValues(alpha: 0.15),
                  blurRadius: m.cardPad * 1.5,
                  offset: Offset(0, m.cardPad * 0.4),
                ),
              ],
            ),
            child: Icon(
              Icons.check_rounded,
              size: m.iconCircle,
              color: c.statusSuccess,
            ),
          ),
          SizedBox(height: m.rowGap * 1.3),
          Text(
            'Payment Successful!',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: m.heroTitleSize * 0.8,
              fontWeight: FontWeight.w700,
              color: c.textPrimary,
            ),
          ),
          SizedBox(height: m.rowGap * 0.5),
          Text(
            'Thank you! Your payment has been received.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: m.bodySize,
              fontWeight: FontWeight.w400,
              color: c.textSecondary,
            ),
          ),
          SizedBox(height: m.rowGap),
          Container(
            padding: EdgeInsets.symmetric(
              horizontal: m.cardPad * 0.8,
              vertical: m.cardPad * 0.5,
            ),
            decoration: BoxDecoration(
              color: c.surface,
              borderRadius: BorderRadius.circular(m.radiusMd),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.receipt_long_outlined,
                  size: m.smallIcon,
                  color: c.brand,
                ),
                SizedBox(width: m.cardPad * 0.4),
                Text(
                  'Order  ',
                  style: TextStyle(
                    fontSize: m.labelSize,
                    fontWeight: FontWeight.w400,
                    color: c.textSecondary,
                  ),
                ),
                Flexible(
                  child: Text(
                    '#${subscription.reference}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: m.labelSize,
                      fontWeight: FontWeight.w700,
                      color: c.brand,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ---------------- invoice ----------------

  Widget _invoiceCard(BuildContext context, MembershipMetrics m) {
    final c = context.c;

    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: c.surface,
        borderRadius: BorderRadius.circular(m.radiusLg),
        border: Border.all(color: c.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // purple header
          Container(
            padding: EdgeInsets.all(m.cardPad),
            decoration: BoxDecoration(
              gradient: c.isDark
                  ? ThemeColors.heroBannerDark
                  : ThemeColors.primaryGradient1,
            ),
            child: Row(
              children: [
                Container(
                  width: m.iconCircle * 0.9,
                  height: m.iconCircle * 0.9,
                  decoration: BoxDecoration(
                    color: ThemeColors.white.withValues(alpha: 0.18),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.storefront_outlined,
                    size: m.iconSize,
                    color: ThemeColors.white,
                  ),
                ),
                SizedBox(width: m.cardPad * 0.6),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'The Vaults',
                        style: TextStyle(
                          fontSize: m.sectionTitleSize,
                          fontWeight: FontWeight.w700,
                          color: ThemeColors.white,
                        ),
                      ),
                      SizedBox(height: m.rowGap * 0.2),
                      Text(
                        'Invoice ${subscription.reference}',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: m.captionSize,
                          fontWeight: FontWeight.w600,
                          color: ThemeColors.white.withValues(alpha: 0.9),
                        ),
                      ),
                      SizedBox(height: m.rowGap * 0.4),
                      Row(
                        children: [
                          Text(
                            'Tax Invoice',
                            style: TextStyle(
                              fontSize: m.captionSize,
                              fontWeight: FontWeight.w400,
                              color: ThemeColors.white.withValues(alpha: 0.8),
                            ),
                          ),
                          const Spacer(),
                          Icon(
                            Icons.calendar_today_outlined,
                            size: m.captionSize * 1.2,
                            color: ThemeColors.white.withValues(alpha: 0.8),
                          ),
                          SizedBox(width: m.cardPad * 0.25),
                          Text(
                            _today(),
                            style: TextStyle(
                              fontSize: m.captionSize,
                              fontWeight: FontWeight.w500,
                              color: ThemeColors.white.withValues(alpha: 0.9),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // rows
          _row(
            context,
            m,
            icon: Icons.workspace_premium_outlined,
            label: 'PLAN',
            title: plan.name,
            subtitle: plan.version?.billingCycleLabel ?? '',
          ),
          Divider(height: 1, color: c.border, indent: m.cardPad),
          _row(
            context,
            m,
            icon: Icons.shopping_bag_outlined,
            title: 'Membership',
            subtitle: plan.version?.durationLabel ?? '',
            trailing: plan.version?.priceLabel ?? '--',
          ),
          Divider(height: 1, color: c.border, indent: m.cardPad),
          _row(
            context,
            m,
            icon: Icons.account_balance_wallet_outlined,
            title: 'Amount Paid',
            subtitle: payment.amountLabel,
            trailing: plan.version?.priceLabel ?? '--',
            trailingColor: c.statusSuccess,
          ),
        ],
      ),
    );
  }

  Widget _row(
      BuildContext context,
      MembershipMetrics m, {
        required IconData icon,
        required String title,
        String? label,
        String? subtitle,
        String? trailing,
        Color? trailingColor,
      }) {
    final c = context.c;

    return Padding(
      padding: EdgeInsets.all(m.cardPad),
      child: Row(
        children: [
          Container(
            width: m.iconCircle * 0.8,
            height: m.iconCircle * 0.8,
            decoration: BoxDecoration(
              color: c.brandSoft,
              borderRadius: BorderRadius.circular(m.radiusSm),
            ),
            child: Icon(icon, size: m.iconSize, color: c.brand),
          ),
          SizedBox(width: m.cardPad * 0.7),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (label != null) ...[
                  Text(
                    label,
                    style: TextStyle(
                      fontSize: m.captionSize,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 1,
                      color: c.textMuted,
                    ),
                  ),
                  SizedBox(height: m.rowGap * 0.2),
                ],
                Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: m.bodySize,
                    fontWeight: FontWeight.w700,
                    color: c.textPrimary,
                  ),
                ),
                if (subtitle != null && subtitle.isNotEmpty) ...[
                  SizedBox(height: m.rowGap * 0.2),
                  Text(
                    subtitle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: m.captionSize,
                      fontWeight: FontWeight.w400,
                      color: c.textSecondary,
                    ),
                  ),
                ],
              ],
            ),
          ),
          if (trailing != null) ...[
            SizedBox(width: m.cardPad * 0.4),
            Text(
              trailing,
              style: TextStyle(
                fontSize: m.sectionTitleSize,
                fontWeight: FontWeight.w700,
                color: trailingColor ?? c.textPrimary,
              ),
            ),
          ],
        ],
      ),
    );
  }

  // ---------------- bottom ----------------

  Widget _bottomBar(BuildContext context, MembershipMetrics m) {
    final c = context.c;

    return Container(
      padding: EdgeInsets.fromLTRB(m.hPad, m.rowGap * 0.8, m.hPad, m.rowGap),
      decoration: BoxDecoration(
        color: c.background,
        border: Border(top: BorderSide(color: c.border)),
      ),
      child: Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: m.maxContentWidth),
          child: Row(
            children: [
              Expanded(
                child: SizedBox(
                  height: m.buttonHeight,
                  child: OutlinedButton.icon(
                    onPressed: () {
                      // TODO: invoice download
                    },
                    style: OutlinedButton.styleFrom(
                      foregroundColor: c.brand,
                      side: BorderSide(color: c.brand),
                      minimumSize: Size.zero,
                      padding: EdgeInsets.symmetric(
                        horizontal: m.cardPad * 0.4,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(m.radiusMd),
                      ),
                    ),
                    icon: Icon(Icons.download_rounded, size: m.smallIcon),
                    label: FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(
                        'Download Invoice',
                        style: TextStyle(
                          fontSize: m.labelSize,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              SizedBox(width: m.cardPad * 0.6),
              Expanded(
                child: SizedBox(
                  height: m.buttonHeight,
                  child: ElevatedButton.icon(
                    onPressed: () => context.go(AppRoutes.home),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: c.brand,
                      foregroundColor: ThemeColors.white,
                      elevation: 0,
                      minimumSize: Size.zero,
                      padding: EdgeInsets.symmetric(
                        horizontal: m.cardPad * 0.4,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(m.radiusMd),
                      ),
                    ),
                    icon: Icon(Icons.home_outlined, size: m.smallIcon),
                    label: FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(
                        'Go to Home',
                        style: TextStyle(
                          fontSize: m.labelSize,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
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

  String _today() {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];
    final d = DateTime.now();
    return '${d.day} ${months[d.month - 1]} ${d.year}';
  }
}