import 'package:flutter/material.dart';

import '../../../../core/theme/theme_colors.dart';

class PriceDetailsCard extends StatelessWidget {
  const PriceDetailsCard({super.key});

  Widget row(
      String title,
      String value, {
        Color? color,
        bool bold = false,
      }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Expanded(child: Text(title)),
          Text(
            value,
            style: TextStyle(
              color: color ?? ThemeColors.ink,
              fontWeight:
              bold ? FontWeight.w700 : FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: ThemeColors.surface,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          row('Subtotal (3 items)', '₹28,970'),
          row(
            'Coupon FESTIVE10',
            '- ₹2,848',
            color: ThemeColors.green,
          ),
          row(
            'BINGOLD coins',
            '- ₹480',
            color: ThemeColors.green,
          ),
          row(
            'Delivery',
            'FREE',
            color: ThemeColors.green,
          ),

          Divider(),

          row(
            'Total payable',
            '₹25,642',
            bold: true,
          ),
        ],
      ),
    );
  }
}