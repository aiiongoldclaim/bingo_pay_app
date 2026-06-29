import 'package:flutter/material.dart';

import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_dimensions.dart';
import '../../../../../core/utils/validators.dart';
import '../../../data/models/category_form_model.dart';
import '../../models/product_form_data.dart';

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
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _VariantFormSheet(
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
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
      ),
      child: Column(
        children: [
          Icon(Icons.layers_outlined, size: 40, color: Colors.grey[400]),
          const SizedBox(height: 8),
          Text('No variants yet', style: TextStyle(color: Colors.grey[500], fontSize: 14)),
          const SizedBox(height: 4),
          Text('Tap "Add Variant" to create one', style: TextStyle(color: Colors.grey[400], fontSize: 12)),
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
        color: Colors.white,
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
                        Text('₹${variant.salePrice}', style: const TextStyle(fontSize: 13)),
                      if (variant.basePrice != null && variant.salePrice != null &&
                          variant.basePrice! > variant.salePrice!)
                        Text(
                          '  ₹${variant.basePrice}',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[500],
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
                  style: TextStyle(fontSize: 12, color: Colors.grey[500]),
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

// ---------------------------------------------------------------------------
// Variant form bottom sheet
// ---------------------------------------------------------------------------

class _VariantFormSheet extends StatefulWidget {
  final VariantDraft? initial;
  final List<FormAttribute> variantAttributes;
  final Future<void> Function(VariantDraft) onSave;

  const _VariantFormSheet({
    this.initial,
    required this.variantAttributes,
    required this.onSave,
  });

  @override
  State<_VariantFormSheet> createState() => _VariantFormSheetState();
}

class _VariantFormSheetState extends State<_VariantFormSheet> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _titleCtrl;
  late final TextEditingController _basePriceCtrl;
  late final TextEditingController _salePriceCtrl;
  late final TextEditingController _costPriceCtrl;
  late final TextEditingController _skuCtrl;
  late final TextEditingController _barcodeCtrl;
  late int _stock;
  late bool _isDefault;
  bool _isSaving = false;
  final Map<String, String?> _attrValues = {}; // attributeUuid → selected optionId

  @override
  void initState() {
    super.initState();
    final v = widget.initial;
    _titleCtrl = TextEditingController(text: v?.title ?? '');
    _basePriceCtrl = TextEditingController(text: v?.basePrice?.toString() ?? '');
    _salePriceCtrl = TextEditingController(text: v?.salePrice?.toString() ?? '');
    _costPriceCtrl = TextEditingController(text: v?.costPrice?.toString() ?? '');
    _skuCtrl = TextEditingController(text: v?.sku ?? '');
    _barcodeCtrl = TextEditingController(text: v?.barcode ?? '');
    _stock = v?.stock ?? 0;
    _isDefault = v?.isDefault ?? false;
    if (v != null) _attrValues.addAll(v.attributeValues.map((k, val) => MapEntry(k, val)));
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _basePriceCtrl.dispose();
    _salePriceCtrl.dispose();
    _costPriceCtrl.dispose();
    _skuCtrl.dispose();
    _barcodeCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (_formKey.currentState?.validate() != true) return;
    if (_isSaving) return;
    setState(() => _isSaving = true);
    try {
      final attrValues = {
        for (final e in _attrValues.entries)
          if (e.value != null && e.value!.isNotEmpty) e.key: e.value!,
      };
      await widget.onSave(VariantDraft(
        uuid: widget.initial?.uuid,
        title: _titleCtrl.text.trim(),
        basePrice: double.tryParse(_basePriceCtrl.text.trim()),
        salePrice: double.tryParse(_salePriceCtrl.text.trim()),
        costPrice: _costPriceCtrl.text.trim().isNotEmpty
            ? double.tryParse(_costPriceCtrl.text.trim())
            : null,
        sku: _skuCtrl.text.trim(),
        barcode: _barcodeCtrl.text.trim(),
        stock: _stock,
        isDefault: _isDefault,
        attributeValues: attrValues,
      ));
      if (mounted) Navigator.of(context).pop();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to save variant: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  String? _requiredPrice(String? v, String name) {
    if (v == null || v.trim().isEmpty) return '$name is required';
    if (double.tryParse(v.trim()) == null) return 'Enter a valid $name';
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFFF4F5F7),
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            margin: const EdgeInsets.symmetric(vertical: 12),
            width: 40,
            height: 4,
            decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(2)),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppDimensions.md),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  widget.initial == null ? 'Add Variant' : 'Edit Variant',
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                _isSaving
                    ? const SizedBox(
                        width: 18, height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : TextButton(onPressed: _save, child: const Text('Save')),
              ],
            ),
          ),
          const Divider(height: 1),
          Flexible(
            child: SingleChildScrollView(
              padding: EdgeInsets.fromLTRB(
                AppDimensions.md,
                AppDimensions.md,
                AppDimensions.md,
                AppDimensions.md + MediaQuery.viewInsetsOf(context).bottom,
              ),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _SectionHeader('Pricing'),
                    const SizedBox(height: AppDimensions.md),
                    const _FieldLabel('Variant title'),
                    TextFormField(
                      controller: _titleCtrl,
                      decoration: const InputDecoration(hintText: 'e.g. Red / Medium'),
                    ),
                    const SizedBox(height: AppDimensions.lg),
                    const _FieldLabel('Base price (MRP)', required: true),
                    TextFormField(
                      controller: _basePriceCtrl,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      decoration: const InputDecoration(prefixText: '₹ ', hintText: '999'),
                      validator: (v) => _requiredPrice(v, 'Base price'),
                    ),
                    const SizedBox(height: AppDimensions.lg),
                    const _FieldLabel('Sale price', required: true),
                    TextFormField(
                      controller: _salePriceCtrl,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      decoration: const InputDecoration(prefixText: '₹ ', hintText: '799'),
                      validator: (v) => _requiredPrice(v, 'Sale price'),
                    ),
                    AnimatedBuilder(
                      animation: Listenable.merge([_basePriceCtrl, _salePriceCtrl]),
                      builder: (context, _) {
                        final base = double.tryParse(_basePriceCtrl.text.trim());
                        final sale = double.tryParse(_salePriceCtrl.text.trim());
                        if (base == null || sale == null || sale >= base || base <= 0) {
                          return const SizedBox.shrink();
                        }
                        final discount = (((base - sale) / base) * 100).round();
                        return Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: Text(
                            '$discount% discount applied',
                            style: const TextStyle(
                              color: AppColors.error,
                              fontWeight: FontWeight.w600,
                              fontSize: 13,
                            ),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: AppDimensions.lg),
                    const _FieldLabel('Cost price (optional)'),
                    TextFormField(
                      controller: _costPriceCtrl,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      decoration: const InputDecoration(prefixText: '₹ ', hintText: '0'),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Text(
                        'Used internally for margin analysis',
                        style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                      ),
                    ),
                    const SizedBox(height: AppDimensions.xl),
                    _SectionHeader('Stock'),
                    const SizedBox(height: AppDimensions.md),
                    const _FieldLabel('SKU', required: true),
                    TextFormField(
                      controller: _skuCtrl,
                      decoration: const InputDecoration(hintText: 'e.g. TSH-1042'),
                      validator: (v) => Validators.required(v, fieldName: 'SKU'),
                    ),
                    const SizedBox(height: AppDimensions.lg),
                    const _FieldLabel('Barcode / EAN'),
                    TextFormField(
                      controller: _barcodeCtrl,
                      decoration: const InputDecoration(hintText: 'Scan or enter barcode'),
                    ),
                    const SizedBox(height: AppDimensions.lg),
                    const _FieldLabel('Stock quantity'),
                    _StockStepper(
                      value: _stock,
                      onChanged: (v) => setState(() => _stock = v),
                    ),
                    const SizedBox(height: AppDimensions.lg),
                    _ToggleRow(
                      title: 'Set as default variant',
                      value: _isDefault,
                      onChanged: (v) => setState(() => _isDefault = v),
                    ),
                    Builder(builder: (context) {
                      final attrs = widget.variantAttributes
                          .where((a) => a.options.isNotEmpty)
                          .toList()
                        ..sort((a, b) => a.sortOrder.compareTo(b.sortOrder));

                      if (attrs.isEmpty) return const SizedBox.shrink();

                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: AppDimensions.xl),
                          _SectionHeader('Variant Options'),
                          const SizedBox(height: AppDimensions.md),
                          for (final attr in attrs) ...[
                            _FieldLabel(attr.name, required: attr.isRequired),
                            DropdownButtonFormField<String>(
                              value: _attrValues[attr.uuid],
                              decoration: InputDecoration(hintText: 'Select ${attr.name.toLowerCase()}'),
                              isExpanded: true,
                              items: attr.options
                                  .map((opt) => DropdownMenuItem(
                                        value: opt.id,
                                        child: Text(opt.value),
                                      ))
                                  .toList(),
                              onChanged: (v) => setState(() => _attrValues[attr.uuid] = v),
                              validator: attr.isRequired
                                  ? (v) => v == null ? '${attr.name} is required' : null
                                  : null,
                            ),
                            const SizedBox(height: AppDimensions.lg),
                          ],
                        ],
                      );
                    }),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Shared helpers
// ---------------------------------------------------------------------------

class _SectionHeader extends StatelessWidget {
  final String text;
  const _SectionHeader(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w600,
        color: Colors.grey,
        letterSpacing: 0.5,
      ),
    );
  }
}

