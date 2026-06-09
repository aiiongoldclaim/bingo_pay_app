# Bingo Pay Foundation Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Bootstrap the complete project foundation — pubspec, Flutter flavors (dev/staging/prod), all of `core/` infrastructure, app shell, and theme — so that the app launches cleanly on all three flavors before any feature work begins.

**Architecture:** Feature-First Clean Architecture. `lib/` splits into `core/` (shared infrastructure) and `features/` (product features, added in later plans). All shared services (DI, router, network, storage, theme) live in `core/` and are configured at startup from `FlavorConfig.instance`.

**Tech Stack:** Flutter 3.x · Dart 3.x · flutter_bloc · go_router · get_it + injectable · dio · flutter_secure_storage · fpdart · connectivity_plus · json_serializable · mocktail · bloc_test

---

## Task 1: Update pubspec.yaml and create folder scaffold

**Files:**
- Modify: `pubspec.yaml`
- Create: all `lib/` subdirectories (no Dart files yet)

- [ ] **Step 1: Replace pubspec.yaml with full dependency set**

```yaml
name: bingo_pay
description: "Bingo Pay — Multi-vendor marketplace app"
publish_to: 'none'
version: 1.0.0+1

environment:
  sdk: ^3.10.8

dependencies:
  flutter:
    sdk: flutter
  cupertino_icons: ^1.0.8

  # State management
  flutter_bloc: ^8.1.6
  equatable: ^2.0.7

  # Navigation
  go_router: ^14.6.3

  # Dependency injection
  get_it: ^8.0.3
  injectable: ^2.5.0

  # Network
  dio: ^5.8.0+1
  pretty_dio_logger: ^1.4.0

  # Storage
  flutter_secure_storage: ^9.2.4
  shared_preferences: ^2.5.3

  # Functional error handling
  fpdart: ^1.1.0

  # Device
  image_picker: ^1.1.2
  permission_handler: ^11.4.0
  connectivity_plus: ^6.1.4
  share_plus: ^10.1.4

  # Utilities
  logger: ^2.5.0
  intl: ^0.19.0
  json_annotation: ^4.9.0

dev_dependencies:
  flutter_test:
    sdk: flutter
  flutter_lints: ^6.0.0
  build_runner: ^2.4.15
  injectable_generator: ^2.7.0
  json_serializable: ^6.9.5
  bloc_test: ^9.1.7
  mocktail: ^1.0.4

flutter:
  uses-material-design: true
  generate: true
```

- [ ] **Step 2: Install dependencies**

```bash
flutter pub get
```

Expected: No errors. All packages resolve.

- [ ] **Step 3: Create the full lib/ folder scaffold**

```bash
mkdir -p lib/app
mkdir -p lib/core/api/interceptors
mkdir -p lib/core/bloc
mkdir -p lib/core/config
mkdir -p lib/core/di
mkdir -p lib/core/error
mkdir -p lib/core/network
mkdir -p lib/core/router
mkdir -p lib/core/storage
mkdir -p lib/core/theme
mkdir -p lib/core/l10n/arb
mkdir -p lib/core/utils/extensions
mkdir -p lib/core/widgets
mkdir -p lib/features/auth/data/datasources
mkdir -p lib/features/auth/data/models
mkdir -p lib/features/auth/data/repositories
mkdir -p lib/features/auth/domain/entities
mkdir -p lib/features/auth/domain/repositories
mkdir -p lib/features/auth/domain/usecases
mkdir -p lib/features/auth/presentation/bloc
mkdir -p lib/features/auth/presentation/screens/kyc
mkdir -p lib/features/auth/presentation/widgets
mkdir -p lib/features/auth/bindings
mkdir -p lib/features/home/data/datasources
mkdir -p lib/features/home/data/models
mkdir -p lib/features/home/data/repositories
mkdir -p lib/features/home/domain/entities
mkdir -p lib/features/home/domain/repositories
mkdir -p lib/features/home/domain/usecases
mkdir -p lib/features/home/presentation/cubit
mkdir -p lib/features/home/presentation/screens
mkdir -p lib/features/home/presentation/widgets
mkdir -p lib/features/home/bindings
mkdir -p lib/features/product_management/data/datasources
mkdir -p lib/features/product_management/data/models
mkdir -p lib/features/product_management/data/repositories
mkdir -p lib/features/product_management/domain/entities
mkdir -p lib/features/product_management/domain/repositories
mkdir -p lib/features/product_management/domain/usecases
mkdir -p lib/features/product_management/presentation/bloc
mkdir -p lib/features/product_management/presentation/screens
mkdir -p lib/features/product_management/presentation/widgets
mkdir -p lib/features/product_management/bindings
mkdir -p lib/features/transactions/data/datasources
mkdir -p lib/features/transactions/data/models
mkdir -p lib/features/transactions/data/repositories
mkdir -p lib/features/transactions/domain/entities
mkdir -p lib/features/transactions/domain/repositories
mkdir -p lib/features/transactions/domain/usecases
mkdir -p lib/features/transactions/presentation/bloc
mkdir -p lib/features/transactions/presentation/screens
mkdir -p lib/features/transactions/presentation/widgets
mkdir -p lib/features/transactions/bindings
mkdir -p lib/features/refer_and_earn/data/datasources
mkdir -p lib/features/refer_and_earn/data/models
mkdir -p lib/features/refer_and_earn/data/repositories
mkdir -p lib/features/refer_and_earn/domain/entities
mkdir -p lib/features/refer_and_earn/domain/repositories
mkdir -p lib/features/refer_and_earn/domain/usecases
mkdir -p lib/features/refer_and_earn/presentation/cubit
mkdir -p lib/features/refer_and_earn/presentation/screens
mkdir -p lib/features/refer_and_earn/presentation/widgets
mkdir -p lib/features/refer_and_earn/bindings
mkdir -p lib/features/invoices/data/datasources
mkdir -p lib/features/invoices/data/models
mkdir -p lib/features/invoices/data/repositories
mkdir -p lib/features/invoices/domain/entities
mkdir -p lib/features/invoices/domain/repositories
mkdir -p lib/features/invoices/domain/usecases
mkdir -p lib/features/invoices/presentation/bloc
mkdir -p lib/features/invoices/presentation/screens
mkdir -p lib/features/invoices/presentation/widgets
mkdir -p lib/features/invoices/bindings
mkdir -p test/unit
mkdir -p test/bloc
mkdir -p test/widget
mkdir -p test/helpers
mkdir -p integration_test
```

- [ ] **Step 4: Commit**

```bash
git add pubspec.yaml pubspec.lock lib/
git commit -m "chore: update pubspec with full dependency set and create folder scaffold"
```

---

## Task 2: Configure Android flavors

**Files:**
- Modify: `android/app/build.gradle.kts`

- [ ] **Step 1: Replace android/app/build.gradle.kts with flavor-aware config**

```kotlin
plugins {
    id("com.android.application")
    id("kotlin-android")
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.bingosg.bingo_pay"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_17.toString()
    }

    defaultConfig {
        applicationId = "com.bingosg.bingo_pay"
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    flavorDimensions += "environment"

    productFlavors {
        create("dev") {
            dimension = "environment"
            applicationIdSuffix = ".dev"
            versionNameSuffix = "-dev"
            resValue("string", "app_name", "Bingo Pay DEV")
        }
        create("staging") {
            dimension = "environment"
            applicationIdSuffix = ".staging"
            versionNameSuffix = "-staging"
            resValue("string", "app_name", "Bingo Pay STG")
        }
        create("prod") {
            dimension = "environment"
            resValue("string", "app_name", "Bingo Pay")
        }
    }

    buildTypes {
        release {
            signingConfig = signingConfigs.getByName("debug")
        }
    }
}

flutter {
    source = "../.."
}
```

- [ ] **Step 2: Update AndroidManifest.xml to use the dynamic app name**

In `android/app/src/main/AndroidManifest.xml`, change the `android:label` attribute on the `<application>` tag from the hardcoded name to:

```xml
android:label="@string/app_name"
```

