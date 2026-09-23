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

/// The Vaults Luxe / Ultra Luxe dashboard body — a distinct content area
/// (never the plain TheVaults dashboard with data swapped in) reused for
/// both tiers via [section]. Mirrors TheVaults' overall structure — banner
/// then product sections — but never shows Book Service, and renders a
/// lavender skeleton while [isLoading] is true.
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

  bool get _isUltra => section == VaultSection.ultraLuxe;

  /// Vaults Luxe / Ultra Luxe reuse TheVaults' banner images (no separate
  /// assets exist) but wash them in the tier's own colour so they still
  /// read as a distinct section — Ultra Luxe deeper/darker than Vaults Luxe.
  Gradient get _bannerOverlay => LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: _isUltra
        ? [
            ThemeColors.vaultSelectorText.withValues(alpha: 0.35),
            ThemeColors.vaultSelectorText.withValues(alpha: 0.72),
          ]
        : [
            ThemeColors.vaultSelectorPrimary.withValues(alpha: 0.28),
            ThemeColors.vaultSelectorPrimary.withValues(alpha: 0.58),
          ],
  );

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return _LuxeContentShimmer(metrics: metrics, isUltra: _isUltra);
    }

    final dealsTitle = _isUltra ? 'Ultra Luxe Exclusives' : 'Vaults Luxe Edit';
    final recommendedTitle = _isUltra
        ? 'Handpicked For You'
        : 'Curated For You';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        PromoBannerCarousel(
          metrics: metrics,
          banners: HomeBanners.defaults,
          onBannerTap: (_) {},
          overlayGradient: _bannerOverlay,
        ),
        SizedBox(height: metrics.sectionGap),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: metrics.pagePadding),
          child: _LuxeTierBanner(metrics: metrics, isUltra: _isUltra),
        ),
        SizedBox(height: metrics.sectionGap),
        if (flashDeals.isEmpty && recommended.isEmpty)
          _LuxeEmptyState(metrics: metrics)
        else ...[
          if (flashDeals.isNotEmpty) ...[
            ProductRail(
              metrics: metrics,
              title: dealsTitle,
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
              title: recommendedTitle,
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

/// Gradient eyebrow that gives Vaults Luxe / Ultra Luxe their own premium
/// identity — Ultra Luxe uses a deeper gradient plus a gold hairline border
/// so it reads as a step above Vaults Luxe (and both above TheVaults).
class _LuxeTierBanner extends StatelessWidget {
  const _LuxeTierBanner({required this.metrics, required this.isUltra});

  final HomeMetrics metrics;
  final bool isUltra;

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
          colors: isUltra
              ? const [
                  ThemeColors.vaultSelectorText,
                  ThemeColors.vaultSelectorPrimary,
                ]
              : const [
                  ThemeColors.vaultSelectorPrimary,
                  ThemeColors.vaultSelectorLavender,
                ],
        ),
        borderRadius: BorderRadius.circular(metrics.heroRadius),
        border: isUltra
            ? Border.all(color: ThemeColors.accent, width: 1)
            : null,
      ),
      child: Row(
        children: [
          Icon(
            isUltra ? Icons.diamond_outlined : Icons.workspace_premium_outlined,
            color: isUltra ? ThemeColors.accent : Colors.white,
            size: metrics.headerIconSize,
          ),
          SizedBox(width: metrics.pagePadding * 0.6),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isUltra ? 'ULTRA LUXE' : 'VAULTS LUXE',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.2,
                    fontSize: metrics.sectionTitleSize * 0.85,
                  ),
                ),
                SizedBox(height: metrics.pagePadding * 0.2),
                Text(
                  isUltra
                      ? 'The pinnacle of curated luxury'
                      : 'Elevated picks, handpicked for you',
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

/// Skeleton shown while a Vaults Luxe / Ultra Luxe selection is "loading" —
/// deliberately omits any Book Service placeholder. Reuses the same
/// [ShimmerLoading]/[ShimmerBox] primitives as the dashboard's initial-load
/// skeleton, whose shimmer already sweeps over the theme's light-lavender
/// surface color, giving the "subtle lavender shimmer" for free.
class _LuxeContentShimmer extends StatelessWidget {
  const _LuxeContentShimmer({required this.metrics, required this.isUltra});

  final HomeMetrics metrics;
  final bool isUltra;

  @override
  Widget build(BuildContext context) {
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

/// Shimmer standing in for [HomeCategoryTabs] during the brief Vaults Luxe /
/// Ultra Luxe loading transition — same row shape as the initial-load
/// skeleton's category block, just reusable from outside it.
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
