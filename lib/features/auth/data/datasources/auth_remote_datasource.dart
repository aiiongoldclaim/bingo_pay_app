import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/api/api_client.dart';
import '../../../../core/api/api_endpoints.dart';
import '../../domain/usecases/submit_vendor_kyc_usecase.dart';
import '../models/bingold_verify_login_result_model.dart';
import '../models/kyc_model.dart';
import '../models/register_otp_model.dart';
import '../models/register_result_model.dart';
import '../models/user_existence_model.dart';
import '../models/vendor_login_result_model.dart';

abstract interface class AuthRemoteDataSource {
  Future<RegisterOtpModel> registerVendor({
    required String fullName,
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

  Future<RegisterResultModel> verifyVendorOtp({
    required String email,
    required String otp,
  });

  Future<RegisterOtpModel> resendVendorOtp({required String email});

  Future<UserExistenceModel> checkUserExists({required String email});

  Future<VendorLoginResultModel> vendorLogin({
    required String identifier,
    required String password,
  });

  Future<RegisterOtpModel> bingoldLoginOtp({required String email});

  Future<BingoldVerifyLoginResultModel> bingoldVerifyLogin({
    required String email,
    required String otp,
  });

  Future<void> setPassword({
    required String accessToken,
    required String password,
  });

  Future<void> forgotPassword({required String email});

  Future<KycModel> submitVendorKyc({
    required String vendorUuid,
    required String kybMode,
    required List<KycDocumentSubmission> documents,
  });

  Future<KycModel> getKycStatus();
}

@Injectable(as: AuthRemoteDataSource)
class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final ApiClient _apiClient;
  AuthRemoteDataSourceImpl(this._apiClient);

  Dio get _dio => _apiClient.dio;

  @override
  Future<RegisterOtpModel> registerVendor({
    required String fullName,
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
        'fullName': fullName,
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
    final outer = response.data['data'] as Map<String, dynamic>;
    return RegisterOtpModel.fromJson(outer['data'] as Map<String, dynamic>);
  }

  @override
  Future<RegisterResultModel> verifyVendorOtp({
    required String email,
    required String otp,
  }) async {
    final response = await _dio.post(
      ApiEndpoints.verifyVendorOtp,
      data: {'email': email, 'otp': otp},
    );
    final outer = response.data['data'] as Map<String, dynamic>;
    return RegisterResultModel.fromVendorJson(outer['data'] as Map<String, dynamic>);
  }

  @override
  Future<RegisterOtpModel> resendVendorOtp({required String email}) async {
    final response = await _dio.post(
      ApiEndpoints.resendVendorOtp,
      data: {'email': email},
    );
    return RegisterOtpModel.fromResendJson(
      response.data['data'] as Map<String, dynamic>,
    );
  }

  @override
  Future<UserExistenceModel> checkUserExists({required String email}) async {
    final response = await _dio.post(
      ApiEndpoints.checkUserExists,
      data: {'email': email},
    );
    final outer = response.data['data'] as Map<String, dynamic>;
    final inner = outer['data'] as Map<String, dynamic>;
    return UserExistenceModel.fromJson(inner);
  }

  @override
  Future<VendorLoginResultModel> vendorLogin({
    required String identifier,
    required String password,
  }) async {
    final response = await _dio.post(
      ApiEndpoints.vendorLogin,
      data: {'identifier': identifier, 'password': password},
    );
    final outer = response.data['data'] as Map<String, dynamic>;
    final inner = outer['data'] as Map<String, dynamic>;
    return VendorLoginResultModel.fromJson(inner);
  }

  @override
  Future<RegisterOtpModel> bingoldLoginOtp({required String email}) async {
    final response = await _dio.post(
      ApiEndpoints.bingoldLoginOtp,
      data: {'email': email},
    );
    final outer = response.data['data'] as Map<String, dynamic>;
    final inner = outer['data'] as Map<String, dynamic>;
    return RegisterOtpModel(
      otpSent: true,
      email: inner['email'] as String,
      message: outer['message'] as String? ?? '',
    );
  }

  @override
  Future<BingoldVerifyLoginResultModel> bingoldVerifyLogin({
    required String email,
    required String otp,
  }) async {
    final response = await _dio.post(
      ApiEndpoints.bingoldVerifyLogin,
      data: {'email': email, 'otp': otp},
    );
    final outer = response.data['data'] as Map<String, dynamic>;
    final inner = outer['data'] as Map<String, dynamic>;
    return BingoldVerifyLoginResultModel.fromJson(inner);
  }

  @override
  Future<void> setPassword({
    required String accessToken,
    required String password,
  }) async {
    await _dio.post(
      ApiEndpoints.setPassword,
      data: {'password': password},
      options: Options(headers: {'Authorization': 'Bearer $accessToken'}),
    );
  }

  @override
  Future<void> forgotPassword({required String email}) async {
    await _dio.post(ApiEndpoints.forgotPassword, data: {'email': email});
  }

  @override
  Future<KycModel> submitVendorKyc({
    required String vendorUuid,
    required String kybMode,
    required List<KycDocumentSubmission> documents,
  }) async {
    final response = await _dio.post(
      ApiEndpoints.vendorKyc(vendorUuid),
      data: {
        'kybMode': kybMode,
        'documents': documents.map((d) => d.toJson()).toList(),
      },
      options: Options(headers: {'x-api-key': 'mysecreate-key'}),
    );
    final outer = response.data['data'] as Map<String, dynamic>;
    final inner = outer['data'] as Map<String, dynamic>;
    return KycModel.fromJson(inner);
  }

  @override
  Future<KycModel> getKycStatus() async {
    final response = await _dio.get(ApiEndpoints.kycStatus);
    return KycModel.fromJson(response.data['data'] as Map<String, dynamic>);
  }
}
