# Two-Step Vendor Registration + Real Register APIs

## Context

Registration currently has a single `RegisterScreen` with Full Name / Email / Password / Confirm Password / role picker (Buyer or Vendor), backed by `AuthBloc._onRegister`, a mock handler that fabricates a `UserEntity` locally and never calls a real API.

The product now has two real, separate backend register endpoints — one for buyers (`USER` role) and one for vendors (`VENDOR` role) — with different payloads and response shapes. Vendor registration needs business details that buyers don't have, so the vendor flow becomes a 2-step wizard (Personal Details → Business Details) while buyer registration stays a single step.

## APIs

### Buyer register

```
POST {apiBaseUrl}/api/bingold/bingopay/auth/register
Headers: x-api-key: <apiKey>
Body: { firstName, lastName, password, countryId, email, phoneNumber }
```

Response (200):
```json
{
  "success": true,
  "message": "Customer registered",
  "data": {
    "bingold": {
      "status": 200, "error": false, "message": "User registered successfully",
      "data": { "id": "...", "email": "...", "userRole": "USER", "clientId": "...", "token": "..." }
    },
    "profile": {
      "email_verified": false, "phone_verified": false, "kyc_status": "pending",
      "id": 7, "uuid": "...", "email": "...", "phone": "...",
      "first_name": "...", "last_name": "...", "bingold_user_id": null,
      "password_hash": "...", "account_type": "customer", "status": "active",
      "updated_at": "...", "created_at": "..."
    },
    "token": "..."
  }
}
```
`data.token` and `data.bingold.data.token` are the same value. `profile.password_hash` must never be read or stored by the client.

### Vendor register

```
POST {apiBaseUrl}/api/v1/common/vendors/sso/register
Headers: x-api-key: <apiKey>
Body: { fullName, email, phone, password, countryId, shopName, shopSlug, businessName, description, gstNumber, panNumber, supportEmail, supportPhone }
```

Response (200):
```json
{
  "success": true,
  "message": "Vendor registered",
  "data": {
    "vendor": {
      "uuid": "...", "shopName": "...", "shopSlug": "...", "businessName": "...",
      "merchantCode": "MER0861525", "status": "pending", "kycStatus": "pending"
    },
    "accessToken": "...",
    "tokenType": "Bearer",
    "bingoldToken": "...",
    "bingold": {
      "status": 200, "error": false, "message": "User registered successfully",
      "data": { "id": "...", "email": "...", "userRole": "VENDOR", "clientId": "...", "token": "..." }
    }
  }
}
```
`data.bingoldToken` equals `data.bingold.data.token` (longer-lived, ~7 days). `data.accessToken` is a shorter-lived (~1hr) vendor-service-specific token.

Neither response includes a `refreshToken`.

### Decisions confirmed with user

