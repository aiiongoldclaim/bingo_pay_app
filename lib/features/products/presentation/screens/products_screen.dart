import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/api/api_client.dart';
import '../../../../core/api/api_endpoints.dart';
import '../../../../core/di/injection.dart';
import '../../../../core/error/error_messages.dart';
import '../../../../core/router/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../../core/theme/app_glass.dart';
import '../../../../core/widgets/glass/glass_scaffold.dart';
import '../../../../core/widgets/toolbar_icon_button.dart';
import '../../../dashboard/data/models/dashboard_stats_model.dart';
import '../../../dashboard/presentation/widgets/stat_card.dart';
import '../../data/datasources/product_remote_datasource.dart';
import '../models/product_mock_data.dart';
import '../widgets/product_card.dart';
import '../widgets/product_filter_sheet.dart';
import '../widgets/products_app_bar.dart';

class ProductsScreen extends StatefulWidget {
  const ProductsScreen({super.key});

  @override
  State<ProductsScreen> createState() => _ProductsScreenState();
}

class _ProductsScreenState extends State<ProductsScreen> {
  ProductFilter _selectedFilter = ProductFilter.all;
  bool _isGridView = true;
  String _searchQuery = '';
  final _searchController = TextEditingController();
  late Future<List<Product>> _productsFuture;
  late Future<DashboardStatsModel?> _statsFuture;

