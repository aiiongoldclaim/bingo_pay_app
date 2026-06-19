import 'package:equatable/equatable.dart';

class UserEntity extends Equatable {
  final String id;
  final String email;
  final String name;
  final String role;       // 'vendor'
  final String kycStatus;  // 'not_required' | 'pending' | 'under_review' | 'approved' | 'rejected'
  final String? shopName;
  final String? merchantCode;
  final String? businessName;

  const UserEntity({
    required this.id,
    required this.email,
    required this.name,
    required this.role,
    required this.kycStatus,
    this.shopName,
    this.merchantCode,
    this.businessName,
  });

  bool get isVendor => role == 'vendor';
  bool get isKycApproved => kycStatus == 'approved' || kycStatus == 'not_required';
  bool get isKycPending  => kycStatus == 'pending';

  @override
  List<Object?> get props =>
      [id, email, name, role, kycStatus, shopName, merchantCode, businessName];
}
