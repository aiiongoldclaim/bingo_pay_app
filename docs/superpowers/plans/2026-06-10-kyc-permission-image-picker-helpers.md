# KYC Permission & Image Picker Helpers Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Extract permission handling and image picking from KYC screens into `PermissionHelper` and `ImagePickerHelper`, and simplify `AppImagePicker` to a pure display widget with a single `onTap` callback.

**Architecture:** `PermissionHelper` (static class) wraps `permission_handler` for all permission types. `ImagePickerHelper` (static class) owns the bottom sheet UI, delegates permission checking to `PermissionHelper`, then picks the image. `AppImagePicker` becomes a dumb display widget — KYC screens call `ImagePickerHelper.pick(context)` and receive `XFile?` with zero permission code in the screens.

**Tech Stack:** Flutter, `permission_handler ^11.4.0`, `image_picker ^1.1.2`, `mocktail ^1.0.4`, `flutter_test`

---

## File Map

| File | Action |
|---|---|
| `lib/core/helpers/permission_helper.dart` | Create |
| `lib/core/helpers/image_picker_helper.dart` | Create |
| `lib/core/widgets/app_image_picker.dart` | Modify |
| `lib/features/auth/presentation/screens/kyc/kyc_document_screen.dart` | Modify |
| `lib/features/auth/presentation/screens/kyc/kyc_selfie_screen.dart` | Modify |
| `test/unit/permission_helper_test.dart` | Create |
| `test/widget/image_picker_helper_test.dart` | Create |
| `test/widget/app_image_picker_test.dart` | Create |

---

### Task 1: PermissionHelper

**Files:**
- Create: `lib/core/helpers/permission_helper.dart`
- Create: `test/unit/permission_helper_test.dart`

- [ ] **Step 1: Write the failing test**

```dart
// test/unit/permission_helper_test.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:bingo_pay/core/helpers/permission_helper.dart';

void _mockPermission(Permission permission, PermissionStatus status) {
  TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
      .setMockMethodCallHandler(
    const MethodChannel('flutter.baseflow.com/permissions/methods'),
    (call) async {
      if (call.method == 'requestPermissions') {
        return <int, int>{permission.value: status.index};
      }
      if (call.method == 'checkPermissionStatus') return status.index;
      if (call.method == 'openAppSettings') return true;
      return null;
    },
  );
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
      const MethodChannel('flutter.baseflow.com/permissions/methods'),
      null,
    );
  });

  group('PermissionHelper.isGranted', () {
    testWidgets('returns true when permission is granted', (tester) async {
      _mockPermission(Permission.camera, PermissionStatus.granted);
      expect(await PermissionHelper.isGranted(Permission.camera), isTrue);
    });

    testWidgets('returns true when permission is limited', (tester) async {
      _mockPermission(Permission.photos, PermissionStatus.limited);
      expect(await PermissionHelper.isGranted(Permission.photos), isTrue);
    });

    testWidgets('returns false when permission is denied', (tester) async {
      _mockPermission(Permission.camera, PermissionStatus.denied);
      expect(await PermissionHelper.isGranted(Permission.camera), isFalse);
    });
  });

  group('PermissionHelper.request', () {
    testWidgets('returns granted status when granted', (tester) async {
      _mockPermission(Permission.camera, PermissionStatus.granted);
      late PermissionStatus result;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (ctx) => ElevatedButton(
                onPressed: () async {
                  result =
                      await PermissionHelper.request(ctx, Permission.camera);
                },
                child: const Text('Go'),
              ),
            ),
          ),
        ),
      );
      await tester.tap(find.text('Go'));
      await tester.pump();
      expect(result, PermissionStatus.granted);
    });

    testWidgets('shows camera snackbar when permanently denied', (tester) async {
      _mockPermission(Permission.camera, PermissionStatus.permanentlyDenied);
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (ctx) => ElevatedButton(
                onPressed: () => PermissionHelper.request(ctx, Permission.camera),
                child: const Text('Go'),
              ),
            ),
          ),
        ),
      );
      await tester.tap(find.text('Go'));
      await tester.pump();
      expect(
        find.text('Camera access denied. Enable it in Settings.'),
        findsOneWidget,
      );
    });

    testWidgets('shows gallery snackbar when photos permanently denied',
        (tester) async {
      _mockPermission(Permission.photos, PermissionStatus.permanentlyDenied);
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (ctx) => ElevatedButton(
                onPressed: () => PermissionHelper.request(ctx, Permission.photos),
                child: const Text('Go'),
              ),
            ),
          ),
        ),
      );
      await tester.tap(find.text('Go'));
      await tester.pump();
      expect(
        find.text('Gallery access denied. Enable it in Settings.'),
        findsOneWidget,
      );
    });

    testWidgets('shows denied snackbar when camera denied', (tester) async {
      _mockPermission(Permission.camera, PermissionStatus.denied);
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (ctx) => ElevatedButton(
                onPressed: () => PermissionHelper.request(ctx, Permission.camera),
                child: const Text('Go'),
              ),
            ),
          ),
        ),
      );
      await tester.tap(find.text('Go'));
      await tester.pump();
      expect(find.text('Camera permission denied.'), findsOneWidget);
    });
  });
}
```

