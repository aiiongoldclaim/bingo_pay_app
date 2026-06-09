# Auth Feature Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** Implement the complete Auth feature — login, register (buyer/vendor), KYC wizard, forgot password — wired end-to-end through Clean Architecture layers with BLoC state management.

**Architecture:** Feature-First Clean Architecture. Domain → Data → Presentation. AuthBloc provided at App root; route guard updated with KYC-pending state.

**Tech Stack:** flutter_bloc · fpdart · dio · injectable · go_router · image_picker · permission_handler · json_serializable · bloc_test · mocktail

---

### Task 1: Domain entities

**Files:**
- Create: `lib/features/auth/domain/entities/user_entity.dart`
- Create: `lib/features/auth/domain/entities/kyc_entity.dart`
- Create: `test/unit/auth/user_entity_test.dart`

- [ ] **Step 1: Create UserEntity**

```dart
// lib/features/auth/domain/entities/user_entity.dart
import 'package:equatable/equatable.dart';

class UserEntity extends Equatable {
  final String id;
  final String email;
  final String name;
  final String role;       // 'buyer' | 'vendor'
  final String kycStatus;  // 'not_required' | 'pending' | 'under_review' | 'approved' | 'rejected'

  const UserEntity({
    required this.id,
    required this.email,
    required this.name,
    required this.role,
    required this.kycStatus,
  });

  bool get isBuyer  => role == 'buyer';
  bool get isVendor => role == 'vendor';
  bool get isKycApproved => kycStatus == 'approved' || kycStatus == 'not_required';
  bool get isKycPending  => kycStatus == 'pending'  || kycStatus == 'under_review';

  @override
  List<Object> get props => [id, email, name, role, kycStatus];
}
```

- [ ] **Step 2: Create KycEntity**

```dart
// lib/features/auth/domain/entities/kyc_entity.dart
import 'package:equatable/equatable.dart';

class KycEntity extends Equatable {
  final String status;          // 'pending' | 'under_review' | 'approved' | 'rejected'
  final String? rejectionReason;

  const KycEntity({required this.status, this.rejectionReason});

  bool get isApproved => status == 'approved';
  bool get isRejected => status == 'rejected';
  bool get isUnderReview => status == 'under_review';

  @override
  List<Object?> get props => [status, rejectionReason];
}
```

- [ ] **Step 3: Write and run tests**

```dart
// test/unit/auth/user_entity_test.dart
import 'package:bingo_pay/features/auth/domain/entities/user_entity.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const buyer = UserEntity(
    id: '1', email: 'b@test.com', name: 'Bob', role: 'buyer', kycStatus: 'not_required',
  );
  const vendor = UserEntity(
    id: '2', email: 'v@test.com', name: 'Ven', role: 'vendor', kycStatus: 'pending',
  );

  group('UserEntity', () {
    test('isBuyer/isVendor returns correct role', () {
      expect(buyer.isBuyer, isTrue);
      expect(buyer.isVendor, isFalse);
      expect(vendor.isVendor, isTrue);
    });

    test('isKycApproved for not_required buyer', () {
      expect(buyer.isKycApproved, isTrue);
      expect(buyer.isKycPending, isFalse);
    });

    test('isKycPending for pending vendor', () {
      expect(vendor.isKycPending, isTrue);
      expect(vendor.isKycApproved, isFalse);
    });

    test('supports value equality', () {
      const same = UserEntity(
        id: '1', email: 'b@test.com', name: 'Bob', role: 'buyer', kycStatus: 'not_required',
      );
      expect(buyer, equals(same));
    });
  });
}
```

Run: `flutter test test/unit/auth/user_entity_test.dart`
Expected: 4 tests pass

- [ ] **Step 4: Commit**

```bash
git add lib/features/auth/domain/entities/ test/unit/auth/
git commit -m "feat(auth): add UserEntity and KycEntity domain entities"
```

---

### Task 2: AuthRepository interface + use cases

**Files:**
- Create: `lib/features/auth/domain/repositories/auth_repository.dart`
- Create: `lib/features/auth/domain/usecases/login_usecase.dart`
- Create: `lib/features/auth/domain/usecases/register_usecase.dart`
- Create: `lib/features/auth/domain/usecases/forgot_password_usecase.dart`
- Create: `lib/features/auth/domain/usecases/logout_usecase.dart`
- Create: `lib/features/auth/domain/usecases/check_auth_status_usecase.dart`
- Create: `lib/features/auth/domain/usecases/submit_kyc_personal_details_usecase.dart`
- Create: `lib/features/auth/domain/usecases/upload_kyc_document_usecase.dart`
- Create: `lib/features/auth/domain/usecases/upload_kyc_selfie_usecase.dart`
- Create: `lib/features/auth/domain/usecases/get_kyc_status_usecase.dart`
- Create: `test/unit/auth/login_usecase_test.dart`

- [ ] **Step 1: Create AuthRepository interface**

```dart
// lib/features/auth/domain/repositories/auth_repository.dart
import 'package:fpdart/fpdart.dart';
import '../../../../core/error/failures.dart';
import '../entities/kyc_entity.dart';
import '../entities/user_entity.dart';

abstract interface class AuthRepository {
  Future<Either<Failure, UserEntity>> login({
    required String email,
    required String password,
  });

  Future<Either<Failure, UserEntity>> register({
    required String email,
    required String password,
    required String name,
    required String role,
  });

  Future<Either<Failure, Unit>> forgotPassword({required String email});

  Future<Either<Failure, Unit>> logout();

  Future<Either<Failure, UserEntity?>> getStoredUser();

  Future<Either<Failure, KycEntity>> submitKycPersonalDetails({
    required String name,
    required String dateOfBirth,
    required String address,
  });

  Future<Either<Failure, KycEntity>> uploadKycDocument({
    required String filePath,
    required String documentType,
  });

  Future<Either<Failure, KycEntity>> uploadKycSelfie({required String filePath});

  Future<Either<Failure, KycEntity>> getKycStatus();
}
```

- [ ] **Step 2: Create use cases**

```dart
// lib/features/auth/domain/usecases/login_usecase.dart
import 'package:equatable/equatable.dart';
import 'package:fpdart/fpdart.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/error/failures.dart';
import '../entities/user_entity.dart';
import '../repositories/auth_repository.dart';

@injectable
class LoginUseCase {
  final AuthRepository _repository;
  const LoginUseCase(this._repository);

  Future<Either<Failure, UserEntity>> call(LoginParams params) =>
      _repository.login(email: params.email, password: params.password);
}

class LoginParams extends Equatable {
  final String email;
  final String password;
  const LoginParams({required this.email, required this.password});
  @override
  List<Object> get props => [email, password];
}
```

```dart
// lib/features/auth/domain/usecases/register_usecase.dart
import 'package:equatable/equatable.dart';
import 'package:fpdart/fpdart.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/error/failures.dart';
import '../entities/user_entity.dart';
import '../repositories/auth_repository.dart';

@injectable
class RegisterUseCase {
  final AuthRepository _repository;
  const RegisterUseCase(this._repository);

  Future<Either<Failure, UserEntity>> call(RegisterParams params) =>
      _repository.register(
        email: params.email,
        password: params.password,
        name: params.name,
        role: params.role,
      );
}

class RegisterParams extends Equatable {
  final String email;
  final String password;
  final String name;
  final String role;
  const RegisterParams({
    required this.email,
    required this.password,
    required this.name,
    required this.role,
  });
  @override
  List<Object> get props => [email, password, name, role];
}
```

```dart
// lib/features/auth/domain/usecases/forgot_password_usecase.dart
import 'package:fpdart/fpdart.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/error/failures.dart';
import '../repositories/auth_repository.dart';

@injectable
class ForgotPasswordUseCase {
  final AuthRepository _repository;
  const ForgotPasswordUseCase(this._repository);

  Future<Either<Failure, Unit>> call(String email) =>
      _repository.forgotPassword(email: email);
}
```

```dart
// lib/features/auth/domain/usecases/logout_usecase.dart
import 'package:fpdart/fpdart.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/error/failures.dart';
import '../repositories/auth_repository.dart';

@injectable
class LogoutUseCase {
  final AuthRepository _repository;
  const LogoutUseCase(this._repository);

  Future<Either<Failure, Unit>> call() => _repository.logout();
}
```

```dart
// lib/features/auth/domain/usecases/check_auth_status_usecase.dart
import 'package:fpdart/fpdart.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/error/failures.dart';
import '../entities/user_entity.dart';
import '../repositories/auth_repository.dart';

@injectable
class CheckAuthStatusUseCase {
  final AuthRepository _repository;
  const CheckAuthStatusUseCase(this._repository);

  Future<Either<Failure, UserEntity?>> call() => _repository.getStoredUser();
}
```

```dart
// lib/features/auth/domain/usecases/submit_kyc_personal_details_usecase.dart
import 'package:equatable/equatable.dart';
import 'package:fpdart/fpdart.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/error/failures.dart';
import '../entities/kyc_entity.dart';
import '../repositories/auth_repository.dart';

@injectable
class SubmitKycPersonalDetailsUseCase {
  final AuthRepository _repository;
  const SubmitKycPersonalDetailsUseCase(this._repository);

  Future<Either<Failure, KycEntity>> call(KycPersonalDetailsParams params) =>
      _repository.submitKycPersonalDetails(
        name: params.name,
        dateOfBirth: params.dateOfBirth,
        address: params.address,
      );
}

class KycPersonalDetailsParams extends Equatable {
  final String name;
  final String dateOfBirth;
  final String address;
  const KycPersonalDetailsParams({
    required this.name,
    required this.dateOfBirth,
    required this.address,
  });
  @override
  List<Object> get props => [name, dateOfBirth, address];
}
```

```dart
// lib/features/auth/domain/usecases/upload_kyc_document_usecase.dart
import 'package:equatable/equatable.dart';
import 'package:fpdart/fpdart.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/error/failures.dart';
import '../entities/kyc_entity.dart';
import '../repositories/auth_repository.dart';

@injectable
class UploadKycDocumentUseCase {
  final AuthRepository _repository;
  const UploadKycDocumentUseCase(this._repository);

  Future<Either<Failure, KycEntity>> call(KycDocumentParams params) =>
      _repository.uploadKycDocument(
        filePath: params.filePath,
        documentType: params.documentType,
      );
}

class KycDocumentParams extends Equatable {
  final String filePath;
  final String documentType;
  const KycDocumentParams({required this.filePath, required this.documentType});
  @override
  List<Object> get props => [filePath, documentType];
}
```

