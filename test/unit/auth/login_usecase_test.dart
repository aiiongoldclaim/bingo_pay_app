import 'package:bingo_pay/core/error/failures.dart';
import 'package:bingo_pay/features/auth/domain/entities/user_entity.dart';
import 'package:bingo_pay/features/auth/domain/repositories/auth_repository.dart';
import 'package:bingo_pay/features/auth/domain/usecases/login_usecase.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:mocktail/mocktail.dart';

class MockAuthRepository extends Mock implements AuthRepository {}

void main() {
  late MockAuthRepository repo;
  late LoginUseCase useCase;

  setUp(() {
    repo = MockAuthRepository();
    useCase = LoginUseCase(repo);
  });

  const params = LoginParams(email: 'a@b.com', password: 'pass123');
  const user = UserEntity(
    id: '1', email: 'a@b.com', name: 'Alice',
    kycStatus: 'not_required',
  );

  test('returns UserEntity on success', () async {
    when(() => repo.login(email: 'a@b.com', password: 'pass123'))
        .thenAnswer((_) async => const Right(user));

    final result = await useCase(params);
    expect(result, const Right<Failure, UserEntity>(user));
  });

  test('returns Failure on error', () async {
    const failure = NetworkFailure();
    when(() => repo.login(email: 'a@b.com', password: 'pass123'))
        .thenAnswer((_) async => const Left(failure));

    final result = await useCase(params);
    expect(result, const Left<Failure, UserEntity>(failure));
  });
}
