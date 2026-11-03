import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/di/injection.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/router/app_routes.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/theme/app_theme_colors.dart';
import '../../../../core/widgets/app_error_widget.dart';
import '../../../../core/widgets/custom_app_bar.dart';
import '../../../orders/data/models/order_model.dart'
    show formatAmount, formatDateTime;
import '../../data/models/refund_request_model.dart';
import '../cubit/refund_requests_cubit.dart';
import '../widgets/refund_widgets.dart';

/// The customer's refund requests. A new one starts from the order page.
class MyRefundsScreen extends StatelessWidget {
  const MyRefundsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<RefundRequestsCubit>()..loadMine(),
      child: Builder(
        builder: (context) {
          final c = context.c;
          final cubit = context.read<RefundRequestsCubit>();
          return Scaffold(
            backgroundColor: c.background,
            appBar: const CustomAppBar(title: 'My Refunds'),
            body: BlocBuilder<RefundRequestsCubit, RefundRequestsState>(
              builder: (context, state) => switch (state) {
                RefundRequestsError(:final message) => AppErrorWidget(
                  failure: UnknownFailure(message),
                  onRetry: cubit.loadMine,
                ),
                RefundListLoaded(:final items) => RefreshIndicator(
                  color: c.brand,
                  onRefresh: cubit.loadMine,
                  child: items.isEmpty
                      ? ListView(
                          padding: const EdgeInsets.all(32),
                          children: [
                            Icon(Icons.undo_rounded, size: 40, color: c.textMuted),
                            const SizedBox(height: 12),
                            Text(
                              'No refund requests yet.\nTo ask for a refund, open the order under My Orders.',
                              textAlign: TextAlign.center,
                              style: AppTextStyles.bodyMedium.copyWith(
                                color: c.textSecondary,
                              ),
                            ),
                          ],
                        )
                      : ListView.separated(
                          padding: const EdgeInsets.all(16),
                          itemCount: items.length,
                          separatorBuilder: (_, _) => const SizedBox(height: 12),
                          itemBuilder: (context, i) => _RefundTile(
                            request: items[i],
                            onTap: () async {
                              await context.push(
                                AppRoutes.refundDetailPath(items[i].uuid),
                              );
                              // A withdrawn request changes status.
                              if (context.mounted) cubit.loadMine();
                            },
                          ),
                        ),
                ),
                _ => const RefundListShimmer(),
              },
            ),
          );
        },
      ),
    );
  }
}

class _RefundTile extends StatelessWidget {
  final RefundRequestModel request;
  final VoidCallback onTap;

  const _RefundTile({required this.request, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    final r = request;
    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: onTap,
      child: RefundCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Text(
                    r.items.map((i) => i.title).join(', '),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.bodyLarge.copyWith(
                      color: c.textPrimary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  formatAmount(r.refundAmount),
                  style: AppTextStyles.bodyLarge.copyWith(
                    color: c.textPrimary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              [
                r.reference,
                'Order ${r.orderNumber}',
                r.shopName,
                if (r.createdAt != null) formatDateTime(r.createdAt!),
              ].where((s) => s.isNotEmpty).join(' · '),
              style: AppTextStyles.bodySmall.copyWith(color: c.textSecondary),
            ),
            if (r.status == 'REJECTED' && (r.adminNote ?? '').isNotEmpty) ...[
              const SizedBox(height: 6),
              Text(
                'Reason for rejection: ${r.adminNote}',
                style: AppTextStyles.bodySmall.copyWith(color: c.error),
              ),
            ],
            const SizedBox(height: 10),
            RefundStatusPill(status: r.status),
          ],
        ),
      ),
    );
  }
}
