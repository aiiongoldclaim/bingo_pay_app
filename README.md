# Bingo Pay

Multi-vendor marketplace mobile app for iOS and Android, built with Flutter.

**Two user roles:**
- **Buyer** — browse products, make purchases, view transactions, refer friends, download invoices
- **Vendor** — manage product listings, complete KYC on registration, view transactions and invoices

---

## Quick Start

### Prerequisites

- Flutter SDK `^3.10.8` (see `.fvmrc` or `pubspec.yaml` for exact version)
- Dart SDK `^3.10.8`
- Android Studio or Xcode for platform tooling

### Setup

```bash
# Install dependencies
flutter pub get

# Generate DI config and JSON serializers (required after any @injectable change)
dart run build_runner build --delete-conflicting-outputs
```

### Run

Three flavors are available. Always specify both `--flavor` and `-t` (target entry point):

```bash
# Development
flutter run --flavor dev -t lib/main_dev.dart

# Staging
flutter run --flavor staging -t lib/main_staging.dart

# Production
flutter run --flavor prod -t lib/main_prod.dart
```

### Test

```bash
# All tests
flutter test

# Single file
flutter test test/unit/auth/login_usecase_test.dart

# Static analysis
flutter analyze
```

---

## Flavors

| Flavor  | App Name       | API Base URL                       | Logging | Analytics |
|---------|----------------|------------------------------------|---------|-----------|
| dev     | Bingo Pay DEV  | `https://dev-api.bingopay.com/v1`  | on      | off       |
| staging | Bingo Pay STG  | `https://stg-api.bingopay.com/v1`  | on      | off       |
| prod    | Bingo Pay      | `https://api.bingopay.com/v1`      | off     | on        |

---

## Project Structure

```
lib/
├── app/                        # Root widget, bootstrap, BLoC observer
├── core/                       # Shared infrastructure (never imports features/)
│   ├── api/                    # Dio client + interceptors
│   ├── config/                 # FlavorConfig, AppConfig, AppConstants
│   ├── di/                     # GetIt + Injectable DI setup
│   ├── error/                  # Failures, Exceptions, ErrorHandler
│   ├── network/                # ConnectivityService
│   ├── router/                 # GoRouter, route constants, route guard
│   ├── storage/                # SecureStorageService, PreferencesService
│   ├── theme/                  # Colors, dimensions, text styles, ThemeData
│   ├── utils/                  # Validators, formatters, extensions
│   └── widgets/                # AppButton, AppTextField, AppImagePicker, etc.
└── features/
    ├── auth/                   # Login, register, forgot password, KYC wizard
    ├── home/                   # Role-specific dashboards (buyer + vendor)
    ├── product_management/     # Vendor: CRUD product listings
    ├── transactions/           # Buyer + Vendor: transaction list + detail
    ├── refer_and_earn/         # Referral code + share sheet
    └── invoices/               # Invoice list + download
```

Each feature follows the same three-layer layout — see [Architecture](docs/ARCHITECTURE.md#feature-structure).

---

## Authentication & KYC

- **Buyers** register and land directly on the buyer home screen.
- **Vendors** must complete a 3-step KYC wizard after registration before accessing the vendor shell:
  1. Personal details (name, date of birth, address)
  2. Government document upload (camera or gallery)
  3. Selfie capture (front camera)
- The route guard enforces KYC completion — a vendor with `kycStatus == 'pending'` or `'under_review'` is locked to `/register/kyc` regardless of where they try to navigate.

---

## Code Generation

Two generators run via `build_runner`:

| Generator           | What it produces                              | Trigger when                          |
|---------------------|-----------------------------------------------|---------------------------------------|
| `injectable_generator` | `lib/core/di/injection.config.dart`        | Any `@injectable` class added/removed |
| `json_serializable` | `*.g.dart` files next to `@JsonSerializable` models | Any model field changed           |

```bash
dart run build_runner build --delete-conflicting-outputs
```

Never edit generated files by hand.

---

## Testing

| Layer      | Location              | Tool                      |
|------------|-----------------------|---------------------------|
| Unit       | `test/unit/`          | `flutter_test`            |
| BLoC       | `test/bloc/`          | `bloc_test` + `mocktail`  |
| Widget     | `test/widget/`        | `flutter_test` + `mocktail` |
| Integration| `integration_test/`   | `integration_test`        |

Current coverage: **56 tests, all passing**.

---

## Further Reading

- [Architecture](docs/ARCHITECTURE.md) — layer design, DI, error handling, routing, state management
- [Development Guide](docs/DEVELOPMENT.md) — adding features, conventions, build commands
- [Architecture Spec](docs/superpowers/specs/2026-06-09-bingo-pay-architecture-design.md) — original design document
