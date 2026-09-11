import 'package:flutter/material.dart';

import '../../../../../core/theme/app_text_styles.dart';
import '../../../../../core/theme/app_theme_colors.dart';
import '../../cubit/payment_state.dart';
import 'payment_metrics.dart';

// ── Wallet Info Card ───────────────────────────────────────────────────────
class PaymentWalletCard extends StatelessWidget {
  final PaymentMethodState state;
  final PaymentMetrics metrics;

  const PaymentWalletCard({super.key, required this.state, required this.metrics});

  @override
  Widget build(BuildContext context) {
    final colors = context.c;
    final m = metrics;

    return Container(
      padding: EdgeInsets.all(m.cardPad),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(m.cardRadius),
        border: Border.all(color: colors.border, width: 1),
        boxShadow: colors.isDark
            ? null
            : [
                BoxShadow(
                  color: colors.textPrimary.withValues(alpha: 0.04),
                  blurRadius: 14,
                  offset: const Offset(0, 3),
                ),
              ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Container(
                width: m.walletIconBox * 0.8,
                height: m.walletIconBox * 0.8,
                decoration: BoxDecoration(
                  color: colors.brandSoft,
                  shape: BoxShape.circle,
                ),
                alignment: Alignment.center,
                child: Icon(
                  Icons.account_balance_wallet_outlined,
                  size: m.walletIconSize * 0.8,
                  color: colors.brand,
                ),
              ),
              SizedBox(width: m.gapSm),
              Expanded(
                child: Text(
                  'Bingold Wallet',
                  style: AppTextStyles.titleMedium.copyWith(
                    color: colors.textPrimary,
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.w700,
                    fontSize: m.sectionTitleSize,
                  ),
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: m.gapSm,
                  vertical: m.gapXs * 0.8,
                ),
                decoration: BoxDecoration(
                  color: colors.statusSuccessSoft,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.lock_outline,
                      size: m.addrChipSize + 3,
                      color: colors.statusSuccess,
                    ),
                    SizedBox(width: m.gapXs * 0.8),
                    Text(
                      'Secured',
                      style: AppTextStyles.labelMedium.copyWith(
                        color: colors.statusSuccess,
                        fontFamily: 'Inter',
                        fontWeight: FontWeight.w600,
                        fontSize: m.addrChipSize,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          SizedBox(height: m.gapMd),
          Divider(height: 1, thickness: 1, color: colors.border),
          SizedBox(height: m.gapMd),

          _BalanceRow(
            icon: Icons.currency_bitcoin,
            label: 'Bigod Balance',
            value: state.formattedBigoldBalance,
            metrics: m,
          ),
        ],
      ),
    );
  }
}

class _BalanceRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final PaymentMetrics metrics;

  const _BalanceRow({
    required this.icon,
    required this.label,
    required this.value,
    required this.metrics,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.c;
    final m = metrics;

    return Row(
      children: [
        Container(
          padding: EdgeInsets.all(m.gapXs * 1.5),
          decoration: BoxDecoration(
            color: colors.brandSoft,
            borderRadius: BorderRadius.circular(9),
          ),
          child: Icon(icon, size: m.addrBodySize + 3, color: colors.brand),
        ),
        SizedBox(width: m.gapSm),
        Expanded(
          child: Text(
            label,
            style: AppTextStyles.bodyMedium.copyWith(
              color: colors.textSecondary,
              fontFamily: 'Inter',
              fontSize: m.summaryLabelSize,
            ),
          ),
        ),
        Text(
          value,
          style: AppTextStyles.titleMedium.copyWith(
            color: colors.textPrimary,
            fontFamily: 'Inter',
            fontWeight: FontWeight.w700,
            fontSize: m.summaryValueSize + 1,
          ),
        ),
      ],
    );
  }
}
