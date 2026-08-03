# Bulk Product Upload (Vendor App)

## Context

The vendor products feature (`lib/features/products/`) only supports creating products one at a time via `AddProductScreen`. The backend already has a full bulk-import module for products (category-specific Excel template, upload-and-validate, async queued creation), and the admin/vendor **web** app (`the_vaults_backend`, a Vite/React project despite its name — no separate NestJS API source is checked out anywhere on this machine, only its compiled `dist/` output) already has a working reference UI for it (`src/pages/products/BulkUploadProducts.jsx` + `src/services/product.service.js`). This design ports that capability into the Flutter vendor app.

`the_vaults_backend` is treated as **read-only reference material** for this change — no backend code is modified.

## Backend API (confirmed by reading compiled `dist/` output)

Base path: `products/bulk` (NestJS, `JwtAuthGuard` + `RolesGuard`).

- `GET /products/bulk/template?categoryUuid=xxx` → xlsx blob (category-specific columns, dropdown validation, ExcelJS-generated). Requires `categoryUuid`.
- `POST /products/bulk/import` (multipart, field `file`) → validates every row **synchronously** server-side (product/category/brand/SKU/price/inventory/specification/variant/image validators) before responding:
  ```json
  {
    "validRows": [{ "rowNumber": 2, "data": { "Product Title": "...", "SKU": "...", ... }, "thumbnailBuffer"?: ..., "galleryBuffers"?: [...] }],
    "invalidRows": [{ "rowNumber": 5, "isValid": false, "errors": [{ "field": "SKU", "message": "..." }] }],
    "totalRows": 10, "validCount": 8, "invalidCount": 2, "hasErrors": true
  }
  ```
  **Critical confirmed behavior**: if `hasErrors` is `true` (any row invalid), the backend returns only the validation result and does **not** enqueue or create anything — not even the valid rows. Nothing is imported until every row in the file passes. Only when `hasErrors` is `false` does it create a `BulkImportJob` row, enqueue all rows to BullMQ, and respond with a **completely different, smaller shape** — no `validRows`, `invalidRows`, `validCount`, `invalidCount`, or `hasErrors` keys at all, just:
  ```json
  { "success": true, "jobUuid": "...", "status": "PENDING", "totalRows": 8, "message": "Bulk import has been queued successfully." }
  ```
  (Key is `jobUuid`, not `jobId`.) Because the success response carries no per-row data, there is nothing to show as a "valid rows preview" in that case — the only row-level detail the client ever receives is the invalid-rows list, and only on the rejected path.
- `GET /products/bulk/status/:jobId` and `GET /products/bulk/report/:jobId` are **stubs**: status always returns `{"status":"PENDING"}` regardless of the id, report always 404s — neither reads the real `BulkImportJob` row even though `BulkJobService.findByUuid` exists and the BullMQ worker genuinely does update job status (`markProcessing`/`completeJob`/`failJob`) and fires a `bulk.import.completed` event that emails the vendor with final totals. **These two endpoints are not used by this design** — confirmed out of scope with the user.

The existing React reference UI's polling code reads `payload.jobId` (always `undefined`, since the backend returns `jobUuid`) and its copy claims "valid rows were imported" when `hasErrors` is true (false — nothing is imported in that case). Both are bugs in the reference app; this design does not copy either.

## Decisions confirmed with user

- Backend is read-only reference; only `the_vaults_vendor` is touched.
- File type: **`.xlsx` only** (matches what the template generator actually produces; no `.xls`/`.csv` support).
- No polling of `status`/`report` endpoints. The synchronous `POST /import` response is treated as the full result. On success (job queued), the UI tells the vendor to check their email for completion and check the products list afterward — no fake progress UI.
- State management: a dedicated `BulkUploadCubit` (not a plain `StatefulWidget`), even though the single-product wizard (`AddProductScreen`) uses local `State` — the wizard here has several independent async flags (categories loading, template downloading, uploading) better modeled as one state object than as `AddProductScreen`-style local fields or `VendorProductsState`-style mutually-exclusive subclasses.
- Entry point: a "Bulk upload" item in a new overflow menu (`PopupMenuButton`) on `ProductsAppBar`, not a second FAB or a list banner.
- Template file handling: `file_picker`'s `FilePicker.platform.saveFile(bytes: ...)` (Storage Access Framework "Save As" dialog on Android, native save panel on iOS/desktop) — one tap, no new permissions, no new dependency. A fully silent write to the public Downloads folder was considered and rejected: it needs new native/platform-channel code on Android and has no iOS equivalent.

