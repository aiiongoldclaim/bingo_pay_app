// import 'package:flutter/material.dart';
// import 'package:sizer/sizer.dart';
// import 'package:bingo_pay/core/theme/theme_colors.dart';
// import 'package:bingo_pay/core/theme/app_text_styles.dart';
//
// import '../../data/models/order_model.dart';
// import 'order_status.dart';
//
// class OrderCard extends StatelessWidget {
//   final OrderModel order;
//   final VoidCallback? onDetails;
//
//   const OrderCard({super.key, required this.order, this.onDetails});
//
//   @override
//   Widget build(BuildContext context) {
//     final previewImageUrl = order.previewImageUrl;
//
//     return InkWell(
//       onTap: onDetails,
//       borderRadius: BorderRadius.circular(18),
//       child: Container(
//         padding: EdgeInsets.all(4.w),
//         decoration: BoxDecoration(
//           color: ThemeColors.surface,
//           borderRadius: BorderRadius.circular(18),
//           border: Border.all(color: ThemeColors.line),
//           boxShadow: [
//             BoxShadow(
//               color: ThemeColors.ink.withValues(alpha: 0.05),
//               blurRadius: 14,
//               offset: const Offset(0, 4),
//             ),
//           ],
//         ),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             /// ── Header: Order number + Status ──
//             Row(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Container(
//                   width: 11.w,
//                   height: 11.w,
//                   decoration: BoxDecoration(
//                     color: ThemeColors.blueSoft,
//                     borderRadius: BorderRadius.circular(13),
//                   ),
//                   clipBehavior: Clip.antiAlias,
//                   child: previewImageUrl == null
//                       ? Icon(
//                           Icons.receipt_long_rounded,
//                           color: ThemeColors.blue,
//                           size: 18.sp,
//                         )
//                       : Image.network(
//                           previewImageUrl,
//                           fit: BoxFit.cover,
//                           errorBuilder: (_, _, _) => Icon(
//                             Icons.receipt_long_rounded,
//                             color: ThemeColors.blue,
//                             size: 18.sp,
//                           ),
//                         ),
//                 ),
//                 SizedBox(width: 3.w),
//                 Expanded(
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       Text(
//                         order.orderNumber,
//                         maxLines: 1,
//                         overflow: TextOverflow.ellipsis,
//                         style: AppTextStyles.titleMedium.copyWith(
//                           fontSize: 15.sp,
//                           fontWeight: FontWeight.bold,
//                         ),
//                       ),
//                       SizedBox(height: 0.3.h),
//                       Text(
//                         '${order.shortDate} · ${order.formattedItemsLabel()}',
//                         style: AppTextStyles.bodySmall.copyWith(
//                           fontSize: 13.5.sp,
//                           color: ThemeColors.inkMid
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//                 SizedBox(width: 2.w),
//                 OrderStatusBadge(status: order.orderStatus),
//               ],
//             ),
//
//             SizedBox(height: 1.8.h),
//             Divider(height: 1, color: ThemeColors.line),
//             SizedBox(height: 1.8.h),
//
//             /// ── Payment + Total row ──
//             Row(
//               children: [
//                 Icon(
//                   Icons.account_balance_wallet_outlined,
//                   size: 16.sp,
//                   color: ThemeColors.inkMid,
//                 ),
//                 SizedBox(width: 1.5.w),
//                 Expanded(
//                   child: Text(
//                     order.displayPaymentMethod,
//                     style: AppTextStyles.bodySmall.copyWith(
//                       fontSize: 14.sp,
//                       color: ThemeColors.inkMid,
//                       fontWeight: FontWeight.w600,
//                     ),
//                   ),
//                 ),
//                 Text(
//                   order.formattedTotal,
//                   style: AppTextStyles.titleMedium.copyWith(
//                     fontSize: 16.sp,
//                     fontWeight: FontWeight.bold,
//                   ),
//                 ),
//               ],
//             ),
//
//             SizedBox(height: 2.h),
//
//             /// ── Action ──
//             SizedBox(
//               width: double.infinity,
//               child: _ActionButton(label: 'View Details', onTap: onDetails),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
//
// class _ActionButton extends StatelessWidget {
//   final String label;
//   final VoidCallback? onTap;
//
//   const _ActionButton({required this.label, this.onTap});
//
//   @override
//   Widget build(BuildContext context) {
//     return GestureDetector(
//       onTap: onTap,
//       child: Container(
//         padding: EdgeInsets.symmetric(vertical: 1.3.h),
//         alignment: Alignment.center,
//         decoration: BoxDecoration(
//           color: ThemeColors.surface2,
//           borderRadius: BorderRadius.circular(12),
//           border: Border.all(color: ThemeColors.line, width: 1.2),
//         ),
//         child: Row(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             Text(
//               label,
//               style: AppTextStyles.labelLarge.copyWith(
//                 fontSize: 14.sp,
//                 fontWeight: FontWeight.bold,
//                 color: ThemeColors.black,
//               ),
//             ),
//             SizedBox(width: 1.w),
//             Icon(
//               Icons.arrow_forward_ios_rounded,
//               size: 12.sp,
//               color: ThemeColors.inkMid,
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
import 'package:flutter/material.dart';

import '../../../../core/theme/app_theme_colors.dart';
import '../../data/models/order_model.dart';
import 'order_status_style.dart';
import 'orders_metrics.dart';

class OrderCard extends StatelessWidget {
  const OrderCard({
    super.key,
    required this.metrics,
    required this.order,
    this.onDetails,
    this.onCta,
  });

  final OrdersMetrics metrics;
  final OrderModel order;
  final VoidCallback? onDetails;
  final VoidCallback? onCta;

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    final m = metrics;
    final status = OrderStatusStyle.of(context, order.orderStatus);
    final item = order.items.isNotEmpty ? order.items.first : null;

    return InkWell(
      onTap: onDetails,
      borderRadius: BorderRadius.circular(m.cardRadius),
      child: Container(
        decoration: BoxDecoration(
          color: c.surface,
          borderRadius: BorderRadius.circular(m.cardRadius),
          border: Border.all(color: c.border),
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: EdgeInsets.all(m.cardGap),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _TopRow(metrics: m, order: order, status: status),
                  SizedBox(height: m.cardGap * 0.9),
                  // List endpoint items nahi bhejta — us case me summary row
                  if (item != null)
                    _ItemRow(
                      metrics: m,
                      order: order,
                      item: item,
                      status: status,
                    )
                  else
                    _SummaryRow(metrics: m, order: order, status: status),
                ],
              ),
            ),
            _FooterStrip(
              metrics: m,
              order: order,
              status: status,
              onCta: onCta ?? onDetails,
            ),
          ],
        ),
      ),
    );
  }
}

