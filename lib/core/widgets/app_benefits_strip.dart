import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../theme/app_text_styles.dart';
import '../theme/app_theme_colors.dart';

class BenefitItem {
  final IconData icon;
  final String title;
  final String subtitle;

  const BenefitItem({
    required this.icon,
    required this.title,
    required this.subtitle,
  });
}

/// Free Delivery / Easy Return / Warranty jaisa strip.
/// Kisi bhi screen pe drop kar sakti ho — sizing khud handle karta hai.
class AppBenefitsStrip extends StatelessWidget {
  final List<BenefitItem> items;
  final bool showCard;
  final EdgeInsets? margin;

  const AppBenefitsStrip({
    super.key,
    this.items = defaultItems,
    this.showCard = true,
    this.margin,
  });

  static const List<BenefitItem> defaultItems = [
    BenefitItem(
      icon: Icons.local_shipping_outlined,
      title: 'Free Delivery',
      subtitle: 'On orders above \$49',
    ),
    BenefitItem(
      icon: Icons.autorenew_rounded,
      title: 'Easy Return',
      subtitle: '15 days return policy',
    ),
    BenefitItem(
      icon: Icons.verified_user_outlined,
      title: 'Warranty',
      subtitle: '6 months warranty',
    ),
  ];

  /// Delivery info se banane ke liye convenience factory
  static List<BenefitItem> fromLabels({
    required String deliveryLabel,
    required String deliverySubtitle,
    required String returnLabel,
    required String returnSubtitle,
    required String warrantyLabel,
    required String warrantySubtitle,
  }) => [
    BenefitItem(
      icon: Icons.local_shipping_outlined,
      title: deliveryLabel,
      subtitle: deliverySubtitle,
    ),
    BenefitItem(
      icon: Icons.autorenew_rounded,
      title: returnLabel,
      subtitle: returnSubtitle,
    ),
    BenefitItem(
      icon: Icons.verified_user_outlined,
      title: warrantyLabel,
      subtitle: warrantySubtitle,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    final size = MediaQuery.sizeOf(context);
    final isTablet = size.shortestSide >= 540;
    final isLandscape = size.width > size.height;

    final iconBox = isTablet ? (isLandscape ? 44.0 : 48.0) : 10.w;
    final iconSize = isTablet ? (isLandscape ? 22.0 : 24.0) : 18.sp;
    final titleSize = isTablet ? (isLandscape ? 14.0 : 15.0) : 12.sp;
    final subSize = isTablet ? (isLandscape ? 12.0 : 13.0) : 10.sp;
    final pad = isTablet ? (isLandscape ? 14.0 : 16.0) : 3.w;
    final gap = isTablet ? 8.0 : 1.8.w;
    final radius = isTablet ? 16.0 : 14.0;

    Widget item(BenefitItem b) => Expanded(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: iconBox,
            height: iconBox,
            decoration: BoxDecoration(
              color: c.brandSoft,
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: Icon(b.icon, size: iconSize, color: c.brand),
          ),
          SizedBox(width: gap),
          Flexible(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  b.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.labelMedium.copyWith(
                    color: c.textPrimary,
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.w700,
                    fontSize: titleSize,
                    height: 1.25,
                  ),
                ),
                Text(
                  b.subtitle,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.bodySmall.copyWith(
                    color: c.textSecondary,
                    fontFamily: 'Inter',
                    fontSize: subSize,
                    height: 1.25,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );

    Widget divider() => Container(
      width: 1,
      height: iconBox * 0.9,
      color: c.border,
    );

    final row = Row(
      children: [
        for (var i = 0; i < items.length; i++) ...[
          item(items[i]),
          if (i != items.length - 1) divider(),
        ],
      ],
    );

    if (!showCard) {
      return Padding(
        padding: margin ?? EdgeInsets.zero,
        child: row,
      );
    }

    return Container(
      margin: margin,
      padding: EdgeInsets.symmetric(
        horizontal: pad * 0.6,
        vertical: pad * 0.9,
      ),
      decoration: BoxDecoration(
        color: c.surface,
        borderRadius: BorderRadius.circular(radius),
        border: Border.all(color: c.border, width: 1),
      ),
      child: row,
    );
  }
}