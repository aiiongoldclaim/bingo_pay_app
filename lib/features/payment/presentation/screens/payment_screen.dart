import 'package:bingo_pay/core/constants/app_sizes.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/theme/theme_colors.dart';
import '../../../../core/widgets/bottom_action_bar.dart';
import '../../../../core/widgets/custom_app_bar.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_state.dart';
import '../../../cart/data/models/cart_model.dart';
import '../cubit/payment_cubit.dart';
import '../cubit/payment_state.dart';
import 'review_pay_screen.dart';
import 'widgets/payment_progress_stepper.dart';

class PaymentScreen extends StatefulWidget {
  final String? vendorEmail;
  final String productName;
  final double productPrice;
  final List<CartItemModel> cartItems;

  const PaymentScreen({
    super.key,
    this.vendorEmail,
    this.productName = '',
    this.productPrice = 0.0,
    this.cartItems = const [],
  });

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  final _nameCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _addressCtrl = TextEditingController();
  final _cityCtrl = TextEditingController();
  final _postalCtrl = TextEditingController();

  bool _submitted = false;

  bool get _nameValid => _nameCtrl.text.trim().length >= 2;
  bool get _phoneValid => _phoneCtrl.text.trim().length == 10;
  bool get _streetValid => _addressCtrl.text.trim().length >= 5;
  bool get _cityValid => _cityCtrl.text.trim().length >= 2;
  bool get _postalValid => _postalCtrl.text.trim().length == 6;

  bool get _addressValid =>
      _nameValid && _phoneValid && _streetValid && _cityValid && _postalValid;

