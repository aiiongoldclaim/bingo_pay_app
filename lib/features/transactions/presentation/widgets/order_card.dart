import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../../core/widgets/glass/glass_card.dart';
import '../models/order_mock_data.dart';

class OrderCard extends StatelessWidget {
  final Order order;
  final VoidCallback? onTap;

  const OrderCard({super.key, required this.order, this.onTap});

  String get _waitingLabel {
    final elapsed = DateTime.now().difference(order.createdAt);
    if (elapsed.inMinutes < 1) return 'waiting less than a minute';
    if (elapsed.inMinutes < 60) return 'waiting ${elapsed.inMinutes} min';
    if (elapsed.inHours < 24) return 'waiting ${elapsed.inHours} h';
    return 'waiting ${elapsed.inDays} d';
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final isPending = order.status == OrderStatus.pending;

    return GlassCard(
      margin: const EdgeInsets.only(bottom: AppDimensions.sm + 4),
      padding: EdgeInsets.zero,
      radius: AppDimensions.radiusXl,
      onTap: onTap,
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Amber accent edge marks orders that still need action.
            if (isPending)
              Container(
                width: 3.5,
                margin: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  color: colors.warningFg,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(AppDimensions.md),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Spacer(),
                        if (isPending)
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.timer_outlined,
                                  size: 14, color: colors.warningFg),
                              const SizedBox(width: 3),
                              Text(
                                _waitingLabel,
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                  color: colors.warningFg,
                                ),
                              ),
                            ],
                          )
                        else
                          Text(order.timeAgo,
                              style: TextStyle(
                                  fontSize: 13, color: colors.textMuted)),
                        if (onTap != null) ...[
                          const SizedBox(width: 6),
                          Icon(Icons.chevron_right,
                              size: 18, color: colors.textMuted),
                        ],
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(order.customerName,
                        style: const TextStyle(
                            fontSize: 16, fontWeight: FontWeight.w700)),
                    const SizedBox(height: 2),
                    Text(order.itemSummary,
                        style: TextStyle(
                            fontSize: 13, color: colors.textSecondary)),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        _PaymentPill(
                          paymentMethod: order.paymentMethod,
                          paymentStatus: order.paymentStatus,
                        ),
                        const SizedBox(width: 8),
                        _StatusPill(status: order.status),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PaymentPill extends StatelessWidget {
  final String paymentMethod;
  final String paymentStatus;

  const _PaymentPill({required this.paymentMethod, required this.paymentStatus});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final (bg, fg) = switch (paymentStatus.toUpperCase()) {
      'PAID' => (colors.successTint, colors.successFg),
      'FAILED' => (colors.errorTint, colors.errorFg),
      'REFUNDED' => (colors.purpleTint, colors.purpleFg),
      'PENDING' => (colors.warningTint, colors.warningFg),
      _ => (colors.inputFill, colors.textSecondary),
    };
    return _Pill(label: _formatMethod(paymentMethod), background: bg, foreground: fg);
  }

  static String _formatMethod(String raw) {
    if (raw.isEmpty) return 'Unknown';
    return raw
        .split('_')
        .map((w) => w.length <= 3 ? w.toUpperCase() : '${w[0].toUpperCase()}${w.substring(1).toLowerCase()}')
        .join(' ');
  }
}

class _StatusPill extends StatelessWidget {
  final OrderStatus status;

  const _StatusPill({required this.status});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final (bg, fg) = switch (status) {
      OrderStatus.pending => (colors.warningTint, colors.warningFg),
      OrderStatus.confirmed => (colors.infoTint, colors.infoFg),
      OrderStatus.processing => (colors.infoTint, colors.infoFg),
      OrderStatus.shipped => (colors.purpleTint, colors.purpleFg),
      OrderStatus.delivered => (colors.successTint, colors.successFg),
    };
    return _Pill(label: status.label, background: bg, foreground: fg);
  }
}

class _Pill extends StatelessWidget {
  final String label;
  final Color background;
  final Color foreground;

  const _Pill({required this.label, required this.background, required this.foreground});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(color: background, borderRadius: BorderRadius.circular(AppDimensions.radiusCircular)),
      child: Text(label, style: TextStyle(color: foreground, fontWeight: FontWeight.w600, fontSize: 12)),
    );
  }
}
