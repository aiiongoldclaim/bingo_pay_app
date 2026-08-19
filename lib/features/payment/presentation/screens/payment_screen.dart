import 'package:bingo_pay/features/payment/presentation/screens/widgets/payment_metrics.dart';
import 'package:bingo_pay/features/payment/presentation/screens/widgets/payment_progress_stepper.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/services.dart';

import '../../../../core/di/injection.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/theme/app_theme_colors.dart';
import '../../../address/domain/entities/address_entity.dart';
import '../../../address/domain/repositories/address_respository.dart';
import '../../../address/presentation/cubit/address_cubit.dart';
import '../../../address/presentation/cubit/address_state.dart';
import '../../../address/presentation/screens/add_edit_address_screen.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_state.dart';
import '../../../cart/domain/entities/cart_item_entity.dart';

import '../cubit/payment_cubit.dart';
import '../cubit/payment_state.dart';

import 'review_pay_screen.dart';

class PaymentScreen extends StatefulWidget {
  final String? vendorEmail;
  final String productName;
  final double productPrice;
  final String? variantUuid;
  final int quantity;
  final List<CartItemEntity> cartItems;
  final bool isCart;

  const PaymentScreen({
    super.key,
    this.vendorEmail,
    this.productName = '',
    this.productPrice = 0.0,
    this.variantUuid,
    this.quantity = 1,
    this.cartItems = const [],
    required this.isCart,
  });

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  String? _selectedAddressId;
  AddressEntity? _selectedAddress;

  bool _submitted = false;

  late final AddressCubit _addressCubit;
  late final PaymentMethodCubit _paymentCubit;

  @override
  void initState() {
    super.initState();
    _addressCubit = AddressCubit(getIt<AddressRepository>())
      ..loadUserAddresses();
  }

  void _initPaymentCubit(String userEmail, bool isCart, double cartTotal) {
    _paymentCubit = PaymentMethodCubit(
      productPrice: cartTotal,
      productName: widget.productName,
      userEmail: userEmail,
      vendorEmail: widget.vendorEmail ?? '',
      variantUuid: widget.variantUuid,
      quantity: widget.quantity,
      cartItems: widget.cartItems,
    )..loadWalletBalance(userEmail);
  }

  @override
  void dispose() {
    _addressCubit.close();
    _paymentCubit.close();
    super.dispose();
  }

  void _selectAddress(AddressEntity addr) {
    setState(() {
      _selectedAddressId = addr.id;
      _selectedAddress = addr;
    });
  }

  void _onAddressDeleted(AddressEntity addr) {
    if (_selectedAddressId != addr.id) return;

    setState(() {
      _selectedAddressId = null;
      _selectedAddress = null;
    });
  }