- Buyer registration stays single-step; only Vendor gets the 2-step (Personal → Business) wizard.
- The `Authorization: Bearer ...` header present in both example curls is a Swagger artifact, not required — both register calls are unauthenticated aside from `x-api-key`.
- `x-api-key` is sent as a default header on every API request (added to `ApiClient`'s base headers), not just register.
- Dev flavor's `apiBaseUrl` is replaced with `https://admin-blog.bingold.to/api` and a new `apiKey` flavor variable holds the given key. Staging/prod keep their current placeholder URLs (no key) until real values are supplied separately.
- Personal Details step always asks **First Name + Last Name** for both roles (not a single "fullName" field), for UI consistency. For vendor's API call, the two are joined as `'$firstName $lastName'.trim()` into `fullName`.
- Vendor Business Details: only `shopName`, `shopSlug`, `businessName` are required. `description`, `gstNumber`, `panNumber`, `supportEmail`, `supportPhone` are optional.
- `shopSlug` auto-generates from `shopName` as the vendor types (slugify: lowercase, non-alphanumeric → hyphen, collapse/trim hyphens), remaining editable.
- The stored session token is: vendor → `data.accessToken`; buyer → `data.token`. Both are saved under the existing single `access_token` secure-storage key — no role-aware logic needed in `AuthInterceptor`. Vendor's longer-lived `bingoldToken` is not stored or used (can be revisited later if a vendor-service-specific 401 needs the shorter token refreshed against the longer one).
- `countryId` is hardcoded to `"91"` in the datasource — not exposed in the UI (no country picker exists in the app today).
- Buyer's `kycStatus` is set to `'not_required'` client-side, ignoring `profile.kyc_status` from the response — buyer KYC isn't part of today's flow (see `docs/superpowers/specs/2026-06-09-bingo-pay-architecture-design.md` for the existing vendor-only KYC wizard).
- No `refreshToken` exists in either response; `AuthRepositoryImpl` stores the access token only, passing an empty string as `refreshToken` to the existing `SecureStorageService.saveTokens`-style call rather than adding new storage methods.
- The 7 pre-existing failing tests in `auth_bloc_test.dart` (login/forgotPassword/checkAuthStatus mock handlers missing `AuthLoading` emissions) are out of scope for this change.

## Design

### Config & network

- `lib/main_dev.dart`: `apiBaseUrl` → `https://admin-blog.bingold.to/api`; add `apiKey: 'GTP_2026_PDA_V1_API_KEY_ASDF'` to `variables`.
- `lib/core/config/app_config.dart`: add `static String get apiKey => FlavorConfig.instance.variables['apiKey'] as String;`
- `lib/core/api/api_client.dart`: add `'x-api-key': AppConfig.apiKey` to the `BaseOptions.headers` map.
- `lib/core/api/api_endpoints.dart`: add
  ```dart
  static const String registerBuyer = '/api/bingold/bingopay/auth/register';
  static const String registerVendor = '/api/v1/common/vendors/sso/register';
  ```
  (`register` constant removed once nothing references it.)

### Domain layer

- Delete `RegisterUseCase` / `RegisterParams`. Add:
  - `RegisterBuyerUseCase(BuyerRegisterParams)` — `firstName, lastName, email, phone, password`
  - `RegisterVendorUseCase(VendorRegisterParams)` — `firstName, lastName, email, phone, password, shopName, shopSlug, businessName, description?, gstNumber?, panNumber?, supportEmail?, supportPhone?`
- `AuthRepository` interface: replace `register(...)` with `registerBuyer(...)` and `registerVendor(...)`, both returning `Either<Failure, UserEntity>`.
- `UserEntity` is unchanged (id, email, name, role, kycStatus) — vendor-specific fields (`shopName`, `merchantCode`, `businessName`, vendor `status`) are not modeled on the entity in this change; they can be fetched from a vendor profile endpoint later if a screen needs them.

### Data layer

- New `lib/features/auth/data/models/register_result_model.dart`:
  ```dart
  class RegisterResultModel {
    final String accessToken;
    final UserModel user;
  }
  ```
  Built via two factory constructors that hand-parse the irregular nested JSON (no `json_serializable` — the two shapes don't share a schema):
  - `RegisterResultModel.fromBuyerJson(json, {required firstName, required lastName})`
  - `RegisterResultModel.fromVendorJson(json, {required firstName, required lastName})`
- `AuthRemoteDataSource`: replace `register(...)` with:
  - `registerBuyer({firstName, lastName, email, phone, password})` → POST `ApiEndpoints.registerBuyer` with `{firstName, lastName, password, countryId: '91', email, phoneNumber: phone}`, parse via `RegisterResultModel.fromBuyerJson`.
  - `registerVendor({...all vendor params})` → POST `ApiEndpoints.registerVendor` with `{fullName: '$firstName $lastName'.trim(), email, phone, password, countryId: '91', shopName, shopSlug, businessName, description, gstNumber, panNumber, supportEmail, supportPhone}`, parse via `RegisterResultModel.fromVendorJson`.
- `AuthRepositoryImpl`: replace `register(...)` with `registerBuyer(...)` / `registerVendor(...)`, each calling the matching datasource method, then `_local.saveTokens(accessToken: result.accessToken, refreshToken: '')` and `_local.saveUser(result.user)`, returning `Right(result.user)` or mapping exceptions to `Failure` as today.

### Presentation — Bloc

- `auth_event.dart`: remove `RegisterRequested`; add `BuyerRegisterRequested` and `VendorRegisterRequested` (fields as in domain layer above).
- `auth_bloc.dart`: register `on<BuyerRegisterRequested>` and `on<VendorRegisterRequested>`, each: `emit(const AuthLoading())`, call the matching use case, `emit(AuthAuthenticated(user))` or `emit(AuthError(failure))`.

### Presentation — UI

`register_screen.dart` restructure:
- Role picker (Buyer/Vendor cards, same visuals as today) shown first.
- **Buyer**: single-step form — First Name, Last Name, Email, Phone, Password, Confirm Password — submit dispatches `BuyerRegisterRequested`.
- **Vendor**: 2-step wizard within the same screen using local `_step` (0/1) state:
  - Step 0 — Personal Details: First Name, Last Name, Email, Phone, Password, Confirm Password, "Next" (client-side validation, advances `_step`, no API call).
  - Step 1 — Business Details: Shop Name, Shop Slug (auto-filled via `slugify(shopName)`, editable), Business Name, Description (optional), GST Number (optional), PAN Number (optional), Support Email (optional), Support Phone (optional), "Back" / "Create Account" (submit dispatches `VendorRegisterRequested` with data from both steps).
  - Reuses the existing `KycStepIndicator` widget (`lib/features/auth/presentation/widgets/kyc_step_indicator.dart`) with `totalSteps: 2` for the "Step X of 2" indicator — it's already generic.
- Single screen, not separate routes per step (unlike the KYC wizard) — there's no account yet to resume across app restarts, so route-level persistence isn't needed here.

New validators in `lib/core/utils/validators.dart`:
- `Validators.phone` — required, 10-digit Indian mobile number.
- `Validators.gst` — optional; if non-empty, must match standard 15-character GST format.
- `Validators.pan` — optional; if non-empty, must match standard 10-character PAN format.

New utility `lib/core/utils/slugify.dart` (or similar): `String slugify(String input)` — lowercase, non-alphanumeric → hyphen, collapse/trim repeated hyphens.

### Error handling

No changes — `ErrorInterceptor` (`lib/core/api/interceptors/error_interceptor.dart`) already extracts a top-level `message` from any non-2xx JSON body and maps by status code to `AuthException` / `ValidationException` / `ServerException`, which both new endpoints are expected to follow on failure.

### Testing

- Update the existing register-related bloc test(s) in `test/bloc/auth_bloc_test.dart` to cover `BuyerRegisterRequested` and `VendorRegisterRequested` against mocked `RegisterBuyerUseCase`/`RegisterVendorUseCase`, replacing the old `RegisterRequested` coverage.
- Add unit tests for `Validators.phone`, `Validators.gst`, `Validators.pan`, and `slugify`.
- The 7 pre-existing failing tests (login/forgotPassword/checkAuthStatus stub handlers) are explicitly out of scope and left as-is.

## Out of scope

- Staging/prod base URLs and API keys (left as current placeholders until real values are provided).
- Token refresh flow (neither API returns a refresh token; not designed here).
- Vendor-specific fields (`shopName`, `merchantCode`, vendor `status`) on `UserEntity` or any vendor profile screen consuming them.
- Fixing the pre-existing `AuthBloc` mock-handler test failures unrelated to register.
