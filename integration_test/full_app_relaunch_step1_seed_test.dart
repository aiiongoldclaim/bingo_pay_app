// Step 1 of a full-app reproduction of "user is logged out when the app is
// closed and reopened".
//
// Unlike session_persistence_step1_login_test.dart (which only exercises
// the storage layer in isolation and already proved that layer persists
// correctly across a relaunch on this device), this pair drives the REAL
// app entry point (bootstrap/App widget, DI container, AuthBloc, GoRouter)
// so it can catch a bug anywhere in that chain — not just in storage.
//
// Run this file first, then run full_app_relaunch_step2_reopen_test.dart as
// a separate `flutter test` invocation on the same device.
import 'package:bingo_pay/core/storage/preferences_service.dart';
import 'package:bingo_pay/core/storage/secure_storage_service.dart';
import 'package:bingo_pay/features/auth/data/datasources/auth_local_datasource.dart';
import 'package:bingo_pay/features/auth/data/models/user_model.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

const fullAppTestUser = UserModel(
  id: 'full-app-relaunch-test-user-id',
  email: 'full-app-relaunch-test@example.com',
  name: 'Full App Relaunch Test User',
  kycStatus: 'not_required',
  emailVerified: true,
  phoneVerified: true,
  passwordSet: true,
);
const fullAppTestAccessToken = 'full-app-relaunch-test-access-token';
const fullAppTestRefreshToken = 'full-app-relaunch-test-refresh-token';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('step 1: seed a logged-in session for the full-app relaunch '
      'check', (tester) async {
    final secureStorage = SecureStorageService(
      storage: const FlutterSecureStorage(),
    );
    final prefs = await SharedPreferences.getInstance();
    final local = AuthLocalDataSourceImpl(secureStorage, prefs);

    // Mark onboarding as seen so step 2's redirect lands on /login or
    // /home rather than /onboarding — this reproduction is about the
    // returning, already-onboarded user, not first-run onboarding.
    await PreferencesService(prefs).setOnboardingSeen();

    await local.clearAll();
    await local.saveTokens(
      accessToken: fullAppTestAccessToken,
      refreshToken: fullAppTestRefreshToken,
    );
    await local.saveUser(fullAppTestUser);

    final seeded = await local.getUser();
    expect(seeded?.id, fullAppTestUser.id);
  });
}
