import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../../core/router/app_routes.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_dimensions.dart';
import '../../../../../core/widgets/app_button.dart';
import '../../domain/entities/shop_product.dart';
import '../bloc/shop_bloc.dart';
import '../bloc/shop_event.dart';
import '../bloc/shop_state.dart';
import '../widgets/shop_widgets.dart';

class ProductDetailScreen extends StatefulWidget {
  final String productId;

  const ProductDetailScreen({
    super.key,
    required this.productId,
  });

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  int _selectedSizeIndex = 0;
  int _selectedColorIndex = 0;
  bool _didAnnounceView = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_didAnnounceView) return;
    _didAnnounceView = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context.read<ShopBloc>().add(ShopProductViewed(widget.productId));
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ShopBloc, ShopState>(
      builder: (context, state) {
        if (state.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        final product = state.productById(widget.productId);
        if (product == null) {
          return SafeArea(
            child: ShopEmptyState(
              icon: Icons.inventory_2_outlined,
              title: 'Product not found',
              message:
                  'The item you opened no longer exists in the current catalog.',
              actionLabel: 'Back to catalog',
              onAction: () => context.go(AppRoutes.buyerCatalog),
            ),
          );
        }

        final selectedSize = product.sizes.isEmpty
            ? 'One size'
            : product.sizes[_selectedSizeIndex.clamp(0, product.sizes.length - 1)];
        final selectedColor = product.colors.isEmpty
            ? 'Default'
            : product.colors[_selectedColorIndex.clamp(0, product.colors.length - 1)];
        final recentProducts = state.recentlyViewedProducts
            .where((item) => item.id != product.id)
            .toList();

        return SafeArea(
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(
                    AppDimensions.lg,
                    AppDimensions.md,
                    AppDimensions.lg,
                    AppDimensions.lg,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _DetailTopBar(
                        cartCount: state.cartCount,
                        onBack: () => context.go(AppRoutes.buyerCatalog),
                        onCart: () => context.go(AppRoutes.buyerCart),
                      ),
                      const SizedBox(height: AppDimensions.lg),
                      _ProductHero(product: product),
                      const SizedBox(height: AppDimensions.lg),
                      Text(product.brand,
                          style: Theme.of(context).textTheme.labelMedium),
                      const SizedBox(height: 4),
                      Text(
                        product.name,
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                      const SizedBox(height: AppDimensions.sm),
                      Row(
                        children: [
                          ShopRatingBadge(
                            rating: product.rating,
                            reviewCount: product.reviewCount,
                          ),
                          const SizedBox(width: AppDimensions.sm),
                          if (product.inStock)
                            _StockChip(
                              label: 'In stock',
                              background: AppColors.success.withOpacity(0.12),
                              color: AppColors.success,
                            )
                          else
                            _StockChip(
                              label: 'Out of stock',
                              background: AppColors.error.withOpacity(0.12),
                              color: AppColors.error,
                            ),
                        ],
                      ),
                      const SizedBox(height: AppDimensions.md),
                      ShopPriceText(
                        price: product.price,
                        compareAtPrice: product.compareAtPrice,
                      ),
                      if (product.badges.isNotEmpty) ...[
                        const SizedBox(height: AppDimensions.md),
                        Wrap(
                          spacing: AppDimensions.sm,
                          runSpacing: AppDimensions.sm,
                          children: product.badges
                              .map(
                                (badge) => _PillBadge(label: badge),
                              )
                              .toList(),
                        ),
                      ],
                      const SizedBox(height: AppDimensions.xl),
                      Text(
                        'Choose your options',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: AppDimensions.sm),
                      _SelectionSection(
                        label: 'Size',
                        values: product.sizes.isEmpty ? const ['One size'] : product.sizes,
                        selectedIndex: _selectedSizeIndex,
                        onSelected: (index) =>
                            setState(() => _selectedSizeIndex = index),
                      ),
                      const SizedBox(height: AppDimensions.md),
                      _SelectionSection(
                        label: 'Color',
                        values: product.colors.isEmpty ? const ['Default'] : product.colors,
                        selectedIndex: _selectedColorIndex,
                        onSelected: (index) =>
                            setState(() => _selectedColorIndex = index),
                      ),
                      const SizedBox(height: AppDimensions.xl),
                      Text(
                        'Description',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: AppDimensions.sm),
                      Text(
                        product.description,
                        style: Theme.of(context).textTheme.bodyLarge,
                      ),
                      const SizedBox(height: AppDimensions.lg),
                      Text(
                        'Highlights',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: AppDimensions.sm),
                      ...product.specs.map(
                        (spec) => Padding(
                          padding: const EdgeInsets.only(bottom: AppDimensions.sm),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Icon(Icons.check_circle, color: AppColors.success, size: 20),
                              const SizedBox(width: AppDimensions.sm),
                              Expanded(
                                child: Text(
                                  spec,
                                  style: Theme.of(context).textTheme.bodyMedium,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: AppDimensions.lg),
                      Text(
                        'Recently browsed',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: AppDimensions.sm),
                      if (recentProducts.isEmpty)
                        Text(
                          'Open a few products to build a recent view history.',
                          style: Theme.of(context).textTheme.bodyMedium,
                        )
                      else
                        SizedBox(
                          height: 225,
                          child: ListView.separated(
                            scrollDirection: Axis.horizontal,
                            itemBuilder: (context, index) {
                              final item = recentProducts[index];
                              return SizedBox(
                                width: 248,
                                child: ShopProductCard(
                                  product: item,
                                  compact: true,
                                  onTap: () => context.go(AppRoutes.buyerProductPath(item.id)),
                                ),
                              );
                            },
                            separatorBuilder: (_, __) =>
                                const SizedBox(width: AppDimensions.md),
                            itemCount: recentProducts.length,
                          ),
                        ),
                      const SizedBox(height: AppDimensions.xl),
                      _SelectionSummary(
                        size: selectedSize,
                        color: selectedColor,
                      ),
                    ],
                  ),
                ),
              ),
              _ProductActionBar(
                price: product.price,
                compareAtPrice: product.compareAtPrice,
                inStock: product.inStock,
                onAddToCart: () {
                  context.read<ShopBloc>().add(ShopAddToCartRequested(product.id));
                  context.go(AppRoutes.buyerCart);
                },
                onBuyNow: () {
                  context.read<ShopBloc>().add(ShopAddToCartRequested(product.id));
                  context.go(AppRoutes.buyerCheckout);
                },
              ),
            ],
          ),
        );
      },
    );
  }
}

