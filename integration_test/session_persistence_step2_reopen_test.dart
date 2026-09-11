// Step 2 of a two-part manual reproduction of "user is logged out when the
// app is closed and reopened".
//
// Run session_persistence_step1_login_test.dart FIRST, as a separate
// `flutter test` invocation on the same device. This file then relaunches
// on a fresh OS process (exactly like reopening the app after closing it)
// and exercises the exact production code path used at startup —
// AuthLocalDataSourceImpl.getUser(), the same method
// CheckAuthStatusUseCase -> AuthBloc._onCheckAuthStatus calls from
// app.dart on every cold start — to see whether the session written in
// step 1 actually survived.
import 'package:bingo_pay/core/storage/secure_storage_service.dart';
import 'package:bingo_pay/features/auth/data/datasources/auth_local_datasource.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'session_persistence_step1_login_test.dart' show testUser, testAccessToken;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets(
    'step 2: reopen the app (fresh process) and check the session survived',
    (tester) async {
      final secureStorage = SecureStorageService(
        storage: const FlutterSecureStorage(),
      );
      final prefs = await SharedPreferences.getInstance();
      final local = AuthLocalDataSourceImpl(secureStorage, prefs);

      final hasToken = await secureStorage.hasAccessToken();
      final accessToken = await secureStorage.getAccessToken();
      final user = await local.getUser();

      // These `expect` calls are exactly what confirms or refutes the
      // reported bug. If they fail, the session genuinely does not
      // survive an app restart on this device/platform, reproducing the
      // bug for real; if they pass, the storage layer itself is fine and
      // the reported symptom must be coming from somewhere else (a real
      // API 401 shortly after reopen, a different build/device, etc.).
      expect(
        hasToken,
        isTrue,
        reason:
            'Access token saved in step 1 was not found after relaunch — '
            'this reproduces the reported auto-logout bug at the token '
            'storage layer.',
      );
      expect(accessToken, testAccessToken);
      expect(
        user,
        isNotNull,
        reason:
            'AuthLocalDataSourceImpl.getUser() returned null after '
            'relaunch even though a token was saved in step 1 — this is '
            'the exact code path app.dart calls on every cold start, so '
            'this reproduces the reported auto-logout bug.',
      );
      expect(user?.id, testUser.id);
      expect(user?.email, testUser.email);

      // Clean up the test fixtures now that the assertions have run.
      await local.clearAll();
    },
  );
}
