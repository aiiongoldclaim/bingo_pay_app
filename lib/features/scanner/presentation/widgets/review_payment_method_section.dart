import 'package:flutter/material.dart';

import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/theme/app_theme_colors.dart';
import 'review_payment_metrics.dart';
import 'review_payment_section_label.dart';

// ── Payment method ─────────────────────────────────────────────────────────
class ReviewPaymentMethodSection extends StatelessWidget {
  final ReviewPaymentMetrics metrics;
  final ScanPayMethod selected;
  final ValueChanged<ScanPayMethod> onSelect;

  const ReviewPaymentMethodSection({
    super.key,
    required this.metrics,
    required this.selected,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    final m = metrics;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        ReviewPaymentSectionLabel(metrics: m, label: 'PAYMENT METHOD'),

        SizedBox(height: m.gapSm),

        _MethodTile(
          metrics: m,
          icon: Icons.account_balance_wallet_outlined,
          title: 'BIGOD Wallet',
          subtitle: 'Pay using your BIGOD balance',
          isSelected: selected == ScanPayMethod.bigod,
          onTap: () => onSelect(ScanPayMethod.bigod),
        ),

        SizedBox(height: m.gapSm),

        _MethodTile(
          metrics: m,
          icon: Icons.payments_outlined,
          title: 'Cash on Delivery',
          subtitle: 'Pay with cash at the counter',
          isSelected: selected == ScanPayMethod.cod,
          onTap: () => onSelect(ScanPayMethod.cod),
        ),
      ],
    );
  }
}

class _MethodTile extends StatelessWidget {
  final ReviewPaymentMetrics metrics;
  final IconData icon;
  final String title;
  final String subtitle;
  final bool isSelected;
  final VoidCallback onTap;

  const _MethodTile({
    required this.metrics,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.c;
    final m = metrics;

    return Material(
      color: isSelected ? colors.brandSoft : colors.surface,
      borderRadius: BorderRadius.circular(m.cardRadius * 0.8),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Container(
          height: m.methodTileHeight,
          padding: EdgeInsets.symmetric(horizontal: m.cardPad * 0.8),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(m.cardRadius * 0.8),
            border: Border.all(
              color: isSelected ? colors.brand : colors.border,
              width: isSelected ? 1.5 : 1,
            ),
          ),
          child: Row(
            children: [
              Container(
                width: m.methodIconBox,
                height: m.methodIconBox,
                decoration: BoxDecoration(
                  color: isSelected
                      ? colors.brand
                      : colors.brandSoft,
                  shape: BoxShape.circle,
                ),
                alignment: Alignment.center,
                child: Icon(
                  icon,
                  size: m.methodIconSize,
                  color: isSelected ? colors.surface : colors.brand,
                ),
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
                        color: colors.textPrimary,
                        fontFamily: 'Inter',
                        fontWeight: FontWeight.w700,
                        fontSize: m.methodTitleSize,
                        height: 1.3,
                      ),
                    ),
                    SizedBox(height: m.gapXs * 0.6),
                    Text(
                      subtitle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.bodySmall.copyWith(
                        color: colors.textSecondary,
                        fontFamily: 'Inter',
                        fontSize: m.methodSubSize,
                        height: 1.3,
                      ),
                    ),
                  ],
                ),
              ),

              Icon(
                isSelected
                    ? Icons.radio_button_checked_rounded
                    : Icons.radio_button_unchecked_rounded,
                size: m.radioSize,
                color: isSelected ? colors.brand : colors.textMuted,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
