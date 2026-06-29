import '../../domain/entities/register_entity.dart';

class RegisterDataModel extends RegisterEntity {
  const RegisterDataModel({
    required super.email,
    required super.message,
    required super.expiresInMinutes,
  });

  factory RegisterDataModel.fromJson(Map<String, dynamic> json) {
    final inner = json['data'] as Map<String, dynamic>? ?? {};
    return RegisterDataModel(
      message: json['message'] as String? ?? '',
      email: inner['email'] as String? ?? '',
      expiresInMinutes: inner['expiresInMinutes'] as int? ?? 0,
    );
  }
}
