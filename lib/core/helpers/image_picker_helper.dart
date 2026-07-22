import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:uuid/uuid.dart';
import 'permission_helper.dart';

class ImagePickerHelper {
  ImagePickerHelper._();

  static final _picker = ImagePicker();

  static const int _maxUploadBytes = 2 * 1024 * 1024;

  /// Converts [path] to JPEG and downsizes it toward 2MB if needed, returning
  /// the path to actually upload. Falls back to the original path if
  /// conversion fails. The compressed file is renamed to a random UUID so the
  /// image_picker's original (often long/identifying) filename never reaches
  /// the backend.
  static Future<String> compressIfNeeded(String path) async {
    final targetDir = await getTemporaryDirectory();
    final tempPath =
        '${targetDir.path}/${DateTime.now().microsecondsSinceEpoch}.jpg';

    try {
      // JPEG is lossy, so quality reduction actually shrinks the file —
      // step quality down first, then dimension, until under the limit.
      var quality = 85;
      var dimension = 1920;
      XFile? converted;
      while (dimension >= 480) {
        final result = await FlutterImageCompress.compressAndGetFile(
          path,
          tempPath,
          minWidth: dimension,
          minHeight: dimension,
          quality: quality,
          format: CompressFormat.jpeg,
        );
        if (result == null) break;
        converted = result;
        if (await File(result.path).length() <= _maxUploadBytes) break;
        if (quality > 40) {
          quality -= 15;
        } else {
          dimension = (dimension * 0.75).round();
        }
      }

      if (converted == null) {
        debugPrint('DEBUG compressIfNeeded: compressAndGetFile returned null');
        return path;
      }

      final renamedPath = '${targetDir.path}/${const Uuid().v4()}.jpg';
      final renamed = await File(converted.path).rename(renamedPath);
      return renamed.path;
    } catch (e, st) {
      debugPrint('DEBUG compressIfNeeded failed: $e\n$st');
      return path;
    }
  }

  static Future<XFile?> pick(
    BuildContext context, {
    int imageQuality = 80,
    CameraDevice preferredCameraDevice = CameraDevice.rear,
  }) async {
    final source = await _showSourceSheet(context);
    if (source == null) return null;

    if (!context.mounted) return null;

    return pickFrom(
      context,
      source,
      imageQuality: imageQuality,
      preferredCameraDevice: preferredCameraDevice,
    );
  }

  /// Picks directly from [source] without showing the camera/gallery chooser
  /// sheet — for callers that already present their own source selection UI.
  static Future<XFile?> pickFrom(
    BuildContext context,
    ImageSource source, {
    int imageQuality = 80,
    CameraDevice preferredCameraDevice = CameraDevice.rear,
  }) async {
    // Camera always needs an explicit permission check on all platforms.
    // Gallery on iOS uses PHPickerViewController (iOS 14+) which handles its own
    // access without requiring a prior permission request — checking Permission.photos
    // here would incorrectly return permanentlyDenied and open Settings instead of
    // showing the picker. On Android, explicit storage permission is still required.
    if (source == ImageSource.camera) {
      final status = await PermissionHelper.request(context, Permission.camera);
      if (!status.isGranted && !status.isLimited) return null;
    } else if (Platform.isAndroid) {
      if (!context.mounted) return null;
      final status = await PermissionHelper.request(context, Permission.photos);
      if (!status.isGranted && !status.isLimited) return null;
    }

    if (!context.mounted) return null;

    return _picker.pickImage(
      source: source,
      imageQuality: imageQuality,
      preferredCameraDevice: preferredCameraDevice,
    );
  }

  static Future<List<XFile>> pickMultiple(
    BuildContext context, {
    int imageQuality = 80,
  }) async {
    if (Platform.isAndroid) {
      // ignore: use_build_context_synchronously
      final status = await PermissionHelper.request(context, Permission.photos);
      if (!status.isGranted && !status.isLimited) return [];
    }
    if (!context.mounted) return [];
    return await _picker.pickMultiImage(imageQuality: imageQuality);
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
