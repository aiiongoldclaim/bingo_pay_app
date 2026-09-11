import 'package:flutter/material.dart';

import '../../../../../core/theme/app_text_styles.dart';
import '../../../../../core/theme/app_theme_colors.dart';
import '../../../../cart/domain/entities/cart_item_entity.dart';
import 'payment_metrics.dart';

// ── Order Summary (cart list + total) ──────────────────────────────────────
class PaymentOrderSummaryCard extends StatelessWidget {
  final PaymentMetrics metrics;
  final bool isCart;
  final List<CartItemEntity> items;
  final String productName;
  final double total;

  const PaymentOrderSummaryCard({
    super.key,
    required this.metrics,
    required this.isCart,
    required this.items,
    required this.productName,
    required this.total,
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
            'Order Summary',
            style: AppTextStyles.titleMedium.copyWith(
              color: colors.textPrimary,
              fontFamily: 'Inter',
              fontWeight: FontWeight.w700,
              fontSize: m.sectionTitleSize,
            ),
          ),

          SizedBox(height: m.gapMd),

          if (isCart)
            ...items.map(
              (item) => Padding(
                padding: EdgeInsets.only(bottom: m.gapSm),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        '${item.product.title} × ${item.quantity}',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: colors.textSecondary,
                          fontFamily: 'Inter',
                          fontSize: m.summaryLabelSize,
                        ),
                      ),
                    ),
                    SizedBox(width: m.gapSm),
                    Text(
                      '\$${item.totalPrice.toStringAsFixed(2)}',
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: colors.textPrimary,
                        fontFamily: 'Inter',
                        fontWeight: FontWeight.w600,
                        fontSize: m.summaryValueSize,
                      ),
                    ),
                  ],
                ),
              ),
            )
          else
            Padding(
              padding: EdgeInsets.only(bottom: m.gapSm),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      productName.isNotEmpty ? productName : 'Product',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: colors.textSecondary,
                        fontFamily: 'Inter',
                        fontSize: m.summaryLabelSize,
                      ),
                    ),
                  ),
                  SizedBox(width: m.gapSm),
                  Text(
                    '\$${total.toStringAsFixed(2)}',
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: colors.textPrimary,
                      fontFamily: 'Inter',
                      fontWeight: FontWeight.w600,
                      fontSize: m.summaryValueSize,
                    ),
                  ),
                ],
              ),
            ),

          Padding(
            padding: EdgeInsets.only(bottom: m.gapSm),
            child: Row(
              children: [
                Expanded(
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Flexible(
                        child: Text(
                          'Shipping Fee',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppTextStyles.bodyMedium.copyWith(
                            color: colors.textSecondary,
                            fontFamily: 'Inter',
                            fontSize: m.summaryLabelSize,
                          ),
                        ),
                      ),
                      SizedBox(width: m.gapXs),
                      Icon(
                        Icons.info_outline_rounded,
                        size: m.summaryLabelSize + 2,
                        color: colors.textMuted,
                      ),
                    ],
                  ),
                ),
                SizedBox(width: m.gapSm),
                Text(
                  'FREE',
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: colors.statusSuccess,
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.w600,
                    fontSize: m.summaryValueSize,
                  ),
                ),
              ],
            ),
          ),

          Padding(
            padding: EdgeInsets.symmetric(vertical: m.gapSm * 0.6),
            child: Divider(height: 1, thickness: 1, color: colors.border),
          ),

          Row(
            children: [
              Expanded(
                child: Text(
                  'Total Amount',
                  style: AppTextStyles.titleMedium.copyWith(
                    color: colors.textPrimary,
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.w700,
                    fontSize: m.totalLabelSize,
                  ),
                ),
              ),
              Text(
                '\$${total.toStringAsFixed(2)}',
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
