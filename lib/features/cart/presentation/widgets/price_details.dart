// import 'package:flutter/material.dart';
//
// import '../../../../core/theme/app_text_styles.dart';
// import '../../../../core/theme/theme_colors.dart';
//
// class PriceDetailsCard extends StatelessWidget {
//   final double subtotal;
//   final int itemCount;
//
//   const PriceDetailsCard({
//     super.key,
//     required this.subtotal,
//     required this.itemCount,
//   });
//
//   String _fmt(double v) {
//     final s = v.truncate().toString();
//     final buf = StringBuffer();
//     for (int i = 0; i < s.length; i++) {
//       final fromEnd = s.length - i;
//       buf.write(s[i]);
//       final rem = fromEnd - 1;
//       if (rem == 3 || (rem > 3 && (rem - 3) % 2 == 0)) buf.write(',');
//     }
//     return buf.toString();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(20),
//         boxShadow: [
//           BoxShadow(
//             color: const Color(0xFF1A1D4E).withValues(alpha: 0.08),
//             blurRadius: 20,
//             offset: const Offset(0, 4),
//           ),
//         ],
//       ),
//       child: Column(
//         children: [
//           // Header
//           Container(
//             padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
//             decoration: const BoxDecoration(
//               gradient: LinearGradient(
//                 colors: [Color(0xFF1A1D4E), Color(0xFF2B2FA8)],
//                 begin: Alignment.centerLeft,
//                 end: Alignment.centerRight,
//               ),
//               borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
//             ),
//             child: Row(
//               children: [
//                 const Icon(Icons.receipt_long_outlined,
//                     color: Colors.white, size: 18),
//                 const SizedBox(width: 8),
//                 Text(
//                   'Price Details',
//                   style: AppTextStyles.titleMedium
//                       .copyWith(color: Colors.white, fontWeight: FontWeight.w700),
//                 ),
//               ],
//             ),
//           ),
//
//           // Rows
//           Padding(
//             padding: const EdgeInsets.fromLTRB(18, 16, 18, 4),
//             child: Column(
//               children: [
//                 _row(
//                   'Subtotal ($itemCount item${itemCount == 1 ? '' : 's'})',
//                   '\$${_fmt(subtotal)}',
//                 ),
//                 _row('Delivery', '\$0', color: ThemeColors.green),
//                 Divider(
//                     height: 24,
//                     color: ThemeColors.inkDim.withValues(alpha: 0.15)),
//                 _row('Total payable', '\$${_fmt(subtotal)}', bold: true),
//                 const SizedBox(height: 4),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }
//
//   Widget _row(String title, String value, {Color? color, bool bold = false}) {
//     return Padding(
//       padding: const EdgeInsets.only(bottom: 12),
//       child: Row(
//         children: [
//           Expanded(
//             child: Text(
//               title,
//               style: bold
//                   ? AppTextStyles.titleMedium
//                   : AppTextStyles.bodyMedium
//                       .copyWith(color: ThemeColors.inkMid),
//             ),
//           ),
//           Text(
//             value,
//             style: bold
//                 ? AppTextStyles.titleLarge.copyWith(
//                     color: const Color(0xFF1A1D4E),
//                     fontWeight: FontWeight.w800,
//                   )
//                 : AppTextStyles.bodyMedium.copyWith(
//                     color: color ?? ThemeColors.ink,
//                     fontWeight: FontWeight.w600,
//                   ),
//           ),
//         ],
//       ),
//     );
//   }
// }
import 'package:flutter/material.dart';

import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/theme/app_theme_colors.dart';
import 'cart_metrics.dart';

class PriceDetailsCard extends StatelessWidget {
  final double subtotal;
  final int itemCount;

  const PriceDetailsCard({
    super.key,
    required this.subtotal,
    required this.itemCount,
  });

  String _fmt(double v) {
    final parts = v.toStringAsFixed(2).split('.');
    final intPart = parts[0];
    final buf = StringBuffer();
    for (int i = 0; i < intPart.length; i++) {
      buf.write(intPart[i]);
      final rem = intPart.length - i - 1;
      if (rem > 0 && rem % 3 == 0) buf.write(',');
    }
    return '${buf.toString()}.${parts[1]}';
  }

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    final m = CartMetrics.of(context);

    return Container(
      padding: EdgeInsets.all(m.cardPad),
      decoration: BoxDecoration(
        color: c.surface,
        borderRadius: BorderRadius.circular(m.cardRadius),
        border: Border.all(color: c.border, width: 1),
        boxShadow: c.isDark
            ? null
            : [
                BoxShadow(
                  color: c.textPrimary.withValues(alpha: 0.04),
                  blurRadius: 14,
                  offset: const Offset(0, 3),
                ),
              ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Order Summary',
            style: AppTextStyles.titleMedium.copyWith(
              color: c.textPrimary,
              fontFamily: 'Inter',
              fontWeight: FontWeight.w700,
              fontSize: m.summaryTitleSize,
            ),
          ),

          SizedBox(height: m.gapMd),

          _Row(
            label: 'Bag Total ($itemCount item${itemCount == 1 ? '' : 's'})',
            value: '\$${_fmt(subtotal)}',
            metrics: m,
          ),
          _Row(
            label: 'Shipping Fee',
            value: 'FREE',
            valueColor: c.statusSuccess,
            metrics: m,
            trailingInfo: true,
          ),

          Padding(
            padding: EdgeInsets.symmetric(vertical: m.gapSm * 0.6),
            child: Divider(height: 1, thickness: 1, color: c.border),
          ),

          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: Text(
                  'Total Amount',
                  style: AppTextStyles.titleMedium.copyWith(
                    color: c.textPrimary,
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.w700,
                    fontSize: m.totalLabelSize,
                  ),
                ),
              ),
              Text(
                '\$${_fmt(subtotal)}',
                textAlign: TextAlign.right,
                style: AppTextStyles.titleLarge.copyWith(
                  color: c.brand,
                  fontFamily: 'Inter',
                  fontWeight: FontWeight.w800,
                  fontSize: m.totalValueSize,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _Row extends StatelessWidget {
  final String label;
  final String value;
  final Color? valueColor;
  final CartMetrics metrics;
  final bool trailingInfo;

  const _Row({
    required this.label,
    required this.value,
    this.valueColor,
    required this.metrics,
    this.trailingInfo = false,
  });

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    final m = metrics;

    return Padding(
      padding: EdgeInsets.only(bottom: m.gapSm),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Label left me — poori bachi hui jagah leta hai
          Expanded(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Flexible(
                  child: Text(
                    label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: c.textSecondary,
                      fontFamily: 'Inter',
                      fontSize: m.summaryLabelSize,
                    ),
                  ),
                ),
                if (trailingInfo) ...[
                  SizedBox(width: m.gapXs),
                  Icon(
                    Icons.info_outline_rounded,
                    size: m.summaryLabelSize + 2,
                    color: c.textMuted,
                  ),
                ],
              ],
            ),
          ),

          SizedBox(width: m.gapSm),

          // Value hamesha right edge par
          Text(
            value,
            textAlign: TextAlign.right,
            style: AppTextStyles.bodyMedium.copyWith(
              color: valueColor ?? c.textPrimary,
              fontFamily: 'Inter',
              fontWeight: FontWeight.w600,
              fontSize: m.summaryValueSize,
            ),
          ),
        ],
      ),
    );
  }
}
