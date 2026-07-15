import 'package:equatable/equatable.dart';

/// Vendor KYB (business) verification status, mirrors the backend's
/// Prisma `KybStatus` enum. Drives post-auth navigation: only `approved`
/// vendors may reach the dashboard.
enum KybStatus { none, inProgress, approved, rejected, recheck, expired }

KybStatus kybStatusFromString(String? raw) {
  switch ((raw ?? '').toUpperCase()) {
    case 'NONE':
      return KybStatus.none;
    case 'INPROGRESS':
      return KybStatus.inProgress;
    case 'APPROVED':
      return KybStatus.approved;
    case 'REJECTED':
      return KybStatus.rejected;
    case 'RECHECK':
      return KybStatus.recheck;
    case 'EXPIRED':
      return KybStatus.expired;
    default:
      return KybStatus.none;
  }
}

String kybStatusToString(KybStatus status) => switch (status) {
      KybStatus.none => 'none',
      KybStatus.inProgress => 'inprogress',
      KybStatus.approved => 'approved',
      KybStatus.rejected => 'rejected',
      KybStatus.recheck => 'recheck',
      KybStatus.expired => 'expired',
    };

class UserEntity extends Equatable {
  final String id;
  final String email;
  final String name;
  final String role;       // 'vendor'
  final String kycStatus;  // 'not_required' | 'pending' | 'under_review' | 'approved' | 'rejected'
  final String kybStatus;  // 'none' | 'inprogress' | 'approved' | 'rejected' | 'recheck' | 'expired'
  final String? shopName;
  final String? merchantCode;
  final String? businessName;

  const UserEntity({
    required this.id,
    required this.email,
    required this.name,
    required this.role,
    required this.kycStatus,
    this.kybStatus = 'none',
    this.shopName,
    this.merchantCode,
    this.businessName,
  });

  bool get isVendor => role == 'vendor';
  bool get isKycApproved => kycStatus == 'approved' || kycStatus == 'not_required';
  bool get isKycPending  => kycStatus == 'pending';

  /// Resolves the vendor's effective KYB status for navigation/route gating.
  ///
  /// The document-level verification outcome (kycStatus, sourced from the
  /// vendor's verificationStatus) can reach a final state — approved/
  /// rejected/recheck/expired — before the backend's broader kybStatus
  /// field catches up (e.g. kybStatus stuck at "inprogress" right after a
  /// rejection). Prefer that final outcome over kybStatus when available;
  /// otherwise fall back to kybStatus (e.g. while verificationStatus is
  /// still pending/under_review, which isn't a final outcome).
  String get effectiveKybStatus {
    final verificationOutcome = kybStatusFromString(kycStatus);
    final resolved = verificationOutcome != KybStatus.none
        ? verificationOutcome
        : kybStatusFromString(kybStatus);
    return kybStatusToString(resolved);
  }

  @override
  List<Object?> get props => [
        id,
        email,
        name,
        role,
        kycStatus,
        kybStatus,
        shopName,
        merchantCode,
        businessName,
      ];
}
