# Bulk Product Upload (Vendor App) Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Let vendors bulk-create products in `the_vaults_vendor` by downloading a category-specific Excel template, filling it in, and uploading it — reusing the backend bulk-import API that already exists.

**Architecture:** A dedicated `BulkUploadCubit` (single state object + `copyWith`) drives a new single-scroll `BulkUploadScreen` with three cards (category/template, upload, results), reached via a new overflow-menu entry on the existing Products screen. Two new `ProductRemoteDataSource` methods talk to the backend's `products/bulk/template` and `products/bulk/import` endpoints; the backend's `status`/`report` endpoints are stubs and are not used.

**Tech Stack:** Flutter, `flutter_bloc` (Cubit), `dio`, `go_router`, `get_it`, `file_picker`.

## Global Constraints

- Dart SDK `^3.10.8`, `flutter_bloc: ^9.1.1`, `go_router: ^17.3.0`, `get_it: ^9.2.1`, `dio: ^5.10.0`, `file_picker: ^12.0.0-beta.7` — all already in `pubspec.yaml`; **no new dependencies are added**.
- No backend changes. `the_vaults_backend` is read-only reference material.
- File type is `.xlsx` only — no `.xls`/`.csv` support.
- No polling of the backend's `status`/`report` endpoints (confirmed stubs, out of scope).
- No new automated test suite: `test/features/products` does not exist in this project today, and the approved spec (`docs/superpowers/specs/2026-08-03-bulk-product-upload-design.md`) explicitly calls for manual verification through the running app instead of introducing one unilaterally. Each task's verification step is `flutter analyze` (static correctness) rather than `flutter test`; the final task is a full manual run-through.
- Follow existing code conventions exactly: `GetIt.I<T>()` resolved inside Cubits (not constructor injection, per `VendorProductsCubit`), `AppSnackbar.showError(context, friendlyErrorMessage(e))` for network errors, `AppButton`/`AppDimensions`/`AppTextStyles`/`context.colors` for styling, `_unwrapObject(response.data)` for JSON POST responses in `ProductRemoteDataSourceImpl`.

Every task's requirements implicitly include the above.

---

### Task 1: Bulk-import result models

**Files:**
- Create: `lib/features/products/data/models/bulk_import_result_model.dart`

**Interfaces:**
- Consumes: nothing (pure Dart, no Flutter/dio dependency).
- Produces: `BulkImportResultModel.fromJson(Map<String, dynamic>)`, `BulkImportResultModel.hasErrors` (bool), `.totalRows` (int), `.validCount`/`.invalidCount` (int?, only present on the has-errors branch), `.invalidRows` (`List<BulkInvalidRow>`), `.jobUuid`/`.message` (String?). `BulkInvalidRow.rowNumber` (int), `.errors` (`List<BulkRowError>`). `BulkRowError.field`/`.message` (String). Later tasks (Cubit, results card) depend on these exact names.

The backend's two response shapes for `POST /products/bulk/import` share almost no fields — the has-errors branch returns `{validRows, invalidRows, totalRows, validCount, invalidCount, hasErrors}`, the success/queued branch returns only `{success, jobUuid, status, totalRows, message}` (see `docs/superpowers/specs/2026-08-03-bulk-product-upload-design.md` for the full confirmed shapes). Every branch-specific field must be nullable/defaulted, not required.

- [ ] **Step 1: Write the model file**

```dart
class BulkRowError {
  final String field;
  final String message;

  const BulkRowError({required this.field, required this.message});

  factory BulkRowError.fromJson(Map<String, dynamic> json) {
    return BulkRowError(
      field: json['field']?.toString() ?? '',
      message: json['message']?.toString() ?? '',
    );
  }
}

class BulkInvalidRow {
  final int rowNumber;
  final List<BulkRowError> errors;

  const BulkInvalidRow({required this.rowNumber, required this.errors});

  factory BulkInvalidRow.fromJson(Map<String, dynamic> json) {
    final errorsJson = json['errors'] as List? ?? [];
    return BulkInvalidRow(
      rowNumber: (json['rowNumber'] as num?)?.toInt() ?? 0,
      errors: errorsJson
          .whereType<Map>()
          .map(
            (e) => BulkRowError.fromJson(
              e.map((k, v) => MapEntry(k.toString(), v)),
            ),
          )
          .toList(),
    );
  }
}

class BulkImportResultModel {
  final int totalRows;
  final int? validCount;
  final int? invalidCount;
  final bool hasErrors;
  final List<BulkInvalidRow> invalidRows;
  final String? jobUuid;
  final String? message;

  const BulkImportResultModel({
    required this.totalRows,
    this.validCount,
    this.invalidCount,
    required this.hasErrors,
    required this.invalidRows,
    this.jobUuid,
    this.message,
  });

  factory BulkImportResultModel.fromJson(Map<String, dynamic> json) {
    final invalidRowsJson = json['invalidRows'] as List? ?? [];
    return BulkImportResultModel(
      totalRows: (json['totalRows'] as num?)?.toInt() ?? 0,
      validCount: (json['validCount'] as num?)?.toInt(),
      invalidCount: (json['invalidCount'] as num?)?.toInt(),
      hasErrors: json['hasErrors'] as bool? ?? false,
      invalidRows: invalidRowsJson
          .whereType<Map>()
          .map(
            (e) => BulkInvalidRow.fromJson(
              e.map((k, v) => MapEntry(k.toString(), v)),
            ),
          )
          .toList(),
      jobUuid: json['jobUuid']?.toString(),
      message: json['message']?.toString(),
    );
  }
}
```

