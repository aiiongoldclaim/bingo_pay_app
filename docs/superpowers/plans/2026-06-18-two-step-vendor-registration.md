# Two-Step Vendor Registration Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Replace the mock `RegisterRequested` flow with real buyer and vendor register APIs, and turn vendor registration into a 2-step (Personal Details → Business Details) wizard while buyer registration stays single-step.

**Architecture:** Two new use cases (`RegisterBuyerUseCase`, `RegisterVendorUseCase`) replace `RegisterUseCase`; the datasource gets `registerBuyer`/`registerVendor` methods hitting two different real endpoints with irregular response shapes parsed by a hand-written `RegisterResultModel`; the bloc gets two new events/handlers; the UI becomes role-aware, reusing the existing `KycStepIndicator` for the vendor wizard.

**Tech Stack:** Flutter, flutter_bloc, get_it/injectable, dio, fpdart (Either), equatable, mocktail/bloc_test for tests.

## Global Constraints

- Buyer register: `POST {apiBaseUrl}/api/bingold/bingopay/auth/register`, body `{firstName, lastName, password, countryId, email, phoneNumber}`.
- Vendor register: `POST {apiBaseUrl}/api/v1/common/vendors/sso/register`, body `{fullName, email, phone, password, countryId, shopName, shopSlug, businessName, description, gstNumber, panNumber, supportEmail, supportPhone}`.
- `countryId` is always the literal string `"91"`, hardcoded, never user-facing.
- Every request sends header `x-api-key: <AppConfig.apiKey>`. No `Authorization` header is needed for either register call.
- Dev flavor `apiBaseUrl` = `https://admin-blog.bingold.to/api`; dev flavor `apiKey` = `GTP_2026_PDA_V1_API_KEY_ASDF`. Staging/prod flavors are untouched.
- Stored session token: vendor → response `data.accessToken`; buyer → response `data.token`. Both saved under the existing single access-token storage key. No refresh token exists in either response — pass `refreshToken: ''` to the existing `saveTokens` call.
- Vendor's `data.bingoldToken` is parsed nowhere — not needed.
- Buyer `kycStatus` is always `'not_required'` client-side (ignore `profile.kyc_status`).
- Vendor `kycStatus` comes from response `data.vendor.kycStatus`.
- `UserEntity.name` is never read from the API response — always built client-side from the entered `firstName`/`lastName`.
- Full spec: `docs/superpowers/specs/2026-06-18-two-step-vendor-registration-design.md`.

---

### Task 1: Config & network plumbing

**Files:**
- Modify: `lib/main_dev.dart`
- Modify: `lib/core/config/app_config.dart`
- Modify: `lib/core/api/api_client.dart`
- Modify: `lib/core/api/api_endpoints.dart`
- Test: `test/unit/app_config_test.dart`

**Interfaces:**
- Produces: `AppConfig.apiKey` (`static String`), `ApiEndpoints.registerBuyer`, `ApiEndpoints.registerVendor` (both `static const String`).

- [ ] **Step 1: Write the failing test**

Add to `test/unit/app_config_test.dart`, inside the `group('AppConfig', () { ... })` block, after the existing `apiBaseUrl` tests:

```dart
    test('apiKey reads from FlavorConfig variables', () {
      FlavorConfig(
        name: 'dev',
        color: Colors.green,
        variables: const {
          'apiBaseUrl': 'https://admin-blog.bingold.to/api',
          'apiKey': 'GTP_2026_PDA_V1_API_KEY_ASDF',
        },
      );

      expect(AppConfig.apiKey, 'GTP_2026_PDA_V1_API_KEY_ASDF');
    });
```

- [ ] **Step 2: Run test to verify it fails**

Run: `flutter test test/unit/app_config_test.dart`
Expected: FAIL — `The getter 'apiKey' isn't defined for the type 'AppConfig'`

- [ ] **Step 3: Implement**

In `lib/core/config/app_config.dart`, add alongside `apiBaseUrl`:

```dart
  static String get apiKey =>
      FlavorConfig.instance.variables['apiKey'] as String;
```

In `lib/main_dev.dart`, replace the `variables` map:

```dart
    variables: const {
      'apiBaseUrl': 'https://admin-blog.bingold.to/api',
      'apiKey': 'GTP_2026_PDA_V1_API_KEY_ASDF',
      'appName': 'Bingo Pay DEV',
      'enableLogging': true,
      'enableAnalytics': false,
    },
```

In `lib/core/api/api_client.dart`, add the header inside `BaseOptions.headers`:

```dart
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'x-api-key': AppConfig.apiKey,
        },
```

In `lib/core/api/api_endpoints.dart`, remove the now-unused `register` constant and add:

```dart
  static const String registerBuyer = '/api/bingold/bingopay/auth/register';
  static const String registerVendor = '/api/v1/common/vendors/sso/register';
```

- [ ] **Step 4: Run test to verify it passes**

Run: `flutter test test/unit/app_config_test.dart`
Expected: PASS (all tests in file)

- [ ] **Step 5: Commit**

```bash
git add lib/main_dev.dart lib/core/config/app_config.dart lib/core/api/api_client.dart lib/core/api/api_endpoints.dart test/unit/app_config_test.dart
git commit -m "feat(config): point dev flavor at register API host and add x-api-key header"
```

---

### Task 2: Validators and slugify utility

**Files:**
- Modify: `lib/core/utils/validators.dart`
- Create: `lib/core/utils/slugify.dart`
- Modify: `test/unit/validators_test.dart`
- Create: `test/unit/slugify_test.dart`

**Interfaces:**
- Produces: `Validators.phone(String?)`, `Validators.gst(String?)`, `Validators.pan(String?)` (all `String? Function(String?)`), `String slugify(String input)`.

- [ ] **Step 1: Write the failing tests**

Append to `test/unit/validators_test.dart`, inside `main()`:

```dart
  group('Validators.phone', () {
    test('returns error for empty value', () {
      expect(Validators.phone(''), isNotNull);
      expect(Validators.phone(null), isNotNull);
    });

    test('returns error for non-10-digit value', () {
      expect(Validators.phone('12345'), isNotNull);
      expect(Validators.phone('98765432101'), isNotNull);
    });

    test('returns null for a valid 10-digit number', () {
      expect(Validators.phone('9876543210'), isNull);
    });
  });

  group('Validators.gst', () {
    test('returns null when empty (optional field)', () {
      expect(Validators.gst(''), isNull);
      expect(Validators.gst(null), isNull);
    });

    test('returns error for malformed value', () {
      expect(Validators.gst('not-a-gst'), isNotNull);
    });

    test('returns null for a valid GST number', () {
      expect(Validators.gst('22AAAAA0000A1Z5'), isNull);
    });
  });

  group('Validators.pan', () {
    test('returns null when empty (optional field)', () {
      expect(Validators.pan(''), isNull);
      expect(Validators.pan(null), isNull);
    });

    test('returns error for malformed value', () {
      expect(Validators.pan('short'), isNotNull);
    });

    test('returns null for a valid PAN number', () {
      expect(Validators.pan('AAAAA0000A'), isNull);
    });
  });
```

Create `test/unit/slugify_test.dart`:

```dart
import 'package:bingo_pay/core/utils/slugify.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('slugify', () {
    test('lowercases and replaces spaces with hyphens', () {
      expect(slugify('Acme Store'), 'acme-store');
    });

    test('strips non-alphanumeric characters', () {
      expect(slugify("Acme's Store!!"), 'acme-s-store');
    });

    test('collapses repeated hyphens', () {
      expect(slugify('Acme   Store--Top'), 'acme-store-top');
    });

    test('trims leading and trailing hyphens', () {
      expect(slugify('-Acme Store-'), 'acme-store');
    });
  });
}
```

- [ ] **Step 2: Run tests to verify they fail**

Run: `flutter test test/unit/validators_test.dart test/unit/slugify_test.dart`
Expected: FAIL — `Validators.phone`/`gst`/`pan` undefined, and `slugify_test.dart` fails to import a nonexistent `slugify.dart`.

- [ ] **Step 3: Implement**

In `lib/core/utils/validators.dart`, add inside the `Validators` class:

