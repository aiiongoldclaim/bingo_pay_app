import 'package:flutter/material.dart';

import '../../../../../core/di/injection.dart';
import '../../../data/datasources/product_remote_datasource.dart';
import '../../../data/models/category_model.dart';
import '../../models/product_category_data.dart';
import 'fetch_option_picker.dart';

/// Returns the full [CategoryModel] so caller can access children.
Future<CategoryModel?> showParentCategoryPicker(
  BuildContext context, {
  String? selectedId,
}) {
  return showModalBottomSheet<CategoryModel>(
    context: context,
    showDragHandle: true,
    builder: (context) => SafeArea(
      child: _ParentCategoryPickerContent(selectedId: selectedId),
    ),
  );
}

class _ParentCategoryPickerContent extends StatefulWidget {
  final String? selectedId;
  const _ParentCategoryPickerContent({this.selectedId});

  @override
  State<_ParentCategoryPickerContent> createState() => _ParentCategoryPickerContentState();
}

class _ParentCategoryPickerContentState extends State<_ParentCategoryPickerContent> {
  late final Future<List<CategoryModel>> _future =
      getIt<ProductRemoteDataSource>().getCategoryTree();

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.7),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Padding(
            padding: EdgeInsets.fromLTRB(20, 4, 20, 12),
            child: Text('Select category', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
          ),
          FutureBuilder<List<CategoryModel>>(
            future: _future,
            builder: (context, snapshot) {
              if (!snapshot.hasData && !snapshot.hasError) {
                return const Padding(
                  padding: EdgeInsets.symmetric(vertical: 32),
                  child: Center(child: CircularProgressIndicator()),
                );
              }
              if (snapshot.hasError) {
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
                  child: Text('Failed to load: ${snapshot.error}'),
                );
              }
              final categories = snapshot.data ?? [];
              return Flexible(
                child: ListView(
                  shrinkWrap: true,
                  children: [
                    for (final cat in categories)
                      ListTile(
                        title: Text(cat.name),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (cat.children.isNotEmpty)
                              const Icon(Icons.chevron_right, color: Colors.grey),
                            if (cat.uuid == widget.selectedId)
                              const Icon(Icons.check, color: Colors.blue),
                          ],
                        ),
                        onTap: () => Navigator.of(context).pop(cat),
                      ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

Future<({String id, String name})?> showSubCategoryPicker(
  BuildContext context, {
  required List<CategoryModel> children,
  String? selectedId,
}) {
  return showFetchOptionPickerById<CategoryModel>(
    context,
    title: 'Select sub-category',
    fetch: () async => children,
    nameOf: (c) => c.name,
    idOf: (c) => c.uuid,
    selectedId: selectedId,
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
              trailing: option == selected ? const Icon(Icons.check, color: Colors.blue) : null,
              onTap: () => Navigator.of(context).pop(option),
            ),
        ],
      ),
    ),
  );
}
