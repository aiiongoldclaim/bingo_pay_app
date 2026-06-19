import 'package:flutter/material.dart';

import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_dimensions.dart';
import '../../models/product_form_data.dart';
import 'category_picker_sheet.dart';
import 'tap_select_field.dart';

class PricingStep extends StatelessWidget {
  final GlobalKey<FormState> formKey;
  final TextEditingController mrpController;
  final TextEditingController sellingPriceController;
  final TextEditingController costPriceController;
  final ProductDraft draft;
  final VoidCallback onDraftChanged;

  const PricingStep({
    super.key,
    required this.formKey,
    required this.mrpController,
    required this.sellingPriceController,
    required this.costPriceController,
    required this.draft,
    required this.onDraftChanged,
  });

  String? _requiredPrice(String? value, String fieldName) {
    if (value == null || value.trim().isEmpty) return '$fieldName is required';
    final parsed = double.tryParse(value.trim());
    if (parsed == null || parsed <= 0) return 'Enter a valid $fieldName';
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _FieldLabel('MRP (max retail price)', required: true),
          TextFormField(
            controller: mrpController,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: const InputDecoration(prefixText: '₹ ', hintText: '999'),
            validator: (v) => _requiredPrice(v, 'MRP'),
          ),
          const SizedBox(height: AppDimensions.lg),
          const _FieldLabel('Selling price', required: true),
          TextFormField(
            controller: sellingPriceController,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: const InputDecoration(prefixText: '₹ ', hintText: '699'),
            validator: (v) => _requiredPrice(v, 'selling price'),
          ),
          AnimatedBuilder(
            animation: Listenable.merge([mrpController, sellingPriceController]),
            builder: (context, _) {
              final mrp = double.tryParse(mrpController.text.trim());
              final sellingPrice = double.tryParse(sellingPriceController.text.trim());
              if (mrp == null || sellingPrice == null || sellingPrice >= mrp || mrp <= 0) {
                return const SizedBox.shrink();
              }
              final discount = (((mrp - sellingPrice) / mrp) * 100).round();
              return Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(
                  '$discount% discount applied',
                  style: const TextStyle(color: AppColors.error, fontWeight: FontWeight.w600, fontSize: 13),
                ),
              );
            },
          ),
          const SizedBox(height: AppDimensions.lg),
          const _FieldLabel('Cost price (optional)'),
          TextFormField(
            controller: costPriceController,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: const InputDecoration(prefixText: '₹ ', hintText: '0'),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Text('Used internally for margin analysis', style: TextStyle(fontSize: 12, color: Colors.grey[500])),
          ),
          const SizedBox(height: AppDimensions.lg),
          TapSelectField(
            label: 'GST slab',
            hint: '12%',
            value: draft.gstSlab,
            required: true,
            onTap: () => showGstSlabPicker(context, selected: draft.gstSlab),
            onChanged: (value) {
              draft.gstSlab = value;
              onDraftChanged();
            },
          ),
          const SizedBox(height: AppDimensions.lg),
          _ToggleRow(
            title: 'Tax inclusive?',
            subtitle: 'Price includes GST',
            value: draft.taxInclusive,
            onChanged: (value) {
              draft.taxInclusive = value;
              onDraftChanged();
            },
          ),
        ],
      ),
    );
  }
}

class _ToggleRow extends StatelessWidget {
  final String title;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;

  const _ToggleRow({required this.title, required this.subtitle, required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppDimensions.md, vertical: 12),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(AppDimensions.radiusMd)),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontSize: 14)),
                const SizedBox(height: 2),
                Text(subtitle, style: TextStyle(fontSize: 12, color: Colors.grey[500])),
              ],
            ),
          ),
          Switch(value: value, onChanged: onChanged, activeThumbColor: AppColors.primary),
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
          children: required ? const [TextSpan(text: ' *', style: TextStyle(color: AppColors.error))] : null,
        ),
      ),
    );
  }
}
