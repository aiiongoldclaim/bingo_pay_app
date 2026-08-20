import 'package:flutter/material.dart';

import '../../../../core/theme/app_theme_colors.dart';
import 'order_details_metrics.dart';

/// Payment method row — icon + title/subtitle + action
class OdPaymentCard extends StatelessWidget {
  const OdPaymentCard({
    super.key,
    required this.metrics,
    required this.title,
    required this.subtitle,
    this.actionLabel,
    this.onAction,
  });

  final OrderDetailMetrics metrics;
  final String title;
  final String subtitle;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    final m = metrics;

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: m.pagePadding),
      child: Container(
        padding: EdgeInsets.all(m.cardPadding),
        decoration: BoxDecoration(
          color: c.surface,
          borderRadius: BorderRadius.circular(m.cardRadius),
          border: Border.all(color: c.border),
        ),
        child: Row(
          children: [
            Container(
              width: m.addressIconBadge,
              height: m.addressIconBadge,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: c.brandSoft,
                borderRadius: BorderRadius.circular(m.cardRadius * 0.7),
              ),
              child: Icon(
                Icons.credit_card_rounded,
                size: m.addressIconSize,
                color: c.brand,
              ),
            ),
            SizedBox(width: m.cardPadding * 0.7),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: m.addressNameSize,
                      fontWeight: FontWeight.w700,
                      color: c.textPrimary,
                    ),
                  ),
                  SizedBox(height: m.cardPadding * 0.2),
                  Text(
                    subtitle,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: m.addressBodySize,
                      height: 1.35,
                      color: c.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            if (actionLabel != null) ...[
              SizedBox(width: m.cardPadding * 0.4),
              InkWell(
                onTap: onAction,
                child: Text(
                  actionLabel!,
                  style: TextStyle(
                    fontSize: m.ctaFontSize,
                    fontWeight: FontWeight.w600,
                    color: c.brand,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Tinted footer banner — "Safe and Secure Payments" / "Need help?"
class OdInfoBanner extends StatelessWidget {
  const OdInfoBanner({
    super.key,
    required this.metrics,
    required this.icon,
    required this.title,
    required this.subtitle,

  });

  final OrderDetailMetrics metrics;
  final IconData icon;
  final String title;
  final String subtitle;


  @override
  Widget build(BuildContext context) {
    final c = context.c;
    final m = metrics;

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: m.pagePadding),
      child: Container(
        padding: EdgeInsets.all(m.cardPadding * 0.9),
        decoration: BoxDecoration(
          color: c.brandSoft,
          borderRadius: BorderRadius.circular(m.cardRadius),
          border: c.isDark ? Border.all(color: c.border) : null,
        ),
        child: Row(
          children: [
            Icon(icon, size: m.addressIconSize * 1.15, color: c.brand),
            SizedBox(width: m.cardPadding * 0.7),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: m.bannerTitleSize,
                      fontWeight: FontWeight.w700,
                      color: c.brand,
                    ),
                  ),
                  SizedBox(height: m.cardPadding * 0.15),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: m.bannerBodySize,
                      height: 1.35,
                      color: c.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// "Reason for Cancellation" jaisa single navigable row
class OdNavRow extends StatelessWidget {
  const OdNavRow({
    super.key,
    required this.metrics,
    required this.title,
    required this.subtitle,
    this.onTap,
  });

  final OrderDetailMetrics metrics;
  final String title;
  final String subtitle;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    final m = metrics;

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: m.pagePadding),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(m.cardRadius),
        child: Container(
          padding: EdgeInsets.all(m.cardPadding),
          decoration: BoxDecoration(
            color: c.surface,
            borderRadius: BorderRadius.circular(m.cardRadius),
            border: Border.all(color: c.border),
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: m.addressNameSize,
                        fontWeight: FontWeight.w700,
                        color: c.textPrimary,
                      ),
                    ),
                    SizedBox(height: m.cardPadding * 0.2),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: m.addressBodySize,
                        color: c.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.chevron_right_rounded,
                size: m.addressIconSize,
                color: c.textSecondary,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