- [ ] **Step 2: Run test to verify it fails**

```
flutter test test/unit/permission_helper_test.dart
```
Expected: FAIL — `Target of URI doesn't exist: 'package:bingo_pay/core/helpers/permission_helper.dart'`

- [ ] **Step 3: Create `lib/core/helpers/permission_helper.dart`**

```dart
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import '../widgets/app_snackbar.dart';

class PermissionHelper {
  PermissionHelper._();

  static Future<PermissionStatus> request(
    BuildContext context,
    Permission permission,
  ) async {
    final status = await permission.request();
    if (!context.mounted) return status;
    switch (status) {
      case PermissionStatus.permanentlyDenied:
        AppSnackbar.showError(context, _permanentlyDeniedMessage(permission));
        await openAppSettings();
      case PermissionStatus.denied:
        AppSnackbar.showError(context, _deniedMessage(permission));
      case PermissionStatus.restricted:
        AppSnackbar.showError(context, 'Permission restricted by device policy.');
      default:
        break;
    }
    return status;
  }

  static Future<Map<Permission, PermissionStatus>> requestMultiple(
    BuildContext context,
    List<Permission> permissions,
  ) async {
    final statuses = await permissions.request();
    if (!context.mounted) return statuses;
    for (final entry in statuses.entries) {
      if (entry.value.isPermanentlyDenied) {
        AppSnackbar.showError(context, _permanentlyDeniedMessage(entry.key));
        await openAppSettings();
        break;
      } else if (entry.value.isDenied) {
        AppSnackbar.showError(context, _deniedMessage(entry.key));
      }
    }
    return statuses;
  }

  static Future<bool> isGranted(Permission permission) async {
    final status = await permission.status;
    return status.isGranted || status.isLimited;
  }

  static Future<void> openSettings() => openAppSettings();

  static String _permanentlyDeniedMessage(Permission permission) {
    if (permission == Permission.camera) {
      return 'Camera access denied. Enable it in Settings.';
    }
    if (permission == Permission.photos ||
        permission == Permission.storage ||
        permission == Permission.mediaLibrary) {
      return 'Gallery access denied. Enable it in Settings.';
    }
    return 'Permission denied. Enable it in Settings.';
  }

  static String _deniedMessage(Permission permission) {
    if (permission == Permission.camera) return 'Camera permission denied.';
    if (permission == Permission.photos ||
        permission == Permission.storage ||
        permission == Permission.mediaLibrary) {
      return 'Gallery permission denied.';
    }
    return 'Permission denied.';
  }
}
```

- [ ] **Step 4: Run test to verify it passes**

```
flutter test test/unit/permission_helper_test.dart
```
Expected: All tests PASS

- [ ] **Step 5: Commit**

```bash
git add lib/core/helpers/permission_helper.dart test/unit/permission_helper_test.dart
git commit -m "feat(helpers): add PermissionHelper for app-wide permission handling"
```

---

### Task 2: ImagePickerHelper

**Files:**
- Create: `lib/core/helpers/image_picker_helper.dart`
- Create: `test/widget/image_picker_helper_test.dart`

- [ ] **Step 1: Write the failing test**