- [ ] **Step 3: Verify Android builds for dev flavor**

```bash
flutter build apk --flavor dev --target lib/main_dev.dart --debug
```

This will fail because `lib/main_dev.dart` doesn't exist yet — that's expected. Verify the error is about the missing file, not a Gradle failure.

Expected error: `Target file "lib/main_dev.dart" not found`

- [ ] **Step 4: Commit**

```bash
git add android/app/build.gradle.kts android/app/src/main/AndroidManifest.xml
git commit -m "chore: configure Android product flavors (dev/staging/prod)"
```

---

## Task 3: Configure iOS flavors

**Files:**
- Create: `ios/Flutter/dev.xcconfig`
- Create: `ios/Flutter/staging.xcconfig`
- Create: `ios/Flutter/prod.xcconfig`

iOS flavor setup requires Xcode steps. Do these in order.

- [ ] **Step 1: Create xcconfig files**

Create `ios/Flutter/dev.xcconfig`:
```
#include "Generated.xcconfig"
FLUTTER_TARGET=lib/main_dev.dart
BUNDLE_ID_SUFFIX=.dev
APP_DISPLAY_NAME=Bingo Pay DEV
```

Create `ios/Flutter/staging.xcconfig`:
```
#include "Generated.xcconfig"
FLUTTER_TARGET=lib/main_staging.dart
BUNDLE_ID_SUFFIX=.staging
APP_DISPLAY_NAME=Bingo Pay STG
```

Create `ios/Flutter/prod.xcconfig`:
```
#include "Generated.xcconfig"
FLUTTER_TARGET=lib/main_prod.dart
BUNDLE_ID_SUFFIX=
APP_DISPLAY_NAME=Bingo Pay
```

- [ ] **Step 2: Open Xcode and create three schemes**

```bash
open ios/Runner.xcworkspace
```

In Xcode:
1. Product → Scheme → Manage Schemes
2. Duplicate the existing `Runner` scheme twice
3. Name them: `Runner-Dev`, `Runner-Staging` (keep `Runner` for prod)
4. For each scheme, edit → Build Configuration → set Debug and Release to the matching config

- [ ] **Step 3: Update Info.plist to use dynamic display name**

In `ios/Runner/Info.plist`, change `CFBundleDisplayName` to:
```xml
<key>CFBundleDisplayName</key>
<string>$(APP_DISPLAY_NAME)</string>
```

- [ ] **Step 4: Commit**

```bash
git add ios/Flutter/dev.xcconfig ios/Flutter/staging.xcconfig ios/Flutter/prod.xcconfig ios/Runner/Info.plist
git commit -m "chore: configure iOS schemes and xcconfig files for flavors"
```

---

## Task 4: FlavorConfig, entry points, and bootstrap skeleton

**Files:**
- Create: `lib/core/config/flavor_config.dart`
- Create: `lib/core/config/app_config.dart`
- Create: `lib/core/config/app_constants.dart`
- Create: `lib/app/bootstrap.dart`
- Create: `lib/main_dev.dart`
- Create: `lib/main_staging.dart`
- Create: `lib/main_prod.dart`
- Test: `test/unit/flavor_config_test.dart`

- [ ] **Step 1: Write failing test for FlavorConfig**

Create `test/unit/flavor_config_test.dart`:

```dart
import 'package:bingo_pay/core/config/flavor_config.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('FlavorConfig', () {
    test('instance holds dev values when set to dev', () {
      FlavorConfig.instance = FlavorConfig(
        flavor: Flavor.dev,
        apiBaseUrl: 'https://dev-api.bingopay.com/v1',
        appName: 'Bingo Pay DEV',
        enableLogging: true,
        enableAnalytics: false,
      );

      expect(FlavorConfig.instance.flavor, Flavor.dev);
      expect(FlavorConfig.instance.apiBaseUrl, 'https://dev-api.bingopay.com/v1');
      expect(FlavorConfig.instance.enableLogging, isTrue);
      expect(FlavorConfig.instance.enableAnalytics, isFalse);
    });

    test('isDev returns true only for dev flavor', () {
      FlavorConfig.instance = FlavorConfig(
        flavor: Flavor.dev,
        apiBaseUrl: '',
        appName: '',
        enableLogging: true,
        enableAnalytics: false,
      );
      expect(FlavorConfig.instance.isDev, isTrue);
      expect(FlavorConfig.instance.isProduction, isFalse);
    });
  });
}
```

- [ ] **Step 2: Run test to confirm it fails**

```bash
flutter test test/unit/flavor_config_test.dart
```

Expected: FAIL — `flavor_config.dart` does not exist yet.

- [ ] **Step 3: Create lib/core/config/flavor_config.dart**

```dart
enum Flavor { dev, staging, prod }

class FlavorConfig {
  static late FlavorConfig instance;

  final Flavor flavor;
  final String apiBaseUrl;
  final String appName;
  final bool enableLogging;
  final bool enableAnalytics;

  const FlavorConfig({
    required this.flavor,
    required this.apiBaseUrl,
    required this.appName,
    required this.enableLogging,
    required this.enableAnalytics,
  });

  bool get isDev => flavor == Flavor.dev;
  bool get isStaging => flavor == Flavor.staging;
  bool get isProduction => flavor == Flavor.prod;
}
```

- [ ] **Step 4: Run test to confirm it passes**

```bash
flutter test test/unit/flavor_config_test.dart
```

Expected: PASS

- [ ] **Step 5: Create lib/core/config/app_config.dart**

```dart
import 'flavor_config.dart';

class AppConfig {
  static const int connectTimeoutSeconds = 30;
  static const int receiveTimeoutSeconds = 30;
  static const int pageSize = 20;
  static const int kycPollingIntervalSeconds = 10;

  static String get apiBaseUrl => FlavorConfig.instance.apiBaseUrl;
}
```

- [ ] **Step 6: Create lib/core/config/app_constants.dart**

```dart
class AppConstants {
  static const String accessTokenKey = 'access_token';
  static const String refreshTokenKey = 'refresh_token';
  static const String userIdKey = 'user_id';
  static const String themeModeKey = 'theme_mode';
  static const String localeKey = 'locale';
  static const String onboardingSeenKey = 'onboarding_seen';
}
```

- [ ] **Step 7: Create lib/app/bootstrap.dart (skeleton — will be completed in Task 13)**

```dart
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

Future<void> bootstrap(Widget Function() appBuilder) async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(appBuilder());
}
```

- [ ] **Step 8: Create the three entry point files**

Create `lib/main_dev.dart`:
```dart
import 'package:bingo_pay/app/bootstrap.dart';
import 'package:bingo_pay/core/config/flavor_config.dart';
import 'package:flutter/material.dart';

void main() async {
  FlavorConfig.instance = const FlavorConfig(
    flavor: Flavor.dev,
    apiBaseUrl: 'https://dev-api.bingopay.com/v1',
    appName: 'Bingo Pay DEV',
    enableLogging: true,
    enableAnalytics: false,
  );
  await bootstrap(() => const Placeholder());
}
```

Create `lib/main_staging.dart`:
```dart
import 'package:bingo_pay/app/bootstrap.dart';
import 'package:bingo_pay/core/config/flavor_config.dart';
import 'package:flutter/material.dart';

void main() async {
  FlavorConfig.instance = const FlavorConfig(
    flavor: Flavor.staging,
    apiBaseUrl: 'https://stg-api.bingopay.com/v1',
    appName: 'Bingo Pay STG',
    enableLogging: true,
    enableAnalytics: false,
  );
  await bootstrap(() => const Placeholder());
}
```

Create `lib/main_prod.dart`:
```dart
import 'package:bingo_pay/app/bootstrap.dart';
import 'package:bingo_pay/core/config/flavor_config.dart';
import 'package:flutter/material.dart';

void main() async {
  FlavorConfig.instance = const FlavorConfig(
    flavor: Flavor.prod,
    apiBaseUrl: 'https://api.bingopay.com/v1',
    appName: 'Bingo Pay',
    enableLogging: false,
    enableAnalytics: true,
  );
  await bootstrap(() => const Placeholder());
}
```

