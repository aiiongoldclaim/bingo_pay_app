import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/theme/theme_colors.dart';
import '../../data/models/categories_model.dart';

class CuratedCollectionCard extends StatelessWidget {
  const CuratedCollectionCard({super.key, required this.collection});

  final CuratedCollectionModel collection;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(AppSizes.paddingMd),
      decoration: BoxDecoration(
        color: ThemeColors.white,
        borderRadius: BorderRadius.circular(AppSizes.radius2Xl),
        border: Border.all(color: ThemeColors.line),
      ),
      child: Row(
        children: [
          Container(
            width: 14.w,
            height: 14.w,
            decoration: BoxDecoration(
              color: collection.iconBg,
              borderRadius: BorderRadius.circular(AppSizes.radiusLg),
            ),
            child: Icon(collection.icon, color: ThemeColors.accent),
          ),

          SizedBox(width: 4.w),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(collection.title, style: AppTextStyles.titleLarge),
                Text(collection.subtitle, style: AppTextStyles.bodyMedium),
              ],
            ),
          ),

          Icon(Icons.chevron_right, color: ThemeColors.inkDim, size: 22.sp),
        ],
      ),
    );
  }
}