- [ ] **Step 2: Verify with the analyzer**

Run: `cd the_vaults_vendor && flutter analyze lib/features/products/data/models/bulk_import_result_model.dart`
Expected: `No issues found!`

- [ ] **Step 3: Commit**

```bash
git add lib/features/products/data/models/bulk_import_result_model.dart
git commit -m "feat: add BulkImportResultModel for bulk product upload"
```

---

### Task 2: API endpoints + datasource methods

**Files:**
- Modify: `lib/core/api/api_endpoints.dart`
- Modify: `lib/features/products/data/datasources/product_remote_datasource.dart`

**Interfaces:**
- Consumes: `BulkImportResultModel` is NOT used here — this datasource returns raw `Map<String, dynamic>`/`List<int>`, matching every other method in the file (parsing into models happens one layer up, same as `Product.fromApi` parses `getProducts()`'s raw output).
- Produces: `ProductRemoteDataSource.downloadBulkTemplate(String categoryUuid) -> Future<List<int>>` and `ProductRemoteDataSource.importBulkProducts(String filePath, {void Function(int sent, int total)? onSendProgress}) -> Future<Map<String, dynamic>>`. Task 4 (Cubit) calls both by these exact names/signatures.

- [ ] **Step 1: Add the two endpoint constants**

In `lib/core/api/api_endpoints.dart`, add these two lines directly after the existing `static const String attributeOptions = '/api/v1/attribute-options';` line:

```dart
  static const String bulkImportTemplate = '/api/v1/products/bulk/template';
  static const String bulkImportUpload = '/api/v1/products/bulk/import';
```

- [ ] **Step 2: Add the two methods to the datasource interface**

In `lib/features/products/data/datasources/product_remote_datasource.dart`, add to the `abstract interface class ProductRemoteDataSource` block, directly after the existing `Future<Map<String, dynamic>> resubmitProduct(String productUuid);` line:

```dart
  Future<List<int>> downloadBulkTemplate(String categoryUuid);
  Future<Map<String, dynamic>> importBulkProducts(
    String filePath, {
    void Function(int sent, int total)? onSendProgress,
  });
```

- [ ] **Step 3: Implement both methods**

In the same file, add to the `ProductRemoteDataSourceImpl` class, directly after the existing `resubmitProduct` implementation (before the closing brace of the class):

```dart
  @override
  Future<List<int>> downloadBulkTemplate(String categoryUuid) async {
    final response = await _apiClient.dio.get<List<int>>(
      ApiEndpoints.bulkImportTemplate,
      queryParameters: {'categoryUuid': categoryUuid},
      options: Options(responseType: ResponseType.bytes),
    );
    return response.data ?? [];
  }

  @override
  Future<Map<String, dynamic>> importBulkProducts(
    String filePath, {
    void Function(int sent, int total)? onSendProgress,
  }) async {
    final formData = FormData.fromMap({
      'file': await MultipartFile.fromFile(filePath),
    });
    final response = await _apiClient.dio.post(
      ApiEndpoints.bulkImportUpload,
      data: formData,
      onSendProgress: onSendProgress,
      options: Options(receiveTimeout: const Duration(seconds: 120)),
    );
    return _unwrapObject(response.data);
  }
```

No new imports needed — `Options`, `ResponseType`, `FormData`, `MultipartFile` all come from `package:dio/dio.dart`, already imported at the top of this file.

- [ ] **Step 4: Verify with the analyzer**

Run: `cd the_vaults_vendor && flutter analyze lib/core/api/api_endpoints.dart lib/features/products/data/datasources/product_remote_datasource.dart`
Expected: `No issues found!`

- [ ] **Step 5: Commit**

```bash
git add lib/core/api/api_endpoints.dart lib/features/products/data/datasources/product_remote_datasource.dart
git commit -m "feat: add bulk-import template/upload endpoints to ProductRemoteDataSource"
```

---

### Task 3: BulkUploadState

**Files:**
- Create: `lib/features/products/presentation/bloc/bulk_upload_state.dart`

**Interfaces:**
- Consumes: `CategoryModel` (`lib/features/products/data/models/category_model.dart`, existing), `BulkImportResultModel` (Task 1).
- Produces: `BulkUploadState` with fields `rootCategories` (`List<CategoryModel>`), `loadingCategories` (bool), `categoriesError` (String?), `selectedCategory` (CategoryModel?), `downloadingTemplate` (bool), `pickedFileName`/`pickedFilePath` (String?), `uploading` (bool), `uploadProgressPercent` (int), `result` (BulkImportResultModel?), `errorMessage` (String?); `.currentStep` getter (int, 0/1/2); `.copyWith(...)`; `BulkUploadState.initial()`. Task 4 (Cubit) and Tasks 5–7 (card widgets) read/set these exact field names.

Several fields (`categoriesError`, `selectedCategory`, `pickedFileName`, `pickedFilePath`, `result`, `errorMessage`) must be explicitly settable back to `null` by `copyWith` (e.g. `reset()` clears `pickedFilePath`/`result` while keeping everything else) — a plain `field ?? this.field` pattern can never null out a field once set, so this uses the standard "sentinel object" `copyWith` pattern below.

- [ ] **Step 1: Write the state file**

```dart
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
```

- [ ] **Step 2: Verify with the analyzer**

Run: `cd the_vaults_vendor && flutter analyze lib/features/products/presentation/bloc/bulk_upload_state.dart`
Expected: `No issues found!`

- [ ] **Step 3: Commit**

```bash
git add lib/features/products/presentation/bloc/bulk_upload_state.dart
git commit -m "feat: add BulkUploadState"
```

---

### Task 4: BulkUploadCubit

**Files:**
- Create: `lib/features/products/presentation/bloc/bulk_upload_cubit.dart`

**Interfaces:**
- Consumes: `ProductRemoteDataSource.getCategoryTree/downloadBulkTemplate/importBulkProducts` (Task 2), `BulkUploadState`/`.copyWith`/`.initial()` (Task 3), `BulkImportResultModel.fromJson` (Task 1), `friendlyErrorMessage` (existing, `core/error/error_messages.dart`), `FilePicker.pickFile`/`FilePicker.saveFile` (`package:file_picker/file_picker.dart`, already a dependency).
- Produces: `BulkUploadCubit` with methods `loadCategories()`, `selectCategory(CategoryModel)`, `downloadTemplate()`, `pickFile()`, `clearFile()`, `upload()`, `reset()`, `clearError()`. Tasks 5–8 (card widgets, screen) call these exact method names via `context.read<BulkUploadCubit>()`.

- [ ] **Step 1: Write the cubit file**

```dart
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
```

`isClosed` is `Cubit`'s own property; guarding with it before `emit` in the `onSendProgress` callback avoids emitting after the cubit's `BlocProvider` has been disposed (e.g. the vendor backs out mid-upload) — `Cubit.emit` is otherwise already a safe no-op when closed, but the guard avoids doing the `copyWith` allocation pointlessly.

- [ ] **Step 2: Verify with the analyzer**

Run: `cd the_vaults_vendor && flutter analyze lib/features/products/presentation/bloc/bulk_upload_cubit.dart`
Expected: `No issues found!`

- [ ] **Step 3: Commit**

```bash
git add lib/features/products/presentation/bloc/bulk_upload_cubit.dart
git commit -m "feat: add BulkUploadCubit"
```

---

### Task 5: Shared section-card wrapper + category/template card

**Files:**
- Create: `lib/features/products/presentation/widgets/bulk_upload/bulk_upload_section_card.dart`
- Create: `lib/features/products/presentation/widgets/bulk_upload/category_template_card.dart`

**Interfaces:**
- Consumes: `BulkUploadCubit`/`BulkUploadState` (Tasks 3–4), `showCategoryPicker`/`fetchRootCategories` (existing, `lib/features/products/presentation/widgets/add_product/category_picker_sheet.dart`), `CategoryModel` (existing).
- Produces: `BulkUploadSectionCard({required Widget child})` — a reusable styled container, reused by Tasks 6 and 7. `CategoryTemplateCard` (no constructor params — reads everything from `context.read<BulkUploadCubit>()`), consumed by Task 8's screen.

- [ ] **Step 1: Write the shared card wrapper**

```dart
import 'package:flutter/material.dart';

import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_dimensions.dart';

/// A styled container shared by the bulk-upload screen's three sections
/// (category/template, upload, results), matching the card look
/// [AddProductScreen]'s bottom bar already uses (`context.colors.card` +
/// `context.colors.shadow`).
class BulkUploadSectionCard extends StatelessWidget {
  final Widget child;

  const BulkUploadSectionCard({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppDimensions.md),
      margin: const EdgeInsets.only(bottom: AppDimensions.md),
      decoration: BoxDecoration(
        color: context.colors.card,
        borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
        boxShadow: [
          BoxShadow(
            color: context.colors.shadow,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: child,
    );
  }
}
```

- [ ] **Step 2: Write the category/template card**

```dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_dimensions.dart';
import '../../../../../core/theme/app_text_styles.dart';
import '../../../../../core/widgets/app_button.dart';
import '../../../data/models/category_model.dart';
import '../../bloc/bulk_upload_cubit.dart';
import '../../bloc/bulk_upload_state.dart';
import '../add_product/category_picker_sheet.dart';
import 'bulk_upload_section_card.dart';

class CategoryTemplateCard extends StatelessWidget {
  const CategoryTemplateCard({super.key});

  /// Drills down through the category tree — same pattern
  /// [AddProductScreen] uses — until a leaf (no children) is picked, since
  /// only leaf categories carry a full bulk-import template.
  Future<void> _pickCategory(BuildContext context) async {
    final cubit = context.read<BulkUploadCubit>();
    var options = cubit.state.rootCategories;
    CategoryModel? picked;
    while (true) {
      if (!context.mounted) return;
      final choice = await showCategoryPicker(
        context,
        options: options,
        selectedId: picked?.uuid,
        title: 'Select category',
      );
      if (choice == null) return;
      if (choice.children.isEmpty) {
        picked = choice;
        break;
      }
      options = choice.children;
    }
    cubit.selectCategory(picked);
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<BulkUploadCubit, BulkUploadState>(
      buildWhen: (prev, curr) =>
          prev.rootCategories != curr.rootCategories ||
          prev.loadingCategories != curr.loadingCategories ||
          prev.categoriesError != curr.categoriesError ||
          prev.selectedCategory != curr.selectedCategory ||
          prev.downloadingTemplate != curr.downloadingTemplate,
      builder: (context, state) {
        return BulkUploadSectionCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '1. Choose a category & get the template',
                style: AppTextStyles.titleLarge.copyWith(fontSize: 16),
              ),
              const SizedBox(height: AppDimensions.sm),
              if (state.loadingCategories)
                const Center(child: CircularProgressIndicator())
              else if (state.categoriesError != null) ...[
                Text(
                  state.categoriesError!,
                  style: const TextStyle(color: AppColors.error, fontSize: 13),
                ),
                const SizedBox(height: AppDimensions.sm),
                OutlinedButton(
                  onPressed: () =>
                      context.read<BulkUploadCubit>().loadCategories(),
                  child: const Text('Retry'),
                ),
              ] else ...[
                InkWell(
                  onTap: () => _pickCategory(context),
                  borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
                  child: Container(
                    padding: const EdgeInsets.all(AppDimensions.md),
                    decoration: BoxDecoration(
                      border: Border.all(color: context.colors.border),
                      borderRadius: BorderRadius.circular(
                        AppDimensions.radiusMd,
                      ),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            state.selectedCategory?.name ??
                                'Select a category',
                            style: AppTextStyles.bodyMedium.copyWith(
                              color: state.selectedCategory == null
                                  ? context.colors.textMuted
                                  : context.colors.textPrimary,
                            ),
                          ),
                        ),
                        const Icon(Icons.chevron_right),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: AppDimensions.md),
                AppButton(
                  label: 'Download template',
                  isLoading: state.downloadingTemplate,
                  onPressed: state.selectedCategory == null
                      ? null
                      : () =>
                            context.read<BulkUploadCubit>().downloadTemplate(),
                ),
              ],
            ],
          ),
        );
      },
    );
  }
}
```

- [ ] **Step 3: Verify with the analyzer**

Run: `cd the_vaults_vendor && flutter analyze lib/features/products/presentation/widgets/bulk_upload/`
Expected: `No issues found!`

- [ ] **Step 4: Commit**

```bash
git add lib/features/products/presentation/widgets/bulk_upload/bulk_upload_section_card.dart lib/features/products/presentation/widgets/bulk_upload/category_template_card.dart
git commit -m "feat: add bulk-upload section card wrapper and category/template card"
```

---

### Task 6: Upload-file card

**Files:**
- Create: `lib/features/products/presentation/widgets/bulk_upload/upload_file_card.dart`

**Interfaces:**
- Consumes: `BulkUploadSectionCard` (Task 5), `BulkUploadCubit`/`BulkUploadState` (Tasks 3–4).
- Produces: `UploadFileCard` (no constructor params), consumed by Task 8's screen.

- [ ] **Step 1: Write the upload card**

```dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_dimensions.dart';
import '../../../../../core/theme/app_text_styles.dart';
import '../../../../../core/widgets/app_button.dart';
import '../../bloc/bulk_upload_cubit.dart';
import '../../bloc/bulk_upload_state.dart';
import 'bulk_upload_section_card.dart';

class UploadFileCard extends StatelessWidget {
  const UploadFileCard({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<BulkUploadCubit, BulkUploadState>(
      buildWhen: (prev, curr) =>
          prev.pickedFileName != curr.pickedFileName ||
          prev.pickedFilePath != curr.pickedFilePath ||
          prev.uploading != curr.uploading ||
          prev.uploadProgressPercent != curr.uploadProgressPercent,
      builder: (context, state) {
        return BulkUploadSectionCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '2. Upload the filled template',
                style: AppTextStyles.titleLarge.copyWith(fontSize: 16),
              ),
              const SizedBox(height: AppDimensions.sm),
              InkWell(
                onTap: state.uploading
                    ? null
                    : () => context.read<BulkUploadCubit>().pickFile(),
                borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(AppDimensions.md),
                  decoration: BoxDecoration(
                    border: Border.all(color: context.colors.border),
                    borderRadius: BorderRadius.circular(
                      AppDimensions.radiusMd,
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.upload_file, color: context.colors.textMuted),
                      const SizedBox(width: AppDimensions.sm),
                      Expanded(
                        child: Text(
                          state.pickedFileName ?? 'Tap to choose a .xlsx file',
                          style: AppTextStyles.bodyMedium.copyWith(
                            color: state.pickedFileName == null
                                ? context.colors.textMuted
                                : context.colors.textPrimary,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              if (state.uploading) ...[
                const SizedBox(height: AppDimensions.md),
                LinearProgressIndicator(
                  value: state.uploadProgressPercent / 100,
                ),
                const SizedBox(height: AppDimensions.xs),
                Text(
                  'Uploading… ${state.uploadProgressPercent}%',
                  style: AppTextStyles.labelMedium,
                ),
              ],
              const SizedBox(height: AppDimensions.md),
              AppButton(
                label: 'Upload & validate',
                isLoading: state.uploading,
                onPressed: state.pickedFilePath == null || state.uploading
                    ? null
                    : () => context.read<BulkUploadCubit>().upload(),
              ),
            ],
          ),
        );
      },
    );
  }
}
```

- [ ] **Step 2: Verify with the analyzer**

Run: `cd the_vaults_vendor && flutter analyze lib/features/products/presentation/widgets/bulk_upload/upload_file_card.dart`
Expected: `No issues found!`

- [ ] **Step 3: Commit**

```bash
git add lib/features/products/presentation/widgets/bulk_upload/upload_file_card.dart
git commit -m "feat: add bulk-upload upload-file card"
```

---

### Task 7: Results card

**Files:**
- Create: `lib/features/products/presentation/widgets/bulk_upload/result_card.dart`

**Interfaces:**
- Consumes: `BulkUploadSectionCard` (Task 5), `BulkUploadCubit`/`BulkUploadState` (Tasks 3–4), `BulkImportResultModel`/`BulkInvalidRow` (Task 1).
- Produces: `ResultCard` (no constructor params), consumed by Task 8's screen.

- [ ] **Step 1: Write the results card**

```dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_dimensions.dart';
import '../../../../../core/theme/app_text_styles.dart';
import '../../../../../core/widgets/app_button.dart';
import '../../../data/models/bulk_import_result_model.dart';
import '../../bloc/bulk_upload_cubit.dart';
import '../../bloc/bulk_upload_state.dart';
import 'bulk_upload_section_card.dart';

class ResultCard extends StatelessWidget {
  const ResultCard({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<BulkUploadCubit, BulkUploadState>(
      buildWhen: (prev, curr) => prev.result != curr.result,
      builder: (context, state) {
        final result = state.result;
        if (result == null) return const SizedBox.shrink();

        return BulkUploadSectionCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '3. Results',
                style: AppTextStyles.titleLarge.copyWith(fontSize: 16),
              ),
              const SizedBox(height: AppDimensions.md),
              if (result.hasErrors)
                ..._buildErrorState(context, result)
              else
                ..._buildSuccessState(result),
              const SizedBox(height: AppDimensions.md),
              Row(
                children: [
                  Expanded(
                    child: AppButton(
                      label: 'Upload another file',
                      variant: AppButtonVariant.outlined,
                      onPressed: () =>
                          context.read<BulkUploadCubit>().reset(),
                    ),
                  ),
                  const SizedBox(width: AppDimensions.md),
                  Expanded(
                    child: AppButton(
                      label: 'View products',
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  List<Widget> _buildSuccessState(BulkImportResultModel result) {
    return [
      Container(
        padding: const EdgeInsets.all(AppDimensions.md),
        decoration: BoxDecoration(
          color: AppColors.successTint,
          borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
        ),
        child: Row(
          children: [
            const Icon(
              Icons.check_circle_outline_rounded,
              color: AppColors.success,
            ),
            const SizedBox(width: AppDimensions.sm),
            Expanded(
              child: Text(
                '${result.totalRows} product(s) queued for import. '
                "You'll get an email when it's done — check My Products afterward.",
                style: const TextStyle(color: AppColors.success, fontSize: 13),
              ),
            ),
          ],
        ),
      ),
    ];
  }

  List<Widget> _buildErrorState(
    BuildContext context,
    BulkImportResultModel result,
  ) {
    return [
      Row(
        children: [
          Expanded(
            child: _StatTile(label: 'Total rows', value: '${result.totalRows}'),
          ),
          const SizedBox(width: AppDimensions.sm),
          Expanded(
            child: _StatTile(
              label: 'Valid',
              value: '${result.validCount ?? 0}',
              color: AppColors.success,
            ),
          ),
          const SizedBox(width: AppDimensions.sm),
          Expanded(
            child: _StatTile(
              label: 'Invalid',
              value: '${result.invalidCount ?? result.invalidRows.length}',
              color: AppColors.error,
            ),
          ),
        ],
      ),
      const SizedBox(height: AppDimensions.md),
      Container(
        padding: const EdgeInsets.all(AppDimensions.md),
        decoration: BoxDecoration(
          color: AppColors.errorTint,
          borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
        ),
        child: Text(
          '${result.invalidRows.length} row(s) need fixing — no products '
          'were imported yet. Fix the errors below and re-upload.',
          style: const TextStyle(color: AppColors.error, fontSize: 13),
        ),
      ),
      const SizedBox(height: AppDimensions.md),
      for (final row in result.invalidRows) _InvalidRowTile(row: row),
    ];
  }
}

class _StatTile extends StatelessWidget {
  final String label;
  final String value;
  final Color? color;

  const _StatTile({required this.label, required this.value, this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppDimensions.sm),
      decoration: BoxDecoration(
        color: context.colors.background,
        borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: color ?? context.colors.textPrimary,
            ),
          ),
          const SizedBox(height: AppDimensions.xs),
          Text(
            label,
            style: AppTextStyles.labelMedium.copyWith(
              color: context.colors.textMuted,
            ),
          ),
        ],
      ),
    );
  }
}

class _InvalidRowTile extends StatefulWidget {
  final BulkInvalidRow row;

  const _InvalidRowTile({required this.row});

  @override
  State<_InvalidRowTile> createState() => _InvalidRowTileState();
}

class _InvalidRowTileState extends State<_InvalidRowTile> {
  bool _open = true;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppDimensions.sm),
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.errorTint),
        borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          InkWell(
            onTap: () => setState(() => _open = !_open),
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppDimensions.md,
                vertical: AppDimensions.sm,
              ),
              child: Row(
                children: [
                  Icon(_open ? Icons.expand_less : Icons.expand_more, size: 18),
                  const SizedBox(width: AppDimensions.xs),
                  Text(
                    'Row ${widget.row.rowNumber}',
                    style: AppTextStyles.bodyMedium.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(width: AppDimensions.xs),
                  Text(
                    '(${widget.row.errors.length} '
                    '${widget.row.errors.length == 1 ? 'error' : 'errors'})',
                    style: AppTextStyles.labelMedium.copyWith(
                      color: AppColors.error,
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (_open)
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppDimensions.md,
                0,
                AppDimensions.md,
                AppDimensions.sm,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  for (final err in widget.row.errors)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 4),
                      child: Text(
                        '${err.field}: ${err.message}',
                        style: AppTextStyles.bodyMedium.copyWith(fontSize: 13),
                      ),
                    ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
```

- [ ] **Step 2: Verify with the analyzer**

Run: `cd the_vaults_vendor && flutter analyze lib/features/products/presentation/widgets/bulk_upload/result_card.dart`
Expected: `No issues found!`

- [ ] **Step 3: Commit**

```bash
git add lib/features/products/presentation/widgets/bulk_upload/result_card.dart
git commit -m "feat: add bulk-upload results card"
```

---

### Task 8: BulkUploadScreen + routing

**Files:**
- Create: `lib/features/products/presentation/screens/bulk_upload_screen.dart`
- Modify: `lib/core/router/app_routes.dart`
- Modify: `lib/core/router/app_router.dart`

**Interfaces:**
- Consumes: `BulkUploadCubit` (Task 4), `CategoryTemplateCard` (Task 5), `UploadFileCard` (Task 6), `ResultCard` (Task 7), `StepIndicator` (existing, `core/widgets/step_indicator.dart`), `AppSnackbar.showError` (existing).
- Produces: `BulkUploadScreen` widget and `AppRoutes.vendorProductBulkUpload` route string. Task 9 (entry point) pushes this exact route.

- [ ] **Step 1: Write the screen**

```dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../../core/widgets/app_snackbar.dart';
import '../../../../core/widgets/step_indicator.dart';
import '../bloc/bulk_upload_cubit.dart';
import '../bloc/bulk_upload_state.dart';
import '../widgets/bulk_upload/category_template_card.dart';
import '../widgets/bulk_upload/result_card.dart';
import '../widgets/bulk_upload/upload_file_card.dart';

class BulkUploadScreen extends StatelessWidget {
  const BulkUploadScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => BulkUploadCubit()..loadCategories(),
      child: const _BulkUploadView(),
    );
  }
}

class _BulkUploadView extends StatelessWidget {
  const _BulkUploadView();

  @override
  Widget build(BuildContext context) {
    return BlocListener<BulkUploadCubit, BulkUploadState>(
      listenWhen: (prev, curr) => prev.errorMessage != curr.errorMessage,
      listener: (context, state) {
        if (state.errorMessage != null) {
          AppSnackbar.showError(context, state.errorMessage!);
          context.read<BulkUploadCubit>().clearError();
        }
      },
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: AppColors.primary,
          elevation: 0,
          iconTheme: const IconThemeData(color: Colors.white),
          title: const Text(
            'Bulk Upload Products',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(AppDimensions.md),
          child: Column(
            children: [
              BlocBuilder<BulkUploadCubit, BulkUploadState>(
                buildWhen: (prev, curr) => prev.currentStep != curr.currentStep,
                builder: (context, state) => Padding(
                  padding: const EdgeInsets.only(bottom: AppDimensions.md),
                  child: StepIndicator(
                    currentStep: state.currentStep,
                    totalSteps: 3,
                    stepLabels: const ['Category', 'Upload', 'Results'],
                  ),
                ),
              ),
              const CategoryTemplateCard(),
              const UploadFileCard(),
              const ResultCard(),
            ],
          ),
        ),
      ),
    );
  }
}
```

- [ ] **Step 2: Register the route**

In `lib/core/router/app_routes.dart`, add directly after the existing `static const String vendorProductEdit = '/vendor/products/:id/edit';` line:

```dart
  static const String vendorProductBulkUpload = '/vendor/products/bulk-upload';
```

In `lib/core/router/app_router.dart`, add this import directly after the existing `import '../../features/products/presentation/screens/add_product_screen.dart';` line:

```dart
import '../../features/products/presentation/screens/bulk_upload_screen.dart';
```

Then add this route directly after the existing:
```dart
        GoRoute(
          path: AppRoutes.vendorProductEdit,
          builder: (context, state) =>
              AddProductScreen(productId: state.pathParameters['id']!),
        ),
```
add:
```dart
        GoRoute(
          path: AppRoutes.vendorProductBulkUpload,
          builder: (_, _) => const BulkUploadScreen(),
        ),
```

- [ ] **Step 3: Verify with the analyzer**

Run: `cd the_vaults_vendor && flutter analyze lib/features/products/presentation/screens/bulk_upload_screen.dart lib/core/router/app_routes.dart lib/core/router/app_router.dart`
Expected: `No issues found!`

- [ ] **Step 4: Commit**

```bash
git add lib/features/products/presentation/screens/bulk_upload_screen.dart lib/core/router/app_routes.dart lib/core/router/app_router.dart
git commit -m "feat: add BulkUploadScreen and register its route"
```

---

### Task 9: Entry point — ProductsAppBar menu + ProductsScreen wiring

**Files:**
- Modify: `lib/features/products/presentation/widgets/products_app_bar.dart`
- Modify: `lib/features/products/presentation/screens/products_screen.dart`

**Interfaces:**
- Consumes: `AppRoutes.vendorProductBulkUpload` (Task 8).
- Produces: `ProductsAppBar({VoidCallback? onBulkUpload})` — the only public-surface change to this widget; existing callers that don't pass `onBulkUpload` keep compiling (it's optional), but `products_screen.dart` is updated in this same task to pass it.

