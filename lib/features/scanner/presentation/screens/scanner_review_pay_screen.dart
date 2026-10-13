import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/error/error_handler.dart';
import '../../../../core/router/app_routes.dart';
import '../../../../core/theme/app_theme_colors.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_loader.dart';
import '../../../../core/widgets/app_snackbar.dart';
import '../../../../core/widgets/custom_app_bar.dart';
import '../../data/tvs_qr_datasource.dart';
import '../cubit/payment_cubit.dart';
import '../cubit/payment_state.dart';
import '../widgets/review_payment_amount_section.dart';
import '../widgets/review_payment_banner.dart';
import '../widgets/review_payment_body.dart';
import '../widgets/review_payment_merchant_card.dart';
import '../widgets/review_payment_method_section.dart';
import '../widgets/review_payment_metrics.dart';
import '../widgets/review_payment_note_section.dart';
import '../widgets/review_payment_pay_bar.dart';
import '../widgets/review_payment_quote_card.dart';

// Shop QR payment with TVS Coins. The cubit was asked to resolve the scanned
// token when this screen was pushed.
class ReviewPaymentScreen extends StatefulWidget {
  const ReviewPaymentScreen({super.key});

  @override
  State<ReviewPaymentScreen> createState() => _ReviewPaymentScreenState();
}

class _ReviewPaymentScreenState extends State<ReviewPaymentScreen> {
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _codeController = TextEditingController();
  final TextEditingController _noteController = TextEditingController();

