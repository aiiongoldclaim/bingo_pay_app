// Step 2 of a full-app reproduction of "user is logged out when the app is
// closed and reopened".
//
// Run full_app_relaunch_step1_seed_test.dart FIRST as a separate
// `flutter test` invocation on the same device. This file then boots the
// REAL app (DI container, AuthBloc, GoRouter) on a fresh OS process —
// exactly like reopening the app after closing it — and checks whether the
// user lands on the login screen or the home screen.
import 'package:bingo_pay/app/app.dart';
import 'package:bingo_pay/core/di/injection.dart';
import 'package:bingo_pay/features/auth/presentation/screens/login_screen.dart';
import 'package:bingo_pay/features/home/presentation/screens/home_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_flavor/flutter_flavor.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets(
    'step 2: reopen the real app (fresh process) after a valid session was '
    'seeded in step 1, and see whether it lands on login or home',
    (tester) async {
      FlavorConfig(
        name: 'dev',
        color: Colors.green,
        variables: const {
          'apiBaseUrl': 'https://dev.thevaults.org',
          'appName': 'Vaults DEV',
          'enableLogging': true,
          'enableAnalytics': true,
          'apiKey': 'GTP_2026_PDA_V1_API_KEY_ASDF',
        },
      );

      await configureDependencies(FlavorConfig.instance.name ?? 'prod');

      await tester.pumpWidget(const App());

      // Let the real startup sequence run to completion: DI-backed
      // CheckAuthStatusRequested, the AuthBloc's 5s timeout ceiling,
      // AuthBloc -> AppRouter -> GoRouter redirect, and any resulting
      // screen build — using real time on a real device, not fake_async.
      for (var i = 0; i < 8; i++) {
        await tester.pump(const Duration(seconds: 1));
      }
      await tester.pumpAndSettle(const Duration(seconds: 1));

      final onLogin = find.byType(LoginScreen).evaluate().isNotEmpty;
      final onHome = find.byType(HomeScreen).evaluate().isNotEmpty;

      debugPrint(
        'full_app_relaunch_step2_reopen_test: onLogin=$onLogin '
        'onHome=$onHome',
      );

      expect(
        onHome,
        isTrue,
        reason:
            'A valid session was seeded in step 1, but the real app landed '
            'on LoginScreen instead of HomeScreen after a fresh-process '
            'relaunch (onLogin=$onLogin). This reproduces the reported '
            'auto-logout bug in the real startup chain (DI/AuthBloc/'
            'GoRouter), not just the raw storage layer.',
      );
      expect(onLogin, isFalse);
    },
  );
}
