import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_dimensions.dart';
import '../../../../../core/theme/app_text_styles.dart';
import '../../../../../core/widgets/app_button.dart';
import '../../../../../core/widgets/app_text_field.dart';
import '../../domain/entities/shop_category.dart';
import '../../domain/entities/shop_product.dart';
import '../bloc/shop_bloc.dart';
import '../bloc/shop_event.dart';
import '../bloc/shop_state.dart';

String formatCurrency(num value) =>
    NumberFormat.currency(symbol: '₹', decimalDigits: 0).format(value);

String categoryLabelFor(String slug) {
  return slug
      .replaceAll('_', ' ')
      .split(' ')
      .map((part) => part.isEmpty ? part : '${part[0].toUpperCase()}${part.substring(1)}')
      .join(' ');
}

IconData categoryIconFor(String slug) {
  return switch (slug) {
    'electronics' => Icons.headphones,
    'fashion' => Icons.checkroom,
    'home' => Icons.chair_alt,
    'beauty' => Icons.spa,
    'sports' => Icons.fitness_center,
    'grocery' => Icons.local_grocery_store,
    _ => Icons.shopping_bag_outlined,
  };
}

LinearGradient categoryGradientFor(String slug) {
  return switch (slug) {
    'electronics' => const LinearGradient(
        colors: [Color(0xFF1A73E8), Color(0xFF0F9D58)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
    'fashion' => const LinearGradient(
        colors: [Color(0xFFEF476F), Color(0xFFFFA62B)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
    'home' => const LinearGradient(
        colors: [Color(0xFF8E7DBE), Color(0xFF4ECDC4)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
    'beauty' => const LinearGradient(
        colors: [Color(0xFFFF8FAB), Color(0xFFF4A261)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
    'sports' => const LinearGradient(
        colors: [Color(0xFF06D6A0), Color(0xFF1A73E8)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
    'grocery' => const LinearGradient(
        colors: [Color(0xFF43AA8B), Color(0xFF90BE6D)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
    _ => const LinearGradient(
        colors: [AppColors.primary, AppColors.secondary],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
  };
}

class ShopSectionHeader extends StatelessWidget {
  final String title;
  final String? subtitle;
  final String? actionLabel;
  final VoidCallback? onActionPressed;

  const ShopSectionHeader({
    super.key,
    required this.title,
    this.subtitle,
    this.actionLabel,
    this.onActionPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: Theme.of(context).textTheme.titleLarge),
              if (subtitle != null) ...[
                const SizedBox(height: 4),
                Text(subtitle!, style: Theme.of(context).textTheme.bodyMedium),
              ],
            ],
          ),
        ),
        if (actionLabel != null)
          TextButton(
            onPressed: onActionPressed,
            child: Text(actionLabel!),
          ),
      ],
    );
  }
}

class ShopArtwork extends StatelessWidget {
  final String categorySlug;
  final double? size;
  final double iconSize;
  final bool elevated;

  const ShopArtwork({
    super.key,
    required this.categorySlug,
    this.size = 120,
    this.iconSize = 42,
    this.elevated = false,
  });

  @override
  Widget build(BuildContext context) {
    final boxSize = size ?? 120;
    final artwork = Container(
      decoration: BoxDecoration(
        gradient: categoryGradientFor(categorySlug),
        borderRadius: BorderRadius.circular(AppDimensions.radiusXl),
        boxShadow: elevated
            ? [
                BoxShadow(
                  color: AppColors.primary.withOpacity(0.2),
                  blurRadius: 24,
                  offset: const Offset(0, 14),
                ),
              ]
            : null,
      ),
      child: Stack(
        children: [
          Positioned(
            right: 10,
            top: 10,
            child: Container(
              width: boxSize * 0.42,
              height: boxSize * 0.42,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.12),
                shape: BoxShape.circle,
              ),
            ),
          ),
          Positioned(
            left: 12,
            bottom: 12,
            child: Container(
              width: boxSize * 0.3,
              height: boxSize * 0.3,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.08),
                shape: BoxShape.circle,
              ),
            ),
          ),
          Center(
            child: Icon(
              categoryIconFor(categorySlug),
              size: iconSize,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );

    if (size == null) {
      return SizedBox.expand(child: artwork);
    }
    return SizedBox(width: boxSize, height: boxSize, child: artwork);
  }
}

class ShopPriceText extends StatelessWidget {
  final double price;
  final double? compareAtPrice;
  final TextAlign textAlign;

  const ShopPriceText({
    super.key,
    required this.price,
    this.compareAtPrice,
    this.textAlign = TextAlign.start,
  });

  @override
  Widget build(BuildContext context) {
    final priceText = formatCurrency(price);
    final compareText =
        compareAtPrice != null ? formatCurrency(compareAtPrice!) : null;

    return RichText(
      textAlign: textAlign,
      text: TextSpan(
        style: Theme.of(context).textTheme.titleLarge?.copyWith(
              color: AppColors.textPrimary,
            ),
        children: [
          TextSpan(text: priceText),
          if (compareText != null)
            TextSpan(
              text: '  $compareText',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    decoration: TextDecoration.lineThrough,
                    color: AppColors.textSecondary,
                  ),
            ),
        ],
      ),
    );
  }
}

class ShopRatingBadge extends StatelessWidget {
  final double rating;
  final int reviewCount;

  const ShopRatingBadge({
    super.key,
    required this.rating,
    required this.reviewCount,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimensions.sm,
        vertical: AppDimensions.xs,
      ),
      decoration: BoxDecoration(
        color: AppColors.success.withOpacity(0.12),
        borderRadius: BorderRadius.circular(AppDimensions.radiusCircular),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.star_rounded, size: 16, color: AppColors.success),
          const SizedBox(width: 4),
          Text(
            rating.toStringAsFixed(1),
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
                  color: AppColors.success,
                  fontWeight: FontWeight.w700,
                ),
          ),
          const SizedBox(width: 4),
          Text(
            '($reviewCount)',
            style: Theme.of(context).textTheme.labelMedium,
          ),
        ],
      ),
    );
  }
}

class ShopCategoryChip extends StatelessWidget {
  final ShopCategory category;
  final bool selected;
  final VoidCallback? onTap;

  const ShopCategoryChip({
    super.key,
    required this.category,
    required this.selected,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return FilterChip(
      selected: selected,
      onSelected: (_) => onTap?.call(),
      avatar: Icon(
        categoryIconFor(category.slug),
        size: 18,
        color: selected ? Colors.white : AppColors.primary,
      ),
      label: Text(category.name),
      labelStyle: Theme.of(context).textTheme.labelMedium?.copyWith(
            color: selected ? Colors.white : AppColors.textPrimary,
            fontWeight: FontWeight.w600,
          ),
      backgroundColor: AppColors.surfaceLight,
      selectedColor: AppColors.primary,
      side: const BorderSide(color: AppColors.divider),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppDimensions.radiusCircular),
      ),
    );
  }
}

class ShopCategoryCard extends StatelessWidget {
  final ShopCategory category;
  final VoidCallback? onTap;

  const ShopCategoryCard({
    super.key,
    required this.category,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppDimensions.radiusXl),
      child: Container(
        padding: const EdgeInsets.all(AppDimensions.sm),
        decoration: BoxDecoration(
          color: AppColors.surfaceLight,
          borderRadius: BorderRadius.circular(AppDimensions.radiusXl),
          border: Border.all(color: AppColors.divider),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: ShopArtwork(
                categorySlug: category.slug,
                size: 40,
                iconSize: 18,
              ),
            ),
            const SizedBox(height: AppDimensions.xs),
            Text(
              category.name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.labelMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}

class ShopProductCard extends StatelessWidget {
  final ShopProduct product;
  final VoidCallback? onTap;
  final bool compact;
  final bool showCategoryPill;
  final bool selected;

  const ShopProductCard({
    super.key,
    required this.product,
    this.onTap,
    this.compact = false,
    this.showCategoryPill = false,
    this.selected = false,
  });

  @override
  Widget build(BuildContext context) {
    final borderColor = selected ? AppColors.primary : AppColors.divider;

    if (compact) {
      return InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppDimensions.radiusXl),
        child: Container(
          decoration: BoxDecoration(
            color: AppColors.surfaceLight,
            borderRadius: BorderRadius.circular(AppDimensions.radiusXl),
            border: Border.all(color: borderColor),
          ),
          child: Row(
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.horizontal(
                  left: Radius.circular(AppDimensions.radiusXl),
                ),
                child: ShopArtwork(
                  categorySlug: product.categorySlug,
                  size: 74,
                  iconSize: 28,
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(AppDimensions.md),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (showCategoryPill)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppDimensions.sm,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(
                              AppDimensions.radiusCircular,
                            ),
                          ),
                            child: Text(
                            categoryLabelFor(product.categorySlug),
                            style:
                                Theme.of(context).textTheme.labelMedium?.copyWith(
                                      color: AppColors.primary,
                                      fontWeight: FontWeight.w700,
                                    ),
                          ),
                        ),
                      if (showCategoryPill) const SizedBox(height: 8),
                      Text(
                        product.brand,
                        style: Theme.of(context).textTheme.labelMedium,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        product.name,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 8),
                      ShopPriceText(
                        price: product.price,
                        compareAtPrice: product.compareAtPrice,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppDimensions.radiusXl),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.surfaceLight,
          borderRadius: BorderRadius.circular(AppDimensions.radiusXl),
          border: Border.all(color: borderColor),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(AppDimensions.radiusXl),
                  ),
                  child: AspectRatio(
                    aspectRatio: 1.08,
                    child: ShopArtwork(
                      categorySlug: product.categorySlug,
                      iconSize: 42,
                      elevated: false,
                    ),
                  ),
                ),
                Positioned(
                  left: AppDimensions.sm,
                  top: AppDimensions.sm,
                  child: Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: [
                      if (!product.inStock)
                        _Badge(
                          label: 'Out of stock',
                          background: AppColors.error.withOpacity(0.88),
                        ),
                      if (product.discountPercent != null)
                        _Badge(
                          label: '${product.discountPercent}% off',
                          background: AppColors.secondary.withOpacity(0.88),
                        ),
                    ],
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(AppDimensions.md),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.brand,
                    style: Theme.of(context).textTheme.labelMedium,
                  ),
                  const SizedBox(height: 6),
                  Text(
                    product.name,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  ShopRatingBadge(
                    rating: product.rating,
                    reviewCount: product.reviewCount,
                  ),
                  const SizedBox(height: 10),
                  ShopPriceText(
                    price: product.price,
                    compareAtPrice: product.compareAtPrice,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Badge extends StatelessWidget {
  final String label;
  final Color background;

  const _Badge({
    required this.label,
    required this.background,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
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
              color: Colors.white,
              fontWeight: FontWeight.w700,
            ),
      ),
    );
  }
}

class ShopEmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String message;
  final String? actionLabel;
  final VoidCallback? onAction;

  const ShopEmptyState({
    super.key,
    required this.icon,
    required this.title,
    required this.message,
    this.actionLabel,
    this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: constraints.maxHeight),
            child: Center(
              child: Padding(
                padding: const EdgeInsets.all(AppDimensions.lg),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(AppDimensions.lg),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withOpacity(0.08),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(icon, size: 42, color: AppColors.primary),
                    ),
                    const SizedBox(height: AppDimensions.lg),
                    Text(
                      title,
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: AppDimensions.sm),
                    Text(
                      message,
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    if (actionLabel != null) ...[
                      const SizedBox(height: AppDimensions.lg),
                      AppButton(label: actionLabel!, onPressed: onAction),
                    ],
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class ShopQuantityStepper extends StatelessWidget {
  final int quantity;
  final VoidCallback onIncrease;
  final VoidCallback onDecrease;

  const ShopQuantityStepper({
    super.key,
    required this.quantity,
    required this.onIncrease,
    required this.onDecrease,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.backgroundLight,
        borderRadius: BorderRadius.circular(AppDimensions.radiusCircular),
        border: Border.all(color: AppColors.divider),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            onPressed: onDecrease,
            icon: const Icon(Icons.remove),
            visualDensity: VisualDensity.compact,
          ),
          Text(
            '$quantity',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
          ),
          IconButton(
            onPressed: onIncrease,
            icon: const Icon(Icons.add),
            visualDensity: VisualDensity.compact,
          ),
        ],
      ),
    );
  }
}

class ShopPromoCodeField extends StatefulWidget {
  final String initialValue;
  final ValueChanged<String> onApply;

  const ShopPromoCodeField({
    super.key,
    required this.initialValue,
    required this.onApply,
  });

  @override
  State<ShopPromoCodeField> createState() => _ShopPromoCodeFieldState();
}

class _ShopPromoCodeFieldState extends State<ShopPromoCodeField> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialValue);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: AppTextField(
            controller: _controller,
            label: 'Promo code',
            hint: 'SAVE10',
            suffixIcon: IconButton(
              icon: const Icon(Icons.local_offer_outlined),
              onPressed: () => widget.onApply(_controller.text),
            ),
          ),
        ),
        const SizedBox(width: AppDimensions.sm),
        SizedBox(
          width: 96,
          height: AppDimensions.buttonHeight,
          child: AppButton(
            label: 'Apply',
            onPressed: () => widget.onApply(_controller.text),
          ),
        ),
      ],
    );
  }
}

