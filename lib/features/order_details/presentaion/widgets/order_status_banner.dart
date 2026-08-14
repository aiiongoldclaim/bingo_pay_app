import 'package:flutter/material.dart';

import '../../../../core/theme/app_theme_colors.dart';
import '../../../orders/presentation/widgets/order_status_style.dart';
import 'order_details_metrics.dart';

class OdStatusBanner extends StatelessWidget {
  const OdStatusBanner({
    super.key,
    required this.metrics,
    required this.status,
    required this.title,
    required this.message,
    this.timestamp,
    this.actionLabel,
    this.onAction,
  });

  final OrderDetailMetrics metrics;
  final String status;
  final String title;
  final String message;
  final String? timestamp;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    final m = metrics;
    final style = OrderStatusStyle.of(context, status);
    final isCancelled =
        OrderStatusStyle.toneOf(status) == OrderStatusTone.cancelled;

    final tint = isCancelled
        ? (c.isDark ? c.surfaceAlt : const Color(0xFFFDEDEA))
        : style.background;

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: m.pagePadding),
      child: Container(
        padding: EdgeInsets.all(m.cardPadding * 0.85),
        decoration: BoxDecoration(
          color: tint,
          borderRadius: BorderRadius.circular(m.cardRadius),
          border: Border.all(
            color: style.foreground.withValues(alpha: c.isDark ? 0.4 : 0.25),
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              width: m.bannerIconBadge,
              height: m.bannerIconBadge,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: style.foreground.withValues(alpha: 0.14),
                shape: BoxShape.circle,
              ),
              child: Icon(
                style.icon,
                size: m.bannerIconSize,
                color: style.foreground,
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
                      fontSize: m.bannerTitleSize,
                      fontWeight: FontWeight.w700,
                      color: style.foreground,
                    ),
                  ),
                  SizedBox(height: m.cardPadding * 0.2),
                  Text(
                    message,
                    style: TextStyle(
                      fontSize: m.bannerBodySize,
                      height: 1.35,
                      color: c.textPrimary,
                    ),
                  ),
                  if (timestamp != null && timestamp!.isNotEmpty) ...[
                    SizedBox(height: m.cardPadding * 0.15),
                    Text(
                      timestamp!,
                      style: TextStyle(
                        fontSize: m.bannerBodySize,
                        height: 1.35,
                        color: c.textSecondary,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            if (actionLabel != null) ...[
              SizedBox(width: m.cardPadding * 0.5),
              SizedBox(
                height: m.ctaHeight,
                child: OutlinedButton(
                  onPressed: onAction,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: c.brand,
                    backgroundColor: c.surface,
                    side: BorderSide(color: c.brand, width: 1.2),
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    padding: EdgeInsets.symmetric(
                      horizontal: m.cardPadding * 0.7,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Text(
                    actionLabel!,
                    maxLines: 1,
                    style: TextStyle(
                      fontSize: m.ctaFontSize,
                      fontWeight: FontWeight.w600,
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
