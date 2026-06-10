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
