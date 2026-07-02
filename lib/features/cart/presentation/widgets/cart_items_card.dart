import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/theme/theme_colors.dart';
import '../../domain/entities/cart_item_entity.dart';

class CartItemsCard extends StatelessWidget {
  final List<CartItemEntity> items;
  final void Function(CartItemEntity item) onIncrease;
  final void Function(CartItemEntity item) onDecrease;
  final void Function(CartItemEntity item) onDelete;

  const CartItemsCard({
    super.key,
    required this.items,
    required this.onIncrease,
    required this.onDecrease,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF1A1D4E).withValues(alpha: 0.08),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: List.generate(items.length, (index) {
          final item = items[index];
          return Column(
            children: [
              CartItemTile(
                item: item,
                onIncrease: () => onIncrease(item),
                onDecrease: () => onDecrease(item),
                onDelete: () => onDelete(item),
              ),
              if (index != items.length - 1)
                Divider(height: 3.h, color: ThemeColors.line),
            ],
          );
        }),
      ),
    );
  }
}

class CartItemTile extends StatelessWidget {
  final CartItemEntity item;
  final VoidCallback onIncrease;
  final VoidCallback onDecrease;
  final VoidCallback onDelete;

  const CartItemTile({
    super.key,
    required this.item,
    required this.onIncrease,
    required this.onDecrease,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final thumbnail = item.product.thumbnail;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        /// Image / Icon
        ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Container(
            width: 20.w,
            height: 20.w,
            color: ThemeColors.surface2,
            child: thumbnail != null
                ? Image.network(
                    thumbnail,
                    fit: BoxFit.cover,
                    errorBuilder: (ctx, e, st) => Icon(
                      Icons.shopping_bag_outlined,
                      color: ThemeColors.blue,
                      size: 10.w,
                    ),
                  )
                : Icon(
                    Icons.shopping_bag_outlined,
                    color: ThemeColors.blue,
                    size: 10.w,
                  ),
          ),
        ),

        SizedBox(width: 3.w),

        /// Product Info
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      item.vendor.shopName,
                      style: AppTextStyles.labelMedium.copyWith(
                        color: ThemeColors.inkDim,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: onDelete,
                    child: Icon(
                      Icons.delete_outline,
                      size: 18.sp,
                      color: ThemeColors.inkDim,
                    ),
                  ),
                ],
              ),

              Text(
                item.product.title,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: AppTextStyles.titleMedium.copyWith(
                  fontWeight: FontWeight.w700,
                  fontSize: 14.sp,
                ),
              ),

              SizedBox(height: 0.5.h),

              Row(
                children: [
                  Text(
                    '\$${item.unitPrice.toStringAsFixed(0)}',
                    style: AppTextStyles.titleLarge.copyWith(
                      fontWeight: FontWeight.w800,
                      fontSize: 15.sp,
                    ),
                  ),
                  const Spacer(),
                  // Quantity controls
                  Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFF1A1D4E),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _QtyButton(
                          icon: Icons.remove,
                          onTap: onDecrease,
                        ),
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 3.w),
                          child: Text(
                            '${item.quantity}',
                            style: AppTextStyles.titleMedium.copyWith(
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                          ),
                        ),
                        _QtyButton(
                          icon: Icons.add,
                          onTap: onIncrease,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _QtyButton extends StatelessWidget {
  const _QtyButton({required this.icon, required this.onTap});
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 2.w, vertical: 1.h),
        child: Icon(icon, size: 16.sp, color: Colors.white),
      ),
    );
  }
}
