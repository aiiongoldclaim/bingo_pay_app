---
name: assets-image-constants-design
description: Design spec for registering project assets in pubspec.yaml and creating a centralized AppImages constants file under lib/core/constants/
metadata:
  type: project
---

# Assets & Image Constants

**Date:** 2026-06-10  
**Status:** Approved

## Overview

Register the existing `assets/` directory in `pubspec.yaml` and create a centralized `AppImages` class at `lib/core/constants/image_constants.dart` that exposes all image and icon paths as typed constants.

## Problem

- The `assets/` directory exists and contains files but is not declared in `pubspec.yaml`, so Flutter does not bundle them.
- Image/icon paths are used as raw strings scattered across the codebase, making refactoring and typo detection error-prone.

## Design

### 1. pubspec.yaml — Asset Registration

Add asset folder declarations under the `flutter:` section:

```yaml
flutter:
  uses-material-design: true
  generate: true
  assets:
    - assets/images/
    - assets/icons/
```

Declaring folders (with trailing slash) means new files added to either folder are automatically bundled without further pubspec changes.

### 2. Directory Structure

```
lib/core/
  config/
    app_constants.dart    (existing — runtime/storage keys)
    app_config.dart       (existing)
    flavor_config.dart    (existing)
  constants/              ← new folder
    image_constants.dart  ← new file
```

`constants/` is separate from `config/` to distinguish static asset paths (never change at runtime) from runtime configuration values.

### 3. image_constants.dart

```dart
class AppImages {
  AppImages._();

  // Images
  static const String logo = 'assets/images/logo.png';

  // Icons
  static const String logoIcon = 'assets/icons/logo_icon.png';
}
```

**Conventions:**
- Private constructor — class is never instantiated.
- Names are camelCase, derived from the filename without extension.
- Sections (`// Images`, `// Icons`) match the folder structure.
- New assets are added to the matching section as files are added to the folder.

### 4. Usage Pattern

```dart
Image.asset(AppImages.logo)
Image.asset(AppImages.logoIcon)
```

## Scope

- Declare `assets/images/` and `assets/icons/` in `pubspec.yaml`.
- Create `lib/core/constants/` folder.
- Create `lib/core/constants/image_constants.dart` with current assets.

No changes to existing files other than `pubspec.yaml`.

## Out of Scope

- SVG support (no svg package currently in dependencies).
- Code generation (e.g., flutter_gen) — overkill for current asset count.
- Migrating existing hardcoded path strings — to be done as part of screens that use them.
