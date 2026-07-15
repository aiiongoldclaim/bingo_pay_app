import 'dart:io';
import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_dimensions.dart';

class AppImagePicker extends StatelessWidget {
  final String? imagePath;
  final String label;
  final VoidCallback onTap;
  final bool isPdf;
  final String? fileName;

  const AppImagePicker({
    super.key,
    required this.label,
    required this.onTap,
    this.imagePath,
    this.isPdf = false,
    this.fileName,
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
              color: context.colors.inputFill,
              borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
              border: Border.all(color: context.colors.border),
            ),
            child: imagePath == null
                ? _placeholder(context)
                : isPdf
                    ? _pdfPreview(context)
                    : ClipRRect(
                        borderRadius:
                            BorderRadius.circular(AppDimensions.radiusMd),
                        child: Image.file(
                          File(imagePath!),
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) =>
                              _placeholder(context),
                        ),
                      ),
          ),
        ),
      ],
    );
  }

  Widget _placeholder(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.add_a_photo_outlined, size: 40, color: context.colors.textSecondary),
        const SizedBox(height: 8),
        Text('Tap to upload', style: TextStyle(color: context.colors.textSecondary)),
      ],
    );
  }

  Widget _pdfPreview(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.picture_as_pdf_outlined, size: 40, color: context.colors.textSecondary),
          const SizedBox(height: 8),
          Text(
            fileName ?? 'PDF document',
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(color: context.colors.textSecondary),
          ),
        ],
      ),
    );
  }
}
