import 'dart:io';

import 'package:flutter/material.dart';

import '../../../../core/helpers/image_picker_helper.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/theme/app_theme_colors.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../setting/features/widgets/settings_metrics.dart';
import 'vendor_application_widgets.dart';

/// Identity documents accepted for vendor verification.
const List<(String, String)> vendorDocumentTypes = [
  ('AADHAAR', 'Aadhaar Card'),
  ('PAN', 'PAN Card'),
  ('PASSPORT', 'Passport'),
  ('DRIVING_LICENCE', 'Driving Licence'),
  ('VOTER_ID', 'Voter ID'),
];

String vendorDocumentLabel(String type) => vendorDocumentTypes
    .firstWhere((t) => t.$1 == type, orElse: () => (type, type))
    .$2;

class VendorDocument {
  final String type;
  final String filePath;

  const VendorDocument({required this.type, required this.filePath});

  String get label => vendorDocumentLabel(type);
}

class IdentityStep extends StatefulWidget {
  final SettingsMetrics metrics;
  final List<VendorDocument> documents;

  /// Adding a type that already exists replaces it.
  final ValueChanged<VendorDocument> onDocumentAdded;
  final ValueChanged<VendorDocument> onDocumentRemoved;

  const IdentityStep({
    super.key,
    required this.metrics,
    required this.documents,
    required this.onDocumentAdded,
    required this.onDocumentRemoved,
  });

  @override
  State<IdentityStep> createState() => _IdentityStepState();
}

class _IdentityStepState extends State<IdentityStep> {
  String? _selectedType;
  String? _selectedFilePath;

  bool get _canUpload => _selectedType != null && _selectedFilePath != null;

  Future<void> _pickFile() async {
    final file = await ImagePickerHelper.pick(context);
    if (file != null && mounted) {
      setState(() => _selectedFilePath = file.path);
    }
  }

  void _upload() {
    if (!_canUpload) return;
    widget.onDocumentAdded(
      VendorDocument(type: _selectedType!, filePath: _selectedFilePath!),
    );
    setState(() {
      _selectedType = null;
      _selectedFilePath = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final m = widget.metrics;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        VendorStepHeader(
          metrics: m,
          title: 'Identity Verification',
          subtitle:
              'Upload a government-issued ID so we can verify the business owner.',
        ),
        SizedBox(height: m.gapLg),

        VendorSectionCard(
          metrics: m,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Upload Document',
                style: AppTextStyles.titleMedium.copyWith(
                  color: context.c.textPrimary,
                  fontFamily: 'Inter',
                  fontWeight: FontWeight.w700,
                  fontSize: m.tileTitleSize + 1,
                ),
              ),
              SizedBox(height: m.gapMd),

              VendorFieldLabel(
                metrics: m,
                label: 'Document Type',
              ),
              SizedBox(height: m.gapSm),
              _DocumentTypeDropdown(
                metrics: m,
                value: _selectedType,
                onChanged: (v) => setState(() => _selectedType = v),
              ),
              SizedBox(height: m.gapMd),

              VendorFieldLabel(
                metrics: m,
                label: 'Document File',
              ),
              SizedBox(height: m.gapXs),
              VendorFieldHint(
                metrics: m,
                text: 'Take a photo or choose one from your gallery',
              ),
              SizedBox(height: m.gapSm),
              AspectRatio(
                aspectRatio: 16 / 9,
                child: VendorImageUploadBox(
                  metrics: m,
                  imagePath: _selectedFilePath,
                  placeholderIcon: Icons.badge_outlined,
                  placeholderText: 'Tap to select document',
                  onPick: _pickFile,
                  onRemove: () => setState(() => _selectedFilePath = null),
                ),
              ),
              SizedBox(height: m.gapMd),

              AppButton(
                label: 'Upload Document',
                variant: AppButtonVariant.secondary,
                prefixIcon: Icons.cloud_upload_outlined,
                onPressed: _canUpload ? _upload : null,
              ),
            ],
          ),
        ),

        if (widget.documents.isNotEmpty) ...[
          SizedBox(height: m.gapLg),
          VendorFieldLabel(
            metrics: m,
            label: 'Uploaded Documents (${widget.documents.length})',
          ),
          SizedBox(height: m.gapSm),
          for (final doc in widget.documents) ...[
            _UploadedDocumentTile(
              metrics: m,
              document: doc,
              onRemove: () => widget.onDocumentRemoved(doc),
            ),
            SizedBox(height: m.gapSm),
          ],
        ],

        SizedBox(height: m.gapLg),
        _UploadTipsCard(metrics: m),
      ],
    );
  }
}

// ── Document type dropdown ─────────────────────────────────────────────────
class _DocumentTypeDropdown extends StatelessWidget {
  final SettingsMetrics metrics;
  final String? value;
  final ValueChanged<String?> onChanged;

