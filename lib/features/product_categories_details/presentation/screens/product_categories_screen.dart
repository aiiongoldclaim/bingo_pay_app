import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:sizer/sizer.dart';
import '../../../../../core/theme/app_text_styles.dart';
import '../../../../../core/theme/theme_colors.dart';
import '../../../../core/router/app_routes.dart';
import '../../../../core/widgets/custom_app_bar.dart';
import '../../../../core/widgets/custom_container.dart';
import '../../../wishlist/data/models/wishlist_model.dart';
import '../../../wishlist/presentation/cubit/wishlist_cubit.dart';
import '../../data/models/product_categories_model.dart';
import '../product_categories_cubit/product_categories_cubit.dart';
import '../product_categories_cubit/product_categories_state.dart';
import '../widgets/filter_bar.dart';
import '../widgets/listing_product_card.dart';
import '../widgets/listing_results_bar.dart';

String _formatListingPrice(double value) {
  final s = value.truncate().toString();
  final buf = StringBuffer();
  for (int i = 0; i < s.length; i++) {
    final fromEnd = s.length - i;
    buf.write(s[i]);
    final rem = fromEnd - 1;
    if (rem == 3 || (rem > 3 && (rem - 3) % 2 == 0)) buf.write(',');
  }
  return buf.toString();
}

WishlistItem _toWishlistItem(ListingProductModel product) => WishlistItem(
      id: product.uuid!,
      brand: product.brand,
      name: product.name,
      price:
          product.price > 0 ? '\$${_formatListingPrice(product.price)}' : 'N/A',
      originalPrice: product.originalPrice != null && product.originalPrice! > 0
          ? '\$${_formatListingPrice(product.originalPrice!)}'
          : null,
      discountPercent: product.discountPercent,
      imageUrl: product.imageUrl,
      rating: (product.rating ?? 0).toStringAsFixed(1),
      reviewCount: product.ratingCount ?? 0,
      badge: product.badge,
    );

class ProductListingScreen extends StatelessWidget {
  final String categoryName;
  final String categoryUuid;

  const ProductListingScreen({
    super.key,
    required this.categoryName,
    required this.categoryUuid,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) =>
          ProductListingCubit()..loadCategory(categoryName, categoryUuid),
      child: _ProductListingView(categoryName: categoryName),
    );
  }
}

