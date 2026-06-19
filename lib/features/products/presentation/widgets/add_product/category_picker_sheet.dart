import 'package:flutter/material.dart';

import '../../models/product_category_data.dart';

Future<String?> showCategoryPicker(BuildContext context, {String? selected}) {
  return _showOptionPicker(context, title: 'Select category', options: ProductCategoryData.categories.keys.toList(), selected: selected);
}

Future<String?> showSubCategoryPicker(BuildContext context, {required String category, String? selected}) {
  final options = ProductCategoryData.categories[category] ?? const [];
  return _showOptionPicker(context, title: 'Select sub-category', options: options, selected: selected);
}

Future<String?> showGstSlabPicker(BuildContext context, {String? selected}) {
  return _showOptionPicker(context, title: 'Select GST slab', options: ProductCategoryData.gstSlabs, selected: selected);
}

Future<String?> _showOptionPicker(
  BuildContext context, {
  required String title,
  required List<String> options,
  String? selected,
}) {
  return showModalBottomSheet<String>(
    context: context,
    showDragHandle: true,
    builder: (context) => SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 4, 20, 12),
            child: Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
          ),
          for (final option in options)
            ListTile(
              title: Text(option),
              trailing: option == selected ? const Icon(Icons.check, color: Colors.blue) : null,
              onTap: () => Navigator.of(context).pop(option),
            ),
        ],
      ),
    ),
  );
}
