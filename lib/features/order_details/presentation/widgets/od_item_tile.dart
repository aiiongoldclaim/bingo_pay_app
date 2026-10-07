import 'package:flutter/material.dart';

import '../../../../core/theme/app_theme_colors.dart';
import '../../../orders/data/models/order_model.dart';
import 'order_details_metrics.dart';

class OdItemTile extends StatelessWidget {
  const OdItemTile({
    super.key,
    required this.metrics,
    required this.item,
    this.actionLabel,
    this.actionAsButton = false,
    this.onAction,
  });

  final OrderDetailMetrics metrics;
  final OrderItemModel item;
  final String? actionLabel;

  final bool actionAsButton;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    final colors = context.c;
    final m = metrics;
    final hasImage = (item.imageUrl ?? '').isNotEmpty;

    final meta = [
      if ((item.size ?? '').isNotEmpty) 'Size: ${item.size}',
      if ((item.color ?? '').isNotEmpty) 'Color: ${item.color}',
    ];

    return Padding(
      padding: EdgeInsets.all(m.cardPadding),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(m.itemThumbRadius),
            child: Container(
              width: m.itemThumbWidth,
              height: m.itemThumbHeight,
              color: colors.surfaceAlt,
              child: hasImage
                  ? Image.network(
                      item.imageUrl!,
                      fit: BoxFit.cover,
                      errorBuilder: (_, _, _) => Icon(
                        Icons.inventory_2_outlined,
                        size: m.itemThumbWidth * 0.35,
                        color: colors.brand,
                      ),
                    )
                  : Icon(
                      Icons.inventory_2_outlined,
                      size: m.itemThumbWidth * 0.35,
                      color: colors.brand,
                    ),
            ),
          ),

          SizedBox(width: m.cardPadding * 0.75),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                if ((item.brandName ?? '').isNotEmpty)
                  Text(
                    item.brandName!.toUpperCase(),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: m.itemBrandSize,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.3,
                      color: colors.textPrimary,
                    ),
                  ),
                SizedBox(height: m.cardPadding * 0.2),
                Text(
                  item.productTitle.toUpperCase(),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: m.itemNameSize,
                    height: 1.3,
                    color: colors.textSecondary,
                  ),
                ),
                SizedBox(height: m.cardPadding * 0.35),
                Text.rich(
                  TextSpan(
                    style: TextStyle(
                      fontSize: m.itemMetaSize,
                      height: 1.3,
                      color: colors.textSecondary,
                    ),
                    children: [
                      if (meta.isNotEmpty)
                        TextSpan(text: '${meta.join('   |   ')}   |   '),
                      TextSpan(
                        text: 'Qty: ${item.quantity}',
                        style: const TextStyle(fontWeight: FontWeight.w700),
                      ),
                    ],
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: m.cardPadding * 0.35),
                Text(
                  item.formattedTotal,
                  style: TextStyle(
                    fontSize: m.itemPriceSize,
                    fontWeight: FontWeight.w700,
                    color: colors.textPrimary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
