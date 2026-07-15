import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../core/di/injection.dart';
import '../../../../core/helpers/image_picker_helper.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/upload_service.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_image_picker.dart';
import '../../../../core/widgets/app_snackbar.dart';

enum KycDocumentType {
  gstCertificate('GST_CERTIFICATE', 'GST Certificate', Icons.receipt_long_outlined),
  panCard('PAN_CARD', 'PAN Card', Icons.badge_outlined);

  final String value;
  final String label;
  final IconData icon;
  const KycDocumentType(this.value, this.label, this.icon);
}

class KycDocumentUploadResult {
  final KycDocumentType documentType;
  final String fileName;
  final bool isPdf;
  final String documentUrl;
  final String publicId;

  const KycDocumentUploadResult({
    required this.documentType,
    required this.fileName,
    required this.isPdf,
    required this.documentUrl,
    required this.publicId,
  });
}

const _maxFileSizeBytes = 5 * 1024 * 1024; // 5 MB

/// Opens a bottom sheet to pick a document type and an image/PDF file,
/// uploads it, and returns the uploaded document's details.
/// [excludedTypes] hides document types that are already uploaded.
Future<KycDocumentUploadResult?> showKycDocumentUploadSheet(
  BuildContext context, {
  Set<KycDocumentType> excludedTypes = const {},
}) {
  return showModalBottomSheet<KycDocumentUploadResult>(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    isDismissible: false,
    enableDrag: false,
    builder: (context) =>
        _KycDocumentUploadSheetContent(excludedTypes: excludedTypes),
  );
}

class _KycDocumentUploadSheetContent extends StatefulWidget {
  final Set<KycDocumentType> excludedTypes;

  const _KycDocumentUploadSheetContent({this.excludedTypes = const {}});

  @override
  State<_KycDocumentUploadSheetContent> createState() =>
      _KycDocumentUploadSheetContentState();
}

class _KycDocumentUploadSheetContentState
    extends State<_KycDocumentUploadSheetContent> {
  late final List<KycDocumentType> _availableTypes = KycDocumentType.values
      .where((t) => !widget.excludedTypes.contains(t))
      .toList();
  late KycDocumentType _documentType = _availableTypes.isNotEmpty
      ? _availableTypes.first
      : KycDocumentType.values.first;
  String? _filePath;
  String? _fileName;
  bool _isPdf = false;
  bool _isUploading = false;

  /// Returns false (with an error snackbar) when the file exceeds 5 MB.
  Future<bool> _checkFileSize(String path) async {
    final size = await File(path).length();
    if (size > _maxFileSizeBytes) {
      if (mounted) {
        AppSnackbar.showError(context, 'File is too large. Maximum size is 5 MB.');
      }
      return false;
    }
    return true;
  }

  Future<void> _pickFile() async {
    final source = await showModalBottomSheet<_FileSource>(
      context: context,
      showDragHandle: true,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt_outlined),
              title: const Text('Take a photo'),
              onTap: () => Navigator.pop(context, _FileSource.camera),
            ),
            ListTile(
              leading: const Icon(Icons.photo_library_outlined),
              title: const Text('Choose from gallery'),
              onTap: () => Navigator.pop(context, _FileSource.gallery),
            ),
            ListTile(
              leading: const Icon(Icons.picture_as_pdf_outlined),
              title: const Text('Choose a PDF file'),
              onTap: () => Navigator.pop(context, _FileSource.pdf),
            ),
          ],
        ),
      ),
    );
    if (source == null || !mounted) return;

    if (source == _FileSource.pdf) {
      final result = await FilePicker.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf'],
      );
      final file = result?.files.single;
      if (file?.path == null) return;
      if (!await _checkFileSize(file!.path!)) return;
      if (!mounted) return;
      setState(() {
        _filePath = file.path;
        _fileName = file.name;
        _isPdf = true;
      });
      return;
    }

    final imageSource =
        source == _FileSource.camera ? ImageSource.camera : ImageSource.gallery;
    final file = await ImagePickerHelper.pickFrom(context, imageSource);
    if (file == null || !mounted) return;
    if (!await _checkFileSize(file.path)) return;
    if (!mounted) return;
    setState(() {
      _filePath = file.path;
      _fileName = file.name;
      _isPdf = false;
    });
  }

  Future<void> _upload() async {
    final filePath = _filePath;
    final fileName = _fileName;
    if (filePath == null || fileName == null) return;

    setState(() => _isUploading = true);
    try {
      final result = await getIt<UploadService>().uploadFile(
        filePath,
        UploadFolder.kycDocument,
      );
      if (!mounted) return;
      Navigator.pop(
        context,
        KycDocumentUploadResult(
          documentType: _documentType,
          fileName: fileName,
          isPdf: _isPdf,
          documentUrl: result.url,
          publicId: result.publicId,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      setState(() => _isUploading = false);
      AppSnackbar.showError(context, 'Failed to upload document');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: 24,
        right: 24,
        bottom: 24 + MediaQuery.of(context).viewInsets.bottom,
      ),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Upload Document',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close_rounded),
                  tooltip: 'Close',
                  visualDensity: VisualDensity.compact,
                  onPressed: _isUploading ? null : () => Navigator.pop(context),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text.rich(
              TextSpan(
                text: 'Document Type',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Theme.of(context).textTheme.bodyMedium?.color,
                ),
                children: [
                  TextSpan(
                    text: ' *',
                    style: TextStyle(color: Theme.of(context).colorScheme.error),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 6),
            DropdownButtonFormField<KycDocumentType>(
              initialValue: _documentType,
              isExpanded: true,
              icon: const Icon(Icons.keyboard_arrow_down_rounded),
              borderRadius: BorderRadius.circular(12),
              decoration: const InputDecoration(
                hintText: 'Select document type',
              ),
              items: _availableTypes
                  .map((type) => DropdownMenuItem(
                        value: type,
                        child: Row(
                          children: [
                            Icon(type.icon, size: 20, color: AppColors.primary),
                            const SizedBox(width: 10),
                            Text(
                              type.label,
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ))
                  .toList(),
              onChanged: _isUploading
                  ? null
                  : (value) {
                      if (value != null) setState(() => _documentType = value);
                    },
            ),
            const SizedBox(height: 20),
            AppImagePicker(
              label: 'Document File',
              imagePath: _filePath,
              isPdf: _isPdf,
              fileName: _fileName,
              onTap: _isUploading ? () {} : _pickFile,
            ),
            const SizedBox(height: 8),
            Text(
              'JPG, PNG or PDF · max 5 MB',
              style: Theme.of(context)
                  .textTheme
                  .bodySmall
                  ?.copyWith(color: context.colors.textSecondary),
            ),
            const SizedBox(height: 24),
            AppButton(
              label: 'Upload',
              isLoading: _isUploading,
              onPressed: _filePath == null ? null : _upload,
            ),
          ],
        ),
      ),
    );
  }
}

enum _FileSource { camera, gallery, pdf }
