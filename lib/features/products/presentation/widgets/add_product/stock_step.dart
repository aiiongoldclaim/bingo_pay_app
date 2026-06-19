import 'package:flutter/material.dart';

import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_dimensions.dart';
import '../../../../../core/utils/validators.dart';
import '../../models/product_form_data.dart';

class StockStep extends StatelessWidget {
  final GlobalKey<FormState> formKey;
  final TextEditingController skuController;
  final TextEditingController barcodeController;
  final TextEditingController lowStockThresholdController;
  final ProductDraft draft;
  final VoidCallback onDraftChanged;

  const StockStep({
    super.key,
    required this.formKey,
    required this.skuController,
    required this.barcodeController,
    required this.lowStockThresholdController,
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
          const _FieldLabel('SKU', required: true),
          TextFormField(
            controller: skuController,
            decoration: const InputDecoration(hintText: 'TSH-1042'),
            validator: (v) => Validators.required(v, fieldName: 'SKU'),
          ),
          const SizedBox(height: AppDimensions.lg),
          const _FieldLabel('Barcode / EAN'),
          TextFormField(
            controller: barcodeController,
            decoration: const InputDecoration(hintText: 'Scan or enter barcode'),
          ),
          const SizedBox(height: AppDimensions.lg),
          _ToggleRow(
            title: 'Track inventory?',
            required: true,
            value: draft.trackInventory,
            onChanged: (value) {
              draft.trackInventory = value;
              onDraftChanged();
            },
          ),
          const SizedBox(height: AppDimensions.lg),
          const _FieldLabel('Current stock qty', required: true),
          _StockStepper(
            value: draft.stockQty,
            enabled: draft.trackInventory,
            onChanged: (value) {
              draft.stockQty = value;
              onDraftChanged();
            },
          ),
          const SizedBox(height: AppDimensions.lg),
          const _FieldLabel('Low stock threshold'),
          TextFormField(
            controller: lowStockThresholdController,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(hintText: '10'),
          ),
          const SizedBox(height: AppDimensions.lg),
          _ToggleRow(
            title: 'Allow backorders',
            value: draft.allowBackorders,
            onChanged: (value) {
              draft.allowBackorders = value;
              onDraftChanged();
            },
          ),
        ],
      ),
    );
  }
}

class _StockStepper extends StatelessWidget {
  final int value;
  final bool enabled;
  final ValueChanged<int> onChanged;

  const _StockStepper({required this.value, required this.enabled, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppDimensions.md, vertical: 4),
      decoration: BoxDecoration(
        color: enabled ? Colors.white : const Color(0xFFF1F0EC),
        borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
      ),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.remove),
            onPressed: enabled && value > 0 ? () => onChanged(value - 1) : null,
          ),
          Expanded(
            child: Text('$value', textAlign: TextAlign.center, style: const TextStyle(fontSize: 16)),
          ),
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: enabled ? () => onChanged(value + 1) : null,
          ),
        ],
      ),
    );
  }
}

class _ToggleRow extends StatelessWidget {
  final String title;
  final bool required;
  final bool value;
  final ValueChanged<bool> onChanged;

  const _ToggleRow({required this.title, this.required = false, required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppDimensions.md, vertical: 14),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(AppDimensions.radiusMd)),
      child: Row(
        children: [
          Expanded(child: _FieldLabel(title, required: required, padBottom: false)),
          Switch(value: value, onChanged: onChanged, activeThumbColor: AppColors.primary),
        ],
      ),
    );
  }
}

class _FieldLabel extends StatelessWidget {
  final String text;
  final bool required;
  final bool padBottom;

  const _FieldLabel(this.text, {this.required = false, this.padBottom = true});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: padBottom ? AppDimensions.sm : 0),
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
