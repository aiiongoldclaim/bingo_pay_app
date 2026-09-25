import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../theme/app_text_styles.dart';
import '../theme/app_theme_colors.dart';

class BenefitItem {
  final IconData icon;
  final String title;

  const BenefitItem({required this.icon, required this.title});
}


class AppBenefitsStrip extends StatelessWidget {
  final List<BenefitItem> items;
  final EdgeInsets? margin;

  const AppBenefitsStrip({super.key, required this.items, this.margin});

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) return const SizedBox.shrink();

    final colors = context.c;
    final size = MediaQuery.sizeOf(context);
    final isTablet = size.shortestSide >= 540;
    final isLandscape = size.width > size.height;

    final iconSize = (isTablet ? (isLandscape ? 26.0 : 28.0) : 21.sp).clamp(
      20.0,
      32.0,
    );
    final titleSize = (isTablet ? (isLandscape ? 16.0 : 17.0) : 13.5.sp)
        .clamp(14.0, 20.0);
    final iconGap = isTablet ? 8.0 : 1.8.w;
    final itemGap = isTablet ? 22.0 : 5.5.w;

    Widget item(BenefitItem b) => Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(b.icon, size: iconSize, color: colors.brand),
        SizedBox(width: iconGap),
        Text(
          b.title,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: AppTextStyles.labelMedium.copyWith(
            color: colors.textPrimary,
            fontFamily: 'Inter',
            fontWeight: FontWeight.w700,
            fontSize: titleSize,
          ),
        ),
      ],
    );

    return Padding(
      padding: margin ?? EdgeInsets.zero,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        physics: const ClampingScrollPhysics(),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            for (var i = 0; i < items.length; i++) ...[
              item(items[i]),
              if (i != items.length - 1) SizedBox(width: itemGap),
            ],
          ],
        ),
      ),
    );
  }
}
