import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import 'package:bingo_pay/core/theme/theme_colors.dart';
import 'package:bingo_pay/core/theme/app_text_styles.dart';

import '../../data/models/order_model.dart';
import 'order_status.dart';

class OrderCard extends StatelessWidget {
  final OrderModel order;
  final VoidCallback? onDetails;

  const OrderCard({super.key, required this.order, this.onDetails});

  @override
  Widget build(BuildContext context) {
    final previewImageUrl = order.previewImageUrl;

    return InkWell(
      onTap: onDetails,
      borderRadius: BorderRadius.circular(18),
      child: Container(
        padding: EdgeInsets.all(4.w),
        decoration: BoxDecoration(
          color: ThemeColors.surface,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: ThemeColors.line),
          boxShadow: [
            BoxShadow(
              color: ThemeColors.ink.withValues(alpha: 0.05),
              blurRadius: 14,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// ── Header: Order number + Status ──
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 11.w,
                  height: 11.w,
                  decoration: BoxDecoration(
                    color: ThemeColors.blueSoft,
                    borderRadius: BorderRadius.circular(13),
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: previewImageUrl == null
                      ? Icon(
                          Icons.receipt_long_rounded,
                          color: ThemeColors.blue,
                          size: 18.sp,
                        )
                      : Image.network(
                          previewImageUrl,
                          fit: BoxFit.cover,
                          errorBuilder: (_, _, _) => Icon(
                            Icons.receipt_long_rounded,
                            color: ThemeColors.blue,
                            size: 18.sp,
                          ),
                        ),
                ),
                SizedBox(width: 3.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        order.orderNumber,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTextStyles.titleMedium.copyWith(
                          fontSize: 15.sp,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 0.3.h),
                      Text(
                        '${order.shortDate} · ${order.formattedItemsLabel()}',
                        style: AppTextStyles.bodySmall.copyWith(
                          fontSize: 13.sp,
                          color: ThemeColors.inkDim,
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(width: 2.w),
                OrderStatusBadge(status: order.orderStatus),
              ],
            ),

            SizedBox(height: 1.8.h),
            Divider(height: 1, color: ThemeColors.line),
            SizedBox(height: 1.8.h),

            /// ── Payment + Total row ──
            Row(
              children: [
                Icon(
                  Icons.account_balance_wallet_outlined,
                  size: 16.sp,
                  color: ThemeColors.inkMid,
                ),
                SizedBox(width: 1.5.w),
                Expanded(
                  child: Text(
                    order.displayPaymentMethod,
                    style: AppTextStyles.bodySmall.copyWith(
                      fontSize: 14.sp,
                      color: ThemeColors.inkMid,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                Text(
                  order.formattedTotal,
                  style: AppTextStyles.titleMedium.copyWith(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),

            SizedBox(height: 2.h),

            /// ── Action ──
            SizedBox(
              width: double.infinity,
              child: _ActionButton(label: 'View Details', onTap: onDetails),
            ),
          ],
        ),
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final String label;
  final VoidCallback? onTap;

  const _ActionButton({required this.label, this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 1.3.h),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: ThemeColors.surface2,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: ThemeColors.line, width: 1.2),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: AppTextStyles.labelLarge.copyWith(
                fontSize: 14.sp,
                fontWeight: FontWeight.bold,
                color: ThemeColors.black,
              ),
            ),
            SizedBox(width: 1.w),
            Icon(
              Icons.arrow_forward_ios_rounded,
              size: 12.sp,
              color: ThemeColors.inkMid,
            ),
          ],
        ),
      ),
    );
  }
}
