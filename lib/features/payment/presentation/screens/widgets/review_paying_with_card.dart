import 'package:flutter/material.dart';

import '../../../../../core/theme/app_text_styles.dart';
import '../../../../../core/theme/app_theme_colors.dart';
import '../../cubit/payment_state.dart';
import 'review_pay_metrics.dart';

// ── Paying with (wallet / COD) ─────────────────────────────────────────────
class ReviewPayingWithCard extends StatelessWidget {
  final ReviewPayMetrics metrics;
  final String methodName;
  final String bigoldBalance;
  final PaymentMethod selectedMethod;
  final VoidCallback onChangeTap;

  const ReviewPayingWithCard({
    super.key,
    required this.metrics,
    required this.methodName,
    required this.bigoldBalance,
    required this.selectedMethod,
    required this.onChangeTap,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.c;
    final m = metrics;
    final isWallet = selectedMethod == PaymentMethod.wallet;

    return Container(
      padding: EdgeInsets.all(m.cardPad),
      decoration: BoxDecoration(
        color: colors.brand,
        borderRadius: BorderRadius.circular(m.cardRadius),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Container(
                width: m.walletIconBox,
                height: m.walletIconBox,
                decoration: BoxDecoration(
                  color: colors.surface.withValues(alpha: 0.18),
                  shape: BoxShape.circle,
                ),
                alignment: Alignment.center,
                child: Icon(
                  isWallet
                      ? Icons.account_balance_wallet_outlined
                      : Icons.payments_outlined,
                  size: m.walletIconSize,
                  color: colors.surface,
                ),
              ),

              SizedBox(width: m.cardPad * 0.7),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      methodName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.titleMedium.copyWith(
                        color: colors.surface,
                        fontFamily: 'Inter',
                        fontWeight: FontWeight.w700,
                        fontSize: m.walletTitleSize,
                        height: 1.25,
                      ),
                    ),
                    SizedBox(height: m.gapXs * 0.8),
                    Row(
                      children: [
                        Icon(
                          Icons.lock_outline_rounded,
                          size: m.walletSubSize + 3,
                          color: colors.surface.withValues(alpha: 0.85),
                        ),
                        SizedBox(width: m.gapXs),
                        Text(
                          'Secured & Encrypted',
                          style: AppTextStyles.bodySmall.copyWith(
                            color: colors.surface.withValues(alpha: 0.85),
                            fontFamily: 'Inter',
                            fontSize: m.walletSubSize,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              Material(
                color: Colors.transparent,
                borderRadius: BorderRadius.circular(8),
                clipBehavior: Clip.antiAlias,
                child: InkWell(
                  onTap: onChangeTap,
                  child: Padding(
                    padding: EdgeInsets.all(m.gapXs * 1.4),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'Change',
                          style: AppTextStyles.labelMedium.copyWith(
                            color: colors.surface,
                            fontFamily: 'Inter',
                            fontWeight: FontWeight.w600,
                            fontSize: m.changeBtnFontSize,
                          ),
                        ),
                        Icon(
                          Icons.chevron_right_rounded,
                          size: m.changeBtnFontSize + 6,
                          color: colors.surface,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),

          SizedBox(height: m.gapMd),

          Container(
            padding: EdgeInsets.all(m.cardPad * 0.8),
            decoration: BoxDecoration(
              color: colors.surface.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(m.cardRadius * 0.75),
              border: Border.all(
                color: colors.surface.withValues(alpha: 0.18),
                width: 1,
              ),
            ),
            child: isWallet
                ? Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'YOUR BALANCE',
                        style: AppTextStyles.labelMedium.copyWith(
                          color: colors.surface.withValues(alpha: 0.75),
                          fontFamily: 'Inter',
                          fontWeight: FontWeight.w600,
                          fontSize: m.balanceLabelSize,
                          letterSpacing: 0.6,
                        ),
                      ),
                      SizedBox(height: m.gapSm),
                      Row(
                        children: [
                          Container(
                            width: m.coinBadgeSize,
                            height: m.coinBadgeSize,
                            decoration: const BoxDecoration(
                              color: Color(0xFFF7A928),
                              shape: BoxShape.circle,
                            ),
                            alignment: Alignment.center,
                            child: Text(
                              'B',
                              style: AppTextStyles.labelLarge.copyWith(
                                color: Colors.white,
                                fontFamily: 'Inter',
                                fontWeight: FontWeight.w800,
                                fontSize: m.balanceLabelSize + 2,
                              ),
                            ),
                          ),
                          SizedBox(width: m.gapSm),
                          Expanded(
                            child: Text(
                              'Bigod Balance',
                              style: AppTextStyles.bodyMedium.copyWith(
                                color: colors.surface,
                                fontFamily: 'Inter',
                                fontWeight: FontWeight.w600,
                                fontSize: m.rowLabelSize,
                              ),
                            ),
                          ),
                          Flexible(
                            child: Text(
                              bigoldBalance,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              textAlign: TextAlign.right,
                              style: AppTextStyles.titleMedium.copyWith(
                                color: const Color(0xFFF7A928),
                                fontFamily: 'Inter',
                                fontWeight: FontWeight.w700,
                                fontSize: m.balanceValueSize,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  )
                : Row(
                    children: [
                      Icon(
                        Icons.payments_outlined,
                        size: m.rowLabelSize + 4,
                        color: colors.surface.withValues(alpha: 0.85),
                      ),
                      SizedBox(width: m.gapSm),
                      Expanded(
                        child: Text(
                          'Pay with cash when your order arrives',
                          style: AppTextStyles.bodyMedium.copyWith(
                            color: colors.surface.withValues(alpha: 0.9),
                            fontFamily: 'Inter',
                            fontSize: m.rowLabelSize,
                          ),
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
