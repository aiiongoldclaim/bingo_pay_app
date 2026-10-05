import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/di/injection.dart';
import '../../../../core/router/app_routes.dart';
import '../../../../core/theme/app_theme_colors.dart';
import '../../domain/entities/category_entity.dart';
import '../../domain/entities/sub_category_entity.dart';
import '../cubit/sub_categories_cubit.dart';
import '../cubit/sub_categories_state.dart';
import '../widgets/categories_grid.dart';
import '../widgets/categories_metrics.dart';
import '../widgets/categories_shimmer.dart';

class SubCategoriesScreen extends StatelessWidget {
  const SubCategoriesScreen({
    super.key,
    required this.categoryUuid,
    this.categoryName,
  });

  final String categoryUuid;
  final String? categoryName;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<SubCategoriesCubit>()..load(categoryUuid),
      child: _SubCategoriesView(
        categoryUuid: categoryUuid,
        categoryName: categoryName,
      ),
    );
  }
}

class _SubCategoriesView extends StatelessWidget {
  const _SubCategoriesView({required this.categoryUuid, this.categoryName});

  final String categoryUuid;
  final String? categoryName;

  String _title(SubCategoriesState state) {
    if (state.breadcrumb.isNotEmpty) return state.breadcrumb.last.name;
    return categoryName ?? '';
  }

  void _openProducts(BuildContext context, String uuid, String name) {
    context.push(AppRoutes.productListingPath(name), extra: uuid);
  }

