# flutter_flavor Integration Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Replace the hand-rolled `FlavorConfig` class with `flutter_flavor 3.1.4`, add a `FlavorBanner` for dev/staging builds, and create VSCode launch configurations for all three flavors.

**Architecture:** `flutter_flavor`'s `FlavorConfig` singleton replaces the custom class. The `Flavor` enum and typed helpers (`isDev`, `isStaging`, `isProduction`) are preserved via a Dart extension. `FlavorBanner` wraps `App()` in non-prod builds inside `bootstrap.dart`.

**Tech Stack:** Flutter, `flutter_flavor: 3.1.4`, GetIt + Injectable DI, flutter_test

---

## File Map

| File | Action |
|---|---|
| `pubspec.yaml` | Add `flutter_flavor: 3.1.4` |
| `lib/core/config/flavor_config.dart` | Full rewrite — keep `Flavor` enum, replace class with `AppFlavorConfig` extension |
| `lib/core/config/app_config.dart` | Update `apiBaseUrl` getter to read from `FlavorConfig.instance.variables` |
| `lib/main_dev.dart` | Use flutter_flavor `FlavorConfig(...)` init |
| `lib/main_staging.dart` | Use flutter_flavor `FlavorConfig(...)` init |
| `lib/main_prod.dart` | Use flutter_flavor `FlavorConfig(...)` init |
| `lib/app/bootstrap.dart` | Add conditional `FlavorBanner` wrap, remove old import |
| `.vscode/launch.json` | Create — 3 launch configurations |
| `test/unit/flavor_config_test.dart` | Rewrite for new extension API |
| `test/unit/app_config_test.dart` | Create — tests `apiBaseUrl` getter |

---

### Task 1: Add flutter_flavor dependency

**Files:**
- Modify: `pubspec.yaml`

- [ ] **Step 1: Add the dependency**

Open `pubspec.yaml` and add under `dependencies:` (after `fpdart`):

```yaml
  # Flavor configuration
  flutter_flavor: 3.1.4
```

- [ ] **Step 2: Fetch the package**

```bash
flutter pub get
```

Expected output includes: `+ flutter_flavor 3.1.4`

- [ ] **Step 3: Commit**

```bash
git add pubspec.yaml pubspec.lock
git commit -m "feat: add flutter_flavor 3.1.4 dependency"
```

---

### Task 2: Rewrite flavor_config.dart (TDD)

**Files:**
- Modify: `lib/core/config/flavor_config.dart`
- Modify: `test/unit/flavor_config_test.dart`

- [ ] **Step 1: Rewrite the test file**

Replace the entire contents of `test/unit/flavor_config_test.dart`:

```dart
import 'package:bingo_pay/core/config/flavor_config.dart';
import 'package:flutter/material.dart';
import 'package:flutter_flavor/flutter_flavor.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('AppFlavorConfig extension', () {
    test('isDev returns true for dev flavor', () {
      FlavorConfig(
        flavor: 'dev',
        color: Colors.green,
        variables: const {
          'apiBaseUrl': 'https://dev-api.bingopay.com/v1',
          'appName': 'Bingo Pay DEV',
          'enableLogging': true,
          'enableAnalytics': false,
        },
      );

      expect(FlavorConfig.instance.isDev, isTrue);
      expect(FlavorConfig.instance.isStaging, isFalse);
      expect(FlavorConfig.instance.isProduction, isFalse);
    });

    test('isStaging returns true for staging flavor', () {
      FlavorConfig(
        flavor: 'staging',
        color: Colors.orange,
        variables: const {
          'apiBaseUrl': 'https://stg-api.bingopay.com/v1',
          'appName': 'Bingo Pay STG',
          'enableLogging': true,
          'enableAnalytics': false,
        },
      );

      expect(FlavorConfig.instance.isStaging, isTrue);
      expect(FlavorConfig.instance.isDev, isFalse);
      expect(FlavorConfig.instance.isProduction, isFalse);
    });

    test('isProduction returns true for prod flavor', () {
      FlavorConfig(
        flavor: 'prod',
        color: Colors.transparent,
        variables: const {
          'apiBaseUrl': 'https://api.bingopay.com/v1',
          'appName': 'Bingo Pay',
          'enableLogging': false,
          'enableAnalytics': true,
        },
      );

      expect(FlavorConfig.instance.isProduction, isTrue);
      expect(FlavorConfig.instance.isDev, isFalse);
      expect(FlavorConfig.instance.isStaging, isFalse);
    });

    test('appFlavor maps flavor string to Flavor enum', () {
      FlavorConfig(
        flavor: 'staging',
        color: Colors.orange,
        variables: const {},
      );

      expect(FlavorConfig.instance.appFlavor, Flavor.staging);
    });
  });
}
```