- [ ] **Step 9: Verify the dev entry point runs**

```bash
flutter run --flavor dev --target lib/main_dev.dart
```

Expected: A blank `Placeholder` widget screen on the device. No crash.

- [ ] **Step 10: Commit**

```bash
git add lib/core/config/ lib/app/bootstrap.dart lib/main_dev.dart lib/main_staging.dart lib/main_prod.dart test/unit/flavor_config_test.dart
git commit -m "feat: add FlavorConfig, three entry points, and bootstrap skeleton"
```

---

## Task 5: Error hierarchy

**Files:**
- Create: `lib/core/error/exceptions.dart`
- Create: `lib/core/error/failures.dart`
- Create: `lib/core/error/error_handler.dart`
- Test: `test/unit/error_handler_test.dart`

- [ ] **Step 1: Write failing tests for ErrorHandler**

Create `test/unit/error_handler_test.dart`:

```dart
import 'dart:io';
import 'package:bingo_pay/core/error/error_handler.dart';
import 'package:bingo_pay/core/error/exceptions.dart';
import 'package:bingo_pay/core/error/failures.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('ErrorHandler.mapExceptionToFailure', () {
    test('maps ServerException to ServerFailure', () {
      final exception = ServerException(
        statusCode: 500,
        message: 'Internal server error',
      );
      final failure = ErrorHandler.mapExceptionToFailure(exception);
      expect(failure, isA<ServerFailure>());
      expect((failure as ServerFailure).statusCode, 500);
    });

    test('maps NetworkException to NetworkFailure', () {
      final exception = NetworkException();
      final failure = ErrorHandler.mapExceptionToFailure(exception);
      expect(failure, isA<NetworkFailure>());
    });

    test('maps AuthException to AuthFailure', () {
      final exception = AuthException(message: 'Unauthorized');
      final failure = ErrorHandler.mapExceptionToFailure(exception);
      expect(failure, isA<AuthFailure>());
      expect(failure.message, 'Unauthorized');
    });

    test('maps ValidationException to ValidationFailure with field errors', () {
      final exception = ValidationException(
        message: 'Validation failed',
        fieldErrors: {'email': 'Already in use'},
      );
      final failure = ErrorHandler.mapExceptionToFailure(exception);
      expect(failure, isA<ValidationFailure>());
      expect((failure as ValidationFailure).fieldErrors['email'], 'Already in use');
    });

    test('maps unknown Exception to UnknownFailure', () {
      final exception = Exception('Something unexpected');
      final failure = ErrorHandler.mapExceptionToFailure(exception);
      expect(failure, isA<UnknownFailure>());
    });
  });
}
```

- [ ] **Step 2: Run to confirm failure**

```bash
flutter test test/unit/error_handler_test.dart
```

Expected: FAIL — files don't exist yet.

- [ ] **Step 3: Create lib/core/error/exceptions.dart**

```dart
class ServerException implements Exception {
  final int? statusCode;
  final String message;
  const ServerException({this.statusCode, required this.message});
}

class NetworkException implements Exception {
  const NetworkException();
}

class AuthException implements Exception {
  final String message;
  const AuthException({required this.message});
}

class ValidationException implements Exception {
  final String message;
  final Map<String, String> fieldErrors;
  const ValidationException({required this.message, required this.fieldErrors});
}

class CacheException implements Exception {
  final String message;
  const CacheException({required this.message});
}
```

- [ ] **Step 4: Create lib/core/error/failures.dart**

```dart
import 'package:equatable/equatable.dart';

sealed class Failure extends Equatable {
  final String message;
  const Failure(this.message);

  @override
  List<Object?> get props => [message];
}

class NetworkFailure extends Failure {
  const NetworkFailure([String message = 'No internet connection'])
      : super(message);
}

class ServerFailure extends Failure {
  final int? statusCode;
  final String? serverMessage;

  const ServerFailure({
    required String message,
    this.statusCode,
    this.serverMessage,
  }) : super(message);

  @override
  List<Object?> get props => [message, statusCode, serverMessage];
}

class AuthFailure extends Failure {
  const AuthFailure({required String message}) : super(message);
}

class CacheFailure extends Failure {
  const CacheFailure({required String message}) : super(message);
}

class ValidationFailure extends Failure {
  final Map<String, String> fieldErrors;

  const ValidationFailure({
    required String message,
    required this.fieldErrors,
  }) : super(message);

  @override
  List<Object?> get props => [message, fieldErrors];
}

class UnknownFailure extends Failure {
  const UnknownFailure([String message = 'An unexpected error occurred'])
      : super(message);
}
```

- [ ] **Step 5: Create lib/core/error/error_handler.dart**

```dart
import 'exceptions.dart';
import 'failures.dart';

class ErrorHandler {
  const ErrorHandler._();

  static Failure mapExceptionToFailure(Exception exception) {
    return switch (exception) {
      ServerException e => ServerFailure(
          message: e.message,
          statusCode: e.statusCode,
          serverMessage: e.message,
        ),
      NetworkException _ => const NetworkFailure(),
      AuthException e => AuthFailure(message: e.message),
      ValidationException e => ValidationFailure(
          message: e.message,
          fieldErrors: e.fieldErrors,
        ),
      CacheException e => CacheFailure(message: e.message),
      _ => UnknownFailure(exception.toString()),
    };
  }
}
```

- [ ] **Step 6: Run tests to confirm they pass**

```bash
flutter test test/unit/error_handler_test.dart
```

Expected: PASS (5 tests)

- [ ] **Step 7: Commit**

```bash
git add lib/core/error/ test/unit/error_handler_test.dart
git commit -m "feat: add error hierarchy — failures, exceptions, error_handler"
```

---

## Task 6: Base AppState sealed class

**Files:**
- Create: `lib/core/bloc/app_state.dart`
- Test: `test/unit/app_state_test.dart`

- [ ] **Step 1: Write failing tests**

Create `test/unit/app_state_test.dart`:

```dart
import 'package:bingo_pay/core/bloc/app_state.dart';
import 'package:bingo_pay/core/error/failures.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('AppState', () {
    test('SuccessState holds data and supports equality', () {
      const s1 = SuccessState<String>('hello');
      const s2 = SuccessState<String>('hello');
      expect(s1, equals(s2));
      expect(s1.data, 'hello');
    });

    test('ErrorState holds failure and supports equality', () {
      const f = NetworkFailure();
      const s1 = ErrorState<String>(f);
      const s2 = ErrorState<String>(f);
      expect(s1, equals(s2));
      expect(s1.failure, isA<NetworkFailure>());
    });

    test('LoadingState instances are equal', () {
      const s1 = LoadingState<String>();
      const s2 = LoadingState<String>();
      expect(s1, equals(s2));
    });
  });
}
```

- [ ] **Step 2: Run to confirm failure**

```bash
flutter test test/unit/app_state_test.dart
```

Expected: FAIL

- [ ] **Step 3: Create lib/core/bloc/app_state.dart**

```dart
import 'package:equatable/equatable.dart';
import '../error/failures.dart';

sealed class AppState<T> extends Equatable {
  const AppState();
}

final class InitialState<T> extends AppState<T> {
  const InitialState();

  @override
  List<Object?> get props => [];
}

final class LoadingState<T> extends AppState<T> {
  const LoadingState();

  @override
  List<Object?> get props => [];
}

final class SuccessState<T> extends AppState<T> {
  final T data;
  const SuccessState(this.data);

  @override
  List<Object?> get props => [data];
}

final class ErrorState<T> extends AppState<T> {
  final Failure failure;
  const ErrorState(this.failure);

  @override
  List<Object?> get props => [failure];
}
```

- [ ] **Step 4: Run tests to confirm pass**

```bash
flutter test test/unit/app_state_test.dart
```

Expected: PASS (3 tests)

- [ ] **Step 5: Commit**