```dart
// lib/features/auth/domain/usecases/upload_kyc_selfie_usecase.dart
import 'package:fpdart/fpdart.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/error/failures.dart';
import '../entities/kyc_entity.dart';
import '../repositories/auth_repository.dart';

@injectable
class UploadKycSelfieUseCase {
  final AuthRepository _repository;
  const UploadKycSelfieUseCase(this._repository);

  Future<Either<Failure, KycEntity>> call(String filePath) =>
      _repository.uploadKycSelfie(filePath: filePath);
}
```

```dart
// lib/features/auth/domain/usecases/get_kyc_status_usecase.dart
import 'package:fpdart/fpdart.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/error/failures.dart';
import '../entities/kyc_entity.dart';
import '../repositories/auth_repository.dart';

@injectable
class GetKycStatusUseCase {
  final AuthRepository _repository;
  const GetKycStatusUseCase(this._repository);

  Future<Either<Failure, KycEntity>> call() => _repository.getKycStatus();
}
```

- [ ] **Step 3: Write and run use case test**

```dart
// test/unit/auth/login_usecase_test.dart
import 'package:bingo_pay/core/error/failures.dart';
import 'package:bingo_pay/features/auth/domain/entities/user_entity.dart';
import 'package:bingo_pay/features/auth/domain/repositories/auth_repository.dart';
import 'package:bingo_pay/features/auth/domain/usecases/login_usecase.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:mocktail/mocktail.dart';

class MockAuthRepository extends Mock implements AuthRepository {}

void main() {
  late MockAuthRepository repo;
  late LoginUseCase useCase;

  setUp(() {
    repo = MockAuthRepository();
    useCase = LoginUseCase(repo);
  });

  const params = LoginParams(email: 'a@b.com', password: 'pass123');
  const user = UserEntity(
    id: '1', email: 'a@b.com', name: 'Alice',
    role: 'buyer', kycStatus: 'not_required',
  );

  test('returns UserEntity on success', () async {
    when(() => repo.login(email: 'a@b.com', password: 'pass123'))
        .thenAnswer((_) async => const Right(user));

    final result = await useCase(params);
    expect(result, const Right<Failure, UserEntity>(user));
  });

  test('returns Failure on error', () async {
    const failure = NetworkFailure();
    when(() => repo.login(email: 'a@b.com', password: 'pass123'))
        .thenAnswer((_) async => const Left(failure));

    final result = await useCase(params);
    expect(result, const Left<Failure, UserEntity>(failure));
  });
}
```

Run: `flutter test test/unit/auth/login_usecase_test.dart`
Expected: 2 tests pass

- [ ] **Step 4: Commit**

```bash
git add lib/features/auth/domain/ test/unit/auth/login_usecase_test.dart
git commit -m "feat(auth): add AuthRepository interface and all use cases"
```

---

### Task 3: Auth data models + build_runner

**Files:**
- Create: `lib/features/auth/data/models/user_model.dart`
- Create: `lib/features/auth/data/models/auth_response_model.dart`
- Create: `lib/features/auth/data/models/kyc_model.dart`
- Create: `test/unit/auth/user_model_test.dart`
- Modify: `lib/core/api/api_endpoints.dart` — add kycPersonalDetails

- [ ] **Step 1: Add kycPersonalDetails to ApiEndpoints**

In `lib/core/api/api_endpoints.dart`, add after `kycStatus`:
```dart
static const String kycPersonalDetails = '/kyc/personal-details';
static const String me = '/auth/me';
```

- [ ] **Step 2: Create UserModel**

```dart
// lib/features/auth/data/models/user_model.dart
import 'package:json_annotation/json_annotation.dart';
import '../../domain/entities/user_entity.dart';

part 'user_model.g.dart';

@JsonSerializable()
class UserModel extends UserEntity {
  const UserModel({
    required super.id,
    required super.email,
    required super.name,
    required super.role,
    required super.kycStatus,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) =>
      _$UserModelFromJson(json);

  Map<String, dynamic> toJson() => _$UserModelToJson(this);
}
```

- [ ] **Step 3: Create AuthResponseModel**

```dart
// lib/features/auth/data/models/auth_response_model.dart
import 'package:json_annotation/json_annotation.dart';
import 'user_model.dart';

part 'auth_response_model.g.dart';

@JsonSerializable()
class AuthResponseModel {
  final String accessToken;
  final String refreshToken;
  final UserModel user;

  const AuthResponseModel({
    required this.accessToken,
    required this.refreshToken,
    required this.user,
  });

  factory AuthResponseModel.fromJson(Map<String, dynamic> json) =>
      _$AuthResponseModelFromJson(json);
}
```

- [ ] **Step 4: Create KycModel**

```dart
// lib/features/auth/data/models/kyc_model.dart
import 'package:json_annotation/json_annotation.dart';
import '../../domain/entities/kyc_entity.dart';

part 'kyc_model.g.dart';

@JsonSerializable()
class KycModel extends KycEntity {
  const KycModel({required super.status, super.rejectionReason});

  factory KycModel.fromJson(Map<String, dynamic> json) =>
      _$KycModelFromJson(json);

  Map<String, dynamic> toJson() => _$KycModelToJson(this);
}
```

- [ ] **Step 5: Run build_runner**

```bash
dart run build_runner build --delete-conflicting-outputs
```

Expected: generates `user_model.g.dart`, `auth_response_model.g.dart`, `kyc_model.g.dart`

- [ ] **Step 6: Write and run model tests**

```dart
// test/unit/auth/user_model_test.dart
import 'package:bingo_pay/features/auth/data/models/user_model.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const json = {
    'id': '1',
    'email': 'a@b.com',
    'name': 'Alice',
    'role': 'buyer',
    'kycStatus': 'not_required',
  };

  group('UserModel', () {
    test('fromJson creates correct model', () {
      final model = UserModel.fromJson(json);
      expect(model.id, '1');
      expect(model.role, 'buyer');
      expect(model.kycStatus, 'not_required');
    });

    test('toJson round-trips correctly', () {
      final model = UserModel.fromJson(json);
      expect(model.toJson(), json);
    });

    test('inherits UserEntity behaviour', () {
      final model = UserModel.fromJson(json);
      expect(model.isBuyer, isTrue);
      expect(model.isKycApproved, isTrue);
    });
  });
}
```

Run: `flutter test test/unit/auth/user_model_test.dart`
Expected: 3 tests pass

- [ ] **Step 7: Commit**

```bash
git add lib/features/auth/data/models/ lib/core/api/api_endpoints.dart test/unit/auth/user_model_test.dart
git commit -m "feat(auth): add data models with json_serializable"
```

---

### Task 4: Auth datasources

**Files:**
- Create: `lib/features/auth/data/datasources/auth_remote_datasource.dart`
- Create: `lib/features/auth/data/datasources/auth_local_datasource.dart`
- Create: `test/unit/auth/auth_local_datasource_test.dart`

- [ ] **Step 1: Create AuthRemoteDataSource**

```dart
// lib/features/auth/data/datasources/auth_remote_datasource.dart
import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/api/api_client.dart';
import '../../../../core/api/api_endpoints.dart';
import '../models/auth_response_model.dart';
import '../models/kyc_model.dart';

abstract interface class AuthRemoteDataSource {
  Future<AuthResponseModel> login({
    required String email,
    required String password,
  });

  Future<AuthResponseModel> register({
    required String email,
    required String password,
    required String name,
    required String role,
  });

  Future<void> forgotPassword({required String email});

  Future<KycModel> submitKycPersonalDetails({
    required String name,
    required String dateOfBirth,
    required String address,
  });

  Future<KycModel> uploadKycDocument({
    required String filePath,
    required String documentType,
  });

  Future<KycModel> uploadKycSelfie({required String filePath});

  Future<KycModel> getKycStatus();
}

@Injectable(as: AuthRemoteDataSource)
class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final ApiClient _apiClient;
  AuthRemoteDataSourceImpl(this._apiClient);

  Dio get _dio => _apiClient.dio;

  @override
  Future<AuthResponseModel> login({
    required String email,
    required String password,
  }) async {
    final response = await _dio.post(
      ApiEndpoints.login,
      data: {'email': email, 'password': password},
    );
    return AuthResponseModel.fromJson(
        response.data['data'] as Map<String, dynamic>);
  }

  @override
  Future<AuthResponseModel> register({
    required String email,
    required String password,
    required String name,
    required String role,
  }) async {
    final response = await _dio.post(
      ApiEndpoints.register,
      data: {'email': email, 'password': password, 'name': name, 'role': role},
    );
    return AuthResponseModel.fromJson(
        response.data['data'] as Map<String, dynamic>);
  }

  @override
  Future<void> forgotPassword({required String email}) async {
    await _dio.post(
      ApiEndpoints.forgotPassword,
      data: {'email': email},
    );
  }

  @override
  Future<KycModel> submitKycPersonalDetails({
    required String name,
    required String dateOfBirth,
    required String address,
  }) async {
    final response = await _dio.post(
      ApiEndpoints.kycPersonalDetails,
      data: {'name': name, 'dateOfBirth': dateOfBirth, 'address': address},
    );
    return KycModel.fromJson(response.data['data'] as Map<String, dynamic>);
  }

  @override
  Future<KycModel> uploadKycDocument({
    required String filePath,
    required String documentType,
  }) async {
    final formData = FormData.fromMap({
      'document': await MultipartFile.fromFile(filePath),
      'documentType': documentType,
    });
    final response = await _dio.post(ApiEndpoints.kycDocument, data: formData);
    return KycModel.fromJson(response.data['data'] as Map<String, dynamic>);
  }

  @override
  Future<KycModel> uploadKycSelfie({required String filePath}) async {
    final formData = FormData.fromMap({
      'selfie': await MultipartFile.fromFile(filePath),
    });
    final response = await _dio.post(ApiEndpoints.kycSelfie, data: formData);
    return KycModel.fromJson(response.data['data'] as Map<String, dynamic>);
  }

  @override
  Future<KycModel> getKycStatus() async {
    final response = await _dio.get(ApiEndpoints.kycStatus);
    return KycModel.fromJson(response.data['data'] as Map<String, dynamic>);
  }
}
```

