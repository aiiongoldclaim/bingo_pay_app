// import 'package:flutter/material.dart';
//
// import '../../../../core/theme/app_text_styles.dart';
// import '../../../../core/theme/theme_colors.dart';
//
// class CouponCard extends StatelessWidget {
//   const CouponCard({super.key});
//
//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       padding: const EdgeInsets.all(18),
//       decoration: BoxDecoration(
//         borderRadius: BorderRadius.circular(16),
//         border: Border.all(color: ThemeColors.blue, style: BorderStyle.solid),
//         color: ThemeColors.surface,
//       ),
//       child: Row(
//         children: [
//           Icon(Icons.local_offer_outlined, color: ThemeColors.blue),
//
//           SizedBox(width: 12),
//
//           Expanded(
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text(
//                   'FESTIVE10 applied',
//                   style: AppTextStyles.titleMedium.copyWith(
//                     color: ThemeColors.blue,
//                   ),
//                 ),
//                 Text('You saved \$2,848', style: AppTextStyles.bodyMedium),
//               ],
//             ),
//           ),
//
//           Icon(Icons.check, color: ThemeColors.green),
//         ],
//       ),
//     );
//   }
// }
import 'package:flutter/material.dart';

import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/theme/app_theme_colors.dart';
import 'cart_metrics.dart';

class CartCouponCard extends StatelessWidget {
  const CartCouponCard({super.key});

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    final m = CartMetrics.of(context);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => showCouponSheet(context),
        borderRadius: BorderRadius.circular(m.cardRadius),
        child: Container(
          padding: EdgeInsets.all(m.cardPad),
          decoration: BoxDecoration(
            color: c.surface,
            borderRadius: BorderRadius.circular(m.cardRadius),
            border: Border.all(color: c.border, width: 1),
          ),
          child: Row(
            children: [
              Container(
                width: m.bannerIconBox * 0.85,
                height: m.bannerIconBox * 0.85,
                decoration: BoxDecoration(
                  color: c.brandSoft,
                  shape: BoxShape.circle,
                ),
                alignment: Alignment.center,
                child: Icon(
                  Icons.local_offer_outlined,
                  size: m.bannerIconSize * 0.85,
                  color: c.brand,
                ),
              ),

              SizedBox(width: m.cardPad * 0.8),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Coupons & Offers',
                      style: AppTextStyles.titleMedium.copyWith(
                        color: c.textPrimary,
                        fontFamily: 'Inter',
                        fontWeight: FontWeight.w700,
                        fontSize: m.summaryTitleSize,
                        height: 1.2,
                      ),
                    ),
                    SizedBox(height: m.gapXs * 0.6),
                    Text(
                      'View all available offers',
                      style: AppTextStyles.bodySmall.copyWith(
                        color: c.textSecondary,
                        fontFamily: 'Inter',
                        fontSize: m.summaryLabelSize,
                        height: 1.2,
                      ),
                    ),
                  ],
                ),
              ),

              Icon(
                Icons.chevron_right_rounded,
                size: m.summaryTitleSize + 8,
                color: c.textMuted,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Coupon dialog — abhi koi coupon API nahi hai, isliye empty state dikhata hai.
Future<void> showCouponSheet(BuildContext context) {
  final c = context.c;
  final m = CartMetrics.of(context);

  return showDialog(
    context: context,
    builder: (_) => Dialog(
      backgroundColor: c.surface,
      insetPadding: EdgeInsets.symmetric(
        horizontal: m.isTablet ? 80 : 6.0,
        vertical: 24,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(m.cardRadius),
      ),
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: m.isTablet ? 520 : 480),
        child: Padding(
          padding: EdgeInsets.all(m.cardPad * 1.2),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header
              Row(
                children: [
                  Icon(
                    Icons.local_offer_outlined,
                    size: m.summaryTitleSize + 4,
                    color: c.brand,
                  ),
                  SizedBox(width: m.gapSm),
                  Expanded(
                    child: Text(
                      'Coupons & Offers',
                      style: AppTextStyles.titleMedium.copyWith(
                        color: c.textPrimary,
                        fontFamily: 'Inter',
                        fontWeight: FontWeight.w700,
                        fontSize: m.summaryTitleSize,
                      ),
                    ),
                  ),
                  InkWell(
                    onTap: () => Navigator.pop(context),
                    borderRadius: BorderRadius.circular(20),
                    child: Padding(
                      padding: EdgeInsets.all(m.gapXs),
                      child: Icon(
                        Icons.close_rounded,
                        size: m.summaryTitleSize + 2,
                        color: c.textSecondary,
                      ),
                    ),
                  ),
                ],
              ),

              SizedBox(height: m.gapMd),
              Divider(height: 1, thickness: 1, color: c.border),
              SizedBox(height: m.gapLg),

              // Empty state
              Icon(
                Icons.confirmation_number_outlined,
                size: m.emptyIllustration * 0.32,
                color: c.textMuted,
              ),

              SizedBox(height: m.gapMd),

              Text(
                'No coupons available',
                textAlign: TextAlign.center,
                style: AppTextStyles.titleMedium.copyWith(
                  color: c.textPrimary,
                  fontFamily: 'Inter',
                  fontWeight: FontWeight.w600,
                  fontSize: m.summaryTitleSize,
                ),
              ),

              SizedBox(height: m.gapSm),

              Text(
                'Offers ke liye baad me check karein.',
                textAlign: TextAlign.center,
                style: AppTextStyles.bodyMedium.copyWith(
                  color: c.textSecondary,
                  fontFamily: 'Inter',
                  fontSize: m.summaryLabelSize,
                  height: 1.4,
                ),
              ),

              SizedBox(height: m.gapLg),

              SizedBox(
                height: m.payHeight * 0.8,
                child: Material(
                  color: c.brand,
                  borderRadius: BorderRadius.circular(12),
                  clipBehavior: Clip.antiAlias,
                  child: InkWell(
                    onTap: () => Navigator.pop(context),
                    child: Center(
                      child: Text(
                        'CLOSE',
                        style: AppTextStyles.buttonText.copyWith(
                          color: c.surface,
                          fontFamily: 'Inter',
                          fontWeight: FontWeight.w700,
                          fontSize: m.payFontSize * 0.9,
                          letterSpacing: 0.4,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}