// ── Order number + date + status ────────────────────────────

class _TopRow extends StatelessWidget {
  const _TopRow({
    required this.metrics,
    required this.order,
    required this.status,
  });

  final OrdersMetrics metrics;
  final OrderModel order;
  final OrderStatusStyle status;

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    final m = metrics;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              RichText(
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                text: TextSpan(
                  style: TextStyle(
                    fontSize: m.orderIdSize,
                    fontWeight: FontWeight.w700,
                    color: c.textPrimary,
                  ),
                  children: [
                    TextSpan(
                      text: 'Order ID  ',
                      style: TextStyle(color: c.textPrimary),
                    ),
                    TextSpan(text: order.orderNumber),
                  ],
                ),
              ),
              SizedBox(height: m.cardGap * 0.25),
              Text(
                order.fullPlacedAt,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: m.orderDateSize,
                  height: 1.2,
                  color: c.textSecondary,
                ),
              ),
            ],
          ),
        ),
        SizedBox(width: m.cardGap * 0.5),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              order.displayOrderStatus,
              style: TextStyle(
                fontSize: m.statusSize,
                fontWeight: FontWeight.w600,
                color: status.foreground,
              ),
            ),
            SizedBox(width: m.cardGap * 0.15),
            Icon(
              Icons.chevron_right_rounded,
              size: m.statusSize * 1.4,
              color: status.foreground,
            ),
          ],
        ),
      ],
    );
  }
}

