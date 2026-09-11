import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/di/injection.dart';
import '../../../../core/router/app_routes.dart';
import '../../../../core/storage/secure_storage_service.dart';
import '../../../../core/theme/app_theme_colors.dart';
import '../../../../core/widgets/app_snackbar.dart';
import '../../../../core/widgets/custom_app_bar.dart';
import '../cubit/payment_cubit.dart';
import '../cubit/payment_state.dart';
import '../widgets/review_payment_amount_section.dart';
import '../widgets/review_payment_banner.dart';
import '../widgets/review_payment_body.dart';
import '../widgets/review_payment_convert_card.dart';
import '../widgets/review_payment_merchant_card.dart';
import '../widgets/review_payment_method_section.dart';
import '../widgets/review_payment_metrics.dart';
import '../widgets/review_payment_note_section.dart';
import '../widgets/review_payment_pay_bar.dart';

class ReviewPaymentScreen extends StatefulWidget {
  final String? merchantName;
  final String merchantEmail;

  const ReviewPaymentScreen({
    super.key,
    required this.merchantName,
    required this.merchantEmail,
  });

  @override
  State<ReviewPaymentScreen> createState() => _ReviewPaymentScreenState();
}

class _ReviewPaymentScreenState extends State<ReviewPaymentScreen> {
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _noteController = TextEditingController();

  double _paymentAmount = 0;
  String _reference = "";

  static const double _maxAmount = 100000;
  static const double _minAmount = 1;

  static const double _usdToBigod = 0.00001772;
  String _selectedCurrency = "USD";

  ScanPayMethod _selectedMethod = ScanPayMethod.bigod;

  @override
  void dispose() {
    _amountController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  void _changeCurrency(String? value) {
    if (value == null || value == _selectedCurrency) return;

    double amount = double.tryParse(_amountController.text) ?? 0;

    if (_selectedCurrency == "USD" && value == "BIGOD") {
      amount *= _usdToBigod;
    } else if (_selectedCurrency == "BIGOD" && value == "USD") {
      amount /= _usdToBigod;
    }

    setState(() {
      _selectedCurrency = value;
      _amountController.text = amount.toStringAsFixed(value == "USD" ? 2 : 8);
    });
  }

  String get _displayName {
    final name = widget.merchantName;
    if (name != null && name.trim().isNotEmpty) return name.trim();
    return _deriveNameFromEmail(widget.merchantEmail);
  }

  String _deriveNameFromEmail(String email) {
    final namePart = email.split('@').first;
    final words = namePart
        .replaceAll(RegExp(r'[._\-0-9]+'), ' ')
        .trim()
        .split(RegExp(r'\s+'))
        .where((w) => w.isNotEmpty);
    if (words.isEmpty) return email;
    return words
        .map((w) => w[0].toUpperCase() + w.substring(1).toLowerCase())
        .join(' ');
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

  Future<void> _pay() async {
    final customerEmail = await getIt<SecureStorageService>().getEmail();
    if (!mounted) return;

    if (customerEmail == null) {
      AppSnackbar.showError(context, "Customer email not found");
      return;
    }

    final paymentAmount = double.tryParse(_amountController.text);

    if (paymentAmount == null) {
      AppSnackbar.showError(context, "Please enter a valid amount");
      return;
    }

    if (paymentAmount < _minAmount) {
      AppSnackbar.showError(context, "Minimum payment amount is \$1");
      return;
    }

    if (paymentAmount > _maxAmount) {
      AppSnackbar.showError(context, "Maximum payment amount is \$100,000");
      return;
    }

    _paymentAmount = paymentAmount;
    _reference = DateTime.now().millisecondsSinceEpoch.toString();

    context.read<PaymentCubit>().pay(
      customerEmail: customerEmail,
      merchantEmail: widget.merchantEmail,
      amount: _paymentAmount,
      reference: _reference,
    );
  }

  bool get _isOverLimit {
    final amount = double.tryParse(_amountController.text) ?? 0;
    return amount > _maxAmount;
  }

  double get _usdValue {
    final amount = double.tryParse(_amountController.text) ?? 0;
    return _selectedCurrency == "USD" ? amount : amount / _usdToBigod;
  }

  double get _bigodValue {
    final amount = double.tryParse(_amountController.text) ?? 0;
    return _selectedCurrency == "USD" ? amount * _usdToBigod : amount;
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.c;

    return BlocListener<PaymentCubit, PaymentState>(
      listener: (context, state) {
        if (state is PaymentSuccess) {
          AppSnackbar.showSuccess(context, "Payment Successful");
          context.push(
            AppRoutes.transferSuccess,
            extra: {
              "merchantName": _displayName,
              "amount": double.parse(_amountController.text),
              "reference": DateTime.now().millisecondsSinceEpoch.toString(),
            },
          );
        }

        if (state is PaymentFailure) {
          AppSnackbar.showError(context, state.message);
        }
      },
      child: Scaffold(
        backgroundColor: colors.background,
        resizeToAvoidBottomInset: true,
        appBar: const CustomAppBar(title: 'Scan & Pay'),
        body: SafeArea(
          bottom: false,
          child: Builder(
            builder: (context) {
              final m = ReviewPaymentMetrics.of(context);

              final banner = ReviewPaymentSecureBanner(metrics: m);

              final merchant = ReviewPaymentMerchantCard(
                metrics: m,
                name: _displayName,
                email: widget.merchantEmail,
                initials: _initials(_displayName),
              );

              final amount = ReviewPaymentAmountSection(
                metrics: m,
                controller: _amountController,
                currency: _selectedCurrency,
                isOverLimit: _isOverLimit,
                maxAmount: _maxAmount,
                onChanged: (_) => setState(() {}),
                onToggleCurrency: () => _changeCurrency(
                  _selectedCurrency == "USD" ? "BIGOD" : "USD",
                ),
              );

              final convert = ReviewPaymentConvertCard(
                metrics: m,
                usdValue: _usdValue,
                bigodValue: _bigodValue,
                onSwap: () => _changeCurrency(
                  _selectedCurrency == "USD" ? "BIGOD" : "USD",
                ),
              );

              final note = ReviewPaymentNoteSection(
                metrics: m,
                controller: _noteController,
                onChanged: (_) => setState(() {}),
              );

              final method = ReviewPaymentMethodSection(
                metrics: m,
                selected: _selectedMethod,
                onSelect: (v) => setState(() => _selectedMethod = v),
              );

              final payBar = BlocBuilder<PaymentCubit, PaymentState>(
                builder: (context, state) {
                  final loading = state is PaymentLoading;
                  return ReviewPaymentPayBar(
                    metrics: m,
                    isLoading: loading,
                    isEnabled: !loading && !_isOverLimit,
                    onPay: _pay,
                  );
                },
              );

              return Column(
                children: [
                  Expanded(
                    child: Center(
                      child: ConstrainedBox(
                        constraints: BoxConstraints(
                          maxWidth: m.maxContentWidth,
                        ),
                        child: m.isLandscape
                            ? ReviewPaymentLandscapeBody(
                                metrics: m,
                                banner: banner,
                                merchant: merchant,
                                amount: amount,
                                convert: convert,
                                note: note,
                                method: method,
                                payBar: payBar,
                              )
                            : ReviewPaymentPortraitBody(
                                metrics: m,
                                banner: banner,
                                merchant: merchant,
                                amount: amount,
                                convert: convert,
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
      ),
    );
  }
}