- [ ] **Step 2: Create AuthLocalDataSource**

```dart
// lib/features/auth/data/datasources/auth_local_datasource.dart
import 'dart:convert';
import 'package:injectable/injectable.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/config/app_constants.dart';
import '../../../../core/storage/secure_storage_service.dart';
import '../models/user_model.dart';

abstract interface class AuthLocalDataSource {
  Future<void> saveTokens({
    required String accessToken,
    required String refreshToken,
  });

  Future<void> saveUser(UserModel user);

  Future<UserModel?> getUser();

  Future<void> clearAll();
}

@Injectable(as: AuthLocalDataSource)
class AuthLocalDataSourceImpl implements AuthLocalDataSource {
  final SecureStorageService _secureStorage;
  final SharedPreferences _prefs;

  AuthLocalDataSourceImpl(this._secureStorage, this._prefs);

  static const _userKey = 'cached_user';

  @override
  Future<void> saveTokens({
    required String accessToken,
    required String refreshToken,
  }) async {
    await _secureStorage.saveAccessToken(accessToken);
    await _secureStorage.saveRefreshToken(refreshToken);
  }

  @override
  Future<void> saveUser(UserModel user) async {
    await _prefs.setString(_userKey, jsonEncode(user.toJson()));
  }

  @override
  Future<UserModel?> getUser() async {
    final hasToken = await _secureStorage.hasAccessToken();
    if (!hasToken) return null;
    final json = _prefs.getString(_userKey);
    if (json == null) return null;
    return UserModel.fromJson(jsonDecode(json) as Map<String, dynamic>);
  }

  @override
  Future<void> clearAll() async {
    await _secureStorage.clearAll();
    await _prefs.remove(_userKey);
    await _prefs.remove(AppConstants.userId);
  }
}
```

- [ ] **Step 3: Write and run local datasource test**

```dart
// test/unit/auth/auth_local_datasource_test.dart
import 'package:bingo_pay/features/auth/data/datasources/auth_local_datasource.dart';
import 'package:bingo_pay/features/auth/data/models/user_model.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../helpers/mocks.dart';

class MockSharedPreferencesReal extends Mock implements SharedPreferences {}

void main() {
  late MockFlutterSecureStorage mockSecure;
  late MockSharedPreferencesReal mockPrefs;
  late AuthLocalDataSourceImpl datasource;

  setUp(() {
    mockSecure = MockFlutterSecureStorage();
    mockPrefs = MockSharedPreferencesReal();
    datasource = AuthLocalDataSourceImpl(
      // ignore: invalid_use_of_protected_member
      MockSecureStorageService(mockSecure),
      mockPrefs,
    );
  });

  const user = UserModel(
    id: '1', email: 'a@b.com', name: 'Alice',
    role: 'buyer', kycStatus: 'not_required',
  );

  test('getUser returns null when no token', () async {
    when(() => mockSecure.containsKey(key: any(named: 'key')))
        .thenAnswer((_) async => false);
    final result = await datasource.getUser();
    expect(result, isNull);
  });
}
```

Note: this test uses a thin `MockSecureStorageService` wrapper. If the test is hard to set up with the current mock structure, simplify to just verify getUser returns null when hasAccessToken returns false by mocking SecureStorageService directly:

```dart
// test/helpers/mocks.dart  — add:
class MockSecureStorageService extends Mock implements SecureStorageService {}
```

Simpler version of the test:
```dart
// test/unit/auth/auth_local_datasource_test.dart
import 'package:bingo_pay/core/storage/secure_storage_service.dart';
import 'package:bingo_pay/features/auth/data/datasources/auth_local_datasource.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MockSecureStorageService extends Mock implements SecureStorageService {}
class MockSharedPreferences extends Mock implements SharedPreferences {}

void main() {
  late MockSecureStorageService mockSecure;
  late MockSharedPreferences mockPrefs;
  late AuthLocalDataSourceImpl datasource;

  setUp(() {
    mockSecure = MockSecureStorageService();
    mockPrefs = MockSharedPreferences();
    datasource = AuthLocalDataSourceImpl(mockSecure, mockPrefs);
  });

  test('getUser returns null when no access token', () async {
    when(() => mockSecure.hasAccessToken()).thenAnswer((_) async => false);
    final result = await datasource.getUser();
    expect(result, isNull);
  });

  test('saveTokens delegates to SecureStorageService', () async {
    when(() => mockSecure.saveAccessToken(any()))
        .thenAnswer((_) async {});
    when(() => mockSecure.saveRefreshToken(any()))
        .thenAnswer((_) async {});

    await datasource.saveTokens(
      accessToken: 'acc', refreshToken: 'ref',
    );

    verify(() => mockSecure.saveAccessToken('acc')).called(1);
    verify(() => mockSecure.saveRefreshToken('ref')).called(1);
  });
}
```

Run: `flutter test test/unit/auth/auth_local_datasource_test.dart`
Expected: 2 tests pass

- [ ] **Step 4: Commit**

```bash
git add lib/features/auth/data/datasources/ test/unit/auth/auth_local_datasource_test.dart
git commit -m "feat(auth): add remote and local datasource implementations"
```

---

### Task 5: AuthRepositoryImpl

**Files:**
- Create: `lib/features/auth/data/repositories/auth_repository_impl.dart`
- Create: `test/unit/auth/auth_repository_impl_test.dart`

- [ ] **Step 1: Create AuthRepositoryImpl**

```dart
// lib/features/auth/data/repositories/auth_repository_impl.dart
import 'package:fpdart/fpdart.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/error/error_handler.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/kyc_entity.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_local_datasource.dart';
import '../datasources/auth_remote_datasource.dart';

@Injectable(as: AuthRepository)
class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource _remote;
  final AuthLocalDataSource _local;

  AuthRepositoryImpl(this._remote, this._local);

  @override
  Future<Either<Failure, UserEntity>> login({
    required String email,
    required String password,
  }) async {
    try {
      final response =
          await _remote.login(email: email, password: password);
      await _local.saveTokens(
        accessToken: response.accessToken,
        refreshToken: response.refreshToken,
      );
      await _local.saveUser(response.user);
      return Right(response.user);
    } on Exception catch (e) {
      return Left(ErrorHandler.mapExceptionToFailure(e));
    }
  }

  @override
  Future<Either<Failure, UserEntity>> register({
    required String email,
    required String password,
    required String name,
    required String role,
  }) async {
    try {
      final response = await _remote.register(
        email: email,
        password: password,
        name: name,
        role: role,
      );
      await _local.saveTokens(
        accessToken: response.accessToken,
        refreshToken: response.refreshToken,
      );
      await _local.saveUser(response.user);
      return Right(response.user);
    } on Exception catch (e) {
      return Left(ErrorHandler.mapExceptionToFailure(e));
    }
  }

  @override
  Future<Either<Failure, Unit>> forgotPassword({
    required String email,
  }) async {
    try {
      await _remote.forgotPassword(email: email);
      return const Right(unit);
    } on Exception catch (e) {
      return Left(ErrorHandler.mapExceptionToFailure(e));
    }
  }

  @override
  Future<Either<Failure, Unit>> logout() async {
    try {
      await _local.clearAll();
      return const Right(unit);
    } on Exception catch (e) {
      return Left(ErrorHandler.mapExceptionToFailure(e));
    }
  }

  @override
  Future<Either<Failure, UserEntity?>> getStoredUser() async {
    try {
      final user = await _local.getUser();
      return Right(user);
    } on Exception catch (e) {
      return Left(ErrorHandler.mapExceptionToFailure(e));
    }
  }

  @override
  Future<Either<Failure, KycEntity>> submitKycPersonalDetails({
    required String name,
    required String dateOfBirth,
    required String address,
  }) async {
    try {
      final kyc = await _remote.submitKycPersonalDetails(
        name: name,
        dateOfBirth: dateOfBirth,
        address: address,
      );
      return Right(kyc);
    } on Exception catch (e) {
      return Left(ErrorHandler.mapExceptionToFailure(e));
    }
  }

  @override
  Future<Either<Failure, KycEntity>> uploadKycDocument({
    required String filePath,
    required String documentType,
  }) async {
    try {
      final kyc = await _remote.uploadKycDocument(
        filePath: filePath,
        documentType: documentType,
      );
      return Right(kyc);
    } on Exception catch (e) {
      return Left(ErrorHandler.mapExceptionToFailure(e));
    }
  }

  @override
  Future<Either<Failure, KycEntity>> uploadKycSelfie({
    required String filePath,
  }) async {
    try {
      final kyc = await _remote.uploadKycSelfie(filePath: filePath);
      return Right(kyc);
    } on Exception catch (e) {
      return Left(ErrorHandler.mapExceptionToFailure(e));
    }
  }

  @override
  Future<Either<Failure, KycEntity>> getKycStatus() async {
    try {
      final kyc = await _remote.getKycStatus();
      return Right(kyc);
    } on Exception catch (e) {
      return Left(ErrorHandler.mapExceptionToFailure(e));
    }
  }
}
```

- [ ] **Step 2: Write and run repository test**

