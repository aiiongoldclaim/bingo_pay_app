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
}