## Design

### Data layer

`lib/core/api/api_endpoints.dart` — add:
```dart
static const String bulkImportTemplate = '/api/v1/products/bulk/template';
static const String bulkImportUpload = '/api/v1/products/bulk/import';
```
(No `status`/`report` constants — out of scope stubs.)

`lib/features/products/data/datasources/product_remote_datasource.dart` — add to the interface and impl, following this file's existing conventions (binary responses return raw bytes with no envelope unwrapping; JSON POSTs return `_unwrapObject(response.data)`):
```dart
Future<List<int>> downloadBulkTemplate(String categoryUuid);
// GET bulkImportTemplate, query {categoryUuid}, Options(responseType: ResponseType.bytes)

Future<Map<String, dynamic>> importBulkProducts(
  String filePath, {
  void Function(int sent, int total)? onSendProgress,
});
// POST bulkImportUpload, FormData with MultipartFile.fromFile(filePath) under 'file',
// Options(receiveTimeout: Duration(seconds: 120)) — see "Large-file validation latency" below.
// Returns _unwrapObject(response.data).
```

New model `lib/features/products/data/models/bulk_import_result_model.dart`, with every field that's branch-specific made nullable/defaulted rather than required, since the two response shapes share almost nothing:
```dart
class BulkImportResultModel {
  final int totalRows;
  final int? validCount;      // only present on the has-errors branch
  final int? invalidCount;    // only present on the has-errors branch
  final bool hasErrors;       // defaults false when absent (the queued/success branch)
  final List<BulkInvalidRow> invalidRows; // empty when absent
  final String? jobUuid;      // only present on the queued/success branch
  final String? message;

  factory BulkImportResultModel.fromJson(Map<String, dynamic> json);
}

class BulkInvalidRow {
  final int rowNumber;
  final List<BulkRowError> errors;
}

class BulkRowError {
  final String field;
  final String message;
}
```
No `validRows`/valid-row-preview model — the backend never returns per-row data for successfully queued imports (see the API section above), so there's nothing to preview in that case, and previewing rows on the rejected path would be misleading (those rows were not imported either).

### Cubit & state

New `lib/features/products/presentation/bloc/bulk_upload_cubit.dart` and `bulk_upload_state.dart`, following `VendorProductsCubit`'s pattern of resolving dependencies via `GetIt.I<...>()` internally (no constructor injection):

```dart
class BulkUploadState {
  final List<CategoryModel> rootCategories;
  final bool loadingCategories;
  final String? categoriesError;
  final CategoryModel? selectedCategory;   // must be a leaf (no children)
  final bool downloadingTemplate;
  final String? pickedFileName;
  final String? pickedFilePath;
  final bool uploading;
  final int uploadProgressPercent;
  final BulkImportResultModel? result;
  final String? errorMessage;              // transient — shown via snackbar, then cleared

  int get currentStep =>                   // feeds the existing StepIndicator widget (0-based)
      result != null ? 2 : pickedFilePath != null ? 1 : 0;

  BulkUploadState copyWith({...});
  factory BulkUploadState.initial();
}

class BulkUploadCubit extends Cubit<BulkUploadState> {
  BulkUploadCubit() : super(BulkUploadState.initial());

  Future<void> loadCategories();          // GetIt.I<ProductRemoteDataSource>().getCategoryTree()
  void selectCategory(CategoryModel leaf);
  Future<void> downloadTemplate();        // downloadBulkTemplate(categoryUuid) -> FilePicker.saveFile
  Future<void> pickFile();                // file_picker, FileType.custom, allowedExtensions: ['xlsx']
  void clearFile();
  Future<void> upload();                  // importBulkProducts(...) -> BulkImportResultModel or errorMessage
  void reset();                           // "Upload another file": clears file+result, KEEPS selectedCategory
}
```

Behavioral rule carried over from the confirmed backend behavior (not the buggy React copy): when `upload()` resolves with `result.hasErrors == true`, the UI must say something like *"N row(s) need fixing — no products were imported yet. Fix the errors below and re-upload."* — never the reference app's "valid rows were imported," which is false whenever there are any invalid rows.

### Screen & navigation

