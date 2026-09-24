import 'package:flutter/material.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/theme/app_theme_colors.dart';
import '../../../../core/theme/theme_colors.dart';
import '../../../../core/widgets/shimmer_loading.dart';
import '../../data/models/product_model.dart';
import '../models/vault_section.dart';
import 'home_banner_data.dart';
import 'home_metrics.dart';
import 'product_rail.dart';
import 'promo_banner_carousel.dart';

class LuxeDashboardBody extends StatelessWidget {
  const LuxeDashboardBody({
    super.key,
    required this.metrics,
    required this.section,
    required this.isLoading,
    required this.flashDeals,
    required this.recommended,
    required this.onProductTap,
    required this.onWishlistTap,
    required this.onAddToCart,
    required this.addingIds,
    required this.onViewAll,
  }) : assert(
         section != VaultSection.theVaults,
         'LuxeDashboardBody is only for Vaults Luxe / Ultra Luxe',
       );

  final HomeMetrics metrics;
  final VaultSection section;
  final bool isLoading;
  final List<ProductModel> flashDeals;
  final List<ProductModel> recommended;
  final ValueChanged<ProductModel> onProductTap;
  final ValueChanged<ProductModel> onWishlistTap;
  final ValueChanged<ProductModel> onAddToCart;
  final Set<String> addingIds;
  final VoidCallback onViewAll;

  @override
  Widget build(BuildContext context) {
    final tier = _tierPresentationFor(section);

    if (isLoading) {
      return const _LuxeContentShimmer();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        PromoBannerCarousel(
          metrics: metrics,
          banners: HomeBanners.defaults,
          onBannerTap: (_) {},
          overlayGradient: tier.bannerOverlay,
        ),
        SizedBox(height: metrics.sectionGap),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: metrics.pagePadding),
          child: _LuxeTierBanner(metrics: metrics, tier: tier),
        ),
        SizedBox(height: metrics.sectionGap),
        if (flashDeals.isEmpty && recommended.isEmpty)
          _LuxeEmptyState(metrics: metrics)
        else ...[
          if (flashDeals.isNotEmpty) ...[
            ProductRail(
              metrics: metrics,
              title: tier.dealsTitle,
              actionText: AppStrings.viewAll,
              products: flashDeals,
              onActionTap: onViewAll,
              onProductTap: onProductTap,
              onWishlistTap: onWishlistTap,
              onAddToCart: onAddToCart,
              addingIds: addingIds,
            ),
            SizedBox(height: metrics.sectionGap),
          ],
          if (recommended.isNotEmpty)
            ProductRail(
              metrics: metrics,
              title: tier.recommendedTitle,
              actionText: AppStrings.viewAll,
              products: recommended,
              onActionTap: onViewAll,
              onProductTap: onProductTap,
              onWishlistTap: onWishlistTap,
              onAddToCart: onAddToCart,
              addingIds: addingIds,
            ),
        ],
        SizedBox(height: metrics.sectionGap),
      ],
    );
  }
}


class _TierPresentation {
  const _TierPresentation({
    required this.eyebrow,
    required this.tagline,
    required this.icon,
    required this.gradientColors,
    required this.dealsTitle,
    required this.recommendedTitle,
    required this.bannerOverlay,
    this.accentBorder,
  });

  final String eyebrow;
  final String tagline;
  final IconData icon;
  final List<Color> gradientColors;
  final Color? accentBorder;
  final String dealsTitle;
  final String recommendedTitle;
  final Gradient bannerOverlay;
}

_TierPresentation _tierPresentationFor(VaultSection section) {
  switch (section) {
    case VaultSection.vaultsLuxe:
      return _TierPresentation(
        eyebrow: 'VAULTS LUXE',
        tagline: 'Elevated picks, handpicked for you',
        icon: Icons.workspace_premium_outlined,
        gradientColors: const [
          ThemeColors.vaultSelectorPrimary,
          ThemeColors.vaultSelectorLavender,
        ],
        dealsTitle: 'Vaults Luxe Edit',
        recommendedTitle: 'Curated For You',
        bannerOverlay: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            ThemeColors.vaultSelectorPrimary.withValues(alpha: 0.28),
            ThemeColors.vaultSelectorPrimary.withValues(alpha: 0.58),
          ],
        ),
      );
    case VaultSection.ultraLuxe:

      return _TierPresentation(
        eyebrow: 'ULTRA LUXE',
        tagline: 'The pinnacle of curated luxury',
        icon: Icons.diamond_outlined,
        gradientColors: const [
          ThemeColors.vaultSelectorText,
          ThemeColors.vaultSelectorPrimary,
        ],
        accentBorder: ThemeColors.accent,
        dealsTitle: 'Ultra Luxe Exclusives',
        recommendedTitle: 'Handpicked For You',
        bannerOverlay: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            ThemeColors.vaultSelectorText.withValues(alpha: 0.35),
            ThemeColors.vaultSelectorText.withValues(alpha: 0.72),
          ],
        ),
      );
    case VaultSection.theVaults:
      throw StateError('LuxeDashboardBody is only for non-default sections');
  }
}


