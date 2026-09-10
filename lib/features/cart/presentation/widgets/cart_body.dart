import 'package:flutter/material.dart';

import '../../domain/entities/cart_item_entity.dart';
import '../cubit/cart_cubit.dart';
import '../cubit/cart_state.dart';
import 'cart_bottom_bar.dart';
import 'cart_items_card.dart';
import 'cart_metrics.dart';
import 'cart_title_block.dart';
import 'coupon_card.dart';
import 'delivery_banner.dart';
import 'price_details.dart';

// ── Portrait / phone ──────────────────────────────────────────────────────
class CartPortraitBody extends StatelessWidget {
  final CartState state;
  final CartCubit cubit;
  final CartMetrics metrics;
  final Set<int> deselected;
  final double selectedTotal;
  final int selectedCount;
  final void Function(CartItemEntity) onToggleSelect;
  final void Function(CartItemEntity) onMoveToWishlist;
  final VoidCallback onMoveAll;

  const CartPortraitBody({
    super.key,
    required this.state,
    required this.cubit,
    required this.metrics,
    required this.deselected,
    required this.selectedTotal,
    required this.selectedCount,
    required this.onToggleSelect,
    required this.onMoveToWishlist,
    required this.onMoveAll,
  });

  @override
  Widget build(BuildContext context) {
    final m = metrics;

    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: EdgeInsets.fromLTRB(m.pageHPad, m.gapXs, m.pageHPad, m.gapLg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          CartTitleBlock(
            metrics: m,
            totalItems: state.totalItems,
            onMoveAll: onMoveAll,
          ),
          SizedBox(height: m.gapMd),
          const FreeDeliveryBanner(),
          SizedBox(height: m.gapMd),
          CartItemsCard(
            items: state.items,
            deselectedIds: deselected,
            pendingItemIds: state.pendingItemIds,
            onToggleSelect: onToggleSelect,
            onMoveToWishlist: onMoveToWishlist,
            onIncrease: cubit.increaseQuantity,
            onDecrease: cubit.decreaseQuantity,
            onDelete: (item) => cubit.removeItem(item.id),
          ),
          SizedBox(height: m.gapMd),
          const CartCouponCard(),
          SizedBox(height: m.gapMd),
          PriceDetailsCard(subtotal: selectedTotal, itemCount: selectedCount),
        ],
      ),
    );
  }
}

// ── Tablet landscape ──────────────────────────────────────────────────────
class CartLandscapeBody extends StatelessWidget {
  final CartState state;
  final CartCubit cubit;
  final CartMetrics metrics;
  final Set<int> deselected;
  final double selectedTotal;
  final int selectedCount;
  final List<CartItemEntity> selectedItems;
  final void Function(CartItemEntity) onToggleSelect;
  final void Function(CartItemEntity) onMoveToWishlist;
  final VoidCallback onMoveAll;

  const CartLandscapeBody({
    super.key,
    required this.state,
    required this.cubit,
    required this.metrics,
    required this.deselected,
    required this.selectedTotal,
    required this.selectedCount,
    required this.selectedItems,
    required this.onToggleSelect,
    required this.onMoveToWishlist,
    required this.onMoveAll,
  });

  @override
  Widget build(BuildContext context) {
    final m = metrics;

    return Padding(
      padding: EdgeInsets.fromLTRB(m.pageHPad, m.gapSm, m.pageHPad, 0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: EdgeInsets.only(bottom: m.gapLg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  CartTitleBlock(
                    metrics: m,
                    totalItems: state.totalItems,
                    onMoveAll: onMoveAll,
                  ),
                  SizedBox(height: m.gapMd),
                  const FreeDeliveryBanner(),
                  SizedBox(height: m.gapMd),
                  CartItemsCard(
                    items: state.items,
                    deselectedIds: deselected,
                    pendingItemIds: state.pendingItemIds,
                    onToggleSelect: onToggleSelect,
                    onMoveToWishlist: onMoveToWishlist,
                    onIncrease: cubit.increaseQuantity,
                    onDecrease: cubit.decreaseQuantity,
                    onDelete: (CartItemEntity item) {},
                  ),
                ],
              ),
            ),
          ),

          SizedBox(width: m.gapLg),

          SizedBox(
            width: m.railWidth,
            child: SingleChildScrollView(
              padding: EdgeInsets.only(top: m.gapSm, bottom: m.gapLg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const CartCouponCard(),
                  SizedBox(height: m.gapMd),
                  PriceDetailsCard(
                    subtotal: selectedTotal,
                    itemCount: selectedCount,
                  ),
                  SizedBox(height: m.gapMd),
                  CartPayButton(
                    items: selectedItems,
                    total: selectedTotal,
                    itemCount: selectedCount,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
