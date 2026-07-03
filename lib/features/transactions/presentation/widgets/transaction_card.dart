import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import 'package:bingo_pay/core/theme/theme_colors.dart';
import 'package:bingo_pay/core/theme/app_text_styles.dart';

import '../../data/models/transaction_model.dart';

class TransactionCard extends StatelessWidget {
  final TransactionModel transaction;
  final VoidCallback? onTap;

  const TransactionCard({super.key, required this.transaction, this.onTap});

  IconData get _gatewayIcon {
    switch (transaction.gateway.toUpperCase()) {
      case 'WALLET':
        return Icons.account_balance_wallet_rounded;
      case 'RAZORPAY':
      case 'PAYTM':
        return Icons.credit_card_rounded;
      default:
        return Icons.payment_rounded;
    }
  }

  _StatusColorConfig get _statusConfig {
    if (transaction.isSuccess) {
      return const _StatusColorConfig(
        bg: ThemeColors.greenSoft,
        text: ThemeColors.green,
      );
    }
    if (transaction.isFailed) {
      return const _StatusColorConfig(
        bg: Color(0xFFFBE7E3),
        text: ThemeColors.red,
      );
    }
    return const _StatusColorConfig(
      bg: Color(0xFFFFF0E0),
      text: ThemeColors.amber,
    );
  }

  @override
  Widget build(BuildContext context) {
    final config = _statusConfig;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: Container(
        padding: EdgeInsets.all(4.w),
        decoration: BoxDecoration(
          color: ThemeColors.surface,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: ThemeColors.line),
          boxShadow: [
            BoxShadow(
              color: ThemeColors.ink.withValues(alpha: 0.05),
              blurRadius: 14,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 11.w,
              height: 11.w,
              decoration: BoxDecoration(
                color: ThemeColors.blueSoft,
                borderRadius: BorderRadius.circular(13),
              ),
              alignment: Alignment.center,
              child: Icon(_gatewayIcon, color: ThemeColors.blue, size: 18.sp),
            ),

            SizedBox(width: 3.w),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          transaction.displayGateway,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppTextStyles.titleMedium.copyWith(
                            fontSize: 15.sp,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 2.5.w,
                          vertical: 0.4.h,
                        ),
                        decoration: BoxDecoration(
                          color: config.bg,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          transaction.displayStatus,
                          style: AppTextStyles.labelSmall.copyWith(
                            fontSize: 11.sp,
                            fontWeight: FontWeight.w700,
                            color: config.text,
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 0.5.h),
                  Text(
                    transaction.order != null
                        ? '${transaction.order!.orderNumber} · ${transaction.shortDate}'
                        : transaction.shortDate,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.bodySmall.copyWith(
                      fontSize: 13.sp,
                      color: ThemeColors.inkDim,
                    ),
                  ),
                ],
              ),
            ),

            SizedBox(width: 2.w),

            Text(
              transaction.formattedAmount,
              style: AppTextStyles.titleMedium.copyWith(
                fontSize: 15.sp,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatusColorConfig {
  final Color bg;
  final Color text;
  const _StatusColorConfig({required this.bg, required this.text});
}
