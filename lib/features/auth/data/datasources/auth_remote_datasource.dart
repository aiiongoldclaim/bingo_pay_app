// import 'package:dio/dio.dart';
// import 'package:injectable/injectable.dart';
// import '../../../../core/api/api_client.dart';
// import '../../../../core/api/api_endpoints.dart';
// import '../../../../core/error/exceptions.dart';
// import '../../domain/entities/email_existence_result.dart';
// import '../models/auth_result_model.dart';
// import '../models/kyc_model.dart';
// import '../models/register_response_model.dart';
// import '../models/user_model.dart';

// abstract interface class AuthRemoteDataSource {
//   Future<AuthResultModel> login({
//     required String email,
//     required String password,
//   });

//   Future<RegisterResponseModel> register({
//     required String fullName,
//     required String password,
//     required String countryId,
//     required String email,
//     required String phone,
//   });

//   Future<AuthResultModel> verifyOtp({
//     required String email,
//     required String otp,
//   });

//   Future<void> sendSsoLoginOtp({required String email});

//   Future<AuthResultModel> verifySsoLogin({
//     required String email,
//     required String otp,
//   });

//   Future<void> setPassword({required String password});

//   Future<void> sendOtp({required String email});

//   Future<void> resendOtp({required String email});

//   Future<EmailExistenceResult> checkEmailExists({required String email});

//   Future<String> logout();

//   Future<String> forgotPassword({required String email});

//   Future<KycModel> submitKycPersonalDetails({
//     required String name,
//     required String dateOfBirth,
//     required String address,
//   });

//   Future<KycModel> uploadKycDocument({
//     required String filePath,
//     required String documentType,
//   });

//   Future<KycModel> uploadKycSelfie({required String filePath});

//   Future<KycModel> getKycStatus();
// }

// @Injectable(as: AuthRemoteDataSource)
// class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
//   final ApiClient _apiClient;
//   AuthRemoteDataSourceImpl(this._apiClient);

//   Dio get _dio => _apiClient.dio;

//   @override
//   Future<AuthResultModel> login({
//     required String email,
//     required String password,
//   }) async {
//     try {
//       final response = await _dio.post(
//         ApiEndpoints.login,
//         data: {'email': email, 'password': password},
//       );
//       final inner = (response.data['data'] as Map<String, dynamic>)['data']
//           as Map<String, dynamic>;
//       final tokens = inner['tokens'] as Map<String, dynamic>;
//       final user = inner['user'] as Map<String, dynamic>;

//       return AuthResultModel(
//         token: tokens['accessToken'] as String,
//         refreshToken: tokens['refreshToken'] as String,
//         user: UserModel.fromVerifyOtpJson(user),
//       );
//     } on DioException catch (e) {
//       final data = e.response?.data;
//       if (data is Map && data['emailVerified'] == false) {
//         throw EmailNotVerifiedException(
//           message: data['message'] as String? ??
//               'Please verify your email before logging in',
//         );
//       }
//       rethrow;
//     }
//   }

//   @override
//   Future<RegisterResponseModel> register({
//     required String fullName,
//     required String password,
//     required String countryId,
//     required String email,
//     required String phone,
//   }) async {
//     final response = await _dio.post(
//       ApiEndpoints.register,
//       data: {
//         'fullName': fullName,
//         'password': password,
//         'countryId': countryId,
//         'email': email,
//         'phone': phone,
//       },
//     );

//     return RegisterResponseModel.fromJson(
//       response.data as Map<String, dynamic>,
//     );
//   }

//   @override
//   Future<AuthResultModel> verifyOtp({
//     required String email,
//     required String otp,
//   }) async {
//     final response = await _dio.post(
//       ApiEndpoints.verifyOtp,
//       data: {'email': email, 'otp': otp},
//     );

//     final inner = (response.data['data'] as Map<String, dynamic>)['data']
//         as Map<String, dynamic>;
//     final tokens = inner['tokens'] as Map<String, dynamic>;
//     final user = inner['user'] as Map<String, dynamic>;