```dart
  static String? phone(String? value) {
    if (value == null || value.trim().isEmpty) return 'Phone number is required';
    final phoneRegex = RegExp(r'^[6-9]\d{9}$');
    if (!phoneRegex.hasMatch(value.trim())) {
      return 'Enter a valid 10-digit phone number';
    }
    return null;
  }

  static String? gst(String? value) {
    if (value == null || value.trim().isEmpty) return null;
    final gstRegex =
        RegExp(r'^[0-9]{2}[A-Z]{5}[0-9]{4}[A-Z]{1}[1-9A-Z]{1}Z[0-9A-Z]{1}$');
    if (!gstRegex.hasMatch(value.trim().toUpperCase())) {
      return 'Enter a valid GST number';
    }
    return null;
  }

  static String? pan(String? value) {
    if (value == null || value.trim().isEmpty) return null;
    final panRegex = RegExp(r'^[A-Z]{5}[0-9]{4}[A-Z]{1}$');
    if (!panRegex.hasMatch(value.trim().toUpperCase())) {
      return 'Enter a valid PAN number';
    }
    return null;
  }
```

Create `lib/core/utils/slugify.dart`:

```dart
String slugify(String input) {
  final lowercased = input.toLowerCase().trim();
  final hyphenated = lowercased.replaceAll(RegExp(r'[^a-z0-9]+'), '-');
  final collapsed = hyphenated.replaceAll(RegExp(r'-+'), '-');
  return collapsed.replaceAll(RegExp(r'^-|-$'), '');
}
```

- [ ] **Step 4: Run tests to verify they pass**

Run: `flutter test test/unit/validators_test.dart test/unit/slugify_test.dart`
Expected: PASS

- [ ] **Step 5: Commit**

```bash
git add lib/core/utils/validators.dart lib/core/utils/slugify.dart test/unit/validators_test.dart test/unit/slugify_test.dart
git commit -m "feat(validators): add phone/gst/pan validators and shop slug slugify utility"
```

---

### Task 3: RegisterResultModel (response parsing)

**Files:**
- Create: `lib/features/auth/data/models/register_result_model.dart`
- Create: `test/unit/auth/register_result_model_test.dart`

**Interfaces:**
- Consumes: `UserModel` (`lib/features/auth/data/models/user_model.dart`) — constructor `UserModel({required id, required email, required name, required role, required kycStatus})`.
- Produces: `RegisterResultModel { final String accessToken; final UserModel user; }` with `RegisterResultModel.fromBuyerJson(Map<String, dynamic> json, {required String firstName, required String lastName})` and `RegisterResultModel.fromVendorJson(Map<String, dynamic> json, {required String firstName, required String lastName})`. Both factories read from the `data` envelope already unwrapped (i.e. caller passes `response.data['data']`, matching how `AuthResponseModel.fromJson` is called today).

- [ ] **Step 1: Write the failing test**

Create `test/unit/auth/register_result_model_test.dart`:

```dart
import 'package:bingo_pay/features/auth/data/models/register_result_model.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('RegisterResultModel.fromBuyerJson', () {
    final json = {
      'bingold': {
        'status': 200,
        'error': false,
        'message': 'User registered successfully',
        'data': {
          'id': '9acb719a-1132-44c7-abbe-3c07291b97d7',
          'email': 'john1@example.com',
          'userRole': 'USER',
          'clientId': 'e4cd09e7-6aff-11f1-9946-0af7521c2b6b',
          'token': 'buyer-jwt',
        },
      },
      'profile': {
        'email_verified': false,
        'phone_verified': false,
        'kyc_status': 'pending',
        'id': 7,
        'uuid': '9acb719a-1132-44c7-abbe-3c07291b97d7',
        'email': 'john1@example.com',
        'phone': '9876543210',
        'first_name': 'John',
        'last_name': 'Doe',
        'bingold_user_id': null,
        'password_hash': 'should-never-be-read',
        'account_type': 'customer',
        'status': 'active',
        'updated_at': '2026-06-18T10:24:31.773Z',
        'created_at': '2026-06-18T10:24:31.773Z',
      },
      'token': 'buyer-jwt',
    };

    test('extracts accessToken from data.token', () {
      final result = RegisterResultModel.fromBuyerJson(
        json,
        firstName: 'John',
        lastName: 'Doe',
      );
      expect(result.accessToken, 'buyer-jwt');
    });

    test('builds a buyer UserModel with not_required kycStatus', () {
      final result = RegisterResultModel.fromBuyerJson(
        json,
        firstName: 'John',
        lastName: 'Doe',
      );
      expect(result.user.id, '9acb719a-1132-44c7-abbe-3c07291b97d7');
      expect(result.user.email, 'john1@example.com');
      expect(result.user.name, 'John Doe');
      expect(result.user.role, 'buyer');
      expect(result.user.kycStatus, 'not_required');
    });
  });

  group('RegisterResultModel.fromVendorJson', () {
    final json = {
      'vendor': {
        'uuid': 'dd4e8bf9-9ad6-4940-b373-f99f28a6dae2',
        'shopName': 'Acme Store',
        'shopSlug': 'acme-store-top',
        'businessName': 'Acme Pvt Ltd',
        'merchantCode': 'MER0861525',
        'status': 'pending',
        'kycStatus': 'pending',
      },
      'accessToken': 'vendor-jwt',
      'tokenType': 'Bearer',
      'bingoldToken': 'bingold-jwt',
      'bingold': {
        'status': 200,
        'error': false,
        'message': 'User registered successfully',
        'data': {
          'id': 'dd4e8bf9-9ad6-4940-b373-f99f28a6dae2',
          'email': 'owner13@acme.com',
          'userRole': 'VENDOR',
          'clientId': '92c05ab6-6af7-11f1-9946-0af7521c2b6b',
          'token': 'bingold-jwt',
        },
      },
    };

    test('extracts accessToken from data.accessToken (not bingoldToken)', () {
      final result = RegisterResultModel.fromVendorJson(
        json,
        firstName: 'Acme',
        lastName: 'Owner',
      );
      expect(result.accessToken, 'vendor-jwt');
    });

    test('builds a vendor UserModel with kycStatus from vendor.kycStatus', () {
      final result = RegisterResultModel.fromVendorJson(
        json,
        firstName: 'Acme',
        lastName: 'Owner',
      );
      expect(result.user.id, 'dd4e8bf9-9ad6-4940-b373-f99f28a6dae2');
      expect(result.user.email, 'owner13@acme.com');
      expect(result.user.name, 'Acme Owner');
      expect(result.user.role, 'vendor');
      expect(result.user.kycStatus, 'pending');
    });
  });
}
```

- [ ] **Step 2: Run test to verify it fails**

Run: `flutter test test/unit/auth/register_result_model_test.dart`
Expected: FAIL — cannot find package import `register_result_model.dart`

- [ ] **Step 3: Implement**

Create `lib/features/auth/data/models/register_result_model.dart`:

```dart
import 'user_model.dart';

class RegisterResultModel {
  final String accessToken;
  final UserModel user;

  const RegisterResultModel({required this.accessToken, required this.user});

  factory RegisterResultModel.fromBuyerJson(
    Map<String, dynamic> json, {
    required String firstName,
    required String lastName,
  }) {
    final bingoldData = json['bingold']['data'] as Map<String, dynamic>;
    return RegisterResultModel(
      accessToken: json['token'] as String,
      user: UserModel(
        id: bingoldData['id'] as String,
        email: bingoldData['email'] as String,
        name: '$firstName $lastName'.trim(),
        role: 'buyer',
        kycStatus: 'not_required',
      ),
    );
  }

  factory RegisterResultModel.fromVendorJson(
    Map<String, dynamic> json, {
    required String firstName,
    required String lastName,
  }) {
    final vendor = json['vendor'] as Map<String, dynamic>;
    final bingoldData = json['bingold']['data'] as Map<String, dynamic>;
    return RegisterResultModel(
      accessToken: json['accessToken'] as String,
      user: UserModel(
        id: vendor['uuid'] as String,
        email: bingoldData['email'] as String,
        name: '$firstName $lastName'.trim(),
        role: 'vendor',
        kycStatus: vendor['kycStatus'] as String,
      ),
    );
  }
}
```

- [ ] **Step 4: Run test to verify it passes**