- [ ] **Step 2: Run the test — verify it fails**

```bash
flutter test test/unit/flavor_config_test.dart
```

Expected: compilation error — `isDev`, `isStaging`, `isProduction`, `appFlavor`, `Flavor` not found.

- [ ] **Step 3: Rewrite flavor_config.dart**

Replace the entire contents of `lib/core/config/flavor_config.dart`:

```dart
import 'package:flutter_flavor/flutter_flavor.dart';

enum Flavor { dev, staging, prod }

extension AppFlavorConfig on FlavorConfig {
  Flavor get appFlavor => Flavor.values.firstWhere(
        (f) => f.name == FlavorConfig.instance.flavor,
      );

  bool get isDev => FlavorConfig.instance.flavor == 'dev';
  bool get isStaging => FlavorConfig.instance.flavor == 'staging';
  bool get isProduction => FlavorConfig.instance.flavor == 'prod';
}
```

- [ ] **Step 4: Run the test — verify it passes**

```bash
flutter test test/unit/flavor_config_test.dart
```

Expected: All 4 tests PASS.

- [ ] **Step 5: Commit**

```bash
git add lib/core/config/flavor_config.dart test/unit/flavor_config_test.dart
git commit -m "feat: replace custom FlavorConfig with flutter_flavor extension"
```

---

### Task 3: Update AppConfig (TDD)

**Files:**
- Modify: `lib/core/config/app_config.dart`
- Create: `test/unit/app_config_test.dart`

- [ ] **Step 1: Write the failing test**

Create `test/unit/app_config_test.dart`:

```dart
import 'package:bingo_pay/core/config/app_config.dart';
import 'package:flutter/material.dart';
import 'package:flutter_flavor/flutter_flavor.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('AppConfig', () {
    test('apiBaseUrl reads from FlavorConfig variables', () {
      FlavorConfig(
        flavor: 'dev',
        color: Colors.green,
        variables: const {
          'apiBaseUrl': 'https://dev-api.bingopay.com/v1',
        },
      );

      expect(AppConfig.apiBaseUrl, 'https://dev-api.bingopay.com/v1');
    });

    test('apiBaseUrl reflects the active flavor', () {
      FlavorConfig(
        flavor: 'prod',
        color: Colors.transparent,
        variables: const {
          'apiBaseUrl': 'https://api.bingopay.com/v1',
        },
      );

      expect(AppConfig.apiBaseUrl, 'https://api.bingopay.com/v1');
    });
  });
}
```

- [ ] **Step 2: Run the test — verify it fails**

```bash
flutter test test/unit/app_config_test.dart
```

Expected: FAIL — `AppConfig.apiBaseUrl` still reads from the old `FlavorConfig` class which no longer exists.

- [ ] **Step 3: Update app_config.dart**

Replace the entire contents of `lib/core/config/app_config.dart`:

```dart
import 'package:flutter_flavor/flutter_flavor.dart';

class AppConfig {
  static const int connectTimeoutSeconds = 30;
  static const int receiveTimeoutSeconds = 30;
  static const int pageSize = 20;
  static const int kycPollingIntervalSeconds = 10;

  static String get apiBaseUrl =>
      FlavorConfig.instance.variables['apiBaseUrl'] as String;
}
```

- [ ] **Step 4: Run the test — verify it passes**

```bash
flutter test test/unit/app_config_test.dart
```

Expected: Both tests PASS.

- [ ] **Step 5: Commit**

```bash
git add lib/core/config/app_config.dart test/unit/app_config_test.dart
git commit -m "feat: update AppConfig to read apiBaseUrl from flutter_flavor variables"
```

---

### Task 4: Update main entry points

**Files:**
- Modify: `lib/main_dev.dart`
- Modify: `lib/main_staging.dart`
- Modify: `lib/main_prod.dart`

- [ ] **Step 1: Replace main_dev.dart**

```dart
import 'package:bingo_pay/app/bootstrap.dart';
import 'package:flutter/material.dart';
import 'package:flutter_flavor/flutter_flavor.dart';

void main() async {
  FlavorConfig(
    flavor: 'dev',
    color: Colors.green,
    variables: const {
      'apiBaseUrl': 'https://dev-api.bingopay.com/v1',
      'appName': 'Bingo Pay DEV',
      'enableLogging': true,
      'enableAnalytics': false,
    },
  );
  await bootstrap();
}
```

