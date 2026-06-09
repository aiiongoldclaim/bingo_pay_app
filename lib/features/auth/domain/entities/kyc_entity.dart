import 'package:equatable/equatable.dart';

class KycEntity extends Equatable {
  final String status;          // 'pending' | 'under_review' | 'approved' | 'rejected'
  final String? rejectionReason;

  const KycEntity({required this.status, this.rejectionReason});

  bool get isApproved    => status == 'approved';
  bool get isRejected    => status == 'rejected';
  bool get isUnderReview => status == 'under_review';

  @override
  List<Object?> get props => [status, rejectionReason];
}
