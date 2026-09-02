// import 'package:injectable/injectable.dart';
//
// import '../datasource/membership_remote_data_source.dart';
// import '../models/member_ship_model.dart';
// import '../models/membership_balance_model.dart';
// import '../models/membership_cancel_model.dart';
// import '../models/membership_plan_model.dart';
// import '../models/membership_resume_model.dart';
// import '../models/membership_subscribe_model.dart';
//
// abstract class MembershipRepository {
//   Future<MembershipModel> getMembership();
//
//   Future<List<MembershipPlanOption>> getPlans();
//
//   Future<MembershipQuote> subscribe(String planUuid);
//
//   Future<MembershipCancelModel> cancel(String subscriptionUuid);
//
//   Future<BigodBalance> getBigodBalance();
//
//   Future<MembershipResumeModel> resume(String subscriptionUuid);
//
//   Future<BigodConfirmResult> confirmBigodPayment(String token);
// }
//
// @LazySingleton(as: MembershipRepository)
// class MembershipRepositoryImpl implements MembershipRepository {
//   final MembershipRemoteDataSource _remote;
//
//   MembershipRepositoryImpl(this._remote);
//
//   @override
//   Future<MembershipModel> getMembership() => _remote.fetchMembership();
//
//   @LazySingleton(as: MembershipRemoteDataSource)
//   @override
//   Future<List<MembershipPlanOption>> getPlans() => _remote.fetchPlans();
//
//   @override
//   Future<MembershipQuote> subscribe(String planUuid) =>
//       _remote.subscribe(planUuid: planUuid);
//
//   @override
//   Future<MembershipCancelModel> cancel(String subscriptionUuid) =>
//       _remote.cancel(subscriptionUuid: subscriptionUuid);
//
//
//   @override
//   Future<BigodBalance> getBigodBalance() {
//     return _remote.fetchBigodBalance();
//   }
//
//   @override
//   Future<BigodConfirmResult> confirmBigodPayment(String token) {
//     return _remote.confirmBigodPayment(
//       token: token,
//     );
//   }
//
//   @override
//   Future<MembershipResumeModel> resume(String subscriptionUuid) {
//     return _remote.resume(
//       subscriptionUuid: subscriptionUuid,
//     );
//   }
// }