- [ ] **Step 2: Replace main_staging.dart**

```dart
import 'package:bingo_pay/app/bootstrap.dart';
import 'package:flutter/material.dart';
import 'package:flutter_flavor/flutter_flavor.dart';

void main() async {
  FlavorConfig(
    flavor: 'staging',
    color: Colors.orange,
    variables: const {
      'apiBaseUrl': 'https://stg-api.bingopay.com/v1',
      'appName': 'Bingo Pay STG',
      'enableLogging': true,
      'enableAnalytics': false,
    },
  );
  await bootstrap();
}
```

- [ ] **Step 3: Replace main_prod.dart**

```dart
import 'package:bingo_pay/app/bootstrap.dart';
import 'package:flutter/material.dart';
import 'package:flutter_flavor/flutter_flavor.dart';

void main() async {
  FlavorConfig(
    flavor: 'prod',
    color: Colors.transparent,
    variables: const {
      'apiBaseUrl': 'https://api.bingopay.com/v1',
      'appName': 'Bingo Pay',
      'enableLogging': false,
      'enableAnalytics': true,
    },
  );
  await bootstrap();
}
```

- [ ] **Step 4: Verify compilation**

```bash
flutter analyze lib/main_dev.dart lib/main_staging.dart lib/main_prod.dart
```

Expected: No issues found.

- [ ] **Step 5: Commit**

```bash
git add lib/main_dev.dart lib/main_staging.dart lib/main_prod.dart
git commit -m "feat: initialize flutter_flavor FlavorConfig in each entry point"
```

---

### Task 5: Update bootstrap.dart with FlavorBanner

**Files:**
- Modify: `lib/app/bootstrap.dart`

- [ ] **Step 1: Replace bootstrap.dart**

```dart
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_flavor/flutter_flavor.dart';
import '../core/config/flavor_config.dart';
import '../core/di/injection.dart';
import 'app.dart';
import 'app_bloc_observer.dart';

Future<void> bootstrap() async {
  WidgetsFlutterBinding.ensureInitialized();
  await configureDependencies(FlavorConfig.instance.flavor);
  Bloc.observer = AppBlocObserver();
  runApp(
    FlavorConfig.instance.isProduction
        ? const App()
        : FlavorBanner(child: const App()),
  );
}
```

- [ ] **Step 2: Run the full test suite**

```bash
flutter test
```

Expected: All tests PASS. (The `FlavorBanner` wrapping is exercised at runtime; existing unit tests cover the config logic.)

- [ ] **Step 3: Commit**

```bash
git add lib/app/bootstrap.dart
git commit -m "feat: wrap App in FlavorBanner for dev and staging builds"
```

---

### Task 6: Create .vscode/launch.json

**Files:**
- Create: `.vscode/launch.json`

- [ ] **Step 1: Create the .vscode directory and launch.json**

Create `.vscode/launch.json` with this content:

```json
{
  "version": "0.2.0",
  "configurations": [
    {
      "name": "Bingo Pay (dev)",
      "request": "launch",
      "type": "dart",
      "program": "lib/main_dev.dart"
    },
    {
      "name": "Bingo Pay (staging)",
      "request": "launch",
      "type": "dart",
      "program": "lib/main_staging.dart"
    },
    {
      "name": "Bingo Pay (prod)",
      "request": "launch",
      "type": "dart",
      "program": "lib/main_prod.dart"
    }
  ]
}
```

- [ ] **Step 2: Commit**

```bash
git add .vscode/launch.json
git commit -m "feat: add VSCode launch configurations for dev, staging, and prod flavors"
```

---

### Task 7: Final verification

- [ ] **Step 1: Run the full test suite**

```bash
flutter test
```

Expected: All tests PASS with no failures.

- [ ] **Step 2: Run static analysis**

```bash
flutter analyze
```

Expected: No issues found.

- [ ] **Step 3: Verify no stale imports remain**

```bash
grep -r "FlavorConfig.instance.apiBaseUrl\|FlavorConfig.instance.appName\|FlavorConfig.instance.enableLogging\|FlavorConfig.instance.enableAnalytics" lib/
```

Expected: No output — all old typed property accesses removed.

- [ ] **Step 4: Smoke-test the dev flavor**

```bash
flutter run --target lib/main_dev.dart
```

Expected: App launches with a green ribbon banner visible in the top corner showing "dev".