```dart
// test/widget/image_picker_helper_test.dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:bingo_pay/core/helpers/image_picker_helper.dart';

void main() {
  group('ImagePickerHelper.pick', () {
    testWidgets('shows bottom sheet with camera and gallery options',
        (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (ctx) => ElevatedButton(
                onPressed: () => ImagePickerHelper.pick(ctx),
                child: const Text('Pick'),
              ),
            ),
          ),
        ),
      );
      await tester.tap(find.text('Pick'));
      await tester.pumpAndSettle();
      expect(find.text('Take a photo'), findsOneWidget);
      expect(find.text('Choose from gallery'), findsOneWidget);
    });

    testWidgets('returns null when bottom sheet is dismissed', (tester) async {
      XFile? result = XFile('placeholder');
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (ctx) => ElevatedButton(
                onPressed: () async {
                  result = await ImagePickerHelper.pick(ctx);
                },
                child: const Text('Pick'),
              ),
            ),
          ),
        ),
      );
      await tester.tap(find.text('Pick'));
      await tester.pumpAndSettle();
      await tester.tapAt(const Offset(10, 10));
      await tester.pumpAndSettle();
      expect(result, isNull);
    });
  });
}
```

- [ ] **Step 2: Run test to verify it fails**

```
flutter test test/widget/image_picker_helper_test.dart
```
Expected: FAIL — `Target of URI doesn't exist: 'package:bingo_pay/core/helpers/image_picker_helper.dart'`

- [ ] **Step 3: Create `lib/core/helpers/image_picker_helper.dart`**

```dart
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'permission_helper.dart';

class ImagePickerHelper {
  ImagePickerHelper._();

  static final _picker = ImagePicker();

  static Future<XFile?> pick(
    BuildContext context, {
    int imageQuality = 80,
    CameraDevice preferredCameraDevice = CameraDevice.rear,
  }) async {
    final source = await _showSourceSheet(context);
    if (source == null) return null;

    final permission =
        source == ImageSource.camera ? Permission.camera : Permission.photos;

    final status = await PermissionHelper.request(context, permission);
    if (!status.isGranted && !status.isLimited) return null;

    return _picker.pickImage(
      source: source,
      imageQuality: imageQuality,
      preferredCameraDevice: preferredCameraDevice,
    );
  }

  static Future<ImageSource?> _showSourceSheet(BuildContext context) {
    return showModalBottomSheet<ImageSource>(
      context: context,
      builder: (_) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt_outlined),
              title: const Text('Take a photo'),
              onTap: () => Navigator.pop(context, ImageSource.camera),
            ),
            ListTile(
              leading: const Icon(Icons.photo_library_outlined),
              title: const Text('Choose from gallery'),
              onTap: () => Navigator.pop(context, ImageSource.gallery),
            ),
          ],
        ),
      ),
    );
  }
}
```

- [ ] **Step 4: Run test to verify it passes**

```
flutter test test/widget/image_picker_helper_test.dart
```
Expected: All tests PASS

- [ ] **Step 5: Commit**

```bash
git add lib/core/helpers/image_picker_helper.dart test/widget/image_picker_helper_test.dart
git commit -m "feat(helpers): add ImagePickerHelper with bottom sheet and permission delegation"
```

---

### Task 3: Update AppImagePicker

**Files:**
- Modify: `lib/core/widgets/app_image_picker.dart`
- Create: `test/widget/app_image_picker_test.dart`

- [ ] **Step 1: Write the failing test**

```dart
// test/widget/app_image_picker_test.dart
import 'package:bingo_pay/core/widgets/app_image_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

Widget buildSubject({String? imagePath, required VoidCallback onTap}) =>
    MaterialApp(
      home: Scaffold(
        body: AppImagePicker(
          label: 'Test Label',
          onTap: onTap,
          imagePath: imagePath,
        ),
      ),
    );

void main() {
  group('AppImagePicker', () {
    testWidgets('shows label', (tester) async {
      await tester.pumpWidget(buildSubject(onTap: () {}));
      expect(find.text('Test Label'), findsOneWidget);
    });

    testWidgets('shows placeholder when no image', (tester) async {
      await tester.pumpWidget(buildSubject(onTap: () {}));
      expect(find.text('Tap to upload'), findsOneWidget);
    });

    testWidgets('calls onTap when tapped', (tester) async {
      var tapped = false;
      await tester.pumpWidget(buildSubject(onTap: () => tapped = true));
      await tester.tap(find.byType(GestureDetector));
      expect(tapped, isTrue);
    });
  });
}
```

