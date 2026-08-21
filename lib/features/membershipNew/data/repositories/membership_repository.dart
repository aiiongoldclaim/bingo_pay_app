import 'package:injectable/injectable.dart';

import '../datasource/membership_remote_data_source.dart';
import '../models/member_ship_model.dart';
import '../models/membership_plan_model.dart';
import '../models/membership_subscribe_model.dart';

abstract class MembershipRepository {
  Future<MembershipModel> getMembership();

  Future<List<MembershipPlanOption>> getPlans();

  Future<MembershipQuote> subscribe(String planUuid);

  Future<MembershipActionResult> cancel(String subscriptionUuid);

  Future<MembershipActionResult> resume(String subscriptionUuid);
}

@LazySingleton(as: MembershipRepository)
class MembershipRepositoryImpl implements MembershipRepository {
  final MembershipRemoteDataSource _remote;

  MembershipRepositoryImpl(this._remote);

  @override
  Future<MembershipModel> getMembership() => _remote.fetchMembership();

  @override
  Future<List<MembershipPlanOption>> getPlans() => _remote.fetchPlans();

  @override
  Future<MembershipQuote> subscribe(String planUuid) =>
      _remote.subscribe(planUuid: planUuid);

  @override
  Future<MembershipActionResult> cancel(String subscriptionUuid) =>
      _remote.cancel(subscriptionUuid: subscriptionUuid);

  @override
  Future<MembershipActionResult> resume(String subscriptionUuid) =>
      _remote.resume(subscriptionUuid: subscriptionUuid);
}