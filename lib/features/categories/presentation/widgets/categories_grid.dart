import 'package:bingo_pay/features/categories/data/categories_model.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:sizer/sizer.dart';

import '../../../../core/router/app_routes.dart';
import 'categories_card.dart';

class CategoriesGrid extends StatelessWidget {
  const CategoriesGrid({super.key, required this.categories});

  final List<CategoryModel> categories;

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
        return GestureDetector(
          onTap: () {
            context.push(AppRoutes.productListing);
          },
          child: CategoryCard(category: category),
        );
      },
    );
  }
}
