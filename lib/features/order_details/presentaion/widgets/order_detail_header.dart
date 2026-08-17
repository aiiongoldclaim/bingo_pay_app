import 'package:flutter/material.dart';

import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/theme/app_theme_colors.dart';
import 'order_details_metrics.dart';

class OrderDetailHeader extends StatelessWidget {
  const OrderDetailHeader({
    super.key,
    required this.metrics,
    required this.brandName,
    this.onBack,
    this.onHelp,
    this.helpLabel = 'Help',
  });

  final OrderDetailMetrics metrics;
  final String brandName;
  final VoidCallback? onBack;
  final VoidCallback? onHelp;
  final String helpLabel;

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    final m = metrics;

    return SizedBox(
      height: m.logoSize * 2,
      child: Row(
        children: [
          InkResponse(
            onTap: onBack,
            radius: m.headerIconSize,
            child: Padding(
              padding: EdgeInsets.all(m.pagePadding * 0.4),
              child: Icon(
                Icons.arrow_back_rounded,
                size: m.headerIconSize,
                color: c.textPrimary,
              ),
            ),
          ),
          Expanded(
            child: Center(
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  brandName,
                  style: AppTextStyles.brandLogo.copyWith(
                    fontSize: m.logoSize,
                    color: c.brand,
                  ),
                ),
              ),
            ),
          ),
          InkWell(
            onTap: onHelp,
            borderRadius: BorderRadius.circular(8),
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: m.pagePadding * 0.3,
                vertical: m.pagePadding * 0.4,
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.headset_mic_outlined,
                    size: m.headerIconSize * 0.85,
                    color: c.brand,
                  ),
                  SizedBox(width: m.pagePadding * 0.3),
                  Text(
                    helpLabel,
                    style: TextStyle(
                      fontSize: m.helpFontSize,
                      fontWeight: FontWeight.w600,
                      color: c.brand,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
