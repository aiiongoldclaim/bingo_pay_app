import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/constants/app_currency.dart';
import '../../../../core/error/error_messages.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../../core/utils/validators.dart';
import '../../data/models/category_form_model.dart';
import '../models/product_form_data.dart';

/// Full-screen form to add or edit a product variant.
/// [onSave] is awaited before popping, so API errors keep the screen open.
class AddVariantScreen extends StatefulWidget {
  final VariantDraft? initial;
  final List<FormAttribute> variantAttributes;
  final Future<void> Function(VariantDraft) onSave;

  const AddVariantScreen({
    super.key,
    this.initial,
    required this.variantAttributes,
    required this.onSave,
  });

  @override
  State<AddVariantScreen> createState() => _AddVariantScreenState();
}

class _AddVariantScreenState extends State<AddVariantScreen> {
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
  final Map<String, String?> _attrValues = {}; // attributeUuid → optionId/text
  final Map<String, TextEditingController> _attrTextControllers = {};

  static bool _isOptionAttr(FormAttribute attr) => attr.hasOptions;

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
    if (v != null) _attrValues.addAll(v.attributeValues);
    for (final attr in widget.variantAttributes) {
      if (!_isOptionAttr(attr)) {
        _attrTextControllers[attr.uuid] =
            TextEditingController(text: _attrValues[attr.uuid] ?? '');
      }
    }
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _basePriceCtrl.dispose();
    _salePriceCtrl.dispose();
    _costPriceCtrl.dispose();
    _skuCtrl.dispose();
    _barcodeCtrl.dispose();
    for (final c in _attrTextControllers.values) {
      c.dispose();
    }
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
          SnackBar(content: Text('Failed to save variant: ${friendlyErrorMessage(e)}')),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  String? _requiredPrice(String? v, String name) {
    if (v == null || v.trim().isEmpty) return '$name is required';
    final parsed = double.tryParse(v.trim());
    if (parsed == null) return 'Enter a valid $name';
    if (parsed <= 0) return '$name must be greater than 0';
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.initial != null;
    return Scaffold(
      backgroundColor: context.colors.background,
      appBar: AppBar(
        title: Text(isEdit ? 'Edit Variant' : 'Add Variant'),
        centerTitle: false,
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
            AppDimensions.md,
            AppDimensions.sm,
            AppDimensions.md,
            AppDimensions.md,
          ),
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              minimumSize: const Size.fromHeight(50),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
              ),
            ),
            onPressed: _isSaving ? null : _save,
            child: _isSaving
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : Text(
                    isEdit ? 'Save Changes' : 'Save Variant',
                    style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
                  ),
          ),
        ),
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppDimensions.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _SectionCard(
                icon: Icons.payments_outlined,
                title: 'Pricing',
                children: [
                  const _FieldLabel('Variant title'),
                  TextFormField(
                    controller: _titleCtrl,
                    decoration: const InputDecoration(hintText: 'e.g. Red / Medium'),
                  ),
                  const SizedBox(height: AppDimensions.md),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const _FieldLabel('Base price (MRP)', required: true),
                            TextFormField(
                              controller: _basePriceCtrl,
                              keyboardType: const TextInputType.numberWithOptions(decimal: true),
                              decoration: const InputDecoration(
                                prefixText: AppCurrency.inputPrefix,
                                hintText: '999',
                              ),
                              validator: (v) => _requiredPrice(v, 'Base price'),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: AppDimensions.sm + 4),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const _FieldLabel('Sale price', required: true),
                            TextFormField(
                              controller: _salePriceCtrl,
                              keyboardType: const TextInputType.numberWithOptions(decimal: true),
                              decoration: const InputDecoration(
                                prefixText: AppCurrency.inputPrefix,
                                hintText: '799',
                              ),
                              validator: (v) => _requiredPrice(v, 'Sale price'),
                            ),
                          ],
                        ),
                      ),
                    ],
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
                        padding: const EdgeInsets.only(top: AppDimensions.sm),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                          decoration: BoxDecoration(
                            color: AppColors.successTint,
                            borderRadius: BorderRadius.circular(AppDimensions.radiusCircular),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.local_offer_outlined,
                                  size: 14, color: Color(0xFF4C7A2D)),
                              const SizedBox(width: 6),
                              Text(
                                '$discount% discount applied',
                                style: const TextStyle(
                                  color: Color(0xFF4C7A2D),
                                  fontWeight: FontWeight.w600,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: AppDimensions.md),
                  const _FieldLabel('Cost price (optional)'),
                  TextFormField(
                    controller: _costPriceCtrl,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    decoration: const InputDecoration(
                      prefixText: AppCurrency.inputPrefix,
                      hintText: '0',
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text(
                      'Used internally for margin analysis',
                      style: TextStyle(fontSize: 12, color: context.colors.textMuted),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppDimensions.md),
              _SectionCard(
                icon: Icons.inventory_2_outlined,
                title: 'Stock',
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const _FieldLabel('SKU', required: true),
                            TextFormField(
                              controller: _skuCtrl,
                              decoration: const InputDecoration(hintText: 'e.g. TSH-1042'),
                              validator: (v) => Validators.required(v, fieldName: 'SKU'),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: AppDimensions.sm + 4),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const _FieldLabel('Barcode / EAN'),
                            TextFormField(
                              controller: _barcodeCtrl,
                              decoration: const InputDecoration(hintText: 'Enter barcode'),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppDimensions.md),
                  const _FieldLabel('Stock quantity'),
                  _StockStepper(
                    value: _stock,
                    onChanged: (v) => setState(() => _stock = v),
                  ),
                  const SizedBox(height: AppDimensions.md),
                  _ToggleRow(
                    title: 'Set as default variant',
                    subtitle: 'Shown first to customers',
                    value: _isDefault,
                    onChanged: (v) => setState(() => _isDefault = v),
                  ),
                ],
              ),
              Builder(builder: (context) {
                final attrs = [...widget.variantAttributes]
                  ..sort((a, b) => a.sortOrder.compareTo(b.sortOrder));
                if (attrs.isEmpty) return const SizedBox.shrink();

                return Padding(
                  padding: const EdgeInsets.only(top: AppDimensions.md),
                  child: _SectionCard(
                    icon: Icons.tune_rounded,
                    title: 'Variant Options',
                    children: [
                      for (var i = 0; i < attrs.length; i++) ...[
                        if (i > 0) const SizedBox(height: AppDimensions.md),
                        _FieldLabel(attrs[i].name, required: attrs[i].isRequired),
                        _buildAttributeField(attrs[i]),
                      ],
                    ],
                  ),
                );
              }),
              const SizedBox(height: AppDimensions.lg),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAttributeField(FormAttribute attr) {
    if (_isOptionAttr(attr)) {
      return DropdownButtonFormField<String>(
        initialValue: _attrValues[attr.uuid],
        decoration: InputDecoration(hintText: 'Select ${attr.name.toLowerCase()}'),
        isExpanded: true,
        icon: const Icon(Icons.keyboard_arrow_down_rounded),
        borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
        items: attr.options
            .map((opt) => DropdownMenuItem(value: opt.id, child: Text(opt.value)))
            .toList(),
        onChanged: (v) => setState(() => _attrValues[attr.uuid] = v),
        validator: attr.isRequired
            ? (v) => v == null ? '${attr.name} is required' : null
            : null,
      );
    }
    return TextFormField(
      controller: _attrTextControllers[attr.uuid],
      keyboardType: attr.isNumeric
          ? const TextInputType.numberWithOptions(decimal: true)
          : TextInputType.text,
      inputFormatters: attr.isNumeric
          ? [FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*'))]
          : null,
      decoration: InputDecoration(hintText: 'Enter ${attr.name.toLowerCase()}'),
      validator: (v) {
        if (attr.isRequired && (v == null || v.trim().isEmpty)) {
          return '${attr.name} is required';
        }
        if (attr.isNumeric &&
            v != null &&
            v.trim().isNotEmpty &&
            double.tryParse(v.trim()) == null) {
          return 'Enter a valid ${attr.name.toLowerCase()}';
        }
        return null;
      },
      onChanged: (v) => _attrValues[attr.uuid] = v,
    );
  }
}

// ---------------------------------------------------------------------------
// Building blocks
// ---------------------------------------------------------------------------

class _SectionCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final List<Widget> children;

  const _SectionCard({
    required this.icon,
    required this.title,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppDimensions.md),
      decoration: BoxDecoration(
        color: context.colors.card,
        borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
                ),
                child: Icon(icon, size: 18, color: AppColors.primary),
              ),
              const SizedBox(width: AppDimensions.sm + 2),
              Text(
                title,
                style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
              ),
            ],
          ),
          const SizedBox(height: AppDimensions.md),
          ...children,
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
      padding: const EdgeInsets.only(bottom: 6),
      child: Text.rich(
        TextSpan(
          text: text,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: context.colors.textPrimary,
          ),
          children: required
              ? const [TextSpan(text: ' *', style: TextStyle(color: AppColors.error))]
              : null,
        ),
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

  Widget _stepButton(IconData icon, VoidCallback? onTap) {
    return Material(
      color: AppColors.primary.withValues(alpha: onTap == null ? 0.04 : 0.08),
      borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
      child: InkWell(
        borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
        onTap: onTap,
        child: SizedBox(
          width: 40,
          height: 40,
          child: Icon(
            icon,
            size: 20,
            color: onTap == null ? Colors.grey : AppColors.primary,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: context.colors.inputFill,
        borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
        border: Border.all(color: context.colors.border),
      ),
      child: Row(
        children: [
          _stepButton(
            Icons.remove,
            widget.value > 0 ? () => widget.onChanged(widget.value - 1) : null,
          ),
          Expanded(
            child: TextField(
              controller: _controller,
              keyboardType: TextInputType.number,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              decoration: const InputDecoration(
                filled: false,
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
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
          _stepButton(Icons.add, () => widget.onChanged(widget.value + 1)),
        ],
      ),
    );
  }
}

class _ToggleRow extends StatelessWidget {
  final String title;
  final String? subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;

  const _ToggleRow({
    required this.title,
    this.subtitle,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimensions.sm + 4,
        vertical: AppDimensions.sm,
      ),
      decoration: BoxDecoration(
        color: context.colors.inputFill,
        borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
        border: Border.all(color: context.colors.border),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
                if (subtitle != null)
                  Text(
                    subtitle!,
                    style: TextStyle(fontSize: 12, color: context.colors.textMuted),
                  ),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeThumbColor: AppColors.primary,
          ),
        ],
      ),
    );
  }
}
