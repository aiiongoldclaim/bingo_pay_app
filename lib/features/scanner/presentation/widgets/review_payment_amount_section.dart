import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/theme/app_theme_colors.dart';
import 'review_payment_metrics.dart';
import 'review_payment_section_label.dart';

// ── Amount (TextField — keyboard) ──────────────────────────────────────────
class ReviewPaymentAmountSection extends StatelessWidget {
  final ReviewPaymentMetrics metrics;
  final TextEditingController controller;
  final String currency;
  final String? error;
  final ValueChanged<String> onChanged;

  const ReviewPaymentAmountSection({
    super.key,
    required this.metrics,
    required this.controller,
    required this.currency,
    required this.error,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.c;
    final m = metrics;
    final isError = error != null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        ReviewPaymentSectionLabel(metrics: m, label: 'ENTER AMOUNT'),

        SizedBox(height: m.gapSm),

        Container(
          height: m.amountBoxHeight,
          decoration: BoxDecoration(
            color: colors.surface,
            borderRadius: BorderRadius.circular(m.cardRadius * 0.8),
            border: Border.all(
              color: isError ? colors.error : colors.brand,
              width: 1.5,
            ),
          ),
          clipBehavior: Clip.antiAlias,
          child: Row(
            children: [
              Container(
                width: m.amountPrefixWidth,
                height: double.infinity,
                color: colors.brandSoft,
                alignment: Alignment.center,
                child: Text(
                  currency,
                  style: AppTextStyles.titleMedium.copyWith(
                    color: colors.brand,
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.w700,
                    fontSize: m.currencySize,
                  ),
                ),
              ),

              Expanded(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: m.cardPad * 0.7),
                  child: TextField(
                    controller: controller,
                    onChanged: onChanged,
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(
                        RegExp(r'^\d*\.?\d{0,2}'), // the API takes 2 decimals

                      ),
                    ],
                    style: AppTextStyles.displayLarge.copyWith(
                      color: colors.textPrimary,
                      fontFamily: 'Inter',
                      fontWeight: FontWeight.w500,
                      fontSize: m.amountSize,
                      height: 1.1,
                    ),
                    decoration: InputDecoration(
                      hintText: '0.00',
                      hintStyle: AppTextStyles.displayLarge.copyWith(
                        color: colors.textMuted,
                        fontFamily: 'Inter',
                        fontWeight: FontWeight.w400,
                        fontSize: m.amountSize,
                        height: 1.1,
                      ),
                      border: InputBorder.none,
                      enabledBorder: InputBorder.none,
                      focusedBorder: InputBorder.none,
                      isDense: true,
                      contentPadding: EdgeInsets.zero,
                    ),
                  ),
                ),
              ),

              Padding(
                padding: EdgeInsets.only(right: m.cardPad * 0.8),
                child: Text(
                  currency,
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: colors.textMuted,
                    fontFamily: 'Inter',
                    fontSize: m.currencySize,
                  ),
                ),
              ),
            ],
          ),
        ),

        SizedBox(height: m.gapSm),

        if (isError)
          Row(
            children: [
              Icon(
                Icons.info_outline_rounded,
                size: m.helperSize + 3,
                color: colors.error,
              ),
              SizedBox(width: m.gapXs),
              Expanded(
                child: Text(
                  error!,
                  style: AppTextStyles.bodySmall.copyWith(
                    color: colors.error,
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.w500,
                    fontSize: m.helperSize,
                  ),
                ),
              ),
            ],
          )
        else
          Text(
            '1 TVS Coin = 1 $currency',
            style: AppTextStyles.bodySmall.copyWith(
              color: colors.textSecondary,
              fontFamily: 'Inter',
              fontSize: m.helperSize+3,
            ),
          ),
      ],
    );
  }
}
