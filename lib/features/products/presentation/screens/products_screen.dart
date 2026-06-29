import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/di/injection.dart';
import '../../../../core/router/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../data/datasources/product_remote_datasource.dart';
import '../models/product_mock_data.dart';
import '../widgets/product_card.dart';
import '../widgets/product_filter_chips.dart';
import '../widgets/products_app_bar.dart';

class ProductsScreen extends StatefulWidget {
  const ProductsScreen({super.key});

  @override
  State<ProductsScreen> createState() => _ProductsScreenState();
}

class _ProductsScreenState extends State<ProductsScreen> {
  ProductFilter _selectedFilter = ProductFilter.all;
  bool _isGridView = false;
  late Future<List<Product>> _productsFuture;

  @override
  void initState() {
    super.initState();
    _productsFuture = _fetchProducts();
  }

  Future<List<Product>> _fetchProducts() async {
    final rows = await getIt<ProductRemoteDataSource>().getProducts();
    return rows.map(Product.fromApi).toList();
  }

  Future<void> _refresh() async {
    final future = _fetchProducts();
    setState(() {
      _productsFuture = future;
    });
    await future;
  }

  Future<void> _openAddProduct() async {
    await context.push(AppRoutes.vendorProductCreate);
    _refresh();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F5F7),
      appBar: ProductsAppBar(
        onSearchTap: () {},
        onFilterTap: () {},
        isGridView: _isGridView,
        onViewToggle: () => setState(() => _isGridView = !_isGridView),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.primary,
        onPressed: _openAddProduct,
        child: const Icon(Icons.add, color: Colors.white),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppDimensions.md,
              AppDimensions.md,
              AppDimensions.md,
              AppDimensions.sm,
            ),
            child: ProductFilterChips(
              selected: _selectedFilter,
              onSelected: (filter) => setState(() => _selectedFilter = filter),
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
                  return _ErrorState(message: '${snapshot.error}', onRetry: _refresh);
                }

                final products = filterProducts(snapshot.data ?? [], _selectedFilter);
                if (products.isEmpty) {
                  return RefreshIndicator(
                    onRefresh: _refresh,
                    child: ListView(
                      children: const [
                        Padding(
                          padding: EdgeInsets.only(top: 120),
                          child: Center(child: Text('No products found')),
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
                            AppDimensions.lg,
                          ),
                          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            crossAxisSpacing: AppDimensions.sm,
                            mainAxisSpacing: AppDimensions.sm,
                            childAspectRatio: 0.75,
                          ),
                          itemCount: products.length,
                          itemBuilder: (context, index) =>
                              ProductCard(product: products[index], isGrid: true),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.fromLTRB(
                            AppDimensions.md,
                            AppDimensions.sm,
                            AppDimensions.md,
                            AppDimensions.lg,
                          ),
                          itemCount: products.length,
                          itemBuilder: (context, index) =>
                              ProductCard(product: products[index]),
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
            Text(message, textAlign: TextAlign.center, style: TextStyle(color: Colors.grey[600], fontSize: 12)),
            const SizedBox(height: AppDimensions.md),
            ElevatedButton(onPressed: onRetry, child: const Text('Retry')),
          ],
        ),
      ),
    );
  }
}
