import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../../core/router/app_routes.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_dimensions.dart';
import '../../../../../core/widgets/app_button.dart';
import '../../domain/entities/cart_item.dart';
import '../bloc/shop_bloc.dart';
import '../bloc/shop_event.dart';
import '../bloc/shop_state.dart';
import '../widgets/shop_widgets.dart';

class CartScreen extends StatelessWidget {
  const CartScreen({super.key});

  void _openProduct(BuildContext context, String productId) {
    context.read<ShopBloc>().add(ShopProductViewed(productId));
    context.go(AppRoutes.buyerProductPath(productId));
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ShopBloc, ShopState>(
      builder: (context, state) {
        if (state.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(
              AppDimensions.lg,
              AppDimensions.md,
              AppDimensions.lg,
              AppDimensions.md,
            ),
            child: state.cartItems.isEmpty
                ? ShopEmptyState(
                    icon: Icons.shopping_bag_outlined,
                    title: 'Your cart is empty',
                    message:
                        'Add products from the catalog or a product detail page to build your order.',
                    actionLabel: 'Start shopping',
                    onAction: () => context.go(AppRoutes.buyerCatalog),
                  )
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _CartHeader(
                        itemCount: state.cartCount,
                        onCatalog: () => context.go(AppRoutes.buyerCatalog),
                        onCheckout: () => context.go(AppRoutes.buyerCheckout),
                      ),
                      const SizedBox(height: AppDimensions.lg),
                      Expanded(
                        child: ListView(
                          children: [
                            ...state.cartItems.map(
                              (item) => Padding(
                                padding: const EdgeInsets.only(
                                  bottom: AppDimensions.md,
                                ),
                                child: _CartItemTile(
                                  item: item,
                                  onTap: () => _openProduct(context, item.product.id),
                                  onIncrease: () => context
                                      .read<ShopBloc>()
                                      .add(ShopQuantityIncreased(item.product.id)),
                                  onDecrease: () => context
                                      .read<ShopBloc>()
                                      .add(ShopQuantityDecreased(item.product.id)),
                                  onRemove: () => context
                                      .read<ShopBloc>()
                                      .add(ShopItemRemoved(item.product.id)),
                                  onSaveForLater: () => context
                                      .read<ShopBloc>()
                                      .add(ShopSaveForLaterToggled(item.product.id)),
                                ),
                              ),
                            ),
                            if (state.savedForLaterProducts.isNotEmpty) ...[
                              const SizedBox(height: AppDimensions.lg),
                              ShopSectionHeader(
                                title: 'Saved for later',
                                subtitle: 'Products you may want to revisit.',
                              ),
                              const SizedBox(height: AppDimensions.sm),
                              ...state.savedForLaterProducts.map(
                                (product) => Padding(
                                  padding: const EdgeInsets.only(
                                    bottom: AppDimensions.md,
                                  ),
                                  child: ShopProductCard(
                                    product: product,
                                    compact: true,
                                    showCategoryPill: true,
                                    onTap: () => context
                                        .read<ShopBloc>()
                                        .add(ShopAddToCartRequested(product.id)),
                                  ),
                                ),
                              ),
                            ],
                            const SizedBox(height: AppDimensions.lg),
                            _CartSummaryCard(
                              state: state,
                              onApplyPromo: (code) => context
                                  .read<ShopBloc>()
                                  .add(ShopPromoCodeApplied(code)),
                              onCheckout: () => context.go(AppRoutes.buyerCheckout),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
          ),
        );
      },
    );
  }
}

class _CartHeader extends StatelessWidget {
  final int itemCount;
  final VoidCallback onCatalog;
  final VoidCallback onCheckout;

  const _CartHeader({
    required this.itemCount,
    required this.onCatalog,
    required this.onCheckout,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Cart', style: Theme.of(context).textTheme.headlineSmall),
              const SizedBox(height: 4),
              Text(
                '$itemCount items ready for checkout',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ],
          ),
        ),
        TextButton(
          onPressed: onCatalog,
          child: const Text('Continue shopping'),
        ),
      ],
    );
  }
}

class _CartItemTile extends StatelessWidget {
  final CartItem item;
  final VoidCallback onTap;
  final VoidCallback onIncrease;
  final VoidCallback onDecrease;
  final VoidCallback onRemove;
  final VoidCallback onSaveForLater;

  const _CartItemTile({
    required this.item,
    required this.onTap,
    required this.onIncrease,
    required this.onDecrease,
    required this.onRemove,
    required this.onSaveForLater,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppDimensions.radiusXl),
      child: Container(
        padding: const EdgeInsets.all(AppDimensions.md),
        decoration: BoxDecoration(
          color: AppColors.surfaceLight,
          borderRadius: BorderRadius.circular(AppDimensions.radiusXl),
          border: Border.all(color: AppColors.divider),
        ),
        child: Column(
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ShopArtwork(
                  categorySlug: item.product.categorySlug,
                  size: 88,
                  iconSize: 32,
                ),
                const SizedBox(width: AppDimensions.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.product.brand,
                        style: Theme.of(context).textTheme.labelMedium,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        item.product.name,
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 8),
                      ShopPriceText(
                        price: item.product.price,
                        compareAtPrice: item.product.compareAtPrice,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppDimensions.md),
            Row(
              children: [
                ShopQuantityStepper(
                  quantity: item.quantity,
                  onIncrease: onIncrease,
                  onDecrease: onDecrease,
                ),
                const Spacer(),
                IconButton(
                  tooltip: 'Save for later',
                  onPressed: onSaveForLater,
                  icon: const Icon(Icons.bookmark_add_outlined),
                ),
                IconButton(
                  tooltip: 'Remove item',
                  onPressed: onRemove,
                  icon: const Icon(Icons.delete_outline),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _CartSummaryCard extends StatelessWidget {
  final ShopState state;
  final ValueChanged<String> onApplyPromo;
  final VoidCallback onCheckout;

  const _CartSummaryCard({
    required this.state,
    required this.onApplyPromo,
    required this.onCheckout,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppDimensions.lg),
      decoration: BoxDecoration(
        color: AppColors.surfaceLight,
        borderRadius: BorderRadius.circular(AppDimensions.radiusXl),
        border: Border.all(color: AppColors.divider),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Order summary', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: AppDimensions.md),
          ShopPromoCodeField(
            initialValue: state.promoCode,
            onApply: onApplyPromo,
          ),
          const SizedBox(height: AppDimensions.lg),
          _SummaryRow(
            label: 'Subtotal',
            value: formatCurrency(state.cartSubtotal),
          ),
          _SummaryRow(
            label: 'Discount',
            value: '- ${formatCurrency(state.promoDiscount)}',
          ),
          _SummaryRow(
            label: 'Shipping',
            value: formatCurrency(state.shippingFee),
          ),
          _SummaryRow(
            label: 'Tax',
            value: formatCurrency(state.taxAmount),
          ),
          const Divider(height: 32),
          _SummaryRow(
            label: 'Total',
            value: formatCurrency(state.cartTotal),
            emphasize: true,
          ),
          const SizedBox(height: AppDimensions.lg),
          AppButton(
            label: 'Proceed to checkout',
            onPressed: onCheckout,
          ),
        ],
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  final String label;
  final String value;
  final bool emphasize;

  const _SummaryRow({
    required this.label,
    required this.value,
    this.emphasize = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: emphasize ? FontWeight.w700 : FontWeight.w400,
                  ),
            ),
          ),
          Text(
            value,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: emphasize ? FontWeight.w700 : FontWeight.w400,
                ),
          ),
        ],
      ),
    );
  }
}
