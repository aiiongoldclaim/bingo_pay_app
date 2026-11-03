import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/theme/app_theme_colors.dart';
import 'review_payment_metrics.dart';

// ── Amount ─────────────────────────────────────────────────────────────────
// Large, centred and borderless: the one thing the customer types.
class ReviewPaymentAmountSection extends StatelessWidget {
  final ReviewPaymentMetrics metrics;
  final TextEditingController controller;
  final String currency;
  final String? error;
  final bool autofocus;
  final bool wholeNumbers; // a currency without decimals (VND, JPY…)
  final ValueChanged<String> onChanged;

  const ReviewPaymentAmountSection({
    super.key,
    required this.metrics,
    required this.controller,
    required this.currency,
    required this.error,
    required this.onChanged,
    this.autofocus = false,
    this.wholeNumbers = false,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final m = metrics;
    final big = AppTextStyles.displayLarge.copyWith(
      color: colors.textPrimary,
      fontFamily: 'Inter',
      fontWeight: FontWeight.w600,
      fontSize: m.amountSize * 1.6,
      height: 1.1,
    );

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.baseline,
          textBaseline: TextBaseline.alphabetic,
          children: [
            Text(
              currency,
              style: big.copyWith(
                color: colors.textSecondary,
                fontWeight: FontWeight.w500,
                fontSize: m.currencySize,
              ),
            ),
            SizedBox(width: m.gapSm),
            Flexible(
              child: IntrinsicWidth(
                child: Semantics(
                  label: 'Amount in $currency',
                  child: TextField(
                    controller: controller,
                    onChanged: onChanged,
                    autofocus: autofocus,
                    keyboardType: TextInputType.numberWithOptions(
                      decimal: !wholeNumbers,
                    ),
                    inputFormatters: [
                      // A pasted "1,000" is 1000.
                      FilteringTextInputFormatter.deny(RegExp(r'[\s,]')),
                      // The API takes 2 decimals.
                      FilteringTextInputFormatter.allow(
                        RegExp(wholeNumbers ? r'^\d*' : r'^\d*\.?\d{0,2}'),
                      ),
                    ],
                    style: big,
                    cursorColor: colors.brand,
                    decoration: InputDecoration(
                      hintText: '0',
                      hintStyle: big.copyWith(color: colors.textMuted),
                      border: InputBorder.none,
                      enabledBorder: InputBorder.none,
                      focusedBorder: InputBorder.none,
                      filled: false,
                      isDense: true,
                      contentPadding: EdgeInsets.zero,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: m.gapSm),
        Text(
          error ?? '1 TVS Coin = 1 $currency',
          textAlign: TextAlign.center,
          style: AppTextStyles.bodySmall.copyWith(
            color: error == null ? colors.textMuted : colors.error,
            fontFamily: 'Inter',
            fontWeight: error == null ? FontWeight.w400 : FontWeight.w500,
            fontSize: m.helperSize + 2,
          ),
        ),
      ],
    );
  }
}