class _DetailTopBar extends StatelessWidget {
  final int cartCount;
  final VoidCallback onBack;
  final VoidCallback onCart;

  const _DetailTopBar({
    required this.cartCount,
    required this.onBack,
    required this.onCart,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        IconButton(
          onPressed: onBack,
          icon: const Icon(Icons.arrow_back_rounded),
        ),
        const Spacer(),
        Badge(
          isLabelVisible: cartCount > 0,
          label: Text('$cartCount'),
          child: IconButton(
            onPressed: onCart,
            icon: const Icon(Icons.shopping_bag_outlined),
          ),
        ),
      ],
    );
  }
}

class _ProductHero extends StatelessWidget {
  final ShopProduct product;

  const _ProductHero({required this.product});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppDimensions.lg),
      decoration: BoxDecoration(
        color: AppColors.surfaceLight,
        borderRadius: BorderRadius.circular(AppDimensions.radiusXl),
        border: Border.all(color: AppColors.divider),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          ShopArtwork(
            categorySlug: product.categorySlug as String,
            size: 260,
            iconSize: 68,
            elevated: true,
          ),
          const SizedBox(height: AppDimensions.md),
          Text(
            '${product.brand} • ${categoryLabelFor(product.categorySlug)}',
            style: Theme.of(context).textTheme.labelMedium,
          ),
        ],
      ),
    );
  }
}

class _SelectionSection extends StatelessWidget {
  final String label;
  final List<String> values;
  final int selectedIndex;
  final ValueChanged<int> onSelected;

  const _SelectionSection({
    required this.label,
    required this.values,
    required this.selectedIndex,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: AppDimensions.sm),
        Wrap(
          spacing: AppDimensions.sm,
          runSpacing: AppDimensions.sm,
          children: List.generate(values.length, (index) {
            final value = values[index];
            return ChoiceChip(
              selected: selectedIndex == index,
              label: Text(value),
              onSelected: (_) => onSelected(index),
            );
          }),
        ),
      ],
    );
  }
}

class _PillBadge extends StatelessWidget {
  final String label;

  const _PillBadge({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimensions.md,
        vertical: AppDimensions.sm,
      ),
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.08),
        borderRadius: BorderRadius.circular(AppDimensions.radiusCircular),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.labelMedium?.copyWith(
              color: AppColors.primary,
              fontWeight: FontWeight.w700,
            ),
      ),
    );
  }
}

class _StockChip extends StatelessWidget {
  final String label;
  final Color background;
  final Color color;

  const _StockChip({
    required this.label,
    required this.background,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(left: AppDimensions.sm),
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimensions.sm,
        vertical: 4,
      ),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(AppDimensions.radiusCircular),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.labelMedium?.copyWith(
              color: color,
              fontWeight: FontWeight.w700,
            ),
      ),
    );
  }
}

class _SelectionSummary extends StatelessWidget {
  final String size;
  final String color;

  const _SelectionSummary({
    required this.size,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppDimensions.md),
      decoration: BoxDecoration(
        color: AppColors.backgroundLight,
        borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
      ),
      child: Text(
        'Selected: $size, $color',
        style: Theme.of(context).textTheme.bodyMedium,
      ),
    );
  }
}

class _ProductActionBar extends StatelessWidget {
  final double price;
  final double? compareAtPrice;
  final bool inStock;
  final VoidCallback onAddToCart;
  final VoidCallback onBuyNow;

  const _ProductActionBar({
    required this.price,
    required this.compareAtPrice,
    required this.inStock,
    required this.onAddToCart,
    required this.onBuyNow,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppDimensions.lg),
      decoration: BoxDecoration(
        color: AppColors.surfaceLight,
        border: Border(
          top: BorderSide(color: AppColors.divider.withOpacity(0.8)),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Expanded(
                child: ShopPriceText(
                  price: price,
                  compareAtPrice: compareAtPrice,
                ),
              ),
              if (!inStock)
                const Padding(
                  padding: EdgeInsets.only(left: AppDimensions.sm),
                  child: Text(
                    'Out of stock',
                    style: TextStyle(
                      color: AppColors.error,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: AppDimensions.md),
          Row(
            children: [
              Expanded(
                child: AppButton(
                  label: inStock ? 'Add to cart' : 'Unavailable',
                  onPressed: inStock ? onAddToCart : null,
                ),
              ),
              const SizedBox(width: AppDimensions.sm),
              Expanded(
                child: OutlinedButton(
                  onPressed: inStock ? onBuyNow : null,
                  child: const Text('Buy now'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
