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
