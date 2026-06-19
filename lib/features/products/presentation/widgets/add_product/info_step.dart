import 'package:flutter/material.dart';

import '../../../../../core/theme/app_dimensions.dart';
import '../../../../../core/utils/validators.dart';
import '../../models/product_form_data.dart';
import 'category_picker_sheet.dart';
import 'tap_select_field.dart';

class InfoStep extends StatelessWidget {
  final GlobalKey<FormState> formKey;
  final TextEditingController nameController;
  final TextEditingController shortDescriptionController;
  final TextEditingController fullDescriptionController;
  final TextEditingController brandController;
  final ProductDraft draft;
  final VoidCallback onDraftChanged;

  const InfoStep({
    super.key,
    required this.formKey,
    required this.nameController,
    required this.shortDescriptionController,
    required this.fullDescriptionController,
    required this.brandController,
    required this.draft,
    required this.onDraftChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Form(
      key: formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _FieldLabel('Product name', required: true),
          TextFormField(
            controller: nameController,
            decoration: const InputDecoration(hintText: "e.g. Men's Cotton T-Shirt"),
            validator: Validators.name,
          ),
          const SizedBox(height: AppDimensions.lg),
          const _FieldLabel('Short description'),
          TextFormField(
            controller: shortDescriptionController,
            decoration: const InputDecoration(hintText: 'One-line summary'),
          ),
          const SizedBox(height: AppDimensions.lg),
          const _FieldLabel('Full description'),
          TextFormField(
            controller: fullDescriptionController,
            decoration: const InputDecoration(hintText: 'Product details, features...'),
            maxLines: 4,
          ),
          const SizedBox(height: AppDimensions.lg),
          TapSelectField(
            label: 'Category',
            hint: 'Tap to select category',
            value: draft.category,
            required: true,
            onTap: () => showCategoryPicker(context, selected: draft.category),
            onChanged: (value) {
              draft.category = value;
              draft.subCategory = null;
              onDraftChanged();
            },
          ),
          const SizedBox(height: AppDimensions.lg),
          TapSelectField(
            key: ValueKey(draft.category),
            label: 'Sub-category',
            hint: draft.category == null ? 'Select category first' : 'Tap to select sub-category',
            value: draft.subCategory,
            enabled: draft.category != null,
            onTap: () => showSubCategoryPicker(
              context,
              category: draft.category!,
              selected: draft.subCategory,
            ),
            onChanged: (value) {
              draft.subCategory = value;
              onDraftChanged();
            },
          ),
          const SizedBox(height: AppDimensions.lg),
          const _FieldLabel('Brand'),
          TextFormField(
            controller: brandController,
            decoration: const InputDecoration(hintText: 'e.g. Nike, Tanishq'),
          ),
        ],
      ),
    );
  }
}

class _FieldLabel extends StatelessWidget {
  final String text;
  final bool required;

  const _FieldLabel(this.text, {this.required = false});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppDimensions.sm),
      child: Text.rich(
        TextSpan(
          text: text,
          style: const TextStyle(fontSize: 14, color: Colors.black87),
          children: required ? const [TextSpan(text: ' *', style: TextStyle(color: Colors.red))] : null,
        ),
      ),
    );
  }
}
