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
