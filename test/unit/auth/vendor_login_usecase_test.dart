import 'package:bingo_pay/core/error/failures.dart';
import 'package:bingo_pay/features/auth/domain/entities/user_entity.dart';
import 'package:bingo_pay/features/auth/domain/repositories/auth_repository.dart';
import 'package:bingo_pay/features/auth/domain/usecases/vendor_login_usecase.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:mocktail/mocktail.dart';

class MockAuthRepository extends Mock implements AuthRepository {}

void main() {
  const user = UserEntity(
    id: 'dd4e8bf9-9ad6-4940-b373-f99f28a6dae2',
    email: 'owner13@acme.com',
    name: 'Acme Owner',
    role: 'vendor',
    kycStatus: 'approved',
  );

  group('VendorLoginUseCase', () {
    test('delegates to repository.vendorLogin with params', () async {
      final repo = MockAuthRepository();
      when(() => repo.vendorLogin(
            identifier: 'owner13@acme.com',
            password: 'Secret@123',
          )).thenAnswer((_) async => const Right(user));

      final useCase = VendorLoginUseCase(repo);
      final result = await useCase(const VendorLoginParams(
        identifier: 'owner13@acme.com',
        password: 'Secret@123',
      ));

      expect(result, const Right<Failure, UserEntity>(user));
    });
  });
}
