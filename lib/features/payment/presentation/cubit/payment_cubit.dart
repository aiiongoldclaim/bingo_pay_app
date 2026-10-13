import 'package:bingo_pay/core/api/api_client.dart';
import 'package:bingo_pay/core/api/api_endpoints.dart';
import 'package:bingo_pay/core/error/error_handler.dart';
import 'package:bingo_pay/core/error/failures.dart';
import 'package:bingo_pay/features/profile/data/profile_model/profile_response.dart';
import 'package:bingo_pay/features/cart/domain/entities/cart_item_entity.dart';
import 'package:bingo_pay/features/cart/domain/usecases/clear_cart_usecase.dart';
import 'package:bingo_pay/features/payment/data/bigod_payment_datasource.dart';
import 'package:bingo_pay/features/payment/data/models/stripe_intent_response.dart';
import 'package:bingo_pay/features/payment/data/nowpayments_payment_datasource.dart';
import 'package:bingo_pay/features/payment/data/stripe_payment_datasource.dart';
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
    String? offeringUuid, // NEW
    String? slotUuid, // NEW
    int? participants, // NEW
    BigodPaymentDataSource? bigodPaymentDataSource,
    StripePaymentDataSource? stripePaymentDataSource,
    NowPaymentsDataSource? nowPaymentsDataSource,
    ClearCartUseCase? clearCartUseCase,
  }) : _bigodPaymentDataSource =
           bigodPaymentDataSource ?? GetIt.I<BigodPaymentDataSource>(),
       _stripePaymentDataSourceOverride = stripePaymentDataSource,
       _nowPaymentsDataSourceOverride = nowPaymentsDataSource,
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

           offeringUuid: offeringUuid, // NEW
           slotUuid: slotUuid, // NEW
           participants: participants, // NEW
         ),
       );

  final BigodPaymentDataSource _bigodPaymentDataSource;
  final StripePaymentDataSource? _stripePaymentDataSourceOverride;
  final NowPaymentsDataSource? _nowPaymentsDataSourceOverride;
  final ClearCartUseCase _clearCartUseCase;

  // Looked up on first use: only the card rail needs it.
  late final StripePaymentDataSource _stripePaymentDataSource =
      _stripePaymentDataSourceOverride ?? GetIt.I<StripePaymentDataSource>();

  // Likewise, for the crypto rail.
  late final NowPaymentsDataSource _nowPaymentsDataSource =
      _nowPaymentsDataSourceOverride ?? GetIt.I<NowPaymentsDataSource>();

  Future<void> _clearCartIfNeeded() async {
    if (!state.isCartFlow) return;
    await _clearCartUseCase(); // best-effort — a clear failure shouldn't block a completed purchase
  }

  Future<({String orderNumber, String? uuid})> _placeCodOrder() async {
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
    final ids = _extractOrderIds(response.data);
    if (ids == null) {
      throw StateError('Order was created but the response had no order id');
    }
    return ids;
  }

  // Human-readable order number is preferred for display; the real uuid
  // (kept separately) is what GET .../invoice needs as its path param.
  ({String orderNumber, String? uuid})? _extractOrderIds(dynamic raw) {
    if (raw is! Map<String, dynamic>) return null;
    final outer = raw['data'];
    if (outer is! Map<String, dynamic>) return null;
    final data = outer['data'] is Map<String, dynamic>
        ? outer['data'] as Map<String, dynamic>
        : outer;
    final orderNumber =
        data['orderNumber'] ?? data['orderId'] ?? data['uuid'] ?? data['id'];
    if (orderNumber == null) return null;
    return (
      orderNumber: orderNumber.toString(),
      uuid: data['uuid']?.toString(),
    );
  }

  void selectPaymentMethod(PaymentMethod method) {
    emit(state.copyWith(selectedMethod: method));
  }

  Future<void> loadWalletBalance(String email) async {
    try {
      final client = GetIt.I<ApiClient>();
      final response = await client.dio.get(ApiEndpoints.profile);
      final profileResponse = ProfileResponseModel.fromJson(
        response.data as Map<String, dynamic>,
      );
      final usdt = profileResponse.profile.usdtBalance;

      emit(
        state.copyWith(
          usdtBalance: usdt,
          bigoldBalance: profileResponse.profile.bigoldBalance,
          walletBalance: usdt,
        ),
      );
    } catch (_) {
      // balance stays at 0 — display will show '—'
    }
  }

  Future<void> loadPaymentMethods() async {
    try {
      final available = await _stripePaymentDataSource.availableMethods();
      emit(
        state.copyWith(
          cardAvailable: available.contains('STRIPE'),
          cryptoAvailable: available.contains('NOWPAYMENTS'),
        ),
      );
    } catch (_) {
      // card and crypto options stay hidden
    }
  }

  Future<void> loadQuote() async {
    try {
      final quote = await _stripePaymentDataSource.getQuote(
        addressId: state.deliveryAddressId,
        variantUuid: state.isCartFlow ? null : state.variantUuid,
        quantity: state.isCartFlow ? null : state.quantity,

        offeringUuid: state.isServiceBooking ? state.offeringUuid : null,
        slotUuid: state.isServiceBooking ? state.slotUuid : null,
        participants: state.isServiceBooking ? state.participants : null,
      );
      emit(
        state.copyWith(
          itemTotal: quote.subtotal,
          savings: quote.discount,
          taxes: quote.tax,
          deliveryCharge: quote.shipping,
          totalAmount: quote.total,
          isQuoted: true,
        ),
      );
    } catch (_) {
      // stays unquoted — the server's figures are then shown at payment
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
        final ids = await _placeCodOrder();
        await _clearCartIfNeeded();
        emit(
          state.copyWith(
            status: PaymentStatus.success,
            isProcessing: false,
            orderId: ids.orderNumber,
            orderUuid: ids.uuid ?? '',
          ),
        );
        return;
      }

      final intent = await _bigodPaymentDataSource.createIntent(
        addressId: state.deliveryAddressId,
        variantUuid: state.isCartFlow ? null : state.variantUuid,
        quantity: state.isCartFlow ? null : state.quantity,

        offeringUuid: state.isServiceBooking ? state.offeringUuid : null,
        slotUuid: state.isServiceBooking ? state.slotUuid : null,
        participants: state.isServiceBooking ? state.participants : null,
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

      final confirmation = await _bigodPaymentDataSource.confirmPayment(
        intent.token,
      );

      await _clearCartIfNeeded();

      emit(
        state.copyWith(
          status: PaymentStatus.success,
          isProcessing: false,
          orderId: confirmation.order.orderNumber,
          orderUuid: confirmation.order.uuid,
          itemTotal: intent.breakdown.subtotal,
          savings: intent.breakdown.discount,
          taxes: intent.breakdown.tax,
          deliveryCharge: intent.breakdown.shipping,
          totalAmount: intent.breakdown.total,
          isQuoted: true,
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

  // Card rail, step 1: ask the server for a Stripe checkout page. Nothing is
  // charged and no order exists yet — the caller sends the customer to
  // `checkoutUrl`, and the order appears once Stripe confirms the payment.
  Future<StripeIntentResponse?> startCardPayment() =>
      _startHostedPayment(crypto: false);

  // Crypto rail, step 1: the same, for a NOWPayments invoice page. Nothing
  // is owed until the customer sends the coins, and the order appears once
  // NOWPayments confirms they arrived.
  Future<StripeIntentResponse?> startCryptoPayment() =>
      _startHostedPayment(crypto: true);

  Future<StripeIntentResponse?> _startHostedPayment({
    required bool crypto,
  }) async {
    emit(state.copyWith(status: PaymentStatus.loading, isProcessing: true));

    try {
      final createIntent = crypto
          ? _nowPaymentsDataSource.createIntent
          : _stripePaymentDataSource.createIntent;
      final intent = await createIntent(
        addressId: state.deliveryAddressId,
        variantUuid: state.isCartFlow ? null : state.variantUuid,
        quantity: state.isCartFlow ? null : state.quantity,

        offeringUuid: state.isServiceBooking ? state.offeringUuid : null,
        slotUuid: state.isServiceBooking ? state.slotUuid : null,
        participants: state.isServiceBooking ? state.participants : null,
      );

      // Only ever follow the gateway's own page — never an arbitrary url.
      final url = Uri.tryParse(intent.checkoutUrl);
      final isGatewayPage = crypto
          ? url != null &&
                url.isScheme('https') &&
                (url.host == 'nowpayments.io' ||
                    url.host.endsWith('.nowpayments.io'))
          : intent.checkoutUrl.startsWith('https://checkout.stripe.com/');
      if (!isGatewayPage) {
        throw const FormatException('No checkout url returned');
      }

      // The server's quote is what the customer is charged, so it replaces
      // the locally computed totals from here on.
      final breakdown = intent.breakdown;
      emit(
        state.copyWith(
          status: PaymentStatus.initial,
          isProcessing: false,
          totalAmount: intent.amount,
          itemTotal: breakdown?.subtotal,
          savings: breakdown?.discount,
          taxes: breakdown?.tax,
          deliveryCharge: breakdown?.shipping,
          isQuoted: breakdown != null,
        ),
      );
      return intent;
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
          errorMessage:
              'Could not start the ${crypto ? 'crypto' : 'card'} payment. '
              'Please try again.',
          isProcessing: false,
        ),
      );
    }
    return null;
  }

  // Card and crypto rails, last step: the server reported the payment PAID
  // and placed the order. It closed the cart too, so there is nothing to
  // clear here.
  void completeCardPayment({
    required String orderNumber,
    required String orderUuid,
  }) {
    emit(
      state.copyWith(
        status: PaymentStatus.success,
        isProcessing: false,
        orderId: orderNumber,
        orderUuid: orderUuid,
      ),
    );
  }

  String _messageFor(DioException e) {
    final failure = ErrorHandler.mapExceptionToFailure(e);
    if (failure is ServerFailure && failure.statusCode == 409) {
      return 'This payment was already processed.';
    }
    return failure.message;
  }
}
