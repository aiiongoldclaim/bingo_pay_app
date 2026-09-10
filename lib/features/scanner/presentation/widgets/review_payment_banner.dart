import 'package:flutter/material.dart';

import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/theme/app_theme_colors.dart';
import 'review_payment_metrics.dart';

// ── Secure banner ──────────────────────────────────────────────────────────
class ReviewPaymentSecureBanner extends StatelessWidget {
  final ReviewPaymentMetrics metrics;

  const ReviewPaymentSecureBanner({super.key, required this.metrics});

  @override
  Widget build(BuildContext context) {
    final colors = context.c;
    final m = metrics;

    return Container(
      padding: EdgeInsets.all(m.cardPad * 0.85),
      decoration: BoxDecoration(
        color: colors.brandSoft,
        borderRadius: BorderRadius.circular(m.cardRadius),
      ),
      child: Row(
        children: [
          Container(
            width: m.bannerIconBox,
            height: m.bannerIconBox,
            decoration: BoxDecoration(
              color: colors.surface.withValues(alpha: colors.isDark ? 0.10 : 0.7),
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: Icon(
              Icons.lock_outline_rounded,
              size: m.bannerIconSize,
              color: colors.brand,
            ),
          ),

          SizedBox(width: m.cardPad * 0.7),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Your payments are 100% safe and secure',
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.labelLarge.copyWith(
                    color: colors.brand,
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.w700,
                    fontSize: m.bannerTitleSize,
                    height: 1.3,
                  ),
                ),
                SizedBox(height: m.gapXs * 0.6),
                Text(
                  '256-bit encrypted transactions',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: colors.textSecondary,
                    fontFamily: 'Inter',
                    fontSize: m.bannerSubSize,
                    height: 1.3,
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