```bash
git add lib/core/bloc/ test/unit/app_state_test.dart
git commit -m "feat: add sealed AppState base class — Initial/Loading/Success/Error"
```

---

## Task 7: Storage services

**Files:**
- Create: `lib/core/storage/secure_storage_service.dart`
- Create: `lib/core/storage/preferences_service.dart`
- Test: `test/unit/secure_storage_service_test.dart`

- [ ] **Step 1: Create test helper with mocks**

Create `test/helpers/mocks.dart`:

```dart
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MockFlutterSecureStorage extends Mock implements FlutterSecureStorage {}
class MockSharedPreferences extends Mock implements SharedPreferences {}
```

- [ ] **Step 2: Write failing tests for SecureStorageService**

Create `test/unit/secure_storage_service_test.dart`:

```dart
import 'package:bingo_pay/core/config/app_constants.dart';
import 'package:bingo_pay/core/storage/secure_storage_service.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
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
```

- [ ] **Step 3: Run to confirm failure**

```bash
flutter test test/unit/secure_storage_service_test.dart
```

Expected: FAIL

- [ ] **Step 4: Create lib/core/storage/secure_storage_service.dart**

```dart
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:injectable/injectable.dart';
import '../config/app_constants.dart';

@singleton
class SecureStorageService {
  final FlutterSecureStorage _storage;

  const SecureStorageService({FlutterSecureStorage? storage})
      : _storage = storage ?? const FlutterSecureStorage();

  Future<void> saveAccessToken(String token) =>
      _storage.write(key: AppConstants.accessTokenKey, value: token);

  Future<void> saveRefreshToken(String token) =>
      _storage.write(key: AppConstants.refreshTokenKey, value: token);

  Future<void> saveUserId(String userId) =>
      _storage.write(key: AppConstants.userIdKey, value: userId);

  Future<String?> getAccessToken() =>
      _storage.read(key: AppConstants.accessTokenKey);

  Future<String?> getRefreshToken() =>
      _storage.read(key: AppConstants.refreshTokenKey);

  Future<String?> getUserId() =>
      _storage.read(key: AppConstants.userIdKey);

  Future<bool> hasAccessToken() async =>
      (await _storage.read(key: AppConstants.accessTokenKey)) != null;

  Future<void> clearAll() => _storage.deleteAll();
}
```

- [ ] **Step 5: Create lib/core/storage/preferences_service.dart**

```dart
import 'package:injectable/injectable.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../config/app_constants.dart';

@singleton
class PreferencesService {
  final SharedPreferences _prefs;

  const PreferencesService(this._prefs);

  Future<void> setThemeMode(String mode) =>
      _prefs.setString(AppConstants.themeModeKey, mode);

  String? getThemeMode() => _prefs.getString(AppConstants.themeModeKey);

  Future<void> setOnboardingSeen() =>
      _prefs.setBool(AppConstants.onboardingSeenKey, true);

  bool isOnboardingSeen() =>
      _prefs.getBool(AppConstants.onboardingSeenKey) ?? false;

  Future<void> setLocale(String locale) =>
      _prefs.setString(AppConstants.localeKey, locale);

  String? getLocale() => _prefs.getString(AppConstants.localeKey);

  Future<void> clear() => _prefs.clear();
}
```

- [ ] **Step 6: Run tests to confirm pass**

```bash
flutter test test/unit/secure_storage_service_test.dart
```

Expected: PASS (3 tests)

- [ ] **Step 7: Commit**

```bash
git add lib/core/storage/ test/unit/secure_storage_service_test.dart test/helpers/mocks.dart
git commit -m "feat: add SecureStorageService and PreferencesService"
```

---

## Task 8: Connectivity service

**Files:**
- Create: `lib/core/network/network_info.dart`
- Create: `lib/core/network/connectivity_service.dart`
- Test: `test/unit/connectivity_service_test.dart`

- [ ] **Step 1: Write failing test**

Create `test/unit/connectivity_service_test.dart`:

```dart
import 'dart:async';
import 'package:bingo_pay/core/network/connectivity_service.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockConnectivity extends Mock implements Connectivity {}

void main() {
  late MockConnectivity mockConnectivity;
  late ConnectivityService service;
  late StreamController<List<ConnectivityResult>> controller;

  setUp(() {
    mockConnectivity = MockConnectivity();
    controller = StreamController<List<ConnectivityResult>>.broadcast();
    when(() => mockConnectivity.onConnectivityChanged)
        .thenAnswer((_) => controller.stream);
    service = ConnectivityService(connectivity: mockConnectivity);
  });

  tearDown(() => controller.close());

  group('ConnectivityService', () {
    test('isConnected emits true when wifi result received', () async {
      expect(
        service.isConnected,
        emitsInOrder([true]),
      );
      controller.add([ConnectivityResult.wifi]);
    });

    test('isConnected emits false when none result received', () async {
      expect(
        service.isConnected,
        emitsInOrder([false]),
      );
      controller.add([ConnectivityResult.none]);
    });
  });
}
```

- [ ] **Step 2: Run to confirm failure**

```bash
flutter test test/unit/connectivity_service_test.dart
```

Expected: FAIL

- [ ] **Step 3: Create lib/core/network/network_info.dart**

```dart
abstract interface class NetworkInfo {
  Future<bool> get isConnected;
}
```

- [ ] **Step 4: Create lib/core/network/connectivity_service.dart**

```dart
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:injectable/injectable.dart';

@lazySingleton
class ConnectivityService {
  final Connectivity _connectivity;

  ConnectivityService({Connectivity? connectivity})
      : _connectivity = connectivity ?? Connectivity();

  Stream<bool> get isConnected => _connectivity.onConnectivityChanged.map(
        (results) => results.any(
          (r) => r != ConnectivityResult.none,
        ),
      );
}
```

- [ ] **Step 5: Run tests to confirm pass**

```bash
flutter test test/unit/connectivity_service_test.dart
```

Expected: PASS (2 tests)

- [ ] **Step 6: Commit**

```bash
git add lib/core/network/ test/unit/connectivity_service_test.dart
git commit -m "feat: add ConnectivityService with isConnected stream"
```

---

## Task 9: Dio API client and interceptors

**Files:**
- Create: `lib/core/api/api_endpoints.dart`
- Create: `lib/core/api/interceptors/logging_interceptor.dart`
- Create: `lib/core/api/interceptors/auth_interceptor.dart`
- Create: `lib/core/api/interceptors/error_interceptor.dart`
- Create: `lib/core/api/api_client.dart`
- Test: `test/unit/error_interceptor_test.dart`

- [ ] **Step 1: Create lib/core/api/api_endpoints.dart**

```dart
class ApiEndpoints {
  static const String login = '/auth/login';
  static const String register = '/auth/register';
  static const String refresh = '/auth/refresh';
  static const String forgotPassword = '/auth/forgot-password';
  static const String kycDocument = '/kyc/document';
  static const String kycSelfie = '/kyc/selfie';
  static const String kycStatus = '/kyc/status';
  static const String products = '/products';
  static const String transactions = '/transactions';
  static const String invoices = '/invoices';
  static const String referral = '/referral';
}
```

- [ ] **Step 2: Create lib/core/api/interceptors/logging_interceptor.dart**

```dart
import 'package:dio/dio.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';
import '../../config/flavor_config.dart';

class LoggingInterceptor extends Interceptor {
  final PrettyDioLogger _logger = PrettyDioLogger(
    requestHeader: true,
    requestBody: true,
    responseBody: true,
    responseHeader: false,
    error: true,
  );

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    if (FlavorConfig.instance.enableLogging) {
      _logger.onRequest(options, handler);
    } else {
      handler.next(options);
    }
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    if (FlavorConfig.instance.enableLogging) {
      _logger.onResponse(response, handler);
    } else {
      handler.next(response);
    }
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    if (FlavorConfig.instance.enableLogging) {
      _logger.onError(err, handler);
    } else {
      handler.next(err);
    }
  }
}
```

- [ ] **Step 3: Create lib/core/api/interceptors/auth_interceptor.dart**

