import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../../core/router/app_routes.dart';
import '../../../../../core/theme/app_dimensions.dart';
import '../../../../../core/widgets/app_text_field.dart';
import '../../domain/entities/shop_category.dart';
import '../bloc/shop_bloc.dart';
import '../bloc/shop_event.dart';
import '../bloc/shop_state.dart';
import '../widgets/shop_widgets.dart';

class CatalogScreen extends StatefulWidget {
  final String title;
  final String? subtitle;
  final String initialQuery;
  final String initialCategorySlug;

  const CatalogScreen({
    super.key,
    this.title = 'Catalog',
    this.subtitle,
    this.initialQuery = '',
    this.initialCategorySlug = '',
  });

  @override
  State<CatalogScreen> createState() => _CatalogScreenState();
}

class _CatalogScreenState extends State<CatalogScreen> {
  late final TextEditingController _searchController;
  bool _didBootstrap = false;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController(text: widget.initialQuery);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_didBootstrap) return;
    _didBootstrap = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final bloc = context.read<ShopBloc>();
      if (widget.initialCategorySlug.isNotEmpty) {
        bloc.add(ShopCategorySelected(widget.initialCategorySlug));
      }
      if (widget.initialQuery.isNotEmpty) {
        bloc.add(ShopSearchChanged(widget.initialQuery));
      }
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _openProduct(BuildContext context, String productId) {
    context.read<ShopBloc>().add(ShopProductViewed(productId));
    context.go(AppRoutes.buyerProductPath(productId));
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ShopBloc, ShopState>(
      builder: (context, state) {
        if (_searchController.text != state.searchQuery) {
          _searchController.value = TextEditingValue(
            text: state.searchQuery,
            selection: TextSelection.collapsed(offset: state.searchQuery.length),
          );
        }

        if (state.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        final selectedCategory = state.selectedCategory;
        final resultCount = state.filteredProducts.length;

        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(
              AppDimensions.lg,
              AppDimensions.md,
              AppDimensions.lg,
              AppDimensions.md,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _CatalogHeader(
                  title: widget.title,
                  subtitle: widget.subtitle ??
                      (selectedCategory != null
                          ? selectedCategory.description
                          : 'Search by product, category, or brand.'),
                  onOpenFilters: () => showShopFilterSheet(context),
                  onOpenCart: () => context.go(AppRoutes.buyerCart),
                  cartCount: state.cartCount,
                ),
                const SizedBox(height: AppDimensions.md),
                AppTextField(
                  controller: _searchController,
                  label: 'Search',
                  hint: 'Headphones, shirts, serum...',
                  prefixIcon: const Icon(Icons.search),
                  onChanged: (value) =>
                      context.read<ShopBloc>().add(ShopSearchChanged(value)),
                ),
                const SizedBox(height: AppDimensions.md),
                _CatalogControls(
                  categories: state.categories,
                  selectedCategorySlug: state.selectedCategorySlug,
                  selectedSort: state.sortOption,
                  selectedViewMode: state.viewMode,
                  onCategorySelected: (slug) => context
                      .read<ShopBloc>()
                      .add(ShopCategorySelected(slug)),
                  onSortChanged: (option) =>
                      context.read<ShopBloc>().add(ShopSortOptionSelected(option)),
                  onViewModeChanged: (mode) =>
                      context.read<ShopBloc>().add(ShopViewModeSelected(mode)),
                  onOpenFilters: () => showShopFilterSheet(context),
                ),
                const SizedBox(height: AppDimensions.md),
                Text(
                  '$resultCount products${selectedCategory != null ? ' in ${selectedCategory.name}' : ''}',
                  style: Theme.of(context).textTheme.labelMedium,
                ),
                const SizedBox(height: AppDimensions.md),
                if (state.filteredProducts.isEmpty)
                  Expanded(
                    child: ShopEmptyState(
                      icon: Icons.search_off_outlined,
                      title: 'No products match your filters',
                      message:
                          'Try another keyword, broaden the category, or clear the filters to explore the full catalog.',
                      actionLabel: 'Clear filters',
                      onAction: () =>
                          context.read<ShopBloc>().add(const ShopFiltersCleared()),
                    ),
                  )
                else
                  Expanded(
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 250),
                      child: state.viewMode == ShopViewMode.grid
                          ? GridView.builder(
                              key: const ValueKey('catalog-grid'),
                              itemCount: state.filteredProducts.length,
                              gridDelegate:
                                  SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount:
                                    MediaQuery.of(context).size.width > 700
                                        ? 3
                                        : 2,
                                mainAxisSpacing: AppDimensions.md,
                                crossAxisSpacing: AppDimensions.md,
                                childAspectRatio: 0.48,
                              ),
                              itemBuilder: (context, index) {
                                final product = state.filteredProducts[index];
                                return ShopProductCard(
                                  product: product,
                                  onTap: () => _openProduct(context, product.id),
                                );
                              },
                            )
                          : ListView.separated(
                              key: const ValueKey('catalog-list'),
                              itemCount: state.filteredProducts.length,
                              separatorBuilder: (_, __) =>
                                  const SizedBox(height: AppDimensions.md),
                              itemBuilder: (context, index) {
                                final product = state.filteredProducts[index];
                                return ShopProductCard(
                                  product: product,
                                  compact: true,
                                  showCategoryPill: true,
                                  onTap: () => _openProduct(context, product.id),
                                );
                              },
                            ),
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _CatalogHeader extends StatelessWidget {
  final String title;
  final String subtitle;
  final int cartCount;
  final VoidCallback onOpenFilters;
  final VoidCallback onOpenCart;

  const _CatalogHeader({
    required this.title,
    required this.subtitle,
    required this.cartCount,
    required this.onOpenFilters,
    required this.onOpenCart,
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
              Text(title, style: Theme.of(context).textTheme.headlineSmall),
              const SizedBox(height: 4),
              Text(subtitle, style: Theme.of(context).textTheme.bodyMedium),
            ],
          ),
        ),
        const SizedBox(width: AppDimensions.sm),
        Badge(
          isLabelVisible: cartCount > 0,
          label: Text('$cartCount'),
          child: IconButton(
            onPressed: onOpenCart,
            icon: const Icon(Icons.shopping_bag_outlined),
          ),
        ),
        IconButton(
          onPressed: onOpenFilters,
          icon: const Icon(Icons.tune_rounded),
        ),
      ],
    );
  }
}

