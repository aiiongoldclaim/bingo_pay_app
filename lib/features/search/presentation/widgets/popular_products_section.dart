import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/theme/theme_colors.dart';
import '../../data/models/search_models.dart';

class PopularProductsSection extends StatelessWidget {
  const PopularProductsSection({
    super.key,
    required this.products,
    required this.onProductTap,
    required this.onFavouriteTap,
  });

  final List<SearchProductPreview> products;
  final ValueChanged<SearchProductPreview> onProductTap;
  final ValueChanged<String> onFavouriteTap;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.fromLTRB(4.w, 2.h, 4.w, 1.h),
          child: Text(
            'Popular right now',
            style: AppTextStyles.titleLarge.copyWith(fontSize: 18.sp),
          ),
        ),

        SizedBox(
          height: 40.h,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: EdgeInsets.symmetric(horizontal: 4.w),
            itemCount: products.length,
            separatorBuilder: (_, __) => SizedBox(width: 3.w),
            itemBuilder: (_, i) => _PopularProductCard(
              product: products[i],
              onTap: () => onProductTap(products[i]),
              onFavouriteTap: () => onFavouriteTap(products[i].id),
            ),
          ),
        ),
      ],
    );
  }
}

class _PopularProductCard extends StatelessWidget {
  const _PopularProductCard({
    required this.product,
    required this.onTap,
    required this.onFavouriteTap,
  });

  final SearchProductPreview product;
  final VoidCallback onTap;
  final VoidCallback onFavouriteTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 42.w,
        decoration: BoxDecoration(
          color: ThemeColors.surface,
          borderRadius: BorderRadius.circular(4.w),
          border: Border.all(color: ThemeColors.line),
        ),
        child: Column(
          children: [
            Stack(
              children: [
                Container(
                  height: 17.h,
                  decoration: BoxDecoration(
                    color: ThemeColors.background,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(4.w),
                      topRight: Radius.circular(4.w),
                    ),
                  ),
                  child: product.imageUrl != null
                      ? ClipRRect(
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(4.w),
                            topRight: Radius.circular(4.w),
                          ),
                          child: Image.network(
                            product.imageUrl!,
                            fit: BoxFit.cover,
                            width: double.infinity,
                          ),
                        )
                      : Center(
                          child: Icon(
                            Icons.inventory_2_outlined,
                            size: 28.sp,
                            color: ThemeColors.line,
                          ),
                        ),
                ),

                if (product.badge != null)
                  Positioned(
                    top: 1.h,
                    left: 2.w,
                    child: _Badge(label: product.badge!),
                  ),

                if (product.badge == null && product.discountPercent != null)
                  Positioned(
                    top: 1.h,
                    left: 2.w,
                    child: _DiscountPill(percent: product.discountPercent!),
                  ),

                Positioned(
                  top: 1.h,
                  right: 2.w,
                  child: GestureDetector(
                    onTap: onFavouriteTap,
                    child: Container(
                      width: 10.w,
                      height: 10.w,
                      decoration: const BoxDecoration(
                        color: ThemeColors.white,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        product.isFavourite
                            ? Icons.favorite
                            : Icons.favorite_border,
                        color: product.isFavourite
                            ? ThemeColors.red
                            : ThemeColors.inkDim,
                        size: 16.sp,
                      ),
                    ),
                  ),
                ),
              ],
            ),

            Expanded(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 2.5.w, vertical: 1.h),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      product.brand.toUpperCase(),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.labelSmall.copyWith(
                        color: ThemeColors.inkDim,
                        fontSize: 15.sp,
                      ),
                    ),

                    SizedBox(height: .4.h),

                    SizedBox(
                      height: 5.h,
                      child: Text(
                        product.name,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: AppTextStyles.labelLarge.copyWith(
                          fontSize: 15.sp,
                        ),
                      ),
                    ),

                    SizedBox(height: .6.h),

                    _RatingBadge(
                      rating: product.rating,
                      count: product.reviewCount,
                    ),

                    SizedBox(height: .8.h),

                    _PriceRow(
                      price: product.price,
                      originalPrice: product.originalPrice,
                      discountPercent: product.discountPercent,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Badge extends StatelessWidget {
  const _Badge({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 2.w, vertical: .4.h),
      decoration: BoxDecoration(
        color: ThemeColors.accentInk,
        borderRadius: BorderRadius.circular(2.w),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: ThemeColors.white,
          fontWeight: FontWeight.w700,
          fontSize: 13.sp,
        ),
      ),
    );
  }
}

class _DiscountPill extends StatelessWidget {
  const _DiscountPill({required this.percent});

  final int percent;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 2.w, vertical: .4.h),
      decoration: BoxDecoration(
        color: ThemeColors.accentSoft,
        borderRadius: BorderRadius.circular(2.w),
      ),
      child: Text(
        '-$percent%',
        style: TextStyle(
          color: ThemeColors.accentInk,
          fontWeight: FontWeight.w700,
          fontSize: 8.sp,
        ),
      ),
    );
  }
}

class _RatingBadge extends StatelessWidget {
  const _RatingBadge({required this.rating, required this.count});

  final double rating;
  final int count;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          padding: EdgeInsets.symmetric(horizontal: 1.5.w, vertical: .3.h),
          decoration: BoxDecoration(
            color: ThemeColors.green,
            borderRadius: BorderRadius.circular(2.w),
          ),
          child: Row(
            children: [
              Icon(Icons.star, color: ThemeColors.white, size: 13.sp),
              SizedBox(width: .5.w),
              Text(
                rating.toStringAsFixed(1),
                style: TextStyle(
                  color: ThemeColors.white,
                  fontSize: 15.sp,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
        SizedBox(width: 1.w),
        Text(
          '($count)',
          style: AppTextStyles.bodySmall.copyWith(fontSize: 15.sp),
        ),
      ],
    );
  }
}

class _PriceRow extends StatelessWidget {
  const _PriceRow({
    required this.price,
    this.originalPrice,
    this.discountPercent,
  });

  final double price;
  final double? originalPrice;
  final int? discountPercent;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 1.w,
      runSpacing: .2.h,
      children: [
        Text(
          '₹${price.toInt()}',
          style: AppTextStyles.titleMedium.copyWith(
            fontWeight: FontWeight.w700,
            fontSize: 15.sp,
          ),
        ),

        if (originalPrice != null)
          Text(
            '₹${originalPrice!.toInt()}',
            style: AppTextStyles.bodySmall.copyWith(
              decoration: TextDecoration.lineThrough,
              fontSize: 15.sp,
            ),
          ),

        if (discountPercent != null)
          Text(
            '$discountPercent%',
            style: TextStyle(
              color: ThemeColors.green,
              fontWeight: FontWeight.w700,
              fontSize: 8.sp,
            ),
          ),
      ],
    );
  }
}
