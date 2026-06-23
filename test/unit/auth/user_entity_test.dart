import 'package:bingo_pay/features/auth/domain/entities/user_entity.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const buyer = UserEntity(
    id: '1', email: 'b@test.com', name: 'Bob', kycStatus: 'not_required',
  );
  const vendor = UserEntity(
    id: '2', email: 'v@test.com', name: 'Ven', kycStatus: 'pending',
  );

  group('UserEntity', () {
    test('isKycApproved for not_required user', () {
      expect(buyer.isKycApproved, isTrue);
      expect(buyer.isKycPending, isFalse);
    });

    test('isKycPending for pending user', () {
      expect(vendor.isKycPending, isTrue);
      expect(vendor.isKycApproved, isFalse);
    });

    test('supports value equality', () {
      const same = UserEntity(
        id: '1', email: 'b@test.com', name: 'Bob', kycStatus: 'not_required',
      );
      expect(buyer, equals(same));
    });
  });
}
