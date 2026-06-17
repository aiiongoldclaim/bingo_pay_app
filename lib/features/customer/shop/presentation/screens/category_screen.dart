import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../bloc/shop_bloc.dart';
import '../bloc/shop_state.dart';
import '../../domain/entities/shop_category.dart';
import '../widgets/shop_widgets.dart';
import 'catalog_screen.dart';

class CategoryScreen extends StatelessWidget {
  final String categorySlug;

  const CategoryScreen({
    super.key,
    required this.categorySlug,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ShopBloc, ShopState>(
      builder: (context, state) {
        if (state.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        ShopCategory? category;
        for (final item in state.categories) {
          if (item.slug == categorySlug) {
            category = item;
            break;
          }
        }

        if (category == null) {
          return const ShopEmptyState(
            icon: Icons.category_outlined,
            title: 'Category not found',
            message: 'The collection you requested is unavailable right now.',
          );
        }

        return CatalogScreen(
          title: category.name,
          subtitle: category.description,
          initialCategorySlug: category.slug,
        );
      },
    );
  }
}
