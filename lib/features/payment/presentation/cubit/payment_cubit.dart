import 'package:bingo_pay/core/api/api_client.dart';
import 'package:bingo_pay/core/api/api_endpoints.dart';
import 'package:bingo_pay/features/cart/data/models/cart_model.dart';
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
    List<CartItemModel> cartItems = const [],
  }) : super(PaymentMethodState.initial(
          productPrice: productPrice,
          productName: productName,
          userEmail: userEmail,
          vendorEmail: vendorEmail,
          cartItems: cartItems,
        ));

  static const _apiUrl =
      'https://admin-blog.bingold.to/api/bingold/bingopay/balance/operation';
  static const _apiKey = 'GTP_2026_PDA_V1_API_KEY_ASDF';

  void selectPaymentMethod(PaymentMethod method) {
    emit(state.copyWith(selectedMethod: method));
  }

  Future<void> loadWalletBalance(String email) async {
    if (email.isEmpty) return;
    try {
      final client = GetIt.I<ApiClient>();
      final response = await client.dio.post(
        ApiEndpoints.profile,
        data: {'email': email},
      );
      final data = response.data as Map<String, dynamic>;
      final accountData = data['data'] as Map<String, dynamic>?;
      if (accountData == null) return;

      final rawBigold =
          (accountData['bigoldBalance'] as num?)?.toDouble() ?? 0.0;
      final usdt =
          (accountData['usdtBalance'] as num?)?.toDouble() ?? 0.0;

      emit(state.copyWith(
        usdtBalance: usdt,
        bigoldBalance: rawBigold / 1e8,
        walletBalance: usdt,
      ));
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
  }) {
    emit(state.copyWith(
      deliveryName: name,
      deliveryPhone: phone,
      deliveryAddress: address,
      deliveryCity: city,
      deliveryPostal: postal,
    ));
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

        // Group items by vendorEmail and credit each vendor
        final Map<String, double> vendorTotals = {};
        for (final item in state.cartItems) {
          final email =
              (item.vendorEmail?.isNotEmpty == true)
                  ? item.vendorEmail!
                  : state.vendorEmail;
          if (email.isEmpty) continue;
          vendorTotals[email] =
              (vendorTotals[email] ?? 0.0) + item.priceValue * item.quantity;
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
            'description': 'Purchase: ${state.productName}',
          },
        );

        await dio.post(
          _apiUrl,
          data: {
            'email': state.vendorEmail,
            'amount': state.productPriceValue,
            'operation': 'add',
            'reference': 'MKT-${ts + 1}-V',
            'description': 'Sale credit for: ${state.productName}',
          },
        );
      }

      emit(state.copyWith(
        status: PaymentStatus.success,
        isProcessing: false,
        orderId: 'BG-${ts % 100000}',
        coinsEarned: 380,
      ));
    } on DioException catch (e) {
      final msg = (e.response?.data as Map<String, dynamic>?)?['message']
              as String? ??
          'Payment failed. Please try again.';
      emit(state.copyWith(
        status: PaymentStatus.failure,
        errorMessage: msg,
        isProcessing: false,
      ));
    } catch (_) {
      emit(state.copyWith(
        status: PaymentStatus.failure,
        errorMessage: 'Payment failed. Please try again.',
        isProcessing: false,
      ));
    }
  }
}
