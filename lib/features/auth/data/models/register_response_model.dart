import 'register_data_model.dart';

class RegisterResponseModel {
  final bool success;
  final String message;
  final RegisterDataModel data;

  const RegisterResponseModel({
    required this.success,
    required this.message,
    required this.data,
  });

  factory RegisterResponseModel.fromJson(Map<String, dynamic> json) {
    return RegisterResponseModel(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      data: RegisterDataModel.fromJson(json['data'] as Map<String, dynamic>),
    );
  }
}
