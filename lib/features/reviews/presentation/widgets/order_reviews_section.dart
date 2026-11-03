import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/di/injection.dart';
import '../../../../core/router/app_routes.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/theme/app_theme_colors.dart';
import '../../../order_details/presentation/widgets/order_details_metrics.dart';
import '../../../order_details/presentation/widgets/order_shell.dart';
import '../../../orders/data/models/order_model.dart' show formatDateTime;
import '../../data/models/review_models.dart';
import '../cubit/review_form_cubit.dart';
import '../cubit/reviews_cubits.dart';
import 'review_widgets.dart';

/// "Reviews" on a delivered order: write or edit a review per product, and
/// rate the delivery agent. Hidden while loading, on error, or with nothing
/// to show. The server decides what can be written.
class OrderReviewsSection extends StatelessWidget {
  final OrderDetailMetrics metrics;
  final String orderUuid;

  const OrderReviewsSection({
    super.key,
    required this.metrics,
    required this.orderUuid,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<OrderReviewsCubit>()..load(orderUuid),
      child: BlocBuilder<OrderReviewsCubit, ReviewsLoad<ReviewEligibility>>(
        builder: (context, state) {
          final e = state.data;
          if (e == null || !e.hasAnything) return const SizedBox.shrink();
          final m = metrics;
          final c = context.c;

          Future<void> open(ReviewFormArgs args) async {
            final changed = await context.push<bool>(
              AppRoutes.reviewForm,
              extra: args,
            );
            if (changed == true && context.mounted) {
              context.read<OrderReviewsCubit>().load(orderUuid);
            }
          }

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              OdSectionLabel(metrics: m, label: 'Reviews'),
              SizedBox(height: m.sectionGap * 0.5),
              OdCard(
                metrics: m,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (!e.canWrite && (e.message ?? '').isNotEmpty)
                      Text(
                        e.message!,
                        style: AppTextStyles.bodySmall.copyWith(
                          color: c.textMuted,
                        ),
                      ),
                    for (final d in e.deliveries) ...[
                      if (e.deliveries.length > 1 && d.shopName.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: Text(
                            'SOLD BY ${d.shopName.toUpperCase()}',
                            style: AppTextStyles.labelSmall.copyWith(
                              color: c.textMuted,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      for (final item in d.items)
                        _ReviewRow(
                          title: item.title,
                          slot: item.slot,
                          canWrite: e.canWrite,
                          writeLabel: 'Write a review',
                          onWrite: () => open(
                            ReviewFormArgs(
                              kind: ReviewKind.product,
                              subject: item.title,
                              orderItemId: item.orderItemId,
                            ),
                          ),
                          onEdit: () => open(
                            ReviewFormArgs(
                              kind: ReviewKind.product,
                              subject: item.title,
                              reviewUuid: item.slot.review?.uuid,
                            ),
                          ),
                        ),
                      if (e.showsAgent(d))
                        _ReviewRow(
                          title: 'Delivered by ${d.agentName}',
                          icon: Icons.local_shipping_outlined,
                          slot: d.agentReview,
                          canWrite: e.canWrite,
                          writeLabel: 'Rate delivery',
                          onWrite: () => open(
                            ReviewFormArgs(
                              kind: ReviewKind.agent,
                              subject: 'Delivery by ${d.agentName}',
                              agentUuid: d.agentUuid,
                              vendorOrderUuid: d.vendorOrderUuid,
                            ),
                          ),
                          onEdit: () => open(
                            ReviewFormArgs(
                              kind: ReviewKind.agent,
                              subject: 'Delivery by ${d.agentName}',
                              reviewUuid: d.agentReview.review?.uuid,
                            ),
                          ),
                        ),
                    ],
                  ],
                ),
              ),
              SizedBox(height: m.sectionGap),
            ],
          );
        },
      ),
    );
  }
}

class _ReviewRow extends StatelessWidget {
  final String title;
  final IconData? icon;
  final ReviewSlot slot;
  final bool canWrite;
  final String writeLabel;
  final VoidCallback onWrite;
  final VoidCallback onEdit;

  const _ReviewRow({
    required this.title,
    this.icon,
    required this.slot,
    required this.canWrite,
    required this.writeLabel,
    required this.onWrite,
    required this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    final muted = AppTextStyles.bodySmall.copyWith(color: c.textMuted);
    final review = slot.review;

    final Widget? trailing;
    String? note;
    if (review != null) {
      trailing = Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          ReviewStars(value: review.rating, size: 14),
          ReviewStatusChip(status: review.status),
          if (canWrite)
            TextButton(onPressed: onEdit, child: const Text('Edit')),
        ],
      );
    } else if (slot.eligible && canWrite) {
      trailing = OutlinedButton.icon(
        onPressed: onWrite,
        icon: const Icon(Icons.star_outline_rounded, size: 18),
        label: Text(writeLabel),
      );
      if (slot.reviewableUntil != null) {
        note = 'Review by ${formatDateTime(slot.reviewableUntil!)}';
      }
    } else {
      trailing = null;
      note = slot.reasonText;
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          if (icon != null) ...[
            Icon(icon, size: 18, color: c.textSecondary),
            const SizedBox(width: 8),
          ],
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: c.textPrimary,
                  ),
                ),
                if (note != null) Text(note, style: muted),
              ],
            ),
          ),
          ?trailing,
        ],
      ),
    );
  }
}
