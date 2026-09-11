import 'package:flutter/material.dart';

import '../../../../../core/theme/app_text_styles.dart';
import '../../../../../core/theme/app_theme_colors.dart';
import '../../../../cart/domain/entities/cart_item_entity.dart';
import 'review_pay_metrics.dart';
import 'review_pay_widgets.dart';

// ── Order summary ──────────────────────────────────────────────────────────
class ReviewOrderSummaryCard extends StatelessWidget {
  final ReviewPayMetrics metrics;
  final String productName;
  final List<CartItemEntity> cartItems;
  final String itemTotal;
  final String savings;
  final String delivery;
  final String tax;
  final String total;

  const ReviewOrderSummaryCard({
    super.key,
    required this.metrics,
    required this.productName,
    required this.cartItems,
    required this.itemTotal,
    required this.savings,
    required this.delivery,
    required this.tax,
    required this.total,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.c;
    final m = metrics;

    return ReviewCard(
      metrics: m,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          if (cartItems.isNotEmpty) ...[
            ...cartItems.map(
              (item) => Padding(
                padding: EdgeInsets.only(bottom: m.gapMd),
                child: Row(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(m.cardRadius * 0.6),
                      child: Container(
                        width: m.thumbSize,
                        height: m.thumbSize,
                        color: colors.surfaceAlt,
                        child: item.product.thumbnail != null
                            ? Image.network(
                                item.product.thumbnail!,
                                fit: BoxFit.cover,
                                errorBuilder: (_, __, ___) => Icon(
                                  Icons.shopping_bag_outlined,
                                  size: m.thumbSize * 0.4,
                                  color: colors.brand,
                                ),
                              )
                            : Icon(
                                Icons.shopping_bag_outlined,
                                size: m.thumbSize * 0.4,
                                color: colors.brand,
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
                            item.product.title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: AppTextStyles.labelLarge.copyWith(
                              color: colors.textPrimary,
                              fontFamily: 'Inter',
                              fontWeight: FontWeight.w600,
                              fontSize: m.itemTitleSize,
                              height: 1.3,
                            ),
                          ),
                          SizedBox(height: m.gapXs * 0.6),
                          Text(
                            'Qty: ${item.quantity}',
                            style: AppTextStyles.bodySmall.copyWith(
                              color: colors.textSecondary,
                              fontFamily: 'Inter',
                              fontSize: m.itemMetaSize,
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(width: m.gapSm),
                    Text(
                      '\$${item.totalPrice.toStringAsFixed(0)}',
                      style: AppTextStyles.titleMedium.copyWith(
                        color: colors.textPrimary,
                        fontFamily: 'Inter',
                        fontWeight: FontWeight.w700,
                        fontSize: m.itemTitleSize,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Divider(height: 1, thickness: 1, color: colors.border),
            SizedBox(height: m.gapMd),
          ] else if (productName.isNotEmpty) ...[
            Text(
              productName,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppTextStyles.labelLarge.copyWith(
                color: colors.textPrimary,
                fontFamily: 'Inter',
                fontWeight: FontWeight.w600,
                fontSize: m.itemTitleSize,
              ),
            ),
            SizedBox(height: m.gapMd),
            Divider(height: 1, thickness: 1, color: colors.border),
            SizedBox(height: m.gapMd),
          ],

          ReviewRow(metrics: m, label: 'Item Total', value: itemTotal),
          SizedBox(height: m.gapSm),
          ReviewRow(
            metrics: m,
            label: 'Savings',
            value: savings,
            valueColor: colors.statusSuccess,
          ),
          SizedBox(height: m.gapSm),
          ReviewRow(
            metrics: m,
            label: 'Delivery',
            value: delivery,
            valueColor: colors.statusSuccess,
          ),
          SizedBox(height: m.gapSm),
          ReviewRow(metrics: m, label: 'Taxes & Fees', value: tax),

          Padding(
            padding: EdgeInsets.symmetric(vertical: m.gapMd * 0.8),
            child: Divider(height: 1, thickness: 1, color: colors.border),
          ),

          ReviewRow(
            metrics: m,
            label: 'Total Amount',
            value: total,
            isTotal: true,
          ),
        ],
      ),
    );
  }
}
