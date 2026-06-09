# Architecture

Bingo Pay uses **Feature-First Clean Architecture**. All shared infrastructure lives in `core/`. Each product feature lives in `features/<name>/` with its own domain, data, and presentation layers. Features never import each other.

---

## Contents

1. [Layers](#layers)
2. [Feature Structure](#feature-structure)
3. [Dependency Injection](#dependency-injection)
4. [Error Handling](#error-handling)
5. [Routing & Navigation Guard](#routing--navigation-guard)
6. [State Management](#state-management)
7. [API Client](#api-client)
8. [Storage](#storage)
9. [Theme Tokens](#theme-tokens)
10. [KYC Flow](#kyc-flow)
11. [API Contract](#api-contract)

---

## Layers

```
Presentation  ←  Domain  ←  Data
(BLoC/Widget)    (Entity    (Model/
                  UseCase   DataSource/
                  Repo IF)  RepoImpl)
```

- **Domain** — pure Dart. Entities, repository interfaces, use cases. Zero framework imports.
- **Data** — implements domain interfaces. JSON models (`@JsonSerializable`), remote and local datasources, repository impls. Converts exceptions to `Either<Failure, T>`.
- **Presentation** — Flutter widgets + BLoC. Receives domain entities, never JSON models.

Dependency direction: Presentation → Domain ← Data. Data imports domain interfaces, not the other way around.

---

## Feature Structure

Every feature is a self-contained vertical slice:

```
features/auth/
├── domain/
│   ├── entities/           # Pure Dart value objects (Equatable)
│   │   ├── user_entity.dart
│   │   └── kyc_entity.dart
│   ├── repositories/       # Abstract interfaces (no implementation)
│   │   └── auth_repository.dart
│   └── usecases/           # One class per operation, @injectable
│       ├── login_usecase.dart
│       ├── register_usecase.dart
│       ├── logout_usecase.dart
│       ├── forgot_password_usecase.dart
│       ├── check_auth_status_usecase.dart
│       ├── submit_kyc_personal_details_usecase.dart
│       ├── upload_kyc_document_usecase.dart
│       ├── upload_kyc_selfie_usecase.dart
│       └── get_kyc_status_usecase.dart
│
├── data/
│   ├── models/             # Extend entities, add fromJson/toJson
│   │   ├── user_model.dart
│   │   ├── auth_response_model.dart
│   │   └── kyc_model.dart
│   ├── datasources/        # Remote (Dio) and local (Storage) sources
│   │   ├── auth_remote_datasource.dart
│   │   └── auth_local_datasource.dart
│   └── repositories/
│       └── auth_repository_impl.dart   # @Injectable(as: AuthRepository)
│
└── presentation/
    ├── bloc/
    │   ├── auth_bloc.dart
    │   ├── auth_event.dart
    │   └── auth_state.dart
    ├── screens/
    │   ├── login_screen.dart
    │   ├── register_screen.dart
    │   ├── forgot_password_screen.dart
    │   └── kyc/
    │       ├── kyc_screen.dart
    │       ├── kyc_document_screen.dart
    │       └── kyc_selfie_screen.dart
    └── widgets/
        └── kyc_step_indicator.dart
```

### Naming conventions

| Thing              | Convention                                | Example                         |
|--------------------|-------------------------------------------|---------------------------------|
| Entity             | `<Name>Entity`                            | `UserEntity`                    |
| Model              | `<Name>Model`                             | `UserModel`                     |
| Repository IF      | `<Feature>Repository`                     | `AuthRepository`                |
| Repository impl    | `<Feature>RepositoryImpl`                 | `AuthRepositoryImpl`            |
| DataSource IF      | `<Feature><Remote\|Local>DataSource`      | `AuthRemoteDataSource`          |
| DataSource impl    | `<Feature><Remote\|Local>DataSourceImpl`  | `AuthRemoteDataSourceImpl`      |
| Use case           | `<Verb><Noun>UseCase`                     | `LoginUseCase`                  |
| Use case params    | `<UseCaseName>.Params`                    | `LoginUseCase.Params`           |
| BLoC event         | `<Noun><Verb>` (past or requested)        | `LoginRequested`                |
| BLoC state         | `Auth<Status>`                            | `AuthAuthenticated`, `AuthError`|

---

## Dependency Injection

GetIt service locator with Injectable for compile-time code generation.

```dart
// lib/core/di/injection.dart
final GetIt getIt = GetIt.instance;

@InjectableInit()
Future<void> configureDependencies(String environment) async =>
    getIt.init(environment: environment);
```

Called in `bootstrap()` with the flavor name (`'dev'`, `'staging'`, `'prod'`).

### Registration annotations

| Annotation               | Lifecycle       | Typical use                                   |
|--------------------------|-----------------|-----------------------------------------------|
| `@singleton`             | one instance    | `ApiClient`, `SecureStorageService`           |
| `@lazySingleton`         | one instance, lazy | `AppRouter`, `ConnectivityService`         |
| `@injectable`            | new per request | BLoCs, use cases, repository impls            |
| `@Injectable(as: Iface)` | factory, bound  | DataSource/Repository impls registered as IFs |
| `@module`                | platform reg    | `AppModule` — registers platform singletons  |

### AppModule

`lib/core/di/app_module.dart` registers objects that require async setup or come from platform packages:

```dart
@module
abstract class AppModule {
  @singleton
  FlutterSecureStorage get secureStorage => const FlutterSecureStorage();

  @preResolve
  @singleton
  Future<SharedPreferences> get prefs => SharedPreferences.getInstance();

  @singleton
  Connectivity get connectivity => Connectivity();
}
```

`@preResolve` means `configureDependencies` awaits the future before the container is ready — which is why `bootstrap()` is `async`.

### After adding a new injectable class

```bash
dart run build_runner build --delete-conflicting-outputs
```

This regenerates `lib/core/di/injection.config.dart`. Commit the generated file.

---

## Error Handling

No exceptions cross layer boundaries. The data layer converts every exception to a `Failure` before returning to the domain/presentation.

### Exception types (data layer only)

```dart
class ServerException     implements Exception  // 4xx/5xx from API
class NetworkException    implements Exception  // connection failure/timeout
class AuthException       implements Exception  // 401
class ValidationException implements Exception  // 422, carries fieldErrors map
class CacheException      implements Exception  // storage read/write failure
```

### Failure types (domain + presentation)

```dart
sealed class Failure extends Equatable {
  final String message;
}

class NetworkFailure    extends Failure  // no internet
class ServerFailure     extends Failure  // { statusCode, serverMessage }
class AuthFailure       extends Failure  // session expired / forbidden
class ValidationFailure extends Failure  // { fieldErrors: Map<String, String> }
class CacheFailure      extends Failure  // storage problem
class UnknownFailure    extends Failure  // catch-all
```

### Repository pattern

Every repository method returns `Either<Failure, T>`:

```dart
@override
Future<Either<Failure, UserEntity>> login({...}) async {
  try {
    final response = await _remote.login(email: email, password: password);
    await _local.saveTokens(response.accessToken, response.refreshToken);
    return Right(response.user.toEntity());
  } on Exception catch (e) {
    return Left(ErrorHandler.mapExceptionToFailure(e));
  }
}
```

`ErrorHandler.mapExceptionToFailure` centralises the exception→failure mapping so it isn't duplicated across repository impls.

---

## Routing & Navigation Guard

GoRouter with a centralized `redirect` function.

### Route constants

All route strings live in `lib/core/router/app_routes.dart`:

```dart
class AppRoutes {
  static const String splash      = '/splash';
  static const String login       = '/login';
  static const String register    = '/register';
  static const String registerKyc = '/register/kyc';

  static const String buyerHome   = '/buyer/home';
  static const String vendorHome  = '/vendor/home';
  // ...

  static const List<String> publicRoutes = [
    splash, login, register, registerKyc, kycDocument, kycSelfie, forgotPassword,
  ];
}
```

### Auth state

`AppRouter` holds a `RouteAuthState` that the root `App` widget updates whenever `AuthBloc` emits `AuthAuthenticated` or `AuthUnauthenticated`:

```dart
// lib/core/router/route_guard.dart
class RouteAuthState {
  final bool isAuthenticated;
  final UserRole? role;      // buyer | vendor
  final bool isKycPending;
}
```

### Redirect logic (in order)

1. **Unauthenticated on protected route** → `/login`
2. **Vendor with `isKycPending` not at `/register/kyc`** → `/register/kyc`
3. **Authenticated on public route (not splash, not KYC-pending)** → role home
4. **Buyer navigating to `/vendor/*`** → `/buyer/home`
5. **Vendor navigating to `/buyer/*`** → `/vendor/home`
6. No redirect → `null`

The KYC guard fires before the "already logged in" guard so vendors in the KYC wizard are not bounced to `/vendor/home`.

---

## State Management

BLoC is used for operations with side effects (network, storage). Cubit is used for simpler UI state with no async branching.

| Feature            | Manager | Reason                                          |
|--------------------|---------|-------------------------------------------------|
| auth               | BLoC    | 9 distinct event types, complex state machine   |
| home               | Cubit   | Dashboard data load, minimal branching          |
| product_management | BLoC    | CRUD + pagination + image upload states         |
| transactions       | BLoC    | List + filters + detail states                  |
| refer_and_earn     | Cubit   | Load referral code + share action               |
| invoices           | BLoC    | List + filter + download states                 |

### AuthBloc

Events (sealed):

| Event                        | Triggers                                      |
|------------------------------|-----------------------------------------------|
| `CheckAuthStatusRequested`   | App startup — loads stored user from cache    |
| `LoginRequested`             | Login form submit                             |
| `RegisterRequested`          | Register form submit                          |
| `ForgotPasswordRequested`    | Forgot password form submit                   |
| `LogoutRequested`            | Logout button                                 |
| `KycPersonalDetailsSubmitted`| KYC step 1 form submit                        |
| `KycDocumentUploaded`        | KYC step 2 file selected                      |
| `KycSelfieUploaded`          | KYC step 3 selfie captured                    |
| `KycStatusPolled`            | Polling timer on KYC submitted screen         |

States (sealed):

| State               | Emitted when                                        |
|---------------------|-----------------------------------------------------|
| `AuthInitial`       | Before any check                                    |
| `AuthLoading`       | Any async operation started                         |
| `AuthAuthenticated` | Login / register / stored user restored             |
| `AuthUnauthenticated` | Logout / no stored token                          |
| `AuthError`         | Any failure — carries `Failure`                     |
| `PasswordResetSent` | Forgot password API call succeeded                  |
| `KycLoading`        | Any KYC step upload started                         |
| `KycStepCompleted`  | KYC step finished — carries `step: int`             |
| `KycSubmitted`      | All KYC steps done, under review                    |

### AppBlocObserver

Registered globally in `bootstrap.dart`. Logs every state change and transition in dev/staging; routes errors to analytics in prod.

### App root

`app.dart` wires the root `BlocProvider<AuthBloc>` and a `BlocListener` that calls `AppRouter.updateAuthState()` on every `AuthAuthenticated` / `AuthUnauthenticated` transition. The router then re-evaluates the redirect, which navigates the user automatically.

---

## API Client

Dio singleton registered with `@singleton`. Three interceptors in order:

### 1. LoggingInterceptor

Uses `pretty_dio_logger`. Active only when `FlavorConfig.enableLogging == true` (dev and staging).

### 2. AuthInterceptor

Reads the JWT access token from `SecureStorageService` and injects `Authorization: Bearer <token>` on every outgoing request. No token → header omitted (login/register requests work unauthenticated).

### 3. ErrorInterceptor

Maps `DioException` to a typed `Exception` and rejects the error with it:

| HTTP Status | Exception thrown       |
|-------------|------------------------|
| 401         | `AuthException`        |
| 422         | `ValidationException`  |
| Other 4xx/5xx | `ServerException`    |
| Connection error / timeout | `NetworkException` |

The repository `try/catch` then converts this to a `Failure` via `ErrorHandler`.

---

## Storage

### SecureStorageService

Wraps `flutter_secure_storage`. Stores sensitive values encrypted on-device:

| Key             | Constant                         | Value         |
|-----------------|----------------------------------|---------------|
| `access_token`  | `AppConstants.accessTokenKey`    | JWT           |
| `refresh_token` | `AppConstants.refreshTokenKey`   | JWT           |
| `user_id`       | `AppConstants.userIdKey`         | UUID string   |

Never store tokens in SharedPreferences.

### PreferencesService

Wraps `shared_preferences`. Stores non-sensitive preferences:

| Key               | Purpose                    |
|-------------------|----------------------------|
| `theme_mode`      | Light / dark preference    |
| `locale`          | Selected locale            |
| `onboarding_seen` | Whether to show onboarding |
| `cached_user`     | JSON-serialised UserModel  |

---

## Theme Tokens

All UI values come from token classes — no raw hex or literal numbers in widgets.

### AppColors

| Token              | Value       | Use                        |
|--------------------|-------------|----------------------------|
| `primary`          | `#1A73E8`   | Buttons, links, active UI  |
| `primaryDark`      | `#1557B0`   | Pressed states             |
| `secondary`        | `#34A853`   | Success indicators         |
| `backgroundLight`  | `#F8F9FA`   | Screen background (light)  |
| `textPrimary`      | `#202124`   | Body text                  |
| `textSecondary`    | `#5F6368`   | Captions, hints            |
| `error`            | `#EA4335`   | Error states               |
| `divider`          | `#E0E0E0`   | Dividers, borders          |

### AppDimensions

| Token          | Value  | Use                     |
|----------------|--------|-------------------------|
| `xs`           | 4px    | Tight internal spacing  |
| `sm`           | 8px    | Component gaps          |
| `md`           | 16px   | Standard screen padding |
| `lg`           | 24px   | Section spacing         |
| `xl`           | 32px   | Large gaps              |
| `radiusMd`     | 8px    | Cards, inputs           |
| `radiusLg`     | 12px   | Sheets, dialogs         |
| `buttonHeight` | 52px   | All primary buttons     |
| `inputHeight`  | 52px   | All text inputs         |

---

## KYC Flow

Vendor-only. Triggered immediately after registration, before the vendor home screen is accessible.

### Steps

```
/register/kyc          Step 0: Personal details
  └── /register/kyc/document   Step 1: Document upload
        └── /register/kyc/selfie   Step 2: Selfie
```

### Bloc events/states

```
KycPersonalDetailsSubmitted → KycLoading → KycStepCompleted(step: 0)
KycDocumentUploaded         → KycLoading → KycStepCompleted(step: 1)
KycSelfieUploaded           → KycLoading → KycSubmitted
```

Each screen listens to `BlocListener` and pushes to the next route on `KycStepCompleted`. On `KycSubmitted` the screen shows an "Under Review" banner and the route guard keeps the vendor locked to the KYC sub-tree until `kycStatus` changes to `'approved'`.

### Permissions

`permission_handler` requests camera permission before opening the camera picker. On document upload, `Permission.photos` (iOS) / `Permission.storage` (Android) is requested for gallery access. Denial shows an inline error; the user can re-request from the sheet.

### File upload

Documents and selfies are uploaded as `multipart/form-data` via Dio:

```dart
final formData = FormData.fromMap({
  'file': await MultipartFile.fromFile(filePath, filename: basename(filePath)),
  'documentType': documentType,
});
await _apiClient.dio.post(ApiEndpoints.kycDocument, data: formData);
```

---

## API Contract

### Response envelope

```json
// Success (2xx)
{ "success": true, "data": { ... }, "message": "..." }

// Validation error (422)
{
  "success": false,
  "message": "Validation failed",
  "errors": { "email": "Already taken", "password": "Too short" }
}

// Error (4xx / 5xx)
{ "success": false, "message": "Human-readable description" }
```

### Endpoints

| Method | Path                       | Auth | Description                  |
|--------|----------------------------|------|------------------------------|
| POST   | `/auth/login`              | No   | Login                        |
| POST   | `/auth/register`           | No   | Register (buyer or vendor)   |
| POST   | `/auth/refresh`            | No   | Refresh JWT tokens           |
| POST   | `/auth/forgot-password`    | No   | Send reset email             |
| GET    | `/auth/me`                 | Yes  | Current user profile         |
| POST   | `/kyc/personal-details`    | Yes  | KYC step 1                   |
| POST   | `/kyc/document`            | Yes  | KYC step 2 (multipart)       |
| POST   | `/kyc/selfie`              | Yes  | KYC step 3 (multipart)       |
| GET    | `/kyc/status`              | Yes  | Poll KYC review status       |
| GET    | `/products`                | No   | Product listing              |
| GET/POST/PUT/DELETE | `/products/:id` | Yes | Product CRUD (vendor) |
| GET    | `/transactions`            | Yes  | Transaction list             |
| GET    | `/invoices`                | Yes  | Invoice list                 |
| GET    | `/referral`                | Yes  | Referral code + stats        |
