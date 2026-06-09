import 'package:bingo_pay/core/storage/secure_storage_service.dart';
import 'package:bingo_pay/features/auth/data/datasources/auth_local_datasource.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MockSecureStorageService extends Mock implements SecureStorageService {}
class MockSharedPreferences extends Mock implements SharedPreferences {}

void main() {
  late MockSecureStorageService mockSecure;
  late MockSharedPreferences mockPrefs;
  late AuthLocalDataSourceImpl datasource;

  setUp(() {
    mockSecure = MockSecureStorageService();
    mockPrefs = MockSharedPreferences();
    datasource = AuthLocalDataSourceImpl(mockSecure, mockPrefs);
  });

  test('getUser returns null when no access token', () async {
    when(() => mockSecure.hasAccessToken()).thenAnswer((_) async => false);
    final result = await datasource.getUser();
    expect(result, isNull);
  });

  test('saveTokens delegates to SecureStorageService', () async {
    when(() => mockSecure.saveAccessToken(any())).thenAnswer((_) async {});
    when(() => mockSecure.saveRefreshToken(any())).thenAnswer((_) async {});

    await datasource.saveTokens(accessToken: 'acc', refreshToken: 'ref');

    verify(() => mockSecure.saveAccessToken('acc')).called(1);
    verify(() => mockSecure.saveRefreshToken('ref')).called(1);
  });
}
