import 'package:flutter/material.dart';

import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/theme/app_theme_colors.dart';
import 'review_payment_metrics.dart';

// ── Quote ──────────────────────────────────────────────────────────────────
// What /qr/quote adds to the amount typed, as quiet lines under it: discount,
// bonus/own split, coupon result, offers nearly reached and any shortfall.
// What the customer pays is on the Pay button.
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
    final colors = context.colors;
    final m = metrics;
    final q = quote;

    if (q == null) {
      if (!quoting) return const SizedBox.shrink();
      return Center(
        child: SizedBox.square(
          dimension: 18,
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

    Widget line(String text, Color color, [FontWeight w = FontWeight.w500]) =>
        Padding(
          padding: EdgeInsets.only(top: m.gapXs),
          child: Text(
            text,
            textAlign: TextAlign.center,
            style: AppTextStyles.bodySmall.copyWith(
              color: color,
              fontFamily: 'Inter',
              fontWeight: w,
              fontSize: m.helperSize + 2,
            ),
          ),
        );

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (hasDiscount)
          line(
            '− ${q['discount']} $cur off'
            '${offer == null ? '' : ' · ${offer['name']}'}',
            colors.statusSuccess,
            FontWeight.w600,
          ),
        if (hasBonus)
          line(
            '${q['fromBonus']} from bonus · ${q['fromAvailable']} from your coins',
            colors.textSecondary,
          ),
        if (coupon != null)
          line(
            '${coupon['message']}',
            coupon['ok'] == true ? colors.statusSuccess : colors.error,
          ),
        for (final a in almost.whereType<Map>())
          line('${a['name']}: ${a['hint']}', colors.statusInfo),
        if (q['sufficient'] != true)
          line(
            'You need ${q['shortfall']} $cur more TVS Coins.',
            colors.error,
            FontWeight.w700,
          ),
      ],
    );
  }
}
