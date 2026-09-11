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
  final bool isOverLimit;
  final double maxAmount;
  final ValueChanged<String> onChanged;
  final VoidCallback onToggleCurrency;

  const ReviewPaymentAmountSection({
    super.key,
    required this.metrics,
    required this.controller,
    required this.currency,
    required this.isOverLimit,
    required this.maxAmount,
    required this.onChanged,
    required this.onToggleCurrency,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.c;
    final m = metrics;
    final decimals = currency == "USD" ? 2 : 8;

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
              color: isOverLimit ? colors.statusWarning : colors.brand,
              width: 1.5,
            ),
          ),
          clipBehavior: Clip.antiAlias,
          child: Row(
            children: [
              Material(
                color: colors.brandSoft,
                child: InkWell(
                  onTap: onToggleCurrency,
                  child: Container(
                    width: m.amountPrefixWidth,
                    height: double.infinity,
                    alignment: Alignment.center,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          currency,
                          style: AppTextStyles.titleMedium.copyWith(
                            color: colors.brand,
                            fontFamily: 'Inter',
                            fontWeight: FontWeight.w700,
                            fontSize: m.currencySize,
                          ),
                        ),
                        SizedBox(width: m.gapXs),
                        Icon(
                          Icons.keyboard_arrow_down_rounded,
                          size: m.currencySize + 6,
                          color: colors.brand,
                        ),
                      ],
                    ),
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
                        RegExp(r'^\d*\.?\d{0,' '$decimals' r'}'),
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

        if (isOverLimit)
          Row(
            children: [
              Icon(
                Icons.info_outline_rounded,
                size: m.helperSize + 3,
                color: colors.statusWarning,
              ),
              SizedBox(width: m.gapXs),
              Expanded(
                child: Text(
                  'You can only send upto \$${maxAmount.toStringAsFixed(1)} at a time.',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: colors.statusWarning,
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
            'Minimum amount \$1.00',
            style: AppTextStyles.bodySmall.copyWith(
              color: colors.textSecondary,
              fontFamily: 'Inter',
              fontSize: m.helperSize,
            ),
          ),
      ],
    );
  }
}
