import 'package:flutter/material.dart';

import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/theme/app_theme_colors.dart';
import 'review_payment_metrics.dart';
import 'review_payment_section_label.dart';

// ── Note ───────────────────────────────────────────────────────────────────
class ReviewPaymentNoteSection extends StatelessWidget {
  final ReviewPaymentMetrics metrics;
  final TextEditingController controller;
  final ValueChanged<String> onChanged;
  final String label;
  final String hint;
  final IconData icon;
  final int maxLength;
  final TextCapitalization capitalization;

  const ReviewPaymentNoteSection({
    super.key,
    required this.metrics,
    required this.controller,
    required this.onChanged,
    this.label = 'ADD NOTE (OPTIONAL)',
    this.hint = 'What is this payment for?',
    this.icon = Icons.sticky_note_2_outlined,
    this.maxLength = 50,
    this.capitalization = TextCapitalization.sentences,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.c;
    final m = metrics;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        ReviewPaymentSectionLabel(metrics: m, label: label),

        SizedBox(height: m.gapSm),

        Container(
          height: m.noteBoxHeight,
          padding: EdgeInsets.symmetric(horizontal: m.cardPad * 0.7),
          decoration: BoxDecoration(
            color: colors.surface,
            borderRadius: BorderRadius.circular(m.cardRadius * 0.8),
            border: Border.all(color: colors.border, width: 1),
          ),
          child: Row(
            children: [
              Icon(
                icon,
                size: m.methodIconSize * 0.85,
                color: colors.textSecondary,
              ),

              SizedBox(width: m.gapSm),

              Expanded(
                child: TextField(
                  controller: controller,
                  onChanged: onChanged,
                  maxLength: maxLength,
                  textCapitalization: capitalization,
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: colors.textPrimary,
                    fontFamily: 'Inter',
                    fontSize: m.methodTitleSize,
                  ),
                  decoration: InputDecoration(
                    hintText: hint,
                    hintStyle: AppTextStyles.bodyMedium.copyWith(
                      color: colors.textMuted,
                      fontFamily: 'Inter',
                      fontSize: m.methodTitleSize,
                    ),
                    counterText: '',
                    border: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    isDense: true,
                    contentPadding: EdgeInsets.zero,
                  ),
                ),
              ),

              SizedBox(width: m.gapSm),

              Text(
                '${controller.text.length}/$maxLength',
                style: AppTextStyles.bodySmall.copyWith(
                  color: colors.textMuted,
                  fontFamily: 'Inter',
                  fontSize: m.helperSize,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
