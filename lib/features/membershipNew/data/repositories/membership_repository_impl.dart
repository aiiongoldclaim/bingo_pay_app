import 'package:injectable/injectable.dart';

import '../../domain/repositories/membership_repository.dart';
import '../datasource/membership_remote_data_source.dart';
import '../models/member_ship_model.dart';
import '../models/membership_balance_model.dart';
import '../models/membership_cancel_model.dart';
import '../models/membership_plan_model.dart';
import '../models/membership_resume_model.dart';
import '../models/membership_subscribe_model.dart';

@LazySingleton(as: MembershipRepository)
class MembershipRepositoryImpl implements MembershipRepository {
  final MembershipRemoteDataSource _remoteDataSource;

  MembershipRepositoryImpl(this._remoteDataSource);

  @override
  Future<MembershipModel> getMembership() => _remoteDataSource.fetchMembership();

  @override
  Future<List<MembershipPlanOption>> getPlans() => _remoteDataSource.fetchPlans();

  @override
  Future<MembershipQuote> subscribe(String planUuid) =>
      _remoteDataSource.subscribe(planUuid: planUuid);

  @override
  Future<MembershipCancelModel> cancel(String subscriptionUuid) =>
      _remoteDataSource.cancel(subscriptionUuid: subscriptionUuid);

  @override
  Future<MembershipResumeModel> resume(String subscriptionUuid) =>
      _remoteDataSource.resume(subscriptionUuid: subscriptionUuid);

  @override
  Future<BigodBalance> getBigodBalance() => _remoteDataSource.fetchBigodBalance();

  @override
  Future<BigodConfirmResult> confirmBigodPayment(String token) =>
      _remoteDataSource.confirmBigodPayment(token: token);
}