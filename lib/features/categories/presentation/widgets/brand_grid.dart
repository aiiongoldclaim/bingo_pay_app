import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../domain/entities/brand_entity.dart';
import 'brand_chip.dart';

class BrandsGrid extends StatelessWidget {
  const BrandsGrid({
    super.key,
    required this.brands,
    this.isLoading = false,
    this.error,
  });

  final List<BrandEntity> brands;
  final bool isLoading;
  final String? error;

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return SizedBox(
        height: 15.h,
        child: GridView.builder(
          itemCount: 6,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            crossAxisSpacing: 3.w,
            mainAxisSpacing: 2.h,
            childAspectRatio: 1.45,
          ),
          itemBuilder: (_, index) {
            return Container(
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(12),
              ),
            );
          },
        ),
      );
    }

    if (error != null) {
      return Container(
        padding: EdgeInsets.symmetric(vertical: 2.h, horizontal: 4.w),
        decoration: BoxDecoration(
          color: const Color(0xFFFCE4EC),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFE91E63).withOpacity(0.3)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.warning_outlined,
              color: const Color(0xFFE91E63),
              size: 24,
            ),
            SizedBox(height: 1.h),
            Text(
              'Failed to load brands',
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.w600,
                color: const Color(0xFFE91E63),
              ),
            ),
          ],
        ),
      );
    }

    if (brands.isEmpty) {
      return SizedBox(
        height: 10.h,
        child: Center(
          child: Text(
            'No brands available',
            style: TextStyle(
              fontSize: 14.sp,
              fontWeight: FontWeight.w500,
              color: Colors.grey[600],
            ),
          ),
        ),
      );
    }

    return GridView.builder(
      itemCount: brands.length,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 3.w,
        mainAxisSpacing: 2.h,
        childAspectRatio: 1.45,
      ),
      itemBuilder: (_, index) {
        return BrandChip(brand: brands[index]);
      },
    );
  }
}