Run: `flutter test test/unit/auth/register_result_model_test.dart`
Expected: PASS

- [ ] **Step 5: Commit**

```bash
git add lib/features/auth/data/models/register_result_model.dart test/unit/auth/register_result_model_test.dart
git commit -m "feat(auth): parse buyer/vendor register responses into RegisterResultModel"
```

---

### Task 4: Domain layer — repository interface and use cases

**Files:**
- Modify: `lib/features/auth/domain/repositories/auth_repository.dart`
- Delete: `lib/features/auth/domain/usecases/register_usecase.dart`
- Create: `lib/features/auth/domain/usecases/register_buyer_usecase.dart`
- Create: `lib/features/auth/domain/usecases/register_vendor_usecase.dart`
- Test: `test/unit/auth/register_usecases_test.dart`

**Interfaces:**
- Consumes: `UserEntity` (`lib/features/auth/domain/entities/user_entity.dart`, unchanged), `Failure` (`lib/core/error/failures.dart`).
- Produces: `AuthRepository.registerBuyer({required firstName, required lastName, required email, required phone, required password})` and `AuthRepository.registerVendor({required firstName, required lastName, required email, required phone, required password, required shopName, required shopSlug, required businessName, String? description, String? gstNumber, String? panNumber, String? supportEmail, String? supportPhone})`, both `Future<Either<Failure, UserEntity>>`. `RegisterBuyerUseCase(BuyerRegisterParams)`, `RegisterVendorUseCase(VendorRegisterParams)`, both `Future<Either<Failure, UserEntity>> call(params)`.

This task only changes the interface and use cases; `AuthRepositoryImpl` still implements the old `register(...)` method at this point, so it will not compile standalone — Task 4's test mocks `AuthRepository` directly (not the impl), and the whole project compiles again once Task 5 updates the impl. Run the two tasks back to back.

- [ ] **Step 1: Write the failing test**

Create `test/unit/auth/register_usecases_test.dart`:

```dart
import 'package:bingo_pay/core/error/failures.dart';
import 'package:bingo_pay/features/auth/domain/entities/user_entity.dart';
import 'package:bingo_pay/features/auth/domain/repositories/auth_repository.dart';
import 'package:bingo_pay/features/auth/domain/usecases/register_buyer_usecase.dart';
import 'package:bingo_pay/features/auth/domain/usecases/register_vendor_usecase.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:mocktail/mocktail.dart';

class MockAuthRepository extends Mock implements AuthRepository {}

void main() {
  const user = UserEntity(
    id: '1', email: 'a@b.com', name: 'Alice Doe',
    role: 'buyer', kycStatus: 'not_required',
  );

  group('RegisterBuyerUseCase', () {
    test('delegates to repository.registerBuyer with params', () async {
      final repo = MockAuthRepository();
      when(() => repo.registerBuyer(
            firstName: 'Alice',
            lastName: 'Doe',
            email: 'a@b.com',
            phone: '9876543210',
            password: 'password1',
          )).thenAnswer((_) async => const Right(user));

      final useCase = RegisterBuyerUseCase(repo);
      final result = await useCase(const BuyerRegisterParams(
        firstName: 'Alice',
        lastName: 'Doe',
        email: 'a@b.com',
        phone: '9876543210',
        password: 'password1',
      ));

      expect(result, const Right<Failure, UserEntity>(user));
    });
  });

  group('RegisterVendorUseCase', () {
    test('delegates to repository.registerVendor with params', () async {
      final repo = MockAuthRepository();
      when(() => repo.registerVendor(
            firstName: 'Acme',
            lastName: 'Owner',
            email: 'owner@acme.com',
            phone: '9876543210',
            password: 'password1',
            shopName: 'Acme Store',
            shopSlug: 'acme-store',
            businessName: 'Acme Pvt Ltd',
            description: null,
            gstNumber: null,
            panNumber: null,
            supportEmail: null,
            supportPhone: null,
          )).thenAnswer((_) async => const Right(user));

      final useCase = RegisterVendorUseCase(repo);
      final result = await useCase(const VendorRegisterParams(
        firstName: 'Acme',
        lastName: 'Owner',
        email: 'owner@acme.com',
        phone: '9876543210',
        password: 'password1',
        shopName: 'Acme Store',
        shopSlug: 'acme-store',
        businessName: 'Acme Pvt Ltd',
      ));

      expect(result, const Right<Failure, UserEntity>(user));
    });
  });
}
```

- [ ] **Step 2: Run test to verify it fails**

Run: `flutter test test/unit/auth/register_usecases_test.dart`
Expected: FAIL — cannot find `register_buyer_usecase.dart` / `register_vendor_usecase.dart`, and `AuthRepository.registerBuyer`/`registerVendor` are undefined.

- [ ] **Step 3: Implement**

In `lib/features/auth/domain/repositories/auth_repository.dart`, replace the `register(...)` method:

```dart
  Future<Either<Failure, UserEntity>> registerBuyer({
    required String firstName,
    required String lastName,
    required String email,
    required String phone,
    required String password,
  });

  Future<Either<Failure, UserEntity>> registerVendor({
    required String firstName,
    required String lastName,
    required String email,
    required String phone,
    required String password,
    required String shopName,
    required String shopSlug,
    required String businessName,
    String? description,
    String? gstNumber,
    String? panNumber,
    String? supportEmail,
    String? supportPhone,
  });
```

Delete `lib/features/auth/domain/usecases/register_usecase.dart`.

Create `lib/features/auth/domain/usecases/register_buyer_usecase.dart`:

```dart
import 'package:equatable/equatable.dart';
import 'package:fpdart/fpdart.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/error/failures.dart';
import '../entities/user_entity.dart';
import '../repositories/auth_repository.dart';

@injectable
class RegisterBuyerUseCase {
  final AuthRepository _repository;
  const RegisterBuyerUseCase(this._repository);

  Future<Either<Failure, UserEntity>> call(BuyerRegisterParams params) =>
      _repository.registerBuyer(
        firstName: params.firstName,
        lastName: params.lastName,
        email: params.email,
        phone: params.phone,
        password: params.password,
      );
}

class BuyerRegisterParams extends Equatable {
  final String firstName;
  final String lastName;
  final String email;
  final String phone;
  final String password;
  const BuyerRegisterParams({
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.phone,
    required this.password,
  });
  @override
  List<Object> get props => [firstName, lastName, email, phone, password];
}
```

Create `lib/features/auth/domain/usecases/register_vendor_usecase.dart`:

```dart
import 'package:equatable/equatable.dart';
import 'package:fpdart/fpdart.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/error/failures.dart';
import '../entities/user_entity.dart';
import '../repositories/auth_repository.dart';

@injectable
class RegisterVendorUseCase {
  final AuthRepository _repository;
  const RegisterVendorUseCase(this._repository);

  Future<Either<Failure, UserEntity>> call(VendorRegisterParams params) =>
      _repository.registerVendor(
        firstName: params.firstName,
        lastName: params.lastName,
        email: params.email,
        phone: params.phone,
        password: params.password,
        shopName: params.shopName,
        shopSlug: params.shopSlug,
        businessName: params.businessName,
        description: params.description,
        gstNumber: params.gstNumber,
        panNumber: params.panNumber,
        supportEmail: params.supportEmail,
        supportPhone: params.supportPhone,
      );
}

class VendorRegisterParams extends Equatable {
  final String firstName;
  final String lastName;
  final String email;
  final String phone;
  final String password;
  final String shopName;
  final String shopSlug;
  final String businessName;
  final String? description;
  final String? gstNumber;
  final String? panNumber;
  final String? supportEmail;
  final String? supportPhone;
  const VendorRegisterParams({
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.phone,
    required this.password,
    required this.shopName,
    required this.shopSlug,
    required this.businessName,
    this.description,
    this.gstNumber,
    this.panNumber,
    this.supportEmail,
    this.supportPhone,
  });
  @override
  List<Object?> get props => [
        firstName, lastName, email, phone, password,
        shopName, shopSlug, businessName,
        description, gstNumber, panNumber, supportEmail, supportPhone,
      ];
}
```

