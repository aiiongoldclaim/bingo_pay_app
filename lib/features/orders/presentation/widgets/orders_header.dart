import 'package:flutter/material.dart';

import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/theme/app_theme_colors.dart';
import 'orders_metrics.dart';

class OrdersHeader extends StatelessWidget {
  const OrdersHeader({
    super.key,
    required this.metrics,
    required this.title,
    required this.subtitle,
    this.onBack,
    this.onSearch,
  });

  final OrdersMetrics metrics;
  final String title;
  final String subtitle;
  final VoidCallback? onBack;
  final VoidCallback? onSearch;

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    final m = metrics;

    return Padding(
      padding: EdgeInsets.fromLTRB(
        m.pagePadding * 0.4,
        m.pagePadding * 0.4,
        m.pagePadding,
        0,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          InkResponse(
            onTap: onBack,
            radius: m.headerIconSize,
            child: Padding(
              padding: EdgeInsets.all(m.pagePadding * 0.5),
              child: Icon(
                Icons.arrow_back_ios_new_rounded,
                size: m.headerIconSize * 0.8,
                color: c.textPrimary,
              ),
            ),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.brandLogo.copyWith(
                    fontSize: m.titleSize,
                    fontWeight: FontWeight.w700,
                    color: c.brand,
                  ),
                ),
                SizedBox(height: m.pagePadding * 0.15),
                Text(
                  subtitle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: m.subtitleSize,
                    height: 1.2,
                    color: c.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          InkResponse(
            onTap: onSearch,
            radius: m.headerIconSize,
            child: Padding(
              padding: EdgeInsets.all(m.pagePadding * 0.4),
              child: Icon(
                Icons.search_rounded,
                size: m.headerIconSize,
                color: c.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
