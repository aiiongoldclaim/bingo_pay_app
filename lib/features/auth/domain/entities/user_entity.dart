import 'package:equatable/equatable.dart';

class UserEntity extends Equatable {
  final String id;
  final String email;
  final String name;
  final String role;       // 'buyer' | 'vendor'
  final String kycStatus;  // 'not_required' | 'pending' | 'under_review' | 'approved' | 'rejected'

  const UserEntity({
    required this.id,
    required this.email,
    required this.name,
    required this.role,
    required this.kycStatus,
  });

  bool get isBuyer  => role == 'buyer';
  bool get isVendor => role == 'vendor';
  bool get isKycApproved => kycStatus == 'approved' || kycStatus == 'not_required';
  bool get isKycPending  => kycStatus == 'pending'  || kycStatus == 'under_review';

  @override
  List<Object> get props => [id, email, name, role, kycStatus];
}