  const _DocumentTypeDropdown({
    required this.metrics,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.c;
    final m = metrics;
    final textStyle = AppTextStyles.bodyMedium.copyWith(
      color: colors.textPrimary,
      fontFamily: 'Inter',
      fontSize: m.tileSubSize,
    );

    OutlineInputBorder border(Color color, [double width = 1]) =>
        OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: color, width: width),
        );

    return DropdownButtonFormField<String>(
      // Keyed so the field resets when the parent clears the selection.
      key: ValueKey(value),
      initialValue: value,
      isExpanded: true,
      onChanged: onChanged,
      style: textStyle,
      dropdownColor: colors.surface,
      borderRadius: BorderRadius.circular(12),
      icon: Icon(
        Icons.keyboard_arrow_down_rounded,
        color: colors.textSecondary,
        size: m.iconSize,
      ),
      hint: Text(
        'Select document type',
        style: textStyle.copyWith(color: colors.textMuted),
      ),
      decoration: InputDecoration(
        filled: true,
        fillColor: colors.background,
        contentPadding: EdgeInsets.symmetric(
          horizontal: m.tileHPad * 0.8,
          vertical: m.tileVPad * 0.7,
        ),
        border: border(colors.border),
        enabledBorder: border(colors.border),
        focusedBorder: border(colors.brand, 1.6),
      ),
      items: [
        for (final type in vendorDocumentTypes)
          DropdownMenuItem(value: type.$1, child: Text(type.$2)),
      ],
    );
  }
}

// ── Uploaded document row ──────────────────────────────────────────────────
class _UploadedDocumentTile extends StatelessWidget {
  final SettingsMetrics metrics;
  final VendorDocument document;
  final VoidCallback onRemove;

  const _UploadedDocumentTile({
    required this.metrics,
    required this.document,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.c;
    final m = metrics;
    final thumb = m.iconBox * 1.15;

    return Container(
      padding: EdgeInsets.all(m.tileHPad * 0.6),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(m.cardRadius * 0.75),
        border: Border.all(color: colors.border),
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.file(
              File(document.filePath),
              width: thumb,
              height: thumb,
              fit: BoxFit.cover,
            ),
          ),
          SizedBox(width: m.tileHPad * 0.7),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  document.label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.labelLarge.copyWith(
                    color: colors.textPrimary,
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.w600,
                    fontSize: m.tileTitleSize,
                  ),
                ),
                SizedBox(height: m.gapXs * 0.6),
                Row(
                  children: [
                    Icon(
                      Icons.check_circle_rounded,
                      size: m.tileSubSize,
                      color: colors.brand,
                    ),
                    SizedBox(width: m.gapXs),
                    Text(
                      'Ready to submit',
                      style: AppTextStyles.bodySmall.copyWith(
                        color: colors.textSecondary,
                        fontFamily: 'Inter',
                        fontSize: m.tileSubSize - 2,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: onRemove,
            tooltip: 'Remove',
            icon: Icon(
              Icons.delete_outline_rounded,
              color: colors.error,
              size: m.iconSize,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Tips card ──────────────────────────────────────────────────────────────
class _UploadTipsCard extends StatelessWidget {
  final SettingsMetrics metrics;

  const _UploadTipsCard({required this.metrics});

  static const _tips = [
    'Use the original coloured document — no photocopy or screenshot',
    'Photo should be clear and focused, without blur or glare',
    'All four corners of the document must be visible',
    'Name, number and dates should be clearly readable',
    'Document must be valid (not expired)',
  ];

  @override
  Widget build(BuildContext context) {
    final colors = context.c;
    final m = metrics;
    final bodyStyle = AppTextStyles.bodyMedium.copyWith(
      color: colors.textSecondary,
      fontFamily: 'Inter',
      fontSize: m.tileSubSize - 1,
      height: 1.45,
    );

    return Container(
      padding: EdgeInsets.all(m.tileHPad),
      decoration: BoxDecoration(
        color: colors.brandSoft,
        borderRadius: BorderRadius.circular(m.cardRadius),
        border: Border.all(color: colors.brand.withValues(alpha: 0.25)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.lightbulb_outline_rounded,
                size: m.iconSize,
                color: colors.brand,
              ),
              SizedBox(width: m.gapSm),
              Text(
                'Tips for a clear upload',
                style: AppTextStyles.titleMedium.copyWith(
                  color: colors.textPrimary,
                  fontFamily: 'Inter',
                  fontWeight: FontWeight.w700,
                  fontSize: m.tileTitleSize,
                ),
              ),
            ],
          ),
          SizedBox(height: m.gapSm),
          for (final tip in _tips)
            Padding(
              padding: EdgeInsets.only(top: m.gapXs),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('•  ', style: bodyStyle.copyWith(color: colors.brand)),
                  Expanded(child: Text(tip, style: bodyStyle)),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
