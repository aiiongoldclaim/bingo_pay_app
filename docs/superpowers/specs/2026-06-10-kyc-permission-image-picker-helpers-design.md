# KYC Permission & Image Picker Helpers Design

**Date:** 2026-06-10  
**Status:** Approved

## Overview

Extract permission handling and image picking into two dedicated helper classes so that KYC screens (and any future screen) have zero permission or picking logic in them. A thin `AppImagePicker` widget remains as a pure display component.

## Architecture

```
lib/core/helpers/
  permission_helper.dart     ← handles all permission types
  image_picker_helper.dart   ← owns bottom sheet + delegates to PermissionHelper + picks image
```

**Call chain:**
```
AppImagePicker (tap)
  → ImagePickerHelper.pick(context)
      → shows bottom sheet (camera / gallery)
      → PermissionHelper.request(Permission.camera | Permission.photos)
          → returns PermissionStatus
      → if granted  → ImagePicker.pickImage(source) → XFile?
      → if denied   → AppSnackbar.showError, return null
      → if permanently denied → AppSnackbar.showError + openAppSettings(), return null
```

## `PermissionHelper` (`lib/core/helpers/permission_helper.dart`)

Static utility class. Covers all permission types the app may ever need.

**Public API:**

| Method | Signature | Behaviour |
|---|---|---|
| `request` | `Future<PermissionStatus> request(Permission p)` | Requests a single permission. If permanently denied, calls `openAppSettings()` and shows a snackbar. Returns status. |
| `requestMultiple` | `Future<Map<Permission, PermissionStatus>> requestMultiple(List<Permission> permissions)` | Requests several permissions at once. Returns a status map. |
| `isGranted` | `Future<bool> isGranted(Permission p)` | Returns true if already granted/limited. Does NOT trigger a request. |
| `openSettings` | `Future<void> openSettings()` | Thin wrapper around `openAppSettings()`. |

**Status handling:**
- `granted` / `limited` (iOS) → success path
- `denied` → show snackbar "Permission denied"
- `permanentlyDenied` → show snackbar "[Camera/Gallery] access denied. Enable it in Settings." + `openAppSettings()`
- `restricted` → show snackbar "Permission restricted by device policy"

No `BuildContext` required — snackbar calls go through a global messenger key so the helper stays context-free.

> Note: `AppSnackbar` currently requires a `BuildContext`. During implementation, either pass context into `request()` or switch `AppSnackbar` to use a global key. Passing context is simpler and preferred for now.

## `ImagePickerHelper` (`lib/core/helpers/image_picker_helper.dart`)

Static utility class. Owns the bottom sheet and the full pick flow.

**Public API:**

```dart
static Future<XFile?> pick(BuildContext context, {int imageQuality = 80})
```

**Behaviour:**
1. Shows modal bottom sheet with two options: "Take a photo" (camera) and "Choose from gallery" (gallery).
2. Awaits user selection. If dismissed without selection, returns `null`.
3. Calls `PermissionHelper.request(Permission.camera)` or `PermissionHelper.request(Permission.photos)` based on selection.
4. If status is `granted` or `limited`: calls `ImagePicker().pickImage(source: source, imageQuality: imageQuality)` and returns the `XFile?`.
5. Otherwise returns `null` (error messaging is handled inside `PermissionHelper`).

For the selfie screen, camera uses `CameraDevice.front`. This is passed as an optional parameter:

```dart
static Future<XFile?> pick(
  BuildContext context, {
  int imageQuality = 80,
  CameraDevice preferredCameraDevice = CameraDevice.rear,
})
```

## `AppImagePicker` widget (updated)

The widget becomes a pure display component:
- Accepts `imagePath`, `label`, and `onTap: VoidCallback` (replaces `onPickFromCamera` / `onPickFromGallery`).
- The caller passes `onTap: () async { final file = await ImagePickerHelper.pick(context); if (file != null) setState(() => _imagePath = file.path); }`.
- Internally still shows the same preview container and placeholder. The bottom sheet moves to `ImagePickerHelper`.

## KYC Screen Changes

Both `KycDocumentScreen` and `KycSelfieScreen` are simplified:
- Remove `final _picker = ImagePicker()`.
- Remove all `Permission.*` imports and `_pick(ImageSource)` methods.
- Replace `onPickFromCamera` / `onPickFromGallery` with a single `onTap` callback calling `ImagePickerHelper.pick(context)`.
- `KycSelfieScreen` passes `preferredCameraDevice: CameraDevice.front`.

## File Locations

| File | Action |
|---|---|
| `lib/core/helpers/permission_helper.dart` | Create |
| `lib/core/helpers/image_picker_helper.dart` | Create |
| `lib/core/widgets/app_image_picker.dart` | Update — simplify to single `onTap` callback |
| `lib/features/auth/presentation/screens/kyc/kyc_document_screen.dart` | Update — remove permission/picker logic |
| `lib/features/auth/presentation/screens/kyc/kyc_selfie_screen.dart` | Update — remove permission/picker logic |

## Dependencies

No new packages required. Already in `pubspec.yaml`:
- `permission_handler: ^11.4.0`
- `image_picker: ^1.1.2`

Platform manifests already declare all required permissions (camera, photos).
