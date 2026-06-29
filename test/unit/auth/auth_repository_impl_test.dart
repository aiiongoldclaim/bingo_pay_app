import 'package:bingo_pay/core/error/failures.dart';
import 'package:bingo_pay/features/auth/data/datasources/auth_local_datasource.dart';
import 'package:bingo_pay/features/auth/data/datasources/auth_remote_datasource.dart';
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

  group('getStoredUser', () {
    test('returns null when local has no user', () async {
      when(() => local.getUser()).thenAnswer((_) async => null);
      final result = await repo.getStoredUser();
      expect(result, const Right<Failure, UserModel?>(null));
    });
  });

  group('checkEmailExists', () {
    test('returns true when the remote datasource reports the user exists', () async {
      when(() => remote.checkUserExists(email: 'nishant.vendor@yopmail.com'))
          .thenAnswer((_) async => true);

      final result = await repo.checkEmailExists(email: 'nishant.vendor@yopmail.com');

      expect(result, const Right<Failure, bool>(true));
    });

    test('returns false when the remote datasource reports the user does not exist', () async {
      when(() => remote.checkUserExists(email: 'nishant.vendor2@yopmail.com'))
          .thenAnswer((_) async => false);

      final result = await repo.checkEmailExists(email: 'nishant.vendor2@yopmail.com');

      expect(result, const Right<Failure, bool>(false));
    });
  });
}
