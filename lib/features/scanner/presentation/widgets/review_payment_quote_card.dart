import 'package:flutter/material.dart';

import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/theme/app_theme_colors.dart';
import 'review_payment_metrics.dart';

// ── Quote ──────────────────────────────────────────────────────────────────
// What /qr/quote says the customer pays: discount, bonus/own split, coupon
// result, offers they nearly qualify for, and any shortfall.
class ReviewPaymentQuoteCard extends StatelessWidget {
  final ReviewPaymentMetrics metrics;
  final Map<String, dynamic>? quote;
  final bool quoting;

  const ReviewPaymentQuoteCard({
    super.key,
    required this.metrics,
    required this.quote,
    required this.quoting,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.c;
    final m = metrics;
    final q = quote;

    if (q == null) {
      if (!quoting) return const SizedBox.shrink();
      return Center(
        child: SizedBox.square(
          dimension: m.convertLabelSize * 2,
          child: CircularProgressIndicator(strokeWidth: 2, color: colors.brand),
        ),
      );
    }

    final cur = '${q['currency']}';
    final offer = q['offer'] as Map<String, dynamic>?;
    final coupon = q['code'] as Map<String, dynamic>?;
    final almost = (q['almost'] as List?) ?? const [];
    final hasDiscount = (double.tryParse('${q['discount']}') ?? 0) > 0;
    final hasBonus = (double.tryParse('${q['fromBonus']}') ?? 0) > 0;

    TextStyle style(Color c, {double? size, FontWeight w = FontWeight.w500}) =>
        AppTextStyles.bodyMedium.copyWith(
          color: c,
          fontFamily: 'Inter',
          fontWeight: w,
          fontSize: size ?? m.convertLabelSize,
        );

    Widget row(String label, String value, {bool strong = false}) => Padding(
      padding: EdgeInsets.only(bottom: m.gapXs),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: style(strong ? colors.textPrimary : colors.textSecondary,
                  size: strong ? m.convertValueSize : null,
                  w: strong ? FontWeight.w700 : FontWeight.w500),
            ),
          ),
          Text(
            value,
            style: style(strong ? colors.brand : colors.textPrimary,
                size: strong ? m.convertValueSize : null,
                w: strong ? FontWeight.w800 : FontWeight.w600),
          ),
        ],
      ),
    );

    return Container(
      padding: EdgeInsets.all(m.cardPad),
      decoration: BoxDecoration(
        color: colors.brandSoft,
        borderRadius: BorderRadius.circular(m.cardRadius),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          row('Amount', '${q['amount']} $cur'),
          if (hasDiscount)
            row(
              offer == null ? 'Discount' : 'Discount · ${offer['name']}',
              '− ${q['discount']} $cur',
            ),
          Divider(color: colors.border, height: m.gapMd),
          row('You pay', '${q['payable']} $cur', strong: true),
          if (hasBonus)
            Text(
              '${q['fromBonus']} from bonus coins · ${q['fromAvailable']} from your coins',
              style: style(colors.textSecondary, size: m.helperSize + 2),
            ),
          if (coupon != null) ...[
            SizedBox(height: m.gapSm),
            Text(
              '${coupon['message']}',
              style: style(
                coupon['ok'] == true ? colors.statusSuccess : colors.error,
                size: m.helperSize + 2,
              ),
            ),
          ],
          for (final a in almost.whereType<Map>()) ...[
            SizedBox(height: m.gapXs),
            Text(
              '${a['name']}: ${a['hint']}',
              style: style(colors.statusInfo, size: m.helperSize + 2),
            ),
          ],
          if (q['sufficient'] != true) ...[
            SizedBox(height: m.gapSm),
            Text(
              'You need ${q['shortfall']} $cur more TVS Coins.',
              style: style(colors.error, w: FontWeight.w700),
            ),
          ],
        ],
      ),
    );
  }
}
