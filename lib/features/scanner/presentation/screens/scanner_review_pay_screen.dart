import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:sizer/sizer.dart';

import '../../../../core/di/injection.dart';
import '../../../../core/router/app_routes.dart';
import '../../../../core/storage/secure_storage_service.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/theme/app_theme_colors.dart';
import '../../../../core/widgets/app_snackbar.dart';
import '../cubit/payment_cubit.dart';
import '../cubit/payment_state.dart';
import '../widgets/review_payment_metrics.dart';

/// UI-only payment method selection (cubit abhi method accept nahi karta)
enum ScanPayMethod { bigod, cod }

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

  static const double _maxAmount = 100000; // 1 Lakh USD
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
    final c = context.c;

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
        backgroundColor: c.background,
        resizeToAvoidBottomInset: true,
        body: SafeArea(
          bottom: false,
          child: Builder(
            builder: (context) {
              final m = ReviewPaymentMetrics.of(context);

              final banner = _SecureBanner(metrics: m);

              final merchant = _MerchantCard(
                metrics: m,
                name: _displayName,
                email: widget.merchantEmail,
                initials: _initials(_displayName),
              );

              final amount = _AmountSection(
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

              final convert = _ConvertCard(
                metrics: m,
                usdValue: _usdValue,
                bigodValue: _bigodValue,
                onSwap: () => _changeCurrency(
                  _selectedCurrency == "USD" ? "BIGOD" : "USD",
                ),
              );

              final note = _NoteSection(
                metrics: m,
                controller: _noteController,
                onChanged: (_) => setState(() {}),
              );

              final method = _PaymentMethodSection(
                metrics: m,
                selected: _selectedMethod,
                onSelect: (v) => setState(() => _selectedMethod = v),
              );

              final payBar = BlocBuilder<PaymentCubit, PaymentState>(
                builder: (context, state) {
                  final loading = state is PaymentLoading;
                  return _PayBar(
                    metrics: m,
                    isLoading: loading,
                    isEnabled: !loading && !_isOverLimit,
                    onPay: _pay,
                  );
                },
              );

              return Column(
                children: [
                  _PaymentTopBar(metrics: m),

                  Expanded(
                    child: Center(
                      child: ConstrainedBox(
                        constraints: BoxConstraints(
                          maxWidth: m.maxContentWidth,
                        ),
                        child: m.isLandscape
                            ? _LandscapeBody(
                          metrics: m,
                          banner: banner,
                          merchant: merchant,
                          amount: amount,
                          convert: convert,
                          note: note,
                          method: method,
                          payBar: payBar,
                        )
                            : _PortraitBody(
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
                        color: c.background,
                        border: Border(
                          top: BorderSide(color: c.border, width: 1),
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

// ── Top bar ────────────────────────────────────────────────────────────────
class _PaymentTopBar extends StatelessWidget {
  final ReviewPaymentMetrics metrics;

  const _PaymentTopBar({required this.metrics});

  @override
  Widget build(BuildContext context) {
    final colors = context.c;
    final m = metrics;

    return Padding(
      padding: EdgeInsets.fromLTRB(
        m.pageHPad * 0.4,
        m.pageVPad * 0.5,
        m.pageHPad,
        m.pageVPad * 0.5,
      ),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.pop(context),
            splashRadius: m.backIconSize * 1.2,
            icon: Icon(
              Icons.arrow_back_ios_rounded,
              size: m.backIconSize,
              color: colors.textPrimary,
            ),
          ),

          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'TheVaults',
                  style: AppTextStyles.titleLarge.copyWith(
                    color: colors.brand,
                    fontFamily: 'CormorantGaramond',
                    fontWeight: FontWeight.w600,
                    fontSize: m.logoSize,
                    height: 1.1,
                  ),
                ),
                SizedBox(height: m.gapXs * 0.5),
                Text(
                  'Scan & Pay',
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: colors.textSecondary,
                    fontFamily: 'Inter',
                    fontSize: m.logoSubSize,
                    height: 1.2,
                  ),
                ),
              ],
            ),
          ),

          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.verified_user_outlined,
                size: m.topIconSize,
                color: colors.brand,
              ),
              SizedBox(width: m.gapXs * 1.2),
              SizedBox(
                width: m.isTablet ? 84 : 18.5.w,
                child: Text(
                  'Secure\nPayments',
                  style: AppTextStyles.labelMedium.copyWith(
                    color: colors.brand,
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.w600,
                    fontSize: m.helperSize,
                    height: 1.25,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ── Portrait ───────────────────────────────────────────────────────────────
class _PortraitBody extends StatelessWidget {
  final ReviewPaymentMetrics metrics;
  final Widget banner;
  final Widget merchant;
  final Widget amount;
  final Widget convert;
  final Widget note;
  final Widget method;

  const _PortraitBody({
    required this.metrics,
    required this.banner,
    required this.merchant,
    required this.amount,
    required this.convert,
    required this.note,
    required this.method,
  });

  @override
  Widget build(BuildContext context) {
    final m = metrics;

    return SingleChildScrollView(
      padding: EdgeInsets.fromLTRB(m.pageHPad, m.gapSm, m.pageHPad, m.gapLg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          banner,
          SizedBox(height: m.gapMd),
          merchant,
          SizedBox(height: m.gapLg),
          amount,
          SizedBox(height: m.gapMd),
          convert,
          SizedBox(height: m.gapLg),
          note,
          SizedBox(height: m.gapLg),
          method,
        ],
      ),
    );
  }
}

// ── Landscape ──────────────────────────────────────────────────────────────
class _LandscapeBody extends StatelessWidget {
  final ReviewPaymentMetrics metrics;
  final Widget banner;
  final Widget merchant;
  final Widget amount;
  final Widget convert;
  final Widget note;
  final Widget method;
  final Widget payBar;

  const _LandscapeBody({
    required this.metrics,
    required this.banner,
    required this.merchant,
    required this.amount,
    required this.convert,
    required this.note,
    required this.method,
    required this.payBar,
  });

  @override
  Widget build(BuildContext context) {
    final m = metrics;

    return Padding(
      padding: EdgeInsets.fromLTRB(m.pageHPad, m.gapSm, m.pageHPad, 0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.only(bottom: m.gapLg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  banner,
                  SizedBox(height: m.gapMd),
                  merchant,
                  SizedBox(height: m.gapLg),
                  amount,
                  SizedBox(height: m.gapMd),
                  convert,
                ],
              ),
            ),
          ),

          SizedBox(width: m.gapLg),

          SizedBox(
            width: m.railWidth,
            child: SingleChildScrollView(
              padding: EdgeInsets.only(bottom: m.gapLg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  note,
                  SizedBox(height: m.gapLg),
                  method,
                  SizedBox(height: m.gapLg),
                  payBar,
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Secure banner ──────────────────────────────────────────────────────────
class _SecureBanner extends StatelessWidget {
  final ReviewPaymentMetrics metrics;

  const _SecureBanner({required this.metrics});

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    final m = metrics;

    return Container(
      padding: EdgeInsets.all(m.cardPad * 0.85),
      decoration: BoxDecoration(
        color: c.brandSoft,
        borderRadius: BorderRadius.circular(m.cardRadius),
      ),
      child: Row(
        children: [
          Container(
            width: m.bannerIconBox,
            height: m.bannerIconBox,
            decoration: BoxDecoration(
              color: c.surface.withValues(alpha: c.isDark ? 0.10 : 0.7),
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: Icon(
              Icons.lock_outline_rounded,
              size: m.bannerIconSize,
              color: c.brand,
            ),
          ),

          SizedBox(width: m.cardPad * 0.7),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Your payments are 100% safe and secure',
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.labelLarge.copyWith(
                    color: c.brand,
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.w700,
                    fontSize: m.bannerTitleSize,
                    height: 1.3,
                  ),
                ),
                SizedBox(height: m.gapXs * 0.6),
                Text(
                  '256-bit encrypted transactions',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: c.textSecondary,
                    fontFamily: 'Inter',
                    fontSize: m.bannerSubSize,
                    height: 1.3,
                  ),
                ),
              ],
            ),
          ),

          Icon(
            Icons.chevron_right_rounded,
            size: m.bannerTitleSize + 10,
            color: c.brand,
          ),
        ],
      ),
    );
  }
}

// ── Merchant ───────────────────────────────────────────────────────────────
class _MerchantCard extends StatelessWidget {
  final ReviewPaymentMetrics metrics;
  final String name;
  final String email;
  final String initials;

  const _MerchantCard({
    required this.metrics,
    required this.name,
    required this.email,
    required this.initials,
  });

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    final m = metrics;

    return Container(
      padding: EdgeInsets.all(m.cardPad),
      decoration: BoxDecoration(
        color: c.surface,
        borderRadius: BorderRadius.circular(m.cardRadius),
        border: Border.all(color: c.border, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: m.merchantAvatar,
                height: m.merchantAvatar,
                decoration: BoxDecoration(
                  color: c.brandSoft,
                  shape: BoxShape.circle,
                ),
                alignment: Alignment.center,
                child: Text(
                  initials,
                  style: AppTextStyles.titleLarge.copyWith(
                    color: c.brand,
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.w700,
                    fontSize: m.merchantInitialSize,
                  ),
                ),
              ),

              SizedBox(width: m.cardPad * 0.7),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.titleMedium.copyWith(
                        color: c.textPrimary,
                        fontFamily: 'Inter',
                        fontWeight: FontWeight.w700,
                        fontSize: m.merchantNameSize,
                        height: 1.25,
                      ),
                    ),
                    SizedBox(height: m.gapXs),
                    Text(
                      email,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: c.textSecondary,
                        fontFamily: 'Inter',
                        fontSize: m.merchantIdSize,
                        height: 1.3,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          SizedBox(height: m.gapMd),

          Row(
            children: [
              _Chip(
                metrics: m,
                icon: Icons.verified_rounded,
                label: 'Verified Merchant',
              ),
              SizedBox(width: m.gapSm),
              _Chip(
                metrics: m,
                icon: Icons.bolt_rounded,
                label: 'Instant Transfer',
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  final ReviewPaymentMetrics metrics;
  final IconData icon;
  final String label;

  const _Chip({
    required this.metrics,
    required this.icon,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    final m = metrics;

    return Flexible(
      child: Container(
        height: m.chipHeight,
        padding: EdgeInsets.symmetric(horizontal: m.gapSm * 1.1),
        decoration: BoxDecoration(
          color: c.brandSoft,
          borderRadius: BorderRadius.circular(m.chipHeight),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: m.chipFontSize + 4, color: c.brand),
            SizedBox(width: m.gapXs * 1.2),
            Flexible(
              child: Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppTextStyles.labelMedium.copyWith(
                  color: c.brand,
                  fontFamily: 'Inter',
                  fontWeight: FontWeight.w600,
                  fontSize: m.chipFontSize,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Section label ──────────────────────────────────────────────────────────
class _SectionLabel extends StatelessWidget {
  final ReviewPaymentMetrics metrics;
  final String label;

  const _SectionLabel({required this.metrics, required this.label});

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    final m = metrics;

    return Text(
      label,
      style: AppTextStyles.labelMedium.copyWith(
        color: c.textSecondary,
        fontFamily: 'Inter',
        fontWeight: FontWeight.w600,
        fontSize: m.sectionLabelSize,
        letterSpacing: 0.6,
      ),
    );
  }
}

// ── Amount (TextField — keyboard) ──────────────────────────────────────────
class _AmountSection extends StatelessWidget {
  final ReviewPaymentMetrics metrics;
  final TextEditingController controller;
  final String currency;
  final bool isOverLimit;
  final double maxAmount;
  final ValueChanged<String> onChanged;
  final VoidCallback onToggleCurrency;

  const _AmountSection({
    required this.metrics,
    required this.controller,
    required this.currency,
    required this.isOverLimit,
    required this.maxAmount,
    required this.onChanged,
    required this.onToggleCurrency,
  });

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    final m = metrics;
    final decimals = currency == "USD" ? 2 : 8;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        _SectionLabel(metrics: m, label: 'ENTER AMOUNT'),

        SizedBox(height: m.gapSm),

        Container(
          height: m.amountBoxHeight,
          decoration: BoxDecoration(
            color: c.surface,
            borderRadius: BorderRadius.circular(m.cardRadius * 0.8),
            border: Border.all(
              color: isOverLimit ? c.statusWarning : c.brand,
              width: 1.5,
            ),
          ),
          clipBehavior: Clip.antiAlias,
          child: Row(
            children: [
              Material(
                color: c.brandSoft,
                child: InkWell(
                  onTap: onToggleCurrency,
                  child: Container(
                    width: m.amountPrefixWidth,
                    height: double.infinity,
                    alignment: Alignment.center,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          currency,
                          style: AppTextStyles.titleMedium.copyWith(
                            color: c.brand,
                            fontFamily: 'Inter',
                            fontWeight: FontWeight.w700,
                            fontSize: m.currencySize,
                          ),
                        ),
                        SizedBox(width: m.gapXs),
                        Icon(
                          Icons.keyboard_arrow_down_rounded,
                          size: m.currencySize + 6,
                          color: c.brand,
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              Expanded(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: m.cardPad * 0.7),
                  child: TextField(
                    controller: controller,
                    onChanged: onChanged,
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(
                        RegExp(r'^\d*\.?\d{0,' '$decimals' r'}'),
                      ),
                    ],
                    style: AppTextStyles.displayLarge.copyWith(
                      color: c.textPrimary,
                      fontFamily: 'Inter',
                      fontWeight: FontWeight.w500,
                      fontSize: m.amountSize,
                      height: 1.1,
                    ),
                    decoration: InputDecoration(
                      hintText: '0.00',
                      hintStyle: AppTextStyles.displayLarge.copyWith(
                        color: c.textMuted,
                        fontFamily: 'Inter',
                        fontWeight: FontWeight.w400,
                        fontSize: m.amountSize,
                        height: 1.1,
                      ),
                      border: InputBorder.none,
                      enabledBorder: InputBorder.none,
                      focusedBorder: InputBorder.none,
                      isDense: true,
                      contentPadding: EdgeInsets.zero,
                    ),
                  ),
                ),
              ),

              Padding(
                padding: EdgeInsets.only(right: m.cardPad * 0.8),
                child: Text(
                  currency,
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: c.textMuted,
                    fontFamily: 'Inter',
                    fontSize: m.currencySize,
                  ),
                ),
              ),
            ],
          ),
        ),

        SizedBox(height: m.gapSm),

        if (isOverLimit)
          Row(
            children: [
              Icon(
                Icons.info_outline_rounded,
                size: m.helperSize + 3,
                color: c.statusWarning,
              ),
              SizedBox(width: m.gapXs),
              Expanded(
                child: Text(
                  'You can only send upto \$${maxAmount.toStringAsFixed(1)} at a time.',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: c.statusWarning,
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.w500,
                    fontSize: m.helperSize,
                  ),
                ),
              ),
            ],
          )
        else
          Text(
            'Minimum amount \$1.00',
            style: AppTextStyles.bodySmall.copyWith(
              color: c.textSecondary,
              fontFamily: 'Inter',
              fontSize: m.helperSize,
            ),
          ),
      ],
    );
  }
}

// ── Convert ────────────────────────────────────────────────────────────────
class _ConvertCard extends StatelessWidget {
  final ReviewPaymentMetrics metrics;
  final double usdValue;
  final double bigodValue;
  final VoidCallback onSwap;

  const _ConvertCard({
    required this.metrics,
    required this.usdValue,
    required this.bigodValue,
    required this.onSwap,
  });

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    final m = metrics;

    return Container(
      padding: EdgeInsets.all(m.cardPad),
      decoration: BoxDecoration(
        color: c.brandSoft,
        borderRadius: BorderRadius.circular(m.cardRadius),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Convert to BIGOD',
            style: AppTextStyles.labelLarge.copyWith(
              color: c.brand,
              fontFamily: 'Inter',
              fontWeight: FontWeight.w700,
              fontSize: m.bannerTitleSize,
            ),
          ),

          SizedBox(height: m.gapMd),

          Row(
            children: [
              Expanded(
                child: _ConvertBox(
                  metrics: m,
                  label: 'USD',
                  value: usdValue.toStringAsFixed(2),
                  badge: Container(
                    width: m.coinBadge,
                    height: m.coinBadge,
                    decoration: BoxDecoration(
                      color: c.statusInfo,
                      shape: BoxShape.circle,
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      '\$',
                      style: AppTextStyles.labelLarge.copyWith(
                        color: c.surface,
                        fontFamily: 'Inter',
                        fontWeight: FontWeight.w800,
                        fontSize: m.convertLabelSize + 2,
                      ),
                    ),
                  ),
                ),
              ),

              SizedBox(width: m.gapSm),

              Material(
                color: c.surface,
                shape: const CircleBorder(),
                clipBehavior: Clip.antiAlias,
                child: InkWell(
                  onTap: onSwap,
                  child: SizedBox(
                    width: m.swapBtnSize,
                    height: m.swapBtnSize,
                    child: Icon(
                      Icons.swap_horiz_rounded,
                      size: m.swapBtnSize * 0.5,
                      color: c.brand,
                    ),
                  ),
                ),
              ),

              SizedBox(width: m.gapSm),

              Expanded(
                child: _ConvertBox(
                  metrics: m,
                  label: 'BIGOD',
                  value: bigodValue.toStringAsFixed(8),
                  badge: Container(
                    width: m.coinBadge,
                    height: m.coinBadge,
                    decoration: BoxDecoration(
                      color: c.brand,
                      shape: BoxShape.circle,
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      'B',
                      style: AppTextStyles.labelLarge.copyWith(
                        color: const Color(0xFFF7A928),
                        fontFamily: 'Inter',
                        fontWeight: FontWeight.w800,
                        fontSize: m.convertLabelSize + 2,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),

          SizedBox(height: m.gapSm),

          Row(
            children: [
              Icon(
                Icons.info_outline_rounded,
                size: m.rateSize + 3,
                color: c.textMuted,
              ),
              SizedBox(width: m.gapXs),
              Expanded(
                child: Text(
                  '1 USD = 0.00001772 BIGOD',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.bodySmall.copyWith(
                    color: c.textSecondary,
                    fontFamily: 'Inter',
                    fontSize: m.rateSize,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ConvertBox extends StatelessWidget {
  final ReviewPaymentMetrics metrics;
  final String label;
  final String value;
  final Widget badge;

  const _ConvertBox({
    required this.metrics,
    required this.label,
    required this.value,
    required this.badge,
  });

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    final m = metrics;

    return Container(
      height: m.convertBoxHeight,
      padding: EdgeInsets.symmetric(horizontal: m.cardPad * 0.6),
      decoration: BoxDecoration(
        color: c.surface,
        borderRadius: BorderRadius.circular(m.cardRadius * 0.75),
      ),
      child: Row(
        children: [
          badge,
          SizedBox(width: m.gapSm * 0.8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  label,
                  style: AppTextStyles.bodySmall.copyWith(
                    color: c.textSecondary,
                    fontFamily: 'Inter',
                    fontSize: m.convertLabelSize,
                    height: 1.2,
                  ),
                ),
                SizedBox(height: m.gapXs * 0.5),
                FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: Text(
                    value,
                    style: AppTextStyles.titleMedium.copyWith(
                      color: c.textPrimary,
                      fontFamily: 'Inter',
                      fontWeight: FontWeight.w700,
                      fontSize: m.convertValueSize,
                      height: 1.2,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Note ───────────────────────────────────────────────────────────────────
class _NoteSection extends StatelessWidget {
  final ReviewPaymentMetrics metrics;
  final TextEditingController controller;
  final ValueChanged<String> onChanged;

  const _NoteSection({
    required this.metrics,
    required this.controller,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    final m = metrics;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        _SectionLabel(metrics: m, label: 'ADD NOTE (OPTIONAL)'),

        SizedBox(height: m.gapSm),

        Container(
          height: m.noteBoxHeight,
          padding: EdgeInsets.symmetric(horizontal: m.cardPad * 0.7),
          decoration: BoxDecoration(
            color: c.surface,
            borderRadius: BorderRadius.circular(m.cardRadius * 0.8),
            border: Border.all(color: c.border, width: 1),
          ),
          child: Row(
            children: [
              Icon(
                Icons.sticky_note_2_outlined,
                size: m.methodIconSize * 0.85,
                color: c.textSecondary,
              ),

              SizedBox(width: m.gapSm),

              Expanded(
                child: TextField(
                  controller: controller,
                  onChanged: onChanged,
                  maxLength: 50,
                  textCapitalization: TextCapitalization.sentences,
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: c.textPrimary,
                    fontFamily: 'Inter',
                    fontSize: m.methodTitleSize,
                  ),
                  decoration: InputDecoration(
                    hintText: 'What is this payment for?',
                    hintStyle: AppTextStyles.bodyMedium.copyWith(
                      color: c.textMuted,
                      fontFamily: 'Inter',
                      fontSize: m.methodTitleSize,
                    ),
                    counterText: '',
                    border: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    isDense: true,
                    contentPadding: EdgeInsets.zero,
                  ),
                ),
              ),

              SizedBox(width: m.gapSm),

              Text(
                '${controller.text.length}/50',
                style: AppTextStyles.bodySmall.copyWith(
                  color: c.textMuted,
                  fontFamily: 'Inter',
                  fontSize: m.helperSize,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// ── Payment method ─────────────────────────────────────────────────────────
class _PaymentMethodSection extends StatelessWidget {
  final ReviewPaymentMetrics metrics;
  final ScanPayMethod selected;
  final ValueChanged<ScanPayMethod> onSelect;

  const _PaymentMethodSection({
    required this.metrics,
    required this.selected,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    final m = metrics;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        _SectionLabel(metrics: m, label: 'PAYMENT METHOD'),

        SizedBox(height: m.gapSm),

        _MethodTile(
          metrics: m,
          icon: Icons.account_balance_wallet_outlined,
          title: 'BIGOD Wallet',
          subtitle: 'Pay using your BIGOD balance',
          isSelected: selected == ScanPayMethod.bigod,
          onTap: () => onSelect(ScanPayMethod.bigod),
        ),

        SizedBox(height: m.gapSm),

        _MethodTile(
          metrics: m,
          icon: Icons.payments_outlined,
          title: 'Cash on Delivery',
          subtitle: 'Pay with cash at the counter',
          isSelected: selected == ScanPayMethod.cod,
          onTap: () => onSelect(ScanPayMethod.cod),
        ),
      ],
    );
  }
}

class _MethodTile extends StatelessWidget {
  final ReviewPaymentMetrics metrics;
  final IconData icon;
  final String title;
  final String subtitle;
  final bool isSelected;
  final VoidCallback onTap;

  const _MethodTile({
    required this.metrics,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    final m = metrics;

    return Material(
      color: isSelected ? c.brandSoft : c.surface,
      borderRadius: BorderRadius.circular(m.cardRadius * 0.8),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Container(
          height: m.methodTileHeight,
          padding: EdgeInsets.symmetric(horizontal: m.cardPad * 0.8),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(m.cardRadius * 0.8),
            border: Border.all(
              color: isSelected ? c.brand : c.border,
              width: isSelected ? 1.5 : 1,
            ),
          ),
          child: Row(
            children: [
              Container(
                width: m.methodIconBox,
                height: m.methodIconBox,
                decoration: BoxDecoration(
                  color: isSelected
                      ? c.brand
                      : c.brandSoft,
                  shape: BoxShape.circle,
                ),
                alignment: Alignment.center,
                child: Icon(
                  icon,
                  size: m.methodIconSize,
                  color: isSelected ? c.surface : c.brand,
                ),
              ),

              SizedBox(width: m.cardPad * 0.7),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.labelLarge.copyWith(
                        color: c.textPrimary,
                        fontFamily: 'Inter',
                        fontWeight: FontWeight.w700,
                        fontSize: m.methodTitleSize,
                        height: 1.3,
                      ),
                    ),
                    SizedBox(height: m.gapXs * 0.6),
                    Text(
                      subtitle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.bodySmall.copyWith(
                        color: c.textSecondary,
                        fontFamily: 'Inter',
                        fontSize: m.methodSubSize,
                        height: 1.3,
                      ),
                    ),
                  ],
                ),
              ),

              Icon(
                isSelected
                    ? Icons.radio_button_checked_rounded
                    : Icons.radio_button_unchecked_rounded,
                size: m.radioSize,
                color: isSelected ? c.brand : c.textMuted,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Pay bar ────────────────────────────────────────────────────────────────
class _PayBar extends StatelessWidget {
  final ReviewPaymentMetrics metrics;
  final bool isLoading;
  final bool isEnabled;
  final VoidCallback onPay;

  const _PayBar({
    required this.metrics,
    required this.isLoading,
    required this.isEnabled,
    required this.onPay,
  });

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    final m = metrics;

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.verified_user_outlined,
              size: m.payNoteSize + 4,
              color: c.statusSuccess,
            ),
            SizedBox(width: m.gapXs),
            Flexible(
              child: Text(
                'Your payment details are secure with 256-bit encryption',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppTextStyles.bodySmall.copyWith(
                  color: c.textSecondary,
                  fontFamily: 'Inter',
                  fontSize: m.payNoteSize,
                ),
              ),
            ),
          ],
        ),

        SizedBox(height: m.gapSm),

        SizedBox(
          height: m.payHeight,
          child: Material(
            color: isEnabled ? c.brand : c.border,
            borderRadius: BorderRadius.circular(12),
            clipBehavior: Clip.antiAlias,
            child: InkWell(
              onTap: isEnabled ? onPay : null,
              child: Center(
                child: isLoading
                    ? SizedBox(
                  width: m.payFontSize + 4,
                  height: m.payFontSize + 4,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation(c.surface),
                  ),
                )
                    : Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Proceed to Pay',
                      style: AppTextStyles.buttonText.copyWith(
                        color: isEnabled ? c.surface : c.textMuted,
                        fontFamily: 'Inter',
                        fontWeight: FontWeight.w700,
                        fontSize: m.payFontSize,
                      ),
                    ),
                    SizedBox(width: m.gapSm),
                    Icon(
                      Icons.chevron_right_rounded,
                      size: m.payFontSize + 8,
                      color: isEnabled ? c.surface : c.textMuted,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}