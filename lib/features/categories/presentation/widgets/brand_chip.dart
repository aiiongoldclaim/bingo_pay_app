import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../../core/constants/app_sizes.dart';
import '../../../../core/theme/theme_colors.dart';

class BrandChip extends StatelessWidget {
  const BrandChip({super.key, required this.brand});

  final String brand;

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: ThemeColors.surface,
        borderRadius: BorderRadius.circular(AppSizes.radius2Xl),
        border: Border.all(color: ThemeColors.line),
      ),
      child: Text(
        brand,
        style: TextStyle(
          fontSize: 16.sp,
          fontWeight: FontWeight.w600,
          fontFamily: 'Roboto',
        ),
      ),
    );
  }
}
