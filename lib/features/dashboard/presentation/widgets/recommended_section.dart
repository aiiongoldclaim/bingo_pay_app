import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../product_details/data/models/product_details_model.dart';
import 'flash_deal_card.dart';

class RecommendedSection extends StatelessWidget {
  const RecommendedSection({super.key, required this.products});

  final List<ProductDetailModel> products;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 4.w),
          child: Row(
            children: [
              Text(
                "Recommended for you",
                style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
        SizedBox(height: 1.h),

        SizedBox(
          height: 34.h,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: EdgeInsets.symmetric(horizontal: 4.w),
            itemCount: products.length,
            separatorBuilder: (_, __) => SizedBox(width: 3.w),
            itemBuilder: (context, index) {
              return FlashDealCard(product: products[index]);
            },
          ),
        ),
      ],
    );
  }
}
