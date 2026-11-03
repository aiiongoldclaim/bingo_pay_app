import 'package:flutter/material.dart';

import '../../../../core/constants/app_strings.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/theme/app_theme_colors.dart';
import 'cart_metrics.dart';

/// Tax, delivery and fees for the cart, from the same rules checkout uses.
typedef CartCharges = ({double tax, double shipping, double fee});

/// What the customer will pay: items plus charges (just the items until priced).
double cartPayTotal(double subtotal, CartCharges? c) => c == null
    ? subtotal
    : ((subtotal + c.tax + c.shipping + c.fee) * 100).round() / 100;

class PriceDetailsCard extends StatelessWidget {
  final double subtotal;
  final int itemCount;
  final CartCharges? charges; // null until the charge rules have loaded

  const PriceDetailsCard({
    super.key,
    required this.subtotal,
    required this.itemCount,
    this.charges,
  });

  String _fmt(double v) {
    final parts = v.toStringAsFixed(2).split('.');
    final intPart = parts[0];
    final buf = StringBuffer();
    for (int i = 0; i < intPart.length; i++) {
      buf.write(intPart[i]);
      final rem = intPart.length - i - 1;
      if (rem > 0 && rem % 3 == 0) buf.write(',');
    }
    return '${buf.toString()}.${parts[1]}';
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.c;
    final m = CartMetrics.of(context);

    return Container(
      padding: EdgeInsets.all(m.cardPad),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(m.cardRadius),
        border: Border.all(color: colors.border, width: 1),
        boxShadow: colors.isDark
            ? null
            : [
                BoxShadow(
                  color: colors.textPrimary.withValues(alpha: 0.04),
                  blurRadius: 14,
                  offset: const Offset(0, 3),
                ),
              ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            AppStrings.orderSummary,
            style: AppTextStyles.titleMedium.copyWith(
              color: colors.textPrimary,
              fontFamily: 'Inter',
              fontWeight: FontWeight.w700,
              fontSize: m.summaryTitleSize,
            ),
          ),

          SizedBox(height: m.gapMd),

          _Row(
            label: AppStrings.bagTotal(itemCount),
            value: '\$${_fmt(subtotal)}',
            metrics: m,
          ),
          _Row(
            label: AppStrings.shippingFee,
            value: charges == null
                ? AppStrings.atCheckout
                : charges!.shipping == 0
                ? AppStrings.free
                : '\$${_fmt(charges!.shipping)}',
            valueColor: charges?.shipping == 0 ? colors.statusSuccess : null,
            metrics: m,
            trailingInfo: true,
          ),
          if (charges != null && charges!.tax + charges!.fee > 0)
            _Row(
              label: AppStrings.taxesAndFees,
              value: '\$${_fmt(charges!.tax + charges!.fee)}',
              metrics: m,
            ),

          Padding(
            padding: EdgeInsets.symmetric(vertical: m.gapSm * 0.6),
            child: Divider(height: 1, thickness: 1, color: colors.border),
          ),

          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: Text(
                  AppStrings.totalAmount,
                  style: AppTextStyles.titleMedium.copyWith(
                    color: colors.textPrimary,
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.w700,
                    fontSize: m.totalLabelSize,
                  ),
                ),
              ),
              Text(
                '\$${_fmt(cartPayTotal(subtotal, charges))}',
                textAlign: TextAlign.right,
                style: AppTextStyles.titleLarge.copyWith(
                  color: colors.brand,
                  fontFamily: 'Inter',
                  fontWeight: FontWeight.w800,
                  fontSize: m.totalValueSize,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _Row extends StatelessWidget {
  final String label;
  final String value;
  final Color? valueColor;
  final CartMetrics metrics;
  final bool trailingInfo;

  const _Row({
    required this.label,
    required this.value,
    this.valueColor,
    required this.metrics,
    this.trailingInfo = false,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.c;
    final m = metrics;

    return Padding(
      padding: EdgeInsets.only(bottom: m.gapSm),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [

          Expanded(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Flexible(
                  child: Text(
                    label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: colors.textSecondary,
                      fontFamily: 'Inter',
                      fontSize: m.summaryLabelSize,
                    ),
                  ),
                ),
                if (trailingInfo) ...[
                  SizedBox(width: m.gapXs),
                  Icon(
                    Icons.info_outline_rounded,
                    size: m.summaryLabelSize + 2,
                    color: colors.textMuted,
                  ),
                ],
              ],
            ),
          ),

          SizedBox(width: m.gapSm),

          Text(
            value,
            textAlign: TextAlign.right,
            style: AppTextStyles.bodyMedium.copyWith(
              color: valueColor ?? colors.textPrimary,
              fontFamily: 'Inter',
              fontWeight: FontWeight.w600,
              fontSize: m.summaryValueSize,
            ),
          ),
        ],
      ),
    );
  }
}
