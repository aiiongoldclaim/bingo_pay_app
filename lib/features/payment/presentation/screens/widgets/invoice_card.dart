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
  });

  final String orderId;
  final String totalAmount;
  final String customerName;
  final String customerAddress;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(AppSizes.paddingMd),
      decoration: BoxDecoration(
        color: ThemeColors.white,
        borderRadius: BorderRadius.circular(AppSizes.radius2Xl),
      ),
      child: Column(
        children: [
          _buildHeader(),

          const Divider(),

          _buildCustomerInfo(),

          const Divider(),

          const Padding(
            padding: EdgeInsets.all(AppSizes.paddingMd),
            child: Column(
              children: [
                InvoiceItemTile(
                  title: 'Aurora Pro Wireless Headphones',
                  subtitle: 'Qty 1 • incl. 18% GST',
                  price: '₹18,990',
                ),

                InvoiceItemTile(
                  title: 'Velvet Runner Knit Sneakers',
                  subtitle: 'Qty 1 • incl. 18% GST',
                  price: '₹6,490',
                ),

                InvoiceItemTile(
                  title: 'Nimbus Smart Desk Lamp',
                  subtitle: 'Qty 1 • incl. 18% GST',
                  price: '₹3,490',
                ),
              ],
            ),
          ),

          const Divider(),

          _buildSummary(),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.all(AppSizes.paddingMd),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('BINGO Pay', style: AppTextStyles.titleLarge),

                const SizedBox(height: 4),

                Text(
                  'Tax Invoice • GSTIN 27ABCDE1234F1Z5',
                  style: AppTextStyles.bodySmall,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),

          const SizedBox(width: 12),

          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text('Invoice no.', style: AppTextStyles.labelMedium),

              Text(
                'INV-${orderId.replaceAll('BG-', '')}',
                style: AppTextStyles.titleMedium,
              ),

              Text('12 Jun 2026', style: AppTextStyles.bodySmall),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCustomerInfo() {
    return Padding(
      padding: const EdgeInsets.all(AppSizes.paddingMd),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('BILLED TO', style: AppTextStyles.labelMedium),

          const SizedBox(height: 8),

          Text(customerName, style: AppTextStyles.titleMedium),

          const SizedBox(height: 4),

          Text(customerAddress, style: AppTextStyles.bodyMedium),
        ],
      ),
    );
  }

  Widget _buildSummary() {
    return Padding(
      padding: const EdgeInsets.all(AppSizes.paddingMd),
      child: Column(
        children: [
          _summaryRow('Subtotal', '₹28,980'),

          _summaryRow('Discount & coins', '- ₹6,338', color: ThemeColors.green),

          _summaryRow('Delivery', 'FREE', color: ThemeColors.green),

          const Divider(height: 28),

          _summaryRow('Amount paid', totalAmount, isBold: true),
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
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: isBold
                ? AppTextStyles.titleMedium
                : AppTextStyles.bodyMedium,
          ),
          Text(
            value,
            style: isBold
                ? AppTextStyles.titleLarge
                : AppTextStyles.bodyMedium.copyWith(color: color),
          ),
        ],
      ),
    );
  }
}
