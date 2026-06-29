import 'package:bingo_pay/features/auth/data/datasources/auth_local_datasource.dart';
import 'package:bingo_pay/features/auth/data/datasources/auth_remote_datasource.dart';
import 'package:bingo_pay/features/auth/data/models/register_otp_model.dart';
import 'package:bingo_pay/features/auth/data/models/register_result_model.dart';
import 'package:bingo_pay/features/auth/data/models/user_model.dart';
import 'package:bingo_pay/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:bingo_pay/features/auth/domain/entities/register_otp_entity.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:mocktail/mocktail.dart';

class MockAuthRemoteDataSource extends Mock implements AuthRemoteDataSource {}
class MockAuthLocalDataSource extends Mock implements AuthLocalDataSource {}

void main() {
  const vendorUser = UserModel(
    id: '2', email: 'owner@acme.com', name: 'Acme Owner',
    role: 'vendor', kycStatus: 'pending',
  );

  late MockAuthRemoteDataSource remote;
  late MockAuthLocalDataSource local;
  late AuthRepositoryImpl repo;

  setUpAll(() {
    registerFallbackValue(vendorUser);
  });

  setUp(() {
    remote = MockAuthRemoteDataSource();
    local = MockAuthLocalDataSource();
    repo = AuthRepositoryImpl(remote, local);
    when(() => local.saveTokens(
          accessToken: any(named: 'accessToken'),
          refreshToken: any(named: 'refreshToken'),
        )).thenAnswer((_) async {});
    when(() => local.saveUser(any())).thenAnswer((_) async {});
  });

  group('registerVendor', () {
    test('returns otp info without saving any token yet', () async {
      when(() => remote.registerVendor(
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
          )).thenAnswer((_) async => const RegisterOtpModel(
            otpSent: true,
            email: 'owner@acme.com',
            message: 'OTP sent to your email. Verify it to complete vendor registration.',
          ));

      final result = await repo.registerVendor(
        firstName: 'Acme',
        lastName: 'Owner',
        email: 'owner@acme.com',
        phone: '9876543210',
        password: 'password1',
        shopName: 'Acme Store',
        shopSlug: 'acme-store',
        businessName: 'Acme Pvt Ltd',
      );

      expect(
        result,
        const Right(RegisterOtpEntity(
          email: 'owner@acme.com',
          message: 'OTP sent to your email. Verify it to complete vendor registration.',
        )),
      );
      verifyNever(() => local.saveTokens(
            accessToken: any(named: 'accessToken'),
            refreshToken: any(named: 'refreshToken'),
          ));
      verifyNever(() => local.saveUser(any()));
    });
  });

  group('verifyVendorOtp', () {
    test('saves the access and refresh tokens and returns the user', () async {
      when(() => remote.verifyVendorOtp(
            email: 'owner@acme.com',
            otp: '942653',
          )).thenAnswer((_) async => const RegisterResultModel(
            accessToken: 'vendor-jwt',
            refreshToken: 'vendor-refresh-jwt',
            user: vendorUser,
          ));

      final result = await repo.verifyVendorOtp(
        email: 'owner@acme.com',
        otp: '942653',
      );

      expect(result, const Right(vendorUser));
      verify(() => local.saveTokens(
            accessToken: 'vendor-jwt',
            refreshToken: 'vendor-refresh-jwt',
          )).called(1);
      verify(() => local.saveUser(vendorUser)).called(1);
    });
  });
}
