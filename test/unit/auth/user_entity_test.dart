import 'package:bingo_pay/features/auth/domain/entities/user_entity.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const buyer = UserEntity(
    id: '1', email: 'b@test.com', name: 'Bob', role: 'buyer', kycStatus: 'not_required',
  );
  const vendor = UserEntity(
    id: '2', email: 'v@test.com', name: 'Ven', role: 'vendor', kycStatus: 'pending',
  );

  group('UserEntity', () {
    test('isBuyer/isVendor returns correct role', () {
      expect(buyer.isBuyer, isTrue);
      expect(buyer.isVendor, isFalse);
      expect(vendor.isVendor, isTrue);
    });

    test('isKycApproved for not_required buyer', () {
      expect(buyer.isKycApproved, isTrue);
      expect(buyer.isKycPending, isFalse);
    });

    test('isKycPending for pending vendor', () {
      expect(vendor.isKycPending, isTrue);
      expect(vendor.isKycApproved, isFalse);
    });

    test('supports value equality', () {
      const same = UserEntity(
        id: '1', email: 'b@test.com', name: 'Bob', role: 'buyer', kycStatus: 'not_required',
      );
      expect(buyer, equals(same));
    });
  });
}
