import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import 'package:bingo_pay/core/theme/theme_colors.dart';
import 'package:bingo_pay/core/theme/app_text_styles.dart';

import '../../data/models/order_model.dart';
import 'order_status.dart';

class OrderCard extends StatelessWidget {
  final OrderModel order;
  final VoidCallback? onTrack;
  final VoidCallback? onDetails;
  final VoidCallback? onReorder;
  final VoidCallback? onRate;

  const OrderCard({
    super.key,
    required this.order,
    this.onTrack,
    this.onDetails,
    this.onReorder,
    this.onRate,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: ThemeColors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: ThemeColors.line),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /// ── Header: Order ID + Status ──
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    order.orderId,
                    style: AppTextStyles.titleMedium.copyWith(
                      fontSize: 15.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 0.1.h),
                  Text(
                    '${order.formattedDate} · ${order.itemCount} ${order.itemCount == 1 ? 'item' : 'items'}',
                    style: AppTextStyles.bodySmall.copyWith(
                      fontSize: 14.sp,
                      color: ThemeColors.inkDim,
                    ),
                  ),
                ],
              ),
              OrderStatusBadge(status: order.status),
            ],
          ),

          SizedBox(height: 2.h),

          /// ── Product Row ──
          Row(
            children: [
              /// Icon Box
              Container(
                width: 15.w,
                height: 15.w,
                decoration: BoxDecoration(
                  color: ThemeColors.surface2,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(
                  order.items.first.icon,
                  color: order.items.first.iconColor,
                  size: 20.sp,
                ),
              ),

              SizedBox(width: 3.w),

              /// Name + delivery
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      order.mainItemName,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.bodyMedium.copyWith(
                        fontSize: 15.sp,
                        fontWeight: FontWeight.w600,
                        color: ThemeColors.ink,
                      ),
                    ),
                    SizedBox(height: 0.4.h),
                    Row(
                      children: [
                        Icon(
                          order.isDelivered
                              ? Icons.check_circle_outline_rounded
                              : Icons.local_shipping_outlined,
                          size: 15.sp,
                          color: order.isDelivered
                              ? ThemeColors.green
                              : ThemeColors.blue,
                        ),
                        SizedBox(width: 1.w),
                        Text(
                          order.deliveryDate,
                          style: AppTextStyles.labelSmall.copyWith(
                            fontSize: 14.sp,
                            color: order.isDelivered
                                ? ThemeColors.green
                                : ThemeColors.blue,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              /// Price
              Text(
                '₹${_formatPrice(order.totalAmount)}',
                style: AppTextStyles.titleMedium.copyWith(
                  fontSize: 15.sp,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),

          SizedBox(height: 2.h),

          /// ── Action Buttons ──
          Row(
            children: [
              Expanded(
                child: _ActionButton(
                  label: order.isDelivered ? 'Reorder' : 'Track',
                  onTap: order.isDelivered ? onReorder : onTrack,
                ),
              ),
              SizedBox(width: 3.w),
              Expanded(
                child: _ActionButton(
                  label: order.isDelivered ? 'Rate' : 'Details',
                  onTap: order.isDelivered ? onRate : onDetails,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _formatPrice(double price) {
    return price
        .toStringAsFixed(0)
        .replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (m) => '${m[1]},',
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
          color: ThemeColors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: ThemeColors.line, width: 1.2),
        ),
        child: Text(
          label,
          style: AppTextStyles.labelLarge.copyWith(
            fontSize: 15.sp,
            fontWeight: FontWeight.bold,
            color: ThemeColors.black,
          ),
        ),
      ),
    );
  }
}