- [ ] **Step 1: Add the overflow menu to ProductsAppBar**

Replace the full contents of `lib/features/products/presentation/widgets/products_app_bar.dart` with:

```dart
import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';

class ProductsAppBar extends StatelessWidget implements PreferredSizeWidget {
  final VoidCallback? onBulkUpload;

  const ProductsAppBar({super.key, this.onBulkUpload});

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      automaticallyImplyLeading: false,
      centerTitle: false,
      title: Text(
        'Products',
        style: TextStyle(
          color: context.colors.textPrimary,
          fontSize: 24,
          fontWeight: FontWeight.w800,
          letterSpacing: -0.4,
        ),
      ),
      actions: [
        PopupMenuButton<void>(
          icon: Icon(Icons.more_vert, color: context.colors.textPrimary),
          itemBuilder: (context) => [
            PopupMenuItem<void>(
              onTap: onBulkUpload,
              child: const Row(
                children: [
                  Icon(Icons.upload_file_outlined, size: 20),
                  SizedBox(width: 12),
                  Text('Bulk upload'),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }
}
```

- [ ] **Step 2: Wire the entry point in ProductsScreen**

In `lib/features/products/presentation/screens/products_screen.dart`, add a new method directly after the existing `_openAddProduct` method (which reads `Future<void> _openAddProduct() async { await context.push(AppRoutes.vendorProductCreate); _refresh(); }`):

