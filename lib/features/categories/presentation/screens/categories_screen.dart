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
import '../cubit/categories_cubit.dart';
import '../cubit/categories_state.dart';
import '../widgets/brand_grid.dart';
import '../widgets/categories_benefits_strip.dart';
import '../widgets/categories_grid.dart';
import '../widgets/categories_metrics.dart';
import '../widgets/cat_search_field.dart';
import '../widgets/cat_section_header.dart';
import '../widgets/curated_collection_list.dart';
import '../widgets/popular_categories_rail.dart';

class CategoriesScreen extends StatelessWidget {
  const CategoriesScreen({super.key});

  static const List<CatBenefitData> _benefits = [
    CatBenefitData(
      icon: Icons.local_shipping_outlined,
      title: 'Free Shipping',
      subtitle: 'On orders above ₹499',
    ),
    CatBenefitData(
      icon: Icons.shield_outlined,
      title: 'Secure Payment',
      subtitle: '100% secure payments',
    ),
    CatBenefitData(
      icon: Icons.replay_rounded,
      title: 'Easy Returns',
      subtitle: '7 days return policy',
    ),
    CatBenefitData(
      icon: Icons.headset_mic_outlined,
      title: '24/7 Support',
      subtitle: "We're here to help you",
    ),
  ];

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

  void _openCategory(BuildContext context, String name, String? uuid) {
    context.push('/product-listing/${Uri.encodeComponent(name)}', extra: uuid);
  }

  @override
  Widget build(BuildContext context) {
    final m = CategoriesMetrics.of(context);
    final c = context.c;

    return Scaffold(
      backgroundColor: c.background,
      appBar: AppBar(
        backgroundColor: c.background,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        leading: Padding(
          padding: EdgeInsets.only(left: m.pagePadding * 0.5),
          child: InkResponse(
            onTap: () => context.pop(),
            child: Container(
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: c.brandSoft,
                borderRadius: BorderRadius.circular(m.searchRadius),
              ),
              child: Icon(
                Icons.arrow_back_rounded,
                size: m.searchIconSize,
                color: c.brand,
              ),
            ),
          ),
        ),
        title: Text(
          'Categories',
          style: TextStyle(
            fontSize: m.sectionTitleSize * 1.25,
            fontWeight: FontWeight.w700,
            color: c.textPrimary,
          ),
        ),
        actions: [
          Padding(
            padding: EdgeInsets.only(right: m.pagePadding),
            child: InkResponse(
              onTap: () => context.push(AppRoutes.search),
              child: Container(
                width: m.searchHeight * 0.82,
                height: m.searchHeight * 0.82,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: c.surface,
                  borderRadius: BorderRadius.circular(m.searchRadius),
                  border: Border.all(color: c.border),
                ),
                child: Icon(
                  Icons.search_rounded,
                  size: m.searchIconSize,
                  color: c.textPrimary,
                ),
              ),
            ),
          ),
        ],
      ),
      body: BlocBuilder<CategoriesCubit, CategoriesState>(
        builder: (context, state) {
          if (state.isLoading) {
            return Center(child: CircularProgressIndicator(color: c.brand));
          }

          return Center(
            child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: m.contentMaxWidth),
              child: CustomScrollView(
                slivers: [
                  // ── Search ────────────────────────────────
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: EdgeInsets.fromLTRB(
                        m.pagePadding,
                        m.pagePadding * 0.4,
                        m.pagePadding,
                        0,
                      ),
                      child: CatSearchField(
                        metrics: m,
                        hintText: 'Search for categories...',
                        onTap: () => context.push(AppRoutes.search),
                      ),
                    ),
                  ),

                  SliverToBoxAdapter(child: SizedBox(height: m.sectionGap)),

                  // ── All Categories ────────────────────────
                  if (state.categories.isNotEmpty) ...[
                    SliverToBoxAdapter(
                      child: CatSectionHeader(
                        metrics: m,
                        title: 'All Categories',
                        actionText: 'View All',
                        onActionTap: () => context.push(AppRoutes.allProducts),
                      ),
                    ),
                    SliverToBoxAdapter(
                      child: SizedBox(height: m.pagePadding * 0.8),
                    ),
                    SliverToBoxAdapter(
                      child: CategoriesGrid(
                        metrics: m,
                        categories: state.categories,
                        onCategoryTap: (cat) =>
                            _openCategory(context, cat.name, cat.uuid),
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
                    child: SizedBox(height: m.pagePadding * 0.8),
                  ),
                  SliverToBoxAdapter(
                    child: BrandsGrid(
                      metrics: m,
                      brands: state.brands,
                      isLoading: state.isBrandsLoading,
                      error: state.brandsError,
                      onBrandTap: (brand) {},
                    ),
                  ),

                  SliverToBoxAdapter(child: SizedBox(height: m.sectionGap)),

                  // ── Curated Collections ───────────────────
                  if (state.collections.isNotEmpty) ...[
                    SliverToBoxAdapter(
                      child: CatSectionHeader(
                        metrics: m,
                        title: 'Curated Collection',
                        actionText: 'View All',
                        onActionTap: () => context.push(AppRoutes.allProducts),
                      ),
                    ),
                    SliverToBoxAdapter(
                      child: SizedBox(height: m.pagePadding * 0.8),
                    ),
                    SliverToBoxAdapter(
                      child: CuratedCollectionsList(
                        metrics: m,
                        collections: state.collections,
                        onCollectionTap: (col) {},
                      ),
                    ),
                    SliverToBoxAdapter(child: SizedBox(height: m.sectionGap)),
                  ],

                  // ── Popular Categories ────────────────────
                  if (state.categories.isNotEmpty) ...[
                    SliverToBoxAdapter(
                      child: CatSectionHeader(
                        metrics: m,
                        title: 'Popular Categories',
                      ),
                    ),
                    SliverToBoxAdapter(
                      child: SizedBox(height: m.pagePadding * 0.8),
                    ),
                    SliverToBoxAdapter(
                      child: PopularCategoriesRail(
                        metrics: m,
                        categories: state.categories,
                        onCategoryTap: (cat) =>
                            _openCategory(context, cat.name, cat.uuid),
                      ),
                    ),
                    SliverToBoxAdapter(child: SizedBox(height: m.sectionGap)),
                  ],

                  // ── Benefits ──────────────────────────────
                  SliverToBoxAdapter(
                    child: CategoriesBenefitsStrip(
                      metrics: m,
                      benefits: CategoriesScreen._benefits,
                    ),
                  ),

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
    );
  }
}
