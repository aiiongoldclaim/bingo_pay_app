import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/router/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimensions.dart';
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F5F7),
      appBar: ProductsAppBar(onSearchTap: () {}, onFilterTap: () {}),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.primary,
        onPressed: () => context.push(AppRoutes.vendorProductCreate),
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
            child: ListenableBuilder(
              listenable: ProductRepository.instance,
              builder: (context, _) {
                final products = ProductRepository.instance.filtered(_selectedFilter);
                return ListView.builder(
                  padding: const EdgeInsets.fromLTRB(
                    AppDimensions.md,
                    AppDimensions.sm,
                    AppDimensions.md,
                    AppDimensions.lg,
                  ),
                  itemCount: products.length,
                  itemBuilder: (context, index) => ProductCard(product: products[index]),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
