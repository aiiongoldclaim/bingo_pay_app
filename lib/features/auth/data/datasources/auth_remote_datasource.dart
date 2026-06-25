import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/api/api_client.dart';
import '../../../../core/api/api_endpoints.dart';
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
    required String firstName,
    required String lastName,
    required String password,
    required String countryId,
    required String email,
    required String phoneNumber,
  });

  Future<AuthResultModel> verifyOtp({
    required String email,
    required String otp,
  });

  Future<void> resendOtp({required String email});

  Future<bool> checkEmailExists({required String email});

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
    final response = await _dio.post(
      ApiEndpoints.login,
      data: {'email': email, 'password': password},
    );
    final data = response.data['data'] as Map<String, dynamic>;
    final profile = data['profile'] as Map<String, dynamic>;
    // The login response has no token field; use the profile's uuid as the
    // stored session identifier instead.
    return AuthResultModel(
      token: profile['uuid'] as String,
      user: UserModel.fromProfileJson(profile),
    );
  }

  @override
  Future<RegisterResponseModel> register({
    required String firstName,
    required String lastName,
    required String password,
    required String countryId,
    required String email,
    required String phoneNumber,
  }) async {
    final response = await _dio.post(
      ApiEndpoints.register,
      data: {
        'firstName': firstName,
        'lastName': lastName,
        'password': password,
        'countryId': countryId,
        'email': email,
        'phoneNumber': phoneNumber,
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
      data: {
        "email": email,
        "otp": otp,
        "type": "SignUp", // Required by backend
        "tOtp": "",
        "google2faSecret": "",
        "token": "",
      },
    );

    final data = response.data["data"] as Map<String, dynamic>;

    return AuthResultModel(
      token: data["token"] as String,
      user: UserModel.fromProfileJson(data["profile"] as Map<String, dynamic>),
    );
  }

  @override
  Future<void> resendOtp({required String email}) async {
    await _dio.post(
      ApiEndpoints.resendOtp,
      data: {"email": email, "type": "SIGNUP"},
    );
  }

  @override
  Future<bool> checkEmailExists({required String email}) async {
    final response = await _dio.post(
      ApiEndpoints.userExists,
      data: {'email': email},
    );
    final data = response.data['data'] as Map<String, dynamic>;
    return data['exists'] as bool? ?? false;
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
