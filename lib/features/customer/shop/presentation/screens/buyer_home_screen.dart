import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../../core/router/app_routes.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_dimensions.dart';
import '../../domain/entities/shop_category.dart';
import '../bloc/shop_bloc.dart';
import '../bloc/shop_event.dart';
import '../bloc/shop_state.dart';
import '../widgets/shop_widgets.dart';

class BuyerHomeScreen extends StatelessWidget {
  const BuyerHomeScreen({super.key});

  void _openProduct(BuildContext context, String productId) {
    context.read<ShopBloc>().add(ShopProductViewed(productId));
    context.go(AppRoutes.buyerProductPath(productId));
  }

  void _openCategory(BuildContext context, String categorySlug) {
    context.read<ShopBloc>().add(ShopCategorySelected(categorySlug));
    context.go(AppRoutes.buyerCategoryPath(categorySlug));
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ShopBloc, ShopState>(
      builder: (context, state) {
        if (state.isLoading) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        final featured = state.featuredProducts.take(4).toList();
        final trending = state.trendingProducts.take(4).toList();
        final recent = state.recentlyViewedProducts;
        final saved = state.savedForLaterProducts;

        return Scaffold(
          // backgroundColor: AppColors.backgroundLight,
          body: Stack(
            children: [
              const _BackgroundWash(),
              SafeArea(
                top: false,
                child: RefreshIndicator(
                  onRefresh: () async {
                    context.read<ShopBloc>().add(const ShopStarted());
                  },
                  child: ListView(
                    padding: const EdgeInsets.fromLTRB(
                      AppDimensions.lg,
                      AppDimensions.md,
                      AppDimensions.lg,
                      140,
                    ),
                    children: [
                      _HomeTopBar(cartCount: state.cartCount),
                      const SizedBox(height: AppDimensions.lg),
                      _HeroBanner(
                        onShopNow: () => context.go(AppRoutes.buyerCatalog),
                        onSearch: () => context.go(AppRoutes.buyerSearch),
                        cartCount: state.cartCount,
                        categoryCount: state.categories.length,
                        featuredCount: featured.length,
                      ),
                      const SizedBox(height: AppDimensions.lg),
                      _SearchPrompt(
                        onTap: () => context.go(AppRoutes.buyerSearch),
                      ),
                      const SizedBox(height: AppDimensions.lg),
                      _QuickActionsRow(
                        onCategoriesTap: () => context.go(AppRoutes.buyerCatalog),
                        onDealsTap: () => context.go(AppRoutes.buyerSearch),
                        onCartTap: () => context.go(AppRoutes.buyerCart),
                        onSavedTap: () => context.go(AppRoutes.buyerWishlist),
                      ),
                      const SizedBox(height: AppDimensions.xl),
                      ShopSectionHeader(
                        title: 'Categories',
                        subtitle: 'Jump into the collection that fits your day.',
                        actionLabel: 'Browse all',
                        onActionPressed: () => context.go(AppRoutes.buyerCatalog),
                      ),
                      const SizedBox(height: AppDimensions.sm),
                      SizedBox(
                        height: 142,
                        child: ListView.separated(
                          scrollDirection: Axis.horizontal,
                          itemCount: state.categories.length,
                          itemBuilder: (context, index) {
                            final category = state.categories[index];
                            return SizedBox(
                              width: 150,
                              child: _CategoryShowcaseCard(
                                category: category,
                                onTap: () => _openCategory(context, category.slug),
                              ),
                            );
                          },
                          separatorBuilder: (_, __) =>
                              const SizedBox(width: AppDimensions.md),
                        ),
                      ),
                      const SizedBox(height: AppDimensions.xl),
                      _SectionFeatureStrip(
                        title: 'Today\'s spotlight',
                        subtitle:
                            'A tighter, more curated view of the products people are exploring most.',
                        accentLabel: '${state.trendingProducts.length} trending',
                        accentIcon: Icons.local_fire_department_rounded,
                      ),
                      const SizedBox(height: AppDimensions.sm),
                      LayoutBuilder(
                        builder: (context, constraints) {
                          final crossAxisCount = constraints.maxWidth > 700 ? 4 : 2;
                          return GridView.builder(
                            itemCount: featured.length,
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            gridDelegate:
                                SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: crossAxisCount,
                              mainAxisSpacing: AppDimensions.md,
                              crossAxisSpacing: AppDimensions.md,
                              childAspectRatio: 0.52,
                            ),
                            itemBuilder: (context, index) {
                              final product = featured[index];
                              return ShopProductCard(
                                product: product,
                                onTap: () => _openProduct(context, product.id),
                              );
                            },
                          );
                        },
                      ),
                      const SizedBox(height: AppDimensions.xl),
                      ShopSectionHeader(
                        title: 'Trending now',
                        subtitle: 'Products moving fast this week.',
                        actionLabel: 'Explore',
                        onActionPressed: () => context.go(AppRoutes.buyerCatalog),
                      ),
                      const SizedBox(height: AppDimensions.sm),
                      SizedBox(
                        height: 226,
                        child: ListView.separated(
                          scrollDirection: Axis.horizontal,
                          itemCount: trending.length,
                          itemBuilder: (context, index) {
                            final product = trending[index];
                            return SizedBox(
                              width: 260,
                              child: ShopProductCard(
                                product: product,
                                compact: true,
                                showCategoryPill: true,
                                onTap: () => _openProduct(context, product.id),
                              ),
                            );
                          },
                          separatorBuilder: (_, __) =>
                              const SizedBox(width: AppDimensions.md),
                        ),
                      ),
                      if (saved.isNotEmpty) ...[
                        const SizedBox(height: AppDimensions.xl),
                        ShopSectionHeader(
                          title: 'Saved for later',
                          subtitle: 'Items the user bookmarked for another visit.',
                          actionLabel: 'Open wishlist',
                          onActionPressed: () =>
                              context.go(AppRoutes.buyerWishlist),
                        ),
                        const SizedBox(height: AppDimensions.sm),
                        ...saved.take(3).map(
                              (product) => Padding(
                                padding: const EdgeInsets.only(
                                  bottom: AppDimensions.md,
                                ),
                                child: ShopProductCard(
                                  product: product,
                                  compact: true,
                                  onTap: () => _openProduct(context, product.id),
                                ),
                              ),
                            ),
                      ],
                      if (recent.isNotEmpty) ...[
                        const SizedBox(height: AppDimensions.xl),
                        ShopSectionHeader(
                          title: 'Recently viewed',
                          subtitle: 'Pick up where you left off.',
                        ),
                        const SizedBox(height: AppDimensions.sm),
                        ...recent.take(3).map(
                              (product) => Padding(
                                padding: const EdgeInsets.only(
                                  bottom: AppDimensions.md,
                                ),
                                child: ShopProductCard(
                                  product: product,
                                  compact: true,
                                  onTap: () => _openProduct(context, product.id),
                                ),
                              ),
                            ),
                      ],
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _BackgroundWash extends StatelessWidget {
  const _BackgroundWash();

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Stack(
        children: [
          Positioned(
            top: -80,
            right: -60,
            child: _Glow(
              size: 180,
              colors: [
                AppColors.primary.withOpacity(0.14),
                AppColors.secondary.withOpacity(0.05),
              ],
            ),
          ),
          Positioned(
            top: 260,
            left: -90,
            child: _Glow(
              size: 220,
              colors: [
                AppColors.secondary.withOpacity(0.08),
                Colors.transparent,
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Glow extends StatelessWidget {
  final double size;
  final List<Color> colors;

  const _Glow({
    required this.size,
    required this.colors,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(colors: colors),
      ),
    );
  }
}

class _HomeTopBar extends StatelessWidget {
  final int cartCount;

  const _HomeTopBar({required this.cartCount});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppDimensions.sm,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(AppDimensions.radiusCircular),
                ),
                child: Text(
                  'Welcome back',
                  style: Theme.of(context).textTheme.labelMedium?.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w700,
                      ),
                ),
              ),
              const SizedBox(height: AppDimensions.sm),
              Text(
                'What are we shopping for today?',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
              ),
              const SizedBox(height: 4),
              Text(
                'A cleaner path to categories, deals, and your recent picks.',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppColors.textSecondary,
                    ),
              ),
            ],
          ),
        ),
        const SizedBox(width: AppDimensions.md),
        Badge(
          isLabelVisible: cartCount > 0,
          label: Text('$cartCount'),
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(AppDimensions.radiusCircular),
              border: Border.all(color: AppColors.divider),
            ),
            child: IconButton(
              onPressed: () => context.go(AppRoutes.buyerCart),
              icon: const Icon(Icons.shopping_bag_outlined),
            ),
          ),
        ),
      ],
    );
  }
}

class _HeroBanner extends StatelessWidget {
  final VoidCallback onShopNow;
  final VoidCallback onSearch;
  final int cartCount;
  final int categoryCount;
  final int featuredCount;

  const _HeroBanner({
    required this.onShopNow,
    required this.onSearch,
    required this.cartCount,
    required this.categoryCount,
    required this.featuredCount,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppDimensions.lg),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF0F172A), Color(0xFF123D7A), Color(0xFF1A73E8)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(AppDimensions.radiusXl),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.24),
            blurRadius: 28,
            offset: const Offset(0, 16),
          ),
        ],
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isWide = constraints.maxWidth > 620;

