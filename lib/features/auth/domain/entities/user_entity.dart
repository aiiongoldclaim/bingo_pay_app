import 'package:equatable/equatable.dart';

class UserEntity extends Equatable {
  final String id;
  final String email;
  final String name;
  final String kycStatus;  // 'not_required' | 'pending' | 'under_review' | 'approved' | 'rejected'
  final bool emailVerified;
  final bool phoneVerified;

  const UserEntity({
    required this.id,
    required this.email,
    required this.name,
    required this.kycStatus,
    this.emailVerified = false,
    this.phoneVerified = false,
  });

  bool get isKycApproved => kycStatus == 'approved' || kycStatus == 'not_required';
  bool get isKycPending  => kycStatus == 'pending';

  @override
  List<Object> get props =>
      [id, email, name, kycStatus, emailVerified, phoneVerified];
}
