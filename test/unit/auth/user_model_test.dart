import 'package:bingo_pay/features/auth/data/models/user_model.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const json = {
    'id': '1',
    'email': 'a@b.com',
    'name': 'Alice',
    'phone': '9876543210',
  };

  group('UserModel', () {
    test('fromJson creates correct model', () {
      final model = UserModel.fromJson(json);
      expect(model.id, '1');
      expect(model.email, 'a@b.com');
      expect(model.name, 'Alice');
      expect(model.phone, '9876543210');
    });

    test('toJson round-trips correctly', () {
      final model = UserModel.fromJson(json);
      expect(model.toJson(), json);
    });
  });
}
