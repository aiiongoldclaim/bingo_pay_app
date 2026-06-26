import 'package:flutter/material.dart';

import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/theme/theme_colors.dart';

class PriceDetailsCard extends StatelessWidget {
  final double subtotal;
  final int itemCount;

  const PriceDetailsCard({
    super.key,
    required this.subtotal,
    required this.itemCount,
  });

  String _fmt(double v) {
    final s = v.truncate().toString();
    final buf = StringBuffer();
    for (int i = 0; i < s.length; i++) {
      final fromEnd = s.length - i;
      buf.write(s[i]);
      final rem = fromEnd - 1;
      if (rem == 3 || (rem > 3 && (rem - 3) % 2 == 0)) buf.write(',');
    }
    return buf.toString();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
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
        children: [
          // Header
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF1A1D4E), Color(0xFF2B2FA8)],
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
              ),
              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            ),
            child: Row(
              children: [
                const Icon(Icons.receipt_long_outlined,
                    color: Colors.white, size: 18),
                const SizedBox(width: 8),
                Text(
                  'Price Details',
                  style: AppTextStyles.titleMedium
                      .copyWith(color: Colors.white, fontWeight: FontWeight.w700),
                ),
              ],
            ),
          ),

          // Rows
          Padding(
            padding: const EdgeInsets.fromLTRB(18, 16, 18, 4),
            child: Column(
              children: [
                _row(
                  'Subtotal ($itemCount item${itemCount == 1 ? '' : 's'})',
                  '\$${_fmt(subtotal)}',
                ),
                _row('Delivery', '\$0', color: ThemeColors.green),
                Divider(
                    height: 24,
                    color: ThemeColors.inkDim.withValues(alpha: 0.15)),
                _row('Total payable', '\$${_fmt(subtotal)}', bold: true),
                const SizedBox(height: 4),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _row(String title, String value, {Color? color, bool bold = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Expanded(
            child: Text(
              title,
              style: bold
                  ? AppTextStyles.titleMedium
                  : AppTextStyles.bodyMedium
                      .copyWith(color: ThemeColors.inkMid),
            ),
          ),
          Text(
            value,
            style: bold
                ? AppTextStyles.titleLarge.copyWith(
                    color: const Color(0xFF1A1D4E),
                    fontWeight: FontWeight.w800,
                  )
                : AppTextStyles.bodyMedium.copyWith(
                    color: color ?? ThemeColors.ink,
                    fontWeight: FontWeight.w600,
                  ),
          ),
        ],
      ),
    );
  }
}
