import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../../core/constants/app_sizes.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/theme/theme_colors.dart';
import '../../../categories/data/models/categories_model.dart';
import '../../domain/entities/category_entity.dart';

class CategoryCard extends StatelessWidget {
  const CategoryCard({
    super.key,
    required this.category,
    this.onTap,
    this.height,
  });

  final CategoryEntity category;
  final VoidCallback? onTap;
  final double? height;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(AppSizes.radius2Xl),
      onTap: onTap,
      child: Container(
        height: height ?? 16.h,
        decoration: BoxDecoration(
          color: category.color,
          borderRadius: BorderRadius.circular(AppSizes.radius2Xl),
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: category.image != null
                  ? Image.network(
                      category.image!,
                      fit: BoxFit.cover,
                      errorBuilder: (context, e, st) => _PlaceholderIcon(
                        icon: category.icon,
                        color: category.color,
                      ),
                      loadingBuilder: (_, child, loadingProgress) {
                        if (loadingProgress == null) return child;
                        return _PlaceholderIcon(
                          icon: category.icon,
                          color: category.color,
                        );
                      },
                    )
                  : _PlaceholderIcon(
                      icon: category.icon,
                      color: category.color,
                    ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: AppSizes.paddingSm,
                vertical: AppSizes.paddingSm,
              ),
              child: Text(
                category.name,
                style: AppTextStyles.titleLarge,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PlaceholderIcon extends StatelessWidget {
  const _PlaceholderIcon({required this.icon, required this.color});

  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: color,
      alignment: Alignment.center,
      child: Icon(icon, color: ThemeColors.accent, size: 22.sp),
    );
  }
}
