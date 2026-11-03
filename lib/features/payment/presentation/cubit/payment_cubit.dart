import 'package:bingo_pay/core/api/api_client.dart';
import 'package:bingo_pay/core/api/api_endpoints.dart';
import 'package:bingo_pay/core/error/error_handler.dart';
import 'package:bingo_pay/core/error/failures.dart';
import 'package:bingo_pay/core/utils/idempotency_key_generator.dart';
import 'package:bingo_pay/features/profile/data/profile_model/profile_response.dart';
import 'package:bingo_pay/features/cart/domain/entities/cart_item_entity.dart';
import 'package:bingo_pay/features/cart/domain/usecases/clear_cart_usecase.dart';
import 'package:bingo_pay/features/payment/data/bigod_payment_datasource.dart';
import 'package:bingo_pay/features/payment/data/models/stripe_intent_response.dart';
import 'package:bingo_pay/features/payment/data/nowpayments_payment_datasource.dart';
import 'package:bingo_pay/features/payment/data/stripe_payment_datasource.dart';
import 'package:bingo_pay/features/payment/domain/checkout_charges.dart';
import 'package:bingo_pay/features/payment/presentation/cubit/payment_state.dart';
import 'package:bingo_pay/features/scanner/data/tvs_qr_datasource.dart';
import 'package:bingo_pay/features/setting/data/datasources/settings_remote_datasource.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
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
    TvsQrDataSource? tvsDataSource,
    SettingsRemoteDataSource? settingsDataSource,
    ClearCartUseCase? clearCartUseCase,
  }) : _bigodPaymentDataSource =
           bigodPaymentDataSource ?? GetIt.I<BigodPaymentDataSource>(),
       _stripePaymentDataSourceOverride = stripePaymentDataSource,
       _nowPaymentsDataSourceOverride = nowPaymentsDataSource,
       _tvsOverride = tvsDataSource,
       _settingsOverride = settingsDataSource,
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
  final TvsQrDataSource? _tvsOverride;
  final SettingsRemoteDataSource? _settingsOverride;
  final ClearCartUseCase _clearCartUseCase;

  // Looked up on first use: only the card rail needs it.
  late final StripePaymentDataSource _stripePaymentDataSource =
      _stripePaymentDataSourceOverride ?? GetIt.I<StripePaymentDataSource>();

  // Likewise, for the crypto rail.
  late final NowPaymentsDataSource _nowPaymentsDataSource =
      _nowPaymentsDataSourceOverride ?? GetIt.I<NowPaymentsDataSource>();

  // …and for TVS Wallet.
  late final TvsQrDataSource _tvs = _tvsOverride ?? GetIt.I<TvsQrDataSource>();

  // …and for the checkout charge rules (tax, delivery, fees), fetched once.
  late final SettingsRemoteDataSource _settings =
      _settingsOverride ?? GetIt.I<SettingsRemoteDataSource>();
  List<Map<String, dynamic>>? _chargeRules;

  // One per TVS payment; reused on retry so the order is paid once.
  String? _tvsKey;

  // The TVS coupon typed and the offer picked ('' = the best one, NONE = no
  // offer, else an offer uuid), sent with every quote and the payment.
  String _tvsCode = '';
  String _tvsOffer = '';

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
    if (method == state.selectedMethod) return;
    emit(state.copyWith(selectedMethod: method));
    // Charges can differ by method: price it again once there is an address.
    if (state.deliveryAddressId.isNotEmpty) loadQuote();
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
    try {
      final bigod = await _bigodPaymentDataSource.balance();
      if (!isClosed) emit(state.copyWith(bigodValueLine: bigod.valueLine));
    } catch (_) {
      // Display only: without it the balance shows on its own.
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

  // Bumped per quote request, so an answer for an earlier method is dropped.
  int _quoteSeq = 0;

  // Tax, delivery and the total for the basket and the selected payment
  // method (charges can differ by method), from the server's charge rules.
  Future<void> loadQuote() async {
    final seq = ++_quoteSeq;
    // A COD order is charged its item total: no tax or delivery is added.
    if (state.selectedMethod == PaymentMethod.cashOnDelivery) {
      emit(
        state.copyWith(
          taxes: 0,
          deliveryCharge: 0,
          totalAmount: state.itemTotal,
          isQuoted: true,
        ),
      );
      return;
    }
    try {
      final rules = _chargeRules ??= await _settings.getCharges();
      if (isClosed || seq != _quoteSeq) return;
      final c = computeCharges(
        rules,
        _chargeLines(),
        method: switch (state.selectedMethod) {
          PaymentMethod.card => 'STRIPE',
          PaymentMethod.crypto => 'NOWPAYMENTS',
          PaymentMethod.tvsWallet => 'TVS_WALLET',
          _ => 'BIGOD',
        },
      );
      emit(
        state.copyWith(
          taxes: c.tax + c.fee, // the summary's "Taxes & Fees"
          deliveryCharge: c.shipping,
          totalAmount:
              ((state.itemTotal + c.tax + c.shipping + c.fee) * 100).round() /
              100,
          isQuoted: true,
        ),
      );
    } catch (_) {
      // stays unquoted — the server's figures are then shown at payment
    }
  }

  // The basket as the charge rules see it: one line per cart item, or the
  // buy-now line / booking.
  List<ChargeLine> _chargeLines() => state.isCartFlow
      ? [
          for (final i in state.cartItems)
            ChargeLine(
              subtotal: i.totalPrice,
              quantity: i.quantity,
              vendor: i.vendor.uuid,
            ),
        ]
      : [
          ChargeLine(
            subtotal: state.itemTotal,
            quantity: state.quantity,
            isService: state.isServiceBooking,
          ),
        ];

  // What TVS Wallet prices: the buy-now line or booking (the cart when none),
  // for the chosen address.
  Map<String, dynamic> _tvsBasket() => {
    if (!state.isCartFlow && state.variantUuid != null) ...{
      'variantUuid': state.variantUuid,
      'quantity': state.quantity,
    },
    if (state.isServiceBooking) ...{
      'offeringUuid': state.offeringUuid,
      'slotUuid': state.slotUuid,
      'participants': ?state.participants,
    },
    if (state.deliveryAddressId.isNotEmpty)
      'addressId': state.deliveryAddressId,
    if (_tvsCode.isNotEmpty) 'code': _tvsCode,
    if (_tvsOffer.isNotEmpty) 'offer': _tvsOffer,
    'method': 'TVS_WALLET',
  };

  // The order in TVS Coins: price, best offer, whether the customer can pay.
  // The option is hidden only when TVS Wallet is switched off for this
  // account; any other failure shows it with the reason, as the web does.
  // `keep` leaves the current quote on screen while the new one loads.
  Future<void> loadTvsQuote({bool keep = false}) async {
    emit(state.copyWith(clearTvsQuote: !keep, tvsAvailable: true));
    try {
      final quote = await _tvs.checkoutQuote(_tvsBasket());
      if (!isClosed) emit(state.copyWith(tvsQuote: quote));
    } catch (e) {
      debugPrint('TVS checkout quote failed: $e');
      if (isClosed) return;
      if (e is TvsQrException && e.code == 'FEATURE_DISABLED') {
        emit(
          state.copyWith(
            tvsAvailable: false,
            selectedMethod: state.selectedMethod == PaymentMethod.tvsWallet
                ? PaymentMethod.wallet
                : null,
          ),
        );
        return;
      }
      emit(
        state.copyWith(
          tvsQuote: {
            'canPay': false,
            'reason': ErrorHandler.mapObjectToFailure(e).message,
          },
        ),
      );
    }
  }

  // A coupon code from "Apply coupon": the quote says whether it applies, and
  // the best offer is picked again with it.
  Future<void> applyTvsCode(String code) {
    _tvsCode = code.trim();
    _tvsOffer = '';
    return loadTvsQuote(keep: true);
  }

  // One of the quote's offers (uuid), '' for the best one, NONE for none.
  Future<void> chooseTvsOffer(String offer) {
    _tvsOffer = offer;
    return loadTvsQuote(keep: true);
  }

  // Pays exactly the quoted coins (the server refuses with QUOTE_CHANGED if
  // the price moved). Throws TvsQrException for the screen to handle (MPIN,
  // changed price…); the server closes the cart itself.
  Future<Map<String, dynamic>> payWithTvs({String? pin}) async {
    final coins = state.tvsQuote?['coins'] as Map?;
    _tvsKey ??= IdempotencyKeyGenerator.generate().substring(0, 64);
    emit(state.copyWith(status: PaymentStatus.loading, isProcessing: true));
    try {
      final paid = await _tvs.checkoutPay({
        ..._tvsBasket(),
        'addressId': state.deliveryAddressId,
        'idempotencyKey': _tvsKey,
        'expectedCoins': '${coins?['total']}',
        'pin': ?pin,
      });
      final order = paid['order'] as Map?;
      emit(
        state.copyWith(
          status: PaymentStatus.success,
          isProcessing: false,
          orderId: '${order?['orderNumber'] ?? ''}',
          orderUuid: '${order?['uuid'] ?? ''}',
        ),
      );
      return paid;
    } catch (e) {
      // A new price is a new payment.
      if (e is TvsQrException && e.code == 'QUOTE_CHANGED') _tvsKey = null;
      emit(state.copyWith(status: PaymentStatus.initial, isProcessing: false));
      rethrow;
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
          taxes: intent.breakdown.taxesAndFees,
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
          taxes: breakdown?.taxesAndFees,
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
