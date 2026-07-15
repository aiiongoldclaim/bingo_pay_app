import 'package:flutter/material.dart';

import '../../../../../core/di/injection.dart';
import '../../../data/datasources/product_remote_datasource.dart';
import '../../../data/models/brand_model.dart';
import 'fetch_option_picker.dart';

Future<String?> showBrandPicker(BuildContext context, {String? selected}) {
  return showFetchOptionPicker<BrandModel>(
    context,
    title: 'Select brand',
    fetch: () => getIt<ProductRemoteDataSource>().getBrands(),
    nameOf: (brand) => brand.name,
    selected: selected,
  );
}

Future<({String id, String name})?> showBrandPickerById(
  BuildContext context, {
  String? selectedId,
}) {
  return showFetchOptionPickerById<BrandModel>(
    context,
    title: 'Select brand',
    fetch: () => getIt<ProductRemoteDataSource>().getBrands(),
    nameOf: (b) => b.name,
    idOf: (b) => b.uuid,
    selectedId: selectedId,
  );
}
