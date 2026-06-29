import 'package:flutter/material.dart';

import '../../../../../core/theme/app_dimensions.dart';
import '../../../data/models/category_form_model.dart';
import '../../models/product_form_data.dart';

class SpecificationsStep extends StatefulWidget {
  final GlobalKey<FormState> formKey;
  final ProductDraft draft;
  final List<FormAttribute> attributes;

  const SpecificationsStep({
    super.key,
    required this.formKey,
    required this.draft,
    required this.attributes,
  });

  @override
  State<SpecificationsStep> createState() => _SpecificationsStepState();
}

class _SpecificationsStepState extends State<SpecificationsStep> {
  final Map<String, TextEditingController> _textControllers = {};

  @override
  void initState() {
    super.initState();
    _initControllers();
  }

  @override
  void didUpdateWidget(SpecificationsStep oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.attributes != widget.attributes) {
      _initControllers();
    }
  }

  void _initControllers() {
    for (final attr in widget.attributes) {
      if (attr.fieldType != 'SELECT') {
        _textControllers.putIfAbsent(
          attr.uuid,
          () => TextEditingController(text: widget.draft.specifications[attr.uuid] ?? ''),
        );
      }
    }
  }

  @override
  void dispose() {
    for (final c in _textControllers.values) c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final attrs = [...widget.attributes]..sort((a, b) => a.sortOrder.compareTo(b.sortOrder));

    if (attrs.isEmpty) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 48),
        child: Center(
          child: Text(
            'No specifications required for this category.',
            style: TextStyle(color: Colors.grey),
          ),
        ),
      );
    }

    return Form(
      key: widget.formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (final attr in attrs) ...[
            _FieldLabel(attr.name, required: attr.isRequired),
            if (attr.fieldType == 'SELECT' && attr.options.isNotEmpty)
              DropdownButtonFormField<String>(
                value: widget.draft.specifications[attr.uuid]?.isEmpty == false
                    ? widget.draft.specifications[attr.uuid]
                    : null,
                decoration: InputDecoration(hintText: 'Select ${attr.name.toLowerCase()}'),
                isExpanded: true,
                items: attr.options
                    .map((opt) => DropdownMenuItem(value: opt.value, child: Text(opt.value)))
                    .toList(),
                onChanged: (v) {
                  if (v != null) setState(() => widget.draft.specifications[attr.uuid] = v);
                },
                validator: attr.isRequired
                    ? (v) => (v == null || v.isEmpty) ? '${attr.name} is required' : null
                    : null,
              )
            else
              TextFormField(
                controller: _textControllers[attr.uuid],
                decoration: InputDecoration(hintText: 'Enter ${attr.name.toLowerCase()}'),
                validator: attr.isRequired
                    ? (v) => (v == null || v.trim().isEmpty) ? '${attr.name} is required' : null
                    : null,
                onChanged: (v) => widget.draft.specifications[attr.uuid] = v,
              ),
            const SizedBox(height: AppDimensions.lg),
          ],
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
