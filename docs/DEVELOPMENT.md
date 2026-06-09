# Development Guide

Setup, conventions, and workflows for contributing to Bingo Pay.

---

## Contents

1. [Environment Setup](#environment-setup)
2. [Running the App](#running-the-app)
3. [Build Commands](#build-commands)
4. [Code Generation](#code-generation)
5. [Adding a New Feature](#adding-a-new-feature)
6. [Adding a New API Endpoint](#adding-a-new-api-endpoint)
7. [Testing Conventions](#testing-conventions)
8. [Shared Widgets](#shared-widgets)
9. [CI Checklist](#ci-checklist)

---

## Environment Setup

1. Install Flutter SDK `^3.10.8`. Use [fvm](https://fvm.app/) if managing multiple Flutter versions.
2. Run `flutter doctor` and resolve any issues.
3. Install dependencies:
   ```bash
   flutter pub get
   ```
4. Run code generation (required on first clone and after any model/DI change):
   ```bash
   dart run build_runner build --delete-conflicting-outputs
   ```

---

## Running the App

Always pass both `--flavor` and `-t`. Omitting either causes a runtime crash or wrong API URL.

```bash
# Development
flutter run --flavor dev -t lib/main_dev.dart

# Staging
flutter run --flavor staging -t lib/main_staging.dart

# Production (requires signing config)
flutter run --flavor prod -t lib/main_prod.dart
```

To run on a specific device:

```bash
flutter devices            # list connected devices
flutter run -d <device-id> --flavor dev -t lib/main_dev.dart
```

---

## Build Commands

### Android APK

```bash
# Debug
flutter build apk --flavor dev -t lib/main_dev.dart --debug

# Release
flutter build apk --flavor prod -t lib/main_prod.dart --release

# App bundle (Play Store)
flutter build appbundle --flavor prod -t lib/main_prod.dart --release
```

### iOS IPA

```bash
flutter build ipa --flavor dev -t lib/main_dev.dart
flutter build ipa --flavor prod -t lib/main_prod.dart --release
```

---

## Code Generation

Two generators are in use:

### injectable_generator

Produces `lib/core/di/injection.config.dart`.

Run when you add, remove, or change:
- Any class annotated with `@injectable`, `@singleton`, `@lazySingleton`
- Any `@Injectable(as: Interface)` binding
- Anything in `AppModule`

### json_serializable

Produces `*.g.dart` files next to each `@JsonSerializable` model.

Run when you add, rename, or remove fields in any model class.

### Command

```bash
dart run build_runner build --delete-conflicting-outputs
```

Run in watch mode during active model editing:

```bash
dart run build_runner watch --delete-conflicting-outputs
```

Never edit generated files. Commit them — they are required for the app to compile.

---

## Adding a New Feature

Use `auth` as the reference implementation. Follow each step in order.

### 1. Create the folder structure

```
lib/features/<feature_name>/
├── domain/
│   ├── entities/
│   ├── repositories/
│   └── usecases/
├── data/
│   ├── models/
│   ├── datasources/
│   └── repositories/
└── presentation/
    ├── bloc/      (or cubit/)
    ├── screens/
    └── widgets/
```

### 2. Write domain entities

Extend `Equatable`. No framework imports. Example:

```dart
class ProductEntity extends Equatable {
  final String id;
  final String name;
  final double price;

  const ProductEntity({required this.id, required this.name, required this.price});

  @override
  List<Object> get props => [id, name, price];
}
```

### 3. Write the repository interface

```dart
abstract interface class ProductRepository {
  Future<Either<Failure, List<ProductEntity>>> getProducts();
  Future<Either<Failure, ProductEntity>> createProduct(CreateProductParams params);
}
```

### 4. Write use cases

One class per operation. Each is `@injectable` and accepts the repository interface. Params is a nested `Equatable` class:

```dart
@injectable
class GetProductsUseCase {
  final ProductRepository _repository;
  const GetProductsUseCase(this._repository);

  Future<Either<Failure, List<ProductEntity>>> call() => _repository.getProducts();
}
```

### 5. Write models

Extend the entity, add `@JsonSerializable`:

```dart
@JsonSerializable()
class ProductModel extends ProductEntity {
  const ProductModel({required super.id, required super.name, required super.price});

  factory ProductModel.fromJson(Map<String, dynamic> json) => _$ProductModelFromJson(json);
  Map<String, dynamic> toJson() => _$ProductModelToJson(this);
}
```

Then run build_runner.

### 6. Write datasources

```dart
abstract interface class ProductRemoteDataSource {
  Future<List<ProductModel>> getProducts();
}

@Injectable(as: ProductRemoteDataSource)
class ProductRemoteDataSourceImpl implements ProductRemoteDataSource {
  final ApiClient _apiClient;
  const ProductRemoteDataSourceImpl(this._apiClient);

  @override
  Future<List<ProductModel>> getProducts() async {
    final response = await _apiClient.dio.get(ApiEndpoints.products);
    return (response.data['data'] as List)
        .map((e) => ProductModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }
}
```

### 7. Write the repository impl

```dart
@Injectable(as: ProductRepository)
class ProductRepositoryImpl implements ProductRepository {
  final ProductRemoteDataSource _remote;
  const ProductRepositoryImpl(this._remote);

  @override
  Future<Either<Failure, List<ProductEntity>>> getProducts() async {
    try {
      return Right(await _remote.getProducts());
    } on Exception catch (e) {
      return Left(ErrorHandler.mapExceptionToFailure(e));
    }
  }
}
```

### 8. Write the BLoC or Cubit

- **BLoC** — sealed events + sealed states. Inject all use cases via constructor. Use `@injectable`.
- **Cubit** — single class with `emit()` calls. Simpler, for dashboards and single-load screens.

Register use cases as constructor parameters — Injectable will wire them automatically.

### 9. Run build_runner

```bash
dart run build_runner build --delete-conflicting-outputs
```

### 10. Add routes

In `lib/core/router/app_routes.dart`, add route constants:

```dart
static const String vendorProducts = '/vendor/products';
static const String vendorProductCreate = '/vendor/products/create';
```

In `lib/core/router/app_router.dart`, add `GoRoute` entries and use the real screen widget.

### 11. Write tests

Write tests for every layer before marking the feature done. See [Testing Conventions](#testing-conventions).

---

## Adding a New API Endpoint

1. Add the path constant to `lib/core/api/api_endpoints.dart`:
   ```dart
   static const String newEndpoint = '/some/path';
   ```
2. Add the call to the appropriate remote datasource.
3. Add the corresponding method to the repository interface.
4. Add the repository impl method (with `try/catch → Either`).
5. Add a use case.
6. Add a BLoC event + handler.
7. Add tests.

---

## Testing Conventions

### Unit tests

Location: `test/unit/<feature>/`

- Mock repositories with `mocktail`. No real network calls.
- Test the `Either` result: both `Right` (success) and `Left` (failure) paths.
- Example:

```dart
test('returns UserEntity on success', () async {
  when(() => mockRepo.login(email: any(named: 'email'), password: any(named: 'password')))
      .thenAnswer((_) async => Right(tUser));

  final result = await useCase(LoginUseCase.Params(email: 'a@b.com', password: 'pass'));

  expect(result, Right(tUser));
});
```

### BLoC tests

Location: `test/bloc/`

Use `blocTest<BlocType, StateType>()` from `bloc_test`:

```dart
blocTest<AuthBloc, AuthState>(
  'emits [AuthLoading, AuthAuthenticated] on login success',
  build: () {
    when(() => mockLoginUseCase(any())).thenAnswer((_) async => Right(tUser));
    return authBloc;
  },
  act: (bloc) => bloc.add(LoginRequested(email: 'a@b.com', password: 'pass')),
  expect: () => [const AuthLoading(), AuthAuthenticated(tUser)],
);
```

### Widget tests

Location: `test/widget/<feature>/`

Use `MockBloc` from `mocktail` + `bloc_test`:

```dart
class MockAuthBloc extends MockBloc<AuthEvent, AuthState> implements AuthBloc {}

testWidgets('shows loading indicator when AuthLoading', (tester) async {
  when(() => bloc.state).thenReturn(const AuthLoading());
  await tester.pumpWidget(buildSubject(bloc));
  expect(find.byType(CircularProgressIndicator), findsOneWidget);
});
```

Wrap the widget under test in `BlocProvider.value(value: mockBloc, child: MaterialApp(...))`.

### Test file locations

```
test/
├── unit/
│   ├── auth/
│   │   ├── user_entity_test.dart
│   │   ├── user_model_test.dart
│   │   ├── login_usecase_test.dart
│   │   ├── auth_local_datasource_test.dart
│   │   └── auth_repository_impl_test.dart
│   ├── validators_test.dart
│   ├── route_guard_test.dart
│   ├── error_handler_test.dart
│   ├── error_interceptor_test.dart
│   ├── flavor_config_test.dart
│   ├── connectivity_service_test.dart
│   └── secure_storage_service_test.dart
├── bloc/
│   └── auth_bloc_test.dart
├── widget/
│   └── auth/
│       └── login_screen_test.dart
└── helpers/
    └── mocks.dart              # Shared mock declarations
```

---

## Shared Widgets

Use these core widgets instead of raw Material widgets to stay consistent with the design system.

### AppButton

```dart
AppButton(
  label: 'Sign In',
  onPressed: _submit,
  isLoading: state is AuthLoading,
  variant: AppButtonVariant.primary,  // primary | secondary | outlined
)
```

### AppTextField

```dart
AppTextField(
  label: 'Email',
  hint: 'you@example.com',
  controller: _emailController,
  keyboardType: TextInputType.emailAddress,
  validator: Validators.email,
)
```

### AppImagePicker

```dart
AppImagePicker(
  label: 'Government ID',
  imagePath: _selectedPath,
  onPickFromCamera: _pickCamera,
  onPickFromGallery: _pickGallery,
)
```

Shows a bottom sheet with camera/gallery options. Displays the selected image preview.

### Validators

```dart
Validators.email(value)             // null = valid
Validators.password(value)          // min 8 chars
Validators.confirmPassword(value, original)
Validators.required(value, fieldName: 'Name')
Validators.name(value)              // min 2 chars
```

Pass directly to `AppTextField.validator`.

### AppSnackbar

```dart
AppSnackbar.showError(context, 'Something went wrong');
AppSnackbar.showSuccess(context, 'Profile updated');
AppSnackbar.showOfflineBanner(context);  // shown automatically by App root
```

---

## CI Checklist

These steps run (or should run) on every PR:

```bash
flutter pub get
dart run build_runner build --delete-conflicting-outputs
flutter analyze                    # must exit 0
flutter test                       # must exit 0
flutter build apk --flavor dev -t lib/main_dev.dart --debug
```

Before merging to main:

- All tests pass (`flutter test`)
- No analysis issues (`flutter analyze`)
- No uncommitted generated files
- New feature has unit + BLoC tests covering both success and failure paths
- New screens have at least one widget test verifying the loading and error states
