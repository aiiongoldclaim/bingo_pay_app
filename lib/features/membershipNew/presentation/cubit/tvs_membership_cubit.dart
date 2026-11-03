import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/error/error_handler.dart';
import '../../../../core/utils/idempotency_key_generator.dart';
import '../../../scanner/data/tvs_qr_datasource.dart';

// A membership paid with TVS Coins. The state is the server's quote (null
// while it loads); paying sends exactly the quoted coins.
class TvsMembershipCubit extends Cubit<Map<String, dynamic>?> {
  final TvsQrDataSource _api;
  final String planUuid;

  // One per payment; reused on retry so the plan is paid once (a retry also
  // finishes an activation that failed after the coins moved).
  String? _key;

  TvsMembershipCubit(this._api, this.planUuid) : super(null);

  // "Can't pay" is an answer with a reason; FEATURE_DISABLED hides the option.
  Future<void> load() async {
    emit(null);
    try {
      final quote = await _api.membershipQuote(planUuid);
      if (!isClosed) emit(quote);
    } catch (e) {
      if (isClosed) return;
      emit({
        'canPay': false,
        'reasonCode': e is TvsQrException ? e.code : null,
        'reason': ErrorHandler.mapObjectToFailure(e).message,
      });
    }
  }

  // Throws TvsQrException for the screen to handle (MPIN, new price…).
  Future<Map<String, dynamic>> pay({String? pin}) async {
    _key ??= IdempotencyKeyGenerator.generate().substring(0, 64);
    try {
      return await _api.membershipPay({
        'planUuid': planUuid,
        'idempotencyKey': _key,
        'expectedCoins': '${(state?['coins'] as Map?)?['total']}',
        'pin': ?pin,
      });
    } on TvsQrException catch (e) {
      if (e.code == 'QUOTE_CHANGED') _key = null; // a new price, a new payment
      rethrow;
    }
  }
}
