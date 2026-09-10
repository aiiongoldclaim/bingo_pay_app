import 'package:flutter/material.dart';

import '../../../../../core/theme/app_theme_colors.dart';
import '../../../../../core/widgets/app_button.dart';
import 'payment_success_matrics.dart';

// ── Bottom actions ─────────────────────────────────────────────────────────
class PaymentSuccessActionBar extends StatelessWidget {
  final PaymentSuccessMetrics metrics;
  final bool generating;
  final VoidCallback? onDownload;
  final VoidCallback onHome;

  const PaymentSuccessActionBar({
    super.key,
    required this.metrics,
    required this.generating,
    required this.onDownload,
    required this.onHome,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.c;
    final m = metrics;

    return Container(
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(m.cardRadius),
        ),
        boxShadow: [
          BoxShadow(
            color: colors.brand.withValues(alpha: colors.isDark ? 0.28 : 0.10),
            blurRadius: 20,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: m.barHPad,
            vertical: m.barVPad,
          ),
          child: Row(
            children: [
              Expanded(
                child: AppButton(
                  label: generating ? 'Generating…' : 'Download Invoice',
                  prefixIcon: generating
                      ? Icons.hourglass_top_outlined
                      : Icons.download_outlined,
                  variant: AppButtonVariant.outlined,
                  height: m.btnHeight,
                  fontSize: m.btnFontSize,
                  onPressed: onDownload,
                ),
              ),
              SizedBox(width: m.gapSm * 1.2),
              Expanded(
                child: AppButton(
                  label: 'Go to Home',
                  prefixIcon: Icons.home_outlined,
                  height: m.btnHeight,
                  fontSize: m.btnFontSize,
                  onPressed: onHome,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