class _CatalogControls extends StatelessWidget {
  final List<ShopCategory> categories;
  final String selectedCategorySlug;
  final ShopSortOption selectedSort;
  final ShopViewMode selectedViewMode;
  final ValueChanged<String> onCategorySelected;
  final ValueChanged<ShopSortOption> onSortChanged;
  final ValueChanged<ShopViewMode> onViewModeChanged;
  final VoidCallback onOpenFilters;

  const _CatalogControls({
    required this.categories,
    required this.selectedCategorySlug,
    required this.selectedSort,
    required this.selectedViewMode,
    required this.onCategorySelected,
    required this.onSortChanged,
    required this.onViewModeChanged,
    required this.onOpenFilters,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          height: 38,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: categories.length + 1,
            itemBuilder: (context, index) {
              if (index == 0) {
                final selected = selectedCategorySlug.isEmpty;
                return ChoiceChip(
                  selected: selected,
                  label: const Text('All'),
                  onSelected: (_) => onCategorySelected(''),
                );
              }
              final category = categories[index - 1];
              return ShopCategoryChip(
                category: category,
                selected: selectedCategorySlug == category.slug,
                onTap: () => onCategorySelected(category.slug),
              );
            },
            separatorBuilder: (_, __) => const SizedBox(width: AppDimensions.sm),
          ),
        ),
        const SizedBox(height: AppDimensions.md),
        Row(
          children: [
            Expanded(
              child: DropdownButtonFormField<ShopSortOption>(
                value: selectedSort,
                items: ShopSortOption.values
                    .map(
                      (option) => DropdownMenuItem(
                        value: option,
                        child: Text(option.label),
                      ),
                    )
                    .toList(),
                onChanged: (value) {
                  if (value != null) onSortChanged(value);
                },
                decoration: const InputDecoration(
                  labelText: 'Sort by',
                  prefixIcon: Icon(Icons.swap_vert_rounded),
                ),
              ),
            ),
            const SizedBox(width: AppDimensions.sm),
            _ViewModeToggle(
              selectedViewMode: selectedViewMode,
              onViewModeChanged: onViewModeChanged,
            ),
          ],
        ),
        const SizedBox(height: AppDimensions.sm),
        Align(
          alignment: Alignment.centerLeft,
          child: TextButton.icon(
            onPressed: onOpenFilters,
            icon: const Icon(Icons.filter_alt_outlined),
            label: const Text('More filters'),
          ),
        ),
      ],
    );
  }
}

class _ViewModeToggle extends StatelessWidget {
  final ShopViewMode selectedViewMode;
  final ValueChanged<ShopViewMode> onViewModeChanged;

  const _ViewModeToggle({
    required this.selectedViewMode,
    required this.onViewModeChanged,
  });

  @override
  Widget build(BuildContext context) {
    return ToggleButtons(
      isSelected: [
        selectedViewMode == ShopViewMode.grid,
        selectedViewMode == ShopViewMode.list,
      ],
      onPressed: (index) {
        onViewModeChanged(
          index == 0 ? ShopViewMode.grid : ShopViewMode.list,
        );
      },
      borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
      constraints: const BoxConstraints(
        minHeight: 52,
        minWidth: 48,
      ),
      children: const [
        Icon(Icons.grid_view_rounded),
        Icon(Icons.view_agenda_rounded),
      ],
    );
  }
}