```dart
// test/unit/auth/auth_repository_impl_test.dart
import 'package:bingo_pay/core/error/exceptions.dart';
import 'package:bingo_pay/core/error/failures.dart';
import 'package:bingo_pay/features/auth/data/datasources/auth_local_datasource.dart';
import 'package:bingo_pay/features/auth/data/datasources/auth_remote_datasource.dart';
import 'package:bingo_pay/features/auth/data/models/auth_response_model.dart';
import 'package:bingo_pay/features/auth/data/models/user_model.dart';
import 'package:bingo_pay/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:mocktail/mocktail.dart';

class MockAuthRemote extends Mock implements AuthRemoteDataSource {}
class MockAuthLocal extends Mock implements AuthLocalDataSource {}

void main() {
  late MockAuthRemote remote;
  late MockAuthLocal local;
  late AuthRepositoryImpl repo;

  setUp(() {
    remote = MockAuthRemote();
    local = MockAuthLocal();
    repo = AuthRepositoryImpl(remote, local);
  });

  const user = UserModel(
    id: '1', email: 'a@b.com', name: 'Alice',
    role: 'buyer', kycStatus: 'not_required',
  );
  const response = AuthResponseModel(
    accessToken: 'acc', refreshToken: 'ref', user: user,
  );

  group('login', () {
    test('saves tokens and returns user on success', () async {
      when(() => remote.login(email: 'a@b.com', password: 'pw'))
          .thenAnswer((_) async => response);
      when(() => local.saveTokens(
            accessToken: 'acc',
            refreshToken: 'ref',
          )).thenAnswer((_) async {});
      when(() => local.saveUser(user)).thenAnswer((_) async {});

      final result = await repo.login(email: 'a@b.com', password: 'pw');

      expect(result, Right<Failure, UserModel>(user));
      verify(() => local.saveTokens(accessToken: 'acc', refreshToken: 'ref'))
          .called(1);
    });

    test('returns NetworkFailure when NetworkException thrown', () async {
      when(() => remote.login(email: any(named: 'email'), password: any(named: 'password')))
          .thenThrow(NetworkException());

      final result = await repo.login(email: 'a@b.com', password: 'pw');
      expect(result.isLeft(), isTrue);
      expect(
        result.fold((f) => f, (_) => null),
        isA<NetworkFailure>(),
      );
    });
  });
}
```

Run: `flutter test test/unit/auth/auth_repository_impl_test.dart`
Expected: 2 tests pass

- [ ] **Step 3: Commit**

```bash
git add lib/features/auth/data/repositories/ test/unit/auth/auth_repository_impl_test.dart
git commit -m "feat(auth): add AuthRepositoryImpl with error handling"
```

---

### Task 6: AuthBloc (events, states, bloc)

**Files:**
- Create: `lib/features/auth/presentation/bloc/auth_event.dart`
- Create: `lib/features/auth/presentation/bloc/auth_state.dart`
- Create: `lib/features/auth/presentation/bloc/auth_bloc.dart`
- Create: `test/bloc/auth_bloc_test.dart`

- [ ] **Step 1: Create AuthEvent**

```dart
// lib/features/auth/presentation/bloc/auth_event.dart
import 'package:equatable/equatable.dart';

sealed class AuthEvent extends Equatable {
  const AuthEvent();
}

class CheckAuthStatusRequested extends AuthEvent {
  const CheckAuthStatusRequested();
  @override
  List<Object> get props => [];
}

class LoginRequested extends AuthEvent {
  final String email;
  final String password;
  const LoginRequested({required this.email, required this.password});
  @override
  List<Object> get props => [email, password];
}

class RegisterRequested extends AuthEvent {
  final String email;
  final String password;
  final String name;
  final String role;
  const RegisterRequested({
    required this.email,
    required this.password,
    required this.name,
    required this.role,
  });
  @override
  List<Object> get props => [email, password, name, role];
}

class ForgotPasswordRequested extends AuthEvent {
  final String email;
  const ForgotPasswordRequested({required this.email});
  @override
  List<Object> get props => [email];
}

class LogoutRequested extends AuthEvent {
  const LogoutRequested();
  @override
  List<Object> get props => [];
}

class KycPersonalDetailsSubmitted extends AuthEvent {
  final String name;
  final String dateOfBirth;
  final String address;
  const KycPersonalDetailsSubmitted({
    required this.name,
    required this.dateOfBirth,
    required this.address,
  });
  @override
  List<Object> get props => [name, dateOfBirth, address];
}

class KycDocumentUploaded extends AuthEvent {
  final String filePath;
  final String documentType;
  const KycDocumentUploaded({
    required this.filePath,
    required this.documentType,
  });
  @override
  List<Object> get props => [filePath, documentType];
}

class KycSelfieUploaded extends AuthEvent {
  final String filePath;
  const KycSelfieUploaded({required this.filePath});
  @override
  List<Object> get props => [filePath];
}

class KycStatusPolled extends AuthEvent {
  const KycStatusPolled();
  @override
  List<Object> get props => [];
}
```

- [ ] **Step 2: Create AuthState**

```dart
// lib/features/auth/presentation/bloc/auth_state.dart
import 'package:equatable/equatable.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/kyc_entity.dart';
import '../../domain/entities/user_entity.dart';

sealed class AuthState extends Equatable {
  const AuthState();
}

class AuthInitial extends AuthState {
  const AuthInitial();
  @override
  List<Object> get props => [];
}

class AuthLoading extends AuthState {
  const AuthLoading();
  @override
  List<Object> get props => [];
}

class AuthAuthenticated extends AuthState {
  final UserEntity user;
  const AuthAuthenticated(this.user);
  @override
  List<Object> get props => [user];
}

class AuthUnauthenticated extends AuthState {
  const AuthUnauthenticated();
  @override
  List<Object> get props => [];
}

class AuthError extends AuthState {
  final Failure failure;
  const AuthError(this.failure);
  @override
  List<Object> get props => [failure];
}

class PasswordResetSent extends AuthState {
  const PasswordResetSent();
  @override
  List<Object> get props => [];
}

class KycLoading extends AuthState {
  const KycLoading();
  @override
  List<Object> get props => [];
}

class KycStepCompleted extends AuthState {
  final KycEntity kyc;
  final int step;
  const KycStepCompleted({required this.kyc, required this.step});
  @override
  List<Object> get props => [kyc, step];
}

class KycSubmitted extends AuthState {
  final KycEntity kyc;
  const KycSubmitted(this.kyc);
  @override
  List<Object> get props => [kyc];
}
```

- [ ] **Step 3: Create AuthBloc**

```dart
// lib/features/auth/presentation/bloc/auth_bloc.dart
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import '../../domain/usecases/check_auth_status_usecase.dart';
import '../../domain/usecases/forgot_password_usecase.dart';
import '../../domain/usecases/get_kyc_status_usecase.dart';
import '../../domain/usecases/login_usecase.dart';
import '../../domain/usecases/logout_usecase.dart';
import '../../domain/usecases/register_usecase.dart';
import '../../domain/usecases/submit_kyc_personal_details_usecase.dart';
import '../../domain/usecases/upload_kyc_document_usecase.dart';
import '../../domain/usecases/upload_kyc_selfie_usecase.dart';
import 'auth_event.dart';
import 'auth_state.dart';

@injectable
class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final CheckAuthStatusUseCase _checkAuthStatus;
  final LoginUseCase _login;
  final RegisterUseCase _register;
  final ForgotPasswordUseCase _forgotPassword;
  final LogoutUseCase _logout;
  final SubmitKycPersonalDetailsUseCase _kycPersonalDetails;
  final UploadKycDocumentUseCase _kycDocument;
  final UploadKycSelfieUseCase _kycSelfie;
  final GetKycStatusUseCase _getKycStatus;

  AuthBloc({
    required CheckAuthStatusUseCase checkAuthStatus,
    required LoginUseCase login,
    required RegisterUseCase register,
    required ForgotPasswordUseCase forgotPassword,
    required LogoutUseCase logout,
    required SubmitKycPersonalDetailsUseCase kycPersonalDetails,
    required UploadKycDocumentUseCase kycDocument,
    required UploadKycSelfieUseCase kycSelfie,
    required GetKycStatusUseCase getKycStatus,
  })  : _checkAuthStatus = checkAuthStatus,
        _login = login,
        _register = register,
        _forgotPassword = forgotPassword,
        _logout = logout,
        _kycPersonalDetails = kycPersonalDetails,
        _kycDocument = kycDocument,
        _kycSelfie = kycSelfie,
        _getKycStatus = getKycStatus,
        super(const AuthInitial()) {
    on<CheckAuthStatusRequested>(_onCheckAuthStatus);
    on<LoginRequested>(_onLogin);
    on<RegisterRequested>(_onRegister);
    on<ForgotPasswordRequested>(_onForgotPassword);
    on<LogoutRequested>(_onLogout);
    on<KycPersonalDetailsSubmitted>(_onKycPersonalDetails);
    on<KycDocumentUploaded>(_onKycDocument);
    on<KycSelfieUploaded>(_onKycSelfie);
    on<KycStatusPolled>(_onKycStatusPoll);
  }

  Future<void> _onCheckAuthStatus(
    CheckAuthStatusRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());
    final result = await _checkAuthStatus();
    result.fold(
      (_) => emit(const AuthUnauthenticated()),
      (user) => user != null
          ? emit(AuthAuthenticated(user))
          : emit(const AuthUnauthenticated()),
    );
  }

  Future<void> _onLogin(
    LoginRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());
    final result = await _login(
      LoginParams(email: event.email, password: event.password),
    );
    result.fold(
      (failure) => emit(AuthError(failure)),
      (user) => emit(AuthAuthenticated(user)),
    );
  }

  Future<void> _onRegister(
    RegisterRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());
    final result = await _register(
      RegisterParams(
        email: event.email,
        password: event.password,
        name: event.name,
        role: event.role,
      ),
    );
    result.fold(
      (failure) => emit(AuthError(failure)),
      (user) => emit(AuthAuthenticated(user)),
    );
  }

  Future<void> _onForgotPassword(
    ForgotPasswordRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());
    final result = await _forgotPassword(event.email);
    result.fold(
      (failure) => emit(AuthError(failure)),
      (_) => emit(const PasswordResetSent()),
    );
  }

  Future<void> _onLogout(
    LogoutRequested event,
    Emitter<AuthState> emit,
  ) async {
    await _logout();
    emit(const AuthUnauthenticated());
  }

  Future<void> _onKycPersonalDetails(
    KycPersonalDetailsSubmitted event,
    Emitter<AuthState> emit,
  ) async {
    emit(const KycLoading());
    final result = await _kycPersonalDetails(
      KycPersonalDetailsParams(
        name: event.name,
        dateOfBirth: event.dateOfBirth,
        address: event.address,
      ),
    );
    result.fold(
      (failure) => emit(AuthError(failure)),
      (kyc) => emit(KycStepCompleted(kyc: kyc, step: 0)),
    );
  }

  Future<void> _onKycDocument(
    KycDocumentUploaded event,
    Emitter<AuthState> emit,
  ) async {
    emit(const KycLoading());
    final result = await _kycDocument(
      KycDocumentParams(
        filePath: event.filePath,
        documentType: event.documentType,
      ),
    );
    result.fold(
      (failure) => emit(AuthError(failure)),
      (kyc) => emit(KycStepCompleted(kyc: kyc, step: 1)),
    );
  }

  Future<void> _onKycSelfie(
    KycSelfieUploaded event,
    Emitter<AuthState> emit,
  ) async {
    emit(const KycLoading());
    final result = await _kycSelfie(event.filePath);
    result.fold(
      (failure) => emit(AuthError(failure)),
      (kyc) => emit(KycSubmitted(kyc)),
    );
  }

  Future<void> _onKycStatusPoll(
    KycStatusPolled event,
    Emitter<AuthState> emit,
  ) async {
    final result = await _getKycStatus();
    result.fold(
      (_) {},
      (kyc) => emit(KycSubmitted(kyc)),
    );
  }
}
```

