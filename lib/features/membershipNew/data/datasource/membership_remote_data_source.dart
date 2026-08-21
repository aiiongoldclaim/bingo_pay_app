import 'package:injectable/injectable.dart';

import 'package:bingo_pay/core/error/exceptions.dart';

import '../../../../core/api/api_client.dart';
import '../../../../core/api/api_endpoints.dart';
import '../models/member_ship_model.dart';
import '../models/membership_plan_model.dart';
import '../models/membership_subscribe_model.dart';

abstract class MembershipRemoteDataSource {
  /// GET /membership
  Future<MembershipModel> fetchMembership();

  /// GET /membership/plans
  Future<List<MembershipPlanOption>> fetchPlans();

  /// POST /membership/subscribe
  Future<MembershipQuote> subscribe({required String planUuid});

  /// POST /membership/{uuid}/cancel
  Future<MembershipActionResult> cancel({required String subscriptionUuid});

  /// POST /membership/{uuid}/resume
  Future<MembershipActionResult> resume({required String subscriptionUuid});
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
    // Auth token AuthInterceptor se lag jaata hai.
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

    // rank ascending, phir price ascending
    plans.sort((a, b) {
      final byRank = a.rank.compareTo(b.rank);
      if (byRank != 0) return byRank;
      return (a.version?.price ?? 0).compareTo(b.version?.price ?? 0);
    });

    return plans;
  }

  // -------------------------------------------------------------------------
  // POST /membership/subscribe
  // -------------------------------------------------------------------------
  @override
  Future<MembershipQuote> subscribe({required String planUuid}) async {
    final response = await _apiClient.dio.post(
      ApiEndpoints.membershipSubscribe,
      data: {'planUuid': planUuid},          // ← planVersionUuid nahi
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
  // POST /membership/{uuid}/cancel
  // -------------------------------------------------------------------------
  @override
  Future<MembershipActionResult> cancel({
    required String subscriptionUuid,
  }) async {
    final response = await _apiClient.dio.post(
      ApiEndpoints.membershipCancel(subscriptionUuid),
    );

    return _actionResult(
      response.data,
      response.statusCode,
      'Could not cancel the membership',
    );
  }

  // -------------------------------------------------------------------------
  // POST /membership/{uuid}/resume
  // -------------------------------------------------------------------------
  @override
  Future<MembershipActionResult> resume({
    required String subscriptionUuid,
  }) async {
    final response = await _apiClient.dio.post(
      ApiEndpoints.membershipResume(subscriptionUuid),
    );

    return _actionResult(
      response.data,
      response.statusCode,
      'Could not resume the membership',
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

  MembershipActionResult _actionResult(
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

    return MembershipActionResult.fromJson(
      Map<String, dynamic>.from(inner),
      message: outer['message']?.toString() ?? '',
    );
  }
}