import '../../domain/enities/account_entity.dart';

class AccountModel {
  final String id;
  final String uuid;
  final String fullName;
  final String email;
  final String phone;
  final String? avatar;
  final bool emailVerified;
  final bool phoneVerified;
  final String status;
  final KycStatus kycStatus;

  const AccountModel({
    required this.id,
    required this.uuid,
    required this.fullName,
    required this.email,
    required this.phone,
    this.avatar,
    required this.emailVerified,
    required this.phoneVerified,
    required this.status,
    required this.kycStatus,
  });

  // response.data['data']['data']
  factory AccountModel.fromJson(Map<String, dynamic> json) {
    return AccountModel(
      id: json['id']?.toString() ?? '',
      uuid: json['uuid'] as String? ?? '',
      fullName: json['fullName'] as String? ?? '',
      email: json['email'] as String? ?? '',
      phone: json['phone'] as String? ?? '',
      avatar: json['avatar'] as String?,
      emailVerified: json['isEmailVerified'] as bool? ?? false,
      phoneVerified: json['isPhoneVerified'] as bool? ?? false,
      status: json['status'] as String? ?? '',
      kycStatus: KycStatus.fromString(json['kycStatus'] as String? ?? ''),
    );
  }
}
