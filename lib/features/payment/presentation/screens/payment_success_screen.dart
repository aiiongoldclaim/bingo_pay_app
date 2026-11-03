import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/router/app_routes.dart';
import '../../../../core/storage/preferences_service.dart';
import '../../../../core/theme/app_theme_colors.dart';
import '../../../../core/utils/pdf_file_handler.dart';
import '../../../../core/utils/review_helper.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_snackbar.dart';
import '../../../orders/data/datasource/orders_remote_datasource.dart';
import '../cubit/payment_cubit.dart';
import '../cubit/payment_state.dart';
import '../widgets/checkout_ui.dart';

// The order is placed: a tick, what was paid (or is owed on delivery), the
// order number, a receipt, and where to go next.
class PaymentSuccessScreen extends StatefulWidget {
  const PaymentSuccessScreen({super.key});

  @override
  State<PaymentSuccessScreen> createState() => _PaymentSuccessScreenState();
}

class _PaymentSuccessScreenState extends State<PaymentSuccessScreen> {
  bool _generatingPdf = false;

  @override
  void initState() {
    super.initState();
    // Asked once only: every time, it just covers the order confirmation.
    final prefs = GetIt.I<PreferencesService>();
    if (prefs.isReviewPromptSeen()) return;

    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        prefs.setReviewPromptSeen();
        ReviewHelper.showReviewDialog(
          context,
          title: 'Payment Successful! 🎉',
          subtitle: 'Help us improve by rating this app',
          positiveRatingMessage:
              'Thank you! Please share your positive experience on the Play Store.',
          negativeRatingMessage:
              'We appreciate your feedback. Let us know how we can improve.',
        );
      }
    });
  }

  Future<void> _downloadInvoice(PaymentMethodState state) async {
    if (state.orderUuid.isEmpty) {
      AppSnackbar.showError(
        context,
        'Invoice is not available for this order yet.',
      );
      return;
    }
    setState(() => _generatingPdf = true);
    try {
      final invoice = await GetIt.I<OrdersRemoteDataSource>().downloadInvoice(
        state.orderUuid,
      );
      await openOrSharePdf(invoice.bytes, invoice.filename);
    } catch (e, st) {
      debugPrint('[Invoice] Download failed: $e\n$st');
      if (mounted) {
        AppSnackbar.showError(
          context,
          'Failed to download invoice. Please try again.',
        );
      }
    } finally {
      if (mounted) setState(() => _generatingPdf = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return BlocBuilder<PaymentMethodCubit, PaymentMethodState>(
      builder: (context, state) {
        final cod = state.selectedMethod == PaymentMethod.cashOnDelivery;
        final total = state.totalAmount > 0 ? money(state.totalAmount) : null;

        return PopScope(
          canPop: false,
          child: Scaffold(
            backgroundColor: colors.background,
            body: SafeArea(
              child: Column(
                children: [
                  Expanded(
                    child: CheckoutBody(
                      children: [
                        const SizedBox(height: 24),
                        const Center(child: _SuccessMark()),
                        const SizedBox(height: 20),
                        Text(
                          cod ? 'Order placed' : 'Payment successful',
                          textAlign: TextAlign.center,
                          style: checkoutText(
                            colors.textPrimary,
                            size: 22,
                            weight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          cod
                              ? 'Pay${total == null ? '' : ' $total'} when your order arrives.'
                              : 'Thank you! Your order is confirmed.',
                          textAlign: TextAlign.center,
                          style: checkoutText(colors.textSecondary),
                        ),
                        if (total != null && !cod) ...[
                          const SizedBox(height: 14),
                          Text(
                            total,
                            textAlign: TextAlign.center,
                            style: checkoutText(
                              colors.textPrimary,
                              size: 34,
                              weight: FontWeight.w800,
                            ),
                          ),
                        ],
                        if (state.orderId.isNotEmpty) ...[
                          const SizedBox(height: 12),
                          Center(child: _OrderNumber(state.orderId)),
                        ],
                        const SizedBox(height: 28),
                        CheckoutSection(
                          title: 'Receipt',
                          padding: const EdgeInsets.fromLTRB(14, 10, 14, 10),
                          child: Column(
                            children: [
                              CheckoutItems(state: state),
                              if (state.isQuoted &&
                                  (state.deliveryCharge > 0 ||
                                      state.taxes > 0)) ...[
                                Divider(height: 20, color: colors.border),
                                if (state.deliveryCharge > 0)
                                  CheckoutLine(
                                    'Delivery',
                                    money(state.deliveryCharge),
                                  ),
                                if (state.taxes > 0)
                                  CheckoutLine(
                                    'Taxes & fees',
                                    money(state.taxes),
                                  ),
                              ],
                              if (total != null) ...[
                                Divider(height: 20, color: colors.border),
                                CheckoutLine(
                                  cod ? 'To pay on delivery' : 'Total paid',
                                  total,
                                  total: true,
                                ),
                              ],
                            ],
                          ),
                        ),
                        if (state.deliveryName.isNotEmpty) ...[
                          const SizedBox(height: 20),
                          CheckoutSection(
                            title: 'Delivering to',
                            padding: const EdgeInsets.all(14),
                            child: Text(
                              '${state.deliveryName}\n${state.deliveryAddress}, '
                              '${state.deliveryCity} ${state.deliveryPostal}',
                              style: checkoutText(
                                colors.textSecondary,
                                size: 13,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                    child: Center(
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 560),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            AppButton(
                              label: 'View my orders',
                              onPressed: () => context.go(AppRoutes.orders),
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                Expanded(
                                  child: TextButton.icon(
                                    onPressed: _generatingPdf
                                        ? null
                                        : () => _downloadInvoice(state),
                                    icon: _generatingPdf
                                        ? const SizedBox.square(
                                            dimension: 16,
                                            child: CircularProgressIndicator(
                                              strokeWidth: 2,
                                            ),
                                          )
                                        : const Icon(
                                            Icons.download_rounded,
                                            size: 18,
                                          ),
                                    label: Text(
                                      _generatingPdf ? 'Preparing…' : 'Invoice',
                                    ),
                                  ),
                                ),
                                Expanded(
                                  child: TextButton.icon(
                                    onPressed: () => context.go(AppRoutes.home),
                                    icon: const Icon(
                                      Icons.storefront_outlined,
                                      size: 18,
                                    ),
                                    label: const Text('Keep shopping'),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

// A green tick that pops in.
class _SuccessMark extends StatelessWidget {
  const _SuccessMark();

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.6, end: 1),
      duration: const Duration(milliseconds: 450),
      curve: Curves.easeOutBack,
      builder: (context, scale, child) =>
          Transform.scale(scale: scale, child: child),
      child: Container(
        width: 96,
        height: 96,
        decoration: BoxDecoration(
          color: colors.statusSuccess.withValues(alpha: 0.12),
          shape: BoxShape.circle,
        ),
        alignment: Alignment.center,
        child: Container(
          width: 64,
          height: 64,
          decoration: BoxDecoration(
            color: colors.statusSuccess,
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.check_rounded,
            color: Colors.white,
            size: 38,
            semanticLabel: 'Success',
          ),
        ),
      ),
    );
  }
}

// The order number, on a chip that copies it.
class _OrderNumber extends StatelessWidget {
  final String id;

  const _OrderNumber(this.id);

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Material(
      color: colors.surfaceAlt,
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: () {
          Clipboard.setData(ClipboardData(text: id));
          AppSnackbar.showSuccess(context, 'Order number copied');
        },
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Flexible(
                child: Text.rich(
                  TextSpan(
                    children: [
                      TextSpan(
                        text: 'Order ',
                        style: checkoutText(colors.textSecondary, size: 13),
                      ),
                      TextSpan(
                        text: id,
                        style: checkoutText(
                          colors.textPrimary,
                          size: 13,
                          weight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 6),
              Icon(Icons.copy_rounded, size: 14, color: colors.textMuted),
            ],
          ),
        ),
      ),
    );
  }
}
