import 'package:bingo_pay/core/router/app_router.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/router/app_routes.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/theme/app_theme_colors.dart';
import 'order_details_metrics.dart';

/// Back + brand logo + Help
class OdHeader extends StatelessWidget {
  const OdHeader({
    super.key,
    required this.metrics,
    required this.brandName,
    this.onBack,
    this.onHelp,
  });

  final OrderDetailMetrics metrics;
  final String brandName;
  final VoidCallback? onBack;
  final VoidCallback? onHelp;

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    final m = metrics;

    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: m.pagePadding * 0.4,
        vertical: m.pagePadding * 0.3,
      ),
      child: Row(
        children: [
          InkResponse(
            onTap: onBack,
            radius: m.headerIconSize,
            child: Padding(
              padding: EdgeInsets.all(m.pagePadding * 0.5),
              child: Icon(
                Icons.arrow_back_ios_rounded,
                size: m.headerIconSize,
                color: c.textPrimary,
              ),
            ),
          ),
          Expanded(
            child: Center(
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  brandName,
                  style: AppTextStyles.brandLogo.copyWith(
                    fontSize: m.logoSize,
                    color: c.brand,
                  ),
                ),
              ),
            ),
          ),
          InkWell(
            onTap: ()=> context.push(AppRoutes.help),
            child: Padding(
              padding: EdgeInsets.all(m.pagePadding * 0.4),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.headset_mic_outlined,
                    size: m.headerIconSize * 0.82,
                    color: c.brand,
                  ),
                  SizedBox(width: m.pagePadding * 0.3),
                  Text(
                    'Help',
                    style: TextStyle(
                      fontSize: m.helpFontSize,
                      fontWeight: FontWeight.w600,
                      color: c.brand,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// "Order Details" + order id (+ copy) + placed-at
class OdTitleBlock extends StatelessWidget {
  const OdTitleBlock({
    super.key,
    required this.metrics,
    required this.title,
    required this.orderId,
    required this.placedAt,
    this.onCopy,
  });

  final OrderDetailMetrics metrics;
  final String title;
  final String orderId;
  final String placedAt;
  final VoidCallback? onCopy;

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    final m = metrics;

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: m.pagePadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: m.screenTitleSize,
              fontWeight: FontWeight.w700,
              height: 1.2,
              color: c.textPrimary,
            ),
          ),
          SizedBox(height: m.pagePadding * 0.4),
          Row(
            children: [
              Flexible(
                child: Text(
                  'Order ID: $orderId',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: m.orderIdSize,
                    fontWeight: FontWeight.w600,
                    color: c.textPrimary,
                  ),
                ),
              ),
              if (onCopy != null) ...[
                SizedBox(width: m.pagePadding * 0.35),
                InkResponse(
                  onTap: onCopy,
                  radius: m.orderIdSize * 1.5,
                  child: Icon(
                    Icons.copy_rounded,
                    size: m.orderIdSize * 1.15,
                    color: c.brand,
                  ),
                ),
              ],
            ],
          ),
          SizedBox(height: m.pagePadding * 0.25),
          Text(
            'Placed on $placedAt',
            style: TextStyle(
              fontSize: m.placedAtSize,
              height: 1.3,
              color: c.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

class OdSectionLabel extends StatelessWidget {
  const OdSectionLabel({super.key, required this.metrics, required this.label});

  final OrderDetailMetrics metrics;
  final String label;

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: metrics.pagePadding),
      child: Text(
        label,
        style: TextStyle(
          fontSize: metrics.sectionLabelSize,
          fontWeight: FontWeight.w700,
          height: 1.2,
          color: c.textPrimary,
        ),
      ),
    );
  }
}

/// Bordered surface card — saare sections isi me wrap hote hain
class OdCard extends StatelessWidget {
  const OdCard({
    super.key,
    required this.metrics,
    required this.child,
    this.padded = true,
    this.background,
    this.borderColor,
  });

  final OrderDetailMetrics metrics;
  final Widget child;
  final bool padded;
  final Color? background;
  final Color? borderColor;

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    final m = metrics;

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: m.pagePadding),
      child: Container(
        width: double.infinity,
        padding: padded ? EdgeInsets.all(m.cardPadding) : EdgeInsets.zero,
        decoration: BoxDecoration(
          color: background ?? c.surface,
          borderRadius: BorderRadius.circular(m.cardRadius),
          border: Border.all(color: borderColor ?? c.border),
        ),
        clipBehavior: Clip.antiAlias,
        child: child,
      ),
    );
  }
}