```dart
import 'package:dio/dio.dart';
import '../../storage/secure_storage_service.dart';

class AuthInterceptor extends Interceptor {
  final SecureStorageService _storage;

  AuthInterceptor(this._storage);

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    final token = await _storage.getAccessToken();
    if (token != null) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    handler.next(options);
  }
}
```

- [ ] **Step 4: Write failing test for ErrorInterceptor**

Create `test/unit/error_interceptor_test.dart`:

```dart
import 'package:bingo_pay/core/api/interceptors/error_interceptor.dart';
import 'package:bingo_pay/core/error/exceptions.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockErrorInterceptorHandler extends Mock
    implements ErrorInterceptorHandler {}

void main() {
  late ErrorInterceptor interceptor;
  late MockErrorInterceptorHandler handler;

  setUp(() {
    interceptor = ErrorInterceptor();
    handler = MockErrorInterceptorHandler();
  });

  group('ErrorInterceptor', () {
    test('rejects with ServerException on 500 response', () {
      final dioError = DioException(
        requestOptions: RequestOptions(path: '/test'),
        response: Response(
          requestOptions: RequestOptions(path: '/test'),
          statusCode: 500,
          data: {'message': 'Internal server error'},
        ),
        type: DioExceptionType.badResponse,
      );

      interceptor.onError(dioError, handler);

      final captured = verify(() => handler.reject(captureAny())).captured;
      expect(captured.first, isA<DioException>());
      expect(
        (captured.first as DioException).error,
        isA<ServerException>(),
      );
    });

    test('rejects with NetworkException on connection error', () {
      final dioError = DioException(
        requestOptions: RequestOptions(path: '/test'),
        type: DioExceptionType.connectionError,
      );

      interceptor.onError(dioError, handler);

      final captured = verify(() => handler.reject(captureAny())).captured;
      expect(
        (captured.first as DioException).error,
        isA<NetworkException>(),
      );
    });
  });
}
```

- [ ] **Step 5: Run to confirm failure**

```bash
flutter test test/unit/error_interceptor_test.dart
```

Expected: FAIL

- [ ] **Step 6: Create lib/core/api/interceptors/error_interceptor.dart**

```dart
import 'package:dio/dio.dart';
import '../../error/exceptions.dart';

class ErrorInterceptor extends Interceptor {
  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    final exception = _mapDioError(err);
    handler.reject(
      DioException(
        requestOptions: err.requestOptions,
        response: err.response,
        type: err.type,
        error: exception,
      ),
    );
  }

  Exception _mapDioError(DioException err) {
    if (err.type == DioExceptionType.connectionError ||
        err.type == DioExceptionType.connectionTimeout ||
        err.type == DioExceptionType.receiveTimeout) {
      return const NetworkException();
    }

    final response = err.response;
    if (response == null) return const NetworkException();

    final message = _extractMessage(response.data) ?? 'Server error';
    final fieldErrors = _extractFieldErrors(response.data);

    return switch (response.statusCode) {
      401 => AuthException(message: message),
      422 => ValidationException(message: message, fieldErrors: fieldErrors),
      _ => ServerException(statusCode: response.statusCode, message: message),
    };
  }

  String? _extractMessage(dynamic data) {
    if (data is Map<String, dynamic>) return data['message'] as String?;
    return null;
  }

  Map<String, String> _extractFieldErrors(dynamic data) {
    if (data is Map<String, dynamic> && data['errors'] is Map) {
      return Map<String, String>.from(data['errors'] as Map);
    }
    return {};
  }
}
```

- [ ] **Step 7: Run tests to confirm pass**

```bash
flutter test test/unit/error_interceptor_test.dart
```

Expected: PASS (2 tests)

- [ ] **Step 8: Create lib/core/api/api_client.dart**

```dart
import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import '../config/app_config.dart';
import '../storage/secure_storage_service.dart';
import 'interceptors/auth_interceptor.dart';
import 'interceptors/error_interceptor.dart';
import 'interceptors/logging_interceptor.dart';

@singleton
class ApiClient {
  late final Dio dio;

  ApiClient(SecureStorageService storage) {
    dio = Dio(
      BaseOptions(
        baseUrl: AppConfig.apiBaseUrl,
        connectTimeout: const Duration(seconds: AppConfig.connectTimeoutSeconds),
        receiveTimeout: const Duration(seconds: AppConfig.receiveTimeoutSeconds),
        headers: {'Content-Type': 'application/json', 'Accept': 'application/json'},
      ),
    );

    dio.interceptors.addAll([
      LoggingInterceptor(),
      AuthInterceptor(storage),
      ErrorInterceptor(),
    ]);
  }
}
```

- [ ] **Step 9: Commit**

```bash
git add lib/core/api/ test/unit/error_interceptor_test.dart
git commit -m "feat: add Dio ApiClient with logging, auth, and error interceptors"
```

---

## Task 10: Dependency injection setup

**Files:**
- Create: `lib/core/di/injection.dart`
- Modify: `lib/core/di/injection.config.dart` (generated)
- Create: `lib/core/di/app_module.dart`

- [ ] **Step 1: Create lib/core/di/app_module.dart**

This registers third-party types that can't use `@injectable` annotations directly.

```dart
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:injectable/injectable.dart';
import 'package:shared_preferences/shared_preferences.dart';

@module
abstract class AppModule {
  @singleton
  FlutterSecureStorage get secureStorage => const FlutterSecureStorage();

  @preResolve
  @singleton
  Future<SharedPreferences> get prefs => SharedPreferences.getInstance();
}
```

- [ ] **Step 2: Create lib/core/di/injection.dart**

```dart
import 'package:get_it/get_it.dart';
import 'package:injectable/injectable.dart';
import 'injection.config.dart';

final GetIt getIt = GetIt.instance;

@InjectableInit()
Future<void> configureDependencies(String environment) async =>
    getIt.init(environment: environment);
```

- [ ] **Step 3: Run code generation**

```bash
flutter pub run build_runner build --delete-conflicting-outputs
```

Expected: `injection.config.dart` is generated in `lib/core/di/`. No errors.

- [ ] **Step 4: Verify the generated file exists**

```bash
cat lib/core/di/injection.config.dart
```

Expected: File exists and contains `getIt.init(...)` registration logic.

- [ ] **Step 5: Commit**

```bash
git add lib/core/di/
git commit -m "feat: set up GetIt + Injectable DI with AppModule for third-party registrations"
```

---

## Task 11: GoRouter skeleton

**Files:**
- Create: `lib/core/router/app_routes.dart`
- Create: `lib/core/router/route_guard.dart`
- Create: `lib/core/router/app_router.dart`
- Test: `test/unit/route_guard_test.dart`

- [ ] **Step 1: Create lib/core/router/app_routes.dart**

```dart
class AppRoutes {
  static const String splash = '/splash';
  static const String login = '/login';
  static const String register = '/register';
  static const String registerKyc = '/register/kyc';
  static const String forgotPassword = '/forgot-password';

  // Buyer shell
  static const String buyerHome = '/buyer/home';
  static const String buyerTransactions = '/buyer/transactions';
  static const String buyerTransactionDetail = '/buyer/transactions/:id';
  static const String buyerRefer = '/buyer/refer';
  static const String buyerInvoices = '/buyer/invoices';
  static const String buyerInvoiceDetail = '/buyer/invoices/:id';

  // Vendor shell
  static const String vendorHome = '/vendor/home';
  static const String vendorProducts = '/vendor/products';
  static const String vendorProductCreate = '/vendor/products/create';
  static const String vendorProductEdit = '/vendor/products/:id/edit';
  static const String vendorTransactions = '/vendor/transactions';
  static const String vendorTransactionDetail = '/vendor/transactions/:id';
  static const String vendorInvoices = '/vendor/invoices';
  static const String vendorInvoiceDetail = '/vendor/invoices/:id';

  static const List<String> publicRoutes = [
    splash,
    login,
    register,
    registerKyc,
    forgotPassword,
  ];
}
```

