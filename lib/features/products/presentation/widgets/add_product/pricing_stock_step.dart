import 'package:flutter/material.dart';

import '../../../../../core/constants/app_currency.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_dimensions.dart';
import '../../../data/models/category_form_model.dart';
import '../../models/product_form_data.dart';
import '../../screens/add_variant_screen.dart';

class PricingStockStep extends StatelessWidget {
  final GlobalKey<FormState> formKey;
  final ProductDraft draft;
  final VoidCallback onDraftChanged;
  final Future<void> Function(VariantDraft variant)? onVariantSaved;
  final List<FormAttribute> variantAttributes;

  const PricingStockStep({
    super.key,
    required this.formKey,
    required this.draft,
    required this.onDraftChanged,
    required this.variantAttributes,
    this.onVariantSaved,
  });

  void _showVariantForm(BuildContext context, {int? editIndex}) {
    final existing = editIndex != null ? draft.variants[editIndex] : null;
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => AddVariantScreen(
          initial: existing,
          variantAttributes: variantAttributes,
          onSave: (saved) async {
            if (saved.isDefault) {
              for (final v in draft.variants) {
                v.isDefault = false;
              }
            }
            if (onVariantSaved != null) await onVariantSaved!(saved);
            if (editIndex != null) {
              draft.variants[editIndex] = saved;
            } else {
              draft.variants.add(saved);
            }
            onDraftChanged();
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (draft.variants.isEmpty)
            _EmptyState()
          else
            ...draft.variants.asMap().entries.map(
              (entry) => Padding(
                padding: const EdgeInsets.only(bottom: AppDimensions.sm),
                child: _VariantCard(
                  variant: entry.value,
                  onEdit: () => _showVariantForm(context, editIndex: entry.key),
                  onDelete: () {
                    draft.variants.removeAt(entry.key);
                    onDraftChanged();
                  },
                ),
              ),
            ),
          const SizedBox(height: AppDimensions.md),
          OutlinedButton.icon(
            onPressed: () => _showVariantForm(context),
            icon: const Icon(Icons.add),
            label: const Text('Add Variant'),
            style: OutlinedButton.styleFrom(
              minimumSize: const Size(double.infinity, 48),
              side: const BorderSide(color: AppColors.primary),
              foregroundColor: AppColors.primary,
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 36),
      decoration: BoxDecoration(
        color: context.colors.card,
        borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
      ),
      child: Column(
        children: [
          Icon(Icons.layers_outlined, size: 40, color: context.colors.textMuted),
          const SizedBox(height: 8),
          Text('No variants yet', style: TextStyle(color: context.colors.textMuted, fontSize: 14)),
          const SizedBox(height: 4),
          Text('Tap "Add Variant" to create one', style: TextStyle(color: context.colors.textMuted, fontSize: 12)),
        ],
      ),
    );
  }
}

class _VariantCard extends StatelessWidget {
  final VariantDraft variant;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _VariantCard({required this.variant, required this.onEdit, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppDimensions.md),
      decoration: BoxDecoration(
        color: context.colors.card,
        borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
        border: variant.isDefault ? Border.all(color: AppColors.primary, width: 1.5) : null,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      variant.title.isNotEmpty ? variant.title : 'Untitled',
                      style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                    ),
                    if (variant.isDefault) ...[
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withAlpha(20),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          'Default',
                          style: TextStyle(fontSize: 10, color: AppColors.primary, fontWeight: FontWeight.w600),
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 6),
                if (variant.salePrice != null || variant.basePrice != null)
                  Row(
                    children: [
                      if (variant.salePrice != null)
                        Text('${AppCurrency.symbol}${variant.salePrice}', style: const TextStyle(fontSize: 13)),
                      if (variant.basePrice != null && variant.salePrice != null &&
                          variant.basePrice! > variant.salePrice!)
                        Text(
                          '  ${AppCurrency.symbol}${variant.basePrice}',
                          style: TextStyle(
                            fontSize: 12,
                            color: context.colors.textMuted,
                            decoration: TextDecoration.lineThrough,
                          ),
                        ),
                    ],
                  ),
                const SizedBox(height: 4),
                Text(
                  [
                    if (variant.sku.isNotEmpty) 'SKU: ${variant.sku}',
                    'Stock: ${variant.stock}',
                  ].join('  •  '),
                  style: TextStyle(fontSize: 12, color: context.colors.textMuted),
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.edit_outlined, size: 20),
            onPressed: onEdit,
            visualDensity: VisualDensity.compact,
          ),
          IconButton(
            icon: Icon(Icons.delete_outline, size: 20, color: Colors.red[400]),
            onPressed: onDelete,
            visualDensity: VisualDensity.compact,
          ),
        ],
      ),
    );
  }
}
