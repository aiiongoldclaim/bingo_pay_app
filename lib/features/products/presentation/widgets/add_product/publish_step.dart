import 'package:flutter/material.dart';

import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_dimensions.dart';
import '../../models/product_form_data.dart';

class PublishStep extends StatelessWidget {
  final GlobalKey<FormState> formKey;
  final String productName;
  final String shortDescription;
  final ProductDraft draft;

  const PublishStep({
    super.key,
    required this.formKey,
    required this.productName,
    required this.shortDescription,
    required this.draft,
  });

  @override
  Widget build(BuildContext context) {
    return Form(
      key: formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _SectionHeader('Product overview'),
          _ReviewCard(children: [
            _ReviewRow('Name', productName.isNotEmpty ? productName : '—'),
            if (shortDescription.isNotEmpty) _ReviewRow('Description', shortDescription),
            _ReviewRow('Category', [draft.category, draft.subCategory].whereType<String>().join(' › ')),
            if (draft.brand != null) _ReviewRow('Brand', draft.brand!),
          ]),
          const SizedBox(height: AppDimensions.lg),
          _SectionHeader('Specifications'),
          _ReviewCard(children: [
            if (draft.specifications.isEmpty)
              const _ReviewEmpty('No specifications added')
            else
              for (final entry in draft.specifications.entries)
                if (entry.value.trim().isNotEmpty) _ReviewRow(entry.key, entry.value),
          ]),
          const SizedBox(height: AppDimensions.lg),
          _SectionHeader('Variants'),
          _ReviewCard(children: [
            if (draft.variants.isEmpty)
              const _ReviewEmpty('No variants added')
            else
              for (final v in draft.variants) ...[
                _VariantRow(v),
                if (v != draft.variants.last)
                  const Divider(height: 1, thickness: 0.5),
              ],
          ]),
          const SizedBox(height: AppDimensions.lg),
          _SectionHeader('Media'),
          _ReviewCard(children: [
            _ReviewRow(
              'Images',
              draft.imagePaths.isEmpty ? 'None added' : '${draft.imagePaths.length} image(s)',
            ),
          ]),
          const SizedBox(height: AppDimensions.lg),
          Container(
            padding: const EdgeInsets.all(AppDimensions.md),
            decoration: BoxDecoration(
              color: AppColors.infoTint,
              borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
            ),
            child: Row(
              children: [
                Icon(Icons.info_outline, size: 16, color: AppColors.primary),
                const SizedBox(width: 8),
                const Expanded(
                  child: Text(
                    'Submitting will send the product for admin review. You can still save as draft instead.',
                    style: TextStyle(fontSize: 13),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String text;
  const _SectionHeader(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppDimensions.sm),
      child: Text(
        text,
        style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Colors.black54, letterSpacing: 0.3),
      ),
    );
  }
}

class _ReviewCard extends StatelessWidget {
  final List<Widget> children;
  const _ReviewCard({required this.children});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: children,
      ),
    );
  }
}

class _ReviewRow extends StatelessWidget {
  final String label;
  final String value;
  const _ReviewRow(this.label, this.value);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppDimensions.md, vertical: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 110,
            child: Text(label, style: const TextStyle(fontSize: 13, color: Colors.black54)),
          ),
          Expanded(
            child: Text(value.isNotEmpty ? value : '—', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
          ),
        ],
      ),
    );
  }
}

class _ReviewEmpty extends StatelessWidget {
  final String text;
  const _ReviewEmpty(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppDimensions.md, vertical: 12),
      child: Text(text, style: const TextStyle(fontSize: 13, color: Colors.grey)),
    );
  }
}

class _VariantRow extends StatelessWidget {
  final VariantDraft variant;
  const _VariantRow(this.variant);

  @override
  Widget build(BuildContext context) {
    final price = variant.salePrice ?? variant.basePrice;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppDimensions.md, vertical: 10),
      child: Row(
        children: [
          Expanded(
            child: Text(
              variant.title.isNotEmpty ? variant.title : 'Default',
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
            ),
          ),
          if (price != null)
            Text('₹${price.toStringAsFixed(0)}', style: const TextStyle(fontSize: 13, color: Colors.black54)),
          const SizedBox(width: 12),
          Text('Stock: ${variant.stock}', style: const TextStyle(fontSize: 13, color: Colors.black54)),
        ],
      ),
    );
  }
}
