import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';

import '../../../core/api/api_client.dart';
import '../../../core/api/api_endpoints.dart';
import '../../../core/api/api_envelope.dart';

// A refusal from the TVS Wallet API. `message` is already written for the
// customer; `code` (PIN_REQUIRED, QUOTE_CHANGED…) says what the app should do.
class TvsQrException implements Exception {
  final String code;
  final String message;
  const TvsQrException(this.code, this.message);

  @override
  String toString() => message;
}

// TVS Wallet: balances and activity, adding money, sending coins, offers and
// invites, paying a shop by scanning its QR, the wallet PIN, and the KYC that
// activates the wallet. Payloads stay as the API sends them: amounts are
// strings with 2 decimals, never parsed to doubles.
@singleton
class TvsQrDataSource {
  final ApiClient _client;

  const TvsQrDataSource(this._client);

  // {kycStatus, activationRequired, wallets: [home wallet first:
  // {currency, status, available, bonus, spendable…}]}
  Future<Map<String, dynamic>> walletSummary() async {
    final response = await _client.dio.get(ApiEndpoints.tvsWallet);
    return unwrapEnvelope(response.data);
  }

  // {items: [{id, label, direction, bucket, amount, currency, balanceAfter,
  // createdAt, transaction: {type, details}}], nextCursor}, newest first.
  Future<Map<String, dynamic>> statement({
    String? walletUuid,
    String? cursor,
  }) async {
    final response = await _client.dio.get(
      ApiEndpoints.tvsStatement,
      queryParameters: {
        'walletUuid': ?walletUuid,
        'cursor': ?cursor,
        'limit': 20,
      },
    );
    return unwrapEnvelope(response.data);
  }

  // [{amount, remaining, expiresAt, waitingForActivation}], soonest expiry first.
  Future<List<dynamic>> bonusLots({String? walletUuid}) async {
    final response = await _client.dio.get(
      ApiEndpoints.tvsBonus,
      queryParameters: {'walletUuid': ?walletUuid},
    );
    return response.data['data']['data'] as List<dynamic>;
  }

  // Add money by card: {uuid, status, amount, currency, checkoutUrl…}.
  Future<Map<String, dynamic>> startTopup({
    required String amount,
    required String idempotencyKey,
    String? walletUuid,
  }) => _post(ApiEndpoints.tvsTopups, {
    'amount': amount,
    'idempotencyKey': idempotencyKey,
    'walletUuid': ?walletUuid,
  });

  // {status: PENDING | COMPLETED | FAILED…, failureMessage, refunded…}
  Future<Map<String, dynamic>> topup(String uuid) async {
    final response = await _client.dio.get(ApiEndpoints.tvsTopup(uuid));
    return unwrapEnvelope(response.data);
  }

  Future<Map<String, dynamic>> cancelTopup(String uuid) =>
      _post(ApiEndpoints.tvsTopupCancel(uuid), const <String, dynamic>{});

  // {recipient: {name, currency}, canSend, reason, available, pinAbove}
  Future<Map<String, dynamic>> resolveRecipient(String to) =>
      _post(ApiEndpoints.tvsTransferResolve, {'to': to});

  // Own coins only (bonus can't be sent). {amount, currency, to: {name}…}
  Future<Map<String, dynamic>> sendCoins({
    required String to,
    required String amount,
    required String idempotencyKey,
    String note = '',
    String? pin,
  }) => _post(ApiEndpoints.tvsTransfers, {
    'to': to,
    'amount': amount,
    'idempotencyKey': idempotencyKey,
    if (note.isNotEmpty) 'note': note,
    'pin': ?pin,
  });

  // {currency, location, coupons, forYou, inProgress, onTheWay}
  Future<Map<String, dynamic>> offers() async {
    final response = await _client.dio.get(ApiEndpoints.tvsOffers);
    return unwrapEnvelope(response.data);
  }

  // {items: [{uuid, name, at, note, amount, currency, status}]}
  Future<Map<String, dynamic>> rewardsHistory() async {
    final response = await _client.dio.get(
      ApiEndpoints.tvsOffersHistory,
      queryParameters: {'limit': 50},
    );
    return unwrapEnvelope(response.data);
  }

  // {code, link, programme, stats, canAddCode, joinedVia, friends}
  Future<Map<String, dynamic>> referrals() async {
    final response = await _client.dio.get(ApiEndpoints.tvsReferrals);
    return unwrapEnvelope(response.data);
  }

  // An order priced in TVS Coins. "Can't pay" is an answer, not an error:
  // {canPay, reasonCode, reason, coins: {total, currency, discount…},
  // wallet, pin: {required, isSet, length…}}
  Future<Map<String, dynamic>> checkoutQuote(Map<String, dynamic> basket) =>
      _post(ApiEndpoints.tvsCheckoutQuote, basket);

