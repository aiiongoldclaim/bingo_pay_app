import 'package:flutter/material.dart';

import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/theme/app_theme_colors.dart';
import 'review_payment_metrics.dart';

// ── Optional field ─────────────────────────────────────────────────────────
// A note or coupon: a quiet link until tapped, then a plain field.
class ReviewPaymentNoteSection extends StatefulWidget {
  final ReviewPaymentMetrics metrics;
  final TextEditingController controller;
  final ValueChanged<String> onChanged;
  final String label; // the link
  final String hint;
  final IconData icon;
  final int maxLength;
  final TextCapitalization capitalization;

  const ReviewPaymentNoteSection({
    super.key,
    required this.metrics,
    required this.controller,
    required this.onChanged,
    this.label = 'Add a note',
    this.hint = 'What is this payment for?',
    this.icon = Icons.edit_note_rounded,
    this.maxLength = 50,
    this.capitalization = TextCapitalization.sentences,
  });

  @override
  State<ReviewPaymentNoteSection> createState() =>
      _ReviewPaymentNoteSectionState();
}

class _ReviewPaymentNoteSectionState extends State<ReviewPaymentNoteSection> {
  late bool _open = widget.controller.text.isNotEmpty;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final w = widget;

    if (!_open) {
      return TextButton.icon(
        onPressed: () => setState(() => _open = true),
        icon: Icon(w.icon, size: 18),
        label: Text(w.label),
        style: TextButton.styleFrom(
          foregroundColor: colors.textSecondary,
          textStyle: AppTextStyles.bodyMedium.copyWith(
            fontFamily: 'Inter',
            fontWeight: FontWeight.w500,
            fontSize: w.metrics.helperSize + 3,
          ),
        ),
      );
    }

    final none = OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide.none,
    );
    // Full width, also inside the Wrap that holds the closed links.
    return SizedBox(
      width: double.infinity,
      child: TextField(
        controller: w.controller,
        onChanged: w.onChanged,
        autofocus: true,
        maxLength: w.maxLength,
        textCapitalization: w.capitalization,
        style: AppTextStyles.bodyMedium.copyWith(
          color: colors.textPrimary,
          fontFamily: 'Inter',
          fontSize: w.metrics.methodTitleSize,
        ),
        decoration: InputDecoration(
          hintText: w.hint,
          hintStyle: AppTextStyles.bodyMedium.copyWith(
            color: colors.textMuted,
            fontFamily: 'Inter',
            fontSize: w.metrics.methodTitleSize,
          ),
          prefixIcon: Icon(w.icon, size: 20, color: colors.textSecondary),
          counterText: '',
          filled: true,
          fillColor: colors.surfaceAlt,
          isDense: true,
          border: none,
          enabledBorder: none,
          focusedBorder: none,
        ),
      ),
    );
  }
}
