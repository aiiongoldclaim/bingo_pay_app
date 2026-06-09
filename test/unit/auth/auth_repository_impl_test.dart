import 'package:bingo_pay/core/error/exceptions.dart';
import 'package:bingo_pay/core/error/failures.dart';
import 'package:bingo_pay/features/auth/data/datasources/auth_local_datasource.dart';
import 'package:bingo_pay/features/auth/data/datasources/auth_remote_datasource.dart';
import 'package:bingo_pay/features/auth/data/models/auth_response_model.dart';
import 'package:bingo_pay/features/auth/data/models/user_model.dart';
import 'package:bingo_pay/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:mocktail/mocktail.dart';

class MockAuthRemote extends Mock implements AuthRemoteDataSource {}
class MockAuthLocal extends Mock implements AuthLocalDataSource {}

void main() {
  late MockAuthRemote remote;
  late MockAuthLocal local;
  late AuthRepositoryImpl repo;

  setUp(() {
    remote = MockAuthRemote();
    local = MockAuthLocal();
    repo = AuthRepositoryImpl(remote, local);
  });

  const user = UserModel(
    id: '1', email: 'a@b.com', name: 'Alice',
    role: 'buyer', kycStatus: 'not_required',
  );
  const response = AuthResponseModel(
    accessToken: 'acc', refreshToken: 'ref', user: user,
  );

  group('login', () {
    test('saves tokens and returns user on success', () async {
      when(() => remote.login(email: 'a@b.com', password: 'pw'))
          .thenAnswer((_) async => response);
      when(() => local.saveTokens(accessToken: 'acc', refreshToken: 'ref'))
          .thenAnswer((_) async {});
      when(() => local.saveUser(user)).thenAnswer((_) async {});

      final result = await repo.login(email: 'a@b.com', password: 'pw');

      expect(result, Right<Failure, UserModel>(user));
      verify(() => local.saveTokens(accessToken: 'acc', refreshToken: 'ref'))
          .called(1);
    });

    test('returns NetworkFailure when NetworkException thrown', () async {
      when(() => remote.login(
            email: any(named: 'email'),
            password: any(named: 'password'),
          )).thenThrow(NetworkException());

      final result = await repo.login(email: 'a@b.com', password: 'pw');
      expect(result.isLeft(), isTrue);
      expect(result.fold((f) => f, (_) => null), isA<NetworkFailure>());
    });
  });

  group('getStoredUser', () {
    test('returns null when local has no user', () async {
      when(() => local.getUser()).thenAnswer((_) async => null);
      final result = await repo.getStoredUser();
      expect(result, const Right<Failure, UserModel?>(null));
    });
  });
}