// ── Full product row (detail endpoint) ──────────────────────

class _ItemRow extends StatelessWidget {
  const _ItemRow({
    required this.metrics,
    required this.order,
    required this.item,
    required this.status,
  });

  final OrdersMetrics metrics;
  final OrderModel order;
  final OrderItemModel item;
  final OrderStatusStyle status;

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    final m = metrics;

    final attributes = [
      if ((item.size ?? '').isNotEmpty) 'Size: ${item.size}',
      if ((item.color ?? '').isNotEmpty) 'Color: ${item.color}',
      if ((item.variantName ?? '').isNotEmpty && (item.size ?? '').isEmpty)
        item.variantName!,
    ];

    final extraItems = order.items.length - 1;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _Thumb(metrics: m, imageUrl: item.imageUrl),
        SizedBox(width: m.cardGap * 0.8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                item.productTitle,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: m.productNameSize,
                  fontWeight: FontWeight.w600,
                  height: 1.25,
                  color: c.textPrimary,
                ),
              ),
              SizedBox(height: m.cardGap * 0.3),
              Text(
                'Qty: ${item.quantity}  •  ${item.formattedUnitPrice}',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: m.productMetaSize,
                  height: 1.3,
                  color: c.textSecondary,
                ),
              ),
              if (attributes.isNotEmpty) ...[
                SizedBox(height: m.cardGap * 0.2),
                Text(
                  attributes.join('  •  '),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: m.productMetaSize,
                    height: 1.3,
                    color: c.textSecondary,
                  ),
                ),
              ],
              if (extraItems > 0) ...[
                SizedBox(height: m.cardGap * 0.2),
                Text(
                  '+$extraItems more ${extraItems == 1 ? 'item' : 'items'}',
                  style: TextStyle(
                    fontSize: m.productMetaSize,
                    fontWeight: FontWeight.w600,
                    height: 1.3,
                    color: c.brand,
                  ),
                ),
              ],
            ],
          ),
        ),
        SizedBox(width: m.cardGap * 0.5),
        _PriceColumn(metrics: m, order: order, status: status),
      ],
    );
  }
}

// ── Fallback row (list endpoint, no items) ──────────────────

class _SummaryRow extends StatelessWidget {
  const _SummaryRow({
    required this.metrics,
    required this.order,
    required this.status,
  });

  final OrdersMetrics metrics;
  final OrderModel order;
  final OrderStatusStyle status;

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    final m = metrics;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _Thumb(metrics: m, imageUrl: order.previewImageUrl),
        SizedBox(width: m.cardGap * 0.8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                order.formattedItemsLabel(),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: m.productNameSize,
                  fontWeight: FontWeight.w600,
                  height: 1.25,
                  color: c.textPrimary,
                ),
              ),
              SizedBox(height: m.cardGap * 0.3),
              Row(
                children: [
                  Icon(
                    Icons.account_balance_wallet_outlined,
                    size: m.productMetaSize * 1.25,
                    color: c.textSecondary,
                  ),
                  SizedBox(width: m.cardGap * 0.3),
                  Expanded(
                    child: Text(
                      order.displayPaymentMethod,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: m.productMetaSize,
                        height: 1.3,
                        color: c.textSecondary,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        SizedBox(width: m.cardGap * 0.5),
        _PriceColumn(metrics: m, order: order, status: status),
      ],
    );
  }
}

// ── Shared pieces ───────────────────────────────────────────

class _Thumb extends StatelessWidget {
  const _Thumb({required this.metrics, required this.imageUrl});

  final OrdersMetrics metrics;
  final String? imageUrl;

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    final m = metrics;
    final hasImage = imageUrl != null && imageUrl!.isNotEmpty;

