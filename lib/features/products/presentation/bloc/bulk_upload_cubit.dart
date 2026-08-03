import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';

import '../../../../core/error/error_messages.dart';
import '../../data/datasources/product_remote_datasource.dart';
import '../../data/models/bulk_import_result_model.dart';
import '../../data/models/category_model.dart';
import 'bulk_upload_state.dart';

class BulkUploadCubit extends Cubit<BulkUploadState> {
  BulkUploadCubit() : super(BulkUploadState.initial());

  ProductRemoteDataSource get _dataSource =>
      GetIt.I<ProductRemoteDataSource>();

  Future<void> loadCategories() async {
    emit(state.copyWith(loadingCategories: true, categoriesError: null));
    try {
      final tree = await _dataSource.getCategoryTree();
      emit(state.copyWith(rootCategories: tree, loadingCategories: false));
    } catch (e) {
      emit(
        state.copyWith(
          loadingCategories: false,
          categoriesError: friendlyErrorMessage(e),
        ),
      );
    }
  }

  void selectCategory(CategoryModel leaf) {
    emit(state.copyWith(selectedCategory: leaf));
  }

  Future<void> downloadTemplate() async {
    final category = state.selectedCategory;
    if (category == null || state.downloadingTemplate) return;

    emit(state.copyWith(downloadingTemplate: true));
    try {
      final bytes = await _dataSource.downloadBulkTemplate(category.uuid);
      await FilePicker.saveFile(
        fileName: 'bulk-product-template-${category.slug}.xlsx',
        bytes: Uint8List.fromList(bytes),
      );
      emit(state.copyWith(downloadingTemplate: false));
    } catch (e) {
      emit(
        state.copyWith(
          downloadingTemplate: false,
          errorMessage: friendlyErrorMessage(e),
        ),
      );
    }
  }

  Future<void> pickFile() async {
    final picked = await FilePicker.pickFile(
      type: FileType.custom,
      allowedExtensions: ['xlsx'],
    );
    if (picked?.path == null) return;
    emit(
      state.copyWith(
        pickedFileName: picked!.name,
        pickedFilePath: picked.path,
        result: null,
      ),
    );
  }

  void clearFile() {
    emit(
      state.copyWith(pickedFileName: null, pickedFilePath: null, result: null),
    );
  }

  Future<void> upload() async {
    final filePath = state.pickedFilePath;
    if (filePath == null || state.uploading) return;

    emit(
      state.copyWith(uploading: true, uploadProgressPercent: 0, result: null),
    );
    try {
      final json = await _dataSource.importBulkProducts(
        filePath,
        onSendProgress: (sent, total) {
          if (total <= 0 || isClosed) return;
          emit(
            state.copyWith(
              uploadProgressPercent: ((sent / total) * 100).round(),
            ),
          );
        },
      );
      final result = BulkImportResultModel.fromJson(json);
      emit(state.copyWith(uploading: false, result: result));
    } catch (e) {
      emit(
        state.copyWith(uploading: false, errorMessage: friendlyErrorMessage(e)),
      );
    }
  }

  /// "Upload another file" — clears the picked file and result, keeps the
  /// selected category so the vendor doesn't have to re-pick it.
  void reset() {
    emit(
      state.copyWith(pickedFileName: null, pickedFilePath: null, result: null),
    );
  }

  void clearError() {
    emit(state.copyWith(errorMessage: null));
  }
}