- [ ] **Step 4: Write and run BLoC test**

```dart
// test/bloc/auth_bloc_test.dart
import 'package:bloc_test/bloc_test.dart';
import 'package:bingo_pay/core/error/failures.dart';
import 'package:bingo_pay/features/auth/domain/entities/user_entity.dart';
import 'package:bingo_pay/features/auth/domain/usecases/check_auth_status_usecase.dart';
import 'package:bingo_pay/features/auth/domain/usecases/forgot_password_usecase.dart';
import 'package:bingo_pay/features/auth/domain/usecases/get_kyc_status_usecase.dart';
import 'package:bingo_pay/features/auth/domain/usecases/login_usecase.dart';
import 'package:bingo_pay/features/auth/domain/usecases/logout_usecase.dart';
import 'package:bingo_pay/features/auth/domain/usecases/register_usecase.dart';
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
class MockRegisterUseCase extends Mock implements RegisterUseCase {}
class MockForgotPasswordUseCase extends Mock implements ForgotPasswordUseCase {}
class MockLogoutUseCase extends Mock implements LogoutUseCase {}
class MockCheckAuthStatusUseCase extends Mock implements CheckAuthStatusUseCase {}
class MockKycPersonalDetailsUseCase extends Mock implements SubmitKycPersonalDetailsUseCase {}
class MockKycDocumentUseCase extends Mock implements UploadKycDocumentUseCase {}
class MockKycSelfieUseCase extends Mock implements UploadKycSelfieUseCase {}
class MockGetKycStatusUseCase extends Mock implements GetKycStatusUseCase {}

AuthBloc buildBloc({
  MockLoginUseCase? login,
  MockRegisterUseCase? register,
  MockCheckAuthStatusUseCase? checkAuth,
  MockLogoutUseCase? logout,
  MockForgotPasswordUseCase? forgotPassword,
}) =>
    AuthBloc(
      checkAuthStatus: checkAuth ?? MockCheckAuthStatusUseCase(),
      login: login ?? MockLoginUseCase(),
      register: register ?? MockRegisterUseCase(),
      forgotPassword: forgotPassword ?? MockForgotPasswordUseCase(),
      logout: logout ?? MockLogoutUseCase(),
      kycPersonalDetails: MockKycPersonalDetailsUseCase(),
      kycDocument: MockKycDocumentUseCase(),
      kycSelfie: MockKycSelfieUseCase(),
      getKycStatus: MockGetKycStatusUseCase(),
    );

void main() {
  setUpAll(() {
    registerFallbackValue(
      const LoginParams(email: '', password: ''),
    );
    registerFallbackValue(
      const RegisterParams(email: '', password: '', name: '', role: ''),
    );
  });

  const user = UserEntity(
    id: '1', email: 'a@b.com', name: 'Alice',
    role: 'buyer', kycStatus: 'not_required',
  );

  group('LoginRequested', () {
    blocTest<AuthBloc, AuthState>(
      'emits [AuthLoading, AuthAuthenticated] on success',
      build: () {
        final mockLogin = MockLoginUseCase();
        when(() => mockLogin(any()))
            .thenAnswer((_) async => const Right(user));
        return buildBloc(login: mockLogin);
      },
      act: (bloc) => bloc.add(
        const LoginRequested(email: 'a@b.com', password: 'pw'),
      ),
      expect: () => [const AuthLoading(), const AuthAuthenticated(user)],
    );

    blocTest<AuthBloc, AuthState>(
      'emits [AuthLoading, AuthError] on failure',
      build: () {
        final mockLogin = MockLoginUseCase();
        when(() => mockLogin(any()))
            .thenAnswer((_) async => const Left(NetworkFailure()));
        return buildBloc(login: mockLogin);
      },
      act: (bloc) => bloc.add(
        const LoginRequested(email: 'a@b.com', password: 'pw'),
      ),
      expect: () => [
        const AuthLoading(),
        const AuthError(NetworkFailure()),
      ],
    );
  });

  group('CheckAuthStatusRequested', () {
    blocTest<AuthBloc, AuthState>(
      'emits [AuthLoading, AuthAuthenticated] when stored user exists',
      build: () {
        final mockCheck = MockCheckAuthStatusUseCase();
        when(() => mockCheck())
            .thenAnswer((_) async => const Right(user));
        return buildBloc(checkAuth: mockCheck);
      },
      act: (bloc) => bloc.add(const CheckAuthStatusRequested()),
      expect: () => [const AuthLoading(), const AuthAuthenticated(user)],
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

Run: `flutter test test/bloc/auth_bloc_test.dart`
Expected: 5 tests pass

- [ ] **Step 5: Commit**

```bash
git add lib/features/auth/presentation/bloc/ test/bloc/
git commit -m "feat(auth): add AuthBloc with all events and states"
```

---

### Task 7: Validators utility + AppImagePicker widget

**Files:**
- Create: `lib/core/utils/validators.dart`
- Create: `lib/core/widgets/app_image_picker.dart`
- Create: `test/unit/validators_test.dart`

- [ ] **Step 1: Create Validators**

```dart
// lib/core/utils/validators.dart
class Validators {
  static String? email(String? value) {
    if (value == null || value.trim().isEmpty) return 'Email is required';
    final emailRegex = RegExp(r'^[\w.-]+@[\w.-]+\.\w{2,}$');
    if (!emailRegex.hasMatch(value.trim())) return 'Enter a valid email';
    return null;
  }

  static String? password(String? value) {
    if (value == null || value.isEmpty) return 'Password is required';
    if (value.length < 8) return 'Password must be at least 8 characters';
    return null;
  }

  static String? confirmPassword(String? value, String original) {
    if (value == null || value.isEmpty) return 'Please confirm your password';
    if (value != original) return 'Passwords do not match';
    return null;
  }

  static String? required(String? value, {String fieldName = 'This field'}) {
    if (value == null || value.trim().isEmpty) return '$fieldName is required';
    return null;
  }

  static String? name(String? value) {
    if (value == null || value.trim().isEmpty) return 'Name is required';
    if (value.trim().length < 2) return 'Name must be at least 2 characters';
    return null;
  }
}
```

- [ ] **Step 2: Create AppImagePicker**

```dart
// lib/core/widgets/app_image_picker.dart
import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_dimensions.dart';

class AppImagePicker extends StatelessWidget {
  final String? imagePath;
  final String label;
  final VoidCallback onPickFromCamera;
  final VoidCallback onPickFromGallery;

  const AppImagePicker({
    super.key,
    required this.label,
    required this.onPickFromCamera,
    required this.onPickFromGallery,
    this.imagePath,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: Theme.of(context).textTheme.labelLarge),
        const SizedBox(height: AppDimensions.spaceS),
        GestureDetector(
          onTap: () => _showPickerSheet(context),
          child: Container(
            height: 160,
            width: double.infinity,
            decoration: BoxDecoration(
              color: AppColors.surfaceVariant,
              borderRadius: BorderRadius.circular(AppDimensions.radiusM),
              border: Border.all(color: AppColors.outline),
            ),
            child: imagePath != null
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(AppDimensions.radiusM),
                    child: Image.network(imagePath!, fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => _placeholder()),
                  )
                : _placeholder(),
          ),
        ),
      ],
    );
  }

  Widget _placeholder() {
    return const Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.add_a_photo_outlined, size: 40, color: AppColors.outline),
        SizedBox(height: 8),
        Text('Tap to upload', style: TextStyle(color: AppColors.outline)),
      ],
    );
  }

  void _showPickerSheet(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      builder: (_) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt_outlined),
              title: const Text('Take a photo'),
              onTap: () {
                Navigator.pop(context);
                onPickFromCamera();
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library_outlined),
              title: const Text('Choose from gallery'),
              onTap: () {
                Navigator.pop(context);
                onPickFromGallery();
              },
            ),
          ],
        ),
      ),
    );
  }
}
```

- [ ] **Step 3: Write and run validator tests**

```dart
// test/unit/validators_test.dart
import 'package:bingo_pay/core/utils/validators.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Validators.email', () {
    test('returns error for empty value', () {
      expect(Validators.email(''), isNotNull);
      expect(Validators.email(null), isNotNull);
    });

    test('returns error for invalid email', () {
      expect(Validators.email('notanemail'), isNotNull);
      expect(Validators.email('a@'), isNotNull);
    });

    test('returns null for valid email', () {
      expect(Validators.email('user@example.com'), isNull);
    });
  });

  group('Validators.password', () {
    test('returns error when too short', () {
      expect(Validators.password('abc'), isNotNull);
    });
    test('returns null for valid password', () {
      expect(Validators.password('password123'), isNull);
    });
  });

  group('Validators.confirmPassword', () {
    test('returns error when passwords do not match', () {
      expect(Validators.confirmPassword('abc', 'xyz'), isNotNull);
    });
    test('returns null when passwords match', () {
      expect(Validators.confirmPassword('pass1234', 'pass1234'), isNull);
    });
  });
}
```

Run: `flutter test test/unit/validators_test.dart`
Expected: 5 tests pass

- [ ] **Step 4: Commit**

```bash
git add lib/core/utils/validators.dart lib/core/widgets/app_image_picker.dart test/unit/validators_test.dart
git commit -m "feat(core): add Validators utility and AppImagePicker widget"
```

---

### Task 8: Update RouteAuthState + RouteGuard + App

**Files:**
- Modify: `lib/core/router/route_guard.dart` — add isKycPending, KYC redirect
- Modify: `lib/core/router/app_router.dart` — wire real screens (placeholder paths for now, will fill in Task 14)
- Modify: `lib/app/app.dart` — add BlocProvider<AuthBloc> + BlocListener
- Modify: `test/unit/route_guard_test.dart` — add KYC redirect test

- [ ] **Step 1: Update RouteAuthState and RouteGuard**

Replace `lib/core/router/route_guard.dart` entirely:

```dart
// lib/core/router/route_guard.dart
import 'app_routes.dart';

