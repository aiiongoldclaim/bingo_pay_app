// Drives the real app through login and a handful of core screens,
// printing a `SCREENSHOT_MARKER:<name>` line right after each screen has
// settled so an external script (e.g. `xcrun simctl io booted screenshot`)
// can capture it at the right moment. This is a throwaway capture harness
// for App Store / Play Store listing screenshots, not a correctness test.
import 'package:bingo_pay/app/app.dart';
import 'package:bingo_pay/core/di/injection.dart';
import 'package:bingo_pay/core/router/app_routes.dart';
import 'package:bingo_pay/core/config/app_constants.dart';
import 'package:bingo_pay/core/storage/secure_storage_service.dart';
import 'package:bingo_pay/core/widgets/app_product_card.dart';
import 'package:bingo_pay/features/auth/data/datasources/auth_local_datasource.dart';
import 'package:bingo_pay/features/home/presentation/screens/home_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_flavor/flutter_flavor.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:integration_test/integration_test.dart';
import 'package:intro/intro.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<void> _mark(String name) async {
  debugPrint('SCREENSHOT_MARKER:$name');
  await Future.delayed(const Duration(milliseconds: 700));
}

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets(
    'capture store screenshots',
    (tester) async {
      // Start from a clean, logged-out slate — earlier integration test
      // runs on this same simulator may have left fake tokens behind.
      final secureStorage = SecureStorageService(
        storage: const FlutterSecureStorage(),
      );
      final prefs = await SharedPreferences.getInstance();
      await AuthLocalDataSourceImpl(secureStorage, prefs).clearAll();
      // Skip the onboarding carousel — RouteGuard force-redirects to it
      // whenever this flag is unset, regardless of what route we request.
      await prefs.setBool(AppConstants.onboardingSeenKey, true);

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

      for (var i = 0; i < 6; i++) {
        await tester.pump(const Duration(seconds: 1));
      }
      await tester.pumpAndSettle(const Duration(seconds: 1));

      // Force to the login screen regardless of onboarding/splash state.
      final bootCtx = tester.element(find.byType(Scaffold).first);
      GoRouter.of(bootCtx).go(AppRoutes.login);
      await tester.pumpAndSettle(const Duration(seconds: 1));

      expect(
        find.byType(TextFormField),
        findsNWidgets(2),
        reason: 'Expected the login form (email + password) to be showing',
      );

      await tester.enterText(
        find.byType(TextFormField).at(0),
        'modi@yopmail.com',
      );
      await tester.pump();
      await tester.enterText(find.byType(TextFormField).at(1), 'Admin@123');
      await tester.pump();

      await tester.tap(find.text('Login'));
      for (var i = 0; i < 6; i++) {
        await tester.pump(const Duration(seconds: 1));
      }
      await tester.pumpAndSettle(const Duration(seconds: 2));

      final homeCtx = tester.element(find.byType(HomeScreen));

      // Dismiss the first-run "intro" coachmark overlay — besides not
      // being wanted in a store screenshot, leaving it active across a
      // later navigation crashes it (it holds a stale renderObject
      // reference to a highlighted target that gets disposed).
      await Intro.of(homeCtx).controller.close();
      await tester.pumpAndSettle(const Duration(seconds: 1));

      await _mark('home');

      GoRouter.of(homeCtx).push(AppRoutes.auctionScreen);
      await tester.pumpAndSettle(const Duration(seconds: 2));
      await _mark('auctions');
      GoRouter.of(homeCtx).pop();
      await tester.pumpAndSettle(const Duration(seconds: 1));

      // Home's own "recommended"/"flash deals" rails are empty for this
      // account, so there's no product card to tap there — go via the
      // All Products catalog instead, which isn't personalization-gated.
      GoRouter.of(homeCtx).push(AppRoutes.allProducts);
      await tester.pumpAndSettle(const Duration(seconds: 2));

      final productCard = find.byType(AppProductCard).first;
      await tester.ensureVisible(productCard);
      await tester.pumpAndSettle();
      await tester.tap(productCard);
      await tester.pumpAndSettle(const Duration(seconds: 2));
      await _mark('product_detail');
      GoRouter.of(homeCtx).pop();
      await tester.pumpAndSettle(const Duration(seconds: 1));
      GoRouter.of(homeCtx).pop();
      await tester.pumpAndSettle(const Duration(seconds: 1));

      GoRouter.of(homeCtx).push(AppRoutes.cart);
      await tester.pumpAndSettle(const Duration(seconds: 2));
      await _mark('cart');
      GoRouter.of(homeCtx).pop();
      await tester.pumpAndSettle(const Duration(seconds: 1));

      GoRouter.of(homeCtx).push(AppRoutes.profile);
      await tester.pumpAndSettle(const Duration(seconds: 2));
      await _mark('profile');

      debugPrint('SCREENSHOT_MARKER:done');
    },
    timeout: const Timeout(Duration(minutes: 5)),
  );
}