//     return AuthResultModel(
//       token: tokens['accessToken'] as String,
//       refreshToken: tokens['refreshToken'] as String,
//       user: UserModel.fromVerifyOtpJson(user),
//     );
//   }

//   @override
//   Future<void> sendSsoLoginOtp({required String email}) async {
//     await _dio.post(
//       ApiEndpoints.bingoldLoginOtp,
//       data: {'email': email},
//     );
//   }

//   @override
//   Future<AuthResultModel> verifySsoLogin({
//     required String email,
//     required String otp,
//   }) async {
//     final response = await _dio.post(
//       ApiEndpoints.bingoldVerifyLogin,
//       data: {'email': email, 'otp': otp},
//     );

//     final inner = (response.data['data'] as Map<String, dynamic>)['data']
//         as Map<String, dynamic>;
//     final tokens = inner['tokens'] as Map<String, dynamic>;
//     final user = inner['user'] as Map<String, dynamic>;

//     return AuthResultModel(
//       token: tokens['accessToken'] as String,
//       refreshToken: tokens['refreshToken'] as String,
//       user: UserModel.fromVerifyOtpJson(user),
//     );
//   }

//   @override
//   Future<void> setPassword({required String password}) async {
//     await _dio.post(
//       ApiEndpoints.setPassword,
//       data: {'password': password},
//     );
//   }

//   @override
//   Future<void> sendOtp({required String email}) async {
//     await _dio.post(
//       ApiEndpoints.sendOtp,
//       data: {'email': email},
//     );
//   }

//   @override
//   Future<void> resendOtp({required String email}) async {
//     await _dio.post(
//       ApiEndpoints.resendOtp,
//       data: {'email': email},
//     );
//   }

//   @override
//   Future<EmailExistenceResult> checkEmailExists({
//     required String email,
//   }) async {
//     final response = await _dio.post(
//       ApiEndpoints.userExists,
//       data: {'email': email},
//     );
//     final outer = response.data['data'] as Map<String, dynamic>?;
//     final inner = outer?['data'] as Map<String, dynamic>?;
//     return EmailExistenceResult(
//       exists: inner?['exists'] as bool? ?? false,
//       hasLocalProfile: inner?['hasLocalProfile'] as bool? ?? false,
//       localEntry: inner?['localEntry'] as bool? ?? false,
//       hasLocalPassword: inner?['hasLocalPassword'] as bool? ?? false,
//     );
//   }

//   @override
//   Future<String> logout() async {
//     final response = await _dio.post(ApiEndpoints.logout);
//     final data = response.data['data'] as Map<String, dynamic>?;
//     return data?['message'] as String? ?? 'Logged out successfully';
//   }

//   @override
//   Future<String> forgotPassword({required String email}) async {
//     final response = await _dio.post(
//       ApiEndpoints.forgotPassword,
//       data: {'email': email},
//     );
//     final data = response.data['data'] as Map<String, dynamic>?;
//     return data?['message'] as String? ?? 'Password reset link sent successfully';
//   }

//   @override
//   Future<KycModel> submitKycPersonalDetails({
//     required String name,
//     required String dateOfBirth,
//     required String address,
//   }) async {
//     final response = await _dio.post(
//       ApiEndpoints.kycPersonalDetails,
//       data: {'name': name, 'dateOfBirth': dateOfBirth, 'address': address},
//     );
//     return KycModel.fromJson(response.data['data'] as Map<String, dynamic>);
//   }

//   @override
//   Future<KycModel> uploadKycDocument({
//     required String filePath,
//     required String documentType,
//   }) async {
//     final formData = FormData.fromMap({
//       'document': await MultipartFile.fromFile(filePath),
//       'documentType': documentType,
//     });
//     final response = await _dio.post(ApiEndpoints.kycDocument, data: formData);
//     return KycModel.fromJson(response.data['data'] as Map<String, dynamic>);
//   }

