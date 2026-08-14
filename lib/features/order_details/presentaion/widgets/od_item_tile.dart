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

  /// Cancelled/delivered pe outlined "Buy Again" button, warna text link
  final bool actionAsButton;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    final m = metrics;
    final hasImage = (item.imageUrl ?? '').isNotEmpty;

    final meta = [
      if ((item.size ?? '').isNotEmpty) 'Size: ${item.size}',
      if ((item.color ?? '').isNotEmpty) 'Color: ${item.color}',
      'Qty: ${item.quantity}',
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
              color: c.surfaceAlt,
              child: hasImage
                  ? Image.network(
                      item.imageUrl!,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Icon(
                        Icons.inventory_2_outlined,
                        size: m.itemThumbWidth * 0.35,
                        color: c.brand,
                      ),
                    )
                  : Icon(
                      Icons.inventory_2_outlined,
                      size: m.itemThumbWidth * 0.35,
                      color: c.brand,
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
                      color: c.textPrimary,
                    ),
                  ),
                SizedBox(height: m.cardPadding * 0.2),
                Text(
                  item.productTitle,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: m.itemNameSize,
                    height: 1.3,
                    color: c.textSecondary,
                  ),
                ),
                SizedBox(height: m.cardPadding * 0.35),
                Text(
                  meta.join('   |   '),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: m.itemMetaSize,
                    height: 1.3,
                    color: c.textSecondary,
                  ),
                ),
                SizedBox(height: m.cardPadding * 0.35),
                Text(
                  item.formattedUnitPrice,
                  style: TextStyle(
                    fontSize: m.itemPriceSize,
                    fontWeight: FontWeight.w700,
                    color: c.textPrimary,
                  ),
                ),
              ],
            ),
          ),

          SizedBox(width: m.cardPadding * 0.5),

          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                item.formattedTotal,
                style: TextStyle(
                  fontSize: m.itemPriceSize,
                  fontWeight: FontWeight.w700,
                  color: c.textPrimary,
                ),
              ),
              if (actionLabel != null) ...[
                SizedBox(height: m.cardPadding * 0.6),
                if (actionAsButton)
                  SizedBox(
                    height: m.ctaHeight,
                    child: OutlinedButton(
                      onPressed: onAction,
                      style: OutlinedButton.styleFrom(
                        foregroundColor: c.brand,
                        side: BorderSide(color: c.brand, width: 1.2),
                        minimumSize: Size.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        padding: EdgeInsets.symmetric(
                          horizontal: m.cardPadding * 0.7,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: Text(
                        actionLabel!,
                        maxLines: 1,
                        style: TextStyle(
                          fontSize: m.ctaFontSize,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  )
                else
                  InkWell(
                    onTap: onAction,
                    child: Text(
                      actionLabel!,
                      style: TextStyle(
                        fontSize: m.ctaFontSize,
                        fontWeight: FontWeight.w600,
                        color: c.brand,
                      ),
                    ),
                  ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}