- [ ] **Step 2: Create lib/core/router/route_guard.dart**

```dart
enum UserRole { buyer, vendor }

// AuthState for routing — simplified mirror of auth BLoC state.
// Updated by AuthBloc via the router's refreshListenable.
class RouteAuthState {
  final bool isAuthenticated;
  final UserRole? role;
  const RouteAuthState({required this.isAuthenticated, this.role});
  const RouteAuthState.unauthenticated()
      : isAuthenticated = false,
        role = null;
}

class RouteGuard {
  static String? redirect({
    required String location,
    required RouteAuthState authState,
  }) {
    final isPublic = AppRoutes.publicRoutes.any(
      (r) => location == r || location.startsWith(r),
    );

    if (!authState.isAuthenticated) {
      return isPublic ? null : AppRoutes.login;
    }

    // Already logged in, redirect away from public routes
    if (isPublic && location != AppRoutes.splash) {
      return authState.role == UserRole.vendor
          ? AppRoutes.vendorHome
          : AppRoutes.buyerHome;
    }

    // Block cross-role navigation
    if (location.startsWith('/vendor') && authState.role != UserRole.vendor) {
      return AppRoutes.buyerHome;
    }
    if (location.startsWith('/buyer') && authState.role != UserRole.buyer) {
      return AppRoutes.vendorHome;
    }

    return null;
  }
}
```

- [ ] **Step 3: Write failing test for RouteGuard**

Create `test/unit/route_guard_test.dart`:

```dart
import 'package:bingo_pay/core/router/app_routes.dart';
import 'package:bingo_pay/core/router/route_guard.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('RouteGuard.redirect', () {
    test('unauthenticated user on protected route redirects to login', () {
      final result = RouteGuard.redirect(
        location: AppRoutes.buyerHome,
        authState: const RouteAuthState.unauthenticated(),
      );
      expect(result, AppRoutes.login);
    });

    test('unauthenticated user on public route is allowed', () {
      final result = RouteGuard.redirect(
        location: AppRoutes.login,
        authState: const RouteAuthState.unauthenticated(),
      );
      expect(result, isNull);
    });

    test('authenticated buyer on vendor route redirects to buyer home', () {
      final result = RouteGuard.redirect(
        location: AppRoutes.vendorHome,
        authState: const RouteAuthState(
          isAuthenticated: true,
          role: UserRole.buyer,
        ),
      );
      expect(result, AppRoutes.buyerHome);
    });

    test('authenticated vendor on vendor route is allowed', () {
      final result = RouteGuard.redirect(
        location: AppRoutes.vendorHome,
        authState: const RouteAuthState(
          isAuthenticated: true,
          role: UserRole.vendor,
        ),
      );
      expect(result, isNull);
    });

    test('authenticated user on login page is redirected to their home', () {
      final result = RouteGuard.redirect(
        location: AppRoutes.login,
        authState: const RouteAuthState(
          isAuthenticated: true,
          role: UserRole.buyer,
        ),
      );
      expect(result, AppRoutes.buyerHome);
    });
  });
}
```

- [ ] **Step 4: Run to confirm failure**

```bash
flutter test test/unit/route_guard_test.dart
```

Expected: FAIL

- [ ] **Step 5: Run tests after creating route_guard.dart**

```bash
flutter test test/unit/route_guard_test.dart
```

Expected: PASS (5 tests)

- [ ] **Step 6: Create lib/core/router/app_router.dart**

```dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:injectable/injectable.dart';
import 'app_routes.dart';
import 'route_guard.dart';

@lazySingleton
class AppRouter {
  late final GoRouter router;
  RouteAuthState _authState = const RouteAuthState.unauthenticated();

  AppRouter() {
    router = GoRouter(
      initialLocation: AppRoutes.splash,
      redirect: (context, state) => RouteGuard.redirect(
        location: state.matchedLocation,
        authState: _authState,
      ),
      routes: [
        GoRoute(
          path: AppRoutes.splash,
          builder: (_, __) => const _SplashPage(),
        ),
        GoRoute(
          path: AppRoutes.login,
          builder: (_, __) => const _PlaceholderPage('Login'),
        ),
        GoRoute(
          path: AppRoutes.register,
          builder: (_, __) => const _PlaceholderPage('Register'),
        ),
        GoRoute(
          path: AppRoutes.forgotPassword,
          builder: (_, __) => const _PlaceholderPage('Forgot Password'),
        ),
        GoRoute(
          path: '/buyer',
          builder: (_, __) => const _PlaceholderPage('Buyer Shell'),
          routes: [
            GoRoute(
              path: 'home',
              builder: (_, __) => const _PlaceholderPage('Buyer Home'),
            ),
          ],
        ),
        GoRoute(
          path: '/vendor',
          builder: (_, __) => const _PlaceholderPage('Vendor Shell'),
          routes: [
            GoRoute(
              path: 'home',
              builder: (_, __) => const _PlaceholderPage('Vendor Home'),
            ),
          ],
        ),
      ],
    );
  }

  void updateAuthState(RouteAuthState state) {
    _authState = state;
    router.refresh();
  }
}

class _SplashPage extends StatelessWidget {
  const _SplashPage();

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(child: CircularProgressIndicator()),
    );
  }
}

class _PlaceholderPage extends StatelessWidget {
  final String name;
  const _PlaceholderPage(this.name);

  @override
  Widget build(BuildContext context) {
    return Scaffold(body: Center(child: Text(name)));
  }
}
```

- [ ] **Step 7: Commit**

```bash
git add lib/core/router/ test/unit/route_guard_test.dart
git commit -m "feat: add GoRouter with role-based route guard and placeholder routes"
```

---

## Task 12: Theme system

**Files:**
- Create: `lib/core/theme/app_colors.dart`
- Create: `lib/core/theme/app_dimensions.dart`
- Create: `lib/core/theme/app_text_styles.dart`
- Create: `lib/core/theme/app_theme.dart`

- [ ] **Step 1: Create lib/core/theme/app_colors.dart**

```dart
import 'package:flutter/material.dart';

class AppColors {
  // Brand
  static const Color primary = Color(0xFF1A73E8);
  static const Color primaryDark = Color(0xFF1557B0);
  static const Color secondary = Color(0xFF34A853);

  // Neutrals
  static const Color backgroundLight = Color(0xFFF8F9FA);
  static const Color backgroundDark = Color(0xFF121212);
  static const Color surfaceLight = Color(0xFFFFFFFF);
  static const Color surfaceDark = Color(0xFF1E1E1E);

  // Text
  static const Color textPrimary = Color(0xFF202124);
  static const Color textSecondary = Color(0xFF5F6368);
  static const Color textPrimaryDark = Color(0xFFE8EAED);
  static const Color textSecondaryDark = Color(0xFF9AA0A6);

  // Semantic
  static const Color success = Color(0xFF34A853);
  static const Color error = Color(0xFFEA4335);
  static const Color warning = Color(0xFFFBBC04);
  static const Color info = Color(0xFF4285F4);

  // Dividers
  static const Color divider = Color(0xFFE0E0E0);
}
```

- [ ] **Step 2: Create lib/core/theme/app_dimensions.dart**

```dart
class AppDimensions {
  // Spacing
  static const double xs = 4.0;
  static const double sm = 8.0;
  static const double md = 16.0;
  static const double lg = 24.0;
  static const double xl = 32.0;
  static const double xxl = 48.0;

  // Border radius
  static const double radiusSm = 4.0;
  static const double radiusMd = 8.0;
  static const double radiusLg = 12.0;
  static const double radiusXl = 16.0;
  static const double radiusCircular = 999.0;

  // Icon sizes
  static const double iconSm = 16.0;
  static const double iconMd = 24.0;
  static const double iconLg = 32.0;

  // Input
  static const double inputHeight = 52.0;
  static const double buttonHeight = 52.0;

  // AppBar
  static const double appBarHeight = 56.0;
}
```

- [ ] **Step 3: Create lib/core/theme/app_text_styles.dart**