- `lib/core/router/app_routes.dart`: add `static const String vendorProductBulkUpload = '/vendor/products/bulk-upload';`
- `lib/core/router/app_router.dart`: register the route next to `vendorProductCreate`, building `const BulkUploadScreen()`.
- New `lib/features/products/presentation/screens/bulk_upload_screen.dart`: `BlocProvider(create: (_) => BulkUploadCubit()..loadCategories(), child: ...)`.
- `lib/features/products/presentation/widgets/products_app_bar.dart`: add `actions: [PopupMenuButton<void>(itemBuilder: (_) => [PopupMenuItem(child: Text('Bulk upload'), onTap: ...)])]`. The menu item pushes `AppRoutes.vendorProductBulkUpload`; on the calling screen (`products_screen.dart`), returning from that push triggers the existing `_refresh()` (same pattern `_openAddProduct` already uses).

### Screen layout

Single scrollable page (not a hard-gated paged wizard — matches the reference app's actual layout, where the category/template card and upload card are both visible/usable together). `StepIndicator(currentStep: state.currentStep, totalSteps: 3, stepLabels: ['Category', 'Upload', 'Results'])` at the top is a cosmetic progress cue, not page navigation.

1. **Category card** — leaf-category picker reusing `showCategoryPicker` from `category_picker_sheet.dart` with the same drill-down loop `AddProductScreen` already uses (call with root categories; if the picked node has children, call again with `cat.children`; repeat until a leaf is picked) + a "Download template" button, disabled until a leaf is selected, spinner while `downloadingTemplate`.
2. **Upload card** — `file_picker` button restricted to `.xlsx`, shows the picked filename + size once chosen, "Upload & validate" button disabled until a file is picked, a linear progress indicator driven by `uploadProgressPercent` while `uploading`.
3. **Results card** — rendered only once `state.result != null`:
   - If `hasErrors`: stat tiles for total / valid / invalid rows (using this app's existing card/tile styling, not the web's ad-hoc colored boxes), the corrected messaging (see behavioral rule above), and an expandable list of invalid rows, each showing its row number and field errors. No valid-row preview — those rows weren't imported either, so listing them would be misleading.
   - If not `hasErrors` (job queued): a single success message with `totalRows` and the confirmed-with-user copy ("N product(s) queued — you'll get an email when it's done, then check My Products"), optionally showing `jobUuid` for reference. No per-row detail exists to show here (see API section above).
   - Actions: "Upload another file" (`cubit.reset()`) and "View products" (`context.pop()`).

### Error handling

- Category-load and template-download failures show inline retry affordances on their own card (not a full-screen error), consistent with those being recoverable, localized failures.
- Upload network/server failures (`DioException`, distinct from a normal 200 response with `hasErrors: true`) surface via the existing `AppSnackbar.showError(context, friendlyErrorMessage(e))` — no new error-message plumbing needed, since `friendlyErrorMessage` already forwards server-provided messages (e.g. the backend's "Please upload an Excel or CSV file." / "Vendor profile not found.") through `ServerFailure.message`.
- **Large-file validation latency**: because validation happens synchronously across many rows before the backend responds, a large file can plausibly exceed the app's global 30s receive timeout (`AppConfig.receiveTimeoutSeconds`). Rather than raising the global timeout, `importBulkProducts` passes a per-request `Options(receiveTimeout: Duration(seconds: 120))`.
- No destructive local state exists to protect against back-navigation mid-upload; the Cubit (not tied to widget lifecycle beyond the `BlocProvider`'s scope) is allowed to keep running if the user navigates back quickly, matching how other async actions in this app behave.

### Testing

No test suite currently exists for the products feature (`test/features/products` doesn't exist), so this change doesn't introduce a new testing pattern unilaterally. Verification is manual, run through the live app: category picker → template download → fill in and re-upload a real file, covering both the all-valid (queued) path and the has-errors (rejected, no partial import) path — consistent with this app's existing verification approach for other features.

## Out of scope

- Fixing the backend's stubbed `status`/`report` endpoints, or anything in `the_vaults_backend`.
- `.xls`/`.csv` file support.
- Polling for async job completion or downloading an error report from the app.
- A hard-gated, back/forward paged wizard (this is a single scrolling page with a cosmetic step indicator instead).
- Silent, dialog-free auto-save of the template to the public Downloads folder.
