import 'package:flutter/material.dart';

import '../../data/models/product_model.dart';
import 'home_metrics.dart';
import 'product_card.dart';
import 'section_header.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../wishlist/presentation/cubit/wishlist_cubit.dart';
import '../../../wishlist/presentation/cubit/wishlist_state.dart';

class ProductRail extends StatelessWidget {
  const ProductRail({
    super.key,
    required this.metrics,
    required this.title,
    required this.products,
    this.actionText,
    this.onActionTap,
    this.onProductTap,
    this.onWishlistTap,
    this.onAddToCart,
    this.addingIds = const {},
  });

  final HomeMetrics metrics;
  final String title;
  final List<ProductModel> products;
  final String? actionText;
  final VoidCallback? onActionTap;
  final ValueChanged<ProductModel>? onProductTap;
  final ValueChanged<ProductModel>? onWishlistTap;
  final ValueChanged<ProductModel>? onAddToCart;
  final Set<String> addingIds;

  @override
  Widget build(BuildContext context) {
    if (products.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: metrics.pagePadding),
          child: SectionHeader(
            metrics: metrics,
            title: title,
            actionText: actionText,
            onActionTap: onActionTap,
          ),
        ),
        SizedBox(height: metrics.pagePadding * 0.8),
        SizedBox(
          height: metrics.productCardHeight,
          // Wishlist change pe sirf ye rail rebuild hogi, poora screen nahi
          child: BlocBuilder<WishlistCubit, WishlistState>(
            builder: (context, wishlistState) {
              return ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: EdgeInsets.symmetric(horizontal: metrics.pagePadding),
                itemCount: products.length,
                separatorBuilder: (_, __) =>
                    SizedBox(width: metrics.pagePadding * 0.7),
                itemBuilder: (_, i) {
                  final p = products[i];
                  return ProductCard(
                    metrics: metrics,
                    product: p,
                    isWishlisted:
                        p.uuid != null &&
                        wishlistState.items.any((e) => e.id == p.uuid),
                    isAddingToCart: p.uuid != null && addingIds.contains(p.uuid),
                    onTap: () => onProductTap?.call(p),
                    onWishlistTap: p.uuid == null
                        ? null
                        : () => onWishlistTap?.call(p),
                    onAddToCart: p.variantUuid == null
                        ? null
                        : () => onAddToCart?.call(p),
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }
}
