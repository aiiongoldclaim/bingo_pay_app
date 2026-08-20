import 'package:flutter/material.dart';

import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/theme/app_theme_colors.dart';
import 'order_details_metrics.dart';

class OrderDetailBottomBar extends StatelessWidget {
  final OrderDetailMetrics metrics;
  final bool canCancel;
  final bool showInvoice;
  final bool isCancelling;
  final VoidCallback onPrimary;
  final VoidCallback? onInvoice;

  const OrderDetailBottomBar({
    super.key,
    required this.metrics,
    required this.canCancel,
    this.showInvoice = true,
    this.isCancelling = false,
    required this.onPrimary,
    this.onInvoice,
  });

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    final m = metrics;

    final btnHeight = m.isTablet ? 54.0 : 52.0;
    final fontSize = m.isTablet ? 16.0 : 14.0;

    Widget primary() => SizedBox(
      height: btnHeight,
      child: Material(
        color: canCancel ? c.statusWarning : c.brand,
        borderRadius: BorderRadius.circular(12),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: isCancelling ? null : onPrimary,
          child: Center(
            child: isCancelling
                ? SizedBox(
              width: fontSize + 4,
              height: fontSize + 4,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation(c.surface),
              ),
            )
                : Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  canCancel
                      ? Icons.close_rounded
                      : Icons.headset_mic_outlined,
                  size: fontSize + 4,
                  color: c.surface,
                ),
                SizedBox(width: m.sectionGap * 0.4),
                Text(
                  canCancel ? 'Cancel Order' : 'Need Help',
                  style: AppTextStyles.buttonText.copyWith(
                    color: c.surface,
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.w700,
                    fontSize: fontSize,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );

    Widget invoice() => SizedBox(
      height: btnHeight,
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(12),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onInvoice,
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: c.brand.withValues(alpha: 0.5)),
            ),
            alignment: Alignment.center,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.receipt_long_outlined,
                  size: fontSize + 4,
                  color: c.brand,
                ),
                SizedBox(width: m.sectionGap * 0.4),
                Flexible(
                  child: Text(
                    'Invoice',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.buttonText.copyWith(
                      color: c.brand,
                      fontFamily: 'Inter',
                      fontWeight: FontWeight.w700,
                      fontSize: fontSize,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );

    return Container(
      padding: EdgeInsets.fromLTRB(
        m.pagePadding,
        m.sectionGap * 0.6,
        m.pagePadding,
        m.sectionGap * 0.3,
      ),
      decoration: BoxDecoration(
        color: c.background,
        border: Border(top: BorderSide(color: c.border, width: 1)),
      ),
      child: SafeArea(
        top: false,
        child: Center(
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: m.contentMaxWidth),
            child: showInvoice
                ? Row(
              children: [
                Expanded(child: invoice()),
                SizedBox(width: m.sectionGap * 0.5),
                Expanded(flex: 2, child: primary()),
              ],
            )
                : primary(),
          ),
        ),
      ),
    );
  }
}