enum UserRole { buyer, vendor }

class RouteAuthState {
  final bool isAuthenticated;
  final UserRole? role;
  final bool isKycPending;

  const RouteAuthState({
    required this.isAuthenticated,
    this.role,
    this.isKycPending = false,
  });

  const RouteAuthState.unauthenticated()
      : isAuthenticated = false,
        role = null,
        isKycPending = false;

  const RouteAuthState.authenticated({
    required UserRole role,
    bool isKycPending = false,
  })  : isAuthenticated = true,
        role = role,
        isKycPending = isKycPending;
}

class RouteGuard {
  static String? redirect({
    required String location,
    required RouteAuthState authState,
  }) {
    final isPublic = AppRoutes.publicRoutes.any(
      (r) => location == r || location.startsWith(r),
    );

    if (!authState.isAuthenticated) {
      return isPublic ? null : AppRoutes.login;
    }

    // Vendor with pending KYC must complete KYC first
    if (authState.isKycPending &&
        authState.role == UserRole.vendor &&
        location != AppRoutes.registerKyc) {
      return AppRoutes.registerKyc;
    }

    // Already logged in — redirect away from auth screens
    if (isPublic && location != AppRoutes.splash) {
      return authState.role == UserRole.vendor
          ? AppRoutes.vendorHome
          : AppRoutes.buyerHome;
    }

    // Block cross-role navigation
    if (location.startsWith('/vendor') && authState.role != UserRole.vendor) {
      return AppRoutes.buyerHome;
    }
    if (location.startsWith('/buyer') && authState.role != UserRole.buyer) {
      return AppRoutes.vendorHome;
    }

    return null;
  }
}
```

- [ ] **Step 2: Update app.dart with AuthBloc provider**

Replace `lib/app/app.dart` entirely:

```dart
// lib/app/app.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../core/di/injection.dart';
import '../core/network/connectivity_service.dart';
import '../core/router/app_router.dart';
import '../core/router/route_guard.dart';
import '../core/theme/app_theme.dart';
import '../core/widgets/app_snackbar.dart';
import '../features/auth/domain/entities/user_entity.dart';
import '../features/auth/presentation/bloc/auth_bloc.dart';
import '../features/auth/presentation/bloc/auth_event.dart';
import '../features/auth/presentation/bloc/auth_state.dart';

class App extends StatefulWidget {
  const App({super.key});

  @override
  State<App> createState() => _AppState();
}

class _AppState extends State<App> {
  final _router = getIt<AppRouter>();
  final _connectivity = getIt<ConnectivityService>();

  void _onAuthStateChanged(BuildContext context, AuthState state) {
    if (state is AuthAuthenticated) {
      _router.updateAuthState(
        RouteAuthState.authenticated(
          role: state.user.isVendor ? UserRole.vendor : UserRole.buyer,
          isKycPending: state.user.isKycPending,
        ),
      );
    } else if (state is AuthUnauthenticated) {
      _router.updateAuthState(const RouteAuthState.unauthenticated());
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider<AuthBloc>(
      create: (_) =>
          getIt<AuthBloc>()..add(const CheckAuthStatusRequested()),
      child: BlocListener<AuthBloc, AuthState>(
        listener: _onAuthStateChanged,
        child: StreamBuilder<bool>(
          stream: _connectivity.isConnected,
          builder: (context, snapshot) {
            final isConnected = snapshot.data ?? true;
            return MaterialApp.router(
              title: 'Bingo Pay',
              theme: AppTheme.light,
              darkTheme: AppTheme.dark,
              routerConfig: _router.router,
              builder: (context, child) {
                if (!isConnected) {
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    if (context.mounted) AppSnackbar.showOfflineBanner(context);
                  });
                }
                return child ?? const SizedBox.shrink();
              },
            );
          },
        ),
      ),
    );
  }
}
```

- [ ] **Step 3: Add KYC redirect test to route_guard_test.dart**

Append to the existing test file:

```dart
    test('vendor with pending KYC is redirected to /register/kyc', () {
      const state = RouteAuthState.authenticated(
        role: UserRole.vendor,
        isKycPending: true,
      );
      expect(
        RouteGuard.redirect(location: '/vendor/home', authState: state),
        AppRoutes.registerKyc,
      );
    });

    test('vendor with pending KYC already at /register/kyc is not redirected', () {
      const state = RouteAuthState.authenticated(
        role: UserRole.vendor,
        isKycPending: true,
      );
      expect(
        RouteGuard.redirect(location: AppRoutes.registerKyc, authState: state),
        isNull,
      );
    });