class _ProductListingView extends StatelessWidget {
  final String categoryName;
  const _ProductListingView({required this.categoryName});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ProductListingCubit, ProductListingState>(
      builder: (context, state) {
        final cubit = context.read<ProductListingCubit>();

        return Scaffold(
          backgroundColor: ThemeColors.background,
          appBar: CustomAppBar(
            title: categoryName,
            actionIcon1: Icons.search,
            onAction1: () {
              context.push(AppRoutes.search);
            },
            // actionIcon2: Icons.delete,
            // onAction2: () {},
          ),

          body: Column(
            children: [
              // // ── Sticky filter  ────────────────────
              if (state is ProductListingLoaded) ...[
                ListingFilterBar(
                  selectedSort: state.selectedSort,
                  selectedPriceFilter: state.selectedPriceFilter,
                  selectedRatingFilter: state.selectedRatingFilter,
                  onFilterTap: () {},
                  onSortTap: cubit.applySort,
                  onPriceFilter: cubit.applyPriceFilter,
                  onRatingFilter: cubit.applyRatingFilter,
                ),
              ],

              // ── Body ─────────────────────────────────────────────────────
              Expanded(
                child: switch (state) {
                  ProductListingLoading() => const Center(
                    child: CircularProgressIndicator(color: ThemeColors.blue),
                  ),

                  ProductListingError(:final message) => Center(
                    child: Text(message),
                  ),

                  ProductListingLoaded() => CustomScrollView(
                    slivers: [
                      SliverToBoxAdapter(
                        child: ListingResultsBar(
                          count: state.filteredProducts.length,
                          viewMode: state.viewMode,
                          onToggleView: cubit.toggleViewMode,
                        ),
                      ),

                      if (state.filteredProducts.isEmpty)
                        SliverFillRemaining(
                          hasScrollBody: false,
                          child: _EmptyProductsState(
                            hasActiveFilters: state.selectedPriceFilter != null ||
                                state.selectedRatingFilter != null,
                            onClearFilters: cubit.clearFilters,
                          ),
                        )
                      else if (state.viewMode == ViewMode.grid)
                        SliverPadding(
                          padding: EdgeInsets.symmetric(horizontal: 4.w),
                          sliver: SliverGrid(
                            gridDelegate:
                                SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 2,
                                  crossAxisSpacing: 3.w,
                                  mainAxisSpacing: 2.h,
                                  childAspectRatio: 0.62,
                                ),
                            delegate: SliverChildBuilderDelegate((
                              context,
                              index,
                            ) {
                              final product = state.filteredProducts[index];
                              final wishlist = context.watch<WishlistCubit>();

                              return ListingProductCard(
                                product: product.copyWith(
                                  isFavourite:
                                      wishlist.isWishlisted(product.uuid),
                                ),

                                onTap: product.uuid != null
                                    ? () => context.push(
                                          AppRoutes.productDetails,
                                          extra: product.uuid,
                                        )
                                    : null,
                                onFavouriteTap: product.uuid == null
                                    ? null
                                    : () => context
                                        .read<WishlistCubit>()
                                        .toggle(_toWishlistItem(product)),
                              );
                            }, childCount: state.filteredProducts.length),
                          ),
                        )
                      else
                        SliverPadding(
                          padding: EdgeInsets.symmetric(horizontal: 4.w),
                          sliver: SliverList(
                            delegate: SliverChildBuilderDelegate((
                              context,
                              index,
                            ) {
                              final product = state.filteredProducts[index];
                              final wishlist = context.watch<WishlistCubit>();

                              return Padding(
                                padding: EdgeInsets.only(bottom: 2.h),
                                child: SizedBox(
                                  height: 18.h,
                                  child: ListingProductCard(
                                    product: product.copyWith(
                                      isFavourite:
                                          wishlist.isWishlisted(product.uuid),
                                    ),
                                    onTap: product.uuid != null
                                    ? () => context.push(
                                          AppRoutes.productDetails,
                                          extra: product.uuid,
                                        )
                                    : null,
                                    onFavouriteTap: product.uuid == null
                                        ? null
                                        : () => context
                                            .read<WishlistCubit>()
                                            .toggle(_toWishlistItem(product)),
                                  ),
                                ),
                              );
                            }, childCount: state.filteredProducts.length),
                          ),
                        ),

                      SliverToBoxAdapter(child: SizedBox(height: 3.h)),
                    ],
                  ),

                  _ => const SizedBox.shrink(),
                },
              ),
            ],
          ),
        );
      },
    );
  }
}

class _EmptyProductsState extends StatelessWidget {
  const _EmptyProductsState({
    required this.hasActiveFilters,
    this.onClearFilters,
  });

  final bool hasActiveFilters;
  final VoidCallback? onClearFilters;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: EdgeInsets.all(5.w),
              decoration: const BoxDecoration(
                color: ThemeColors.blueSoft,
                shape: BoxShape.circle,
              ),
              child: Icon(
                hasActiveFilters
                    ? Icons.filter_alt_off_outlined
                    : Icons.inventory_2_outlined,
                size: 32,
                color: ThemeColors.blue,
              ),
            ),
            SizedBox(height: 2.h),
            Text(
              hasActiveFilters ? 'No matching products' : 'No products yet',
              style: AppTextStyles.titleMedium,
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 1.h),
            Text(
              hasActiveFilters
                  ? 'Try adjusting or clearing your filters to see more results.'
                  : 'This category is currently empty. Check back later for new arrivals.',
              style: AppTextStyles.bodyMedium,
              textAlign: TextAlign.center,
            ),
            if (hasActiveFilters && onClearFilters != null) ...[
              SizedBox(height: 2.5.h),
              OutlinedButton(
                onPressed: onClearFilters,
                style: OutlinedButton.styleFrom(
                  foregroundColor: ThemeColors.blue,
                  side: const BorderSide(color: ThemeColors.blue),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(24),
                  ),
                  padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 1.2.h),
                ),
                child: const Text('Clear filters'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