This leaves `AuthRepositoryImpl` (Task 5) and `auth_bloc.dart`/`auth_bloc_test.dart` (Task 6) referencing the now-deleted `register(...)`/`RegisterUseCase` — the project will not compile until Task 5 and Task 6 land. Proceed directly to Task 5 without running the full test suite in between.

- [ ] **Step 4: Run the new test to verify it passes**

Run: `flutter test test/unit/auth/register_usecases_test.dart`
Expected: PASS (this file only depends on the `AuthRepository` interface and the two new use cases, not on `AuthRepositoryImpl`, so it compiles independently of Task 5)

- [ ] **Step 5: Commit**

```bash
git add lib/features/auth/domain/repositories/auth_repository.dart lib/features/auth/domain/usecases/register_buyer_usecase.dart lib/features/auth/domain/usecases/register_vendor_usecase.dart test/unit/auth/register_usecases_test.dart
git rm lib/features/auth/domain/usecases/register_usecase.dart
git commit -m "feat(auth): split register use case into buyer/vendor variants"
```

---

### Task 5: Data layer — datasource and repository implementation

**Files:**
- Modify: `lib/features/auth/data/datasources/auth_remote_datasource.dart`
- Modify: `lib/features/auth/data/repositories/auth_repository_impl.dart`
- Test: `test/unit/auth/auth_repository_impl_register_test.dart`

**Interfaces:**
- Consumes: `RegisterResultModel.fromBuyerJson`/`fromVendorJson` (Task 3), `ApiEndpoints.registerBuyer`/`registerVendor` (Task 1), `AuthLocalDataSource.saveTokens({required accessToken, required refreshToken})` / `saveUser(UserModel)` (unchanged, `lib/features/auth/data/datasources/auth_local_datasource.dart`).
- Produces: `AuthRemoteDataSource.registerBuyer({required firstName, required lastName, required email, required phone, required password})` and `.registerVendor({...})`, both `Future<RegisterResultModel>`. `AuthRepositoryImpl.registerBuyer(...)` / `.registerVendor(...)` satisfying the Task 4 interface.

- [ ] **Step 1: Write the failing test**

Create `test/unit/auth/auth_repository_impl_register_test.dart`:

```dart
import 'package:bingo_pay/features/auth/data/datasources/auth_local_datasource.dart';
import 'package:bingo_pay/features/auth/data/datasources/auth_remote_datasource.dart';
import 'package:bingo_pay/features/auth/data/models/register_result_model.dart';
import 'package:bingo_pay/features/auth/data/models/user_model.dart';
import 'package:bingo_pay/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:mocktail/mocktail.dart';

class MockAuthRemoteDataSource extends Mock implements AuthRemoteDataSource {}
class MockAuthLocalDataSource extends Mock implements AuthLocalDataSource {}

void main() {
  const buyerUser = UserModel(
    id: '1', email: 'a@b.com', name: 'Alice Doe',
    role: 'buyer', kycStatus: 'not_required',
  );
  const vendorUser = UserModel(
    id: '2', email: 'owner@acme.com', name: 'Acme Owner',
    role: 'vendor', kycStatus: 'pending',
  );

  late MockAuthRemoteDataSource remote;
  late MockAuthLocalDataSource local;
  late AuthRepositoryImpl repo;

  setUp(() {
    remote = MockAuthRemoteDataSource();
    local = MockAuthLocalDataSource();
    repo = AuthRepositoryImpl(remote, local);
    when(() => local.saveTokens(
          accessToken: any(named: 'accessToken'),
          refreshToken: any(named: 'refreshToken'),
        )).thenAnswer((_) async {});
    when(() => local.saveUser(any())).thenAnswer((_) async {});
  });

  group('registerBuyer', () {
    test('saves token with empty refreshToken and returns the user', () async {
      when(() => remote.registerBuyer(
            firstName: 'Alice',
            lastName: 'Doe',
            email: 'a@b.com',
            phone: '9876543210',
            password: 'password1',
          )).thenAnswer((_) async => const RegisterResultModel(
            accessToken: 'buyer-jwt',
            user: buyerUser,
          ));

      final result = await repo.registerBuyer(
        firstName: 'Alice',
        lastName: 'Doe',
        email: 'a@b.com',
        phone: '9876543210',
        password: 'password1',
      );

      expect(result, const Right(buyerUser));
      verify(() => local.saveTokens(accessToken: 'buyer-jwt', refreshToken: ''))
          .called(1);
      verify(() => local.saveUser(buyerUser)).called(1);
    });
  });

  group('registerVendor', () {
    test('saves token with empty refreshToken and returns the user', () async {
      when(() => remote.registerVendor(
            firstName: 'Acme',
            lastName: 'Owner',
            email: 'owner@acme.com',
            phone: '9876543210',
            password: 'password1',
            shopName: 'Acme Store',
            shopSlug: 'acme-store',
            businessName: 'Acme Pvt Ltd',
            description: null,
            gstNumber: null,
            panNumber: null,
            supportEmail: null,
            supportPhone: null,
          )).thenAnswer((_) async => const RegisterResultModel(
            accessToken: 'vendor-jwt',
            user: vendorUser,
          ));

      final result = await repo.registerVendor(
        firstName: 'Acme',
        lastName: 'Owner',
        email: 'owner@acme.com',
        phone: '9876543210',
        password: 'password1',
        shopName: 'Acme Store',
        shopSlug: 'acme-store',
        businessName: 'Acme Pvt Ltd',
      );

      expect(result, const Right(vendorUser));
      verify(() => local.saveTokens(accessToken: 'vendor-jwt', refreshToken: ''))
          .called(1);
      verify(() => local.saveUser(vendorUser)).called(1);
    });
  });
}
```

- [ ] **Step 2: Run test to verify it fails**

Run: `flutter test test/unit/auth/auth_repository_impl_register_test.dart`
Expected: FAIL — `registerBuyer`/`registerVendor` undefined on `AuthRemoteDataSource` and `AuthRepositoryImpl`.

- [ ] **Step 3: Implement**

In `lib/features/auth/data/datasources/auth_remote_datasource.dart`, replace the `register(...)` abstract method and its implementation. Abstract interface:

```dart
  Future<RegisterResultModel> registerBuyer({
    required String firstName,
    required String lastName,
    required String email,
    required String phone,
    required String password,
  });

  Future<RegisterResultModel> registerVendor({
    required String firstName,
    required String lastName,
    required String email,
    required String phone,
    required String password,
    required String shopName,
    required String shopSlug,
    required String businessName,
    String? description,
    String? gstNumber,
    String? panNumber,
    String? supportEmail,
    String? supportPhone,
  });
```

Add the import `import '../models/register_result_model.dart';` at the top. Implementation (replacing the old `register` method body):

```dart
  @override
  Future<RegisterResultModel> registerBuyer({
    required String firstName,
    required String lastName,
    required String email,
    required String phone,
    required String password,
  }) async {
    final response = await _dio.post(
      ApiEndpoints.registerBuyer,
      data: {
        'firstName': firstName,
        'lastName': lastName,
        'password': password,
        'countryId': '91',
        'email': email,
        'phoneNumber': phone,
      },
    );
    return RegisterResultModel.fromBuyerJson(
      response.data['data'] as Map<String, dynamic>,
      firstName: firstName,
      lastName: lastName,
    );
  }

  @override
  Future<RegisterResultModel> registerVendor({
    required String firstName,
    required String lastName,
    required String email,
    required String phone,
    required String password,
    required String shopName,
    required String shopSlug,
    required String businessName,
    String? description,
    String? gstNumber,
    String? panNumber,
    String? supportEmail,
    String? supportPhone,
  }) async {
    final response = await _dio.post(
      ApiEndpoints.registerVendor,
      data: {
        'fullName': '$firstName $lastName'.trim(),
        'email': email,
        'phone': phone,
        'password': password,
        'countryId': '91',
        'shopName': shopName,
        'shopSlug': shopSlug,
        'businessName': businessName,
        'description': description,
        'gstNumber': gstNumber,
        'panNumber': panNumber,
        'supportEmail': supportEmail,
        'supportPhone': supportPhone,
      },
    );
    return RegisterResultModel.fromVendorJson(
      response.data['data'] as Map<String, dynamic>,
      firstName: firstName,
      lastName: lastName,
    );
  }
```

In `lib/features/auth/data/repositories/auth_repository_impl.dart`, replace the `register(...)` method:

```dart
  @override
  Future<Either<Failure, UserEntity>> registerBuyer({
    required String firstName,
    required String lastName,
    required String email,
    required String phone,
    required String password,
  }) async {
    try {
      final result = await _remote.registerBuyer(
        firstName: firstName,
        lastName: lastName,
        email: email,
        phone: phone,
        password: password,
      );
      await _local.saveTokens(accessToken: result.accessToken, refreshToken: '');
      await _local.saveUser(result.user);
      return Right(result.user);
    } on Exception catch (e) {
      return Left(ErrorHandler.mapExceptionToFailure(e));
    }
  }

  @override
  Future<Either<Failure, UserEntity>> registerVendor({
    required String firstName,
    required String lastName,
    required String email,
    required String phone,
    required String password,
    required String shopName,
    required String shopSlug,
    required String businessName,
    String? description,
    String? gstNumber,
    String? panNumber,
    String? supportEmail,
    String? supportPhone,
  }) async {
    try {
      final result = await _remote.registerVendor(
        firstName: firstName,
        lastName: lastName,
        email: email,
        phone: phone,
        password: password,
        shopName: shopName,
        shopSlug: shopSlug,
        businessName: businessName,
        description: description,
        gstNumber: gstNumber,
        panNumber: panNumber,
        supportEmail: supportEmail,
        supportPhone: supportPhone,
      );
      await _local.saveTokens(accessToken: result.accessToken, refreshToken: '');
      await _local.saveUser(result.user);
      return Right(result.user);
    } on Exception catch (e) {
      return Left(ErrorHandler.mapExceptionToFailure(e));
    }
  }
```

The project still will not compile after this step: `auth_bloc.dart` and `test/bloc/auth_bloc_test.dart` still reference the deleted `RegisterUseCase`/`RegisterRequested`. Proceed directly to Task 6.

- [ ] **Step 4: Run the new test to verify it passes**

Run: `flutter test test/unit/auth/auth_repository_impl_register_test.dart`
Expected: PASS

- [ ] **Step 5: Commit**

```bash
git add lib/features/auth/data/datasources/auth_remote_datasource.dart lib/features/auth/data/repositories/auth_repository_impl.dart test/unit/auth/auth_repository_impl_register_test.dart
git commit -m "feat(auth): wire registerBuyer/registerVendor through datasource and repository"
```

---

### Task 6: Bloc — events, handlers, and DI regeneration

**Files:**
- Modify: `lib/features/auth/presentation/bloc/auth_event.dart`
- Modify: `lib/features/auth/presentation/bloc/auth_bloc.dart`
- Modify: `test/bloc/auth_bloc_test.dart`
- Regenerate: `lib/core/di/injection.config.dart` (via build_runner, not hand-edited)

**Interfaces:**
- Consumes: `RegisterBuyerUseCase`/`BuyerRegisterParams`, `RegisterVendorUseCase`/`VendorRegisterParams` (Task 4).
- Produces: `BuyerRegisterRequested(firstName, lastName, email, phone, password)`, `VendorRegisterRequested(firstName, lastName, email, phone, password, shopName, shopSlug, businessName, description?, gstNumber?, panNumber?, supportEmail?, supportPhone?)` — both extend `AuthEvent`. `AuthBloc` constructor now takes `registerBuyer: RegisterBuyerUseCase` and `registerVendor: RegisterVendorUseCase` instead of `register: RegisterUseCase`.

- [ ] **Step 1: Write the failing test**

In `test/bloc/auth_bloc_test.dart`, replace the imports, mocks, `buildBloc`, and `setUpAll` block, and add two new test groups. Replace the whole file with:

