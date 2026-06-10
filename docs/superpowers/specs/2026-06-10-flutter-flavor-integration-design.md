---
name: flutter-flavor-integration
description: Migrate bingo_pay from manual FlavorConfig to flutter_flavor 3.1.4 with VSCode launch configurations
metadata:
  type: project
---

# flutter_flavor Integration Design

**Date:** 2026-06-10  
**Flavors:** dev, staging, prod  
**Package:** `flutter_flavor: 3.1.4`

## Overview

Replace the hand-rolled `FlavorConfig` class with `flutter_flavor`'s `FlavorConfig`. The `Flavor` enum and typed helpers (`isDev`, `isStaging`, `isProduction`) are preserved via a Dart extension. A `FlavorBanner` ribbon is shown on-screen in dev and staging builds. A VSCode `launch.json` provides one-click launch for each flavor.

No native (Android/iOS) build configuration is required — `flutter_flavor` is pure Dart.

## Files Changed

| File | Action |
|---|---|
| `pubspec.yaml` | Add `flutter_flavor: 3.1.4` |
| `lib/core/config/flavor_config.dart` | Replace custom class — keep `Flavor` enum, add `AppFlavorConfig` extension |
| `lib/main_dev.dart` | Initialize flutter_flavor `FlavorConfig` with dev values |
| `lib/main_staging.dart` | Initialize flutter_flavor `FlavorConfig` with staging values |
| `lib/main_prod.dart` | Initialize flutter_flavor `FlavorConfig` with prod values |
| `lib/core/config/app_config.dart` | Read `apiBaseUrl` from `FlavorConfig.instance.variables` |
| `lib/app/bootstrap.dart` | Conditionally wrap `App()` in `FlavorBanner` for non-prod |
| `.vscode/launch.json` | New file — 3 launch configurations |

## flavor_config.dart

Keep the `Flavor` enum for type-safe comparisons. Remove the old `FlavorConfig` class entirely. Add an extension on flutter_flavor's `FlavorConfig`:

```dart
import 'package:flutter_flavor/flutter_flavor.dart';

enum Flavor { dev, staging, prod }

extension AppFlavorConfig on FlavorConfig {
  Flavor get appFlavor => Flavor.values.firstWhere(
        (f) => f.name == FlavorConfig.instance.flavor,
      );
  bool get isDev => FlavorConfig.instance.flavor == 'dev';
  bool get isStaging => FlavorConfig.instance.flavor == 'staging';
}
```

`FlavorConfig.instance.isProduction` is provided by `flutter_flavor` itself (true when flavor is `"prod"` or `"production"`).

## main_*.dart Initialization

Each entry point calls `FlavorConfig(...)` before `bootstrap()`:

**dev** — color: `Colors.green`
```dart
FlavorConfig(
  flavor: 'dev',
  color: Colors.green,
  variables: {
    'apiBaseUrl': 'https://dev-api.bingopay.com/v1',
    'appName': 'Bingo Pay DEV',
    'enableLogging': true,
    'enableAnalytics': false,
  },
);
```

**staging** — color: `Colors.orange`
```dart
FlavorConfig(
  flavor: 'staging',
  color: Colors.orange,
  variables: {
    'apiBaseUrl': 'https://stg-api.bingopay.com/v1',
    'appName': 'Bingo Pay STG',
    'enableLogging': true,
    'enableAnalytics': false,
  },
);
```

**prod** — color: `Colors.transparent` (no visible banner)
```dart
FlavorConfig(
  flavor: 'prod',
  color: Colors.transparent,
  variables: {
    'apiBaseUrl': 'https://api.bingopay.com/v1',
    'appName': 'Bingo Pay',
    'enableLogging': false,
    'enableAnalytics': true,
  },
);
```

## AppConfig

```dart
static String get apiBaseUrl =>
    FlavorConfig.instance.variables['apiBaseUrl'] as String;
```

## bootstrap.dart

```dart
final showBanner = !FlavorConfig.instance.isProduction;
runApp(
  showBanner ? FlavorBanner(child: const App()) : const App(),
);
```

DI initialization:
```dart
await configureDependencies(FlavorConfig.instance.flavor);
```

## .vscode/launch.json

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

## Out of Scope

- Native Android `productFlavors` / iOS schemes — not needed for `flutter_flavor`
- Flavor-specific app icons or splash screens
- Firebase or other per-flavor SDK configuration
