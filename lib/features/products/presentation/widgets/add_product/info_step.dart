import 'package:flutter/material.dart';

import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_dimensions.dart';
import '../../../../../core/utils/input_formatters.dart';
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
  List<CategoryModel> _rootCategories = [];
  bool _loadingRoots = true;

  ProductDraft get _draft => widget.draft;

  @override
  void initState() {
    super.initState();
    _loadRootCategories();
  }

  Future<void> _loadRootCategories() async {
    final roots = await fetchRootCategories();
    if (mounted) setState(() { _rootCategories = roots; _loadingRoots = false; });
  }

  /// Picks the category at [depth], truncating any deeper selections
  /// (they no longer apply once an ancestor changes).
  void _onCategorySelectedAt(int depth, CategoryModel selected) {
    final path = [..._draft.categoryPath.take(depth), selected];
    _draft.categoryPath = path;
    _draft.specifications.clear();
    widget.onDraftChanged();
    setState(() {});
  }

  String _labelForDepth(int depth) {
    if (depth == 0) return 'Category';
    if (depth == 1) return 'Sub-category';
    return 'Sub-category $depth';
  }

  /// Builds one field per category depth: the already-selected levels, plus
  /// one more if the deepest selection still has children to drill into.
  List<Widget> _buildCategoryFields(BuildContext context) {
    final path = _draft.categoryPath;
    final fields = <Widget>[];

    for (var depth = 0; ; depth++) {
      final options = depth == 0 ? _rootCategories : path[depth - 1].children;
      if (depth > 0 && options.isEmpty) break;

      final selected = depth < path.length ? path[depth] : null;
      final parentUuid = depth == 0 ? 'root' : path[depth - 1].uuid;
      fields.add(
        TapSelectField(
          key: ValueKey('cat_field_${depth}_$parentUuid'),
          label: _labelForDepth(depth),
          hint: depth == 0 && _loadingRoots ? 'Loading categories...' : 'Tap to select ${_labelForDepth(depth).toLowerCase()}',
          value: selected?.name,
          required: true,
          enabled: depth > 0 || !_loadingRoots,
          onTap: () async {
            final result = await showCategoryPicker(
              context,
              options: options,
              selectedId: selected?.uuid,
              title: 'Select ${_labelForDepth(depth).toLowerCase()}',
            );
            if (result != null) _onCategorySelectedAt(depth, result);
            return result?.name;
          },
          onChanged: (_) {},
        ),
      );

      if (depth >= path.length) break;
    }

    return fields;
  }

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
            autovalidateMode: AutovalidateMode.onUserInteraction,
            textCapitalization: TextCapitalization.words,
            inputFormatters: AppInputFormatters.text(100),
            decoration: const InputDecoration(hintText: "e.g. Men's Cotton T-Shirt"),
            // Product names may contain digits/symbols (e.g. "iPhone 15"),
            // so only require a non-empty value with a sensible minimum.
            validator: (v) {
              final t = v?.trim() ?? '';
              if (t.isEmpty) return 'Product name is required';
              if (t.length < 2) return 'Please enter a valid product name';
              return null;
            },
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
          for (final field in _buildCategoryFields(context)) ...[
            field,
            const SizedBox(height: AppDimensions.lg),
          ],
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
          style: TextStyle(fontSize: 14, color: context.colors.textPrimary),
          children: required ? const [TextSpan(text: ' *', style: TextStyle(color: Colors.red))] : null,
        ),
      ),
    );
  }
}
