import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/error/error_handler.dart';
import '../../../../core/utils/idempotency_key_generator.dart';
import '../../data/tvs_qr_datasource.dart';
import 'payment_state.dart';

// Scan a shop QR → resolve → quote as the user types → pay.
@injectable
class PaymentCubit extends Cubit<PaymentState> {
  final TvsQrDataSource _api;

  PaymentCubit(this._api) : super(const PaymentState());

  String _token = '';
  String _amount = '';
  String _code = '';
  Timer? _debounce;
  int _quoteSeq = 0;

  // One per payment, reused on every retry of it so it is charged once.
  String? _idempotencyKey;

  Future<void> resolve(String token) async {
    _token = token;
    emit(const PaymentState());
    try {
      final shop = await _api.resolve(token);
      if (!isClosed) emit(state.copyWith(shop: shop));
    } catch (e) {
      if (!isClosed) emit(state.copyWith(error: _message(e)));
    }
  }

  // After KYC, the wallet may now be able to pay.
  Future<void> reload() => resolve(_token);

  // Called on every keystroke in the amount or coupon field.
  void inputChanged(String amount, String code) {
    _debounce?.cancel();
    _amount = amount;
    _code = code.trim();
    _idempotencyKey = null; // a different amount or code is a new payment
    _quoteSeq++;
    final valid = (double.tryParse(amount) ?? 0) > 0 && state.canPay;
    emit(state.copyWith(quote: null, error: null, quoting: valid));
    if (valid) {
      _debounce = Timer(const Duration(milliseconds: 400), requote);
    }
  }

  Future<void> requote() async {
    final seq = ++_quoteSeq;
    emit(state.copyWith(quoting: true));
    try {
      final quote = await _api.quote(_token, _amount, _code);
      if (isClosed || seq != _quoteSeq) return; // a newer keystroke won
      emit(state.copyWith(quote: quote, error: null, quoting: false));
    } catch (e) {
      if (isClosed || seq != _quoteSeq) return;
      emit(state.copyWith(quote: null, error: _message(e), quoting: false));
    }
  }

  // Pays exactly what was quoted. Throws TvsQrException for the screen to
  // handle (PIN, changed price…); returns the receipt.
  Future<Map<String, dynamic>> pay({String? pin, String note = ''}) async {
    final quote = state.quote!;
    // The API caps the key at 100 characters.
    _idempotencyKey ??= IdempotencyKeyGenerator.generate().substring(0, 64);
    emit(state.copyWith(paying: true));
    try {
      return await _api.pay(
        token: _token,
        amount: _amount,
        code: _code,
        idempotencyKey: _idempotencyKey!,
        expectedPayable: '${quote['payable']}',
        pin: pin,
        note: note,
      );
    } finally {
      if (!isClosed) emit(state.copyWith(paying: false));
    }
  }

  Future<bool> pinIsSet() => _api.pinIsSet();

  Future<void> setPin(String pin) => _api.setPin(pin);

  // TvsQrException's toString is its message, so this covers it too.
  String _message(Object e) => ErrorHandler.mapObjectToFailure(e).message;

  @override
  Future<void> close() {
    _debounce?.cancel();
    return super.close();
  }
}
