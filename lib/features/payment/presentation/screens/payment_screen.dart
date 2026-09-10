import 'package:bingo_pay/features/payment/presentation/screens/widgets/payment_metrics.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/di/injection.dart';
import '../../../../core/router/app_routes.dart';
import '../../../../core/theme/app_theme_colors.dart';
import '../../../../core/widgets/custom_app_bar.dart';
import '../../../address/domain/entities/address_entity.dart';
import '../../../address/domain/repositories/address_respository.dart';
import '../../../address/presentation/cubit/address_cubit.dart';
import '../../../address/presentation/cubit/address_state.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_state.dart';
import '../../../cart/domain/entities/cart_item_entity.dart';

import '../cubit/payment_cubit.dart';
import '../cubit/payment_state.dart';

import 'payment_flow_args.dart';
import 'widgets/payment_body.dart';
import 'widgets/payment_continue_bar.dart';
import 'widgets/payment_order_summary_card.dart';

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
  late final bool _isCart;
  late final double _cartTotal;
  late final String _userEmail;

  @override
  void initState() {
    super.initState();
    _addressCubit = AddressCubit(getIt<AddressRepository>())
      ..loadUserAddresses();

    _isCart = widget.cartItems.isNotEmpty;
    _cartTotal = _isCart
        ? widget.cartItems.fold<double>(0.0, (s, i) => s + i.totalPrice)
        : widget.productPrice * widget.quantity;

    final authState = context.read<AuthBloc>().state;
    _userEmail = authState is AuthAuthenticated ? authState.user.email : '';

    _paymentCubit = PaymentMethodCubit(
      productPrice: _cartTotal,
      productName: widget.productName,
      userEmail: _userEmail,
      vendorEmail: widget.vendorEmail ?? '',
      variantUuid: widget.variantUuid,
      quantity: widget.quantity,
      cartItems: widget.cartItems,
    )..loadWalletBalance(_userEmail);
  }

  Future<void> _refresh() async {
    await Future.wait([
      _addressCubit.loadUserAddresses(),
      _paymentCubit.loadWalletBalance(_userEmail),
    ]);
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

    context.push(
      AppRoutes.paymentReview,
      extra: ReviewPayArgs(cubit: cubit, isCart: widget.isCart),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.c;
    final m = PaymentMetrics.of(context);

    return MultiBlocProvider(
      providers: [
        BlocProvider<AddressCubit>.value(value: _addressCubit),
        BlocProvider<PaymentMethodCubit>.value(value: _paymentCubit),
      ],
      child: AnnotatedRegion<SystemUiOverlayStyle>(
        value: SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: colors.isDark
              ? Brightness.light
              : Brightness.dark,
          statusBarBrightness: colors.isDark
              ? Brightness.dark
              : Brightness.light,
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
            backgroundColor: colors.background,
            appBar: const CustomAppBar(title: 'Payment'),
            body: SafeArea(
              bottom: false,
              child: BlocBuilder<PaymentMethodCubit, PaymentMethodState>(
                builder: (context, state) {
                  final summary = PaymentOrderSummaryCard(
                    metrics: m,
                    isCart: _isCart,
                    items: widget.cartItems,
                    productName: widget.quantity > 1
                        ? '${widget.productName} × ${widget.quantity}'
                        : widget.productName,
                    total: _cartTotal,
                  );

                  final continueBar = PaymentContinueBar(
                    metrics: m,
                    isEnabled: _selectedAddress != null,
                    total: _cartTotal,
                    onPressed: () => _onContinue(
                      context,
                      context.read<PaymentMethodCubit>(),
                    ),
                  );

                  return Column(
                    children: [
                      Expanded(
                        child: RefreshIndicator(
                          color: colors.brand,
                          backgroundColor: colors.surface,
                          onRefresh: _refresh,
                          child: Center(
                            child: ConstrainedBox(
                              constraints: BoxConstraints(
                                maxWidth: m.maxContentWidth,
                              ),
                              child: m.isLandscape
                                  ? PaymentLandscapeBody(
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
                                  : PaymentPortraitBody(
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
