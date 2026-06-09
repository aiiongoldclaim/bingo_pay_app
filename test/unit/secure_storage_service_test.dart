import 'package:bingo_pay/core/config/app_constants.dart';
import 'package:bingo_pay/core/storage/secure_storage_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import '../helpers/mocks.dart';

void main() {
  late MockFlutterSecureStorage mockStorage;
  late SecureStorageService service;

  setUp(() {
    mockStorage = MockFlutterSecureStorage();
    service = SecureStorageService(storage: mockStorage);
  });

  group('SecureStorageService', () {
    test('saveAccessToken writes to secure storage', () async {
      when(() => mockStorage.write(
            key: AppConstants.accessTokenKey,
            value: 'token123',
          )).thenAnswer((_) async {});

      await service.saveAccessToken('token123');

      verify(() => mockStorage.write(
            key: AppConstants.accessTokenKey,
            value: 'token123',
          )).called(1);
    });

    test('getAccessToken reads from secure storage', () async {
      when(() => mockStorage.read(key: AppConstants.accessTokenKey))
          .thenAnswer((_) async => 'token123');

      final result = await service.getAccessToken();

      expect(result, 'token123');
    });

    test('clearAll deletes all secure keys', () async {
      when(() => mockStorage.deleteAll()).thenAnswer((_) async {});

      await service.clearAll();

      verify(() => mockStorage.deleteAll()).called(1);
    });
  });
}
