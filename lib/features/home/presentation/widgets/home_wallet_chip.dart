import 'package:flutter/material.dart';

import '../../../../core/theme/app_theme_colors.dart';
import 'home_metrics.dart';

class HomeWalletChip extends StatelessWidget {
  const HomeWalletChip({
    super.key,
    required this.metrics,
    required this.balanceLabel,
    this.onTap,
  });

  final HomeMetrics metrics;
  final String balanceLabel;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.c;
    final m = metrics;

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        height: m.searchHeight,
        padding: EdgeInsets.symmetric(horizontal: m.pagePadding * 0.55),
        decoration: BoxDecoration(
          color: colors.brandSoft,
          borderRadius: BorderRadius.circular(m.searchRadius),
          border: Border.all(color: colors.border),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.account_balance_wallet_rounded,
              size: m.searchIconSize * 0.8,
              color: colors.brand,
            ),
            SizedBox(width: m.pagePadding * 0.3),
            Text(
              balanceLabel,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: m.searchFontSize * 0.85,
                fontWeight: FontWeight.w700,
                color: colors.brand,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
