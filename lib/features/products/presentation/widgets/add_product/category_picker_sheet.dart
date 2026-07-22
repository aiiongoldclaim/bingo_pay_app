import 'package:flutter/material.dart';

import '../../../../../core/di/injection.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../data/datasources/product_remote_datasource.dart';
import '../../../data/models/category_model.dart';
import '../../models/product_category_data.dart';

/// Root categories for the top of the category path. The full nested tree
/// (all descendant levels) comes back in one call, so deeper levels are read
/// straight off [CategoryModel.children] without further fetches.
Future<List<CategoryModel>> fetchRootCategories() =>
    getIt<ProductRemoteDataSource>().getCategoryTree();

/// Shows [options] as a flat list and returns the picked [CategoryModel] (so
/// callers can read `.children` for the next level down), or null if
/// dismissed. A chevron marks options that have further sub-categories.
Future<CategoryModel?> showCategoryPicker(
  BuildContext context, {
  required List<CategoryModel> options,
  String? selectedId,
  String title = 'Select category',
}) {
  return showModalBottomSheet<CategoryModel>(
    context: context,
    showDragHandle: true,
    builder: (context) => SafeArea(
      child: ConstrainedBox(
        constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.7),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 4, 20, 12),
              child: Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
            ),
            Flexible(
              child: ListView(
                shrinkWrap: true,
                children: [
                  for (final cat in options)
                    ListTile(
                      title: Text(cat.name),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (cat.children.isNotEmpty)
                            Icon(Icons.chevron_right, color: context.colors.textMuted),
                          if (cat.uuid == selectedId)
                            const Icon(Icons.check, color: AppColors.primary),
                        ],
                      ),
                      onTap: () => Navigator.of(context).pop(cat),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    ),
  );
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
              trailing: option == selected ? const Icon(Icons.check, color: AppColors.primary) : null,
              onTap: () => Navigator.of(context).pop(option),
            ),
        ],
      ),
    ),
  );
}
