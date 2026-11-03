import 'package:flutter/material.dart';

import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/theme/app_theme_colors.dart';
import '../../../../core/widgets/app_shimmer.dart';
import '../../data/models/refund_request_model.dart';

/// Surface card used across the refund screens.
class RefundCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;

  const RefundCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(14),
  });

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    return Container(
      width: double.infinity,
      padding: padding,
      decoration: BoxDecoration(
        color: c.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: c.border),
      ),
      child: child,
    );
  }
}

/// A tinted message box (seller deadline, rejection reason, refund sent…).
class RefundNotice extends StatelessWidget {
  final String text;
  final String? title;
  final Color color;

  const RefundNotice({
    super.key,
    required this.text,
    required this.color,
    this.title,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (title != null)
            Text(
              title!,
              style: AppTextStyles.bodyMedium.copyWith(
                color: color,
                fontWeight: FontWeight.w700,
              ),
            ),
          Text(text, style: AppTextStyles.bodyMedium.copyWith(color: color)),
        ],
      ),
    );
  }
}

class RefundStatusPill extends StatelessWidget {
  final String status;

  const RefundStatusPill({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    final color = switch (status) {
      'REFUNDED' || 'APPROVED' => c.statusSuccess,
      'REFUNDING' => c.statusInfo,
      'VENDOR_REVIEW' || 'ADMIN_REVIEW' => c.statusWarning,
      'REJECTED' || 'REFUND_FAILED' => c.error,
      _ => c.textMuted,
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        refundStatusLabels[status] ?? status,
        style: AppTextStyles.labelSmall.copyWith(
          color: color,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class RefundListShimmer extends StatelessWidget {
  const RefundListShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return AppShimmer(
      child: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: 5,
        separatorBuilder: (_, _) => const SizedBox(height: 12),
        itemBuilder: (_, _) => Container(
          height: 84,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }
}
