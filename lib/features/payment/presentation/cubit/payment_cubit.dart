import 'package:bingo_pay/core/api/api_client.dart';
import 'package:bingo_pay/core/api/api_endpoints.dart';
import 'package:bingo_pay/core/error/error_handler.dart';
import 'package:bingo_pay/core/error/failures.dart';
import 'package:bingo_pay/features/account/data/account_model/account_profile_response.dart';
import 'package:bingo_pay/features/cart/domain/entities/cart_item_entity.dart';
import 'package:bingo_pay/features/cart/domain/usecases/clear_cart_usecase.dart';
import 'package:bingo_pay/features/payment/data/bigod_payment_datasource.dart';
import 'package:bingo_pay/features/payment/presentation/cubit/payment_state.dart';
import 'package:dio/dio.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';

class PaymentMethodCubit extends Cubit<PaymentMethodState> {
  PaymentMethodCubit({
    double productPrice = 0.0,
    String productName = '',
    String userEmail = '',
    String vendorEmail = '',
    String? variantUuid,
    int quantity = 1,
    List<CartItemEntity> cartItems = const [],
    BigodPaymentDataSource? bigodPaymentDataSource,
    ClearCartUseCase? clearCartUseCase,
  })  : _bigodPaymentDataSource =
            bigodPaymentDataSource ?? GetIt.I<BigodPaymentDataSource>(),
        _clearCartUseCase = clearCartUseCase ?? GetIt.I<ClearCartUseCase>(),
        super(
         PaymentMethodState.initial(
           productPrice: productPrice,
           productName: productName,
           userEmail: userEmail,
           vendorEmail: vendorEmail,
           variantUuid: variantUuid,
           quantity: quantity,
           cartItems: cartItems,
         ),
       );

  final BigodPaymentDataSource _bigodPaymentDataSource;
  final ClearCartUseCase _clearCartUseCase;

  Future<void> _clearCartIfNeeded() async {
    if (!state.isCartFlow) return;
    await _clearCartUseCase(); // best-effort — a clear failure shouldn't block a completed purchase
  }

  Future<String> _placeCodOrder() async {
    final client = GetIt.I<ApiClient>();
    final response = await client.dio.post(
      ApiEndpoints.orders,
      data: {
        'addressId': state.deliveryAddressId,
        'paymentMethod': 'COD',
        if (!state.isCartFlow) 'variantUuid': state.variantUuid,
        if (!state.isCartFlow) 'quantity': state.quantity,
        if (!state.isCartFlow && state.couponCode.isNotEmpty)
          'couponCode': state.couponCode,
        if (!state.isCartFlow && state.notes.isNotEmpty) 'notes': state.notes,
      },
    );
    final orderId = _extractOrderId(response.data);
    if (orderId == null) {
      throw StateError('Order was created but the response had no order id');
    }
    return orderId;
  }

  String? _extractOrderId(dynamic raw) {
    if (raw is! Map<String, dynamic>) return null;
    final data = raw['data'];
    if (data is! Map<String, dynamic>) return null;
    final candidate =
        data['orderNumber'] ?? data['orderId'] ?? data['uuid'] ?? data['id'];
    return candidate?.toString();
  }

  void selectPaymentMethod(PaymentMethod method) {
    emit(state.copyWith(selectedMethod: method));
  }

  Future<void> loadWalletBalance(String email) async {
    try {
      final client = GetIt.I<ApiClient>();
      final response = await client.dio.get(ApiEndpoints.profile);
      final profile = AccountResponseModel.fromJson(
        response.data as Map<String, dynamic>,
      );
      final usdt = profile.account.usdtBalance;

      emit(
        state.copyWith(
          usdtBalance: usdt,
          bigoldBalance: profile.account.bigoldBalance / 1e8,
          walletBalance: usdt,
        ),
      );
    } catch (_) {
      // balance stays at 0 — display will show '—'
    }
  }

  void updateDeliveryAddress({
    required String name,
    required String phone,
    required String address,
    required String city,
    required String postal,
    required String addressId,
  }) {
    emit(
      state.copyWith(
        deliveryName: name,
        deliveryPhone: phone,
        deliveryAddress: address,
        deliveryCity: city,
        deliveryPostal: postal,
        deliveryAddressId: addressId,
      ),
    );
  }

  void updateCouponCode(String couponCode) {
    emit(state.copyWith(couponCode: couponCode));
  }

  void updateNotes(String notes) {
    emit(state.copyWith(notes: notes));
  }

  Future<void> makePayment() async {
    emit(state.copyWith(status: PaymentStatus.loading, isProcessing: true));

    try {
      if (state.selectedMethod == PaymentMethod.cashOnDelivery) {
        final orderId = await _placeCodOrder();
        await _clearCartIfNeeded();
        emit(
          state.copyWith(
            status: PaymentStatus.success,
            isProcessing: false,
            orderId: orderId,
          ),
        );
        return;
      }

      final intent = await _bigodPaymentDataSource.createIntent(
        addressId: state.deliveryAddressId,
        variantUuid: state.isCartFlow ? null : state.variantUuid,
        quantity: state.isCartFlow ? null : state.quantity,
      );

      if (intent.customerBalance != null &&
          intent.customerBalance! < intent.amount) {
        emit(
          state.copyWith(
            status: PaymentStatus.failure,
            errorMessage: 'Insufficient BingoPay balance for this purchase.',
            isProcessing: false,
          ),
        );
        return;
      }

      final confirmation =
          await _bigodPaymentDataSource.confirmPayment(intent.token);

      await _clearCartIfNeeded();

      emit(
        state.copyWith(
          status: PaymentStatus.success,
          isProcessing: false,
          orderId: confirmation.order.orderNumber,
        ),
      );
    } on DioException catch (e) {
      emit(
        state.copyWith(
          status: PaymentStatus.failure,
          errorMessage: _messageFor(e),
          isProcessing: false,
        ),
      );
    } catch (_) {
      emit(
        state.copyWith(
          status: PaymentStatus.failure,
          errorMessage: 'Payment failed. Please try again.',
          isProcessing: false,
        ),
      );
    }
  }

  String _messageFor(DioException e) {
    final failure = ErrorHandler.mapExceptionToFailure(e);
    if (failure is ServerFailure && failure.statusCode == 409) {
      return 'This payment was already processed.';
    }
    return failure.message;
  }
}
