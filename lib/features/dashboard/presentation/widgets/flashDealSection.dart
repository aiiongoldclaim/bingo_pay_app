import 'package:bingo_pay/features/product_details/presentation/cubit/product_details_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sizer/sizer.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/theme/theme_colors.dart';
import '../../../product_details/data/models/product_details_model.dart';
import '../../../product_details/presentation/screens/product_details_screen.dart';
import 'countdown_timer.dart';
import 'flash_deal_card.dart';

class FlashDealSection extends StatelessWidget {
  const FlashDealSection({
    super.key,
    required this.products,
    this.title = 'Flash Deals',
    this.duration = const Duration(hours: 2, minutes: 14, seconds: 38),
    this.onSeeAll,
    this.icon = Icons.flash_on_outlined,
  });

  final List<ProductDetailModel> products;
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

              GestureDetector(
                onTap: onSeeAll,
                child: Text(
                  'See all',
                  style: AppTextStyles.labelLarge.copyWith(
                    color: ThemeColors.blue,
                  ),
                ),
              ),
            ],
          ),
        ),

        SizedBox(height: 1.h),

        SizedBox(
          height: 38.h,
          child: ListView.separated(
            padding: EdgeInsets.symmetric(horizontal: 4.w),
            scrollDirection: Axis.horizontal,
            itemCount: products.length,
            separatorBuilder: (_, __) => SizedBox(width: 3.w),
            itemBuilder: (context, index) {
              final product = products[index];

              return FlashDealCard(
                product: product,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => BlocProvider(
                        create: (_) =>
                            ProductDetailCubit()..loadProduct(product),
                        child: const ProductDetailScreen(),
                      ),
                    ),
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
