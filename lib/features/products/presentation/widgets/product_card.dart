import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../models/product_mock_data.dart';

class ProductCard extends StatelessWidget {
  final Product product;

  const ProductCard({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    final currency = NumberFormat.currency(locale: 'en_IN', symbol: '₹', decimalDigits: 0);

    return Container(
      margin: const EdgeInsets.only(bottom: AppDimensions.sm + 4),
      padding: const EdgeInsets.all(AppDimensions.md),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8, offset: const Offset(0, 2)),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: AppColors.infoTint,
              borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
            ),
            child: const Icon(Icons.image_outlined, color: AppColors.primary),
          ),
          const SizedBox(width: AppDimensions.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        product.name,
                        style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
                      ),
                    ),
                    const SizedBox(width: 8),
                    _StatusBadge(status: product.status),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  '${product.sku} · ${product.category}',
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),
                const SizedBox(height: 8),
                if (product.price != null) ...[
                  Row(
                    children: [
                      Text(
                        currency.format(product.price),
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey[500],
                          decoration: product.discountPercent != null ? TextDecoration.lineThrough : null,
                        ),
                      ),
                      if (product.discountPercent != null) ...[
                        const SizedBox(width: 8),
                        _Pill(
                          label: '${product.discountPercent}% off',
                          background: AppColors.errorTint,
                          foreground: AppColors.error,
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 8),
                ],
                _StockPill(stock: product.stock),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final ProductStatus status;

  const _StatusBadge({required this.status});

  @override
  Widget build(BuildContext context) {
    final (bg, fg, label) = switch (status) {
      ProductStatus.active => (AppColors.successTint, const Color(0xFF4C7A2D), 'Active'),
      ProductStatus.draft => (const Color(0xFFEDEEF0), Colors.grey[700]!, 'Draft'),
      ProductStatus.archived => (const Color(0xFFEDEEF0), Colors.grey[700]!, 'Archived'),
    };
    return _Pill(label: label, background: bg, foreground: fg);
  }
}

class _StockPill extends StatelessWidget {
  final StockInfo stock;

  const _StockPill({required this.stock});

  @override
  Widget build(BuildContext context) {
    final (bg, fg, label) = switch (stock.type) {
      StockStatusType.inStock => (AppColors.successTint, const Color(0xFF4C7A2D), 'In stock'),
      StockStatusType.lowStock => (
          AppColors.warningTint,
          const Color(0xFFB36B00),
          'Low stock: ${stock.lowStockCount} left',
        ),
      StockStatusType.outOfStock => (AppColors.errorTint, AppColors.error, 'Out of stock'),
    };
    return _Pill(label: label, background: bg, foreground: fg);
  }
}

class _Pill extends StatelessWidget {
  final String label;
  final Color background;
  final Color foreground;

  const _Pill({required this.label, required this.background, required this.foreground});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(color: background, borderRadius: BorderRadius.circular(AppDimensions.radiusCircular)),
      child: Text(label, style: TextStyle(color: foreground, fontWeight: FontWeight.w600, fontSize: 12)),
    );
  }
}