```dart
import 'package:bloc_test/bloc_test.dart';
import 'package:bingo_pay/core/error/failures.dart';
import 'package:bingo_pay/features/auth/domain/entities/user_entity.dart';
import 'package:bingo_pay/features/auth/domain/usecases/check_auth_status_usecase.dart';
import 'package:bingo_pay/features/auth/domain/usecases/forgot_password_usecase.dart';
import 'package:bingo_pay/features/auth/domain/usecases/get_kyc_status_usecase.dart';
import 'package:bingo_pay/features/auth/domain/usecases/login_usecase.dart';
import 'package:bingo_pay/features/auth/domain/usecases/logout_usecase.dart';
import 'package:bingo_pay/features/auth/domain/usecases/register_buyer_usecase.dart';
import 'package:bingo_pay/features/auth/domain/usecases/register_vendor_usecase.dart';
import 'package:bingo_pay/features/auth/domain/usecases/submit_kyc_personal_details_usecase.dart';
import 'package:bingo_pay/features/auth/domain/usecases/upload_kyc_document_usecase.dart';
import 'package:bingo_pay/features/auth/domain/usecases/upload_kyc_selfie_usecase.dart';
import 'package:bingo_pay/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:bingo_pay/features/auth/presentation/bloc/auth_event.dart';
import 'package:bingo_pay/features/auth/presentation/bloc/auth_state.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:mocktail/mocktail.dart';

class MockLoginUseCase extends Mock implements LoginUseCase {}
class MockRegisterBuyerUseCase extends Mock implements RegisterBuyerUseCase {}
class MockRegisterVendorUseCase extends Mock implements RegisterVendorUseCase {}
class MockForgotPasswordUseCase extends Mock implements ForgotPasswordUseCase {}
class MockLogoutUseCase extends Mock implements LogoutUseCase {}
class MockCheckAuthStatusUseCase extends Mock implements CheckAuthStatusUseCase {}
class MockKycPersonalDetailsUseCase extends Mock implements SubmitKycPersonalDetailsUseCase {}
class MockKycDocumentUseCase extends Mock implements UploadKycDocumentUseCase {}
class MockKycSelfieUseCase extends Mock implements UploadKycSelfieUseCase {}
class MockGetKycStatusUseCase extends Mock implements GetKycStatusUseCase {}

AuthBloc buildBloc({
  MockLoginUseCase? login,
  MockRegisterBuyerUseCase? registerBuyer,
  MockRegisterVendorUseCase? registerVendor,
  MockCheckAuthStatusUseCase? checkAuth,
  MockLogoutUseCase? logout,
  MockForgotPasswordUseCase? forgotPassword,
}) =>
    AuthBloc(
      checkAuthStatus: checkAuth ?? MockCheckAuthStatusUseCase(),
      login: login ?? MockLoginUseCase(),
      registerBuyer: registerBuyer ?? MockRegisterBuyerUseCase(),
      registerVendor: registerVendor ?? MockRegisterVendorUseCase(),
      forgotPassword: forgotPassword ?? MockForgotPasswordUseCase(),
      logout: logout ?? MockLogoutUseCase(),
      kycPersonalDetails: MockKycPersonalDetailsUseCase(),
      kycDocument: MockKycDocumentUseCase(),
      kycSelfie: MockKycSelfieUseCase(),
      getKycStatus: MockGetKycStatusUseCase(),
    );

void main() {
  setUpAll(() {
    registerFallbackValue(const LoginParams(email: '', password: ''));
    registerFallbackValue(const BuyerRegisterParams(
      firstName: '', lastName: '', email: '', phone: '', password: '',
    ));
    registerFallbackValue(const VendorRegisterParams(
      firstName: '', lastName: '', email: '', phone: '', password: '',
      shopName: '', shopSlug: '', businessName: '',
    ));
  });

  const buyer = UserEntity(
    id: '1', email: 'a@b.com', name: 'Alice',
    role: 'buyer', kycStatus: 'not_required',
  );
  const vendor = UserEntity(
    id: '2', email: 'owner@acme.com', name: 'Acme Owner',
    role: 'vendor', kycStatus: 'pending',
  );

  group('LoginRequested', () {
    blocTest<AuthBloc, AuthState>(
      'emits [AuthLoading, AuthAuthenticated] on success',
      build: () {
        final mockLogin = MockLoginUseCase();
        when(() => mockLogin(any()))
            .thenAnswer((_) async => const Right(buyer));
        return buildBloc(login: mockLogin);
      },
      act: (bloc) =>
          bloc.add(const LoginRequested(email: 'a@b.com', password: 'pw')),
      expect: () => [const AuthLoading(), const AuthAuthenticated(buyer)],
    );

    blocTest<AuthBloc, AuthState>(
      'emits [AuthLoading, AuthError] on failure',
      build: () {
        final mockLogin = MockLoginUseCase();
        when(() => mockLogin(any()))
            .thenAnswer((_) async => const Left(NetworkFailure()));
        return buildBloc(login: mockLogin);
      },
      act: (bloc) =>
          bloc.add(const LoginRequested(email: 'a@b.com', password: 'pw')),
      expect: () => [const AuthLoading(), const AuthError(NetworkFailure())],
    );
  });

  group('BuyerRegisterRequested', () {
    blocTest<AuthBloc, AuthState>(
      'emits [AuthLoading, AuthAuthenticated] on success',
      build: () {
        final mockRegister = MockRegisterBuyerUseCase();
        when(() => mockRegister(any()))
            .thenAnswer((_) async => const Right(buyer));
        return buildBloc(registerBuyer: mockRegister);
      },
      act: (bloc) => bloc.add(const BuyerRegisterRequested(
        firstName: 'Alice', lastName: 'Doe', email: 'a@b.com',
        phone: '9876543210', password: 'password1',
      )),
      expect: () => [const AuthLoading(), const AuthAuthenticated(buyer)],
    );

    blocTest<AuthBloc, AuthState>(
      'emits [AuthLoading, AuthError] on failure',
      build: () {
        final mockRegister = MockRegisterBuyerUseCase();
        when(() => mockRegister(any()))
            .thenAnswer((_) async => const Left(NetworkFailure()));
        return buildBloc(registerBuyer: mockRegister);
      },
      act: (bloc) => bloc.add(const BuyerRegisterRequested(
        firstName: 'Alice', lastName: 'Doe', email: 'a@b.com',
        phone: '9876543210', password: 'password1',
      )),
      expect: () => [const AuthLoading(), const AuthError(NetworkFailure())],
    );
  });

  group('VendorRegisterRequested', () {
    blocTest<AuthBloc, AuthState>(
      'emits [AuthLoading, AuthAuthenticated] on success',
      build: () {
        final mockRegister = MockRegisterVendorUseCase();
        when(() => mockRegister(any()))
            .thenAnswer((_) async => const Right(vendor));
        return buildBloc(registerVendor: mockRegister);
      },
      act: (bloc) => bloc.add(const VendorRegisterRequested(
        firstName: 'Acme', lastName: 'Owner', email: 'owner@acme.com',
        phone: '9876543210', password: 'password1',
        shopName: 'Acme Store', shopSlug: 'acme-store',
        businessName: 'Acme Pvt Ltd',
      )),
      expect: () => [const AuthLoading(), const AuthAuthenticated(vendor)],
    );

    blocTest<AuthBloc, AuthState>(
      'emits [AuthLoading, AuthError] on failure',
      build: () {
        final mockRegister = MockRegisterVendorUseCase();
        when(() => mockRegister(any()))
            .thenAnswer((_) async => const Left(NetworkFailure()));
        return buildBloc(registerVendor: mockRegister);
      },
      act: (bloc) => bloc.add(const VendorRegisterRequested(
        firstName: 'Acme', lastName: 'Owner', email: 'owner@acme.com',
        phone: '9876543210', password: 'password1',
        shopName: 'Acme Store', shopSlug: 'acme-store',
        businessName: 'Acme Pvt Ltd',
      )),
      expect: () => [const AuthLoading(), const AuthError(NetworkFailure())],
    );
  });

  group('CheckAuthStatusRequested', () {
    blocTest<AuthBloc, AuthState>(
      'emits [AuthLoading, AuthAuthenticated] when stored user exists',
      build: () {
        final mockCheck = MockCheckAuthStatusUseCase();
        when(() => mockCheck())
            .thenAnswer((_) async => const Right(buyer));
        return buildBloc(checkAuth: mockCheck);
      },
      act: (bloc) => bloc.add(const CheckAuthStatusRequested()),
      expect: () => [const AuthLoading(), const AuthAuthenticated(buyer)],
    );

    blocTest<AuthBloc, AuthState>(
      'emits [AuthLoading, AuthUnauthenticated] when no stored user',
      build: () {
        final mockCheck = MockCheckAuthStatusUseCase();
        when(() => mockCheck())
            .thenAnswer((_) async => const Right(null));
        return buildBloc(checkAuth: mockCheck);
      },
      act: (bloc) => bloc.add(const CheckAuthStatusRequested()),
      expect: () => [const AuthLoading(), const AuthUnauthenticated()],
    );
  });

  group('ForgotPasswordRequested', () {
    blocTest<AuthBloc, AuthState>(
      'emits [AuthLoading, PasswordResetSent] on success',
      build: () {
        final mockForgot = MockForgotPasswordUseCase();
        when(() => mockForgot(any()))
            .thenAnswer((_) async => const Right(unit));
        return buildBloc(forgotPassword: mockForgot);
      },
      act: (bloc) =>
          bloc.add(const ForgotPasswordRequested(email: 'a@b.com')),
      expect: () => [const AuthLoading(), const PasswordResetSent()],
    );
  });
}
```

Note: per the spec's confirmed-decisions, the 7 pre-existing failures in `LoginRequested`/`CheckAuthStatusRequested`/`ForgotPasswordRequested` groups (missing `AuthLoading` emission from today's mock handlers) are out of scope. The `expect:` blocks above already assume the real (non-mock) handlers emit `AuthLoading` first, matching Task 6's bloc implementation below — this fixes those 3 groups as a side effect of switching `_onLogin`/`_onForgotPassword`/`_onCheckAuthStatus` to use cases, but that is incidental, not a goal of this task. If after Step 3 those still fail for reasons other than the register changes, leave them — only the two new `*RegisterRequested` groups are this task's responsibility.

- [ ] **Step 2: Run test to verify it fails**

Run: `flutter test test/bloc/auth_bloc_test.dart`
Expected: FAIL to compile — `BuyerRegisterRequested`, `VendorRegisterRequested`, `RegisterBuyerUseCase` constructor param etc. undefined on `AuthBloc`.

- [ ] **Step 3: Implement**

In `lib/features/auth/presentation/bloc/auth_event.dart`, replace the `RegisterRequested` class with:

```dart
class BuyerRegisterRequested extends AuthEvent {
  final String firstName;
  final String lastName;
  final String email;
  final String phone;
  final String password;
  const BuyerRegisterRequested({
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.phone,
    required this.password,
  });
  @override
  List<Object> get props => [firstName, lastName, email, phone, password];
}

class VendorRegisterRequested extends AuthEvent {
  final String firstName;
  final String lastName;
  final String email;
  final String phone;
  final String password;
  final String shopName;
  final String shopSlug;
  final String businessName;
  final String? description;
  final String? gstNumber;
  final String? panNumber;
  final String? supportEmail;
  final String? supportPhone;
  const VendorRegisterRequested({
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.phone,
    required this.password,
    required this.shopName,
    required this.shopSlug,
    required this.businessName,
    this.description,
    this.gstNumber,
    this.panNumber,
    this.supportEmail,
    this.supportPhone,
  });
  @override
  List<Object?> get props => [
        firstName, lastName, email, phone, password,
        shopName, shopSlug, businessName,
        description, gstNumber, panNumber, supportEmail, supportPhone,
      ];
}
```

In `lib/features/auth/presentation/bloc/auth_bloc.dart`:
- Replace the import `'../../domain/usecases/register_usecase.dart'` with:
  ```dart
  import '../../domain/usecases/register_buyer_usecase.dart';
  import '../../domain/usecases/register_vendor_usecase.dart';
  ```
- Add two private fields right after the existing `UserEntity? _currentUser;` line:
  ```dart
    final RegisterBuyerUseCase _registerBuyer;
    final RegisterVendorUseCase _registerVendor;
  ```
- Replace the constructor signature (the `AuthBloc({ ... }) : super(const AuthInitial()) { ... }` block) — change the parameter `required RegisterUseCase register,` to:
  ```dart
    required RegisterBuyerUseCase registerBuyer,
    required RegisterVendorUseCase registerVendor,
  ```
  and change `}) : super(const AuthInitial()) {` to assign the two new fields before calling `super`:
  ```dart
  }) : _registerBuyer = registerBuyer,
       _registerVendor = registerVendor,
       super(const AuthInitial()) {
  ```
