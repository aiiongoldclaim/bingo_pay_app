import 'package:flutter/material.dart';

import '../../../../core/constants/app_strings.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/theme/app_theme_colors.dart';
import 'cart_metrics.dart';

class CartCouponCard extends StatelessWidget {
  const CartCouponCard({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = context.c;
    final m = CartMetrics.of(context);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => showCouponSheet(context),
        borderRadius: BorderRadius.circular(m.cardRadius),
        child: Container(
          padding: EdgeInsets.all(m.cardPad),
          decoration: BoxDecoration(
            color: colors.surface,
            borderRadius: BorderRadius.circular(m.cardRadius),
            border: Border.all(color: colors.border, width: 1),
          ),
          child: Row(
            children: [
              Container(
                width: m.bannerIconBox * 0.85,
                height: m.bannerIconBox * 0.85,
                decoration: BoxDecoration(
                  color: colors.brandSoft,
                  shape: BoxShape.circle,
                ),
                alignment: Alignment.center,
                child: Icon(
                  Icons.local_offer_outlined,
                  size: m.bannerIconSize * 0.85,
                  color: colors.brand,
                ),
              ),

              SizedBox(width: m.cardPad * 0.8),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      AppStrings.couponsOffers,
                      style: AppTextStyles.titleMedium.copyWith(
                        color: colors.textPrimary,
                        fontFamily: 'Inter',
                        fontWeight: FontWeight.w700,
                        fontSize: m.summaryTitleSize,
                        height: 1.2,
                      ),
                    ),
                    SizedBox(height: m.gapXs * 0.6),
                    Text(
                      AppStrings.viewAllOffers,
                      style: AppTextStyles.bodySmall.copyWith(
                        color: colors.textSecondary,
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
                color: colors.textMuted,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

Future<void> showCouponSheet(BuildContext context) {
  final colors = context.c;
  final m = CartMetrics.of(context);

  return showDialog(
    context: context,
    builder: (_) => Dialog(
      backgroundColor: colors.surface,
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
                    color: colors.brand,
                  ),
                  SizedBox(width: m.gapSm),
                  Expanded(
                    child: Text(
                      AppStrings.couponsOffers,
                      style: AppTextStyles.titleMedium.copyWith(
                        color: colors.textPrimary,
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
                        color: colors.textSecondary,
                      ),
                    ),
                  ),
                ],
              ),

              SizedBox(height: m.gapMd),
              Divider(height: 1, thickness: 1, color: colors.border),
              SizedBox(height: m.gapLg),

              // Empty state
              Icon(
                Icons.confirmation_number_outlined,
                size: m.emptyIllustration * 0.32,
                color: colors.textMuted,
              ),

              SizedBox(height: m.gapMd),

              Text(
                AppStrings.noCouponsAvailable,
                textAlign: TextAlign.center,
                style: AppTextStyles.titleMedium.copyWith(
                  color: colors.textPrimary,
                  fontFamily: 'Inter',
                  fontWeight: FontWeight.w600,
                  fontSize: m.summaryTitleSize,
                ),
              ),

              SizedBox(height: m.gapSm),

              Text(
                AppStrings.checkBackLaterOffers,
                textAlign: TextAlign.center,
                style: AppTextStyles.bodyMedium.copyWith(
                  color: colors.textSecondary,
                  fontFamily: 'Inter',
                  fontSize: m.summaryLabelSize,
                  height: 1.4,
                ),
              ),

              SizedBox(height: m.gapLg),

              SizedBox(
                height: m.payHeight * 0.8,
                child: Material(
                  color: colors.brand,
                  borderRadius: BorderRadius.circular(12),
                  clipBehavior: Clip.antiAlias,
                  child: InkWell(
                    onTap: () => Navigator.pop(context),
                    child: Center(
                      child: Text(
                        AppStrings.close,
                        style: AppTextStyles.buttonText.copyWith(
                          color: colors.surface,
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