  void _openSubCategory(BuildContext context, SubCategoryEntity sub) {
    if (sub.uuid.isEmpty) return;
    if (sub.hasChildren) {
      context.push(AppRoutes.subCategoriesPath(sub.uuid), extra: sub.name);
    } else {
      // A leaf (e.g. Electronics › watch): load products by its own uuid,
      // without the extra full category-list call.
      context.push(
        AppRoutes.leafCategoryListingPath(sub.name),
        extra: sub.uuid,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final m = CategoriesMetrics.of(context);
    final colors = context.c;

    return Scaffold(
      backgroundColor: colors.background,
      body: SafeArea(
        bottom: false,
        child: BlocBuilder<SubCategoriesCubit, SubCategoriesState>(
          builder: (context, state) {
            final title = _title(state);

            return ConstrainedBox(
              constraints: BoxConstraints(maxWidth: m.contentMaxWidth),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _TopBar(metrics: m, title: title),
                  if (state.breadcrumb.isNotEmpty)
                    _Breadcrumb(metrics: m, items: state.breadcrumb),
                  Expanded(child: _body(context, state, m, title)),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _body(
    BuildContext context,
    SubCategoriesState state,
    CategoriesMetrics m,
    String title,
  ) {
    final colors = context.c;
    void retry() => context.read<SubCategoriesCubit>().load(categoryUuid);

    if (state.isLoading && state.subCategories.isEmpty) {
      return SubCategoriesShimmer(metrics: m);
    }

    if (state.error != null && state.subCategories.isEmpty) {
      return SingleChildScrollView(
        child: CategoriesStateMessage(
          metrics: m,
          isError: true,
          noun: 'sub-categories',
          onRetry: retry,
        ),
      );
    }

    // Same box cards as the Categories screen. CategoryTile takes a
    // CategoryEntity, so each sub-category is mapped by uuid and the tap
    // looks the original back up to keep its hasChildren flag.
    final subsByUuid = {for (final s in state.subCategories) s.uuid: s};
    final tiles = [
      for (final s in state.subCategories)
        CategoryEntity(
          id: s.uuid,
          uuid: s.uuid,
          name: s.name,
          slug: s.slug,
          image: s.image,
        ),
    ];

    return RefreshIndicator(
      color: colors.brand,
      backgroundColor: colors.surface,
      onRefresh: () => context.read<SubCategoriesCubit>().load(categoryUuid),
      child: CustomScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        slivers: [
          SliverToBoxAdapter(child: SizedBox(height: m.pagePadding * 0.5)),
          SliverToBoxAdapter(
            child: _AllProductsTile(
              metrics: m,
              title: title,
              onTap: () => _openProducts(context, categoryUuid, title),
            ),
          ),
          SliverToBoxAdapter(child: SizedBox(height: m.sectionGap)),
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: m.pagePadding),
              child: Text(
                'Sub-categories',
                style: TextStyle(
                  fontSize: m.sectionTitleSize,
                  fontWeight: FontWeight.w700,
                  color: colors.textPrimary,
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(child: SizedBox(height: m.pagePadding * 0.9)),
          if (state.subCategories.isEmpty)
            SliverToBoxAdapter(
              child: CategoriesStateMessage(
                metrics: m,
                isError: false,
                noun: 'sub-categories',
                onRetry: retry,
              ),
            )
          else
            CategoriesSliverGrid(
              metrics: m,
              categories: tiles,
              onCategoryTap: (tile) {
                final sub = subsByUuid[tile.uuid];
                if (sub != null) _openSubCategory(context, sub);
              },
            ),
          SliverToBoxAdapter(
            child: SizedBox(
              height: m.sectionGap + MediaQuery.paddingOf(context).bottom,
            ),
          ),
        ],
      ),
    );
  }
}

class _TopBar extends StatelessWidget {
  const _TopBar({required this.metrics, required this.title});

  final CategoriesMetrics metrics;
  final String title;

  @override
  Widget build(BuildContext context) {
    final colors = context.c;
    final m = metrics;

    return Padding(
      padding: EdgeInsets.fromLTRB(
        m.pagePadding * 0.4,
        m.pagePadding * 0.3,
        m.pagePadding,
        0,
      ),
      child: Row(
        children: [
          IconButton(
            onPressed: () => context.pop(),
            icon: Icon(
              Icons.arrow_back_ios_new_rounded,
              size: m.headerIconSize,
              color: colors.textPrimary,
            ),
          ),
          Expanded(
            child: Text(
              title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: m.sectionTitleSize * 1.1,
                fontWeight: FontWeight.w700,
                color: colors.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// `Categories › Electronics › Watch` — every step except the current one
/// navigates back up the tree.
class _Breadcrumb extends StatelessWidget {
  const _Breadcrumb({required this.metrics, required this.items});

  final CategoriesMetrics metrics;
  final List<CategoryBreadcrumbEntity> items;

  @override
  Widget build(BuildContext context) {
    final colors = context.c;
    final m = metrics;

    final crumbs = <Widget>[
      _crumb(
        context,
        label: 'Categories',
        onTap: () => context.go(AppRoutes.categories),
      ),
    ];

    for (var i = 0; i < items.length; i++) {
      final item = items[i];
      final isLast = i == items.length - 1;
      crumbs
        ..add(
          Icon(
            Icons.chevron_right_rounded,
            size: m.viewAllSize * 1.3,
            color: colors.textMuted,
          ),
        )
        ..add(
          _crumb(
            context,
            label: item.name,
            onTap: isLast || item.uuid.isEmpty
                ? null
                : () => context.pushReplacement(
                    AppRoutes.subCategoriesPath(item.uuid),
                    extra: item.name,
                  ),
          ),
        );
    }

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: EdgeInsets.symmetric(horizontal: m.pagePadding),
      child: Row(children: crumbs),
    );
  }

  Widget _crumb(
    BuildContext context, {
    required String label,
    VoidCallback? onTap,
  }) {
    final colors = context.c;
    final isCurrent = onTap == null;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(6),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
        child: Text(
          label,
          style: TextStyle(
            fontSize: metrics.viewAllSize,
            fontWeight: isCurrent ? FontWeight.w700 : FontWeight.w500,
            color: isCurrent ? colors.textPrimary : colors.brand,
          ),
        ),
      ),
    );
  }
}

class _AllProductsTile extends StatelessWidget {
  const _AllProductsTile({
    required this.metrics,
    required this.title,
    required this.onTap,
  });

  final CategoriesMetrics metrics;
  final String title;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.c;
    final m = metrics;

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: m.pagePadding),
      child: Material(
        color: colors.brandSoft,
        borderRadius: BorderRadius.circular(m.searchRadius),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(m.searchRadius),
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: m.pagePadding,
              vertical: m.pagePadding * 0.8,
            ),
            child: Row(
              children: [
                Icon(
                  Icons.grid_view_rounded,
                  size: m.searchIconSize,
                  color: colors.brand,
                ),
                SizedBox(width: m.pagePadding * 0.6),
                Expanded(
                  child: Text(
                    title.isEmpty ? 'View all products' : 'All $title products',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: m.categoryNameSize * 1.15,
                      fontWeight: FontWeight.w600,
                      color: colors.textPrimary,
                    ),
                  ),
                ),
                Icon(
                  Icons.arrow_forward_ios_rounded,
                  size: m.viewAllSize,
                  color: colors.textMuted,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