//   @override
//   Future<KycModel> uploadKycSelfie({required String filePath}) async {
//     final formData = FormData.fromMap({
//       'selfie': await MultipartFile.fromFile(filePath),
//     });
//     final response = await _dio.post(ApiEndpoints.kycSelfie, data: formData);
//     return KycModel.fromJson(response.data['data'] as Map<String, dynamic>);
//   }

//   @override
//   Future<KycModel> getKycStatus() async {
//     final response = await _dio.get(ApiEndpoints.kycStatus);
//     return KycModel.fromJson(response.data['data'] as Map<String, dynamic>);
//   }
// }

//NEW FINDING ISSUE FIXED
import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/api/api_client.dart';
import '../../../../core/api/api_endpoints.dart';
import '../../../../core/error/exceptions.dart';
import '../../domain/entities/email_existence_result.dart';
import '../models/auth_result_model.dart';
import '../models/kyc_model.dart';
import '../models/register_response_model.dart';
import '../models/user_model.dart';

abstract interface class AuthRemoteDataSource {
  Future<AuthResultModel> login({
    required String email,
    required String password,
  });

  Future<RegisterResponseModel> register({
    required String fullName,
    required String password,
    required String countryId,
    required String email,
    required String phone,
  });

  Future<AuthResultModel> verifyOtp({
    required String email,
    required String otp,
  });

  Future<void> sendSsoLoginOtp({required String email});

  Future<AuthResultModel> verifySsoLogin({
    required String email,
    required String otp,
  });

  Future<void> setPassword({required String password});

  Future<void> sendOtp({required String email});

  Future<void> resendOtp({required String email});

  Future<EmailExistenceResult> checkEmailExists({required String email});

  Future<String> logout();

  Future<String> forgotPassword({required String email});

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

  // ---------------------------------------------------------------------------
  // Helpers
  // ---------------------------------------------------------------------------

  /// Safely validates that [value] is a JSON object.
  ///
  /// Instead of allowing a Dart TypeError from an unsafe `as Map` cast,
  /// we convert an invalid API response into a known ServerException.
  Map<String, dynamic> _requireMap(
    dynamic value, {
    String message = 'Invalid server response',
  }) {
    if (value is Map) {
      return Map<String, dynamic>.from(value);
    }

    throw ServerException(message: message);
  }

  /// Safely validates that [value] is a non-empty String.
  String _requireString(
    dynamic value, {
    String message = 'Invalid server response',
  }) {
    if (value is String && value.isNotEmpty) {
      return value;
    }

    throw ServerException(message: message);
  }

  /// Extracts the nested authentication payload:
  ///
  /// response
  ///   └── data
  ///       └── data
  ///           ├── tokens
  ///           └── user
  Map<String, dynamic> _extractInnerData(dynamic responseData) {
    final response = _requireMap(responseData);

    final outerData = _requireMap(
      response['data'],
      message: 'Invalid server response data',
    );

    return _requireMap(
      outerData['data'],
      message: 'Invalid server response data',
    );
  }

  /// Safely extracts the `data` object from a standard API response.
  Map<String, dynamic> _extractResponseData(
    dynamic responseData, {
    String message = 'Invalid server response',
  }) {
    final response = _requireMap(responseData);

    return _requireMap(response['data'], message: message);
  }

  // ---------------------------------------------------------------------------
  // Login
  // ---------------------------------------------------------------------------

  @override
  Future<AuthResultModel> login({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _dio.post(
        ApiEndpoints.login,
        data: {'email': email, 'password': password},
      );

      final inner = _extractInnerData(response.data);

      final tokens = _requireMap(
        inner['tokens'],
        message: 'Invalid authentication response',
      );

      final user = _requireMap(
        inner['user'],
        message: 'Invalid authentication response',
      );

      final accessToken = _requireString(
        tokens['accessToken'],
        message: 'Invalid authentication response',
      );

      final refreshToken = _requireString(
        tokens['refreshToken'],
        message: 'Invalid authentication response',
      );

      return AuthResultModel(
        token: accessToken,
        refreshToken: refreshToken,
        user: UserModel.fromVerifyOtpJson(user),
      );
    } on DioException catch (e) {
      final data = e.response?.data;

      if (data is Map && data['emailVerified'] == false) {
        final message = data['message'];

        throw EmailNotVerifiedException(
          message: message is String && message.isNotEmpty
              ? message
              : 'Please verify your email before logging in',
        );
      }

      rethrow;
    }
  }

