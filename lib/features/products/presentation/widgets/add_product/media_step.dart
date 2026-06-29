import 'dart:io';

import 'package:flutter/material.dart';

import '../../../../../core/helpers/image_picker_helper.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_dimensions.dart';
import '../../models/product_form_data.dart';

const int kMaxProductImages = 8;

class MediaStep extends StatefulWidget {
  final GlobalKey<FormState> formKey;
  final TextEditingController videoLinkController;
  final ProductDraft draft;
  final VoidCallback onDraftChanged;
  // Returns (url, id) on success, null on failure/add-mode.
  final Future<({String url, String id})?> Function(String imagePath)? onFirstImageAdded;
  // Returns list of (url, id) on success; empty on failure/add-mode.
  final Future<List<({String url, String id})>> Function(List<String> imagePaths)? onGalleryImagesAdded;
  // Called when user confirms deletion of an uploaded image.
  final Future<void> Function(String mediaId)? onImageDeleted;

  const MediaStep({
    super.key,
    required this.formKey,
    required this.videoLinkController,
    required this.draft,
    required this.onDraftChanged,
    this.onFirstImageAdded,
    this.onGalleryImagesAdded,
    this.onImageDeleted,
  });

  @override
  State<MediaStep> createState() => _MediaStepState();
}

class _MediaStepState extends State<MediaStep> {
  bool _isUploadingThumbnail = false;
  bool _isUploadingGallery = false;

  Future<void> _addImage(BuildContext context) async {
    final isFirst = widget.draft.imagePaths.isEmpty;

    if (isFirst) {
      final picked = await ImagePickerHelper.pick(context);
      if (picked == null) return;

      if (widget.onFirstImageAdded != null) {
        setState(() => _isUploadingThumbnail = true);
        final result = await widget.onFirstImageAdded!(picked.path);
        setState(() => _isUploadingThumbnail = false);
        if (result != null) {
          widget.draft.imagePaths.add(result.url);
          widget.draft.imageMediaIds[result.url] = result.id;
          widget.onDraftChanged();
        }
      } else {
        widget.draft.imagePaths.add(picked.path);
        widget.onDraftChanged();
      }
    } else {
      final remaining = kMaxProductImages - widget.draft.imagePaths.length;
      if (remaining <= 0) return;

      final picked = await ImagePickerHelper.pickMultiple(context);
      if (picked.isEmpty) return;

      final limited = picked.take(remaining).toList();
      final paths = limited.map((f) => f.path).toList();

      if (widget.onGalleryImagesAdded != null) {
        setState(() => _isUploadingGallery = true);
        final results = await widget.onGalleryImagesAdded!(paths);
        setState(() => _isUploadingGallery = false);
        if (results.isNotEmpty) {
          for (final r in results) {
            widget.draft.imagePaths.add(r.url);
            widget.draft.imageMediaIds[r.url] = r.id;
          }
          widget.onDraftChanged();
        }
      } else {
        widget.draft.imagePaths.addAll(paths);
        widget.onDraftChanged();
      }
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
    if (confirmed != true) return;

    final path = widget.draft.imagePaths[index];
    final mediaId = widget.draft.imageMediaIds[path];

    if (mediaId != null && widget.onImageDeleted != null) {
      try {
        await widget.onImageDeleted!(mediaId);
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to delete image: $e')),
          );
        }
        return;
      }
      widget.draft.imageMediaIds.remove(path);
    }

    widget.draft.imagePaths.removeAt(index);
    widget.onDraftChanged();
  }

  @override
  Widget build(BuildContext context) {
    final draft = widget.draft;
    final isUploading = _isUploadingThumbnail || _isUploadingGallery;
    final showAddSlot = !isUploading && draft.imagePaths.length < kMaxProductImages;
    final itemCount = isUploading
        ? draft.imagePaths.length + 1 // +1 for the loading slot
        : showAddSlot
            ? draft.imagePaths.length + 1 // +1 for the add slot
            : draft.imagePaths.length;

    return Form(
      key: widget.formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          FormField<List<String>>(
            initialValue: draft.imagePaths,
            validator: (v) =>
                (v == null || v.isEmpty) && !_isUploadingThumbnail
                    ? 'At least 1 product image is required'
                    : null,
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
                        const TextSpan(
                          text: ' (max $kMaxProductImages)',
                          style: TextStyle(color: Colors.grey),
                        ),
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
                    itemCount: itemCount,
                    itemBuilder: (context, index) {
                      // Loading slot for upload in progress
                      if (isUploading && index == draft.imagePaths.length) {
                        return _LoadingSlot(
                          label: _isUploadingGallery ? 'Uploading…' : 'Uploading…',
                        );
                      }
                      // Add slot
                      if (!isUploading && index == draft.imagePaths.length) {
                        return _AddImageSlot(
                          onTap: isUploading ? null : () => _addImage(context),
                        );
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
                    Text(
                      state.errorText!,
                      style: const TextStyle(fontSize: 12, color: AppColors.error),
                    ),
                  ],
                  const SizedBox(height: 8),
                  Text(
                    '${draft.imagePaths.length} of $kMaxProductImages added · tap to add more · long-press to delete',
                    style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                  ),
                ],
              );
            },
          ),
          const SizedBox(height: AppDimensions.lg),
          const Text(
            'Product video (optional)',
            style: TextStyle(fontSize: 14, color: Colors.black87),
          ),
          const SizedBox(height: AppDimensions.sm),
          TextFormField(
            controller: widget.videoLinkController,
            decoration: const InputDecoration(hintText: 'YouTube/Vimeo link'),
          ),
        ],
      ),
    );
  }
}

class _LoadingSlot extends StatelessWidget {
  final String label;

  const _LoadingSlot({this.label = 'Uploading…'});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
      ),
      child: Stack(
        children: [
          const Center(
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
          Positioned(
            left: 6,
            bottom: 6,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(AppDimensions.radiusCircular),
              ),
              child: Text(
                label,
                style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w600),
              ),
            ),
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

  bool get _isUrl => path.startsWith('http://') || path.startsWith('https://');

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onLongPress: onLongPress,
      child: Stack(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
            child: _isUrl
                ? Image.network(
                    path,
                    width: double.infinity,
                    height: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (ctx, e, _) => Container(color: AppColors.infoTint),
                  )
                : Image.file(
                    File(path),
                    width: double.infinity,
                    height: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (ctx, e, _) => Container(color: AppColors.infoTint),
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
                child: const Text(
                  'Primary',
                  style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w600),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _AddImageSlot extends StatelessWidget {
  final VoidCallback? onTap;

  const _AddImageSlot({this.onTap});

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
