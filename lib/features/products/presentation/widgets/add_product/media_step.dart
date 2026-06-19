import 'dart:io';

import 'package:flutter/material.dart';

import '../../../../../core/helpers/image_picker_helper.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_dimensions.dart';
import '../../models/product_form_data.dart';

const int kMaxProductImages = 8;

class MediaStep extends StatelessWidget {
  final GlobalKey<FormState> formKey;
  final TextEditingController videoLinkController;
  final ProductDraft draft;
  final VoidCallback onDraftChanged;

  const MediaStep({
    super.key,
    required this.formKey,
    required this.videoLinkController,
    required this.draft,
    required this.onDraftChanged,
  });

  Future<void> _addImage(BuildContext context) async {
    final picked = await ImagePickerHelper.pick(context);
    if (picked != null) {
      draft.imagePaths.add(picked.path);
      onDraftChanged();
    }
  }

  Future<void> _confirmDelete(BuildContext context, int index) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Remove image?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Remove')),
        ],
      ),
    );
    if (confirmed == true) {
      draft.imagePaths.removeAt(index);
      onDraftChanged();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          FormField<List<String>>(
            initialValue: draft.imagePaths,
            validator: (v) => (v == null || v.isEmpty) ? 'At least 1 product image is required' : null,
            builder: (state) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text.rich(
                    TextSpan(
                      style: const TextStyle(fontSize: 14, color: Colors.black87),
                      children: [
                        const TextSpan(text: 'Product images'),
                        const TextSpan(text: ' *', style: TextStyle(color: AppColors.error)),
                        const TextSpan(text: ' (max $kMaxProductImages)', style: TextStyle(color: Colors.grey)),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppDimensions.sm),
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                      crossAxisSpacing: AppDimensions.sm,
                      mainAxisSpacing: AppDimensions.sm,
                    ),
                    itemCount: draft.imagePaths.length < kMaxProductImages
                        ? draft.imagePaths.length + 1
                        : draft.imagePaths.length,
                    itemBuilder: (context, index) {
                      if (index == draft.imagePaths.length) {
                        return _AddImageSlot(onTap: () => _addImage(context));
                      }
                      return _ImageSlot(
                        path: draft.imagePaths[index],
                        isPrimary: index == 0,
                        onLongPress: () => _confirmDelete(context, index),
                      );
                    },
                  ),
                  if (state.hasError) ...[
                    const SizedBox(height: 4),
                    Text(state.errorText!, style: const TextStyle(fontSize: 12, color: AppColors.error)),
                  ],
                  const SizedBox(height: 8),
                  Text(
                    '${draft.imagePaths.length} of $kMaxProductImages added · long-press to delete',
                    style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                  ),
                ],
              );
            },
          ),
          const SizedBox(height: AppDimensions.lg),
          const Text('Product video (optional)', style: TextStyle(fontSize: 14, color: Colors.black87)),
          const SizedBox(height: AppDimensions.sm),
          TextFormField(
            controller: videoLinkController,
            decoration: const InputDecoration(hintText: 'YouTube/Vimeo link'),
          ),
        ],
      ),
    );
  }
}

class _ImageSlot extends StatelessWidget {
  final String path;
  final bool isPrimary;
  final VoidCallback onLongPress;

  const _ImageSlot({required this.path, required this.isPrimary, required this.onLongPress});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onLongPress: onLongPress,
      child: Stack(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
            child: Image.file(
              File(path),
              width: double.infinity,
              height: double.infinity,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => Container(color: AppColors.infoTint),
            ),
          ),
          if (isPrimary)
            Positioned(
              left: 6,
              bottom: 6,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(AppDimensions.radiusCircular),
                ),
                child: const Text('Primary', style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w600)),
              ),
            ),
        ],
      ),
    );
  }
}

class _AddImageSlot extends StatelessWidget {
  final VoidCallback onTap;

  const _AddImageSlot({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
          border: Border.all(color: Colors.grey[400]!, style: BorderStyle.solid),
        ),
        child: Icon(Icons.add_photo_alternate_outlined, color: Colors.grey[500]),
      ),
    );
  }
}
