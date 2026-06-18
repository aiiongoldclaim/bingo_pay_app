import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/api/api_client.dart';
import '../../../../core/api/api_endpoints.dart';
import '../models/auth_response_model.dart';
import '../models/kyc_model.dart';
import '../models/register_result_model.dart';

abstract interface class AuthRemoteDataSource {
  Future<AuthResponseModel> login({
    required String email,
    required String password,
  });

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