- Replace `on<RegisterRequested>(_onRegister);` with:
  ```dart
    on<BuyerRegisterRequested>(_onBuyerRegister);
    on<VendorRegisterRequested>(_onVendorRegister);
  ```
- Replace the `_onRegister` method with:
  ```dart
  Future<void> _onBuyerRegister(
    BuyerRegisterRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());
    final result = await _registerBuyer(BuyerRegisterParams(
      firstName: event.firstName,
      lastName: event.lastName,
      email: event.email,
      phone: event.phone,
      password: event.password,
    ));
    result.match(
      (failure) => emit(AuthError(failure)),
      (user) {
        _currentUser = user;
        emit(AuthAuthenticated(user));
      },
    );
  }

  Future<void> _onVendorRegister(
    VendorRegisterRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());
    final result = await _registerVendor(VendorRegisterParams(
      firstName: event.firstName,
      lastName: event.lastName,
      email: event.email,
      phone: event.phone,
      password: event.password,
      shopName: event.shopName,
      shopSlug: event.shopSlug,
      businessName: event.businessName,
      description: event.description,
      gstNumber: event.gstNumber,
      panNumber: event.panNumber,
      supportEmail: event.supportEmail,
      supportPhone: event.supportPhone,
    ));
    result.match(
      (failure) => emit(AuthError(failure)),
      (user) {
        _currentUser = user;
        emit(AuthAuthenticated(user));
      },
    );
  }
  ```
  `result.match(onLeft, onRight)` is `fpdart`'s `Either` pattern, already imported transitively via the domain layer's `Either` return type — add `import 'package:fpdart/fpdart.dart';` to `auth_bloc.dart` if not already present.

Regenerate DI bindings (the generated `injection.config.dart` currently wires `RegisterUseCase`, which no longer exists):

```bash
dart run build_runner build --delete-conflicting-outputs
```

This updates `lib/core/di/injection.config.dart` to provide `RegisterBuyerUseCase`/`RegisterVendorUseCase` and the new `AuthBloc` constructor shape. Do not hand-edit that file.

- [ ] **Step 4: Run test to verify it passes**

