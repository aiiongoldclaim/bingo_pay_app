import 'package:injectable/injectable.dart';

import 'package:bingo_pay/core/error/exceptions.dart';

import '../../../../core/api/api_client.dart';
import '../../../../core/api/api_endpoints.dart';
import '../models/member_ship_model.dart';
import '../models/membership_balance_model.dart';
import '../models/membership_cancel_model.dart';
import '../models/membership_plan_model.dart';
import '../models/membership_subscribe_model.dart';

abstract class MembershipRemoteDataSource {
  /// GET /membership
  Future<MembershipModel> fetchMembership();

  /// GET /membership/plans
  Future<List<MembershipPlanOption>> fetchPlans();

  /// POST /membership/subscribe
  Future<MembershipQuote> subscribe({required String planUuid});

  /// PATCH /membership/{uuid}/cancel
  Future<MembershipCancelModel> cancel({required String subscriptionUuid});
  /// GET /payments/bigod/balance
  Future<BigodBalance> fetchBigodBalance();

  /// POST /payments/bigod/confirm
  Future<BigodConfirmResult> confirmBigodPayment({required String token});

}

@LazySingleton(as: MembershipRemoteDataSource)
class MembershipRemoteDataSourceImpl implements MembershipRemoteDataSource {
  final ApiClient _apiClient;

  MembershipRemoteDataSourceImpl(this._apiClient);

  // -------------------------------------------------------------------------
  // GET /membership
  // -------------------------------------------------------------------------
  @override
  Future<MembershipModel> fetchMembership() async {
    final response = await _apiClient.dio.get(ApiEndpoints.membership);

    final inner = _innerMap(
      response.data,
      response.statusCode,
      'Membership details not available',
    );

    return MembershipModel.fromJson(inner);
  }

  // -------------------------------------------------------------------------
  // GET /membership/plans
  // -------------------------------------------------------------------------
  @override
  Future<List<MembershipPlanOption>> fetchPlans() async {
    final response = await _apiClient.dio.get(ApiEndpoints.membershipPlans);

    final outer = _outerMap(
      response.data,
      response.statusCode,
      'No membership plans available',
    );
    final list = outer['data'];

    if (list is! List) {
      throw ServerException(
        statusCode: response.statusCode,
        message:
        outer['message']?.toString() ?? 'No membership plans available',
      );
    }

    final plans = list
        .whereType<Map>()
        .map((e) => MembershipPlanOption.fromJson(Map<String, dynamic>.from(e)))
        .where((p) => p.version?.isPublished ?? false)
        .toList();


    plans.sort((a, b) {
      final byRank = a.rank.compareTo(b.rank);
      if (byRank != 0) return byRank;
      return (a.version?.price ?? 0).compareTo(b.version?.price ?? 0);
    });

    return plans;
  }

  // -------------------------------------------------------------------------
  // POST /membership/subscribe    body: { planUuid }
  // -------------------------------------------------------------------------
  @override
  Future<MembershipQuote> subscribe({required String planUuid}) async {
    final response = await _apiClient.dio.post(
      ApiEndpoints.membershipSubscribe,
      data: {'planUuid': planUuid},
    );

    final outer = _outerMap(
      response.data,
      response.statusCode,
      'Could not start the subscription',
    );
    final inner = outer['data'];

    if (inner is! Map) {
      throw ServerException(
        statusCode: response.statusCode,
        message:
        outer['message']?.toString() ?? 'Could not start the subscription',
      );
    }

    return MembershipQuote.fromJson(
      Map<String, dynamic>.from(inner),
      message: outer['message']?.toString() ?? '',
    );
  }

  // -------------------------------------------------------------------------
  // PATCH /membership/{uuid}/cancel
  // -------------------------------------------------------------------------
  @override
  Future<MembershipCancelModel> cancel({
    required String subscriptionUuid,
  }) async {
    final response = await _apiClient.dio.patch(
      ApiEndpoints.membershipCancel(subscriptionUuid),
    );

    const fallback = 'Could not cancel the membership';

    final outer = _outerMap(response.data, response.statusCode, fallback);
    final inner = outer['data'];

    if (inner is! Map) {
      throw ServerException(
        statusCode: response.statusCode,
        message: outer['message']?.toString() ?? fallback,
      );
    }

    return MembershipCancelModel.fromJson(
      Map<String, dynamic>.from(inner),
      message: outer['message']?.toString() ?? '',
    );
  }

  // -------------------------------------------------------------------------
  // helpers — saare endpoints ka envelope same hai:
  // { success, statusCode, message, data: { message, data: <payload> } }
  // -------------------------------------------------------------------------

  Map<String, dynamic> _outerMap(
      dynamic body,
      int? statusCode,
      String fallback,
      ) {
    if (body is! Map) {
      throw ServerException(statusCode: statusCode, message: fallback);
    }

    final outer = body['data'];
    if (outer is! Map) {
      throw ServerException(
        statusCode: statusCode,
        message: body['message']?.toString() ?? fallback,
      );
    }

    return Map<String, dynamic>.from(outer);
  }

  Map<String, dynamic> _innerMap(
      dynamic body,
      int? statusCode,
      String fallback,
      ) {
    final outer = _outerMap(body, statusCode, fallback);
    final inner = outer['data'];

    if (inner is! Map) {
      throw ServerException(
        statusCode: statusCode,
        message: outer['message']?.toString() ?? fallback,
      );
    }

    return Map<String, dynamic>.from(inner);
  }


  @override
  Future<BigodBalance> fetchBigodBalance() async {
    print('>>> GET BIGOD BALANCE');

    final response = await _apiClient.dio.get(
      ApiEndpoints.bigodBalance,
    );

    print(
      '<<< BIGOD BALANCE STATUS: ${response.statusCode}',
    );

    print(
      '<<< BIGOD BALANCE RESPONSE: ${response.data}',
    );

    final outer = _outerMap(
      response.data,
      response.statusCode,
      'Could not fetch balance',
    );

    final inner = outer['data'];

    if (inner is! Map) {
      throw ServerException(
        statusCode: response.statusCode,
        message: 'Could not fetch balance',
      );
    }

    final payload =
        inner['data'] ?? inner;

    if (payload is! Map) {
      throw ServerException(
        statusCode: response.statusCode,
        message: 'Invalid balance response',
      );
    }

    return BigodBalance.fromJson(
      Map<String, dynamic>.from(payload),
    );
  }

  @override
  Future<BigodConfirmResult> confirmBigodPayment({
    required String token,
  }) async {
    print('>>> POST BIGOD CONFIRM');
    print('>>> TOKEN: $token');

    final response = await _apiClient.dio.post(
      ApiEndpoints.bigodConfirm,
      data: {
        'token': token,
      },
    );

    print(
      '<<< BIGOD CONFIRM STATUS: ${response.statusCode}',
    );

    print(
      '<<< BIGOD CONFIRM RESPONSE: ${response.data}',
    );

    final outer = _outerMap(
      response.data,
      response.statusCode,
      'Payment confirmation failed',
    );

    final inner = outer['data'];

    if (inner is! Map) {
      throw ServerException(
        statusCode: response.statusCode,
        message: 'Payment confirmation failed',
      );
    }

    final payload =
        inner['data'] ?? inner;

    if (payload is! Map) {
      throw ServerException(
        statusCode: response.statusCode,
        message: 'Invalid confirmation response',
      );
    }

    return BigodConfirmResult.fromJson(
      Map<String, dynamic>.from(payload),
    );
  }


}