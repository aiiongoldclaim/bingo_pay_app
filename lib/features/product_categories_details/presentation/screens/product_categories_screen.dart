import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:sizer/sizer.dart';
import '../../../../../core/theme/theme_colors.dart';
import '../../../../core/router/app_routes.dart';
import '../../../../core/widgets/custom_app_bar.dart';
import '../product_categories_cubit/product_categories_cubit.dart';
import '../product_categories_cubit/product_categories_state.dart';
import '../widgets/filter_bar.dart';
import '../widgets/listing_product_card.dart';
import '../widgets/listing_results_bar.dart';

class ProductListingScreen extends StatelessWidget {
  final String categoryName;

  const ProductListingScreen({super.key, required this.categoryName});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => ProductListingCubit()..loadCategory(categoryName),
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
            leading: IconButton(
              icon: const Icon(
                Icons.arrow_back_ios_new_rounded,
                color: ThemeColors.ink,
                size: 20,
              ),
              onPressed: () => Navigator.of(context).pop(),
            ),
            title: categoryName,
            actionIcon1: Icons.search,
            onAction1: () {
              context.push(AppRoutes.search);
            },
            actionIcon2: Icons.delete,
            onAction2: () {},
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
                        const SliverFillRemaining(
                          child: Center(
                            child: Text('No products match your filters.'),
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

                              return ListingProductCard(
                                product: product,
                                onTap: () {},
                                onFavouriteTap: () =>
                                    cubit.toggleFavourite(product.id),
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

                              return Padding(
                                padding: EdgeInsets.only(bottom: 2.h),
                                child: SizedBox(
                                  height: 18.h,
                                  child: ListingProductCard(
                                    product: product,
                                    onTap: () {},
                                    onFavouriteTap: () =>
                                        cubit.toggleFavourite(product.id),
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
