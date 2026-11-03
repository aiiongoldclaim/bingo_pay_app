import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/di/injection.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/helpers/image_picker_helper.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/theme/app_theme_colors.dart';
import '../../../../core/widgets/app_error_widget.dart';
import '../../../../core/widgets/app_snackbar.dart';
import '../../../../core/widgets/bottom_action_bar.dart';
import '../../../../core/widgets/custom_app_bar.dart';
import '../../../orders/data/models/order_model.dart'
    show formatAmount, formatDateTime;
import '../../data/models/refund_request_model.dart';
import '../cubit/refund_form_cubit.dart';
import '../widgets/refund_widgets.dart';

/// Ask for some lines of an order back. Pops `true` once sent.
class RefundRequestScreen extends StatelessWidget {
  final String orderUuid;

  const RefundRequestScreen({super.key, required this.orderUuid});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<RefundFormCubit>()..load(orderUuid),
      child: _RefundRequestView(orderUuid: orderUuid),
    );
  }
}

class _RefundRequestView extends StatefulWidget {
  final String orderUuid;

  const _RefundRequestView({required this.orderUuid});

  @override
  State<_RefundRequestView> createState() => _RefundRequestViewState();
}

class _RefundRequestViewState extends State<_RefundRequestView> {
  final _description = TextEditingController();

  @override
  void dispose() {
    _description.dispose();
    super.dispose();
  }

  Future<void> _addPhoto() async {
    final cubit = context.read<RefundFormCubit>();
    final file = await ImagePickerHelper.pick(
      context,
      imageQuality: 70,
      maxWidth: 1600,
    );
    if (file != null) await cubit.addPhoto(file);
  }

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    final cubit = context.read<RefundFormCubit>();

    return BlocConsumer<RefundFormCubit, RefundFormState>(
      listener: (context, state) {
        if (state.error != null) AppSnackbar.showError(context, state.error!);
        if (state.sentMessage != null) {
          AppSnackbar.showSuccess(context, state.sentMessage!);
          context.pop(true);
        }
      },
      listenWhen: (prev, next) =>
          next.error != null ||
          (next.sentMessage != null && prev.sentMessage == null),
      builder: (context, state) {
        final eligibility = state.eligibility;
        final Widget body;
        if (state.loadError != null) {
          body = AppErrorWidget(
            failure: UnknownFailure(state.loadError!),
            onRetry: () => cubit.load(widget.orderUuid),
          );
        } else if (eligibility == null) {
          body = Center(child: CircularProgressIndicator(color: c.brand));
        } else {
          body = _Form(
            state: state,
            description: _description,
            onAddPhoto: _addPhoto,
          );
        }

        return Scaffold(
          backgroundColor: c.background,
          appBar: CustomAppBar(
            title: eligibility == null || eligibility.orderNumber.isEmpty
                ? 'Request a refund'
                : 'Refund · ${eligibility.orderNumber}',
          ),
          body: body,
          bottomNavigationBar: eligibility?.available == true
              ? AppBottomActionBar(
                  primaryLabel: 'Send request',
                  primaryLoading: state.submitting,
                  onPrimaryPressed: state.problem == null && !state.uploading
                      ? () => cubit.submit(widget.orderUuid, _description.text)
                      : null,
                )
              : null,
        );
      },
    );
  }
}

class _Form extends StatelessWidget {
  final RefundFormState state;
  final TextEditingController description;
  final VoidCallback onAddPhoto;

