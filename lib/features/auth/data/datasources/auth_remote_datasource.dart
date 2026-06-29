import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/api/api_client.dart';
import '../../../../core/api/api_endpoints.dart';
import '../../../../core/error/exceptions.dart';
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

  Future<void> sendOtp({required String email});

  Future<void> resendOtp({required String email});

  Future<bool> checkEmailExists({required String email});

  Future<String> logout();

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
  Future<AuthResultModel> login({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _dio.post(
        ApiEndpoints.login,
        data: {'email': email, 'password': password},
      );
      final inner = (response.data['data'] as Map<String, dynamic>)['data']
          as Map<String, dynamic>;
      final tokens = inner['tokens'] as Map<String, dynamic>;
      final user = inner['user'] as Map<String, dynamic>;

      return AuthResultModel(
        token: tokens['accessToken'] as String,
        refreshToken: tokens['refreshToken'] as String,
        user: UserModel.fromVerifyOtpJson(user),
      );
    } on DioException catch (e) {
      final data = e.response?.data;
      if (data is Map && data['emailVerified'] == false) {
        throw EmailNotVerifiedException(
          message: data['message'] as String? ??
              'Please verify your email before logging in',
        );
      }
      rethrow;
    }
  }

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

    return RegisterResponseModel.fromJson(
      response.data as Map<String, dynamic>,
    );
  }

  @override
  Future<AuthResultModel> verifyOtp({
    required String email,
    required String otp,
  }) async {
    final response = await _dio.post(
      ApiEndpoints.verifyOtp,
      data: {'email': email, 'otp': otp},
    );

    final inner = (response.data['data'] as Map<String, dynamic>)['data']
        as Map<String, dynamic>;
    final tokens = inner['tokens'] as Map<String, dynamic>;
    final user = inner['user'] as Map<String, dynamic>;

    return AuthResultModel(
      token: tokens['accessToken'] as String,
      refreshToken: tokens['refreshToken'] as String,
      user: UserModel.fromVerifyOtpJson(user),
    );
  }

  @override
  Future<void> sendOtp({required String email}) async {
    await _dio.post(
      ApiEndpoints.sendOtp,
      data: {'email': email},
    );
  }

  @override
  Future<void> resendOtp({required String email}) async {
    await _dio.post(
      ApiEndpoints.resendOtp,
      data: {'email': email},
    );
  }

  @override
  Future<bool> checkEmailExists({required String email}) async {
    final response = await _dio.post(
      ApiEndpoints.userExists,
      data: {'email': email},
    );
    final outer = response.data['data'] as Map<String, dynamic>?;
    final inner = outer?['data'] as Map<String, dynamic>?;
    return inner?['exists'] as bool? ?? false;
  }

  @override
  Future<String> logout() async {
    final response = await _dio.post(ApiEndpoints.logout);
    final data = response.data['data'] as Map<String, dynamic>?;
    return data?['message'] as String? ?? 'Logged out successfully';
  }

  @override
  Future<void> forgotPassword({required String email}) async {
    await _dio.post(ApiEndpoints.forgotPassword, data: {'email': email});
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