class _StockStepper extends StatefulWidget {
  final int value;
  final ValueChanged<int> onChanged;

  const _StockStepper({required this.value, required this.onChanged});

  @override
  State<_StockStepper> createState() => _StockStepperState();
}

class _StockStepperState extends State<_StockStepper> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: '${widget.value}');
  }

  @override
  void didUpdateWidget(_StockStepper oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.value != widget.value) {
      final newText = '${widget.value}';
      if (_controller.text != newText) {
        _controller.text = newText;
        _controller.selection = TextSelection.collapsed(offset: newText.length);
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _commitText(String text) {
    final parsed = int.tryParse(text.trim());
    if (parsed != null && parsed >= 0) {
      widget.onChanged(parsed);
    } else {
      _controller.text = '${widget.value}';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppDimensions.md, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
      ),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.remove),
            onPressed: widget.value > 0 ? () => widget.onChanged(widget.value - 1) : null,
          ),
          Expanded(
            child: TextField(
              controller: _controller,
              keyboardType: TextInputType.number,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 16),
              decoration: const InputDecoration(
                border: InputBorder.none,
                isDense: true,
                contentPadding: EdgeInsets.zero,
              ),
              onChanged: (text) {
                final parsed = int.tryParse(text.trim());
                if (parsed != null && parsed >= 0) widget.onChanged(parsed);
              },
              onSubmitted: _commitText,
              onTapOutside: (_) => _commitText(_controller.text),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => widget.onChanged(widget.value + 1),
          ),
        ],
      ),
    );
  }
}

class _ToggleRow extends StatelessWidget {
  final String title;
  final bool value;
  final ValueChanged<bool> onChanged;

  const _ToggleRow({required this.title, required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppDimensions.md, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
      ),
      child: Row(
        children: [
          Expanded(child: Text(title, style: const TextStyle(fontSize: 14))),
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
          children: required
              ? const [TextSpan(text: ' *', style: TextStyle(color: AppColors.error))]
              : null,
        ),
      ),
    );
  }
}
