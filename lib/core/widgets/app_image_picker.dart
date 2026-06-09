import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_dimensions.dart';

class AppImagePicker extends StatelessWidget {
  final String? imagePath;
  final String label;
  final VoidCallback onPickFromCamera;
  final VoidCallback onPickFromGallery;

  const AppImagePicker({
    super.key,
    required this.label,
    required this.onPickFromCamera,
    required this.onPickFromGallery,
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
          onTap: () => _showPickerSheet(context),
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
                    child: Image.network(
                      imagePath!,
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

  void _showPickerSheet(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      builder: (_) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt_outlined),
              title: const Text('Take a photo'),
              onTap: () {
                Navigator.pop(context);
                onPickFromCamera();
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library_outlined),
              title: const Text('Choose from gallery'),
              onTap: () {
                Navigator.pop(context);
                onPickFromGallery();
              },
            ),
          ],
        ),
      ),
    );
  }
}