  // ---------------------------------------------------------------------------
  // Register
  // ---------------------------------------------------------------------------

  @override
  Future<RegisterResponseModel> register({
    required String fullName,
    required String password,
    required String countryId,
    required String email,
    required String phone,
  }) async {
    final response = await _dio.post(
      ApiEndpoints.register,
      data: {
        'fullName': fullName,
        'password': password,
        'countryId': countryId,
        'email': email,
        'phone': phone,
      },
    );

    final responseMap = _requireMap(response.data);

    return RegisterResponseModel.fromJson(responseMap);
  }

  // ---------------------------------------------------------------------------
  // Verify OTP
  // ---------------------------------------------------------------------------

  @override
  Future<AuthResultModel> verifyOtp({
    required String email,
    required String otp,
  }) async {
    final response = await _dio.post(
      ApiEndpoints.verifyOtp,
      data: {'email': email, 'otp': otp},
    );

    final inner = _extractInnerData(response.data);

    final tokens = _requireMap(
      inner['tokens'],
      message: 'Invalid authentication response',
    );

    final user = _requireMap(
      inner['user'],
      message: 'Invalid authentication response',
    );

    final accessToken = _requireString(
      tokens['accessToken'],
      message: 'Invalid authentication response',
    );

    final refreshToken = _requireString(
      tokens['refreshToken'],
      message: 'Invalid authentication response',
    );

    return AuthResultModel(
      token: accessToken,
      refreshToken: refreshToken,
      user: UserModel.fromVerifyOtpJson(user),
    );
  }

  // ---------------------------------------------------------------------------
  // SSO Login OTP
  // ---------------------------------------------------------------------------

  @override
  Future<void> sendSsoLoginOtp({required String email}) async {
    await _dio.post(ApiEndpoints.bingoldLoginOtp, data: {'email': email});
  }

  // ---------------------------------------------------------------------------
  // Verify SSO Login
  // ---------------------------------------------------------------------------

  @override
  Future<AuthResultModel> verifySsoLogin({
    required String email,
    required String otp,
  }) async {
    final response = await _dio.post(
      ApiEndpoints.bingoldVerifyLogin,
      data: {'email': email, 'otp': otp},
    );

    final inner = _extractInnerData(response.data);

    final tokens = _requireMap(
      inner['tokens'],
      message: 'Invalid authentication response',
    );

    final user = _requireMap(
      inner['user'],
      message: 'Invalid authentication response',
    );

    final accessToken = _requireString(
      tokens['accessToken'],
      message: 'Invalid authentication response',
    );

    final refreshToken = _requireString(
      tokens['refreshToken'],
      message: 'Invalid authentication response',
    );

    return AuthResultModel(
      token: accessToken,
      refreshToken: refreshToken,
      user: UserModel.fromVerifyOtpJson(user),
    );
  }

  // ---------------------------------------------------------------------------
  // Set Password
  // ---------------------------------------------------------------------------

  @override
  Future<void> setPassword({required String password}) async {
    await _dio.post(ApiEndpoints.setPassword, data: {'password': password});
  }

  // ---------------------------------------------------------------------------
  // Send OTP
  // ---------------------------------------------------------------------------

  @override
  Future<void> sendOtp({required String email}) async {
    await _dio.post(ApiEndpoints.sendOtp, data: {'email': email});
  }

  // ---------------------------------------------------------------------------
  // Resend OTP
  // ---------------------------------------------------------------------------

  @override
  Future<void> resendOtp({required String email}) async {
    await _dio.post(ApiEndpoints.resendOtp, data: {'email': email});
  }

  // ---------------------------------------------------------------------------
  // Check Email Exists
  // ---------------------------------------------------------------------------