          final content = Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppDimensions.sm,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.16),
                  borderRadius:
                      BorderRadius.circular(AppDimensions.radiusCircular),
                ),
                child: Text(
                  'Curated for the day',
                  style: Theme.of(context).textTheme.labelMedium?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                      ),
                ),
              ),
              const SizedBox(height: AppDimensions.md),
              Text(
                'Sharper picks, stronger deals, and faster checkout decisions.',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w800,
                    ),
              ),
              const SizedBox(height: AppDimensions.sm),
              Text(
                'Highlight the products, categories, and saved items that matter most to your user.',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.white.withOpacity(0.86),
                    ),
              ),
              const SizedBox(height: AppDimensions.lg),
              Wrap(
                spacing: AppDimensions.sm,
                runSpacing: AppDimensions.sm,
                children: [
                  SizedBox(
                    width: 138,
                    child: ElevatedButton(
                      onPressed: onShopNow,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: AppColors.primaryDark,
                      ),
                      child: const Text('Shop now'),
                    ),
                  ),
                  SizedBox(
                    width: 132,
                    child: OutlinedButton(
                      onPressed: onSearch,
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.white,
                        side: const BorderSide(color: Colors.white),
                      ),
                      child: const Text('Search'),
                    ),
                  ),
                ],
              ),
            ],
          );

          final artwork = Container(
            width: isWide ? 144 : double.infinity,
            height: isWide ? 144 : 120,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
              borderRadius: BorderRadius.circular(AppDimensions.radiusXl),
              border: Border.all(color: Colors.white.withOpacity(0.16)),
            ),
            child: Stack(
              children: [
                Positioned(
                  right: -10,
                  top: -10,
                  child: Container(
                    width: 76,
                    height: 76,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.12),
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
                Positioned(
                  left: -8,
                  bottom: -8,
                  child: Container(
                    width: 96,
                    height: 96,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.08),
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
                const Center(
                  child: ShopArtwork(
                    categorySlug: 'electronics',
                    size: 96,
                    iconSize: 40,
                    elevated: false,
                  ),
                ),
              ],
            ),
          );

          final stats = Row(
            children: [
              Expanded(
                child: _HeroStat(
                  label: 'Categories',
                  value: '$categoryCount',
                ),
              ),
              const SizedBox(width: AppDimensions.sm),
              Expanded(
                child: _HeroStat(
                  label: 'Featured',
                  value: '$featuredCount',
                ),
              ),
              const SizedBox(width: AppDimensions.sm),
              Expanded(
                child: _HeroStat(
                  label: 'In cart',
                  value: '$cartCount',
                ),
              ),
            ],
          );

          if (isWide) {
            return Row(
              children: [
                Expanded(child: content),
                const SizedBox(width: AppDimensions.lg),
                Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    artwork,
                    const SizedBox(height: AppDimensions.md),
                    SizedBox(width: 144, child: stats),
                  ],
                ),
              ],
            );
          }

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              content,
              const SizedBox(height: AppDimensions.lg),
              artwork,
              const SizedBox(height: AppDimensions.md),
              stats,
            ],
          );
        },
      ),
    );
  }
}

