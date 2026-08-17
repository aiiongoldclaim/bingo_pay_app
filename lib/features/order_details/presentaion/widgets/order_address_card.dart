import 'package:flutter/material.dart';

import '../../../../core/theme/app_theme_colors.dart';
import 'order_details_metrics.dart';

class OdAddressCard extends StatelessWidget {
  const OdAddressCard({
    super.key,
    required this.metrics,
    required this.addressText,
    this.recipientName,
    this.phone,
    this.actionLabel,
    this.onAction,
  });

  final OrderDetailMetrics metrics;
  final String addressText;
  final String? recipientName;
  final String? phone;
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
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: m.addressIconBadge,
              height: m.addressIconBadge,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: c.brandSoft,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.location_on_outlined,
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
                  if ((recipientName ?? '').isNotEmpty) ...[
                    Text(
                      recipientName!,
                      style: TextStyle(
                        fontSize: m.addressNameSize,
                        fontWeight: FontWeight.w700,
                        color: c.textPrimary,
                      ),
                    ),
                    SizedBox(height: m.cardPadding * 0.3),
                  ],
                  Text(
                    addressText,
                    style: TextStyle(
                      fontSize: m.addressBodySize,
                      height: 1.45,
                      color: c.textSecondary,
                    ),
                  ),
                  if ((phone ?? '').isNotEmpty) ...[
                    SizedBox(height: m.cardPadding * 0.2),
                    Text(
                      'Phone: $phone',
                      style: TextStyle(
                        fontSize: m.addressBodySize,
                        height: 1.45,
                        color: c.textSecondary,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            if (actionLabel != null) ...[
              SizedBox(width: m.cardPadding * 0.4),
              InkWell(
                onTap: onAction,
                child: Padding(
                  padding: EdgeInsets.all(m.cardPadding * 0.2),
                  child: Text(
                    actionLabel!,
                    style: TextStyle(
                      fontSize: m.ctaFontSize,
                      fontWeight: FontWeight.w600,
                      color: c.brand,
                    ),
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
