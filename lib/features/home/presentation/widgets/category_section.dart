import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:sizer/sizer.dart';
import '../../../../core/router/app_routes.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/theme/theme_colors.dart';
import '../../../categories/data/models/categories_model.dart';
import 'category_item.dart';

class CategorySection extends StatelessWidget {
  const CategorySection({super.key, required this.categories});

  final List<CategoryModel> categories;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 5.w),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Shop by category',
                style: AppTextStyles.titleLarge.copyWith(
                  fontSize: 18.sp,
                  color: ThemeColors.black,
                  fontWeight: FontWeight.w600,
                ),
              ),

              InkWell(
                onTap: () {
                  context.push(AppRoutes.categories);
                },
                child: Text(
                  'See all',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 16.sp,
                    color: ThemeColors.blue,
                  ),
                ),
              ),
            ],
          ),
        ),

        SizedBox(height: 1.h),

        SizedBox(
          height: 15.h,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: EdgeInsets.symmetric(horizontal: 4.w),
            itemCount: categories.length,
            itemBuilder: (_, index) {
              final category = categories[index];

              return CategoryItem(
                category: category,
                onTap: () {
                  context.push(
                    '/product-listing/${Uri.encodeComponent(category.name)}',
                    extra: category.uuid,
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }
}
