import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/router/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../../core/widgets/cached_image.dart';
import '../models/product_mock_data.dart';

class ProductCard extends StatelessWidget {
  final Product product;
  final bool isGrid;

  const ProductCard({super.key, required this.product, this.isGrid = false});

  @override
  Widget build(BuildContext context) {
    return isGrid ? _GridCard(product: product) : _ListCard(product: product);
  }
}

class _ListCard extends StatelessWidget {
  final Product product;
  const _ListCard({required this.product});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
      onTap: product.uuid.isEmpty
          ? null
          : () => context.push(AppRoutes.vendorProductDetailPath(product.uuid)),
      child: Container(
        margin: const EdgeInsets.only(bottom: AppDimensions.sm + 4),
        padding: const EdgeInsets.all(AppDimensions.md),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
              child: CachedImage(
                url: product.imageUrl,
                width: 64,
                height: 64,
                errorWidget: const _ImagePlaceholder(size: 64),

              ),
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
                    product.category,
                    style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                  ),
                  const SizedBox(height: 8),
                  _StockPill(stock: product.stock),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _GridCard extends StatelessWidget {
  final Product product;
  const _GridCard({required this.product});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
      onTap: product.uuid.isEmpty
          ? null
          : () => context.push(AppRoutes.vendorProductDetailPath(product.uuid)),
      child: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: 3,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  ClipRRect(
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(AppDimensions.radiusLg)),
                    child: CachedImage(
                      url: product.imageUrl,
                      width: double.infinity,
                      height: double.infinity,
                      errorWidget: const _ImagePlaceholder(),
                    ),
                  ),
                  Positioned(
                    top: AppDimensions.sm,
                    left: AppDimensions.sm,
                    child: _StatusBadge(status: product.status),
                  ),
                ],
              ),
            ),
            Expanded(
              flex: 2,
              child: Padding(
                padding: const EdgeInsets.all(AppDimensions.sm),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      product.name,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      product.category,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(fontSize: 11, color: Colors.grey[500]),
                    ),
                    const Spacer(),
                    _StockPill(stock: product.stock),
                  ],
                ),
              ),
            ),
          ],
        ),
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
      ProductStatus.pending => (const Color(0xFFFFF3CD), const Color(0xFF7D5A00), 'Pending Review'),
      ProductStatus.draft => (const Color(0xFFEDEEF0), const Color(0xFF666666), 'Draft'),
      ProductStatus.archived => (const Color(0xFFEDEEF0), const Color(0xFF666666), 'Archived'),
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
      StockStatusType.inStock => (
        AppColors.successTint,
        const Color(0xFF4C7A2D),
        'In stock',
      ),
      StockStatusType.lowStock => (
        AppColors.warningTint,
        const Color(0xFFB36B00),
        'Low stock: ${stock.lowStockCount} left',
      ),
      StockStatusType.outOfStock => (
        AppColors.errorTint,
        AppColors.error,
        'Out of stock',
      ),
    };
    return _Pill(label: label, background: bg, foreground: fg);
  }
}

class _ImagePlaceholder extends StatelessWidget {
  final double? size;
  const _ImagePlaceholder({this.size});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      color: AppColors.infoTint,
      child: const Icon(Icons.image_outlined, color: AppColors.primary),
    );
  }
}

class _Pill extends StatelessWidget {
  final String label;
  final Color background;
  final Color foreground;

  const _Pill({
    required this.label,
    required this.background,
    required this.foreground,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(AppDimensions.radiusCircular),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: foreground,
          fontWeight: FontWeight.w600,
          fontSize: 12,
        ),
      ),
    );
  }
}
