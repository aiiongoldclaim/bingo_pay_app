// import 'package:flutter/material.dart';
// import 'package:sizer/sizer.dart';
// import 'package:bingo_pay/core/theme/theme_colors.dart';
// import 'package:bingo_pay/core/theme/app_text_styles.dart';
//
// import '../../data/models/transaction_model.dart';
//
// class TransactionCard extends StatelessWidget {
//   final TransactionModel transaction;
//   final VoidCallback? onTap;
//
//   const TransactionCard({super.key, required this.transaction, this.onTap});
//
//   IconData get _gatewayIcon {
//     switch (transaction.gateway.toUpperCase()) {
//       case 'WALLET':
//         return Icons.account_balance_wallet_rounded;
//       case 'RAZORPAY':
//       case 'PAYTM':
//         return Icons.credit_card_rounded;
//       default:
//         return Icons.payment_rounded;
//     }
//   }
//
//   _StatusColorConfig get _statusConfig {
//     if (transaction.isSuccess) {
//       return const _StatusColorConfig(
//         bg: ThemeColors.greenSoft,
//         text: ThemeColors.green,
//       );
//     }
//     if (transaction.isFailed) {
//       return const _StatusColorConfig(
//         bg: Color(0xFFFBE7E3),
//         text: ThemeColors.red,
//       );
//     }
//     return const _StatusColorConfig(
//       bg: Color(0xFFFFF0E0),
//       text: ThemeColors.amber,
//     );
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     final config = _statusConfig;
//
//     return InkWell(
//       onTap: onTap,
//       borderRadius: BorderRadius.circular(18),
//       child: Container(
//         padding: EdgeInsets.all(4.w),
//         decoration: BoxDecoration(
//           color: ThemeColors.surface,
//           borderRadius: BorderRadius.circular(18),
//           border: Border.all(color: ThemeColors.line),
//           boxShadow: [
//             BoxShadow(
//               color: ThemeColors.ink.withValues(alpha: 0.05),
//               blurRadius: 14,
//               offset: const Offset(0, 4),
//             ),
//           ],
//         ),
//         child: Row(
//           crossAxisAlignment: CrossAxisAlignment.center,
//           children: [
//             Container(
//               width: 11.w,
//               height: 11.w,
//               decoration: BoxDecoration(
//                 color: ThemeColors.blueSoft,
//                 borderRadius: BorderRadius.circular(13),
//               ),
//               alignment: Alignment.center,
//               child: Icon(_gatewayIcon, color: ThemeColors.blue, size: 18.sp),
//             ),
//
//             SizedBox(width: 3.w),
//
//             Expanded(
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Text(
//                     transaction.displayGateway,
//                     maxLines: 1,
//                     overflow: TextOverflow.ellipsis,
//                     style: AppTextStyles.titleMedium.copyWith(
//                       fontSize: 15.sp,
//                       fontWeight: FontWeight.bold,
//                     ),
//                   ),
//                   SizedBox(height: 0.5.h),
//                   Text(
//                     transaction.order != null
//                         ? '${transaction.order!.orderNumber} · ${transaction.shortDate}'
//                         : transaction.shortDate,
//                     maxLines: 1,
//                     overflow: TextOverflow.ellipsis,
//                     style: AppTextStyles.bodySmall.copyWith(
//                       fontSize: 14.sp,
//                       color: ThemeColors.inkMid,
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//
//             SizedBox(width: 3.w),
//
//             /// Amount stacked above the status pill, both right-aligned —
//             /// keeps the badge from colliding with the amount and gives the
//             /// row a clean, balanced trailing edge.
//             Column(
//               mainAxisSize: MainAxisSize.min,
//               crossAxisAlignment: CrossAxisAlignment.end,
//               children: [
//                 Text(
//                   transaction.formattedAmount,
//                   style: AppTextStyles.titleMedium.copyWith(
//                     fontSize: 15.sp,
//                     fontWeight: FontWeight.bold,
//                   ),
//                 ),
//                 SizedBox(height: 0.8.h),
//                 Container(
//                   padding: EdgeInsets.symmetric(
//                     horizontal: 2.5.w,
//                     vertical: 0.4.h,
//                   ),
//                   decoration: BoxDecoration(
//                     color: config.bg,
//                     borderRadius: BorderRadius.circular(20),
//                   ),
//                   child: Text(
//                     transaction.displayStatus,
//                     style: AppTextStyles.labelSmall.copyWith(
//                       fontSize: 14.sp,
//                       fontWeight: FontWeight.w700,
//                       color: config.text,
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
//
// class _StatusColorConfig {
//   final Color bg;
//   final Color text;
//   const _StatusColorConfig({required this.bg, required this.text});
// }
import 'package:bingo_pay/features/transactions/presentation/widgets/transactions_metrics.dart';
import 'package:flutter/material.dart';

import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/theme/app_theme_colors.dart';
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

  ({Color bg, Color fg}) _statusColors(AppThemeColors c) {
    if (transaction.isSuccess) {
      return (bg: c.statusSuccessSoft, fg: c.statusSuccess);
    }
    if (transaction.isFailed) {
      return (bg: c.statusWarningSoft, fg: c.statusWarning);
    }
    return (bg: c.statusWarningSoft, fg: c.statusWarning);
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.c;
    final m = TransactionsMetrics.of(context);
    final status = _statusColors(colors);

    return Material(
      color: colors.surface,
      borderRadius: BorderRadius.circular(m.cardRadius),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Container(
          padding: EdgeInsets.all(m.cardPad),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(m.cardRadius),
            border: Border.all(color: colors.border, width: 1),
            boxShadow: colors.isDark
                ? null
                : [
              BoxShadow(
                color: colors.textPrimary.withValues(alpha: 0.03),
                blurRadius: 12,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: m.iconBox,
                height: m.iconBox,
                decoration: BoxDecoration(
                  color: colors.brandSoft,
                  shape: BoxShape.circle,
                ),
                alignment: Alignment.center,
                child: Icon(_gatewayIcon, size: m.iconSize, color: colors.brand),
              ),

              SizedBox(width: m.cardPad * 0.7),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      transaction.displayGateway,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.labelLarge.copyWith(
                        color: colors.textPrimary,
                        fontFamily: 'Inter',
                        fontWeight: FontWeight.w700,
                        fontSize: m.gatewaySize,
                        height: 1.3,
                      ),
                    ),
                    SizedBox(height: m.gapXs * 0.8),
                    Text(
                      transaction.order != null
                          ? '${transaction.order!.orderNumber} · ${transaction.shortDate}'
                          : transaction.shortDate,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.bodySmall.copyWith(
                        color: colors.textSecondary,
                        fontFamily: 'Inter',
                        fontSize: m.metaSize,
                        height: 1.3,
                      ),
                    ),
                  ],
                ),
              ),

              SizedBox(width: m.gapSm),

              Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    transaction.formattedAmount,
                    style: AppTextStyles.titleMedium.copyWith(
                      color: colors.textPrimary,
                      fontFamily: 'Inter',
                      fontWeight: FontWeight.w700,
                      fontSize: m.amountSize,
                      height: 1.2,
                    ),
                  ),
                  SizedBox(height: m.gapXs * 1.2),
                  Container(
                    height: m.badgeHeight,
                    padding: EdgeInsets.symmetric(horizontal: m.gapSm * 1.1),
                    decoration: BoxDecoration(
                      color: status.bg,
                      borderRadius: BorderRadius.circular(m.badgeHeight),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      transaction.displayStatus,
                      style: AppTextStyles.labelMedium.copyWith(
                        color: status.fg,
                        fontFamily: 'Inter',
                        fontWeight: FontWeight.w700,
                        fontSize: m.badgeFontSize,
                        letterSpacing: 0.3,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}