  String? get _nameError => _submitted && !_nameValid ? 'Enter at least 2 characters' : null;
  String? get _phoneError => _submitted && !_phoneValid ? 'Enter a valid 10-digit number' : null;
  String? get _streetError => _submitted && !_streetValid ? 'Enter a valid address' : null;
  String? get _cityError => _submitted && !_cityValid ? 'Enter a valid city name' : null;
  String? get _postalError => _submitted && !_postalValid ? 'Enter a valid 6-digit PIN' : null;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _phoneCtrl.dispose();
    _addressCtrl.dispose();
    _cityCtrl.dispose();
    _postalCtrl.dispose();
    super.dispose();
  }

  void _onContinue(BuildContext context, PaymentMethodCubit cubit) {
    setState(() => _submitted = true);

    if (!_addressValid) return;

    cubit.updateDeliveryAddress(
      name: _nameCtrl.text.trim(),
      phone: _phoneCtrl.text.trim(),
      address: _addressCtrl.text.trim(),
      city: _cityCtrl.text.trim(),
      postal: _postalCtrl.text.trim(),
    );

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => BlocProvider.value(
          value: cubit,
          child: const ReviewPayScreen(),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authState = context.read<AuthBloc>().state;
    final userEmail =
        authState is AuthAuthenticated ? authState.user.email : '';

    final isCart = widget.cartItems.isNotEmpty;
    final cartTotal = isCart
        ? widget.cartItems.fold<double>(
            0.0, (s, i) => s + i.priceValue * i.quantity)
        : widget.productPrice;

    return BlocProvider(
      create: (_) => PaymentMethodCubit(
        productPrice: isCart ? cartTotal : widget.productPrice,
        productName: widget.productName,
        userEmail: userEmail,
        vendorEmail: widget.vendorEmail ?? '',
        cartItems: widget.cartItems,
      )..loadWalletBalance(userEmail),
      child: AnnotatedRegion<SystemUiOverlayStyle>(
        value: const SystemUiOverlayStyle(
          statusBarColor: AppColors.surface,
          statusBarIconBrightness: Brightness.dark,
        ),
        child: Scaffold(
          backgroundColor: AppColors.background,
          appBar: CustomAppBar(
            title: 'Payment',
            actionIcon1: Icons.security,
            onAction1: () {},
          ),
          bottomNavigationBar:
              BlocBuilder<PaymentMethodCubit, PaymentMethodState>(
            builder: (context, state) {
              return AppBottomActionBar(
                primaryLabel: 'Continue to Pay',
                secondaryLabel: 'Cancel',
                secondaryIcon: Icons.close,
                onPrimaryPressed: () => _onContinue(
                    context, context.read<PaymentMethodCubit>()),
                onSecondaryPressed: () => Navigator.pop(context),
              );
            },
          ),
          body: BlocBuilder<PaymentMethodCubit, PaymentMethodState>(
            builder: (context, state) {
              return SingleChildScrollView(
                padding: EdgeInsets.symmetric(horizontal: AppSizes.radiusMd),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const PaymentProgressStepper(currentStep: 3),
                    SizedBox(height: AppSizes.radiusSm),

                    // // Vendor Email (single-product flow only)
                    // if (!isCart && widget.vendorEmail != null) ...[
                    //   _VendorBadge(email: widget.vendorEmail!),
                    //   SizedBox(height: AppSizes.radiusSm),
                    // ],

                    // Cart items summary OR single product banner
                    if (isCart) ...[
                      _CartSummaryBanner(
                        items: widget.cartItems,
                        total:
                            '\$${cartTotal.toStringAsFixed(0)}',
                      ),
                      SizedBox(height: AppSizes.radiusSm),
                    ] else if (widget.productPrice > 0) ...[
                      _AmountBanner(
                        productName: widget.productName,
                        price: '\$${widget.productPrice.toStringAsFixed(0)}',
                      ),
                      SizedBox(height: AppSizes.radiusSm),
                    ],

                    // ── Delivery Address Form ──────────────────────────────
                    _AddressForm(
                      nameCtrl: _nameCtrl,
                      phoneCtrl: _phoneCtrl,
                      addressCtrl: _addressCtrl,
                      cityCtrl: _cityCtrl,
                      postalCtrl: _postalCtrl,
                      nameError: _nameError,
                      phoneError: _phoneError,
                      streetError: _streetError,
                      cityError: _cityError,
                      postalError: _postalError,
                      nameValid: _nameValid,
                      phoneValid: _phoneValid,
                      streetValid: _streetValid,
                      cityValid: _cityValid,
                      postalValid: _postalValid,
                      onChanged: () => setState(() {}),
                    ),

                    SizedBox(height: AppSizes.radiusMd),

                    // ── Bingo Wallet ───────────────────────────────────────
                    _WalletInfoCard(state: state),

                    const SizedBox(height: 24),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

// ── Bingo Wallet Info Card ───────────────────────────────────────────────────

class _WalletInfoCard extends StatelessWidget {
  final PaymentMethodState state;
  const _WalletInfoCard({required this.state});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: ThemeColors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: ThemeColors.blue.withValues(alpha: 0.08),
            blurRadius: 24,
            offset: const Offset(0, 6),
          ),
          BoxShadow(
            color: ThemeColors.ink.withValues(alpha: 0.03),
            blurRadius: 6,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF1A1D4E), Color(0xFF2B2FA8)],
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
              ),
              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(7),
                  decoration: BoxDecoration(
                    color: ThemeColors.white.withValues(alpha: 0.18),
                    borderRadius: BorderRadius.circular(9),
                  ),
                  child: const Icon(Icons.account_balance_wallet_outlined,
                      size: 17, color: ThemeColors.white),
                ),
                const SizedBox(width: 10),
                Text(
                  'Bingold Wallet',
                  style: AppTextStyles.titleMedium.copyWith(
                    color: ThemeColors.white,
                    letterSpacing: 0.3,
                  ),
                ),
                const Spacer(),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: ThemeColors.white.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.lock_outline,
                          size: 11, color: ThemeColors.white),
                      const SizedBox(width: 4),
                      Text(
                        'Secured',
                        style: AppTextStyles.labelSmall
                            .copyWith(color: ThemeColors.white),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Balances + coins
          Padding(
            padding: const EdgeInsets.all(18),
            child: Column(
              children: [
                _BalanceRow(
                  icon: Icons.currency_bitcoin,
                  label: 'Bigod Balance',
                  value: state.formattedBigoldBalance,
                  color: const Color(0xFFF7A928),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _BalanceRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;
  const _BalanceRow(
      {required this.icon,
      required this.label,
      required this.value,
      required this.color});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(7),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(9),
          ),
          child: Icon(icon, size: 15, color: color),
        ),
        const SizedBox(width: 10),
        Expanded(child: Text(label, style: AppTextStyles.bodyMedium)),
        Text(
          value,
          style: AppTextStyles.titleMedium
              .copyWith(fontWeight: FontWeight.w700),
        ),
      ],
    );
  }
}

// ── Amount Banner ───────────────────────────────────────────────────────────

class _AmountBanner extends StatelessWidget {
  final String productName;
  final String price;
  const _AmountBanner({required this.productName, required this.price});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: ThemeColors.blue.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
            color: ThemeColors.blue.withValues(alpha: 0.2)),
      ),
      child: Row(
        children: [
          Icon(Icons.shopping_bag_outlined,
              size: 20, color: ThemeColors.blue),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              productName.isNotEmpty ? productName : 'Product',
              style: AppTextStyles.bodyMedium
                  .copyWith(color: ThemeColors.ink),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Text(
            price,
            style: AppTextStyles.titleMedium.copyWith(
                color: ThemeColors.blue, fontWeight: FontWeight.w700),
          ),
        ],
      ),
    );
  }
}

