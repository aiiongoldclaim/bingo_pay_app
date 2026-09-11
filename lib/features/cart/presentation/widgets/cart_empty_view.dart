import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_strings.dart';
import '../../../../core/router/app_routes.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/theme/app_theme_colors.dart';
import 'cart_metrics.dart';

// ── Empty state ───────────────────────────────────────────────────────────
class CartEmptyView extends StatelessWidget {
  final CartMetrics metrics;

  const CartEmptyView({super.key, required this.metrics});

  @override
  Widget build(BuildContext context) {
    final colors = context.c;
    final m = metrics;

    final illustrationSize = m.emptyIllustration * 1.15;

    return Center(
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: EdgeInsets.symmetric(
          horizontal: m.pageHPad,
          vertical: m.gapLg,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: illustrationSize,
              height: illustrationSize,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Container(
                    width: illustrationSize,
                    height: illustrationSize,
                    decoration: BoxDecoration(
                      color: colors.brandSoft,
                      shape: BoxShape.circle,
                    ),
                  ),
                  Container(
                    width: illustrationSize * 0.78,
                    height: illustrationSize * 0.78,
                    decoration: BoxDecoration(
                      color: colors.surface,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: colors.textPrimary.withValues(alpha: 0.06),
                          blurRadius: 18,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    alignment: Alignment.center,
                    child: Icon(
                      Icons.shopping_bag_outlined,
                      size: illustrationSize * 0.38,
                      color: colors.brand,
                    ),
                  ),
                  Positioned(
                    top: illustrationSize * 0.06,
                    right: illustrationSize * 0.08,
                    child: Container(
                      width: illustrationSize * 0.16,
                      height: illustrationSize * 0.16,
                      decoration: BoxDecoration(
                        color: colors.brand,
                        shape: BoxShape.circle,
                        border: Border.all(color: colors.background, width: 3),
                      ),
                      alignment: Alignment.center,
                      child: Icon(
                        Icons.auto_awesome_rounded,
                        size: illustrationSize * 0.08,
                        color: colors.surface,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            SizedBox(height: m.gapLg),

            Text(
              AppStrings.cartEmptyTitle,
              textAlign: TextAlign.center,
              style: AppTextStyles.titleLarge.copyWith(
                color: colors.textPrimary,
                fontFamily: 'Inter',
                fontWeight: FontWeight.w800,
                fontSize: m.emptyTitleSize * 1.1,
              ),
            ),

            SizedBox(height: m.gapSm * 0.7),

            Text(
              AppStrings.cartEmptySubtitle,
              textAlign: TextAlign.center,
              style: AppTextStyles.bodyMedium.copyWith(
                color: colors.textSecondary,
                fontFamily: 'Inter',
                fontSize: m.emptySubSize,
                height: 1.5,
              ),
            ),

            SizedBox(height: m.gapLg * 1.2),

            SizedBox(
              width: m.isTablet ? 300 : double.infinity,
              height: m.payHeight,
              child: Material(
                color: colors.brand,
                borderRadius: BorderRadius.circular(m.payHeight / 2),
                clipBehavior: Clip.antiAlias,
                elevation: 0,
                child: InkWell(
                  onTap: () => context.go(AppRoutes.home),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.storefront_rounded,
                        size: m.payFontSize + 4,
                        color: colors.surface,
                      ),
                      SizedBox(width: m.gapSm * 0.6),
                      Text(
                        AppStrings.startShopping,
                        style: AppTextStyles.buttonText.copyWith(
                          color: colors.surface,
                          fontFamily: 'Inter',
                          fontWeight: FontWeight.w700,
                          fontSize: m.payFontSize,
                          letterSpacing: 0.6,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
