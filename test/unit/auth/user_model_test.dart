import 'package:bingo_pay/features/auth/data/models/user_model.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const json = {
    'id': '1',
    'email': 'a@b.com',
    'name': 'Alice',
    'role': 'buyer',
    'kycStatus': 'not_required',
  };

  group('UserModel', () {
    test('fromJson creates correct model', () {
      final model = UserModel.fromJson(json);
      expect(model.id, '1');
      expect(model.role, 'buyer');
      expect(model.kycStatus, 'not_required');
    });

    test('toJson round-trips correctly', () {
      final model = UserModel.fromJson(json);
      expect(model.toJson(), json);
    });

    test('inherits UserEntity behaviour', () {
      final model = UserModel.fromJson(json);
      expect(model.isBuyer, isTrue);
      expect(model.isKycApproved, isTrue);
    });
  });
}
