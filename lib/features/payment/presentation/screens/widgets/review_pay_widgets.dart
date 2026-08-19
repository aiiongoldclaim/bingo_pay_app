import 'package:bingo_pay/features/payment/presentation/screens/widgets/review_pay_metrics.dart';
import 'package:flutter/material.dart';

import '../../../../../core/theme/app_text_styles.dart';
import '../../../../../core/theme/app_theme_colors.dart';


// ── Reusable section card ──────────────────────────────────────────────────
class ReviewCard extends StatelessWidget {
  final ReviewPayMetrics metrics;
  final Widget child;
  final EdgeInsets? padding;

  const ReviewCard({
    super.key,
    required this.metrics,
    required this.child,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    final m = metrics;

    return Container(
      padding: padding ?? EdgeInsets.all(m.cardPad),
      decoration: BoxDecoration(
        color: c.surface,
        borderRadius: BorderRadius.circular(m.cardRadius),
        border: Border.all(color: c.border, width: 1),
      ),
      child: child,
    );
  }
}

// ── Reusable label/value row ───────────────────────────────────────────────
class ReviewRow extends StatelessWidget {
  final ReviewPayMetrics metrics;
  final String label;
  final String value;
  final Color? valueColor;
  final bool isTotal;

  const ReviewRow({
    super.key,
    required this.metrics,
    required this.label,
    required this.value,
    this.valueColor,
    this.isTotal = false,
  });

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    final m = metrics;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          child: Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: isTotal
                ? AppTextStyles.titleMedium.copyWith(
              color: c.textPrimary,
              fontFamily: 'Inter',
              fontWeight: FontWeight.w700,
              fontSize: m.totalLabelSize,
            )
                : AppTextStyles.bodyMedium.copyWith(
              color: c.textSecondary,
              fontFamily: 'Inter',
              fontSize: m.rowLabelSize,
            ),
          ),
        ),
        SizedBox(width: m.gapSm),
        Text(
          value,
          textAlign: TextAlign.right,
          style: isTotal
              ? AppTextStyles.titleLarge.copyWith(
            color: c.brand,
            fontFamily: 'Inter',
            fontWeight: FontWeight.w800,
            fontSize: m.totalValueSize,
          )
              : AppTextStyles.bodyMedium.copyWith(
            color: valueColor ?? c.textPrimary,
            fontFamily: 'Inter',
            fontWeight: FontWeight.w600,
            fontSize: m.rowValueSize,
          ),
        ),
      ],
    );
  }
}

// ── Reusable icon + title + subtitle strip ─────────────────────────────────
class ReviewInfoStrip extends StatelessWidget {
  final ReviewPayMetrics metrics;
  final IconData icon;
  final String title;
  final String subtitle;

