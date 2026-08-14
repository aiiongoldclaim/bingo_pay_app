import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

import '../../../../core/constants/svg_image.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/theme/app_theme_colors.dart';

import 'account_metrics.dart';

class AccountBenefitsStrip extends StatelessWidget {
  const AccountBenefitsStrip({super.key});

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    final m = AccountMetrics.of(context);

    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: m.pageHPad,
        vertical: m.benefitVPad,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: _Benefit(
              icon: AppSvgImages.original100,
              title: '100% Original',
              subtitle: 'Genuine Products',
              metrics: m,
            ),
          ),
          _VDivider(color: c.border, height: m.benefitIconSize * 2),
          Expanded(
            child: _Benefit(
              icon: AppSvgImages.easyReturns,
              title: 'Easy Returns',
              subtitle: 'Hassle Free Returns',
              metrics: m,
            ),
          ),
          _VDivider(color: c.border, height: m.benefitIconSize * 2),
          Expanded(
            child: _Benefit(
              icon: AppSvgImages.securePayments,
              title: 'Secure Payments',
              subtitle: '100% Protected',
              metrics: m,
            ),
          ),
        ],
      ),
    );
  }
}

class _VDivider extends StatelessWidget {
  final Color color;
  final double height;

  const _VDivider({required this.color, required this.height});

  @override
  Widget build(BuildContext context) =>
      Container(width: 1, height: height, color: color);
}

class _Benefit extends StatelessWidget {
  final String icon;
  final String title;
  final String subtitle;
  final AccountMetrics metrics;

  const _Benefit({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.metrics,
  });

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    final m = metrics;

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        SvgPicture.asset(
          icon,
          width: m.benefitIconSize,
          height: m.benefitIconSize,
          colorFilter: ColorFilter.mode(c.brand, BlendMode.srcIn),
        ),
        SizedBox(width: m.gapSm * 0.6),
        Flexible(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppTextStyles.labelMedium.copyWith(
                  color: c.brand,
                  fontFamily: 'Inter',
                  fontWeight: FontWeight.w600,
                  fontSize: m.benefitTitleSize * 1,
                ),
              ),
              Text(
                subtitle,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppTextStyles.bodySmall.copyWith(
                  color: c.textSecondary,
                  fontFamily: 'Inter',
                  fontSize: m.benefitSubtitleSize * 1,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