  // Pays `expectedCoins` for the basket; QUOTE_CHANGED if the price moved.
  // {order: {uuid, orderNumber}, bookings, coins…}
  Future<Map<String, dynamic>> checkoutPay(Map<String, dynamic> body) =>
      _post(ApiEndpoints.tvsCheckoutPay, body);

  // A membership plan priced in TVS Coins, paid from own coins only:
  // {canPay, reasonCode, reason, price, coins: {total, currency, available,
  // rateText…}, pin: {required, isSet, length, lockedUntil…}}
  Future<Map<String, dynamic>> membershipQuote(String planUuid) =>
      _post(ApiEndpoints.tvsMembershipQuote, {'planUuid': planUuid});

  // Pays `expectedCoins` and switches the plan on; QUOTE_CHANGED if the price
  // moved. {transactionUuid, coins, subscription: {uuid, reference, status}}
  Future<Map<String, dynamic>> membershipPay(Map<String, dynamic> body) =>
      _post(ApiEndpoints.tvsMembershipPay, body);

  // channel: CODE (typed), LINK or QR (an invite link or its QR).
  Future<Map<String, dynamic>> applyReferralCode(
    String code, {
    String channel = 'CODE',
  }) => _post(ApiEndpoints.tvsReferralApply, {
    'code': code,
    'channel': channel,
  });

  // Who an invite code is from, before login: {valid, code, type, name}.
  Future<Map<String, dynamic>> describeInvite(String code) async {
    final response = await _client.dio.get(ApiEndpoints.tvsInvite(code));
    return unwrapEnvelope(response.data);
  }

  Future<Map<String, dynamic>> resolve(String token) =>
      _post(ApiEndpoints.tvsQrResolve, {'token': token});

  // Moves no money.
  Future<Map<String, dynamic>> quote(
    String token,
    String amount,
    String code,
  ) => _post(ApiEndpoints.tvsQrQuote, {
    'token': token,
    'amount': amount,
    if (code.isNotEmpty) 'code': code,
  });

  Future<Map<String, dynamic>> pay({
    required String token,
    required String amount,
    required String code,
    required String idempotencyKey,
    required String expectedPayable,
    String? pin,
    String note = '',
  }) => _post(ApiEndpoints.tvsQrPay, {
    'token': token,
    'amount': amount,
    if (code.isNotEmpty) 'code': code,
    'idempotencyKey': idempotencyKey,
    'expectedPayable': expectedPayable,
    'pin': ?pin,
    if (note.isNotEmpty) 'note': note,
  });

  // The wallet MPIN. {isSet, length, lockedUntil}
  Future<Map<String, dynamic>> pinStatus() async {
    final response = await _client.dio.get(ApiEndpoints.tvsPin);
    return unwrapEnvelope(response.data);
  }

  // Changing an existing MPIN needs the current one.
  Future<void> setPin(String pin, {String? currentPin}) =>
      _post(ApiEndpoints.tvsPin, {'pin': pin, 'currentPin': ?currentPin});

  // Forgot MPIN: emails a 6-digit code. {sentTo, expiresInMinutes}
  Future<Map<String, dynamic>> requestPinReset() =>
      _post(ApiEndpoints.tvsPinResetRequest, const <String, dynamic>{});

  Future<void> confirmPinReset(String otp, String pin) =>
      _post(ApiEndpoints.tvsPinResetConfirm, {'otp': otp, 'pin': pin});

  // KYC activates the wallet: the user submits, an admin approves.
  // Each country: {country, name, documents: [{code, label, files}], rule}.
  Future<List<dynamic>> kycRequirements() async {
    final response = await _client.dio.get(ApiEndpoints.tvsKycRequirements);
    return response.data['data']['data'] as List<dynamic>;
  }

  // {status, canSubmit, attemptsLeft, legalName, latest: {status, reason…}}
  Future<Map<String, dynamic>> kycStatus() async {
    final response = await _client.dio.get(ApiEndpoints.tvsKyc);
    return unwrapEnvelope(response.data);
  }

  Future<Map<String, dynamic>> submitKyc(FormData form) =>
      _post(ApiEndpoints.tvsKyc, form);

  Future<Map<String, dynamic>> _post(String path, Object body) async {
    try {
      final response = await _client.dio.post(path, data: body);
      return unwrapEnvelope(response.data);
    } on DioException catch (e) {
      // ErrorInterceptor keeps only the message; the app needs the code too.
      final data = e.response?.data;
      if (data is Map && data['code'] is String) {
        throw TvsQrException(data['code'] as String, '${data['message']}');
      }
      rethrow;
    }
  }
}
