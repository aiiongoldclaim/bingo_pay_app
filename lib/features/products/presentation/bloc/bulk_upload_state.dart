import '../../data/models/bulk_import_result_model.dart';
import '../../data/models/category_model.dart';

const Object _unset = Object();

class BulkUploadState {
  final List<CategoryModel> rootCategories;
  final bool loadingCategories;
  final String? categoriesError;
  final CategoryModel? selectedCategory;
  final bool downloadingTemplate;
  final String? pickedFileName;
  final String? pickedFilePath;
  final bool uploading;
  final int uploadProgressPercent;
  final BulkImportResultModel? result;
  final String? errorMessage;

  const BulkUploadState({
    required this.rootCategories,
    required this.loadingCategories,
    this.categoriesError,
    this.selectedCategory,
    required this.downloadingTemplate,
    this.pickedFileName,
    this.pickedFilePath,
    required this.uploading,
    required this.uploadProgressPercent,
    this.result,
    this.errorMessage,
  });

  factory BulkUploadState.initial() => const BulkUploadState(
    rootCategories: [],
    loadingCategories: false,
    downloadingTemplate: false,
    uploading: false,
    uploadProgressPercent: 0,
  );

  /// 0-based step for the [StepIndicator]: 0 = picking a category, 1 = a
  /// file has been picked (ready to upload), 2 = a result has come back.
  int get currentStep {
    if (result != null) return 2;
    if (pickedFilePath != null) return 1;
    return 0;
  }

  BulkUploadState copyWith({
    List<CategoryModel>? rootCategories,
    bool? loadingCategories,
    Object? categoriesError = _unset,
    Object? selectedCategory = _unset,
    bool? downloadingTemplate,
    Object? pickedFileName = _unset,
    Object? pickedFilePath = _unset,
    bool? uploading,
    int? uploadProgressPercent,
    Object? result = _unset,
    Object? errorMessage = _unset,
  }) {
    return BulkUploadState(
      rootCategories: rootCategories ?? this.rootCategories,
      loadingCategories: loadingCategories ?? this.loadingCategories,
      categoriesError: identical(categoriesError, _unset)
          ? this.categoriesError
          : categoriesError as String?,
      selectedCategory: identical(selectedCategory, _unset)
          ? this.selectedCategory
          : selectedCategory as CategoryModel?,
      downloadingTemplate: downloadingTemplate ?? this.downloadingTemplate,
      pickedFileName: identical(pickedFileName, _unset)
          ? this.pickedFileName
          : pickedFileName as String?,
      pickedFilePath: identical(pickedFilePath, _unset)
          ? this.pickedFilePath
          : pickedFilePath as String?,
      uploading: uploading ?? this.uploading,
      uploadProgressPercent:
          uploadProgressPercent ?? this.uploadProgressPercent,
      result: identical(result, _unset)
          ? this.result
          : result as BulkImportResultModel?,
      errorMessage: identical(errorMessage, _unset)
          ? this.errorMessage
          : errorMessage as String?,
    );
  }
}
