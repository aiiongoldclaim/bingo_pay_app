import 'package:bingo_pay/core/error/failures.dart';
import 'package:bingo_pay/features/auth/domain/entities/register_otp_entity.dart';
import 'package:bingo_pay/features/auth/domain/entities/user_entity.dart';
import 'package:bingo_pay/features/auth/domain/repositories/auth_repository.dart';
import 'package:bingo_pay/features/auth/domain/usecases/register_vendor_usecase.dart';
import 'package:bingo_pay/features/auth/domain/usecases/verify_vendor_otp_usecase.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:mocktail/mocktail.dart';

class MockAuthRepository extends Mock implements AuthRepository {}

void main() {
  const otpInfo = RegisterOtpEntity(
    email: 'owner@acme.com',
    message: 'OTP sent to your email. Verify it to complete vendor registration.',
  );

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
          )).thenAnswer((_) async => const Right(otpInfo));

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

      expect(result, const Right<Failure, RegisterOtpEntity>(otpInfo));
    });
  });

  group('VerifyVendorOtpUseCase', () {
    test('delegates to repository.verifyVendorOtp with params', () async {
      final repo = MockAuthRepository();
      when(() => repo.verifyVendorOtp(
            email: 'owner@acme.com',
            otp: '942653',
          )).thenAnswer((_) async => const Right(user));

      final useCase = VerifyVendorOtpUseCase(repo);
      final result = await useCase(const VerifyVendorOtpParams(
        email: 'owner@acme.com',
        otp: '942653',
      ));

      expect(result, const Right<Failure, UserEntity>(user));
    });
  });
}
