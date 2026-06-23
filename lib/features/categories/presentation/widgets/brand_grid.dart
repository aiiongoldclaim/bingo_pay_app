import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import 'brand_chip.dart';

class BrandsGrid extends StatelessWidget {
  const BrandsGrid({super.key, required this.brands});

  final List<String> brands;

  @override
  Widget build(BuildContext context) {
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
