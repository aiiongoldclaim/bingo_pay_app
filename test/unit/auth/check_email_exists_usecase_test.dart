import 'package:bingo_pay/core/error/failures.dart';
import 'package:bingo_pay/features/auth/domain/repositories/auth_repository.dart';
import 'package:bingo_pay/features/auth/domain/usecases/check_email_exists_usecase.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:mocktail/mocktail.dart';

class MockAuthRepository extends Mock implements AuthRepository {}

void main() {
  group('CheckEmailExistsUseCase', () {
    test('delegates to repository.checkEmailExists and returns true when the user exists', () async {
      final repo = MockAuthRepository();
      when(() => repo.checkEmailExists(email: 'nishant.vendor@yopmail.com'))
          .thenAnswer((_) async => const Right(true));

      final useCase = CheckEmailExistsUseCase(repo);
      final result = await useCase('nishant.vendor@yopmail.com');

      expect(result, const Right<Failure, bool>(true));
    });

    test('returns false when the user does not exist', () async {
      final repo = MockAuthRepository();
      when(() => repo.checkEmailExists(email: 'nishant.vendor2@yopmail.com'))
          .thenAnswer((_) async => const Right(false));

      final useCase = CheckEmailExistsUseCase(repo);
      final result = await useCase('nishant.vendor2@yopmail.com');

      expect(result, const Right<Failure, bool>(false));
    });
  });
}
