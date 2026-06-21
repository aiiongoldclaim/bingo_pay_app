import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../customer/shop/data/shop_remote_datasource.dart';
import '../../../customer/shop/domain/entities/cart_item.dart';
import '../../../customer/shop/presentation/bloc/shop_bloc.dart';
import '../../../customer/shop/presentation/bloc/shop_event.dart';
import '../../../customer/shop/presentation/bloc/shop_state.dart';
import '../../data/wallet_payment_datasource.dart';

part 'payment_state.dart';

class PaymentCubit extends Cubit<PaymentState> {
  final ShopBloc _shopBloc;
  final ShopRemoteDataSource _shopRemoteDataSource;
  final WalletPaymentDataSource _walletPaymentDataSource;

  final String _customerName;
  final String _customerPhone;

  PaymentCubit({
    required ShopBloc shopBloc,
    required String customerName,
    required String customerPhone,
    ShopRemoteDataSource? shopRemoteDataSource,
    WalletPaymentDataSource? walletPaymentDataSource,
  })  : _shopBloc = shopBloc,
        _customerName = customerName,
        _customerPhone = customerPhone,
        _shopRemoteDataSource =
            shopRemoteDataSource ?? shopBloc.remoteDataSource,
        _walletPaymentDataSource =
            walletPaymentDataSource ?? WalletPaymentDataSource(),
        super(_seedFromCart(shopBloc.state));

  static PaymentState _seedFromCart(ShopState cart) {
    return PaymentState(
      selectedMethod: PaymentMethod.bingoldWallet,
      cartItems: cart.cartItems,
      vendorEmail: cart.cartVendorEmail,
      reference: 'MKT-ORDER-${DateTime.now().millisecondsSinceEpoch}',
      itemTotal: cart.cartSubtotal,
      savings: cart.promoDiscount,
      deliveryCharge: cart.shippingFee,
      taxes: cart.taxAmount,
      totalAmount: cart.cartTotal,
    );
  }

  void selectPaymentMethod(PaymentMethod method) {
    if (!enabledPaymentMethods.contains(method)) return;
    emit(state.copyWith(selectedMethod: method));
  }

  Future<void> makePayment() async {
    if (state.cartItems.isEmpty) return;

    emit(state.copyWith(status: PaymentStatus.loading, isProcessing: true));

    try {
      if (state.selectedMethod == PaymentMethod.bingoldWallet) {
        final vendorEmail = state.vendorEmail;
        if (vendorEmail == null) {
          throw Exception('This order has no vendor configured for payout.');
        }
        await _walletPaymentDataSource.pay(
          amount: state.totalAmount,
          vendorEmail: vendorEmail,
          reference: state.reference,
          description: 'Marketplace purchase settlement',
        );
      }

      final orderId = await _shopRemoteDataSource.placeOrder(
        customerName: _customerName,
        customerPhone: _customerPhone,
        totalAmount: state.totalAmount,
        items: state.cartItems,
        paymentType: state.selectedMethod == PaymentMethod.bingoldWallet
            ? 'bingold_wallet'
            : 'cod',
      );

      _shopBloc.add(const ShopCartCleared());

      emit(
        state.copyWith(
          status: PaymentStatus.success,
          isProcessing: false,
          orderId: orderId,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          status: PaymentStatus.failure,
          isProcessing: false,
          errorMessage: e.toString(),
        ),
      );
    }
  }
}
