import 'package:flutter/material.dart';

import '../../../../../core/constants/app_sizes.dart';
import '../../../../../core/theme/app_text_styles.dart';
import '../../../../../core/theme/theme_colors.dart';
import 'invoice_item_tile.dart';

class InvoiceCard extends StatelessWidget {
  const InvoiceCard({
    super.key,
    required this.orderId,
    required this.totalAmount,
    required this.customerName,
    required this.customerAddress,
    this.productName = '',
    this.deliveryCharge = 0.0,
  });

  final String orderId;
  final String totalAmount;
  final String productName;
  final String customerName;
  final String customerAddress;
  final double deliveryCharge;

  static String _month(int m) {
    const months = [
      'Jan','Feb','Mar','Apr','May','Jun',
      'Jul','Aug','Sep','Oct','Nov','Dec'
    ];
    return months[m - 1];
  }

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final dateStr = '${now.day} ${_month(now.month)} ${now.year}';

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: AppSizes.paddingMd),
      decoration: BoxDecoration(
        color: ThemeColors.white,
        borderRadius: BorderRadius.circular(AppSizes.radius2Xl),
        boxShadow: [
          BoxShadow(
            color: ThemeColors.deepPurple.withValues(alpha: 0.18),
            blurRadius: 32,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          // ── Gradient header ─────────────────────────────────────────
          Container(
            padding: const EdgeInsets.all(AppSizes.paddingMd),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF4C1E76), Color(0xFF3F185F)],
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
              ),
              borderRadius: BorderRadius.vertical(
                  top: Radius.circular(AppSizes.radius2Xl)),
            ),
            child: Row(
              children: [
                Container(
                  height: 46,
                  width: 46,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.18),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.store_rounded,
                      color: Colors.white, size: 24),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Bingold Pay',
                        style: AppTextStyles.titleMedium
                            .copyWith(color: Colors.white),
                      ),
                          Text(
                            'Invoice INV-${orderId.replaceAll('BG-', '')}',
                            style: AppTextStyles.labelLarge
                                .copyWith(color: Colors.white),
                          ),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Tax Invoice',
                            style: AppTextStyles.bodyMedium.copyWith(
                                color: Colors.white.withValues(alpha: 0.75)),
                          ),

                              Text(
                                dateStr,
                                style: AppTextStyles.bodyMedium.copyWith(
                                    color: Colors.white.withValues(alpha: 0.75)),
                              ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // ── Billed To ───────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.all(AppSizes.paddingMd),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1A1D4E).withValues(alpha: 0.07),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.location_on_outlined,
                      size: 18, color: ThemeColors.black),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('BILLED TO',
                          style: AppTextStyles.labelMedium
                              .copyWith(color: ThemeColors.black)),
                      const SizedBox(height: 4),
                      Text(customerName,
                          style: AppTextStyles.titleMedium),
                      if (customerAddress.isNotEmpty) ...[
                        const SizedBox(height: 2),
                        Text(customerAddress,
                            style: AppTextStyles.bodyMedium
                                .copyWith(color: ThemeColors.inkMid)),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSizes.paddingMd),
            child: Divider(height: 1, color: ThemeColors.inkMid.withValues(alpha: 0.25)),
          ),

          // ── Item ────────────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSizes.paddingMd, vertical: AppSizes.paddingX),
            child: InvoiceItemTile(
              title: productName.isNotEmpty ? productName : 'Product',
              subtitle: 'Qty 1 • incl. GST',
              price: totalAmount,
            ),
          ),

          // ── Summary ─────────────────────────────────────────────────
          Padding(
            // padding: const EdgeInsets.all(AppSizes.paddingX),
            padding: const EdgeInsets.symmetric(horizontal: AppSizes.paddingMd, vertical: AppSizes.paddingSm),
            child: Column(
              children: [
                if (deliveryCharge > 0) ...[
                  _summaryRow(
                    'Delivery',
                    '\$${deliveryCharge.toStringAsFixed(0)}',
                    color: ThemeColors.green,
                  ),
                  const SizedBox(height: 8),
                ],
                Divider(
                    height: 1,
                    color: ThemeColors.inkMid.withValues(alpha: 0.25)),
                _summaryRow('Amount paid', totalAmount, isBold: true),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _summaryRow(
    String title,
    String value, {
    Color? color,
    bool isBold = false,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: isBold
              ? AppTextStyles.titleMedium
              : AppTextStyles.bodyMedium
                  .copyWith(color: ThemeColors.inkMid),
        ),
        Text(
          value,
          style: isBold
              ? AppTextStyles.titleLarge.copyWith(
                  color: ThemeColors.green,
                  fontWeight: FontWeight.w800,
                )
              : AppTextStyles.bodyMedium.copyWith(color: color),
        ),
      ],
    );
  }
}