// ── Cart Summary Banner ─────────────────────────────────────────────────────

class _CartSummaryBanner extends StatelessWidget {
  final List<CartItemModel> items;
  final String total;
  const _CartSummaryBanner({required this.items, required this.total});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: ThemeColors.blue.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: ThemeColors.blue.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.shopping_cart_outlined,
                  size: 18, color: ThemeColors.blue),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  '${items.length} item${items.length == 1 ? '' : 's'} in cart',
                  style: AppTextStyles.bodyMedium
                      .copyWith(color: ThemeColors.ink),
                ),
              ),
              Text(
                total,
                style: AppTextStyles.titleMedium.copyWith(
                    color: ThemeColors.blue, fontWeight: FontWeight.w700),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ...items.map((item) => Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Row(
                  children: [
                    const SizedBox(width: 26),
                    Expanded(
                      child: Text(
                        '${item.name} × ${item.quantity}',
                        style: AppTextStyles.bodySmall
                            .copyWith(color: ThemeColors.inkMid),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Text(
                      '\$${(item.priceValue * item.quantity).toStringAsFixed(0)}',
                      style: AppTextStyles.bodySmall
                          .copyWith(color: ThemeColors.inkMid),
                    ),
                  ],
                ),
              )),
        ],
      ),
    );
  }
}

// ── Address Form ────────────────────────────────────────────────────────────

class _AddressForm extends StatelessWidget {
  final TextEditingController nameCtrl;
  final TextEditingController phoneCtrl;
  final TextEditingController addressCtrl;
  final TextEditingController cityCtrl;
  final TextEditingController postalCtrl;
  final String? nameError;
  final String? phoneError;
  final String? streetError;
  final String? cityError;
  final String? postalError;
  final bool nameValid;
  final bool phoneValid;
  final bool streetValid;
  final bool cityValid;
  final bool postalValid;
  final VoidCallback onChanged;