Future<void> showShopFilterSheet(BuildContext context) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    builder: (context) {
      return BlocBuilder<ShopBloc, ShopState>(
        builder: (context, state) {
          return DraggableScrollableSheet(
            initialChildSize: 0.78,
            minChildSize: 0.45,
            maxChildSize: 0.95,
            expand: false,
            builder: (context, scrollController) {
              return Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppDimensions.lg,
                  AppDimensions.sm,
                  AppDimensions.lg,
                  AppDimensions.lg,
                ),
                child: ListView(
                  controller: scrollController,
                  children: [
                    Text(
                      'Filters',
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    const SizedBox(height: AppDimensions.lg),
                    Text(
                      'Sort by',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: AppDimensions.sm),
                    ...ShopSortOption.values.map(
                      (option) => RadioListTile<ShopSortOption>(
                        value: option,
                        groupValue: state.sortOption,
                        onChanged: (value) {
                          if (value != null) {
                            context
                                .read<ShopBloc>()
                                .add(ShopSortOptionSelected(value));
                          }
                        },
                        title: Text(option.label),
                      ),
                    ),
                    const SizedBox(height: AppDimensions.sm),
                    SwitchListTile.adaptive(
                      value: state.showOnlyInStock,
                      onChanged: (value) => context
                          .read<ShopBloc>()
                          .add(ShopOnlyInStockChanged(value)),
                      title: const Text('Show only in-stock items'),
                      subtitle: const Text('Hide out-of-stock products from results'),
                    ),
                    const Divider(height: 32),
                    Text(
                      'Categories',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: AppDimensions.sm),
                    Wrap(
                      spacing: AppDimensions.sm,
                      runSpacing: AppDimensions.sm,
                      children: state.categories
                          .map(
                            (category) => FilterChip(
                              selected: state.selectedCategorySlug == category.slug,
                              label: Text(category.name),
                              onSelected: (_) => context
                                  .read<ShopBloc>()
                                  .add(ShopCategorySelected(category.slug)),
                            ),
                          )
                          .toList(),
                    ),
                    const SizedBox(height: AppDimensions.xl),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () {
                              context.read<ShopBloc>().add(const ShopFiltersCleared());
                            },
                            child: const Text('Clear filters'),
                          ),
                        ),
                        const SizedBox(width: AppDimensions.sm),
                        Expanded(
                          child: AppButton(
                            label: 'Done',
                            onPressed: () => Navigator.of(context).pop(),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            },
          );
        },
      );
    },
  );
}