- [ ] **Step 2: Run test to verify it fails**

```
flutter test test/widget/app_image_picker_test.dart
```
Expected: FAIL — `The named parameter 'onTap' isn't defined`

- [ ] **Step 3: Replace `lib/core/widgets/app_image_picker.dart`**

```dart
import 'dart:io';
import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_dimensions.dart';

class AppImagePicker extends StatelessWidget {
  final String? imagePath;
  final String label;
  final VoidCallback onTap;

  const AppImagePicker({
    super.key,
    required this.label,
    required this.onTap,
    this.imagePath,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: Theme.of(context).textTheme.labelLarge),
        const SizedBox(height: AppDimensions.sm),
        GestureDetector(
          onTap: onTap,
          child: Container(
            height: 160,
            width: double.infinity,
            decoration: BoxDecoration(
              color: AppColors.backgroundLight,
              borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
              border: Border.all(color: AppColors.divider),
            ),
            child: imagePath != null
                ? ClipRRect(
                    borderRadius:
                        BorderRadius.circular(AppDimensions.radiusMd),
                    child: Image.file(
                      File(imagePath!),
                      fit: BoxFit.cover,
                      errorBuilder: (_, _, _) => _placeholder(),
                    ),
                  )
                : _placeholder(),
          ),
        ),
      ],
    );
  }

  Widget _placeholder() {
    return const Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.add_a_photo_outlined, size: 40, color: AppColors.textSecondary),
        SizedBox(height: 8),
        Text('Tap to upload', style: TextStyle(color: AppColors.textSecondary)),
      ],
    );
  }
}
```

- [ ] **Step 4: Run tests and analysis**

```
flutter test test/widget/app_image_picker_test.dart && flutter analyze lib/core/widgets/app_image_picker.dart
```
Expected: All tests PASS, `No issues found!`

- [ ] **Step 5: Commit**

```bash
git add lib/core/widgets/app_image_picker.dart test/widget/app_image_picker_test.dart
git commit -m "refactor(widgets): simplify AppImagePicker to single onTap callback"
```

---

### Task 4: Update KycDocumentScreen

**Files:**
- Modify: `lib/features/auth/presentation/screens/kyc/kyc_document_screen.dart`

- [ ] **Step 1: Replace the full file**

```dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../../core/helpers/image_picker_helper.dart';
import '../../../../../core/router/app_routes.dart';
import '../../../../../core/widgets/app_button.dart';
import '../../../../../core/widgets/app_image_picker.dart';
import '../../../../../core/widgets/app_snackbar.dart';
import '../../bloc/auth_bloc.dart';
import '../../bloc/auth_event.dart';
import '../../bloc/auth_state.dart';
import '../../widgets/kyc_step_indicator.dart';

class KycDocumentScreen extends StatefulWidget {
  const KycDocumentScreen({super.key});

  @override
  State<KycDocumentScreen> createState() => _KycDocumentScreenState();
}

class _KycDocumentScreenState extends State<KycDocumentScreen> {
  String? _imagePath;
  String _documentType = 'passport';

  static const _documentTypes = [
    ('passport', 'Passport'),
    ('national_id', 'National ID'),
    ('drivers_license', "Driver's License"),
  ];

  void _submit() {
    if (_imagePath == null) {
      AppSnackbar.showError(context, 'Please upload your document');
      return;
    }
    context.read<AuthBloc>().add(
          KycDocumentUploaded(
            filePath: _imagePath!,
            documentType: _documentType,
          ),
        );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Identity Verification')),
      body: BlocListener<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is AuthError) {
            AppSnackbar.showError(context, state.failure.message);
          }
          if (state is KycStepCompleted && state.step == 1) {
            context.push(AppRoutes.kycSelfie);
          }
        },
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const KycStepIndicator(currentStep: 1),
              const SizedBox(height: 8),
              const Text('Step 2 of 3: Document Upload'),
              const SizedBox(height: 24),
              const Text('Document Type'),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: _documentTypes
                    .map(
                      (type) => ChoiceChip(
                        label: Text(type.$2),
                        selected: _documentType == type.$1,
                        onSelected: (_) =>
                            setState(() => _documentType = type.$1),
                      ),
                    )
                    .toList(),
              ),
              const SizedBox(height: 24),
              AppImagePicker(
                label: 'Upload Document',
                imagePath: _imagePath,
                onTap: () async {
                  final file = await ImagePickerHelper.pick(context);
                  if (file != null && mounted) {
                    setState(() => _imagePath = file.path);
                  }
                },
              ),
              const Spacer(),
              BlocBuilder<AuthBloc, AuthState>(
                builder: (context, state) => AppButton(
                  label: 'Continue',
                  onPressed: _submit,
                  isLoading: state is KycLoading,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
```