```dart
  Future<void> _openBulkUpload() async {
    await context.push(AppRoutes.vendorProductBulkUpload);
    _refresh();
  }
```

Then change the `build` method's `appBar: const ProductsAppBar(),` to:

```dart
      appBar: ProductsAppBar(onBulkUpload: _openBulkUpload),
```

(dropping `const` since it now passes a non-const callback).

- [ ] **Step 3: Verify with the analyzer**

Run: `cd the_vaults_vendor && flutter analyze lib/features/products/presentation/widgets/products_app_bar.dart lib/features/products/presentation/screens/products_screen.dart`
Expected: `No issues found!`

- [ ] **Step 4: Commit**

```bash
git add lib/features/products/presentation/widgets/products_app_bar.dart lib/features/products/presentation/screens/products_screen.dart
git commit -m "feat: wire bulk-upload entry point into ProductsAppBar overflow menu"
```

---

### Task 10: Full manual verification pass

**Files:** none (verification only).

**Interfaces:** none — this task exercises everything built in Tasks 1–9 end to end.

- [ ] **Step 1: Static check across the whole feature**

Run: `cd the_vaults_vendor && flutter analyze`
Expected: `No issues found!` (or only pre-existing issues unrelated to this feature — confirm by comparing against `git stash` output if anything unexpected shows up).

