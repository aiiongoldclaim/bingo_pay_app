import 'package:bingo_pay/core/theme/theme_colors.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:sizer/sizer.dart';

import '../../../../core/router/app_routes.dart';
import '../../../../core/widgets/product_card.dart';
import '../../../product_details/data/models/product_details_model.dart';
import '../../data/models/product_model.dart';

class RecommendedSection extends StatelessWidget {
  const RecommendedSection({super.key, required this.products});

  final List<ProductModel> products;

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
                style: TextStyle(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.bold,
                  color: ThemeColors.black,
                ),
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
              final product = products[index];
              return ProductCard(
                brand: product.brand,
                productName: product.name,
                price: product.price,
                imageUrl: product.images.isNotEmpty ? product.images.first : '',
                rating: product.rating,
                onTap: product.uuid != null
                    ? () => context.push(
                          AppRoutes.productDetails,
                          extra: product.uuid,
                        )
                    : null,
              );
            },
          ),
        ),
      ],
    );
  }
}