```dart
import 'package:flutter/material.dart';
import 'app_colors.dart';

class AppTextStyles {
  static const TextStyle displayLarge = TextStyle(
    fontSize: 32,
    fontWeight: FontWeight.w700,
    color: AppColors.textPrimary,
    letterSpacing: -0.5,
  );

  static const TextStyle headlineMedium = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.w700,
    color: AppColors.textPrimary,
  );

  static const TextStyle titleLarge = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
  );

  static const TextStyle bodyLarge = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w400,
    color: AppColors.textPrimary,
    height: 1.5,
  );

  static const TextStyle bodyMedium = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    color: AppColors.textPrimary,
    height: 1.5,
  );

  static const TextStyle labelMedium = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w500,
    color: AppColors.textSecondary,
    letterSpacing: 0.4,
  );

  static const TextStyle buttonText = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.2,
  );
}
```

- [ ] **Step 4: Create lib/core/theme/app_theme.dart**

```dart
import 'package:flutter/material.dart';
import 'app_colors.dart';
import 'app_dimensions.dart';
import 'app_text_styles.dart';

class AppTheme {
  static ThemeData get light => _buildTheme(Brightness.light);
  static ThemeData get dark => _buildTheme(Brightness.dark);

  static ThemeData _buildTheme(Brightness brightness) {
    final isLight = brightness == Brightness.light;
    final colorScheme = ColorScheme.fromSeed(
      seedColor: AppColors.primary,
      brightness: brightness,
      background: isLight ? AppColors.backgroundLight : AppColors.backgroundDark,
      surface: isLight ? AppColors.surfaceLight : AppColors.surfaceDark,
      error: AppColors.error,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      textTheme: TextTheme(
        displayLarge: AppTextStyles.displayLarge,
        headlineMedium: AppTextStyles.headlineMedium,
        titleLarge: AppTextStyles.titleLarge,
        bodyLarge: AppTextStyles.bodyLarge,
        bodyMedium: AppTextStyles.bodyMedium,
        labelMedium: AppTextStyles.labelMedium,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          minimumSize: const Size(double.infinity, AppDimensions.buttonHeight),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
          ),
          textStyle: AppTextStyles.buttonText,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: isLight ? AppColors.backgroundLight : AppColors.surfaceDark,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
          borderSide: const BorderSide(color: AppColors.divider),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
          borderSide: const BorderSide(color: AppColors.divider),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
          borderSide: const BorderSide(color: AppColors.primary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
          borderSide: const BorderSide(color: AppColors.error),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppDimensions.md,
          vertical: AppDimensions.md,
        ),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: isLight ? AppColors.surfaceLight : AppColors.surfaceDark,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: AppTextStyles.titleLarge,
        iconTheme: const IconThemeData(color: AppColors.textPrimary),
      ),
      scaffoldBackgroundColor:
          isLight ? AppColors.backgroundLight : AppColors.backgroundDark,
      dividerColor: AppColors.divider,
    );
  }
}
```

- [ ] **Step 5: Commit**

```bash
git add lib/core/theme/
git commit -m "feat: add Material 3 theme system with token-based colors, dimensions, text styles"
```

---

## Task 13: Core shared widgets

**Files:**
- Create: `lib/core/widgets/app_button.dart`
- Create: `lib/core/widgets/app_text_field.dart`
- Create: `lib/core/widgets/app_loader.dart`
- Create: `lib/core/widgets/app_snackbar.dart`
- Create: `lib/core/widgets/app_error_widget.dart`
- Test: `test/widget/app_button_test.dart`

- [ ] **Step 1: Create lib/core/widgets/app_button.dart**

```dart
import 'package:flutter/material.dart';

enum AppButtonVariant { primary, secondary, outlined }

class AppButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final bool isLoading;
  final AppButtonVariant variant;

  const AppButton({
    super.key,
    required this.label,
    this.onPressed,
    this.isLoading = false,
    this.variant = AppButtonVariant.primary,
  });

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const SizedBox(
        height: 52,
        child: Center(child: CircularProgressIndicator()),
      );
    }

    return switch (variant) {
      AppButtonVariant.primary => ElevatedButton(
          onPressed: onPressed,
          child: Text(label),
        ),
      AppButtonVariant.secondary => FilledButton.tonal(
          onPressed: onPressed,
          child: Text(label),
        ),
      AppButtonVariant.outlined => OutlinedButton(
          onPressed: onPressed,
          child: Text(label),
        ),
    };
  }
}
```

- [ ] **Step 2: Write widget test for AppButton**

Create `test/widget/app_button_test.dart`:

```dart
import 'package:bingo_pay/core/widgets/app_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  Widget buildSubject({
    VoidCallback? onPressed,
    bool isLoading = false,
  }) {
    return MaterialApp(
      home: Scaffold(
        body: AppButton(
          label: 'Test Button',
          onPressed: onPressed,
          isLoading: isLoading,
        ),
      ),
    );
  }

  group('AppButton', () {
    testWidgets('shows label when not loading', (tester) async {
      await tester.pumpWidget(buildSubject(onPressed: () {}));
      expect(find.text('Test Button'), findsOneWidget);
    });

    testWidgets('shows loading indicator when isLoading is true', (tester) async {
      await tester.pumpWidget(buildSubject(isLoading: true));
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.text('Test Button'), findsNothing);
    });

    testWidgets('calls onPressed when tapped', (tester) async {
      var tapped = false;
      await tester.pumpWidget(buildSubject(onPressed: () => tapped = true));
      await tester.tap(find.text('Test Button'));
      expect(tapped, isTrue);
    });
  });
}
```

- [ ] **Step 3: Run widget test**

```bash
flutter test test/widget/app_button_test.dart
```

Expected: PASS (3 tests)

- [ ] **Step 4: Create lib/core/widgets/app_text_field.dart**

```dart
import 'package:flutter/material.dart';

class AppTextField extends StatelessWidget {
  final String label;
  final String? hint;
  final TextEditingController? controller;
  final bool obscureText;
  final TextInputType keyboardType;
  final String? Function(String?)? validator;
  final void Function(String)? onChanged;
  final Widget? suffixIcon;
  final Widget? prefixIcon;
  final bool enabled;

  const AppTextField({
    super.key,
    required this.label,
    this.hint,
    this.controller,
    this.obscureText = false,
    this.keyboardType = TextInputType.text,
    this.validator,
    this.onChanged,
    this.suffixIcon,
    this.prefixIcon,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      validator: validator,
      onChanged: onChanged,
      enabled: enabled,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        suffixIcon: suffixIcon,
        prefixIcon: prefixIcon,
      ),
    );
  }
}
```

- [ ] **Step 5: Create lib/core/widgets/app_loader.dart**

```dart
import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class AppLoader extends StatelessWidget {
  final String? message;
  const AppLoader({super.key, this.message});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const CircularProgressIndicator(color: AppColors.primary),
          if (message != null) ...[
            const SizedBox(height: 16),
            Text(message!, style: Theme.of(context).textTheme.bodyMedium),
          ],
        ],
      ),
    );
  }
}
```

- [ ] **Step 6: Create lib/core/widgets/app_snackbar.dart**

```dart
import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class AppSnackbar {
  static void showError(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.error,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  static void showSuccess(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.success,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  static void showOfflineBanner(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('No internet connection'),
        backgroundColor: AppColors.warning,
        behavior: SnackBarBehavior.floating,
        duration: Duration(days: 1),
      ),
    );
  }
}
```

- [ ] **Step 7: Create lib/core/widgets/app_error_widget.dart**

```dart
import 'package:flutter/material.dart';
import '../error/failures.dart';
import 'app_button.dart';

class AppErrorWidget extends StatelessWidget {
  final Failure failure;
  final VoidCallback? onRetry;

  const AppErrorWidget({super.key, required this.failure, this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, size: 48, color: Colors.red),
            const SizedBox(height: 16),
            Text(
              failure.message,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            if (onRetry != null) ...[
              const SizedBox(height: 24),
              AppButton(label: 'Try Again', onPressed: onRetry),
            ],
          ],
        ),
      ),
    );
  }
}
```

