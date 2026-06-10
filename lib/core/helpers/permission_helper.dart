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
