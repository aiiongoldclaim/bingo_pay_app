import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/widgets/app_text_field.dart';
import '../../../setting/features/widgets/settings_metrics.dart';
import 'vendor_application_widgets.dart';

/// Controllers are owned by the screen so values survive switching steps.
class BusinessInfoControllers {
  final shopName = TextEditingController();
  final shopSlug = TextEditingController();
  final businessName = TextEditingController();
  final gstNumber = TextEditingController();
  final panNumber = TextEditingController();
  final supportEmail = TextEditingController();
  final supportPhone = TextEditingController();
  final description = TextEditingController();

  void dispose() {
    for (final c in [
      shopName,
      shopSlug,
      businessName,
      gstNumber,
      panNumber,
      supportEmail,
      supportPhone,
      description,
    ]) {
      c.dispose();
    }
  }
}

class BusinessInfoStep extends StatefulWidget {
  final SettingsMetrics metrics;
  final BusinessInfoControllers controllers;
  final GlobalKey<FormState> formKey;

  const BusinessInfoStep({
    super.key,
    required this.metrics,
    required this.controllers,
    required this.formKey,
  });

  @override
  State<BusinessInfoStep> createState() => _BusinessInfoStepState();
}

class _BusinessInfoStepState extends State<BusinessInfoStep> {
  static final _gstRegex =
      RegExp(r'^[0-9]{2}[A-Z]{5}[0-9]{4}[A-Z][1-9A-Z]Z[0-9A-Z]$');
  static final _panRegex = RegExp(r'^[A-Z]{5}[0-9]{4}[A-Z]$');
  static final _emailRegex = RegExp(r'^[\w.+-]+@[\w-]+(\.[\w-]+)+$');
  static final _slugRegex = RegExp(r'^[a-z0-9]+(-[a-z0-9]+)*$');

  /// Slug follows the shop name until the user edits it by hand.
  late bool _slugEdited = widget.controllers.shopSlug.text.isNotEmpty;

  BusinessInfoControllers get c => widget.controllers;

  static String _slugify(String value) => value
      .toLowerCase()
      .trim()
      .replaceAll(RegExp(r'[^a-z0-9\s-]'), '')
      .replaceAll(RegExp(r'[\s-]+'), '-')
      .replaceAll(RegExp(r'^-+|-+$'), '');

  @override
  Widget build(BuildContext context) {
    final m = widget.metrics;
    final gap = SizedBox(height: m.gapMd);

    return Form(
      key: widget.formKey,
      autovalidateMode: AutovalidateMode.onUserInteraction,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          VendorStepHeader(
            metrics: m,
            title: 'Business Information',
            subtitle:
                'Provide your business details and contact information.',
          ),
          SizedBox(height: m.gapLg),

          AppTextField(
            label: 'Shop Name',
            hint: 'e.g. The Golden Vault',
            controller: c.shopName,
            textInputAction: TextInputAction.next,
            onChanged: (v) {
              if (!_slugEdited) c.shopSlug.text = _slugify(v);
            },
          ),
          gap,

          AppTextField(
            label: 'Shop Slug',
            hint: 'e.g. the-golden-vault',
            controller: c.shopSlug,
            textInputAction: TextInputAction.next,
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp(r'[a-z0-9-]')),
            ],
            onChanged: (_) => _slugEdited = true,
            validator: (v) {
              final value = v?.trim() ?? '';
              if (value.isEmpty) return null;
              return _slugRegex.hasMatch(value)
                  ? null
                  : 'Use lowercase letters, numbers and hyphens only';
            },
          ),
          gap,

          AppTextField(
            label: 'Business Name',
            hint: 'Registered business name',
            controller: c.businessName,
            textInputAction: TextInputAction.next,
          ),
          gap,

          AppTextField(
            label: 'GST Number',
            hint: 'e.g. 22AAAAA0000A1Z5',
            controller: c.gstNumber,
            textInputAction: TextInputAction.next,
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp(r'[A-Za-z0-9]')),
              LengthLimitingTextInputFormatter(15),
              _UpperCaseFormatter(),
            ],
            validator: (v) {
              final value = v?.trim() ?? '';
              if (value.isEmpty) return null;
              return _gstRegex.hasMatch(value)
                  ? null
                  : 'Enter a valid 15-character GST number';
            },
          ),
          gap,

          AppTextField(
            label: 'PAN Number',
            hint: 'e.g. ABCDE1234F',
            controller: c.panNumber,
            textInputAction: TextInputAction.next,
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp(r'[A-Za-z0-9]')),
              LengthLimitingTextInputFormatter(10),
              _UpperCaseFormatter(),
            ],
            validator: (v) {
              final value = v?.trim() ?? '';
              if (value.isEmpty) return null;
              return _panRegex.hasMatch(value)
                  ? null
                  : 'Enter a valid 10-character PAN number';
            },
          ),
          gap,

          AppTextField(
            label: 'Support Email',
            hint: 'support@yourshop.com',
            controller: c.supportEmail,
            keyboardType: TextInputType.emailAddress,
            textInputAction: TextInputAction.next,
            validator: (v) {
              final value = v?.trim() ?? '';
              if (value.isEmpty) return null;
              return _emailRegex.hasMatch(value)
                  ? null
                  : 'Enter a valid email address';
            },
          ),
          gap,

          AppTextField(
            label: 'Support Phone Number',
            hint: '10-digit mobile number',
            controller: c.supportPhone,
            keyboardType: TextInputType.phone,
            textInputAction: TextInputAction.next,
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
              LengthLimitingTextInputFormatter(10),
            ],
            validator: (v) {
              final value = v?.trim() ?? '';
              if (value.isEmpty) return null;
              return value.length == 10
                  ? null
                  : 'Enter a valid 10-digit phone number';
            },
          ),
          gap,

          AppTextField(
            label: 'Description',
            hint: 'What does your shop sell?',
            controller: c.description,
            keyboardType: TextInputType.multiline,
            maxLines: 4,
            inputFormatters: [LengthLimitingTextInputFormatter(500)],
          ),
        ],
      ),
    );
  }
}

class _UpperCaseFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) =>
      newValue.copyWith(text: newValue.text.toUpperCase());
}
