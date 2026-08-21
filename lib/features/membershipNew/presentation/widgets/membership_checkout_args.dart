import '../../data/models/membership_plan_model.dart';
import '../../data/models/membership_subscribe_model.dart';

class MembershipCheckoutArgs {
  final MembershipPlanOption plan;
  final MembershipQuote quote;

  const MembershipCheckoutArgs({required this.plan, required this.quote});
}