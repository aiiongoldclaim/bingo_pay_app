import 'package:bingo_pay/features/auth/data/models/user_model.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const json = {
    'id': '1',
    'email': 'a@b.com',
    'name': 'Alice',
    'kycStatus': 'not_required',
    'emailVerified': false,
    'phoneVerified': false,
  };

  group('UserModel', () {
    test('fromJson creates correct model', () {
      final model = UserModel.fromJson(json);
      expect(model.id, '1');
      expect(model.kycStatus, 'not_required');
    });

    test('toJson round-trips correctly', () {
      final model = UserModel.fromJson(json);
      expect(model.toJson(), json);
    });

    test('inherits UserEntity behaviour', () {
      final model = UserModel.fromJson(json);
      expect(model.isKycApproved, isTrue);
    });
  });
}