- [ ] **Step 8: Commit**

```bash
git add lib/core/widgets/ test/widget/app_button_test.dart
git commit -m "feat: add core shared widgets — AppButton, AppTextField, AppLoader, AppSnackbar, AppErrorWidget"
```

---

## Task 14: AppBlocObserver, App root widget, and complete bootstrap

**Files:**
- Create: `lib/app/app_bloc_observer.dart`
- Create: `lib/app/app.dart`
- Modify: `lib/app/bootstrap.dart`
- Modify: `lib/main_dev.dart`, `lib/main_staging.dart`, `lib/main_prod.dart`

- [ ] **Step 1: Create lib/app/app_bloc_observer.dart**

```dart
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:logger/logger.dart';
import '../core/config/flavor_config.dart';

class AppBlocObserver extends BlocObserver {
  final Logger _logger = Logger();

  @override
  void onChange(BlocBase bloc, Change change) {
    super.onChange(bloc, change);
    if (FlavorConfig.instance.enableLogging) {
      _logger.d('[${bloc.runtimeType}] $change');
    }
  }

  @override
  void onError(BlocBase bloc, Object error, StackTrace stackTrace) {
    _logger.e('[${bloc.runtimeType}] Error', error: error, stackTrace: stackTrace);
    super.onError(bloc, error, stackTrace);
  }

  @override
  void onTransition(Bloc bloc, Transition transition) {
    super.onTransition(bloc, transition);
    if (FlavorConfig.instance.enableLogging) {
      _logger.d('[${bloc.runtimeType}] $transition');
    }
  }
}
```

- [ ] **Step 2: Create lib/app/app.dart**

```dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../core/di/injection.dart';
import '../core/network/connectivity_service.dart';
import '../core/router/app_router.dart';
import '../core/theme/app_theme.dart';
import '../core/widgets/app_snackbar.dart';

class App extends StatefulWidget {
  const App({super.key});

  @override
  State<App> createState() => _AppState();
}

class _AppState extends State<App> {
  final _router = getIt<AppRouter>();
  final _connectivity = getIt<ConnectivityService>();

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<bool>(
      stream: _connectivity.isConnected,
      builder: (context, snapshot) {
        final isConnected = snapshot.data ?? true;

        return MaterialApp.router(
          title: 'Bingo Pay',
          theme: AppTheme.light,
          darkTheme: AppTheme.dark,
          routerConfig: _router.router,
          builder: (context, child) {
            if (!isConnected) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                AppSnackbar.showOfflineBanner(context);
              });
            }
            return child ?? const SizedBox.shrink();
          },
        );
      },
    );
  }
}
```

- [ ] **Step 3: Update lib/app/bootstrap.dart with full initialization**

```dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../core/config/flavor_config.dart';
import '../core/di/injection.dart';
import 'app.dart';
import 'app_bloc_observer.dart';

Future<void> bootstrap() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize DI with the current flavor as the environment key
  await configureDependencies(FlavorConfig.instance.flavor.name);

  // Register global BLoC observer
  Bloc.observer = AppBlocObserver();

  runApp(const App());
}
```

- [ ] **Step 4: Update all three main files to call bootstrap correctly**

Update `lib/main_dev.dart`:
```dart
import 'package:bingo_pay/app/bootstrap.dart';
import 'package:bingo_pay/core/config/flavor_config.dart';

void main() async {
  FlavorConfig.instance = const FlavorConfig(
    flavor: Flavor.dev,
    apiBaseUrl: 'https://dev-api.bingopay.com/v1',
    appName: 'Bingo Pay DEV',
    enableLogging: true,
    enableAnalytics: false,
  );
  await bootstrap();
}
```

Update `lib/main_staging.dart`:
```dart
import 'package:bingo_pay/app/bootstrap.dart';
import 'package:bingo_pay/core/config/flavor_config.dart';

void main() async {
  FlavorConfig.instance = const FlavorConfig(
    flavor: Flavor.staging,
    apiBaseUrl: 'https://stg-api.bingopay.com/v1',
    appName: 'Bingo Pay STG',
    enableLogging: true,
    enableAnalytics: false,
  );
  await bootstrap();
}
```

Update `lib/main_prod.dart`:
```dart
import 'package:bingo_pay/app/bootstrap.dart';
import 'package:bingo_pay/core/config/flavor_config.dart';

void main() async {
  FlavorConfig.instance = const FlavorConfig(
    flavor: Flavor.prod,
    apiBaseUrl: 'https://api.bingopay.com/v1',
    appName: 'Bingo Pay',
    enableLogging: false,
    enableAnalytics: true,
  );
  await bootstrap();
}
```

- [ ] **Step 5: Re-run code generation to pick up any new @injectable classes**

```bash
flutter pub run build_runner build --delete-conflicting-outputs
```

Expected: `injection.config.dart` regenerated with all services registered.

- [ ] **Step 6: Run all tests**

```bash
flutter test
```

Expected: All tests PASS. No failures.

- [ ] **Step 7: Commit**

```bash
git add lib/app/ lib/main_dev.dart lib/main_staging.dart lib/main_prod.dart lib/core/di/injection.config.dart
git commit -m "feat: wire up App root widget, AppBlocObserver, and complete bootstrap initialization"
```

---

## Task 15: Final verification — app runs on all three flavors

- [ ] **Step 1: Run full test suite**

```bash
flutter test
```

Expected: All tests PASS.

- [ ] **Step 2: Analyze for issues**

```bash
flutter analyze
```

Expected: No errors. Warnings about unused imports are acceptable to fix.

- [ ] **Step 3: Launch on dev flavor**

```bash
flutter run --flavor dev --target lib/main_dev.dart
```

Expected: App launches, shows splash screen (loading spinner), no crash. Dev API URL is used.

- [ ] **Step 4: Launch on staging flavor**

```bash
flutter run --flavor staging --target lib/main_staging.dart
```

Expected: App launches, staging API URL is used.

- [ ] **Step 5: Verify offline banner**

With the app running, disable device WiFi. Expected: offline snackbar appears within a few seconds.

- [ ] **Step 6: Final commit**

```bash
git add .
git commit -m "chore: foundation complete — all flavors launch, all tests pass, flutter analyze clean"
```

---

## Self-Review Checklist

- [x] **Spec §3 (Flavors):** Tasks 2, 3, 4 cover Android productFlavors, iOS schemes, and FlavorConfig
- [x] **Spec §4 (Folder Structure):** Task 1 creates complete scaffold
- [x] **Spec §6.1 (API Client):** Task 9 covers Dio + 3 interceptors
- [x] **Spec §6.2 (Error Hierarchy):** Task 5 covers sealed Failure + error_handler
- [x] **Spec §6.3 (Base State):** Task 6 covers sealed AppState
- [x] **Spec §6.4 (Router):** Task 11 covers GoRouter + route guard with tests
- [x] **Spec §6.5 (DI):** Task 10 covers GetIt + Injectable + AppModule
- [x] **Spec §6.6 (Storage):** Task 7 covers SecureStorageService + PreferencesService
- [x] **Spec §6.7 (Theme):** Task 12 covers Material 3 token-based theme
- [x] **Spec §6.8 (Connectivity):** Task 8 covers ConnectivityService with stream
- [x] **Spec §12 (CI/CD):** build commands are captured in Task 15 verification steps
- [x] **All types consistent:** `RouteAuthState`, `UserRole`, `AppState<T>`, `Failure` sealed class used consistently across tasks
- [x] **No TBD/TODO placeholders**
- [x] **Test coverage:** Unit tests for FlavorConfig, ErrorHandler, AppState, SecureStorage, Connectivity, ErrorInterceptor, RouteGuard. Widget test for AppButton.

**Not covered in this plan (covered in Plan 2 — Auth Feature):**
- Auth BLoC + use cases (login, register, KYC, forgot password)
- Token refresh flow wired into AuthInterceptor
- KYC screen and document upload
- Role-aware router updates after login
