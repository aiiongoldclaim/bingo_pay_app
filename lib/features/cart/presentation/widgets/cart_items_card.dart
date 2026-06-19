import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/theme/theme_colors.dart';
import '../../data/models/cart_model.dart';

class CartItemsCard extends StatelessWidget {
  final List<CartItemModel> items;

  const CartItemsCard({super.key, required this.items});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: ThemeColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: ThemeColors.line),
      ),
      child: Column(
        children: List.generate(
          items.length,
          (index) => Column(
            children: [
              CartItemTile(item: items[index]),

              if (index != items.length - 1)
                Divider(height: 3.h, color: ThemeColors.line),
            ],
          ),
        ),
      ),
    );
  }
}

class CartItemTile extends StatelessWidget {
  final CartItemModel item;

  const CartItemTile({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        /// Product Icon Box
        Container(
          width: 24.w,
          height: 24.w,
          decoration: BoxDecoration(
            color: ThemeColors.surface2,
            borderRadius: BorderRadius.circular(18),
          ),
          child: Icon(item.icon, color: ThemeColors.blue, size: 12.w),
        ),

        SizedBox(width: 3.w),

        /// Product Info
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                item.brand,
                style: AppTextStyles.labelMedium.copyWith(
                  color: ThemeColors.inkDim,
                  fontWeight: FontWeight.w700,
                ),
              ),

              Text(
                item.name,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: AppTextStyles.titleMedium.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),

              SizedBox(height: 1.h),

              Text(
                item.price,
                style: AppTextStyles.titleLarge.copyWith(
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
        ),

        SizedBox(width: 2.w),

        /// Quantity Selector
        Container(
          padding: EdgeInsets.symmetric(horizontal: 2.w, vertical: 1.h),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: ThemeColors.line),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.remove, size: 18.sp, color: ThemeColors.ink),

              SizedBox(width: 4.w),

              Text(
                '${item.quantity}',
                style: AppTextStyles.titleMedium.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),

              SizedBox(width: 4.w),

              Icon(Icons.add, size: 18.sp, color: ThemeColors.ink),
            ],
          ),
        ),
      ],
    );
  }
}
