import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:sizer/sizer.dart';

import '../../../../core/router/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/theme/theme_colors.dart';
import '../../../../core/widgets/product_card.dart';
import '../../data/models/product_model.dart';
import 'countdown_timer.dart';

class FlashDealSection extends StatelessWidget {
  const FlashDealSection({
    super.key,
    required this.products,
    this.title = 'Flash Deals',
    this.duration = const Duration(hours: 2, minutes: 14, seconds: 38),
    this.onSeeAll,
    this.icon = Icons.flash_on_outlined,
  });

  final List<ProductModel> products;
  final String title;
  final Duration duration;
  final VoidCallback? onSeeAll;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 5.w),
          child: Row(
            children: [
              Icon(icon, color: AppColors.red),

              Text(title, style: AppTextStyles.titleMedium),

              SizedBox(width: 2.w),

              CountdownTimer(duration: duration),

              const Spacer(),

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
          height: 34.h,
          child: ListView.separated(
            padding: EdgeInsets.symmetric(horizontal: 4.w),
            scrollDirection: Axis.horizontal,
            itemCount: products.length,
            separatorBuilder: (_, __) => SizedBox(width: 3.w),
            itemBuilder: (context, index) {
              final product = products[index];

              return ProductCard(
                width: 42.w,
                brand: product.brand,
                productName: product.name,
                price: product.price,
                imageUrl: product.images.isNotEmpty ? product.images.first : '',
                rating: product.rating,
                onTap: () {
                  context.push(AppRoutes.productDetails, extra: product);
                },
              );
            },
          ),
        ),
      ],
    );
  }
}