Run: `flutter test test/bloc/auth_bloc_test.dart`
Expected: PASS for `BuyerRegisterRequested` and `VendorRegisterRequested` groups (and ideally all groups, though only those two are this task's scope per the note in Step 1).

Run: `flutter analyze`
Expected: no errors (confirms `injection.config.dart` regenerated cleanly and nothing else references the deleted `RegisterUseCase`/`RegisterRequested`/`AuthRepository.register`).

- [ ] **Step 5: Commit**

```bash
git add lib/features/auth/presentation/bloc/auth_event.dart lib/features/auth/presentation/bloc/auth_bloc.dart lib/core/di/injection.config.dart test/bloc/auth_bloc_test.dart
git commit -m "feat(auth): add BuyerRegisterRequested/VendorRegisterRequested bloc events"
```

---

### Task 7: UI — role-aware register screen with vendor 2-step wizard

**Files:**
- Modify: `lib/features/auth/presentation/screens/register_screen.dart`

**Interfaces:**
- Consumes: `BuyerRegisterRequested`, `VendorRegisterRequested` (Task 6), `Validators.phone`/`gst`/`pan` and `slugify()` (Task 2), `KycStepIndicator` (`lib/features/auth/presentation/widgets/kyc_step_indicator.dart`, unchanged — `KycStepIndicator({required currentStep, totalSteps = 3})`).
- No new public interface — this is a leaf UI widget.

This task has no automated test (it's a widget-heavy screen rewrite); verify manually per Step 4.

- [ ] **Step 1: Replace `register_screen.dart`**

Replace the full contents of `lib/features/auth/presentation/screens/register_screen.dart`:

```dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/router/app_routes.dart';
import '../../../../core/utils/slugify.dart';
import '../../../../core/utils/validators.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_snackbar.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../bloc/auth_bloc.dart';
import '../bloc/auth_event.dart';
import '../bloc/auth_state.dart';
import '../widgets/kyc_step_indicator.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _personalFormKey = GlobalKey<FormState>();
  final _businessFormKey = GlobalKey<FormState>();

  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  final _shopNameController = TextEditingController();
  final _shopSlugController = TextEditingController();
  final _businessNameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _gstController = TextEditingController();
  final _panController = TextEditingController();
  final _supportEmailController = TextEditingController();
  final _supportPhoneController = TextEditingController();

  String _selectedRole = 'buyer';
  int _step = 0;
  bool _obscurePassword = true;
  bool _obscureConfirm = true;
  bool _shopSlugEdited = false;

  @override
  void initState() {
    super.initState();
    _shopNameController.addListener(_onShopNameChanged);
  }

  void _onShopNameChanged() {
    if (_shopSlugEdited) return;
    _shopSlugController.text = slugify(_shopNameController.text);
  }

  @override
  void dispose() {
    _shopNameController.removeListener(_onShopNameChanged);
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _shopNameController.dispose();
    _shopSlugController.dispose();
    _businessNameController.dispose();
    _descriptionController.dispose();
    _gstController.dispose();
    _panController.dispose();
    _supportEmailController.dispose();
    _supportPhoneController.dispose();
    super.dispose();
  }

  void _selectRole(String role) {
    setState(() {
      _selectedRole = role;
      _step = 0;
    });
  }

  void _submitBuyer() {
    if (_personalFormKey.currentState?.validate() ?? false) {
      context.read<AuthBloc>().add(BuyerRegisterRequested(
            firstName: _firstNameController.text.trim(),
            lastName: _lastNameController.text.trim(),
            email: _emailController.text.trim(),
            phone: _phoneController.text.trim(),
            password: _passwordController.text,
          ));
    }
  }

  void _goToBusinessStep() {
    if (_personalFormKey.currentState?.validate() ?? false) {
      setState(() => _step = 1);
    }
  }

  void _submitVendor() {
    if (_businessFormKey.currentState?.validate() ?? false) {
      context.read<AuthBloc>().add(VendorRegisterRequested(
            firstName: _firstNameController.text.trim(),
            lastName: _lastNameController.text.trim(),
            email: _emailController.text.trim(),
            phone: _phoneController.text.trim(),
            password: _passwordController.text,
            shopName: _shopNameController.text.trim(),
            shopSlug: _shopSlugController.text.trim(),
            businessName: _businessNameController.text.trim(),
            description: _descriptionController.text.trim().isEmpty
                ? null
                : _descriptionController.text.trim(),
            gstNumber: _gstController.text.trim().isEmpty
                ? null
                : _gstController.text.trim(),
            panNumber: _panController.text.trim().isEmpty
                ? null
                : _panController.text.trim(),
            supportEmail: _supportEmailController.text.trim().isEmpty
                ? null
                : _supportEmailController.text.trim(),
            supportPhone: _supportPhoneController.text.trim().isEmpty
                ? null
                : _supportPhoneController.text.trim(),
          ));
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      body: BlocListener<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is AuthError) {
            AppSnackbar.showError(context, state.failure.message);
          }
        },
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 32),
                Text(
                  'Create Account',
                  style: theme.textTheme.headlineMedium,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),
                Text('I am a:', style: theme.textTheme.labelLarge),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: _RoleCard(
                        label: 'Buyer',
                        icon: Icons.shopping_bag_outlined,
                        isSelected: _selectedRole == 'buyer',
                        onTap: () => _selectRole('buyer'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _RoleCard(
                        label: 'Vendor',
                        icon: Icons.storefront_outlined,
                        isSelected: _selectedRole == 'vendor',
                        onTap: () => _selectRole('vendor'),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 32),
                if (_selectedRole == 'vendor') ...[
                  KycStepIndicator(currentStep: _step, totalSteps: 2),
                  const SizedBox(height: 8),
                  Text(_step == 0
                      ? 'Step 1 of 2: Personal Details'
                      : 'Step 2 of 2: Business Details'),
                  const SizedBox(height: 24),
                ],
                if (_selectedRole == 'buyer' || _step == 0)
                  Form(
                    key: _personalFormKey,
                    child: _PersonalDetailsFields(
                      firstNameController: _firstNameController,
                      lastNameController: _lastNameController,
                      emailController: _emailController,
                      phoneController: _phoneController,
                      passwordController: _passwordController,
                      confirmPasswordController: _confirmPasswordController,
                      obscurePassword: _obscurePassword,
                      obscureConfirm: _obscureConfirm,
                      onTogglePassword: () =>
                          setState(() => _obscurePassword = !_obscurePassword),
                      onToggleConfirm: () =>
                          setState(() => _obscureConfirm = !_obscureConfirm),
                    ),
                  )
                else
                  Form(
                    key: _businessFormKey,
                    child: _BusinessDetailsFields(
                      shopNameController: _shopNameController,
                      shopSlugController: _shopSlugController,
                      businessNameController: _businessNameController,
                      descriptionController: _descriptionController,
                      gstController: _gstController,
                      panController: _panController,
                      supportEmailController: _supportEmailController,
                      supportPhoneController: _supportPhoneController,
                      onShopSlugChanged: () => _shopSlugEdited = true,
                    ),
                  ),
                const SizedBox(height: 32),
                BlocBuilder<AuthBloc, AuthState>(
                  builder: (context, state) {
                    final isLoading = state is AuthLoading;
                    if (_selectedRole == 'buyer') {
                      return AppButton(
                        label: 'Create Account',
                        onPressed: _submitBuyer,
                        isLoading: isLoading,
                      );
                    }
                    if (_step == 0) {
                      return AppButton(
                        label: 'Next',
                        onPressed: _goToBusinessStep,
                        isLoading: isLoading,
                      );
                    }
                    return Column(
                      children: [
                        AppButton(
                          label: 'Create Account',
                          onPressed: _submitVendor,
                          isLoading: isLoading,
                        ),
                        const SizedBox(height: 12),
                        AppButton(
                          label: 'Back',
                          variant: AppButtonVariant.outlined,
                          onPressed:
                              isLoading ? null : () => setState(() => _step = 0),
                        ),
                      ],
                    );
                  },
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text('Already have an account?'),
                    TextButton(
                      onPressed: () => context.go(AppRoutes.login),
                      child: const Text('Sign In'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _PersonalDetailsFields extends StatelessWidget {
  final TextEditingController firstNameController;
  final TextEditingController lastNameController;
  final TextEditingController emailController;
  final TextEditingController phoneController;
  final TextEditingController passwordController;
  final TextEditingController confirmPasswordController;
  final bool obscurePassword;
  final bool obscureConfirm;
  final VoidCallback onTogglePassword;
  final VoidCallback onToggleConfirm;

  const _PersonalDetailsFields({
    required this.firstNameController,
    required this.lastNameController,
    required this.emailController,
    required this.phoneController,
    required this.passwordController,
    required this.confirmPasswordController,
    required this.obscurePassword,
    required this.obscureConfirm,
    required this.onTogglePassword,
    required this.onToggleConfirm,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        AppTextField(
          controller: firstNameController,
          label: 'First Name',
          validator: (v) => Validators.required(v, fieldName: 'First name'),
        ),
        const SizedBox(height: 16),
        AppTextField(
          controller: lastNameController,
          label: 'Last Name',
          validator: (v) => Validators.required(v, fieldName: 'Last name'),
        ),
        const SizedBox(height: 16),
        AppTextField(
          controller: emailController,
          label: 'Email',
          keyboardType: TextInputType.emailAddress,
          validator: Validators.email,
        ),
        const SizedBox(height: 16),
        AppTextField(
          controller: phoneController,
          label: 'Phone Number',
          keyboardType: TextInputType.phone,
          validator: Validators.phone,
        ),
        const SizedBox(height: 16),
        AppTextField(
          controller: passwordController,
          label: 'Password',
          obscureText: obscurePassword,
          validator: Validators.password,
          suffixIcon: IconButton(
            icon: Icon(obscurePassword
                ? Icons.visibility_outlined
                : Icons.visibility_off_outlined),
            onPressed: onTogglePassword,
          ),
        ),
        const SizedBox(height: 16),
        AppTextField(
          controller: confirmPasswordController,
          label: 'Confirm Password',
          obscureText: obscureConfirm,
          validator: (v) =>
              Validators.confirmPassword(v, passwordController.text),
          suffixIcon: IconButton(
            icon: Icon(obscureConfirm
                ? Icons.visibility_outlined
                : Icons.visibility_off_outlined),
            onPressed: onToggleConfirm,
          ),
        ),
      ],
    );
  }
}

class _BusinessDetailsFields extends StatelessWidget {
  final TextEditingController shopNameController;
  final TextEditingController shopSlugController;
  final TextEditingController businessNameController;
  final TextEditingController descriptionController;
  final TextEditingController gstController;
  final TextEditingController panController;
  final TextEditingController supportEmailController;
  final TextEditingController supportPhoneController;
  final VoidCallback onShopSlugChanged;

  const _BusinessDetailsFields({
    required this.shopNameController,
    required this.shopSlugController,
    required this.businessNameController,
    required this.descriptionController,
    required this.gstController,
    required this.panController,
    required this.supportEmailController,
    required this.supportPhoneController,
    required this.onShopSlugChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        AppTextField(
          controller: shopNameController,
          label: 'Shop Name',
          validator: (v) => Validators.required(v, fieldName: 'Shop name'),
        ),
        const SizedBox(height: 16),
        AppTextField(
          controller: shopSlugController,
          label: 'Shop Slug',
          onChanged: (_) => onShopSlugChanged(),
          validator: (v) => Validators.required(v, fieldName: 'Shop slug'),
        ),
        const SizedBox(height: 16),
        AppTextField(
          controller: businessNameController,
          label: 'Business Name',
          validator: (v) =>
              Validators.required(v, fieldName: 'Business name'),
        ),
        const SizedBox(height: 16),
        AppTextField(
          controller: descriptionController,
          label: 'Description (optional)',
          maxLines: 3,
        ),
        const SizedBox(height: 16),
        AppTextField(
          controller: gstController,
          label: 'GST Number (optional)',
          validator: Validators.gst,
        ),
        const SizedBox(height: 16),
        AppTextField(
          controller: panController,
          label: 'PAN Number (optional)',
          validator: Validators.pan,
        ),
        const SizedBox(height: 16),
        AppTextField(
          controller: supportEmailController,
          label: 'Support Email (optional)',
          keyboardType: TextInputType.emailAddress,
        ),
        const SizedBox(height: 16),
        AppTextField(
          controller: supportPhoneController,
          label: 'Support Phone (optional)',
          keyboardType: TextInputType.phone,
        ),
      ],
    );
  }
}

class _RoleCard extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  const _RoleCard({
    required this.label,
    required this.icon,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: isSelected
              ? theme.colorScheme.primaryContainer
              : theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected
                ? theme.colorScheme.primary
                : theme.colorScheme.outline,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              color: isSelected
                  ? theme.colorScheme.primary
                  : theme.colorScheme.onSurface,
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: isSelected
                    ? theme.colorScheme.primary
                    : theme.colorScheme.onSurface,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
```

- [ ] **Step 2: Run static analysis**

Run: `flutter analyze`
Expected: no errors in `register_screen.dart`.

- [ ] **Step 3: Run the full test suite**

Run: `flutter test`
Expected: all tests pass except the pre-existing out-of-scope failures noted in Global Constraints / Task 6 Step 1 (if any remain).

- [ ] **Step 4: Manual verification**

Run the app on a simulator/device (`flutter run`) and walk both flows:
- Buyer: role card → fill First/Last Name, Email, Phone, Password, Confirm → Create Account → observe loading state then navigation (or error snackbar if the dev API is unreachable).
- Vendor: role card → fill Personal Details → Next → step indicator advances to step 2 → fill Shop Name (observe Shop Slug auto-fill) → edit slug manually (observe it stops auto-updating on further shop name edits) → Create Account → Back returns to step 1 with entered data retained (controllers aren't cleared on step change).

- [ ] **Step 5: Commit**

```bash
git add lib/features/auth/presentation/screens/register_screen.dart
git commit -m "feat(auth): rebuild register screen with buyer single-step and vendor 2-step wizard"
```