  const _Form({
    required this.state,
    required this.description,
    required this.onAddPhoto,
  });

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    final cubit = context.read<RefundFormCubit>();
    final eligibility = state.eligibility!;
    final heading = AppTextStyles.bodyLarge.copyWith(
      color: c.textPrimary,
      fontWeight: FontWeight.w700,
    );
    final muted = AppTextStyles.bodySmall.copyWith(color: c.textSecondary);
    final reason = state.reason;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        if ((eligibility.message ?? '').isNotEmpty) ...[
          RefundNotice(color: c.statusWarning, text: eligibility.message!),
          const SizedBox(height: 16),
        ],
        Text('Which items?', style: heading),
        const SizedBox(height: 8),
        RefundCard(
          padding: EdgeInsets.zero,
          child: Column(
            children: [
              for (final line in eligibility.lines)
                _LineTile(line: line, quantity: state.picked[line.orderItemId] ?? 0),
            ],
          ),
        ),
        if (eligibility.available) ...[
          const SizedBox(height: 20),
          Text('Reason', style: heading),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final r in state.reasons)
                ChoiceChip(
                  label: Text(r.label),
                  selected: r.code == reason?.code,
                  onSelected: (_) => cubit.setReason(r.code),
                ),
            ],
          ),
          const SizedBox(height: 20),
          Text('Tell us more (optional)', style: heading),
          const SizedBox(height: 8),
          TextField(
            controller: description,
            maxLines: 3,
            maxLength: 2000,
            decoration: InputDecoration(
              hintText: 'What went wrong?',
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Photos ${reason?.requiresEvidence == true ? '(required)' : '(optional)'} · up to $maxRefundPhotos',
            style: heading,
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final url in state.photos)
                Stack(
                  clipBehavior: Clip.none,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.network(url, width: 72, height: 72, fit: BoxFit.cover),
                    ),
                    Positioned(
                      right: -8,
                      top: -8,
                      child: IconButton.filledTonal(
                        visualDensity: VisualDensity.compact,
                        iconSize: 14,
                        tooltip: 'Remove photo',
                        onPressed: () => cubit.removePhoto(url),
                        icon: const Icon(Icons.close_rounded),
                      ),
                    ),
                  ],
                ),
              if (state.photos.length < maxRefundPhotos)
                InkWell(
                  onTap: state.uploading ? null : onAddPhoto,
                  borderRadius: BorderRadius.circular(8),
                  child: Container(
                    width: 72,
                    height: 72,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: c.border),
                    ),
                    child: state.uploading
                        ? Center(
                            child: SizedBox.square(
                              dimension: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: c.brand,
                              ),
                            ),
                          )
                        : Icon(Icons.add_a_photo_outlined, color: c.textSecondary),
                  ),
                ),
            ],
          ),
          if (state.selected.isNotEmpty) ...[
            const SizedBox(height: 20),
            RefundCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Items value: ${formatAmount(state.estimate)}',
                    style: heading,
                  ),
                  if (state.restockPercent > 0)
                    Text(
                      'For this reason a restocking fee of up to ${state.restockPercent.toStringAsFixed(0)}% may be kept.',
                      style: muted,
                    ),
                  Text(
                    'The refund goes back to the payment method you used.',
                    style: muted,
                  ),
                ],
              ),
            ),
          ],
          if (state.problem != null) ...[
            const SizedBox(height: 12),
            Text(state.problem!, style: muted),
          ],
        ],
      ],
    );
  }
}

class _LineTile extends StatelessWidget {
  final RefundLine line;
  final int quantity;

  const _LineTile({required this.line, required this.quantity});

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    final cubit = context.read<RefundFormCubit>();
    final muted = AppTextStyles.bodySmall.copyWith(color: c.textSecondary);
    final details = [
      if (line.shopName.isNotEmpty) line.shopName,
      '${formatAmount(line.totalAmount)} for ${line.quantity}',
      if (line.eligible && line.deadline != null)
        'ask by ${formatDateTime(line.deadline!)}',
    ].join(' · ');

    return CheckboxListTile(
      value: quantity > 0,
      onChanged: line.eligible ? (_) => cubit.toggle(line) : null,
      controlAffinity: ListTileControlAffinity.leading,
      activeColor: c.brand,
      title: Text(
        line.title,
        style: AppTextStyles.bodyMedium.copyWith(
          color: line.eligible ? c.textPrimary : c.textMuted,
        ),
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(details, style: muted),
          if (!line.eligible && (line.reason ?? '').isNotEmpty)
            Text(line.reason!, style: muted.copyWith(color: c.textMuted)),
          if (quantity > 0 && line.maxQuantity > 1)
            Row(
              children: [
                IconButton(
                  tooltip: 'Fewer',
                  onPressed: quantity > 1
                      ? () => cubit.setQuantity(line, quantity - 1)
                      : null,
                  icon: const Icon(Icons.remove_circle_outline),
                ),
                Text('$quantity', style: AppTextStyles.bodyMedium),
                IconButton(
                  tooltip: 'More',
                  onPressed: quantity < line.maxQuantity
                      ? () => cubit.setQuantity(line, quantity + 1)
                      : null,
                  icon: const Icon(Icons.add_circle_outline),
                ),
              ],
            ),
        ],
      ),
    );
  }
}