    return ClipRRect(
      borderRadius: BorderRadius.circular(m.thumbRadius),
      child: Container(
        width: m.thumbSize,
        height: m.thumbSize,
        color: c.surfaceAlt,
        child: hasImage
            ? Image.network(
                imageUrl!,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Icon(
                  Icons.shopping_bag_outlined,
                  size: m.thumbSize * 0.35,
                  color: c.brand,
                ),
              )
            : Icon(
                Icons.shopping_bag_outlined,
                size: m.thumbSize * 0.35,
                color: c.brand,
              ),
      ),
    );
  }
}

class _PriceColumn extends StatelessWidget {
  const _PriceColumn({
    required this.metrics,
    required this.order,
    required this.status,
  });

  final OrdersMetrics metrics;
  final OrderModel order;
  final OrderStatusStyle status;

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    final m = metrics;

    final tone = OrderStatusStyle.toneOf(order.orderStatus);
    final label = tone == OrderStatusTone.delivered && order.deliveredAt != null
        ? 'Delivered on\n${_shortDate(order.deliveredAt!)}'
        : order.displayPaymentStatus;

    final labelColor = order.isPaid ? c.statusSuccess : status.foreground;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          order.formattedTotal,
          style: TextStyle(
            fontSize: m.priceSize,
            fontWeight: FontWeight.w700,
            color: c.textPrimary,
          ),
        ),
        SizedBox(height: m.cardGap * 0.25),
        SizedBox(
          width: m.thumbSize * 1.2,
          child: Text(
            label,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.end,
            style: TextStyle(
              fontSize: m.productMetaSize,
              fontWeight: FontWeight.w600,
              height: 1.25,
              color: labelColor,
            ),
          ),
        ),
      ],
    );
  }

  static String _shortDate(DateTime d) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return '${d.day} ${months[d.month - 1]} ${d.year}';
  }
}

class _FooterStrip extends StatelessWidget {
  const _FooterStrip({
    required this.metrics,
    required this.order,
    required this.status,
    this.onCta,
  });

  final OrdersMetrics metrics;
  final OrderModel order;
  final OrderStatusStyle status;
  final VoidCallback? onCta;

  String get _footerText {
    switch (OrderStatusStyle.toneOf(order.orderStatus)) {
      case OrderStatusTone.delivered:
        return 'Order Delivered';
      case OrderStatusTone.cancelled:
        return 'Order Cancelled';
      case OrderStatusTone.pending:
        return order.isPaid ? 'Payment Confirmed' : 'Payment Pending';
      case OrderStatusTone.processing:
        return 'Order Processing';
      case OrderStatusTone.shipping:
        return 'Order Shipped';
    }
  }

  String get _ctaLabel {
    switch (OrderStatusStyle.toneOf(order.orderStatus)) {
      case OrderStatusTone.delivered:
        return 'Buy Again';
      case OrderStatusTone.shipping:
      case OrderStatusTone.processing:
        return 'Track Order';
      default:
        return 'View Details';
    }
  }

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    final m = metrics;

    return Container(
      height: m.footerHeight,
      padding: EdgeInsets.symmetric(horizontal: m.cardGap),
      decoration: BoxDecoration(
        color: status.background,
        border: Border(top: BorderSide(color: c.border)),
      ),
      child: Row(
        children: [
          Icon(status.icon, size: m.footerIconSize, color: status.foreground),
          SizedBox(width: m.cardGap * 0.5),
          Expanded(
            child: Text(
              _footerText,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: m.footerTextSize,
                fontWeight: FontWeight.w500,
                height: 1.25,
                color: status.foreground,
              ),
            ),
          ),
          SizedBox(width: m.cardGap * 0.5),
          SizedBox(
            height: m.ctaHeight,
            child: OutlinedButton(
              onPressed: onCta,
              style: OutlinedButton.styleFrom(
                foregroundColor: c.brand,
                backgroundColor: c.surface,
                side: BorderSide(color: c.brand, width: 1.2),
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                padding: EdgeInsets.symmetric(horizontal: m.cardGap * 0.85),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Text(
                _ctaLabel,
                maxLines: 1,
                style: TextStyle(
                  fontSize: m.ctaFontSize,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