class _HeroStat extends StatelessWidget {
  final String label;
  final String value;

  const _HeroStat({
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimensions.sm,
        vertical: AppDimensions.sm,
      ),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
        border: Border.all(color: Colors.white.withOpacity(0.12)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            value,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w800,
                ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
                  color: Colors.white.withOpacity(0.76),
                ),
          ),
        ],
      ),
    );
  }
}

class _SearchPrompt extends StatelessWidget {
  final VoidCallback onTap;

  const _SearchPrompt({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppDimensions.radiusXl),
      child: Container(
        padding: const EdgeInsets.all(AppDimensions.md),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(AppDimensions.radiusXl),
          border: Border.all(color: AppColors.divider),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(AppDimensions.sm),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.08),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.search_rounded,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(width: AppDimensions.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Search anything',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Products, brands, categories, or deals',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppColors.textSecondary,
                        ),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.chevron_right_rounded,
              color: AppColors.textSecondary,
            ),
          ],
        ),
      ),
    );
  }
}

class _QuickActionsRow extends StatelessWidget {
  final VoidCallback onCategoriesTap;
  final VoidCallback onDealsTap;
  final VoidCallback onCartTap;
  final VoidCallback onSavedTap;

  const _QuickActionsRow({
    required this.onCategoriesTap,
    required this.onDealsTap,
    required this.onCartTap,
    required this.onSavedTap,
  });

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: AppDimensions.md,
      runSpacing: AppDimensions.md,
      children: [
        _ActionTile(
          icon: Icons.grid_view_rounded,
          label: 'Categories',
          onTap: onCategoriesTap,
        ),
        _ActionTile(
          icon: Icons.local_offer_rounded,
          label: 'Deals',
          onTap: onDealsTap,
        ),
        _ActionTile(
          icon: Icons.shopping_bag_outlined,
          label: 'Cart',
          onTap: onCartTap,
        ),
        _ActionTile(
          icon: Icons.bookmark_border_rounded,
          label: 'Saved',
          onTap: onSavedTap,
        ),
      ],
    );
  }
}