  @override
  Future<EmailExistenceResult> checkEmailExists({required String email}) async {
    final response = await _dio.post(
      ApiEndpoints.userExists,
      data: {'email': email},
    );

    final responseMap = _requireMap(response.data);

    final outer = responseMap['data'];

    if (outer == null) {
      return const EmailExistenceResult(
        exists: false,
        hasLocalProfile: false,
        localEntry: false,
        hasLocalPassword: false,
      );
    }

    final outerMap = _requireMap(
      outer,
      message: 'Invalid email existence response',
    );

    final inner = outerMap['data'];

    if (inner == null) {
      return const EmailExistenceResult(
        exists: false,
        hasLocalProfile: false,
        localEntry: false,
        hasLocalPassword: false,
      );
    }

    final innerMap = _requireMap(
      inner,
      message: 'Invalid email existence response',
    );

    return EmailExistenceResult(
      exists: innerMap['exists'] is bool ? innerMap['exists'] as bool : false,
      hasLocalProfile: innerMap['hasLocalProfile'] is bool
          ? innerMap['hasLocalProfile'] as bool
          : false,
      localEntry: innerMap['localEntry'] is bool
          ? innerMap['localEntry'] as bool
          : false,
      hasLocalPassword: innerMap['hasLocalPassword'] is bool
          ? innerMap['hasLocalPassword'] as bool
          : false,
    );
  }

  // ---------------------------------------------------------------------------
  // Logout
  // ---------------------------------------------------------------------------

  @override
  Future<String> logout() async {
    final response = await _dio.post(ApiEndpoints.logout);

    final responseMap = _requireMap(response.data);

    final data = responseMap['data'];

    if (data == null) {
      return 'Logged out successfully';
    }

    final dataMap = _requireMap(data, message: 'Invalid logout response');

    final message = dataMap['message'];

    if (message is String && message.isNotEmpty) {
      return message;
    }

    return 'Logged out successfully';
  }

  // ---------------------------------------------------------------------------
  // Forgot Password
  // ---------------------------------------------------------------------------

  @override
  Future<String> forgotPassword({required String email}) async {
    final response = await _dio.post(
      ApiEndpoints.forgotPassword,
      data: {'email': email},
    );

    final responseMap = _requireMap(response.data);

    final data = responseMap['data'];

    if (data == null) {
      return 'Password reset link sent successfully';
    }

    final dataMap = _requireMap(
      data,
      message: 'Invalid forgot password response',
    );

    final message = dataMap['message'];

    if (message is String && message.isNotEmpty) {
      return message;
    }

    return 'Password reset link sent successfully';
  }

  // ---------------------------------------------------------------------------
  // Submit KYC Personal Details
  // ---------------------------------------------------------------------------

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

    final data = _extractResponseData(
      response.data,
      message: 'Invalid KYC response',
    );

    return KycModel.fromJson(data);
  }

  // ---------------------------------------------------------------------------
  // Upload KYC Document
  // ---------------------------------------------------------------------------

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

    final data = _extractResponseData(
      response.data,
      message: 'Invalid KYC document response',
    );

    return KycModel.fromJson(data);
  }

  // ---------------------------------------------------------------------------
  // Upload KYC Selfie
  // ---------------------------------------------------------------------------

  @override
  Future<KycModel> uploadKycSelfie({required String filePath}) async {
    final formData = FormData.fromMap({
      'selfie': await MultipartFile.fromFile(filePath),
    });

    final response = await _dio.post(ApiEndpoints.kycSelfie, data: formData);

    final data = _extractResponseData(
      response.data,
      message: 'Invalid KYC selfie response',
    );

    return KycModel.fromJson(data);
  }

  // ---------------------------------------------------------------------------
  // Get KYC Status
  // ---------------------------------------------------------------------------

  @override
  Future<KycModel> getKycStatus() async {
    final response = await _dio.get(ApiEndpoints.kycStatus);

    final data = _extractResponseData(
      response.data,
      message: 'Invalid KYC status response',
    );

    return KycModel.fromJson(data);
  }
}