  const ReviewInfoStrip({
    super.key,
    required this.metrics,
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    final m = metrics;

    return Container(
      padding: EdgeInsets.all(m.cardPad * 0.85),
      decoration: BoxDecoration(
        color: c.brandSoft,
        borderRadius: BorderRadius.circular(m.cardRadius),
      ),
      child: Row(
        children: [
          Container(
            width: m.stripIconBox,
            height: m.stripIconBox,
            decoration: BoxDecoration(
              color: c.surface.withValues(alpha: c.isDark ? 0.10 : 0.7),
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: Icon(icon, size: m.stripIconSize, color: c.brand),
          ),
          SizedBox(width: m.cardPad * 0.7),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.labelLarge.copyWith(
                    color: c.brand,
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.w700,
                    fontSize: m.stripTitleSize,
                    letterSpacing: 0.3,
                    height: 1.3,
                  ),
                ),
                SizedBox(height: m.gapXs * 0.6),
                Text(
                  subtitle,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.bodySmall.copyWith(
                    color: c.textSecondary,
                    fontFamily: 'Inter',
                    fontSize: m.stripSubSize,
                    height: 1.35,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Section heading (small caps label) ─────────────────────────────────────
class ReviewSectionLabel extends StatelessWidget {
  final ReviewPayMetrics metrics;
  final String label;
  final IconData? icon;

  const ReviewSectionLabel({
    super.key,
    required this.metrics,
    required this.label,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    final m = metrics;

    return Row(
      children: [
        if (icon != null) ...[
          Icon(icon, size: m.sectionLabelSize + 4, color: c.brand),
          SizedBox(width: m.gapXs * 1.4),
        ],
        Text(
          label.toUpperCase(),
          style: AppTextStyles.labelMedium.copyWith(
            color: c.brand,
            fontFamily: 'Inter',
            fontWeight: FontWeight.w700,
            fontSize: m.sectionLabelSize,
            letterSpacing: 0.6,
          ),
        ),
      ],
    );
  }
}

// ── Offers ─────────────────────────────────────────────────────────────────
class ReviewOffer {
  final String title;
  final String subtitle;

  const ReviewOffer({required this.title, required this.subtitle});
}

class ReviewOffersCard extends StatelessWidget {
  final ReviewPayMetrics metrics;
  final List<ReviewOffer> offers;
  final VoidCallback? onViewAll;

  const ReviewOffersCard({
    super.key,
    required this.metrics,
    required this.offers,
    this.onViewAll,
  });

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    final m = metrics;

    if (offers.isEmpty) return const SizedBox.shrink();

    return ReviewCard(
      metrics: m,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          ReviewSectionLabel(
            metrics: m,
            label: 'Offers For You',
            icon: Icons.local_offer_outlined,
          ),

          SizedBox(height: m.gapMd),

          ...List.generate(offers.length, (i) {
            final offer = offers[i];
            final isLast = i == offers.length - 1;

            return Column(
              children: [
                Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () {},
                    borderRadius: BorderRadius.circular(m.cardRadius * 0.6),
                    child: Padding(
                      padding: EdgeInsets.symmetric(vertical: m.gapSm * 0.9),
                      child: Row(
                        children: [
                          Container(
                            width: m.offerIconBox,
                            height: m.offerIconBox,
                            decoration: BoxDecoration(
                              color: c.brandSoft,
                              shape: BoxShape.circle,
                            ),
                            alignment: Alignment.center,
                            child: Icon(
                              Icons.percent_rounded,
                              size: m.offerIconSize,
                              color: c.brand,
                            ),
                          ),
                          SizedBox(width: m.cardPad * 0.7),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  offer.title,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: AppTextStyles.labelLarge.copyWith(
                                    color: c.textPrimary,
                                    fontFamily: 'Inter',
                                    fontWeight: FontWeight.w600,
                                    fontSize: m.offerTitleSize,
                                    height: 1.3,
                                  ),
                                ),
                                SizedBox(height: m.gapXs * 0.6),
                                Text(
                                  offer.subtitle,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: AppTextStyles.bodySmall.copyWith(
                                    color: c.textSecondary,
                                    fontFamily: 'Inter',
                                    fontSize: m.offerSubSize,
                                    height: 1.3,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Icon(
                            Icons.chevron_right_rounded,
                            size: m.offerTitleSize + 10,
                            color: c.textMuted,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                if (!isLast)
                  Divider(height: 1, thickness: 1, color: c.border),
              ],
            );
          }),

          SizedBox(height: m.gapSm),

          Center(
            child: InkWell(
              onTap: onViewAll,
              borderRadius: BorderRadius.circular(8),
              child: Padding(
                padding: EdgeInsets.all(m.gapXs * 1.4),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'View All Offers (${offers.length})',
                      style: AppTextStyles.labelMedium.copyWith(
                        color: c.brand,
                        fontFamily: 'Inter',
                        fontWeight: FontWeight.w700,
                        fontSize: m.linkSize,
                      ),
                    ),
                    SizedBox(width: m.gapXs),
                    Icon(
                      Icons.chevron_right_rounded,
                      size: m.linkSize + 6,
                      color: c.brand,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Reusable outlined field ────────────────────────────────────────────────
class ReviewField extends StatelessWidget {
  final ReviewPayMetrics metrics;
  final TextEditingController controller;
  final String hint;
  final int maxLines;
  final int? maxLength;
  final Widget? suffix;
  final TextCapitalization textCapitalization;
  final ValueChanged<String>? onChanged;

  const ReviewField({
    super.key,
    required this.metrics,
    required this.controller,
    required this.hint,
    this.maxLines = 1,
    this.maxLength,
    this.suffix,
    this.textCapitalization = TextCapitalization.none,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    final m = metrics;

    return TextField(
      controller: controller,
      maxLines: maxLines,
      maxLength: maxLength,
      textCapitalization: textCapitalization,
      onChanged: onChanged,
      style: AppTextStyles.bodyMedium.copyWith(
        color: c.textPrimary,
        fontFamily: 'Inter',
        fontSize: m.fieldTextSize,
      ),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: AppTextStyles.bodyMedium.copyWith(
          color: c.textMuted,
          fontFamily: 'Inter',
          fontSize: m.fieldTextSize,
        ),
        counterStyle: AppTextStyles.bodySmall.copyWith(
          color: c.textMuted,
          fontFamily: 'Inter',
          fontSize: m.offerSubSize,
        ),
        filled: true,
        fillColor: c.surface,
        isDense: true,
        suffixIcon: suffix,
        contentPadding: EdgeInsets.symmetric(
          horizontal: m.cardPad * 0.8,
          vertical: m.gapMd * 0.8,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(m.fieldRadius),
          borderSide: BorderSide(color: c.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(m.fieldRadius),
          borderSide: BorderSide(color: c.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(m.fieldRadius),
          borderSide: BorderSide(color: c.brand, width: 1.5),
        ),
      ),
    );
  }
}