```

Run: `flutter test test/unit/route_guard_test.dart`
Expected: 7 tests pass

- [ ] **Step 4: Commit**

```bash
git add lib/core/router/route_guard.dart lib/app/app.dart test/unit/route_guard_test.dart
git commit -m "feat(auth): update RouteAuthState with KYC-pending guard, wire AuthBloc to App"
```

---

### Task 9: Login screen

**Files:**
- Create: `lib/features/auth/presentation/screens/login_screen.dart`
- Create: `test/widget/auth/login_screen_test.dart`

- [ ] **Step 1: Create LoginScreen**

```dart
// lib/features/auth/presentation/screens/login_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/router/app_routes.dart';
import '../../../../core/utils/validators.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_snackbar.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../bloc/auth_bloc.dart';
import '../bloc/auth_event.dart';
import '../bloc/auth_state.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _submit() {
    if (_formKey.currentState?.validate() ?? false) {
      context.read<AuthBloc>().add(
            LoginRequested(
              email: _emailController.text.trim(),
              password: _passwordController.text,
            ),
          );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocListener<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is AuthError) {
            AppSnackbar.showError(context, state.failure.message);
          }
          // Navigation handled by RouteGuard reacting to AuthAuthenticated
        },
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 48),
                  Text(
                    'Welcome Back',
                    style: Theme.of(context).textTheme.headlineMedium,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Sign in to your account',
                    style: Theme.of(context).textTheme.bodyMedium,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 40),
                  AppTextField(
                    controller: _emailController,
                    label: 'Email',
                    keyboardType: TextInputType.emailAddress,
                    validator: Validators.email,
                  ),
                  const SizedBox(height: 16),
                  AppTextField(
                    controller: _passwordController,
                    label: 'Password',
                    obscureText: _obscurePassword,
                    validator: Validators.password,
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscurePassword
                            ? Icons.visibility_outlined
                            : Icons.visibility_off_outlined,
                      ),
                      onPressed: () =>
                          setState(() => _obscurePassword = !_obscurePassword),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: () => context.push(AppRoutes.forgotPassword),
                      child: const Text('Forgot Password?'),
                    ),
                  ),
                  const SizedBox(height: 24),
                  BlocBuilder<AuthBloc, AuthState>(
                    builder: (context, state) => AppButton(
                      label: 'Sign In',
                      onPressed: _submit,
                      isLoading: state is AuthLoading,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text("Don't have an account?"),
                      TextButton(
                        onPressed: () => context.go(AppRoutes.register),
                        child: const Text('Register'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
```

- [ ] **Step 2: Write and run login screen widget test**

```dart
// test/widget/auth/login_screen_test.dart
import 'package:bloc_test/bloc_test.dart';
import 'package:bingo_pay/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:bingo_pay/features/auth/presentation/bloc/auth_event.dart';
import 'package:bingo_pay/features/auth/presentation/bloc/auth_state.dart';
import 'package:bingo_pay/features/auth/presentation/screens/login_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:mocktail/mocktail.dart';

class MockAuthBloc extends MockBloc<AuthEvent, AuthState> implements AuthBloc {}

Widget buildSubject(AuthBloc bloc) {
  return BlocProvider<AuthBloc>.value(
    value: bloc,
    child: MaterialApp.router(
      routerConfig: GoRouter(
        routes: [GoRoute(path: '/', builder: (_, _s) => const LoginScreen())],
      ),
    ),
  );
}

void main() {
  late MockAuthBloc bloc;

  setUp(() {
    bloc = MockAuthBloc();
    when(() => bloc.state).thenReturn(const AuthInitial());
  });

  tearDown(() => bloc.close());

  testWidgets('renders email and password fields', (tester) async {
    await tester.pumpWidget(buildSubject(bloc));
    expect(find.text('Email'), findsOneWidget);
    expect(find.text('Password'), findsOneWidget);
  });

  testWidgets('shows loading indicator when AuthLoading', (tester) async {
    when(() => bloc.state).thenReturn(const AuthLoading());
    await tester.pumpWidget(buildSubject(bloc));
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });

  testWidgets('dispatches LoginRequested on valid submit', (tester) async {
    await tester.pumpWidget(buildSubject(bloc));
    await tester.enterText(
        find.widgetWithText(TextFormField, 'Email'), 'a@b.com');
    await tester.enterText(
        find.widgetWithText(TextFormField, 'Password'), 'password123');
    await tester.tap(find.text('Sign In'));
    await tester.pump();
    verify(() => bloc.add(const LoginRequested(
          email: 'a@b.com',
          password: 'password123',
        ))).called(1);
  });
}
```

Run: `flutter test test/widget/auth/login_screen_test.dart`
Expected: 3 tests pass

- [ ] **Step 3: Commit**

```bash
git add lib/features/auth/presentation/screens/login_screen.dart test/widget/auth/
git commit -m "feat(auth): add LoginScreen with form validation and BLoC wiring"
```

---

### Task 10: Register screen

**Files:**
- Create: `lib/features/auth/presentation/screens/register_screen.dart`

- [ ] **Step 1: Create RegisterScreen**

```dart
// lib/features/auth/presentation/screens/register_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/router/app_routes.dart';
import '../../../../core/utils/validators.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_snackbar.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../bloc/auth_bloc.dart';
import '../bloc/auth_event.dart';
import '../bloc/auth_state.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  String _selectedRole = 'buyer';
  bool _obscurePassword = true;
  bool _obscureConfirm = true;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _submit() {
    if (_formKey.currentState?.validate() ?? false) {
      context.read<AuthBloc>().add(
            RegisterRequested(
              email: _emailController.text.trim(),
              password: _passwordController.text,
              name: _nameController.text.trim(),
              role: _selectedRole,
            ),
          );
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
          // AuthAuthenticated handled by RouteGuard — vendor goes to KYC, buyer to home
        },
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Form(
              key: _formKey,
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
                  AppTextField(
                    controller: _nameController,
                    label: 'Full Name',
                    validator: Validators.name,
                  ),
                  const SizedBox(height: 16),
                  AppTextField(
                    controller: _emailController,
                    label: 'Email',
                    keyboardType: TextInputType.emailAddress,
                    validator: Validators.email,
                  ),
                  const SizedBox(height: 16),
                  AppTextField(
                    controller: _passwordController,
                    label: 'Password',
                    obscureText: _obscurePassword,
                    validator: Validators.password,
                    suffixIcon: IconButton(
                      icon: Icon(_obscurePassword
                          ? Icons.visibility_outlined
                          : Icons.visibility_off_outlined),
                      onPressed: () =>
                          setState(() => _obscurePassword = !_obscurePassword),
                    ),
                  ),
                  const SizedBox(height: 16),
                  AppTextField(
                    controller: _confirmPasswordController,
                    label: 'Confirm Password',
                    obscureText: _obscureConfirm,
                    validator: (v) => Validators.confirmPassword(
                        v, _passwordController.text),
                    suffixIcon: IconButton(
                      icon: Icon(_obscureConfirm
                          ? Icons.visibility_outlined
                          : Icons.visibility_off_outlined),
                      onPressed: () =>
                          setState(() => _obscureConfirm = !_obscureConfirm),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text('I am a:', style: theme.textTheme.labelLarge),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: _RoleCard(
                          label: 'Buyer',
                          icon: Icons.shopping_bag_outlined,
                          isSelected: _selectedRole == 'buyer',
                          onTap: () =>
                              setState(() => _selectedRole = 'buyer'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _RoleCard(
                          label: 'Vendor',
                          icon: Icons.storefront_outlined,
                          isSelected: _selectedRole == 'vendor',
                          onTap: () =>
                              setState(() => _selectedRole = 'vendor'),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),
                  BlocBuilder<AuthBloc, AuthState>(
                    builder: (context, state) => AppButton(
                      label: 'Create Account',
                      onPressed: _submit,
                      isLoading: state is AuthLoading,
                    ),
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
      ),
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
            Icon(icon,
                color: isSelected
                    ? theme.colorScheme.primary
                    : theme.colorScheme.onSurface),
            const SizedBox(height: 8),
            Text(label,
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: isSelected
                      ? theme.colorScheme.primary
                      : theme.colorScheme.onSurface,
                )),
          ],
        ),
      ),
    );
  }
}
```

- [ ] **Step 2: Commit**

```bash
git add lib/features/auth/presentation/screens/register_screen.dart
git commit -m "feat(auth): add RegisterScreen with role selection"
```

---

### Task 11: Forgot password screen

**Files:**
- Create: `lib/features/auth/presentation/screens/forgot_password_screen.dart`

- [ ] **Step 1: Create ForgotPasswordScreen**

```dart
// lib/features/auth/presentation/screens/forgot_password_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/utils/validators.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_snackbar.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../bloc/auth_bloc.dart';
import '../bloc/auth_event.dart';
import '../bloc/auth_state.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  void _submit() {
    if (_formKey.currentState?.validate() ?? false) {
      context.read<AuthBloc>().add(
            ForgotPasswordRequested(email: _emailController.text.trim()),
          );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Forgot Password')),
      body: BlocListener<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is PasswordResetSent) {
            AppSnackbar.showSuccess(
              context,
              'Password reset email sent. Please check your inbox.',
            );
            Navigator.of(context).pop();
          } else if (state is AuthError) {
            AppSnackbar.showError(context, state.failure.message);
          }
        },
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 24),
                Text(
                  'Reset your password',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: 8),
                Text(
                  "Enter your email and we'll send you a reset link.",
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: 32),
                AppTextField(
                  controller: _emailController,
                  label: 'Email',
                  keyboardType: TextInputType.emailAddress,
                  validator: Validators.email,
                ),
                const SizedBox(height: 24),
                BlocBuilder<AuthBloc, AuthState>(
                  builder: (context, state) => AppButton(
                    label: 'Send Reset Link',
                    onPressed: _submit,
                    isLoading: state is AuthLoading,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
```

- [ ] **Step 2: Commit**

```bash
git add lib/features/auth/presentation/screens/forgot_password_screen.dart
git commit -m "feat(auth): add ForgotPasswordScreen"
```

---

### Task 12: KYC wizard (3 screens + step indicator)

**Files:**
- Create: `lib/features/auth/presentation/widgets/kyc_step_indicator.dart`
- Create: `lib/features/auth/presentation/screens/kyc/kyc_screen.dart`
- Create: `lib/features/auth/presentation/screens/kyc/kyc_document_screen.dart`
- Create: `lib/features/auth/presentation/screens/kyc/kyc_selfie_screen.dart`

- [ ] **Step 1: Create KycStepIndicator**

```dart
// lib/features/auth/presentation/widgets/kyc_step_indicator.dart
import 'package:flutter/material.dart';

class KycStepIndicator extends StatelessWidget {
  final int currentStep; // 0-based
  final int totalSteps;

  const KycStepIndicator({
    super.key,
    required this.currentStep,
    this.totalSteps = 3,
  });

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme.primary;
    return Row(
      children: List.generate(totalSteps * 2 - 1, (index) {
        if (index.isOdd) {
          return Expanded(
            child: Container(
              height: 2,
              color: index ~/ 2 < currentStep ? color : color.withAlpha(60),
            ),
          );
        }
        final step = index ~/ 2;
        final isDone = step < currentStep;
        final isCurrent = step == currentStep;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isDone || isCurrent ? color : color.withAlpha(30),
          ),
          child: Center(
            child: isDone
                ? const Icon(Icons.check, color: Colors.white, size: 16)
                : Text(
                    '${step + 1}',
                    style: TextStyle(
                      color: isCurrent ? Colors.white : color,
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                    ),
                  ),
          ),
        );
      }),
    );
  }
}
```

- [ ] **Step 2: Create KycScreen (personal details — step 1)**

```dart
// lib/features/auth/presentation/screens/kyc/kyc_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../../core/router/app_routes.dart';
import '../../../../../core/utils/validators.dart';
import '../../../../../core/widgets/app_button.dart';
import '../../../../../core/widgets/app_snackbar.dart';
import '../../../../../core/widgets/app_text_field.dart';
import '../../bloc/auth_bloc.dart';
import '../../bloc/auth_event.dart';
import '../../bloc/auth_state.dart';
import '../../widgets/kyc_step_indicator.dart';

class KycScreen extends StatefulWidget {
  const KycScreen({super.key});

  @override
  State<KycScreen> createState() => _KycScreenState();
}