  @override
  void initState() {
    super.initState();
    _productsFuture = _fetchProducts();
    _statsFuture = _fetchStats();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _clearSearch() {
    _searchController.clear();
    setState(() => _searchQuery = '');
  }

  List<Product> _applySearch(List<Product> products) {
    final query = _searchQuery.trim().toLowerCase();
    if (query.isEmpty) return products;
    return products
        .where((p) =>
            p.name.toLowerCase().contains(query) ||
            p.sku.toLowerCase().contains(query) ||
            p.category.toLowerCase().contains(query))
        .toList();
  }

  Future<List<Product>> _fetchProducts() async {
    final rows = await getIt<ProductRemoteDataSource>().getProducts();
    return rows.map(Product.fromApi).toList();
  }

  Future<DashboardStatsModel?> _fetchStats() async {
    try {
      final response = await getIt<ApiClient>().dio.get(ApiEndpoints.vendorDashboard);
      final data = response.data as Map<String, dynamic>;
      final inner = (data['data'] as Map<String, dynamic>)['data'] as Map<String, dynamic>;
      return DashboardStatsModel.fromJson(inner);
    } catch (_) {
      return null;
    }
  }

  Future<void> _refresh() async {
    final future = _fetchProducts();
    setState(() {
      _productsFuture = future;
      _statsFuture = _fetchStats();
    });
    await future;
  }

  Future<void> _openAddProduct() async {
    await context.push(AppRoutes.vendorProductCreate);
    _refresh();
  }

  Future<void> _openFilterSheet() async {
    final result =
        await showProductFilterSheet(context, selected: _selectedFilter);
    if (result != null && mounted) {
      setState(() => _selectedFilter = result);
    }
  }

  @override
  Widget build(BuildContext context) {
    return GlassScaffold(
      appBar: const ProductsAppBar(),
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 96),
        child: FloatingActionButton(
          backgroundColor: AppColors.primary,
          onPressed: _openAddProduct,
          child: const Icon(Icons.add, color: Colors.white),
        ),
      ),
      body: Column(
        children: [
          FutureBuilder<DashboardStatsModel?>(
            future: _statsFuture,
            builder: (context, snapshot) {
              final stats = snapshot.data;
              if (stats == null) return const SizedBox.shrink();
              return Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppDimensions.md,
                  AppDimensions.md,
                  AppDimensions.md,
                  0,
                ),
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      StatCard(
                        title: 'Approved',
                        value: '${stats.approvedProducts}',
                        icon: Icons.check_circle_outline,
                        iconColor: AppColors.success,
                        iconBackground: AppColors.successTint,
                      ),
                      const SizedBox(width: AppDimensions.sm + 4),
                      StatCard(
                        title: 'Draft',
                        value: '${stats.draftProducts}',
                        icon: Icons.edit_note_outlined,
                        iconColor: AppColors.textSecondary,
                        iconBackground: AppColors.backgroundLight,
                      ),
                      const SizedBox(width: AppDimensions.sm + 4),
                      StatCard(
                        title: 'Rejected',
                        value: '${stats.rejectedProducts}',
                        icon: Icons.cancel_outlined,
                        iconColor: AppColors.error,
                        iconBackground: AppColors.errorTint,
                      ),
                      const SizedBox(width: AppDimensions.sm + 4),
                      StatCard(
                        title: 'Total Variants',
                        value: '${stats.totalVariants}',
                        icon: Icons.layers_outlined,
                        iconColor: AppColors.accentPurple,
                        iconBackground: AppColors.accentPurpleTint,
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppDimensions.md,
              AppDimensions.md,
              AppDimensions.md,
              AppDimensions.sm,
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    onChanged: (value) => setState(() => _searchQuery = value),
                    textInputAction: TextInputAction.search,
                    style: const TextStyle(fontSize: 14),
                    decoration: InputDecoration(
                      hintText: 'Search products…',
                      hintStyle: TextStyle(fontSize: 14, color: context.colors.textMuted),
                      isDense: true,
                      filled: true,
                      fillColor: context.glass.fill,
                      contentPadding: const EdgeInsets.symmetric(vertical: 10),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(AppDimensions.radiusXl),
                        borderSide: BorderSide(color: context.glass.border),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(AppDimensions.radiusXl),
                        borderSide: BorderSide(color: context.glass.border),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(AppDimensions.radiusXl),
                        borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
                      ),
                      prefixIcon: Icon(Icons.search, size: 20, color: context.colors.textSecondary),
                      suffixIcon: _searchQuery.isEmpty
                          ? null
                          : IconButton(
                              icon: Icon(Icons.close, size: 18, color: context.colors.textSecondary),
                              onPressed: _clearSearch,
                            ),
                    ),
                  ),
                ),
                const SizedBox(width: AppDimensions.sm),
                ToolbarIconButton(
                  icon: Icons.tune,
                  tooltip: 'Filter',
                  showDot: _selectedFilter != ProductFilter.all,
                  onTap: _openFilterSheet,
                ),
                const SizedBox(width: AppDimensions.sm),
                ToolbarIconButton(
                  icon: _isGridView ? Icons.view_list_outlined : Icons.grid_view_outlined,
                  tooltip: _isGridView ? 'List view' : 'Grid view',
                  onTap: () => setState(() => _isGridView = !_isGridView),
                ),
              ],
            ),
          ),
          Expanded(
            child: FutureBuilder<List<Product>>(
              future: _productsFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return _ErrorState(
                      message: friendlyErrorMessage(snapshot.error), onRetry: _refresh);
                }

                final products =
                    _applySearch(filterProducts(snapshot.data ?? [], _selectedFilter));
                if (products.isEmpty) {
                  return RefreshIndicator(
                    onRefresh: _refresh,
                    child: ListView(
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(top: 120),
                          child: Center(
                            child: Column(
                              children: [
                                Icon(Icons.inventory_2_outlined,
                                    size: 48, color: context.colors.textMuted),
                                const SizedBox(height: AppDimensions.sm),
                                const Text('No products found'),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                }

                return RefreshIndicator(
                  onRefresh: _refresh,
                  child: _isGridView
                      ? GridView.builder(
                          padding: const EdgeInsets.fromLTRB(
                            AppDimensions.md,
                            AppDimensions.sm,
                            AppDimensions.md,
                            96,
                          ),
                          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            crossAxisSpacing: AppDimensions.sm,
                            mainAxisSpacing: AppDimensions.sm,
                            mainAxisExtent: 250,
                          ),
                          itemCount: products.length,
                          itemBuilder: (context, index) => ProductCard(
                            product: products[index],
                            isGrid: true,
                            onChanged: _refresh,
                          ),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.fromLTRB(
                            AppDimensions.md,
                            AppDimensions.sm,
                            AppDimensions.md,
                            96,
                          ),
                          itemCount: products.length,
                          itemBuilder: (context, index) => ProductCard(
                            product: products[index],
                            onChanged: _refresh,
                          ),
                        ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  final String message;
  final Future<void> Function() onRetry;

  const _ErrorState({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppDimensions.lg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Failed to load products', style: const TextStyle(fontWeight: FontWeight.w600)),
            const SizedBox(height: 4),
            Text(message, textAlign: TextAlign.center, style: TextStyle(color: context.colors.textSecondary, fontSize: 12)),
            const SizedBox(height: AppDimensions.md),
            ElevatedButton(onPressed: onRetry, child: const Text('Retry')),
          ],
        ),
      ),
    );
  }
}
