// Step 1 of a two-part manual reproduction of "user is logged out when the
// app is closed and reopened".
//
// This test simulates a successful login by writing tokens + the cached
// user through the *real* production storage classes (SecureStorageService,
// AuthLocalDataSourceImpl), backed by the real platform Keychain/Keystore —
// not a mock. It deliberately does NOT clear storage afterwards.
//
// Run this test first, then run session_persistence_step2_reopen_test.dart
// as a completely separate `flutter test` invocation on the SAME device.
// Because each `flutter test integration_test/...` run relaunches the app
// as a fresh OS process (the same way force-quitting and reopening the app
// does), reading the data back in step 2 is a faithful reproduction of
// "reopen the app after closing it" — unlike a single-process unit test,
// which would never observe a real cross-process persistence bug.
import 'dart:convert';

import 'package:bingo_pay/core/storage/secure_storage_service.dart';
import 'package:bingo_pay/features/auth/data/datasources/auth_local_datasource.dart';
import 'package:bingo_pay/features/auth/data/models/user_model.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

const testUser = UserModel(
  id: 'session-persistence-test-user-id',
  email: 'session-persistence-test@example.com',
  name: 'Session Persistence Test User',
  kycStatus: 'not_required',
  emailVerified: true,
  phoneVerified: true,
  passwordSet: true,
);
const testAccessToken = 'session-persistence-test-access-token';
const testRefreshToken = 'session-persistence-test-refresh-token';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('step 1: perform a "login" and leave the session persisted', (
    tester,
  ) async {
    final secureStorage = SecureStorageService(
      storage: const FlutterSecureStorage(),
    );
    final prefs = await SharedPreferences.getInstance();
    final local = AuthLocalDataSourceImpl(secureStorage, prefs);

    // Start from a clean slate so this reproduction isn't polluted by a
    // previous run.
    await local.clearAll();

    await local.saveTokens(
      accessToken: testAccessToken,
      refreshToken: testRefreshToken,
    );
    await local.saveUser(testUser);

    // Sanity check: the data we just wrote is readable within the SAME
    // process. This is expected to pass even if the real bug exists —
    // the bug only shows up after a process restart, which step 2 covers.
    final readBackImmediately = await local.getUser();
    expect(
      readBackImmediately?.id,
      testUser.id,
      reason:
          'Immediately re-reading the just-saved user within the same '
          'process should always work; if this fails the bug is in the '
          'save/read code itself, not in cross-process persistence.',
    );

    final rawAccessToken = await secureStorage.getAccessToken();
    expect(rawAccessToken, testAccessToken);

    final rawUserJson = await secureStorage.read(key: 'cached_user');
    expect(rawUserJson, jsonEncode(testUser.toJson()));

    // Intentionally NOT calling clearAll() here — step 2 needs this data
    // to still be present after the process is killed and relaunched.
  });
}