- [ ] **Step 2: Run the app**

Run: `cd the_vaults_vendor && flutter run` (pick a connected device/emulator), log in as a vendor.

- [ ] **Step 3: Manual walkthrough — entry point**

From the Products tab, tap the overflow menu (⋮) in the app bar → "Bulk upload". Confirm `BulkUploadScreen` opens with the step indicator showing step 1 of 3 and the category card visible.

- [ ] **Step 4: Manual walkthrough — category + template**

Tap the category selector, drill down to a leaf category, confirm it's shown selected. Tap "Download template" and confirm the native "Save As" dialog appears and a real `.xlsx` file is written wherever the vendor chooses (open it afterward in a spreadsheet app to confirm it has the category's columns).

- [ ] **Step 5: Manual walkthrough — has-errors path**

Edit the downloaded template to have at least one invalid row (e.g. blank a required column) while leaving others valid, then in the app pick that file and tap "Upload & validate". Confirm the results card shows total/valid/invalid stat tiles, the "no products were imported yet" message, and an expandable list of the invalid row(s) with field-level messages — and confirm no product actually appears in "My Products" afterward (nothing should have been imported).

- [ ] **Step 6: Manual walkthrough — success path**

Fix the file so every row is valid, re-upload via "Upload another file" → pick the corrected file → "Upload & validate". Confirm the results card shows the queued-success message with the row count, and that "View products" pops back to the products list.

