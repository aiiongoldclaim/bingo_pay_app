import 'package:bingo_pay/features/membershipNew/data/models/member_ship_model.dart';
import 'package:bingo_pay/features/membershipNew/domain/repositories/membership_repository.dart';
import 'package:mocktail/mocktail.dart';

class MockMembershipRepository extends Mock implements MembershipRepository {}

const ultraLuxeMembership = MembershipModel(
  plan: MembershipPlan(
    uuid: 'plan-ultra',
    code: 'ULTRA_LUXE',
    name: 'Ultra Luxe',
    kind: 'CUSTOMER_CLUB',
    rank: 2,
  ),
  subscription: MembershipSubscription(
    id: '1',
    uuid: 'sub-1',
    reference: 'ref-1',
    status: 'ACTIVE',
    startAt: null,
    endAt: null,
    billingCycle: 'MONTHLY',
    price: 0,
    currency: 'USD',
    autoRenew: true,
    planVersion: 1,
  ),
);

MembershipRepository fullAccessMembershipRepository() {
  final repo = MockMembershipRepository();
  when(repo.getMembership).thenAnswer((_) async => ultraLuxeMembership);
  return repo;
}