class _ActionTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _ActionTile({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 124,
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppDimensions.radiusXl),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(AppDimensions.radiusXl),
          child: Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppDimensions.md,
              vertical: AppDimensions.md,
            ),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(AppDimensions.radiusXl),
              border: Border.all(color: AppColors.divider),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(AppDimensions.sm),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.08),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(icon, color: AppColors.primary),
                ),
                const SizedBox(height: AppDimensions.md),
                Text(
                  label,
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _CategoryShowcaseCard extends StatelessWidget {
  final ShopCategory category;
  final VoidCallback onTap;

  const _CategoryShowcaseCard({
    required this.category,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppDimensions.radiusXl),
      child: Container(
        padding: const EdgeInsets.all(AppDimensions.md),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(AppDimensions.radiusXl),
          border: Border.all(color: AppColors.divider),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 18,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Text(
                    category.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w800,
                        ),
                  ),
                ),
                const SizedBox(width: AppDimensions.sm),
                ShopArtwork(
                  categorySlug: category.slug,
                  size: 46,
                  iconSize: 20,
                ),
              ],
            ),
            const SizedBox(height: AppDimensions.sm),
            Text(
              category.description,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.textSecondary,
                  ),
            ),
            const Spacer(),
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppDimensions.sm,
                vertical: 4,
              ),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.08),
                borderRadius: BorderRadius.circular(AppDimensions.radiusCircular),
              ),
              child: Text(
                '${category.productCount} items',
                style: Theme.of(context).textTheme.labelMedium?.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w700,
                    ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SectionFeatureStrip extends StatelessWidget {
  final String title;
  final String subtitle;
  final String accentLabel;
  final IconData accentIcon;

  const _SectionFeatureStrip({
    required this.title,
    required this.subtitle,
    required this.accentLabel,
    required this.accentIcon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppDimensions.md),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppDimensions.radiusXl),
        border: Border.all(color: AppColors.divider),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(AppDimensions.sm),
            decoration: BoxDecoration(
              color: AppColors.secondary.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              accentIcon,
              color: AppColors.secondary,
            ),
          ),
          const SizedBox(width: AppDimensions.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                ),
              ],
            ),
          ),
          const SizedBox(width: AppDimensions.sm),
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppDimensions.sm,
              vertical: 4,
            ),
            decoration: BoxDecoration(
              color: AppColors.secondary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(AppDimensions.radiusCircular),
            ),
            child: Text(
              accentLabel,
              style: Theme.of(context).textTheme.labelMedium?.copyWith(
                    color: AppColors.secondary,
                    fontWeight: FontWeight.w700,
                  ),
            ),
          ),
        ],
      ),
    );
  }
}
