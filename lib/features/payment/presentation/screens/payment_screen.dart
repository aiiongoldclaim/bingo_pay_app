import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
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
import '../widgets/checkout_address_list.dart';
import '../widgets/checkout_ui.dart';
import 'payment_flow_args.dart';

// Checkout, step 1: where to deliver, and what is being bought. Payment is
// chosen on the next step (Review & Pay), where delivery and tax are added.
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
  AddressEntity? _selectedAddress;

  late final AddressCubit _addressCubit;
  late final PaymentMethodCubit _paymentCubit;
  late final double _cartTotal;
  late final String _userEmail;

  @override
  void initState() {
    super.initState();
    _addressCubit = AddressCubit(getIt<AddressRepository>())
      ..loadUserAddresses();

    final isCart = widget.cartItems.isNotEmpty;
    _cartTotal = isCart
        ? widget.cartItems.fold<double>(0.0, (s, i) => s + i.totalPrice)
        : widget.productPrice * widget.quantity;

    final authState = context.read<AuthBloc>().state;
    _userEmail = authState is AuthAuthenticated ? authState.user.email : '';

    _paymentCubit =
        PaymentMethodCubit(
            productPrice: _cartTotal,
            productName: widget.productName,
            userEmail: _userEmail,
            vendorEmail: widget.vendorEmail ?? '',
            variantUuid: widget.variantUuid,
            quantity: widget.quantity,
            cartItems: widget.cartItems,
          )
          ..loadWalletBalance(_userEmail)
          ..loadPaymentMethods();
  }

  Future<void> _refresh() async {
    await Future.wait([
      _addressCubit.loadUserAddresses(),
      _paymentCubit.loadWalletBalance(_userEmail),
      _paymentCubit.loadPaymentMethods(),
    ]);
  }

  @override
  void dispose() {
    _addressCubit.close();
    _paymentCubit.close();
    super.dispose();
  }

  void _selectAddress(AddressEntity addr) =>
      setState(() => _selectedAddress = addr);

  void _onAddressDeleted(AddressEntity addr) {
    if (_selectedAddress?.id == addr.id) {
      setState(() => _selectedAddress = null);
    }
  }

  void _onContinue() {
    final a = _selectedAddress;
    if (a == null) return;
    _paymentCubit
      ..updateDeliveryAddress(
        name: a.fullName,
        phone: a.phoneNumber,
        address: a.addressLine1,
        city: a.city,
        postal: a.postalCode,
        addressId: a.id,
      )
      ..loadQuote()
      ..loadTvsQuote();

    context.push(
      AppRoutes.paymentReview,
      extra: ReviewPayArgs(cubit: _paymentCubit, isCart: widget.isCart),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return MultiBlocProvider(
      providers: [
        BlocProvider<AddressCubit>.value(value: _addressCubit),
        BlocProvider<PaymentMethodCubit>.value(value: _paymentCubit),
      ],
      // Starts on the default address (or the first) once they load.
      child: BlocListener<AddressCubit, AddressState>(
        listener: (context, s) {
          if (s is AddressListLoaded &&
              s.addresses.isNotEmpty &&
              _selectedAddress == null) {
            _selectAddress(
              s.addresses.firstWhere(
                (a) => a.isDefaultAddress,
                orElse: () => s.addresses.first,
              ),
            );
          }
        },
        child: Scaffold(
          backgroundColor: colors.background,
          appBar: const CustomAppBar(title: 'Checkout'),
          body: Column(
            children: [
              Expanded(
                child: RefreshIndicator(
                  color: colors.brand,
                  backgroundColor: colors.surface,
                  onRefresh: _refresh,
                  child: CheckoutBody(
                    children: [
                      CheckoutSection(
                        title: 'Deliver to',
                        child: CheckoutAddressList(
                          selectedId: _selectedAddress?.id,
                          onSelect: _selectAddress,
                          onDeleted: _onAddressDeleted,
                        ),
                      ),
                      const SizedBox(height: 20),
                      BlocBuilder<PaymentMethodCubit, PaymentMethodState>(
                        builder: (context, state) => CheckoutSection(
                          title: 'Your order',
                          padding: const EdgeInsets.fromLTRB(14, 10, 14, 10),
                          child: Column(
                            children: [
                              CheckoutItems(state: state),
                              if (widget.cartItems.length > 1) ...[
                                Divider(height: 20, color: colors.border),
                                CheckoutLine(
                                  'Item total',
                                  money(_cartTotal),
                                  total: true,
                                ),
                              ],
                            ],
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(4, 10, 4, 0),
                        child: Text(
                          'Delivery and taxes, if any, are added on the next step.',
                          style: checkoutText(colors.textMuted, size: 12),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              CheckoutBar(
                label: 'Continue',
                onPressed: _selectedAddress == null ? null : _onContinue,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
