import 'package:bingo_pay/core/error/failures.dart';
import 'package:bingo_pay/features/auth/domain/entities/user_entity.dart';
import 'package:bingo_pay/features/auth/domain/repositories/auth_repository.dart';
import 'package:bingo_pay/features/auth/domain/usecases/register_vendor_usecase.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:mocktail/mocktail.dart';

class MockAuthRepository extends Mock implements AuthRepository {}

void main() {
  const user = UserEntity(
    id: '1', email: 'owner@acme.com', name: 'Acme Owner',
    role: 'vendor', kycStatus: 'pending',
  );

  group('RegisterVendorUseCase', () {
    test('delegates to repository.registerVendor with params', () async {
      final repo = MockAuthRepository();
      when(() => repo.registerVendor(
            firstName: 'Acme',
            lastName: 'Owner',
            email: 'owner@acme.com',
            phone: '9876543210',
            password: 'password1',
            shopName: 'Acme Store',
            shopSlug: 'acme-store',
            businessName: 'Acme Pvt Ltd',
            description: null,
            gstNumber: null,
            panNumber: null,
            supportEmail: null,
            supportPhone: null,
          )).thenAnswer((_) async => const Right(user));

      final useCase = RegisterVendorUseCase(repo);
      final result = await useCase(const VendorRegisterParams(
        firstName: 'Acme',
        lastName: 'Owner',
        email: 'owner@acme.com',
        phone: '9876543210',
        password: 'password1',
        shopName: 'Acme Store',
        shopSlug: 'acme-store',
        businessName: 'Acme Pvt Ltd',
      ));

      expect(result, const Right<Failure, UserEntity>(user));
    });
  });
}