  void _onContinue(BuildContext context, PaymentMethodCubit cubit) {
    setState(() => _submitted = true);

    if (_selectedAddress == null) return;

    cubit.updateDeliveryAddress(
      name: _selectedAddress!.fullName,
      phone: _selectedAddress!.phoneNumber,
      address: _selectedAddress!.addressLine1,
      city: _selectedAddress!.city,
      postal: _selectedAddress!.postalCode,
      addressId: _selectedAddress!.id,
    );

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => BlocProvider.value(
          value: cubit,
          child: ReviewPayScreen(isCart: widget.isCart),
        ),
      ),
    );
  }

  bool _paymentCubitInitialized = false;

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    final m = PaymentMetrics.of(context);

    final authState = context.read<AuthBloc>().state;
    final userEmail = authState is AuthAuthenticated
        ? authState.user.email
        : '';

    final isCart = widget.cartItems.isNotEmpty;
    final cartTotal = isCart
        ? widget.cartItems.fold<double>(0.0, (s, i) => s + i.totalPrice)
        : widget.productPrice * widget.quantity;

    if (!_paymentCubitInitialized) {
      _initPaymentCubit(userEmail, isCart, cartTotal);
      _paymentCubitInitialized = true;
    }

    return MultiBlocProvider(
      providers: [
        BlocProvider<AddressCubit>.value(value: _addressCubit),
        BlocProvider<PaymentMethodCubit>.value(value: _paymentCubit),
      ],
      child: AnnotatedRegion<SystemUiOverlayStyle>(
        value: SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: c.isDark
              ? Brightness.light
              : Brightness.dark,
          statusBarBrightness: c.isDark ? Brightness.dark : Brightness.light,
        ),
        child: BlocListener<AddressCubit, AddressState>(
          listener: (context, addrState) {
            if (addrState is AddressListLoaded &&
                addrState.addresses.isNotEmpty &&
                _selectedAddressId == null) {
              final defaultAddr = addrState.addresses.firstWhere(
                (a) => a.isDefaultAddress,
                orElse: () => addrState.addresses.first,
              );
              _selectAddress(defaultAddr);
            }
          },
          child: Scaffold(
            backgroundColor: c.background,
            body: SafeArea(
              bottom: false,
              child: BlocBuilder<PaymentMethodCubit, PaymentMethodState>(
                builder: (context, state) {
                  final summary = _OrderSummaryCard(
                    metrics: m,
                    isCart: isCart,
                    items: widget.cartItems,
                    productName: widget.quantity > 1
                        ? '${widget.productName} × ${widget.quantity}'
                        : widget.productName,
                    total: cartTotal,
                  );

                  final continueBar = _ContinueBar(
                    metrics: m,
                    isEnabled: _selectedAddress != null,
                    total: cartTotal,
                    onPressed: () => _onContinue(
                      context,
                      context.read<PaymentMethodCubit>(),
                    ),
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
                                    state: state,
                                    submitted: _submitted,
                                    selectedAddressId: _selectedAddressId,
                                    selectedAddress: _selectedAddress,
                                    onSelect: _selectAddress,
                                    onDeleted: _onAddressDeleted,
                                    summary: summary,
                                    continueBar: continueBar,
                                  )
                                : _PortraitBody(
                                    metrics: m,
                                    state: state,
                                    submitted: _submitted,
                                    selectedAddressId: _selectedAddressId,
                                    selectedAddress: _selectedAddress,
                                    onSelect: _selectAddress,
                                    onDeleted: _onAddressDeleted,
                                    summary: summary,
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
                          child: SafeArea(top: false, child: continueBar),
                        ),
                    ],
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ── Top bar ────────────────────────────────────────────────────────────────
class _PaymentTopBar extends StatelessWidget {
  final PaymentMetrics metrics;

  const _PaymentTopBar({required this.metrics});

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    final m = metrics;

    return Padding(
      padding: EdgeInsets.fromLTRB(
        m.pageHPad * 0.4,
        m.pageVPad * 0.4,
        m.pageHPad * 0.6,
        m.pageVPad * 0.4,
      ),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.pop(context),
            splashRadius: m.backIconSize * 1.2,
            icon: Icon(
              Icons.arrow_back_ios_rounded,
              size: m.backIconSize + 4,
              color: c.textPrimary,
            ),
          ),
          Expanded(
            child: Center(
              child: Text(
                'TheVaults',
                style: AppTextStyles.titleLarge.copyWith(
                  color: c.brand,
                  fontFamily: 'CormorantGaramond',
                  fontWeight: FontWeight.w600,
                  fontSize: m.logoSize,
                  height: 1.1,
                ),
              ),
            ),
          ),
          IconButton(
            onPressed: () {},
            splashRadius: m.topIconSize * 1.2,
            icon: Icon(
              Icons.lock_outline_rounded,
              size: m.topIconSize + 2,
              color: c.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Portrait ───────────────────────────────────────────────────────────────
class _PortraitBody extends StatelessWidget {
  final PaymentMetrics metrics;
  final PaymentMethodState state;
  final bool submitted;
  final String? selectedAddressId;
  final AddressEntity? selectedAddress;
  final ValueChanged<AddressEntity> onSelect;
  final ValueChanged<AddressEntity> onDeleted;
  final Widget summary;

  const _PortraitBody({
    required this.metrics,
    required this.state,
    required this.submitted,
    required this.selectedAddressId,
    required this.selectedAddress,
    required this.onSelect,
    required this.onDeleted,
    required this.summary,
  });

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    final m = metrics;

    return SingleChildScrollView(
      padding: EdgeInsets.fromLTRB(m.pageHPad, m.gapSm, m.pageHPad, m.gapLg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Checkout',
            style: AppTextStyles.titleLarge.copyWith(
              color: c.textPrimary,
              fontFamily: 'Inter',
              fontWeight: FontWeight.w700,
              fontSize: m.sectionTitleSize + 4,
            ),
          ),
          SizedBox(height: m.gapMd),
          const PaymentProgressStepper(currentStep: 3),
          SizedBox(height: m.gapLg),
          _AddressSelectionSection(
            metrics: m,
            selectedAddressId: selectedAddressId,
            onSelect: onSelect,
            onDeleted: onDeleted,
            showError: submitted && selectedAddress == null,
          ),
          SizedBox(height: m.gapMd),
          _WalletInfoCard(state: state, metrics: m),
          SizedBox(height: m.gapMd),
          summary,
        ],
      ),
    );
  }
}

// ── Landscape: address+wallet left, summary rail right ─────────────────────
class _LandscapeBody extends StatelessWidget {
  final PaymentMetrics metrics;
  final PaymentMethodState state;
  final bool submitted;
  final String? selectedAddressId;
  final AddressEntity? selectedAddress;
  final ValueChanged<AddressEntity> onSelect;
  final ValueChanged<AddressEntity> onDeleted;
  final Widget summary;
  final Widget continueBar;

  const _LandscapeBody({
    required this.metrics,
    required this.state,
    required this.submitted,
    required this.selectedAddressId,
    required this.selectedAddress,
    required this.onSelect,
    required this.onDeleted,
    required this.summary,
    required this.continueBar,
  });

  @override
  Widget build(BuildContext context) {
    final c = context.c;
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
                  Text(
                    'Checkout',
                    style: AppTextStyles.titleLarge.copyWith(
                      color: c.textPrimary,
                      fontFamily: 'Inter',
                      fontWeight: FontWeight.w700,
                      fontSize: m.sectionTitleSize + 3,
                    ),
                  ),
                  SizedBox(height: m.gapMd),
                  const PaymentProgressStepper(currentStep: 3),
                  SizedBox(height: m.gapLg),
                  _AddressSelectionSection(
                    metrics: m,
                    selectedAddressId: selectedAddressId,
                    onSelect: onSelect,
                    onDeleted: onDeleted,
                    showError: submitted && selectedAddress == null,
                  ),
                  SizedBox(height: m.gapMd),
                  _WalletInfoCard(state: state, metrics: m),
                ],
              ),
            ),
          ),

          SizedBox(width: m.gapLg),

          SizedBox(
            width: m.railWidth,
            child: SingleChildScrollView(
              padding: EdgeInsets.only(top: m.gapSm, bottom: m.gapLg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  summary,
                  SizedBox(height: m.gapMd),
                  continueBar,
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Order Summary (cart list + total) ──────────────────────────────────────
class _OrderSummaryCard extends StatelessWidget {
  final PaymentMetrics metrics;
  final bool isCart;
  final List<CartItemEntity> items;
  final String productName;
  final double total;

  const _OrderSummaryCard({
    required this.metrics,
    required this.isCart,
    required this.items,
    required this.productName,
    required this.total,
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
        boxShadow: c.isDark
            ? null
            : [
                BoxShadow(
                  color: c.textPrimary.withValues(alpha: 0.04),
                  blurRadius: 14,
                  offset: const Offset(0, 3),
                ),
              ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Order Summary',
            style: AppTextStyles.titleMedium.copyWith(
              color: c.textPrimary,
              fontFamily: 'Inter',
              fontWeight: FontWeight.w700,
              fontSize: m.sectionTitleSize,
            ),
          ),

          SizedBox(height: m.gapMd),

          if (isCart)
            ...items.map(
              (item) => Padding(
                padding: EdgeInsets.only(bottom: m.gapSm),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        '${item.product.title} × ${item.quantity}',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: c.textSecondary,
                          fontFamily: 'Inter',
                          fontSize: m.summaryLabelSize,
                        ),
                      ),
                    ),
                    SizedBox(width: m.gapSm),
                    Text(
                      '\$${item.totalPrice.toStringAsFixed(2)}',
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: c.textPrimary,
                        fontFamily: 'Inter',
                        fontWeight: FontWeight.w600,
                        fontSize: m.summaryValueSize,
                      ),
                    ),
                  ],
                ),
              ),
            )
          else
            Padding(
              padding: EdgeInsets.only(bottom: m.gapSm),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      productName.isNotEmpty ? productName : 'Product',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: c.textSecondary,
                        fontFamily: 'Inter',
                        fontSize: m.summaryLabelSize,
                      ),
                    ),
                  ),
                  SizedBox(width: m.gapSm),
                  Text(
                    '\$${total.toStringAsFixed(2)}',
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: c.textPrimary,
                      fontFamily: 'Inter',
                      fontWeight: FontWeight.w600,
                      fontSize: m.summaryValueSize,
                    ),
                  ),
                ],
              ),
            ),

          Padding(
            padding: EdgeInsets.only(bottom: m.gapSm),
            child: Row(
              children: [
                Expanded(
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Flexible(
                        child: Text(
                          'Shipping Fee',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppTextStyles.bodyMedium.copyWith(
                            color: c.textSecondary,
                            fontFamily: 'Inter',
                            fontSize: m.summaryLabelSize,
                          ),
                        ),
                      ),
                      SizedBox(width: m.gapXs),
                      Icon(
                        Icons.info_outline_rounded,
                        size: m.summaryLabelSize + 2,
                        color: c.textMuted,
                      ),
                    ],
                  ),
                ),
                SizedBox(width: m.gapSm),
                Text(
                  'FREE',
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: c.statusSuccess,
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.w600,
                    fontSize: m.summaryValueSize,
                  ),
                ),
              ],
            ),
          ),

          Padding(
            padding: EdgeInsets.symmetric(vertical: m.gapSm * 0.6),
            child: Divider(height: 1, thickness: 1, color: c.border),
          ),

          Row(
            children: [
              Expanded(
                child: Text(
                  'Total Amount',
                  style: AppTextStyles.titleMedium.copyWith(
                    color: c.textPrimary,
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.w700,
                    fontSize: m.totalLabelSize,
                  ),
                ),
              ),
              Text(
                '\$${total.toStringAsFixed(2)}',
                textAlign: TextAlign.right,
                style: AppTextStyles.titleLarge.copyWith(
                  color: c.brand,
                  fontFamily: 'Inter',
                  fontWeight: FontWeight.w800,
                  fontSize: m.totalValueSize,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ── Continue bar ───────────────────────────────────────────────────────────
class _ContinueBar extends StatelessWidget {
  final PaymentMetrics metrics;
  final bool isEnabled;
  final double total;
  final VoidCallback onPressed;

  const _ContinueBar({
    required this.metrics,
    required this.isEnabled,
    required this.total,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    final m = metrics;

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SizedBox(
          height: m.payHeight,
          child: Material(
            color: isEnabled ? c.brand : c.border,
            borderRadius: BorderRadius.circular(12),
            clipBehavior: Clip.antiAlias,
            child: InkWell(
              onTap: isEnabled ? onPressed : null,
              child: Center(
                child: Text(
                  'CONTINUE TO PAY  •  \$${total.toStringAsFixed(2)}',
                  style: AppTextStyles.buttonText.copyWith(
                    color: isEnabled ? c.surface : c.textMuted,
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.w700,
                    fontSize: m.payFontSize,
                    letterSpacing: 0.4,
                  ),
                ),
              ),
            ),
          ),
        ),
        SizedBox(height: m.gapSm * 0.7),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.lock_outline_rounded,
              size: m.payNoteSize + 3,
              color: c.textMuted,
            ),
            SizedBox(width: m.gapXs),
            Flexible(
              child: Text(
                'Secure Payments. Easy Returns. 100% Authentic.',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppTextStyles.bodySmall.copyWith(
                  color: c.textMuted,
                  fontFamily: 'Inter',
                  fontSize: m.payNoteSize,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

// ── Address Selection Section ──────────────────────────────────────────────
class _AddressSelectionSection extends StatelessWidget {
  final PaymentMetrics metrics;
  final String? selectedAddressId;
  final ValueChanged<AddressEntity> onSelect;
  final ValueChanged<AddressEntity> onDeleted;
  final bool showError;

  const _AddressSelectionSection({
    required this.metrics,
    required this.selectedAddressId,
    required this.onSelect,
    required this.onDeleted,
    this.showError = false,
  });

  Future<void> _openAddEdit(
    BuildContext context,
    AddressEntity? existing,
  ) async {
    final cubit = context.read<AddressCubit>();
    final result = await Navigator.push<AddressEntity>(
      context,
      MaterialPageRoute(
        builder: (_) => BlocProvider.value(
          value: cubit,
          child: AddEditAddressScreen(existingAddress: existing),
        ),
      ),
    );

    if (result != null) {
      onSelect(result);
    }
  }

  Future<void> _deleteAddress(
    BuildContext context,
    AddressEntity address,
  ) async {
    final c = context.c;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: c.surface,
        title: Text(
          'Delete address?',
          style: AppTextStyles.titleMedium.copyWith(color: c.textPrimary),
        ),
        content: Text(
          'Remove ${address.fullName.isNotEmpty ? address.fullName : 'this address'} from your saved addresses?',
          style: AppTextStyles.bodyMedium.copyWith(color: c.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: Text('Cancel', style: TextStyle(color: c.textSecondary)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: Text('Delete', style: TextStyle(color: c.statusWarning)),
          ),
        ],
      ),
    );

    if (confirmed != true || !context.mounted) return;

    final cubit = context.read<AddressCubit>();
    await cubit.removeAddress(address.id);

    if (!context.mounted) return;

    final state = cubit.state;
    if (state is AddressError) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(state.errorMessage)));
      return;
    }

    onDeleted(address);
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Address deleted')));
  }

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    final m = metrics;

    return Container(
      padding: EdgeInsets.all(m.cardPad),
      decoration: BoxDecoration(
        color: c.surface,
        borderRadius: BorderRadius.circular(m.cardRadius),
        border: Border.all(
          color: showError ? c.statusWarning : c.border,
          width: 1,
        ),
        boxShadow: c.isDark
            ? null
            : [
                BoxShadow(
                  color: c.textPrimary.withValues(alpha: 0.04),
                  blurRadius: 14,
                  offset: const Offset(0, 3),
                ),
              ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Container(
                width: m.walletIconBox * 0.8,
                height: m.walletIconBox * 0.8,
                decoration: BoxDecoration(
                  color: c.brandSoft,
                  shape: BoxShape.circle,
                ),
                alignment: Alignment.center,
                child: Icon(
                  Icons.local_shipping_outlined,
                  size: m.walletIconSize * 0.8,
                  color: c.brand,
                ),
              ),
              SizedBox(width: m.gapSm),
              Expanded(
                child: Text(
                  'Delivery Address',
                  style: AppTextStyles.titleMedium.copyWith(
                    color: c.textPrimary,
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.w700,
                    fontSize: m.sectionTitleSize,
                  ),
                ),
              ),
            ],
          ),

          SizedBox(height: m.gapMd),

          BlocBuilder<AddressCubit, AddressState>(
            builder: (context, state) {
              if (state is AddressLoading) {
                return _AddressSkeletonLoader(metrics: m);
              }

              if (state is AddressError) {
                return _AddressErrorRetry(
                  metrics: m,
                  message: state.errorMessage.isNotEmpty
                      ? state.errorMessage
                      : 'Could not load addresses',
                  onRetry: () =>
                      context.read<AddressCubit>().loadUserAddresses(),
                );
              }

              if (state is AddressListLoaded) {
                final addresses = state.addresses;

                if (addresses.isEmpty) {
                  return EmptyAddressWidget(
                    metrics: m,
                    onAddPressed: () => _openAddEdit(context, null),
                  );
                }

                final shown = addresses.take(3).toList();

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    ...shown.map(
                      (addr) => Padding(
                        padding: EdgeInsets.only(bottom: m.gapSm),
                        child: AddressCard(
                          metrics: m,
                          address: addr,
                          isSelected: addr.id == selectedAddressId,
                          onTap: () => onSelect(addr),
                          onEdit: () => _openAddEdit(context, addr),
                          onDelete: () => _deleteAddress(context, addr),
                        ),
                      ),
                    ),
                    if (shown.length < 3)
                      _AddNewAddressButton(
                        metrics: m,
                        onTap: () => _openAddEdit(context, null),
                      ),
                    if (showError) ...[
                      SizedBox(height: m.gapSm),
                      Row(
                        children: [
                          Icon(
                            Icons.info_outline_rounded,
                            size: m.addrChipSize + 2,
                            color: c.statusWarning,
                          ),
                          SizedBox(width: m.gapXs),
                          Text(
                            'Please select a delivery address',
                            style: AppTextStyles.bodySmall.copyWith(
                              color: c.statusWarning,
                              fontFamily: 'Inter',
                              fontWeight: FontWeight.w500,
                              fontSize: m.addrChipSize + 1,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                );
              }

              return _AddressSkeletonLoader(metrics: m);
            },
          ),
        ],
      ),
    );
  }
}

// ── Address Card ───────────────────────────────────────────────────────────
class AddressCard extends StatelessWidget {
  final PaymentMetrics metrics;
  final AddressEntity address;
  final bool isSelected;
  final VoidCallback onTap;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const AddressCard({
    super.key,
    required this.metrics,
    required this.address,
    required this.isSelected,
    required this.onTap,
    required this.onEdit,
    required this.onDelete,
  });

  String _formatAddress(AddressEntity a) {
    final parts = [
      a.addressLine1,
      a.city,
      a.state,
      a.postalCode,
    ].where((p) => p.trim().isNotEmpty);
    return parts.join(', ');
  }

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    final m = metrics;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeOut,
      decoration: BoxDecoration(
        color: isSelected ? c.brandSoft : c.surfaceAlt,
        borderRadius: BorderRadius.circular(m.addrRadius),
        border: Border.all(
          color: isSelected ? c.brand : c.border,
          width: isSelected ? 1.5 : 1,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(m.addrRadius),
          onTap: onTap,
          child: Padding(
            padding: EdgeInsets.all(m.addrPad),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  isSelected
                      ? Icons.check_circle_rounded
                      : Icons.circle_outlined,
                  size: m.addrRadioSize,
                  color: isSelected ? c.brand : c.textMuted,
                ),
                SizedBox(width: m.gapSm),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        children: [
                          Flexible(
                            child: Text(
                              address.fullName,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: AppTextStyles.labelLarge.copyWith(
                                color: c.textPrimary,
                                fontFamily: 'Inter',
                                fontWeight: FontWeight.w700,
                                fontSize: m.addrNameSize,
                              ),
                            ),
                          ),
                          if (address.isDefaultAddress)
                            Container(
                              margin: EdgeInsets.only(left: m.gapXs * 1.5),
                              padding: EdgeInsets.symmetric(
                                horizontal: m.gapSm * 0.8,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: c.brand.withValues(alpha: 0.12),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                'Default',
                                style: AppTextStyles.labelMedium.copyWith(
                                  color: c.brand,
                                  fontFamily: 'Inter',
                                  fontWeight: FontWeight.w600,
                                  fontSize: m.addrChipSize,
                                ),
                              ),
                            ),
                        ],
                      ),
                      SizedBox(height: m.gapXs),
                      Text(
                        address.phoneNumber,
                        style: AppTextStyles.bodySmall.copyWith(
                          color: c.textSecondary,
                          fontFamily: 'Inter',
                          fontSize: m.addrBodySize,
                        ),
                      ),
                      SizedBox(height: m.gapXs * 0.6),
                      Text(
                        _formatAddress(address),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: AppTextStyles.bodySmall.copyWith(
                          color: c.textSecondary,
                          fontFamily: 'Inter',
                          fontSize: m.addrBodySize,
                          height: 1.35,
                        ),
                      ),
                      if (isSelected) ...[
                        SizedBox(height: m.gapXs),
                        Text(
                          'Deliver to this address',
                          style: AppTextStyles.labelMedium.copyWith(
                            color: c.brand,
                            fontFamily: 'Inter',
                            fontWeight: FontWeight.w600,
                            fontSize: m.addrChipSize + 1,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: Icon(
                        Icons.edit_outlined,
                        size: m.addrActionIcon,
                        color: c.textMuted,
                      ),
                      onPressed: onEdit,
                      splashRadius: m.addrActionIcon,
                      constraints: const BoxConstraints(),
                      padding: EdgeInsets.only(left: m.gapSm, bottom: m.gapSm),
                    ),
                    IconButton(
                      icon: Icon(
                        Icons.delete_outline_rounded,
                        size: m.addrActionIcon,
                        color: c.statusWarning,
                      ),
                      onPressed: onDelete,
                      splashRadius: m.addrActionIcon,
                      constraints: const BoxConstraints(),
                      padding: EdgeInsets.only(left: m.gapSm),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ── Add New Address ────────────────────────────────────────────────────────
class _AddNewAddressButton extends StatelessWidget {
  final PaymentMetrics metrics;
  final VoidCallback onTap;

  const _AddNewAddressButton({required this.metrics, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    final m = metrics;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(m.addrRadius),
        onTap: onTap,
        child: Container(
          width: double.infinity,
          padding: EdgeInsets.symmetric(vertical: m.gapSm * 1.3),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(m.addrRadius),
            border: Border.all(color: c.brand.withValues(alpha: 0.45)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.add_circle_outline,
                size: m.addrBodySize + 4,
                color: c.brand,
              ),
              SizedBox(width: m.gapXs * 1.5),
              Text(
                'Add New Address',
                style: AppTextStyles.labelMedium.copyWith(
                  color: c.brand,
                  fontFamily: 'Inter',
                  fontWeight: FontWeight.w600,
                  fontSize: m.addrBodySize + 1,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Empty Address ──────────────────────────────────────────────────────────
class EmptyAddressWidget extends StatelessWidget {
  final PaymentMetrics metrics;
  final VoidCallback onAddPressed;

  const EmptyAddressWidget({
    super.key,
    required this.metrics,
    required this.onAddPressed,
  });

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    final m = metrics;

    return Column(
      children: [
        Container(
          width: m.walletIconBox * 1.4,
          height: m.walletIconBox * 1.4,
          decoration: BoxDecoration(color: c.brandSoft, shape: BoxShape.circle),
          alignment: Alignment.center,
          child: Icon(
            Icons.location_off_outlined,
            size: m.walletIconSize * 1.2,
            color: c.brand,
          ),
        ),
        SizedBox(height: m.gapMd),
        Text(
          'No saved addresses yet',
          style: AppTextStyles.labelLarge.copyWith(
            color: c.textPrimary,
            fontFamily: 'Inter',
            fontWeight: FontWeight.w600,
            fontSize: m.addrNameSize,
          ),
        ),
        SizedBox(height: m.gapXs),
        Text(
          'Add a delivery address to continue',
          textAlign: TextAlign.center,
          style: AppTextStyles.bodySmall.copyWith(
            color: c.textSecondary,
            fontFamily: 'Inter',
            fontSize: m.addrBodySize,
          ),
        ),
        SizedBox(height: m.gapMd),
        _AddNewAddressButton(metrics: m, onTap: onAddPressed),
      ],
    );
  }
}

// ── Skeleton ───────────────────────────────────────────────────────────────
class _AddressSkeletonLoader extends StatefulWidget {
  final PaymentMetrics metrics;

  const _AddressSkeletonLoader({required this.metrics});

  @override
  State<_AddressSkeletonLoader> createState() => _AddressSkeletonLoaderState();
}

class _AddressSkeletonLoaderState extends State<_AddressSkeletonLoader>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 900),
  )..repeat(reverse: true);

  late final Animation<double> _opacity = Tween<double>(
    begin: 0.4,
    end: 1.0,
  ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    final m = widget.metrics;

    return FadeTransition(
      opacity: _opacity,
      child: Column(
        children: List.generate(
          2,
          (i) => Padding(
            padding: EdgeInsets.only(bottom: m.gapSm),
            child: Container(
              height: m.walletIconBox * 1.7,
              decoration: BoxDecoration(
                color: c.surfaceAlt,
                borderRadius: BorderRadius.circular(m.addrRadius),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ── Error / Retry ──────────────────────────────────────────────────────────
class _AddressErrorRetry extends StatelessWidget {
  final PaymentMetrics metrics;
  final String message;
  final VoidCallback onRetry;

  const _AddressErrorRetry({
    required this.metrics,
    required this.message,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    final m = metrics;

    return Column(
      children: [
        Icon(
          Icons.wifi_off_rounded,
          size: m.walletIconSize * 1.3,
          color: c.textMuted,
        ),
        SizedBox(height: m.gapSm),
        Text(
          message.isNotEmpty ? message : 'Could not load addresses',
          textAlign: TextAlign.center,
          style: AppTextStyles.bodySmall.copyWith(
            color: c.textSecondary,
            fontFamily: 'Inter',
            fontSize: m.addrBodySize,
          ),
        ),
        SizedBox(height: m.gapMd),
        OutlinedButton.icon(
          onPressed: onRetry,
          icon: Icon(Icons.refresh, size: m.addrBodySize + 3),
          label: Text(
            'Retry',
            style: AppTextStyles.labelMedium.copyWith(
              fontFamily: 'Inter',
              fontSize: m.addrBodySize,
            ),
          ),
          style: OutlinedButton.styleFrom(
            foregroundColor: c.brand,
            side: BorderSide(color: c.brand.withValues(alpha: 0.45)),
          ),
        ),
      ],
    );
  }
}

// ── Wallet Info Card ───────────────────────────────────────────────────────
class _WalletInfoCard extends StatelessWidget {
  final PaymentMethodState state;
  final PaymentMetrics metrics;

  const _WalletInfoCard({required this.state, required this.metrics});

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
        boxShadow: c.isDark
            ? null
            : [
                BoxShadow(
                  color: c.textPrimary.withValues(alpha: 0.04),
                  blurRadius: 14,
                  offset: const Offset(0, 3),
                ),
              ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Container(
                width: m.walletIconBox * 0.8,
                height: m.walletIconBox * 0.8,
                decoration: BoxDecoration(
                  color: c.brandSoft,
                  shape: BoxShape.circle,
                ),
                alignment: Alignment.center,
                child: Icon(
                  Icons.account_balance_wallet_outlined,
                  size: m.walletIconSize * 0.8,
                  color: c.brand,
                ),
              ),
              SizedBox(width: m.gapSm),
              Expanded(
                child: Text(
                  'Bingold Wallet',
                  style: AppTextStyles.titleMedium.copyWith(
                    color: c.textPrimary,
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.w700,
                    fontSize: m.sectionTitleSize,
                  ),
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: m.gapSm,
                  vertical: m.gapXs * 0.8,
                ),
                decoration: BoxDecoration(
                  color: c.statusSuccessSoft,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.lock_outline,
                      size: m.addrChipSize + 3,
                      color: c.statusSuccess,
                    ),
                    SizedBox(width: m.gapXs * 0.8),
                    Text(
                      'Secured',
                      style: AppTextStyles.labelMedium.copyWith(
                        color: c.statusSuccess,
                        fontFamily: 'Inter',
                        fontWeight: FontWeight.w600,
                        fontSize: m.addrChipSize,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          SizedBox(height: m.gapMd),
          Divider(height: 1, thickness: 1, color: c.border),
          SizedBox(height: m.gapMd),

          _BalanceRow(
            icon: Icons.currency_bitcoin,
            label: 'Bigod Balance',
            value: state.formattedBigoldBalance,
            metrics: m,
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
  final PaymentMetrics metrics;

  const _BalanceRow({
    required this.icon,
    required this.label,
    required this.value,
    required this.metrics,
  });

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    final m = metrics;

    return Row(
      children: [
        Container(
          padding: EdgeInsets.all(m.gapXs * 1.5),
          decoration: BoxDecoration(
            color: c.brandSoft,
            borderRadius: BorderRadius.circular(9),
          ),
          child: Icon(icon, size: m.addrBodySize + 3, color: c.brand),
        ),
        SizedBox(width: m.gapSm),
        Expanded(
          child: Text(
            label,
            style: AppTextStyles.bodyMedium.copyWith(
              color: c.textSecondary,
              fontFamily: 'Inter',
              fontSize: m.summaryLabelSize,
            ),
          ),
        ),
        Text(
          value,
          style: AppTextStyles.titleMedium.copyWith(
            color: c.textPrimary,
            fontFamily: 'Inter',
            fontWeight: FontWeight.w700,
            fontSize: m.summaryValueSize + 1,
          ),
        ),
      ],
    );
  }
}