  @override
  void dispose() {
    _amountController.dispose();
    _codeController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  void _onInputChanged(String _) {
    setState(() {}); // field counters
    context.read<PaymentCubit>().inputChanged(
      _amountController.text,
      _codeController.text,
    );
  }

  String _initials(String name) {
    final parts = name
        .trim()
        .split(RegExp(r'\s+'))
        .where((p) => p.isNotEmpty)
        .toList();
    if (parts.isEmpty) return '?';
    if (parts.length == 1) {
      return parts[0].substring(0, parts[0].length >= 2 ? 2 : 1).toUpperCase();
    }
    return (parts[0][0] + parts[1][0]).toUpperCase();
  }

  Future<void> _pay({String? pin}) async {
    final cubit = context.read<PaymentCubit>();
    try {
      final receipt = await cubit.pay(
        pin: pin,
        note: _noteController.text.trim(),
      );
      if (!mounted) return;
      AppSnackbar.showSuccess(context, 'Payment successful');
      context.push(
        AppRoutes.transferSuccess,
        extra: {
          'merchantName': cubit.state.shop?['shop']?['name'],
          'amount': receipt['paid'],
          'currency': receipt['currency'],
          'reference': receipt['transactionUuid'],
        },
      );
    } on TvsQrException catch (e) {
      if (!mounted) return;
      switch (e.code) {
        case 'PIN_REQUIRED' || 'PIN_INVALID':
          final pin = await _askPin(e);
          if (pin != null && mounted) await _pay(pin: pin);
        case 'QUOTE_CHANGED' || 'INSUFFICIENT_FUNDS':
          // Show the new price / shortfall; the user confirms again.
          AppSnackbar.showError(context, e.message);
          cubit.requote();
        default:
          AppSnackbar.showError(context, e.message);
      }
    } catch (e) {
      // Network drop or timeout: the idempotency key is kept, so tapping Pay
      // again retries this same payment and can't charge twice.
      if (mounted) {
        AppSnackbar.showError(
          context,
          ErrorHandler.mapObjectToFailure(e).message,
        );
      }
    }
  }

  // Asks for the wallet PIN, creating one first if the user has none.
  Future<String?> _askPin(TvsQrException e) async {
    final cubit = context.read<PaymentCubit>();
    var isSet = true;
    if (e.code == 'PIN_REQUIRED') {
      try {
        isSet = await cubit.pinIsSet();
      } catch (_) {}
    }
    if (!mounted) return null;

    final pin = await _pinDialog(
      title: isSet ? 'Enter wallet PIN' : 'Create a wallet PIN',
      message: isSet
          ? e.message
          : 'Larger payments need a wallet PIN. Choose 4 to 6 digits.',
    );
    if (pin == null || isSet) return pin;

    try {
      await cubit.setPin(pin);
      return pin;
    } catch (err) {
      if (mounted) {
        AppSnackbar.showError(
          context,
          ErrorHandler.mapObjectToFailure(err).message,
        );
      }
      return null;
    }
  }

  Future<String?> _pinDialog({required String title, required String message}) {
    var pin = '';
    return showDialog<String>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(title),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(message),
            TextField(
              autofocus: true,
              obscureText: true,
              maxLength: 6,
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              onChanged: (v) => pin = v,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              if (pin.length >= 4) Navigator.of(dialogContext).pop(pin);
            },
            child: const Text('Confirm'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.c;

    return Scaffold(
      backgroundColor: colors.background,
      resizeToAvoidBottomInset: true,
      appBar: const CustomAppBar(title: 'Scan & Pay'),
      body: SafeArea(
        bottom: false,
        child: BlocBuilder<PaymentCubit, PaymentState>(
          builder: (context, state) {
            final resolved = state.shop;
            if (resolved == null) {
              if (state.error == null) return const AppLoader();
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Text(state.error!, textAlign: TextAlign.center),
                ),
              );
            }

            final m = ReviewPaymentMetrics.of(context);
            final shopName = '${resolved['shop']?['name'] ?? 'Shop'}';
            final currency = '${resolved['currency']}';
            final reason = state.canPay ? null : '${resolved['reason']}';

            final banner = ReviewPaymentSecureBanner(metrics: m);

            final merchant = ReviewPaymentMerchantCard(
              metrics: m,
              name: shopName,
              subtitle: 'Accepts TVS Coins · $currency',
              initials: _initials(shopName),
            );

            final amount = Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                ReviewPaymentAmountSection(
                  metrics: m,
                  controller: _amountController,
                  currency: currency,
                  error: reason ?? state.error,
                  onChanged: _onInputChanged,
                ),
                if (resolved['reasonCode'] == 'KYC_REQUIRED') ...[
                  SizedBox(height: m.gapSm),
                  AppButton(
                    label: 'Verify identity',
                    variant: AppButtonVariant.outlined,
                    prefixIcon: Icons.shield_outlined,
                    onPressed: () {
                      final cubit = context.read<PaymentCubit>();
                      context
                          .push(AppRoutes.walletKyc)
                          .then((_) => cubit.reload());
                    },
                  ),
                ],
                SizedBox(height: m.gapMd),
                ReviewPaymentNoteSection(
                  metrics: m,
                  controller: _codeController,
                  onChanged: _onInputChanged,
                  label: 'COUPON CODE (OPTIONAL)',
                  hint: 'Enter a coupon',
                  icon: Icons.local_offer_outlined,
                  maxLength: 40,
                  capitalization: TextCapitalization.characters,
                ),
              ],
            );

            final summary = ReviewPaymentQuoteCard(
              metrics: m,
              quote: state.quote,
              quoting: state.quoting,
            );

            final note = ReviewPaymentNoteSection(
              metrics: m,
              controller: _noteController,
              onChanged: (_) => setState(() {}),
            );

            final wallet = resolved['wallet'] as Map<String, dynamic>?;
            final method = ReviewPaymentMethodSection(
              metrics: m,
              enabled: state.canPay,
              subtitle:
                  reason ??
                  'Balance: ${wallet?['spendable'] ?? '0.00'} ${wallet?['currency'] ?? currency}',
            );

            final payBar = ReviewPaymentPayBar(
              metrics: m,
              isLoading: state.paying,
              isEnabled: state.canSubmit,
              onPay: _pay,
            );

            return Column(
              children: [
                Expanded(
                  child: Center(
                    child: ConstrainedBox(
                      constraints: BoxConstraints(maxWidth: m.maxContentWidth),
                      child: m.isLandscape
                          ? ReviewPaymentLandscapeBody(
                              metrics: m,
                              banner: banner,
                              merchant: merchant,
                              amount: amount,
                              summary: summary,
                              note: note,
                              method: method,
                              payBar: payBar,
                            )
                          : ReviewPaymentPortraitBody(
                              metrics: m,
                              banner: banner,
                              merchant: merchant,
                              amount: amount,
                              summary: summary,
                              note: note,
                              method: method,
                            ),
                    ),
                  ),
                ),

                if (!m.isLandscape)
                  Container(
                    padding: EdgeInsets.fromLTRB(
                      m.pageHPad,
                      m.gapSm,
                      m.pageHPad,
                      m.gapSm * 0.5,
                    ),
                    decoration: BoxDecoration(
                      color: colors.background,
                      border: Border(
                        top: BorderSide(color: colors.border, width: 1),
                      ),
                    ),
                    child: SafeArea(top: false, child: payBar),
                  ),
              ],
            );
          },
        ),
      ),
    );
  }
}
