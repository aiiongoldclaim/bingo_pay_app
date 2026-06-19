import 'package:bingo_pay/core/error/exceptions.dart';
import 'package:bingo_pay/core/error/failures.dart';
import 'package:bingo_pay/features/auth/data/datasources/auth_local_datasource.dart';
import 'package:bingo_pay/features/auth/data/datasources/auth_remote_datasource.dart';
import 'package:bingo_pay/features/auth/data/models/user_model.dart';
import 'package:bingo_pay/features/auth/data/models/vendor_login_result_model.dart';
import 'package:bingo_pay/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:mocktail/mocktail.dart';

class MockAuthRemoteDataSource extends Mock implements AuthRemoteDataSource {}
class MockAuthLocalDataSource extends Mock implements AuthLocalDataSource {}

void main() {
  const vendorUser = UserModel(
    id: 'dd4e8bf9-9ad6-4940-b373-f99f28a6dae2',
    email: 'owner13@acme.com',
    name: 'Acme Owner',
    role: 'vendor',
    kycStatus: 'approved',
    shopName: 'Acme Store',
    merchantCode: 'MER0861525',
    businessName: 'Acme Pvt Ltd',
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

  group('vendorLogin', () {
    test('saves token with empty refreshToken and returns the user', () async {
      when(() => remote.vendorLogin(
            identifier: 'owner13@acme.com',
            password: 'Secret@123',
          )).thenAnswer((_) async => const VendorLoginResultModel(
            accessToken: 'vendor-login-jwt',
            user: vendorUser,
          ));

      final result = await repo.vendorLogin(
        identifier: 'owner13@acme.com',
        password: 'Secret@123',
      );

      expect(result, const Right(vendorUser));
      verify(() => local.saveTokens(
            accessToken: 'vendor-login-jwt',
            refreshToken: '',
          )).called(1);
      verify(() => local.saveUser(vendorUser)).called(1);
    });

    test('returns a Failure instead of throwing when remote throws a '
        'DioException wrapping a mapped exception (e.g. wrong password)', () async {
      final dioError = DioException(
        requestOptions: RequestOptions(path: '/vendors/sso/login'),
        error: const AuthException(message: 'Invalid credentials'),
      );
      when(() => remote.vendorLogin(
            identifier: any(named: 'identifier'),
            password: any(named: 'password'),
          )).thenThrow(dioError);

      final result = await repo.vendorLogin(
        identifier: 'owner13@acme.com',
        password: 'wrong-password',
      );

      expect(result.isLeft(), isTrue);
      final failure = result.fold((f) => f, (_) => null);
      expect(failure, isA<AuthFailure>());
      expect(failure!.message, 'Invalid credentials');
    });

    test('returns a Failure instead of throwing when remote throws a '
        'non-Exception error (e.g. a TypeError from malformed JSON)', () async {
      when(() => remote.vendorLogin(
            identifier: any(named: 'identifier'),
            password: any(named: 'password'),
          )).thenThrow(TypeError());

      final result = await repo.vendorLogin(
        identifier: 'owner13@acme.com',
        password: 'Secret@123',
      );

      expect(result.isLeft(), isTrue);
    });
  });
}
