// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:go_router/go_router.dart';
// import 'package:sizer/sizer.dart';
//
// import '../../../../core/di/injection.dart';
// import '../../../../core/router/app_routes.dart';
// import '../../../../core/theme/theme_colors.dart';
// import '../../../../core/widgets/custom_app_bar.dart';
// import '../cubit/categories_cubit.dart';
// import '../cubit/categories_state.dart';
// import '../widgets/brand_grid.dart';
// import '../widgets/categories_grid.dart';
// import '../widgets/curated_collection_list.dart';
// import '../widgets/section_header.dart';
//
// class CategoriesScreen extends StatelessWidget {
//   const CategoriesScreen({super.key});
//
//   @override
//   Widget build(BuildContext context) {
//     return BlocProvider(
//       create: (_) => getIt<CategoriesCubit>()..loadData(),
//       child: BlocBuilder<CategoriesCubit, CategoriesState>(
//         builder: (context, state) {
//           return AnnotatedRegion<SystemUiOverlayStyle>(
//             value: const SystemUiOverlayStyle(
//               statusBarColor: Colors.transparent,
//               statusBarIconBrightness: Brightness.light,
//               statusBarBrightness: Brightness.dark,
//             ),
//             child: Scaffold(
//               backgroundColor: ThemeColors.background,
//               appBar: CustomAppBar(
//                 title: 'Categories',
//                 actionIcon1: Icons.search_rounded,
//                 onAction1: () {
//                   context.push(AppRoutes.search);
//                 },
//               ),
//               body: SafeArea(
//                 top: false,
//                 child: state.isLoading
//                     ? const Center(child: CircularProgressIndicator())
//                     : SingleChildScrollView(
//                         padding: EdgeInsets.all(4.w),
//                         child: Column(
//                           crossAxisAlignment: CrossAxisAlignment.start,
//                           children: [
//                             if (state.categories.isNotEmpty) ...[
//                               const SectionTitle(title: 'Categories'),
//                               SizedBox(height: 2.h),
//                               CategoriesGrid(categories: state.categories),
//                               SizedBox(height: 2.h),
//                             ],
//
//                             const SectionTitle(title: 'Top brands'),
//                             SizedBox(height: 2.h),
//                             BrandsGrid(
//                               brands: state.brands,
//                               isLoading: state.isBrandsLoading,
//                               error: state.brandsError,
//                             ),
//
//                             SizedBox(height: 2.h),
//
//                             const SectionTitle(title: 'Curated collections'),
//                             SizedBox(height: 2.h),
//                             CuratedCollectionsList(
//                               collections: state.collections,
//                             ),
//
//                             SizedBox(height: 2.h),
//                           ],
//                         ),
//                       ),
//               ),
//             ),
//           );
//         },
//       ),
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/di/injection.dart';
import '../../../../core/router/app_routes.dart';
import '../../../../core/theme/app_theme_colors.dart';
import '../../../cart/presentation/cubit/cart_cubit.dart';
import '../../../cart/presentation/cubit/cart_state.dart';
import '../cubit/categories_cubit.dart';
import '../cubit/categories_state.dart';
import '../widgets/brand_grid.dart';
import '../widgets/cat_header.dart';
import '../../../../core/widgets/cat_search_field.dart';
import '../widgets/cat_section_header.dart';
import '../widgets/categories_grid.dart';
import '../widgets/categories_metrics.dart';
import '../widgets/categories_shimmer.dart';
import '../widgets/curated_collection_list.dart';

class CategoriesScreen extends StatelessWidget {
  const CategoriesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<CategoriesCubit>()..loadData(),
      child: const _CategoriesView(),
    );
  }
}

class _CategoriesView extends StatelessWidget {
  const _CategoriesView();


