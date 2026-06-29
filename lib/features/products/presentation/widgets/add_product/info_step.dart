import 'package:flutter/material.dart';

import '../../../../../core/di/injection.dart';
import '../../../../../core/theme/app_dimensions.dart';
import '../../../../../core/utils/validators.dart';
import '../../../data/datasources/product_remote_datasource.dart';
import '../../../data/models/category_model.dart';
import '../../models/product_form_data.dart';
import 'brand_picker_sheet.dart';
import 'category_picker_sheet.dart';
import 'tap_select_field.dart';

class InfoStep extends StatefulWidget {
  final GlobalKey<FormState> formKey;
  final TextEditingController nameController;
  final TextEditingController shortDescriptionController;
  final TextEditingController fullDescriptionController;
  final ProductDraft draft;
  final VoidCallback onDraftChanged;

  const InfoStep({
    super.key,
    required this.formKey,
    required this.nameController,
    required this.shortDescriptionController,
    required this.fullDescriptionController,
    required this.draft,
    required this.onDraftChanged,
  });

  @override
  State<InfoStep> createState() => _InfoStepState();
}

class _InfoStepState extends State<InfoStep> {
  List<CategoryModel> _subCategories = [];

  ProductDraft get _draft => widget.draft;

  void _onCategorySelected(CategoryModel cat) {
    _draft.category = cat.name;
    _draft.categoryUuid = cat.uuid;
    _draft.subCategory = null;
    _draft.subCategoryUuid = null;
    _draft.specifications.clear();
    setState(() => _subCategories = cat.children);
    widget.onDraftChanged();
  }

  Future<List<CategoryModel>> _loadSubCategories() async {
    if (_subCategories.isNotEmpty) return _subCategories;
    if (_draft.categoryUuid == null) return [];
    final tree = await getIt<ProductRemoteDataSource>().getCategoryTree();
    final parent = tree.cast<CategoryModel?>().firstWhere(
      (c) => c?.uuid == _draft.categoryUuid,
      orElse: () => null,
    );
    final children = parent?.children ?? [];
    if (mounted) setState(() => _subCategories = children);
    return children;
  }

  bool get _hasSubCategories => _subCategories.isNotEmpty || _draft.subCategoryUuid != null;

  @override
  Widget build(BuildContext context) {
    return Form(
      key: widget.formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _FieldLabel('Product name', required: true),
          TextFormField(
            controller: widget.nameController,
            decoration: const InputDecoration(hintText: "e.g. Men's Cotton T-Shirt"),
            validator: Validators.name,
          ),
          const SizedBox(height: AppDimensions.lg),
          const _FieldLabel('Short description'),
          TextFormField(
            controller: widget.shortDescriptionController,
            decoration: const InputDecoration(hintText: 'One-line summary'),
          ),
          const SizedBox(height: AppDimensions.lg),
          const _FieldLabel('Full description'),
          TextFormField(
            controller: widget.fullDescriptionController,
            decoration: const InputDecoration(hintText: 'Product details, features...'),
            maxLines: 4,
          ),
          const SizedBox(height: AppDimensions.lg),
          TapSelectField(
            label: 'Category',
            hint: 'Tap to select category',
            value: _draft.category,
            required: true,
            onTap: () async {
              final cat = await showParentCategoryPicker(context, selectedId: _draft.categoryUuid);
              if (cat != null) _onCategorySelected(cat);
              return cat?.name;
            },
            onChanged: (_) {},
          ),
          if (_hasSubCategories) ...[
            const SizedBox(height: AppDimensions.lg),
            TapSelectField(
              label: 'Sub-category',
              hint: 'Tap to select sub-category',
              value: _draft.subCategory,
              required: true,
              onTap: () async {
                final children = await _loadSubCategories();
                if (!context.mounted) return null;
                final result = await showSubCategoryPicker(
                  context,
                  children: children,
                  selectedId: _draft.subCategoryUuid,
                );
                if (result != null) {
                  _draft.subCategory = result.name;
                  _draft.subCategoryUuid = result.id;
                  _draft.specifications.clear();
                  widget.onDraftChanged();
                }
                return result?.name;
              },
              onChanged: (_) {},
            ),
          ],
          const SizedBox(height: AppDimensions.lg),
          TapSelectField(
            label: 'Brand',
            hint: 'Tap to select brand',
            value: _draft.brand,
            onTap: () async {
              final picked = await showBrandPickerById(context, selectedId: _draft.brandUuid);
              if (picked != null) {
                _draft.brand = picked.name;
                _draft.brandUuid = picked.id;
                widget.onDraftChanged();
              }
              return picked?.name;
            },
            onChanged: (_) {},
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
