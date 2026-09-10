import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../../core/theme/app_text_styles.dart';
import '../../../../../core/theme/app_theme_colors.dart';
import 'review_pay_metrics.dart';

// ── Top bar ────────────────────────────────────────────────────────────────
class ReviewTopBar extends StatelessWidget {
  final ReviewPayMetrics metrics;
  final int cartCount;

  const ReviewTopBar({super.key, required this.metrics, required this.cartCount});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final metrics = this.metrics;
    final tapSize = metrics.walletIconBox;

    Widget tappable({required Widget child, required VoidCallback onTap}) =>
        SizedBox(
          width: tapSize,
          height: tapSize,
          child: Material(
            color: Colors.transparent,
            shape: const CircleBorder(),
            clipBehavior: Clip.antiAlias,
            child: InkWell(
              onTap: onTap,
              customBorder: const CircleBorder(),
              child: Center(child: child),
            ),
          ),
        );

    return Padding(
      padding: EdgeInsets.fromLTRB(
        metrics.pageHPad,
        metrics.pageVPad * 0.5,
        metrics.pageHPad,
        metrics.pageVPad * 0.5,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          tappable(
            onTap: () => context.pop(),
            child: Icon(
              Icons.arrow_back_ios_new_rounded,
              size: metrics.backIconSize,
              color: colors.textPrimary,
            ),
          ),

          SizedBox(width: metrics.gapXs),

          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Review & Pay',
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.titleLarge.copyWith(
                    color: colors.textPrimary,
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.w600,
                    fontSize: metrics.pageTitleSize - 4,
                    height: 1.15,
                  ),
                ),
                SizedBox(height: metrics.gapXs * 0.5),
                Text(
                  'Review your order details and proceed to payment',
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: colors.textSecondary,
                    fontFamily: 'Inter',
                    fontSize: metrics.pageSubtitleSize,
                    height: 1.25,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
