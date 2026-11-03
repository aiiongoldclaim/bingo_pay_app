import 'package:flutter/material.dart';

import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/theme/app_theme_colors.dart';
import 'review_payment_metrics.dart';

// ── Merchant ───────────────────────────────────────────────────────────────
// Who is being paid: initials, name, and what the shop accepts.
class ReviewPaymentMerchantCard extends StatelessWidget {
  final ReviewPaymentMetrics metrics;
  final String name;
  final String subtitle;
  final String initials;

  const ReviewPaymentMerchantCard({
    super.key,
    required this.metrics,
    required this.name,
    required this.subtitle,
    required this.initials,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final m = metrics;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: m.merchantAvatar,
          height: m.merchantAvatar,
          decoration: BoxDecoration(
            color: colors.brandSoft,
            shape: BoxShape.circle,
          ),
          alignment: Alignment.center,
          child: Text(
            initials,
            style: AppTextStyles.titleLarge.copyWith(
              color: colors.brand,
              fontFamily: 'Inter',
              fontWeight: FontWeight.w700,
              fontSize: m.merchantInitialSize,
            ),
          ),
        ),
        SizedBox(height: m.gapSm),
        Text(
          name,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          textAlign: TextAlign.center,
          style: AppTextStyles.titleMedium.copyWith(
            color: colors.textPrimary,
            fontFamily: 'Inter',
            fontWeight: FontWeight.w700,
            fontSize: m.merchantNameSize,
          ),
        ),
        SizedBox(height: m.gapXs),
        Text(
          subtitle,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          textAlign: TextAlign.center,
          style: AppTextStyles.bodyMedium.copyWith(
            color: colors.textSecondary,
            fontFamily: 'Inter',
            fontSize: m.merchantIdSize,
          ),
        ),
      ],
    );
  }
}