- [ ] **Step 7: Manual walkthrough — error handling**

With the device offline (airplane mode), attempt "Upload & validate" again and confirm a snackbar shows a friendly network-error message (not a raw exception) rather than the screen crashing or hanging.

- [ ] **Step 8: Final commit (if any fixups were needed)**

If any of the manual steps above surfaced a bug, fix it, re-run the relevant analyzer command from that task, then:

```bash
git add -A
git commit -m "fix: address issues found during bulk-upload manual verification"
```

If nothing needed fixing, no commit is required for this task.

---

## Self-Review

**Spec coverage:** Backend API/data layer (Task 2), result models (Task 1), state/cubit (Tasks 3–4), category+template UI (Task 5), upload UI (Task 6), results UI incl. corrected has-errors messaging (Task 7), screen/routing (Task 8), entry point (Task 9), manual verification in place of automated tests (Task 10) — every section of the approved spec (and its correction) has a task.

**Placeholder scan:** No TBD/TODO markers; every step has complete, runnable code, not a description of code.

**Type consistency:** `ProductRemoteDataSource.downloadBulkTemplate`/`importBulkProducts` signatures in Task 2 match exactly what Task 4's cubit calls. `BulkImportResultModel`/`BulkInvalidRow`/`BulkRowError` field names in Task 1 match exactly what Task 7's results card reads. `BulkUploadState` field names in Task 3 match what Tasks 4–8 read/write. `BulkUploadCubit` method names in Task 4 match what Tasks 5–8 call. `AppRoutes.vendorProductBulkUpload` in Task 8 matches what Task 9 pushes.
