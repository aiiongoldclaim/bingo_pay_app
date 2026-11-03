import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/di/injection.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/theme/app_theme_colors.dart';
import '../../../../core/widgets/app_bottom_sheets.dart';
import '../../../../core/widgets/app_error_widget.dart';
import '../../../../core/widgets/app_snackbar.dart';
import '../../../../core/widgets/bottom_action_bar.dart';
import '../../../../core/widgets/custom_app_bar.dart';
import '../../../orders/data/models/order_model.dart'
    show formatAmount, formatDateTime;
import '../../data/models/refund_request_model.dart';
import '../cubit/refund_requests_cubit.dart';
import '../widgets/refund_widgets.dart';

/// One refund request: what was asked, where it is, its history, withdraw.
class RefundDetailScreen extends StatelessWidget {
  final String uuid;

  const RefundDetailScreen({super.key, required this.uuid});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<RefundRequestsCubit>()..loadDetail(uuid),
      child: _RefundDetailView(uuid: uuid),
    );
  }
}

class _RefundDetailView extends StatefulWidget {
  final String uuid;

  const _RefundDetailView({required this.uuid});

  @override
  State<_RefundDetailView> createState() => _RefundDetailViewState();
}

class _RefundDetailViewState extends State<_RefundDetailView> {
  bool _withdrawing = false;

  Future<void> _withdraw() async {
    final cubit = context.read<RefundRequestsCubit>();
    final confirmed = await showAppConfirmDialog(
      context: context,
      title: 'Withdraw this request?',
      message:
          'The items become available to ask for again while the return window is open.',
      confirmLabel: 'Withdraw',
      cancelLabel: 'Keep it',
      isDestructive: true,
      icon: Icons.undo_rounded,
    );
    if (!confirmed || !mounted) return;
    setState(() => _withdrawing = true);
    final error = await cubit.cancel(widget.uuid);
    if (!mounted) return;
    setState(() => _withdrawing = false);
    error == null
        ? AppSnackbar.showSuccess(context, 'Request withdrawn')
        : AppSnackbar.showError(context, error);
  }

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    return BlocBuilder<RefundRequestsCubit, RefundRequestsState>(
      builder: (context, state) {
        final request = state is RefundDetailLoaded ? state.request : null;
        return Scaffold(
          backgroundColor: c.background,
          appBar: CustomAppBar(title: 'Refund ${request?.reference ?? ''}'),
          body: switch (state) {
            RefundRequestsError(:final message) => AppErrorWidget(
              failure: UnknownFailure(message),
              onRetry: () =>
                  context.read<RefundRequestsCubit>().loadDetail(widget.uuid),
            ),
            RefundDetailLoaded(:final request) => _Body(request: request),
            _ => const RefundListShimmer(),
          },
          bottomNavigationBar: request != null && request.canCancel
              ? AppBottomActionBar(
                  primaryLabel: 'Withdraw request',
                  primaryLoading: _withdrawing,
                  onPrimaryPressed: _withdrawing ? null : _withdraw,
                )
              : null,
        );
      },
    );
  }
}

class _Body extends StatelessWidget {
  final RefundRequestModel request;

  const _Body({required this.request});

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    final r = request;
    final label = AppTextStyles.labelSmall.copyWith(
      color: c.textMuted,
      fontWeight: FontWeight.w700,
      letterSpacing: 0.6,
    );
    final body = AppTextStyles.bodyMedium.copyWith(color: c.textPrimary);
    final muted = AppTextStyles.bodySmall.copyWith(color: c.textSecondary);

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Row(
          children: [
            RefundStatusPill(status: r.status),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                'Order ${r.orderNumber} · ${r.shopName}',
                style: muted,
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),
        if (r.status == 'VENDOR_REVIEW' && r.vendorRespondBy != null) ...[
          RefundNotice(
            color: c.statusWarning,
            text:
                'The seller has until ${formatDateTime(r.vendorRespondBy!)} to answer. After that our team decides.',
          ),
          const SizedBox(height: 12),
        ],
        if (r.status == 'REJECTED' && (r.adminNote ?? '').isNotEmpty) ...[
          RefundNotice(
            color: c.error,
            title: 'Reason for rejection',
            text: r.adminNote!,
          ),
          const SizedBox(height: 12),
        ],
        if (r.refundReference != null) ...[
          RefundNotice(
            color: c.statusInfo,
            text:
                'Refund ${r.refundReference}: ${formatAmount(r.refundAmount)} back to your original payment method.',
          ),
          const SizedBox(height: 12),
        ],
        RefundCard(
          child: Row(
            children: [
              for (final (title, value) in [
                ('Items', formatAmount(r.itemsAmount)),
                (
                  'Kept (restocking)',
                  r.chargesAmount > 0 ? formatAmount(r.chargesAmount) : '—',
                ),
                ('Refund', formatAmount(r.refundAmount)),
              ])
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(title, style: muted),
                      const SizedBox(height: 2),
                      Text(
                        value,
                        style: body.copyWith(fontWeight: FontWeight.w700),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        RefundCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('REASON', style: label),
              const SizedBox(height: 4),
              Text(r.reasonLabel, style: body.copyWith(fontWeight: FontWeight.w600)),
              if ((r.description ?? '').isNotEmpty) ...[
                const SizedBox(height: 4),
                Text(r.description!, style: muted),
              ],
            ],
          ),
        ),
        const SizedBox(height: 12),
        RefundCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('ITEMS', style: label),
              for (final i in r.items)
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(i.title, style: body),
                            if (i.sku.isNotEmpty) Text(i.sku, style: muted),
                          ],
                        ),
                      ),
                      Text(
                        'Qty ${i.quantity} · ${formatAmount(i.amount)}',
                        style: body,
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
        if (r.evidence.isNotEmpty) ...[
          const SizedBox(height: 12),
          Text('PHOTOS', style: label),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final url in r.evidence)
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.network(
                    url,
                    width: 72,
                    height: 72,
                    fit: BoxFit.cover,
                    errorBuilder: (_, _, _) => Container(
                      width: 72,
                      height: 72,
                      color: c.surfaceAlt,
                      child: Icon(Icons.broken_image_outlined, color: c.textMuted),
                    ),
                  ),
                ),
            ],
          ),
        ],
        if (r.events.isNotEmpty) ...[
          const SizedBox(height: 16),
          Text('HISTORY', style: label),
          const SizedBox(height: 8),
          for (final e in r.events)
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    margin: const EdgeInsets.only(top: 6, right: 10),
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: c.brand,
                      shape: BoxShape.circle,
                    ),
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(e.label, style: body),
                        if ((e.note ?? '').isNotEmpty) Text(e.note!, style: muted),
                        Text(
                          [
                            e.actor,
                            if (e.createdAt != null) formatDateTime(e.createdAt!),
                          ].join(' · '),
                          style: muted.copyWith(color: c.textMuted),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
        ],
      ],
    );
  }
}
