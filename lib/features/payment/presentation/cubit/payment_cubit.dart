import 'package:bingo_pay/core/api/api_client.dart';
import 'package:bingo_pay/core/api/api_endpoints.dart';
import 'package:bingo_pay/core/config/app_config.dart';
import 'package:bingo_pay/features/account/data/account_model/account_profile_response.dart';
import 'package:bingo_pay/features/cart/domain/entities/cart_item_entity.dart';
import 'package:bingo_pay/features/payment/presentation/cubit/payment_state.dart';
import 'package:bingo_pay/core/api/interceptors/logging_interceptor.dart';
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
  }) : super(
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

  static const _apiUrl =
      // 'https://admin-blog.bingold.to/api/bingold/bingopay/balance/operation';
      'http://13.159.7.199:5001/api/v1/customers/bingopay/balance/operation';
  static const _apiKey = 'mysecreate-key';

  // The cart API's vendor object only exposes {uuid, shopName}, not email,
  // so vendor emails (needed to credit the right wallet) are resolved via
  // the product-details endpoint per unique product uuid and cached here
  // for the duration of a single checkout.
  Future<String?> _resolveVendorEmail(String productUuid) async {
    try {
      final client = GetIt.I<ApiClient>();
      final url =
          '${AppConfig.categoriesApiBaseUrl}/api/v1/products/$productUuid';
      final response = await client.dio.get(url);
      final outer =
          (response.data as Map<String, dynamic>)['data']
              as Map<String, dynamic>;
      final data = outer['data'] as Map<String, dynamic>;
      final vendor = data['vendor'] as Map<String, dynamic>?;
      return vendor?['email'] as String?;
    } catch (_) {
      return null;
    }
  }

  Future<String?> _createOrder() async {
    final variantUuid = state.variantUuid;
    if (variantUuid == null || state.deliveryAddressId.isEmpty) return null;

    try {
      final client = GetIt.I<ApiClient>();
      final response = await client.dio.post(
        ApiEndpoints.orders,
        data: {
          'addressId': state.deliveryAddressId,
          'paymentMethod': 'WALLET',
          if (state.couponCode.isNotEmpty) 'couponCode': state.couponCode,
          if (state.notes.isNotEmpty) 'notes': state.notes,
          'variantUuid': variantUuid,
          'quantity': state.quantity,
        },
      );
      return _extractOrderId(response.data);
    } catch (_) {
      return null;
    }
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

    final dio = Dio(
      BaseOptions(
        baseUrl: _apiUrl,
        headers: {
          'x-api-key': _apiKey,
          'Content-Type': 'application/json',
          'accept': '*/*',
        },
      ),
    )..interceptors.add(LoggingInterceptor());

    final ts = DateTime.now().millisecondsSinceEpoch;

    try {
      if (state.isCartFlow) {
        // ── Cart flow ─────────────────────────────────────────────────
        final total = state.totalAmount;

        // Deduct full cart total from buyer
        await dio.post(
          _apiUrl,
          data: {
            'email': state.userEmail,
            'amount': total,
            'operation': 'deduct',
            'reference': 'MKT-$ts-U',
            'description': 'Cart purchase: ${state.cartItems.length} item(s)',
          },
        );

        // Group items by vendor email (resolved via product-details lookup,
        // since the cart API's vendor object has no email) and credit each
        // vendor once.
        final Map<String, String?> resolvedEmailByProductUuid = {};
        final Map<String, double> vendorTotals = {};
        for (final item in state.cartItems) {
          final productUuid = item.product.uuid;
          if (!resolvedEmailByProductUuid.containsKey(productUuid)) {
            resolvedEmailByProductUuid[productUuid] = await _resolveVendorEmail(
              productUuid,
            );
          }
          final resolvedEmail = resolvedEmailByProductUuid[productUuid];
          final email = (resolvedEmail?.isNotEmpty == true)
              ? resolvedEmail!
              : state.vendorEmail;
          if (email.isEmpty) continue;
          vendorTotals[email] = (vendorTotals[email] ?? 0.0) + item.totalPrice;
        }

        int offset = 1;
        for (final entry in vendorTotals.entries) {
          await dio.post(
            _apiUrl,
            data: {
              'email': entry.key,
              'amount': entry.value,
              'operation': 'add',
              'reference': 'MKT-${ts + offset}-V',
              'description': 'Sale credit: cart order',
            },
          );
          offset++;
        }
      } else {
        // ── Single product flow ───────────────────────────────────────
        await dio.post(
          _apiUrl,
          data: {
            'email': state.userEmail,
            'amount': state.productPriceValue,
            'operation': 'deduct',
            'reference': 'MKT-$ts-U',
            // 'description': 'Purchase: ${state.productName}',
            'description': 'Purchase: Static description for testing',
          },
        );

        await dio.post(
          _apiUrl,
          data: {
            'email': state.vendorEmail,
            'amount': state.productPriceValue,
            'operation': 'add',
            'reference': 'MKT-${ts + 1}-V',
            // 'description': 'Sale credit for: ${state.productName}',
            'description': 'Sale credit for: Static description for testing',
          },
        );
      }

      // Record the order (Buy Now / single-product flow only — cart
      // checkout order creation is not wired up yet). The wallet debit
      // above has already succeeded by this point, so a failure here is
      // swallowed rather than surfaced as a failed payment; it just falls
      // back to the synthetic order id.
      final realOrderId = state.isCartFlow ? null : await _createOrder();

      emit(
        state.copyWith(
          status: PaymentStatus.success,
          isProcessing: false,
          orderId: realOrderId ?? 'BG-${ts % 100000}',
          coinsEarned: 380,
        ),
      );
    } on DioException catch (e) {
      final msg =
          (e.response?.data as Map<String, dynamic>?)?['message'] as String? ??
          'Payment failed. Please try again.';
      emit(
        state.copyWith(
          status: PaymentStatus.failure,
          errorMessage: msg,
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
}
