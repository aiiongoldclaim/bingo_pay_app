import 'package:flutter/material.dart';

import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_dimensions.dart';
import '../../models/product_form_data.dart';
import '../../models/product_mock_data.dart';

class PublishStep extends StatelessWidget {
  final GlobalKey<FormState> formKey;
  final TextEditingController scheduledPublishController;
  final TextEditingController hsnCodeController;
  final TextEditingController countryOfOriginController;
  final TextEditingController shippingWeightController;
  final ProductDraft draft;
  final VoidCallback onDraftChanged;

  const PublishStep({
    super.key,
    required this.formKey,
    required this.scheduledPublishController,
    required this.hsnCodeController,
    required this.countryOfOriginController,
    required this.shippingWeightController,
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
          const _FieldLabel('Product status', required: true),
          _StatusSegmentedControl(
            value: draft.status,
            onChanged: (value) {
              draft.status = value;
              onDraftChanged();
            },
          ),
          const SizedBox(height: AppDimensions.lg),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: AppDimensions.md, vertical: 14),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(AppDimensions.radiusMd)),
            child: Row(
              children: [
                const Expanded(child: Text('Featured?', style: TextStyle(fontSize: 14))),
                Switch(
                  value: draft.featured,
                  activeThumbColor: AppColors.primary,
                  onChanged: (value) {
                    draft.featured = value;
                    onDraftChanged();
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: AppDimensions.lg),
          const _FieldLabel('Scheduled publish'),
          TextFormField(
            controller: scheduledPublishController,
            decoration: const InputDecoration(hintText: 'Publish immediately'),
          ),
          const SizedBox(height: AppDimensions.lg),
          const _FieldLabel('HSN code'),
          TextFormField(
            controller: hsnCodeController,
            decoration: const InputDecoration(hintText: '61091000'),
          ),
          const SizedBox(height: AppDimensions.lg),
          const _FieldLabel('Country of origin'),
          TextFormField(
            controller: countryOfOriginController,
            decoration: const InputDecoration(hintText: 'India'),
          ),
          const SizedBox(height: AppDimensions.lg),
          const _FieldLabel('Shipping weight (g)'),
          TextFormField(
            controller: shippingWeightController,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(hintText: '250'),
          ),
        ],
      ),
    );
  }
}

class _StatusSegmentedControl extends StatelessWidget {
  final ProductStatus value;
  final ValueChanged<ProductStatus> onChanged;

  const _StatusSegmentedControl({required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(AppDimensions.radiusMd)),
      child: Row(
        children: [
          for (final status in ProductStatus.values)
            Expanded(
              child: GestureDetector(
                onTap: () => onChanged(status),
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  decoration: BoxDecoration(
                    color: status == value ? AppColors.primary : Colors.transparent,
                    borderRadius: BorderRadius.circular(AppDimensions.radiusSm),
                  ),
                  child: Text(
                    _statusLabel(status),
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: status == value ? Colors.white : Colors.grey[600],
                      fontWeight: status == value ? FontWeight.w600 : FontWeight.w400,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  String _statusLabel(ProductStatus status) => switch (status) {
    ProductStatus.active => 'Active',
    ProductStatus.draft => 'Draft',
    ProductStatus.archived => 'Archived',
  };
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