  const _AddressForm({
    required this.nameCtrl,
    required this.phoneCtrl,
    required this.addressCtrl,
    required this.cityCtrl,
    required this.postalCtrl,
    this.nameError,
    this.phoneError,
    this.streetError,
    this.cityError,
    this.postalError,
    this.nameValid = false,
    this.phoneValid = false,
    this.streetValid = false,
    this.cityValid = false,
    this.postalValid = false,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: ThemeColors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: ThemeColors.blue.withValues(alpha: 0.07),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
          BoxShadow(
            color: ThemeColors.ink.withValues(alpha: 0.04),
            blurRadius: 6,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Header strip ──────────────────────────────────────────────
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF1A1D4E), Color(0xFF2B2FA8)],
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
              ),
              borderRadius: BorderRadius.vertical(
                  top: Radius.circular(20)),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: ThemeColors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.local_shipping_outlined,
                      size: 18, color: ThemeColors.white),
                ),
                const SizedBox(width: 10),
                Text(
                  'Delivery Address',
                  style: AppTextStyles.titleMedium
                      .copyWith(color: ThemeColors.white, letterSpacing: 0.3),
                ),
                const Spacer(),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: ThemeColors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    'Required',
                    style: AppTextStyles.labelSmall
                        .copyWith(color: ThemeColors.white),
                  ),
                ),
              ],
            ),
          ),

          // ── Fields ────────────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.all(18),
            child: Column(
              children: [
                _Field(
                  controller: nameCtrl,
                  label: 'Full Name',
                  hint: 'e.g. Rahul Sharma',
                  icon: Icons.person_outline_rounded,
                  errorText: nameError,
                  isValid: nameValid,
                  onChanged: onChanged,
                  textCapitalization: TextCapitalization.words,
                  maxLength: 50,
                ),
                const SizedBox(height: 14),
                _Field(
                  controller: phoneCtrl,
                  label: 'Mobile Number',
                  hint: 'e.g. 9876543210',
                  icon: Icons.phone_android_rounded,
                  keyboardType: TextInputType.phone,
                  errorText: phoneError,
                  isValid: phoneValid,
                  onChanged: onChanged,
                  maxLength: 10,
                  digitsOnly: true,
                ),
                const SizedBox(height: 14),
                _Field(
                  controller: addressCtrl,
                  label: 'Street Address',
                  hint: 'Flat / House no., Building, Street, Area',
                  icon: Icons.home_outlined,
                  maxLines: 2,
                  errorText: streetError,
                  isValid: streetValid,
                  onChanged: onChanged,
                  maxLength: 200,
                ),
                const SizedBox(height: 14),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      flex: 5,
                      child: _Field(
                        controller: cityCtrl,
                        label: 'City',
                        hint: 'e.g. Mumbai',
                        icon: Icons.location_city_rounded,
                        errorText: cityError,
                        isValid: cityValid,
                        onChanged: onChanged,
                        textCapitalization: TextCapitalization.words,
                        maxLength: 50,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      flex: 4,
                      child: _Field(
                        controller: postalCtrl,
                        label: 'PIN Code',
                        hint: '6 digits',
                        icon: Icons.pin_drop_outlined,
                        keyboardType: TextInputType.number,
                        errorText: postalError,
                        isValid: postalValid,
                        onChanged: onChanged,
                        maxLength: 6,
                        digitsOnly: true,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Field extends StatefulWidget {
  final TextEditingController controller;
  final String label;
  final String hint;
  final IconData icon;
  final TextInputType? keyboardType;
  final int maxLines;
  final String? errorText;
  final bool isValid;
  final VoidCallback onChanged;
  final int? maxLength;
  final bool digitsOnly;
  final TextCapitalization textCapitalization;

  const _Field({
    required this.controller,
    required this.label,
    required this.hint,
    required this.icon,
    this.keyboardType,
    this.maxLines = 1,
    this.errorText,
    this.isValid = false,
    required this.onChanged,
    this.maxLength,
    this.digitsOnly = false,
    this.textCapitalization = TextCapitalization.none,
  });

  @override
  State<_Field> createState() => _FieldState();
}

class _FieldState extends State<_Field> {
  final _focus = FocusNode();
  bool _isFocused = false;

  @override
  void initState() {
    super.initState();
    _focus.addListener(() => setState(() => _isFocused = _focus.hasFocus));
  }

  @override
  void dispose() {
    _focus.dispose();
    super.dispose();
  }

  bool get _isError => widget.errorText != null;
  bool get _isValid => !_isError && widget.isValid;

  Color get _borderColor {
    if (_isError) return ThemeColors.red;
    if (_isFocused) return ThemeColors.blue;
    if (_isValid) return ThemeColors.green;
    return const Color(0xFFDDE1E7);
  }

  Color get _fillColor {
    if (_isError) return const Color(0xFFFFF5F5);
    if (_isFocused) return const Color(0xFFF5F8FF);
    if (_isValid) return const Color(0xFFF4FBF7);
    return const Color(0xFFF8F9FB);
  }

  Color get _iconColor {
    if (_isError) return ThemeColors.red;
    if (_isFocused) return ThemeColors.blue;
    if (_isValid) return ThemeColors.green;
    return const Color(0xFFADB5BD);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: _isFocused
                ? ThemeColors.blue
                : _isError
                    ? ThemeColors.red
                    : const Color(0xFF6C757D),
            letterSpacing: 0.1,
          ),
        ),
        const SizedBox(height: 6),
        TextField(
          controller: widget.controller,
          focusNode: _focus,
          keyboardType: widget.keyboardType,
          maxLines: widget.maxLines,
          textCapitalization: widget.textCapitalization,
          inputFormatters: [
            if (widget.digitsOnly) FilteringTextInputFormatter.digitsOnly,
            if (widget.maxLength != null)
              LengthLimitingTextInputFormatter(widget.maxLength),
          ],
          onChanged: (_) {
            setState(() {});
            widget.onChanged();
          },
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Color(0xFF1A1D23),
          ),
          decoration: InputDecoration(
            hintText: widget.hint,
            hintStyle: const TextStyle(
              fontSize: 13,
              color: Color(0xFFADB5BD),
              fontWeight: FontWeight.w400,
            ),
            prefixIcon: Icon(widget.icon, size: 18, color: _iconColor),
            suffixIcon: _isValid
                ? Icon(Icons.check_circle_rounded,
                    size: 18, color: ThemeColors.green)
                : _isError
                    ? Icon(Icons.error_outline_rounded,
                        size: 18, color: ThemeColors.red)
                    : null,
            filled: true,
            fillColor: _fillColor,
            isDense: true,
            contentPadding: EdgeInsets.symmetric(
              horizontal: 14,
              vertical: widget.maxLines > 1 ? 14 : 13,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: _borderColor),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: _borderColor),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: _borderColor, width: 1.5),
            ),
          ),
        ),
        if (_isError) ...[
          const SizedBox(height: 4),
          Row(
            children: [
              const Icon(Icons.info_outline_rounded,
                  size: 12, color: ThemeColors.red),
              const SizedBox(width: 4),
              Text(
                widget.errorText!,
                style: const TextStyle(
                  fontSize: 11,
                  color: ThemeColors.red,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }
}
