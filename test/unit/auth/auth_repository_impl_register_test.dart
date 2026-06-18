import 'package:bingo_pay/features/auth/data/datasources/auth_local_datasource.dart';
import 'package:bingo_pay/features/auth/data/datasources/auth_remote_datasource.dart';
import 'package:bingo_pay/features/auth/data/models/register_result_model.dart';
import 'package:bingo_pay/features/auth/data/models/user_model.dart';
import 'package:bingo_pay/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:mocktail/mocktail.dart';

class MockAuthRemoteDataSource extends Mock implements AuthRemoteDataSource {}
class MockAuthLocalDataSource extends Mock implements AuthLocalDataSource {}

void main() {
  const buyerUser = UserModel(
    id: '1', email: 'a@b.com', name: 'Alice Doe',
    role: 'buyer', kycStatus: 'not_required',
  );
  const vendorUser = UserModel(
    id: '2', email: 'owner@acme.com', name: 'Acme Owner',
    role: 'vendor', kycStatus: 'pending',
  );

  late MockAuthRemoteDataSource remote;
  late MockAuthLocalDataSource local;
  late AuthRepositoryImpl repo;

  setUpAll(() {
    registerFallbackValue(buyerUser);
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

  group('registerBuyer', () {
    test('saves token with empty refreshToken and returns the user', () async {
      when(() => remote.registerBuyer(
            firstName: 'Alice',
            lastName: 'Doe',
            email: 'a@b.com',
            phone: '9876543210',
            password: 'password1',
          )).thenAnswer((_) async => const RegisterResultModel(
            accessToken: 'buyer-jwt',
            user: buyerUser,
          ));

      final result = await repo.registerBuyer(
        firstName: 'Alice',
        lastName: 'Doe',
        email: 'a@b.com',
        phone: '9876543210',
        password: 'password1',
      );

      expect(result, const Right(buyerUser));
      verify(() => local.saveTokens(accessToken: 'buyer-jwt', refreshToken: ''))
          .called(1);
      verify(() => local.saveUser(buyerUser)).called(1);
    });
  });

  group('registerVendor', () {
    test('saves token with empty refreshToken and returns the user', () async {
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
          )).thenAnswer((_) async => const RegisterResultModel(
            accessToken: 'vendor-jwt',
            user: vendorUser,
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

      expect(result, const Right(vendorUser));
      verify(() => local.saveTokens(accessToken: 'vendor-jwt', refreshToken: ''))
          .called(1);
      verify(() => local.saveUser(vendorUser)).called(1);
    });
  });
}
