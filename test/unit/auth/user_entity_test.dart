import 'package:bingo_pay/features/auth/domain/entities/user_entity.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const user = UserEntity(id: '1', email: 'b@test.com', name: 'Bob');

  group('UserEntity', () {
    test('supports value equality', () {
      const same = UserEntity(id: '1', email: 'b@test.com', name: 'Bob');
      expect(user, equals(same));
    });

    test('differs when id changes', () {
      const other = UserEntity(id: '2', email: 'b@test.com', name: 'Bob');
      expect(user, isNot(equals(other)));
    });
  });
}