class _KycScreenState extends State<KycScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _addressController = TextEditingController();
  DateTime? _selectedDate;

  @override
  void dispose() {
    _nameController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: DateTime(1990),
      firstDate: DateTime(1900),
      lastDate: DateTime.now().subtract(const Duration(days: 365 * 18)),
    );
    if (date != null) setState(() => _selectedDate = date);
  }

  void _submit() {
    if (_selectedDate == null) {
      AppSnackbar.showError(context, 'Please select your date of birth');
      return;
    }
    if (_formKey.currentState?.validate() ?? false) {
      context.read<AuthBloc>().add(
            KycPersonalDetailsSubmitted(
              name: _nameController.text.trim(),
              dateOfBirth:
                  '${_selectedDate!.year}-${_selectedDate!.month.toString().padLeft(2, '0')}-${_selectedDate!.day.toString().padLeft(2, '0')}',
              address: _addressController.text.trim(),
            ),
          );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Identity Verification'),
        automaticallyImplyLeading: false,
      ),
      body: BlocListener<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is AuthError) {
            AppSnackbar.showError(context, state.failure.message);
          }
          if (state is KycStepCompleted && state.step == 0) {
            context.push(AppRoutes.kycDocument);
          }
        },
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              const KycStepIndicator(currentStep: 0),
              const SizedBox(height: 8),
              const Text('Step 1 of 3: Personal Details'),
              const SizedBox(height: 24),
              Expanded(
                child: Form(
                  key: _formKey,
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        AppTextField(
                          controller: _nameController,
                          label: 'Full Legal Name',
                          validator: Validators.name,
                        ),
                        const SizedBox(height: 16),
                        InkWell(
                          onTap: _pickDate,
                          child: InputDecorator(
                            decoration: const InputDecoration(
                              labelText: 'Date of Birth',
                              suffixIcon:
                                  Icon(Icons.calendar_today_outlined),
                            ),
                            child: Text(
                              _selectedDate == null
                                  ? 'Select date'
                                  : '${_selectedDate!.day}/${_selectedDate!.month}/${_selectedDate!.year}',
                              style: TextStyle(
                                color: _selectedDate == null
                                    ? Theme.of(context).hintColor
                                    : null,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        AppTextField(
                          controller: _addressController,
                          label: 'Residential Address',
                          maxLines: 3,
                          validator: (v) =>
                              Validators.required(v, fieldName: 'Address'),
                        ),
                        const SizedBox(height: 32),
                        BlocBuilder<AuthBloc, AuthState>(
                          builder: (context, state) => AppButton(
                            label: 'Continue',
                            onPressed: _submit,
                            isLoading: state is KycLoading,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
```

- [ ] **Step 3: Create KycDocumentScreen (step 2)**

```dart
// lib/features/auth/presentation/screens/kyc/kyc_document_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../../../../core/router/app_routes.dart';
import '../../../../../core/widgets/app_button.dart';
import '../../../../../core/widgets/app_image_picker.dart';
import '../../../../../core/widgets/app_snackbar.dart';
import '../../bloc/auth_bloc.dart';
import '../../bloc/auth_event.dart';
import '../../bloc/auth_state.dart';
import '../../widgets/kyc_step_indicator.dart';

class KycDocumentScreen extends StatefulWidget {
  const KycDocumentScreen({super.key});

  @override
  State<KycDocumentScreen> createState() => _KycDocumentScreenState();
}

class _KycDocumentScreenState extends State<KycDocumentScreen> {
  final _picker = ImagePicker();
  String? _imagePath;
  String _documentType = 'passport';

  static const _documentTypes = [
    ('passport', 'Passport'),
    ('national_id', 'National ID'),
    ('drivers_license', "Driver's License"),
  ];

  Future<void> _pick(ImageSource source) async {
    final permission = source == ImageSource.camera
        ? Permission.camera
        : Permission.photos;
    final status = await permission.request();
    if (!status.isGranted) {
      if (mounted) AppSnackbar.showError(context, 'Permission denied');
      return;
    }
    final file = await _picker.pickImage(source: source, imageQuality: 80);
    if (file != null) setState(() => _imagePath = file.path);
  }

  void _submit() {
    if (_imagePath == null) {
      AppSnackbar.showError(context, 'Please upload your document');
      return;
    }
    context.read<AuthBloc>().add(
          KycDocumentUploaded(
            filePath: _imagePath!,
            documentType: _documentType,
          ),
        );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Identity Verification')),
      body: BlocListener<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is AuthError) {
            AppSnackbar.showError(context, state.failure.message);
          }
          if (state is KycStepCompleted && state.step == 1) {
            context.push(AppRoutes.kycSelfie);
          }
        },
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const KycStepIndicator(currentStep: 1),
              const SizedBox(height: 8),
              const Text('Step 2 of 3: Document Upload'),
              const SizedBox(height: 24),
              const Text('Document Type'),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: _documentTypes
                    .map(
                      (type) => ChoiceChip(
                        label: Text(type.$2),
                        selected: _documentType == type.$1,
                        onSelected: (_) =>
                            setState(() => _documentType = type.$1),
                      ),
                    )
                    .toList(),
              ),
              const SizedBox(height: 24),
              AppImagePicker(
                label: 'Upload Document',
                imagePath: _imagePath,
                onPickFromCamera: () => _pick(ImageSource.camera),
                onPickFromGallery: () => _pick(ImageSource.gallery),
              ),
              const Spacer(),
              BlocBuilder<AuthBloc, AuthState>(
                builder: (context, state) => AppButton(
                  label: 'Continue',
                  onPressed: _submit,
                  isLoading: state is KycLoading,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
```

- [ ] **Step 4: Create KycSelfieScreen (step 3)**

```dart
// lib/features/auth/presentation/screens/kyc/kyc_selfie_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../../../../core/widgets/app_button.dart';
import '../../../../../core/widgets/app_image_picker.dart';
import '../../../../../core/widgets/app_snackbar.dart';
import '../../bloc/auth_bloc.dart';
import '../../bloc/auth_event.dart';
import '../../bloc/auth_state.dart';
import '../../widgets/kyc_step_indicator.dart';

class KycSelfieScreen extends StatefulWidget {
  const KycSelfieScreen({super.key});

  @override
  State<KycSelfieScreen> createState() => _KycSelfieScreenState();
}

class _KycSelfieScreenState extends State<KycSelfieScreen> {
  final _picker = ImagePicker();
  String? _imagePath;

  Future<void> _pick(ImageSource source) async {
    final status = await Permission.camera.request();
    if (!status.isGranted) {
      if (mounted) AppSnackbar.showError(context, 'Camera permission required');
      return;
    }
    final file = await _picker.pickImage(
      source: source,
      preferredCameraDevice: CameraDevice.front,
      imageQuality: 80,
    );
    if (file != null) setState(() => _imagePath = file.path);
  }

  void _submit() {
    if (_imagePath == null) {
      AppSnackbar.showError(context, 'Please take a selfie');
      return;
    }
    context.read<AuthBloc>().add(KycSelfieUploaded(filePath: _imagePath!));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Identity Verification')),
      body: BlocListener<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is AuthError) {
            AppSnackbar.showError(context, state.failure.message);
          }
          // KycSubmitted: RouteGuard will clear isKycPending and navigate to vendor home
        },
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const KycStepIndicator(currentStep: 2),
              const SizedBox(height: 8),
              const Text('Step 3 of 3: Take a Selfie'),
              const SizedBox(height: 24),
              Text(
                'Please take a clear selfie holding your document.',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 24),
              AppImagePicker(
                label: 'Selfie',
                imagePath: _imagePath,
                onPickFromCamera: () => _pick(ImageSource.camera),
                onPickFromGallery: () => _pick(ImageSource.gallery),
              ),
              if (_imagePath != null) ...[
                const SizedBox(height: 24),
                const _UnderReviewCard(),
              ],
              const Spacer(),
              BlocBuilder<AuthBloc, AuthState>(
                builder: (context, state) {
                  if (state is KycSubmitted) {
                    return const _UnderReviewBanner();
                  }
                  return AppButton(
                    label: 'Submit',
                    onPressed: _submit,
                    isLoading: state is KycLoading,
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _UnderReviewCard extends StatelessWidget {
  const _UnderReviewCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.secondaryContainer,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(Icons.info_outline,
              color: Theme.of(context).colorScheme.secondary),
          const SizedBox(width: 12),
          const Expanded(
            child: Text(
              'Your submission is under review. This usually takes 1–2 business days.',
            ),
          ),
        ],
      ),
    );
  }
}

class _UnderReviewBanner extends StatelessWidget {
  const _UnderReviewBanner();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Icon(Icons.hourglass_top, size: 48),
        const SizedBox(height: 8),
        Text(
          'KYC Under Review',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 4),
        const Text('We will notify you once your identity is verified.'),
      ],
    );
  }
}
```

- [ ] **Step 5: Commit**

```bash
git add lib/features/auth/presentation/
git commit -m "feat(auth): add KYC wizard screens (personal details, document, selfie)"
```

---

### Task 13: Wire AppRouter + DI, regenerate, run all tests

**Files:**
- Modify: `lib/core/router/app_routes.dart` — add kycDocument, kycSelfie routes
- Modify: `lib/core/router/app_router.dart` — replace placeholders with real screens
- Run: `dart run build_runner build --delete-conflicting-outputs`
- Run: `flutter test`
- Run: `flutter analyze`

- [ ] **Step 1: Add KYC sub-routes to AppRoutes**

Add to `lib/core/router/app_routes.dart`:
```dart
static const String kycDocument = '/register/kyc/document';
static const String kycSelfie   = '/register/kyc/selfie';
```

And add them to `publicRoutes`:
```dart
static const List<String> publicRoutes = [
  splash,
  login,
  register,
  registerKyc,
  kycDocument,
  kycSelfie,
  forgotPassword,
];
```

- [ ] **Step 2: Replace AppRouter placeholder routes with real screens**

Replace `lib/core/router/app_router.dart` entirely:

```dart
// lib/core/router/app_router.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:injectable/injectable.dart';
import '../../features/auth/presentation/screens/forgot_password_screen.dart';
import '../../features/auth/presentation/screens/kyc/kyc_document_screen.dart';
import '../../features/auth/presentation/screens/kyc/kyc_screen.dart';
import '../../features/auth/presentation/screens/kyc/kyc_selfie_screen.dart';
import '../../features/auth/presentation/screens/login_screen.dart';
import '../../features/auth/presentation/screens/register_screen.dart';
import 'app_routes.dart';
import 'route_guard.dart';

@lazySingleton
class AppRouter {
  late final GoRouter router;
  RouteAuthState _authState = const RouteAuthState.unauthenticated();

  AppRouter() {
    router = GoRouter(
      initialLocation: AppRoutes.splash,
      redirect: (context, state) => RouteGuard.redirect(
        location: state.matchedLocation,
        authState: _authState,
      ),
      routes: [
        GoRoute(
          path: AppRoutes.splash,
          builder: (_, _s) => const _SplashPage(),
        ),
        GoRoute(
          path: AppRoutes.login,
          builder: (_, _s) => const LoginScreen(),
        ),
        GoRoute(
          path: AppRoutes.register,
          builder: (_, _s) => const RegisterScreen(),
        ),
        GoRoute(
          path: AppRoutes.forgotPassword,
          builder: (_, _s) => const ForgotPasswordScreen(),
        ),
        GoRoute(
          path: AppRoutes.registerKyc,
          builder: (_, _s) => const KycScreen(),
        ),
        GoRoute(
          path: AppRoutes.kycDocument,
          builder: (_, _s) => const KycDocumentScreen(),
        ),
        GoRoute(
          path: AppRoutes.kycSelfie,
          builder: (_, _s) => const KycSelfieScreen(),
        ),
        GoRoute(
          path: '/buyer',
          builder: (_, _s) => const _PlaceholderPage('Buyer Shell'),
          routes: [
            GoRoute(
              path: 'home',
              builder: (_, _s) => const _PlaceholderPage('Buyer Home'),
            ),
          ],
        ),
        GoRoute(
          path: '/vendor',
          builder: (_, _s) => const _PlaceholderPage('Vendor Shell'),
          routes: [
            GoRoute(
              path: 'home',
              builder: (_, _s) => const _PlaceholderPage('Vendor Home'),
            ),
          ],
        ),
      ],
    );
  }

  void updateAuthState(RouteAuthState state) {
    _authState = state;
    router.refresh();
  }
}

class _SplashPage extends StatelessWidget {
  const _SplashPage();

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(child: CircularProgressIndicator()),
    );
  }
}

class _PlaceholderPage extends StatelessWidget {
  final String name;
  const _PlaceholderPage(this.name);

  @override
  Widget build(BuildContext context) {
    return Scaffold(body: Center(child: Text(name)));
  }
}
```

- [ ] **Step 3: Run build_runner**

```bash
dart run build_runner build --delete-conflicting-outputs
```

Expected: succeeds, regenerates injection.config.dart with all new @injectable classes

- [ ] **Step 4: Run analyze**

```bash
flutter analyze
```

Expected: No issues found

- [ ] **Step 5: Run all tests**

```bash
flutter test --reporter=compact
```

Expected: all tests pass (target: 35+)

- [ ] **Step 6: Commit**

```bash
git add .
git commit -m "feat(auth): wire full auth feature — login, register, KYC, forgot password"
```
