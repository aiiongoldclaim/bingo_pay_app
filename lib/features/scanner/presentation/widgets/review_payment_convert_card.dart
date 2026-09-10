import 'package:flutter/material.dart';

import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/theme/app_theme_colors.dart';
import 'review_payment_metrics.dart';

// ── Convert ────────────────────────────────────────────────────────────────
class ReviewPaymentConvertCard extends StatelessWidget {
  final ReviewPaymentMetrics metrics;
  final double usdValue;
  final double bigodValue;
  final VoidCallback onSwap;

  const ReviewPaymentConvertCard({
    super.key,
    required this.metrics,
    required this.usdValue,
    required this.bigodValue,
    required this.onSwap,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.c;
    final m = metrics;

    return Container(
      padding: EdgeInsets.all(m.cardPad),
      decoration: BoxDecoration(
        color: colors.brandSoft,
        borderRadius: BorderRadius.circular(m.cardRadius),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Convert to BIGOD',
            style: AppTextStyles.labelLarge.copyWith(
              color: colors.brand,
              fontFamily: 'Inter',
              fontWeight: FontWeight.w700,
              fontSize: m.bannerTitleSize,
            ),
          ),

          SizedBox(height: m.gapMd),

          Row(
            children: [
              Expanded(
                child: _ConvertBox(
                  metrics: m,
                  label: 'USD',
                  value: usdValue.toStringAsFixed(2),
                  badge: Container(
                    width: m.coinBadge,
                    height: m.coinBadge,
                    decoration: BoxDecoration(
                      color: colors.statusInfo,
                      shape: BoxShape.circle,
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      '\$',
                      style: AppTextStyles.labelLarge.copyWith(
                        color: colors.surface,
                        fontFamily: 'Inter',
                        fontWeight: FontWeight.w800,
                        fontSize: m.convertLabelSize + 2,
                      ),
                    ),
                  ),
                ),
              ),

              SizedBox(width: m.gapSm),

              Material(
                color: colors.surface,
                shape: const CircleBorder(),
                clipBehavior: Clip.antiAlias,
                child: InkWell(
                  onTap: onSwap,
                  child: SizedBox(
                    width: m.swapBtnSize,
                    height: m.swapBtnSize,
                    child: Icon(
                      Icons.swap_horiz_rounded,
                      size: m.swapBtnSize * 0.5,
                      color: colors.brand,
                    ),
                  ),
                ),
              ),

              SizedBox(width: m.gapSm),

              Expanded(
                child: _ConvertBox(
                  metrics: m,
                  label: 'BIGOD',
                  value: bigodValue.toStringAsFixed(8),
                  badge: Container(
                    width: m.coinBadge,
                    height: m.coinBadge,
                    decoration: BoxDecoration(
                      color: colors.brand,
                      shape: BoxShape.circle,
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      'B',
                      style: AppTextStyles.labelLarge.copyWith(
                        color: const Color(0xFFF7A928),
                        fontFamily: 'Inter',
                        fontWeight: FontWeight.w800,
                        fontSize: m.convertLabelSize + 2,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),

          SizedBox(height: m.gapSm),

          Row(
            children: [
              Icon(
                Icons.info_outline_rounded,
                size: m.rateSize + 3,
                color: colors.textMuted,
              ),
              SizedBox(width: m.gapXs),
              Expanded(
                child: Text(
                  '1 USD = 0.00001772 BIGOD',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.bodySmall.copyWith(
                    color: colors.textSecondary,
                    fontFamily: 'Inter',
                    fontSize: m.rateSize,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ConvertBox extends StatelessWidget {
  final ReviewPaymentMetrics metrics;
  final String label;
  final String value;
  final Widget badge;

  const _ConvertBox({
    required this.metrics,
    required this.label,
    required this.value,
    required this.badge,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.c;
    final m = metrics;

    return Container(
      height: m.convertBoxHeight,
      padding: EdgeInsets.symmetric(horizontal: m.cardPad * 0.6),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(m.cardRadius * 0.75),
      ),
      child: Row(
        children: [
          badge,
          SizedBox(width: m.gapSm * 0.8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  label,
                  style: AppTextStyles.bodySmall.copyWith(
                    color: colors.textSecondary,
                    fontFamily: 'Inter',
                    fontSize: m.convertLabelSize,
                    height: 1.2,
                  ),
                ),
                SizedBox(height: m.gapXs * 0.5),
                FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: Text(
                    value,
                    style: AppTextStyles.titleMedium.copyWith(
                      color: colors.textPrimary,
                      fontFamily: 'Inter',
                      fontWeight: FontWeight.w700,
                      fontSize: m.convertValueSize,
                      height: 1.2,
                    ),
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
