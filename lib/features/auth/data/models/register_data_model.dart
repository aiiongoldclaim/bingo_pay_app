import '../../domain/entities/register_entity.dart';

class RegisterDataModel extends RegisterEntity {
  final BingoldModel bingold;

  const RegisterDataModel({
    required super.otpSent,
    required super.email,
    required super.message,
    required this.bingold,
  });

  factory RegisterDataModel.fromJson(Map<String, dynamic> json) {
    return RegisterDataModel(
      otpSent: json['otpSent'] ?? false,
      email: json['email'] ?? '',
      message: json['message'] ?? '',
      bingold: BingoldModel.fromJson(json['bingold'] as Map<String, dynamic>),
    );
  }
}

class BingoldModel {
  final int status;
  final bool error;
  final String message;
  final BingoldDataModel data;

  const BingoldModel({
    required this.status,
    required this.error,
    required this.message,
    required this.data,
  });

  factory BingoldModel.fromJson(Map<String, dynamic> json) {
    return BingoldModel(
      status: json['status'] ?? 0,
      error: json['error'] ?? false,
      message: json['message'] ?? '',
      data: BingoldDataModel.fromJson(json['data'] as Map<String, dynamic>),
    );
  }
}

class BingoldDataModel {
  final int maxOtpCount;
  final int referralCode;

  const BingoldDataModel({
    required this.maxOtpCount,
    required this.referralCode,
  });

  factory BingoldDataModel.fromJson(Map<String, dynamic> json) {
    return BingoldDataModel(
      maxOtpCount: json['maxOtpCount'] ?? 0,
      referralCode: json['referralCode'] ?? 0,
    );
  }
}