  @override
  Widget build(BuildContext context) {
    final m = CategoriesMetrics.of(context);
    final colors = context.c;

    return Scaffold(
      backgroundColor: colors.background,
      body: SafeArea(
        bottom: false,
        child: BlocBuilder<CategoriesCubit, CategoriesState>(
          builder: (context, state) {
            if (state.isLoading) {
              return CategoriesShimmer(metrics: m);
              // return Center(child: CircularProgressIndicator(color: c.brand));
            }

            return Center(
              child: ConstrainedBox(
                constraints: BoxConstraints(maxWidth: m.contentMaxWidth),
                child: CustomScrollView(
                  slivers: [
                    // ── Header ────────────────────────────────
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: EdgeInsets.fromLTRB(
                          m.pagePadding,
                          m.pagePadding * 0.5,
                          m.pagePadding,
                          0,
                        ),
                        child: BlocBuilder<CartCubit, CartState>(
                          buildWhen: (a, b) => a.totalItems != b.totalItems,
                          builder: (context, cartState) => CatHeader(
                            metrics: m,
                            brandName: 'TheVaults',
                            tagline: 'Style. Curated for You.',
                            cartCount: cartState.totalItems,
                            onWishlistTap: () =>
                                context.push(AppRoutes.buyerWishlist),
                            onCartTap: () => context.push(AppRoutes.cart),
                          ),
                        ),
                      ),
                    ),

                    SliverToBoxAdapter(
                      child: SizedBox(height: m.pagePadding * 0.9),
                    ),

                    // ── Search ────────────────────────────────
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: m.pagePadding,
                        ),
                        child:
                        CatSearchField(
                          metrics: m,
                          hintText: 'Search for categories, brands & more',
                          onTap: () => context.push(AppRoutes.search),
                        ),
                      ),
                    ),

                    SliverToBoxAdapter(child: SizedBox(height: m.sectionGap)),

                    // ── Categories ────────────────────────────
                    if (state.categories.isNotEmpty) ...[
                      SliverToBoxAdapter(
                        child: CatSectionHeader(
                          metrics: m,
                          title: 'Categories',
                          actionText: '',
                          onActionTap: () =>
                              context.push(AppRoutes.allProducts),
                        ),
                      ),
                      SliverToBoxAdapter(
                        child: SizedBox(height: m.pagePadding * 0.9),
                      ),
                      // SliverToBoxAdapter(
                      //   child: CategoriesGrid(
                      //     metrics: m,
                      //     categories: state.categories,
                      //     // onCategoryTap: (cat) =>
                      //     //     _openCategory(context, cat.name, cat.uuid),
                      //   ),
                      // ),
                      SliverToBoxAdapter(
                        child: CategoriesGrid(
                          metrics: m,
                          categories: state.categories,
                          onCategoryTap: (category) {
                            if (category.uuid == null || category.uuid!.isEmpty) return;
                            context.push(
                              AppRoutes.productListingPath(category.name),
                              extra: category.uuid,
                            );
                          },
                        ),
                      ),
                      SliverToBoxAdapter(child: SizedBox(height: m.sectionGap)),
                    ],

                    // ── Top Brands ────────────────────────────
                    SliverToBoxAdapter(
                      child: CatSectionHeader(
                        metrics: m,
                        title: 'Top Brands',
                        actionText: state.brands.isEmpty ? null : 'View All',
                        onActionTap: state.brands.isEmpty
                            ? null
                            : () => context.push(AppRoutes.allProducts),
                      ),
                    ),
                    SliverToBoxAdapter(
                      child: SizedBox(height: m.pagePadding * 0.9),
                    ),
                    SliverToBoxAdapter(
                      child: BrandsGrid(
                        metrics: m,
                        brands: state.brands,
                        isLoading: state.isBrandsLoading,
                        error: state.brandsError,
                        // logoResolver: (b) => b.logoUrl,
                        onBrandTap: (brand) => context.push(AppRoutes.allProducts),
                      ),
                    ),

                    SliverToBoxAdapter(child: SizedBox(height: m.sectionGap)),

                    // ── Curated Collection ────────────────────
                    if (state.collections.isNotEmpty) ...[
                      SliverToBoxAdapter(
                        child: CatSectionHeader(
                          metrics: m,
                          title: 'Curated Collection',
                          actionText: 'View All',
                          onActionTap: () =>
                              context.push(AppRoutes.allProducts),
                        ),
                      ),
                      SliverToBoxAdapter(
                        child: SizedBox(height: m.pagePadding * 0.9),
                      ),
                      SliverToBoxAdapter(
                        child: CuratedCollectionsList(
                          metrics: m,
                          collections: state.collections,
                          // imageResolver: (col) => col.imageUrl,
                          onCollectionTap: (col) {},
                        ),
                      ),
                      SliverToBoxAdapter(child: SizedBox(height: m.sectionGap)),
                    ],

                    SliverToBoxAdapter(
                      child: SizedBox(
                        height:
                            m.sectionGap + MediaQuery.paddingOf(context).bottom,
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
