import 'package:flutter/material.dart';

import '../../../../core/theme/app_theme_colors.dart';
import '../../../orders/data/models/order_model.dart';
import 'order_details_metrics.dart';

class OdPriceDetails extends StatelessWidget {
  const OdPriceDetails({super.key, required this.metrics, required this.order});

  final OrderDetailMetrics metrics;
  final OrderModel order;

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    final m = metrics;

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: m.pagePadding),
      child: Container(
        padding: EdgeInsets.all(m.cardPadding),
        decoration: BoxDecoration(
          color: c.surface,
          borderRadius: BorderRadius.circular(m.cardRadius),
          border: Border.all(color: c.border),
        ),
        child: Column(
          children: [
            _Row(
              metrics: m,
              label: 'Bag Total',
              value: formatAmount(order.subtotalAmount),
            ),
            if (order.discountAmount > 0) ...[
              SizedBox(height: m.priceRowGap),
              _Row(
                metrics: m,
                label: 'Discount',
                value: '- ${formatAmount(order.discountAmount)}',
                highlight: c.statusSuccess,
              ),
            ],
            if (order.taxAmount > 0) ...[
              SizedBox(height: m.priceRowGap),
              _Row(
                metrics: m,
                label: 'Tax',
                value: formatAmount(order.taxAmount),
              ),
            ],
            SizedBox(height: m.priceRowGap),
            _Row(
              metrics: m,
              label: 'Shipping Fee',
              value: order.shippingAmount > 0
                  ? formatAmount(order.shippingAmount)
                  : 'Free',
              highlight: order.shippingAmount > 0 ? null : c.statusSuccess,
            ),
            SizedBox(height: m.priceRowGap * 1.3),
            _DashedDivider(color: c.border),
            SizedBox(height: m.priceRowGap * 1.3),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Total Amount',
                  style: TextStyle(
                    fontSize: m.priceRowSize * 1.12,
                    fontWeight: FontWeight.w700,
                    color: c.textPrimary,
                  ),
                ),
                Text(
                  order.formattedTotal,
                  style: TextStyle(
                    fontSize: m.priceTotalSize,
                    fontWeight: FontWeight.w800,
                    color: c.brand,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _Row extends StatelessWidget {
  const _Row({
    required this.metrics,
    required this.label,
    required this.value,
    this.highlight,
  });

  final OrderDetailMetrics metrics;
  final String label;
  final String value;
  final Color? highlight;

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    final m = metrics;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Flexible(
          child: Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: m.priceRowSize,
              color: highlight ?? c.textPrimary,
            ),
          ),
        ),
        SizedBox(width: m.cardPadding * 0.5),
        Text(
          value,
          style: TextStyle(
            fontSize: m.priceRowSize,
            fontWeight: FontWeight.w600,
            color: highlight ?? c.textPrimary,
          ),
        ),
      ],
    );
  }
}

class _DashedDivider extends StatelessWidget {
  const _DashedDivider({required this.color});
  final Color color;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        const dashWidth = 4.0;
        const dashGap = 4.0;
        final count = (constraints.maxWidth / (dashWidth + dashGap)).floor();
        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: List.generate(
            count,
            (_) => SizedBox(
              width: dashWidth,
              height: 1,
              child: ColoredBox(color: color),
            ),
          ),
        );
      },
    );
  }
}
