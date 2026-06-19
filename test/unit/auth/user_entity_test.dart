import 'package:bingo_pay/features/auth/domain/entities/user_entity.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const approvedVendor = UserEntity(
    id: '1', email: 'a@test.com', name: 'Ana', role: 'vendor', kycStatus: 'not_required',
  );
  const pendingVendor = UserEntity(
    id: '2', email: 'v@test.com', name: 'Ven', role: 'vendor', kycStatus: 'pending',
  );

  group('UserEntity', () {
    test('isVendor returns true', () {
      expect(approvedVendor.isVendor, isTrue);
      expect(pendingVendor.isVendor, isTrue);
    });

    test('isKycApproved for not_required vendor', () {
      expect(approvedVendor.isKycApproved, isTrue);
      expect(approvedVendor.isKycPending, isFalse);
    });

    test('isKycPending for pending vendor', () {
      expect(pendingVendor.isKycPending, isTrue);
      expect(pendingVendor.isKycApproved, isFalse);
    });

    test('supports value equality', () {
      const same = UserEntity(
        id: '1', email: 'a@test.com', name: 'Ana', role: 'vendor', kycStatus: 'not_required',
      );
      expect(approvedVendor, equals(same));
    });
  });
}
