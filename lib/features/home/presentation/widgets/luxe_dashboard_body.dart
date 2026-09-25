import 'package:flutter/material.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/widgets/shimmer_loading.dart';
import '../../data/models/product_model.dart';
import '../models/vault_section.dart';
import '../models/vault_theme_colors.dart';
import 'home_banner_data.dart';
import 'home_metrics.dart';
import 'product_rail.dart';
import 'promo_banner_carousel.dart';
import 'ultra_luxe_feature_card.dart';

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
    final activeTheme = VaultThemeColors.forSection(section);
    final tier = _tierPresentationFor(section, activeTheme);

    if (isLoading) {
      return const _LuxeContentShimmer();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        PromoBannerCarousel(
          metrics: metrics,
          banners: section == VaultSection.ultraLuxe
              ? HomeBanners.ultraLuxe
              : HomeBanners.defaults,
          onBannerTap: (_) {},
          overlayGradient: tier.bannerOverlay,
          borderColor: activeTheme.border,
          activeDotColor: activeTheme.primary,
          inactiveDotColor: activeTheme.secondary.withValues(alpha: 0.35),
          fallbackIconColor: activeTheme.secondaryText,
          fallbackBackgroundColor: activeTheme.sectionBackground,
        ),
        SizedBox(height: metrics.sectionGap),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: metrics.pagePadding),
          child: section == VaultSection.ultraLuxe
              ? UltraLuxeFeatureCard(
                  metrics: metrics,
                  activeTheme: activeTheme,
                  title: tier.eyebrow,
                  subtitle: tier.tagline,
                  onTap: onViewAll,
                )
              : _LuxeTierBanner(metrics: metrics, tier: tier),
        ),
        SizedBox(height: metrics.sectionGap),
        if (flashDeals.isEmpty && recommended.isEmpty)
          _LuxeEmptyState(metrics: metrics, activeTheme: activeTheme)
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
              activeTheme: activeTheme,
              titleHighlightPrefix: tier.highlightPrefix,
              titleHighlightColor: tier.highlightColor,
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
              activeTheme: activeTheme,
              titleHighlightPrefix: tier.highlightPrefix,
              titleHighlightColor: tier.highlightColor,
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
    required this.accentBorder,
    this.gradientStops,
    this.highlightPrefix,
    this.highlightColor,
  });

  final String eyebrow;
  final String tagline;
  final IconData icon;
  final List<Color> gradientColors;
  final List<double>? gradientStops;
  final Color accentBorder;
  final String dealsTitle;
  final String recommendedTitle;
  final Gradient? bannerOverlay;
  final String? highlightPrefix;
  final Color? highlightColor;
}

_TierPresentation _tierPresentationFor(
  VaultSection section,
  VaultThemeColors theme,
) {
  switch (section) {
    case VaultSection.vaultsLuxe:
      return _TierPresentation(
        eyebrow: 'VAULTS LUXE',
        tagline: 'Elevated picks, handpicked for you',
        icon: Icons.workspace_premium_outlined,
        gradientColors: [theme.primary, theme.secondary],
        accentBorder: theme.buttonText,
        dealsTitle: 'Vaults Luxe Edit',
        recommendedTitle: 'Curated For You',
        bannerOverlay: theme.bannerOverlay,
      );
    case VaultSection.ultraLuxe:
      return _TierPresentation(
        eyebrow: 'ULTRA LUXE',
        tagline: 'The pinnacle of curated luxury',
        icon: Icons.diamond_outlined,
        gradientColors: [
          theme.sectionBackground,
          theme.sectionBackground,
          theme.primary,
          theme.primary,
        ],
        gradientStops: const [0.0, 0.48, 0.52, 1.0],
        accentBorder: theme.primary,
        dealsTitle: 'Ultra Luxe Exclusives',
        recommendedTitle: 'Handpicked For You',
        bannerOverlay: null,
        highlightPrefix: 'Ultra Luxe',
        highlightColor: theme.primary,
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
          stops: tier.gradientStops,
        ),
        borderRadius: BorderRadius.circular(metrics.heroRadius),
        border: Border.all(color: tier.accentBorder, width: 1),
      ),
      child: Row(
        children: [
          Icon(tier.icon, color: tier.accentBorder, size: metrics.headerIconSize),
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
  const _LuxeEmptyState({required this.metrics, required this.activeTheme});

  final HomeMetrics metrics;
  final VaultThemeColors activeTheme;

  @override
  Widget build(BuildContext context) {
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
              color: activeTheme.text,
            ),
          ),
          SizedBox(height: metrics.pagePadding * 0.5),
          Text(
            AppStrings.noProductsRightNowSubtitle,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: metrics.heroBodySize,
              height: 1.55,
              color: activeTheme.secondaryText,
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