class _LuxeTierBanner extends StatelessWidget {
  const _LuxeTierBanner({required this.metrics, required this.tier});

  final HomeMetrics metrics;
  final _TierPresentation tier;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: metrics.pagePadding,
        vertical: metrics.pagePadding * 0.8,
      ),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          colors: tier.gradientColors,
        ),
        borderRadius: BorderRadius.circular(metrics.heroRadius),
        border: tier.accentBorder != null
            ? Border.all(color: tier.accentBorder!, width: 1)
            : null,
      ),
      child: Row(
        children: [
          Icon(
            tier.icon,
            color: tier.accentBorder ?? Colors.white,
            size: metrics.headerIconSize,
          ),
          SizedBox(width: metrics.pagePadding * 0.6),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  tier.eyebrow,
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.2,
                    fontSize: metrics.sectionTitleSize * 0.85,
                  ),
                ),
                SizedBox(height: metrics.pagePadding * 0.2),
                Text(
                  tier.tagline,
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.85),
                    fontSize: metrics.heroBodySize * 0.9,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _LuxeEmptyState extends StatelessWidget {
  const _LuxeEmptyState({required this.metrics});

  final HomeMetrics metrics;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: metrics.pagePadding * 1.5,
        vertical: metrics.sectionGap,
      ),
      child: Column(
        children: [
          Text(
            AppStrings.noProductsRightNow,
            style: TextStyle(
              fontSize: metrics.sectionTitleSize * 1.1,
              fontWeight: FontWeight.w700,
              color: colors.textPrimary,
            ),
          ),
          SizedBox(height: metrics.pagePadding * 0.5),
          Text(
            AppStrings.noProductsRightNowSubtitle,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: metrics.heroBodySize,
              height: 1.55,
              color: colors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}


class _LuxeContentShimmer extends StatelessWidget {
  const _LuxeContentShimmer();

  @override
  Widget build(BuildContext context) {
    final metrics = HomeMetrics.of(context);

    return ShimmerLoading(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: metrics.pagePadding),
            child: ShimmerBox(
              width: double.infinity,
              height: metrics.heroHeight,
              borderRadius: BorderRadius.circular(metrics.heroRadius),
            ),
          ),
          SizedBox(height: metrics.sectionGap),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: metrics.pagePadding),
            child: ShimmerBox(
              width: double.infinity,
              height: metrics.serviceTileSize * 0.9,
              borderRadius: BorderRadius.circular(metrics.heroRadius * 0.75),
            ),
          ),
          SizedBox(height: metrics.sectionGap),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: metrics.pagePadding),
            child: ShimmerBox(
              width: metrics.productCardWidth,
              height: metrics.sectionTitleSize,
            ),
          ),
          SizedBox(height: metrics.pagePadding * 0.8),
          SizedBox(
            height: metrics.productCardHeight,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              physics: const NeverScrollableScrollPhysics(),
              padding: EdgeInsets.symmetric(horizontal: metrics.pagePadding),
              itemCount: 4,
              separatorBuilder: (_, __) =>
                  SizedBox(width: metrics.pagePadding * 0.7),
              itemBuilder: (_, __) => SizedBox(
                width: metrics.productCardWidth,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ShimmerBox(
                      width: metrics.productCardWidth,
                      height: metrics.productImageHeight,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    SizedBox(height: metrics.pagePadding * 0.5),
                    ShimmerBox(
                      width: metrics.productCardWidth * 0.6,
                      height: metrics.productBrandSize,
                    ),
                    SizedBox(height: metrics.pagePadding * 0.3),
                    ShimmerBox(
                      width: metrics.productCardWidth * 0.85,
                      height: metrics.productNameSize,
                    ),
                    SizedBox(height: metrics.pagePadding * 0.3),
                    ShimmerBox(
                      width: metrics.productCardWidth * 0.5,
                      height: metrics.productPriceSize,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class LuxeCategoryShimmer extends StatelessWidget {
  const LuxeCategoryShimmer({super.key, required this.metrics});

  final HomeMetrics metrics;

  @override
  Widget build(BuildContext context) {
    return ShimmerLoading(
      child: SizedBox(
        height: metrics.tabBarHeight,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          physics: const NeverScrollableScrollPhysics(),
          padding: EdgeInsets.symmetric(horizontal: metrics.pagePadding),
          itemCount: 6,
          separatorBuilder: (_, __) => SizedBox(width: metrics.tabGap),
          itemBuilder: (_, __) => Center(
            child: ShimmerBox(
              width: metrics.tabFontSize * 4,
              height: metrics.tabFontSize,
            ),
          ),
        ),
      ),
    );
  }
}