- [ ] **Step 2: Verify no analysis errors**

```
flutter analyze lib/features/auth/presentation/screens/kyc/kyc_document_screen.dart
```
Expected: `No issues found!`

- [ ] **Step 3: Commit**

```bash
git add lib/features/auth/presentation/screens/kyc/kyc_document_screen.dart
git commit -m "refactor(kyc): delegate image picking to ImagePickerHelper in KycDocumentScreen"
```

---

### Task 5: Update KycSelfieScreen

**Files:**
- Modify: `lib/features/auth/presentation/screens/kyc/kyc_selfie_screen.dart`

- [ ] **Step 1: Replace the full file**

```dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../../core/helpers/image_picker_helper.dart';
import '../../../../../core/widgets/app_button.dart';
import '../../../../../core/widgets/app_image_picker.dart';
import '../../../../../core/widgets/app_snackbar.dart';
import '../../bloc/auth_bloc.dart';
import '../../bloc/auth_event.dart';
import '../../bloc/auth_state.dart';
import '../../widgets/kyc_step_indicator.dart';

class KycSelfieScreen extends StatefulWidget {
  const KycSelfieScreen({super.key});

  @override
  State<KycSelfieScreen> createState() => _KycSelfieScreenState();
}

class _KycSelfieScreenState extends State<KycSelfieScreen> {
  String? _imagePath;

  void _submit() {
    if (_imagePath == null) {
      AppSnackbar.showError(context, 'Please take a selfie');
      return;
    }
    context.read<AuthBloc>().add(KycSelfieUploaded(filePath: _imagePath!));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Identity Verification')),
      body: BlocListener<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is AuthError) {
            AppSnackbar.showError(context, state.failure.message);
          }
        },
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const KycStepIndicator(currentStep: 2),
              const SizedBox(height: 8),
              const Text('Step 3 of 3: Take a Selfie'),
              const SizedBox(height: 24),
              Text(
                'Please take a clear selfie holding your document.',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 24),
              AppImagePicker(
                label: 'Selfie',
                imagePath: _imagePath,
                onTap: () async {
                  final file = await ImagePickerHelper.pick(
                    context,
                    preferredCameraDevice: CameraDevice.front,
                  );
                  if (file != null && mounted) {
                    setState(() => _imagePath = file.path);
                  }
                },
              ),
              const Spacer(),
              BlocBuilder<AuthBloc, AuthState>(
                builder: (context, state) {
                  if (state is KycSubmitted) {
                    return const _UnderReviewBanner();
                  }
                  return AppButton(
                    label: 'Submit',
                    onPressed: _submit,
                    isLoading: state is KycLoading,
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _UnderReviewBanner extends StatelessWidget {
  const _UnderReviewBanner();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Icon(Icons.hourglass_top, size: 48),
        const SizedBox(height: 8),
        Text(
          'KYC Under Review',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 4),
        const Text('We will notify you once your identity is verified.'),
      ],
    );
  }
}
```

- [ ] **Step 2: Verify no analysis errors**

```
flutter analyze lib/features/auth/presentation/screens/kyc/kyc_selfie_screen.dart
```
Expected: `No issues found!`

- [ ] **Step 3: Run the full test suite**

```
flutter test
```
Expected: All tests PASS

- [ ] **Step 4: Commit**

```bash
git add lib/features/auth/presentation/screens/kyc/kyc_selfie_screen.dart
git commit -m "refactor(kyc): delegate image picking to ImagePickerHelper in KycSelfieScreen"
```
