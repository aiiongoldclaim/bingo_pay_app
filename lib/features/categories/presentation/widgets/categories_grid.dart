import 'package:bingo_pay/features/categories/domain/entities/category_entity.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:sizer/sizer.dart';
import 'categories_card.dart';

class CategoriesGrid extends StatelessWidget {
  const CategoriesGrid({super.key, required this.categories});

  final List<CategoryEntity> categories;

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      itemCount: categories.length,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 4.w,
        mainAxisSpacing: 2.h,
        childAspectRatio: 1.08,
      ),
      itemBuilder: (_, index) {
        final category = categories[index];
        return CategoryCard(
          category: category,
          onTap: () => context.push(
            '/product-listing/${Uri.encodeComponent(category.name)}',
            extra: category.uuid,
          ),
        );
      },
    );
  }
}
