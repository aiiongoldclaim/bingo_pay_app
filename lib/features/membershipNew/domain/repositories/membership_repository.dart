import '../../data/models/member_ship_model.dart';
import '../../data/models/membership_balance_model.dart';
import '../../data/models/membership_cancel_model.dart';
import '../../data/models/membership_plan_model.dart';
import '../../data/models/membership_resume_model.dart';
import '../../data/models/membership_subscribe_model.dart';

abstract class MembershipRepository {
  Future<MembershipModel> getMembership();

  Future<List<MembershipPlanOption>> getPlans();

  Future<MembershipQuote> subscribe(String planUuid);

  Future<MembershipCancelModel> cancel(String subscriptionUuid);

  Future<MembershipResumeModel> resume(String subscriptionUuid);

  Future<BigodBalance> getBigodBalance();

  Future<BigodConfirmResult> confirmBigodPayment(String token);
}