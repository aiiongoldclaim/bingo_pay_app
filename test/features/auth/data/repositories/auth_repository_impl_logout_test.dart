import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:mocktail/mocktail.dart';
import 'package:bingo_pay/core/error/exceptions.dart';
import 'package:bingo_pay/features/auth/data/datasources/auth_local_datasource.dart';
import 'package:bingo_pay/features/auth/data/datasources/auth_remote_datasource.dart';
import 'package:bingo_pay/features/auth/data/repositories/auth_repository_impl.dart';

class MockAuthRemoteDataSource extends Mock implements AuthRemoteDataSource {}

class MockAuthLocalDataSource extends Mock implements AuthLocalDataSource {}

void main() {
  late AuthRepositoryImpl repository;
  late MockAuthRemoteDataSource mockRemote;
  late MockAuthLocalDataSource mockLocal;

  setUp(() {
    mockRemote = MockAuthRemoteDataSource();
    mockLocal = MockAuthLocalDataSource();
    repository = AuthRepositoryImpl(mockRemote, mockLocal);
  });

  group('AuthRepositoryImpl.logout', () {
    test('should successfully logout when both remote and local succeed', () async {
      // Arrange
      final expectedMessage = 'Session terminated successfully';
      when(() => mockRemote.logout()).thenAnswer((_) async => expectedMessage);
      when(() => mockLocal.clearAll()).thenAnswer((_) async {});

      // Act
      final result = await repository.logout();

      // Assert
      expect(result, isA<Right>());
      result.fold(
        (failure) => fail('Expected Right but got Left: $failure'),
        (message) => expect(message, expectedMessage),
      );

      // Verify both remote and local were called
      verify(() => mockRemote.logout()).called(1);
      verify(() => mockLocal.clearAll()).called(1);
    });

    test('should clear local state even when remote logout fails with exception',
        () async {
      // Arrange: Remote logout throws exception
      when(() => mockRemote.logout())
          .thenThrow(const ServerException(message: 'Server error'));
      when(() => mockLocal.clearAll()).thenAnswer((_) async {});

      // Act
      final result = await repository.logout();

      // Assert: Should return success with default message despite remote failure
      expect(result, isA<Right>());
      result.fold(
        (failure) => fail('Expected Right but got Left: $failure'),
        (message) =>
            expect(message, 'Logged out successfully'), // Default message
      );

      // Verify local clear was still called (best-effort)
      verify(() => mockRemote.logout()).called(1);
      verify(() => mockLocal.clearAll()).called(1);
    });

    test('should return failure only when local state clearance fails', () async {
      // Arrange: Remote succeeds but local fails
      final remoteMessage = 'Remote logout ok';
      when(() => mockRemote.logout()).thenAnswer((_) async => remoteMessage);
      when(() => mockLocal.clearAll())
          .thenThrow(Exception('Failed to clear local storage'));

      // Act
      final result = await repository.logout();

      // Assert: Should return failure since local logout failed
      expect(result, isA<Left>());
      result.fold(
        (failure) => expect(failure.message, contains('Failed to clear')),
        (message) =>
            fail('Expected Left but got Right: $message'),
      );

      verify(() => mockRemote.logout()).called(1);
      verify(() => mockLocal.clearAll()).called(1);
    });

    test('should return failure when local clear fails, even if remote failed first',
        () async {
      // Arrange: Both remote and local fail
      when(() => mockRemote.logout())
          .thenThrow(const NetworkException()); // Network error
      when(() => mockLocal.clearAll())
          .thenThrow(Exception('Storage error'));

      // Act
      final result = await repository.logout();

      // Assert: Should return the local failure (which is more critical)
      expect(result, isA<Left>());
      result.fold(
        (failure) => expect(failure.message, contains('Storage error')),
        (message) => fail('Expected Left but got Right: $message'),
      );

      verify(() => mockRemote.logout()).called(1);
      verify(() => mockLocal.clearAll()).called(1);
    });

    test('should handle remote timeout gracefully', () async {
      // Arrange: Remote times out (common network issue)
      when(() => mockRemote.logout()).thenThrow(Exception('Connection timeout'));
      when(() => mockLocal.clearAll()).thenAnswer((_) async {});

      // Act
      final result = await repository.logout();

      // Assert: Should still succeed locally even though remote timed out
      expect(result, isA<Right>());
      result.fold(
        (failure) => fail('Expected Right but got Left: $failure'),
        (message) => expect(message, 'Logged out successfully'),
      );

      verify(() => mockLocal.clearAll()).called(1);
    });

    test('should handle rate-limit error on remote logout gracefully', () async {
      // Arrange: Remote is rate-limited
      when(() => mockRemote.logout())
          .thenThrow(const ServerException(statusCode: 429, message: 'Too Many Requests'));
      when(() => mockLocal.clearAll()).thenAnswer((_) async {});

      // Act
      final result = await repository.logout();

      // Assert: Should still proceed with local logout
      expect(result, isA<Right>());
      result.fold(
        (failure) => fail('Expected Right but got Left: $failure'),
        (message) => expect(message, 'Logged out successfully'),
      );

      // Verify local clear was called despite remote 429
      verify(() => mockLocal.clearAll()).called(1);
    });

    test('should handle server 500 error on remote logout gracefully', () async {
      // Arrange: Server error
      when(() => mockRemote.logout())
          .thenThrow(const ServerException(statusCode: 500, message: 'Internal Server Error'));
      when(() => mockLocal.clearAll()).thenAnswer((_) async {});

      // Act
      final result = await repository.logout();

      // Assert: Should still clear local state
      expect(result, isA<Right>());
      result.fold(
        (failure) => fail('Expected Right but got Left: $failure'),
        (message) => expect(message, 'Logged out successfully'),
      );

      verify(() => mockLocal.clearAll()).called(1);
    });

    test('should be idempotent - local clear always happens', () async {
      // Arrange: Different remote failures on successive calls
      when(() => mockRemote.logout())
          .thenThrow(Exception('Network unavailable'));
      when(() => mockLocal.clearAll()).thenAnswer((_) async {});

      // Act: Call logout multiple times
      final result1 = await repository.logout();
      final result2 = await repository.logout();

      // Assert: Both should succeed (local clear always happens)
      expect(result1, isA<Right>());
      expect(result2, isA<Right>());

      // Verify clear was called multiple times
      verify(() => mockLocal.clearAll()).called(2);
    });

    test('should not expose raw exceptions to the caller', () async {
      // Arrange: Remote throws exception with sensitive info
      when(() => mockRemote.logout())
          .thenThrow(Exception('Token XYZ123ABC is invalid'));
      when(() => mockLocal.clearAll()).thenAnswer((_) async {});

      // Act
      final result = await repository.logout();

      // Assert: Success message should not contain the sensitive token info
      expect(result, isA<Right>());
      result.fold(
        (failure) => fail('Expected Right but got Left: $failure'),
        (message) {
          // Default success message is used, not the exception message
          expect(message, 'Logged out successfully');
          expect(message, isNot(contains('XYZ123ABC')));
          expect(message, isNot(contains('Token')));
        },
      );
    });

    test('should complete logout sequence regardless of remote response time',
        () async {
      // Arrange: Simulate slow remote logout
      when(() => mockRemote.logout())
          .thenAnswer((_) async => await Future.delayed(Duration(milliseconds: 100), () => 'Logged out'));
      when(() => mockLocal.clearAll()).thenAnswer((_) async {});

      // Act & Assert: Should complete successfully despite delay
      final result = await repository.logout();
      expect(result, isA<Right>());

      verify(() => mockRemote.logout()).called(1);
      verify(() => mockLocal.clearAll()).called(1);
    });
  });
}
