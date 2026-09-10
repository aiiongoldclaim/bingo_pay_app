import 'package:flutter/material.dart';

import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/theme/app_theme_colors.dart';
import 'review_payment_metrics.dart';

// ── Merchant ───────────────────────────────────────────────────────────────
class ReviewPaymentMerchantCard extends StatelessWidget {
  final ReviewPaymentMetrics metrics;
  final String name;
  final String email;
  final String initials;

  const ReviewPaymentMerchantCard({
    super.key,
    required this.metrics,
    required this.name,
    required this.email,
    required this.initials,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.c;
    final m = metrics;

    return Container(
      padding: EdgeInsets.all(m.cardPad),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(m.cardRadius),
        border: Border.all(color: colors.border, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
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

              SizedBox(width: m.cardPad * 0.7),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.titleMedium.copyWith(
                        color: colors.textPrimary,
                        fontFamily: 'Inter',
                        fontWeight: FontWeight.w700,
                        fontSize: m.merchantNameSize,
                        height: 1.25,
                      ),
                    ),
                    SizedBox(height: m.gapXs),
                    Text(
                      email,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: colors.textSecondary,
                        fontFamily: 'Inter',
                        fontSize: m.merchantIdSize,
                        height: 1.3,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          SizedBox(height: m.gapMd),

          Row(
            children: [
              _Chip(
                metrics: m,
                icon: Icons.verified_rounded,
                label: 'Verified Merchant',
              ),
              SizedBox(width: m.gapSm),
              _Chip(
                metrics: m,
                icon: Icons.bolt_rounded,
                label: 'Instant Transfer',
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  final ReviewPaymentMetrics metrics;
  final IconData icon;
  final String label;

  const _Chip({
    required this.metrics,
    required this.icon,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.c;
    final m = metrics;

    return Flexible(
      child: Container(
        height: m.chipHeight,
        padding: EdgeInsets.symmetric(horizontal: m.gapSm * 1.1),
        decoration: BoxDecoration(
          color: colors.brandSoft,
          borderRadius: BorderRadius.circular(m.chipHeight),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: m.chipFontSize + 4, color: colors.brand),
            SizedBox(width: m.gapXs * 1.2),
            Flexible(
              child: Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppTextStyles.labelMedium.copyWith(
                  color: colors.brand,
                  fontFamily: 'Inter',
                  fontWeight: FontWeight.w600,
                  fontSize: m.chipFontSize,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
