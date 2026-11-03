import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/error/error_handler.dart';
import '../../../../core/router/app_routes.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/theme/app_theme_colors.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_loader.dart';
import '../../../../core/widgets/app_snackbar.dart';
import '../../../../core/widgets/custom_app_bar.dart';
import '../../data/tvs_qr_datasource.dart';
import '../cubit/payment_cubit.dart';
import '../cubit/payment_state.dart';
import '../widgets/review_payment_amount_section.dart';
import '../widgets/review_payment_merchant_card.dart';
import '../widgets/review_payment_metrics.dart';
import '../widgets/review_payment_note_section.dart';
import '../widgets/review_payment_pay_bar.dart';
import '../widgets/review_payment_quote_card.dart';
import 'wallet_mpin_screen.dart';

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

  // Pays. When the quote says this amount needs the MPIN, the MPIN screen
  // collects it first, and has the user create one if none is set.
  Future<void> _pay() async {
    final pin = context.read<PaymentCubit>().state.quote?['pin'] as Map?;
    if (pin?['required'] == true) {
      return _payWithMpin(isSet: pin!['isSet'] == true, length: pin['length']);
    }
    try {
      _paid(await _charge());
    } catch (e) {
      _failed(e);
    }
  }

  Future<Map<String, dynamic>> _charge([String? pin]) => context
      .read<PaymentCubit>()
      .pay(pin: pin, note: _noteController.text.trim());

  Future<void> _payWithMpin({required bool isSet, Object? length}) async {
    final cubit = context.read<PaymentCubit>();
    final quote = cubit.state.quote!;
    final outcome = await runWithMpin(
      context,
      isSet: isSet,
      length: length is int ? length : 4,
      subtitle:
          'Pay ${quote['payable']} ${quote['currency']} to '
          '${cubit.state.shop?['shop']?['name'] ?? 'this shop'}',
      attempt: _charge,
    );
    if (!mounted || outcome == null) return;
    final receipt = outcome.result;
    if (receipt != null) return _paid(receipt);
    _failed(outcome.failure!);
  }

  void _paid(Map<String, dynamic> receipt) {
    if (!mounted) return;
    AppSnackbar.showSuccess(context, 'Payment successful');
    context.push(
      AppRoutes.transferSuccess,
      extra: {
        'merchantName': context
            .read<PaymentCubit>()
            .state
            .shop?['shop']?['name'],
        'amount': receipt['paid'],
        'currency': receipt['currency'],
        'reference': receipt['transactionUuid'],
      },
    );
  }

  void _failed(Object e) {
    if (!mounted) return;
    if (e is! TvsQrException) {
      // Network drop or timeout: the idempotency key is kept, so tapping Pay
      // again retries this same payment and can't charge twice.
      return AppSnackbar.showError(
        context,
        ErrorHandler.mapObjectToFailure(e).message,
      );
    }
    switch (e.code) {
      // The PIN limit changed since the quote: ask for the MPIN now.
      case 'PIN_REQUIRED' || 'PIN_NOT_SET':
        _payWithMpin(isSet: e.code == 'PIN_REQUIRED');
      case 'QUOTE_CHANGED' || 'INSUFFICIENT_FUNDS':
        // Show the new price / shortfall; the user confirms again.
        AppSnackbar.showError(context, e.message);
        context.read<PaymentCubit>().requote();
      default:
        AppSnackbar.showError(context, e.message);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

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
            final wallet = resolved['wallet'] as Map<String, dynamic>?;
            final quote = state.quote;

            Widget column(List<Widget> children) => Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 480),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: children,
                ),
              ),
            );

            return Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    padding: EdgeInsets.symmetric(
                      horizontal: m.pageHPad,
                      vertical: m.gapLg,
                    ),
                    child: column([
                      ReviewPaymentMerchantCard(
                        metrics: m,
                        name: shopName,
                        subtitle: 'Accepts TVS Coins · $currency',
                        initials: _initials(shopName),
                      ),
                      SizedBox(height: m.gapLg),
                      ReviewPaymentAmountSection(
                        metrics: m,
                        controller: _amountController,
                        currency: currency,
                        error: reason ?? state.error,
                        autofocus: state.canPay,
                        onChanged: _onInputChanged,
                      ),
                      if (resolved['reasonCode'] == 'KYC_REQUIRED') ...[
                        SizedBox(height: m.gapMd),
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
                      SizedBox(height: m.gapSm),
                      ReviewPaymentQuoteCard(
                        metrics: m,
                        quote: quote,
                        quoting: state.quoting,
                      ),
                      SizedBox(height: m.gapLg),
                      Wrap(
                        alignment: WrapAlignment.center,
                        spacing: m.gapSm,
                        runSpacing: m.gapSm,
                        children: [
                          ReviewPaymentNoteSection(
                            metrics: m,
                            controller: _codeController,
                            onChanged: _onInputChanged,
                            label: 'Apply coupon',
                            hint: 'Coupon code',
                            icon: Icons.local_offer_outlined,
                            maxLength: 40,
                            capitalization: TextCapitalization.characters,
                          ),
                          ReviewPaymentNoteSection(
                            metrics: m,
                            controller: _noteController,
                            onChanged: (_) {},
                          ),
                        ],
                      ),
                    ]),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.fromLTRB(
                    m.pageHPad,
                    m.gapSm,
                    m.pageHPad,
                    m.gapSm,
                  ),
                  child: SafeArea(
                    top: false,
                    child: column([
                      Text(
                        'Paying from TVS Wallet · balance '
                        '${wallet?['spendable'] ?? '0.00'} '
                        '${wallet?['currency'] ?? currency}',
                        textAlign: TextAlign.center,
                        style: AppTextStyles.bodySmall.copyWith(
                          color: colors.textSecondary,
                          fontFamily: 'Inter',
                          fontSize: m.helperSize + 2,
                        ),
                      ),
                      SizedBox(height: m.gapSm),
                      ReviewPaymentPayBar(
                        metrics: m,
                        label: quote == null
                            ? 'Pay'
                            : 'Pay ${quote['payable']} ${quote['currency']}',
                        isLoading: state.paying,
                        isEnabled: state.canSubmit,
                        onPay: _pay,
                      ),
                    ]),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
