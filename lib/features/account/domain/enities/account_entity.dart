// lib/features/account/domain/entity/account_entity.dart

import 'package:equatable/equatable.dart';

class CryptoBalance extends Equatable {
  final String coin;
  final String fullName;
  final String address;
  final double balance;
  final double totalBalance;
  final String iconUrl;
  final bool isWithdrawDisabled;

  const CryptoBalance({
    required this.coin,
    required this.fullName,
    required this.address,
    required this.balance,
    required this.totalBalance,
    required this.iconUrl,
    required this.isWithdrawDisabled,
  });

  @override
  List<Object?> get props => [
    coin,
    fullName,
    address,
    balance,
    totalBalance,
    iconUrl,
  ];
}

class WalletAddresses extends Equatable {
  final String eth;
  final String usdt;
  final String busd;
  final String bnb;

  const WalletAddresses({
    required this.eth,
    required this.usdt,
    required this.busd,
    required this.bnb,
  });

  @override
  List<Object?> get props => [eth, usdt, busd, bnb];
}

enum KycStatus {
  notInitiated,
  pending,
  approved,
  rejected,
  unknown;

  static KycStatus fromString(String value) => switch (value.toUpperCase()) {
    'NOT_INITIATED' => KycStatus.notInitiated,
    'PENDING' => KycStatus.pending,
    'APPROVED' => KycStatus.approved,
    'REJECTED' => KycStatus.rejected,
    _ => KycStatus.unknown,
  };

  String get label => switch (this) {
    KycStatus.notInitiated => 'KYC Pending',
    KycStatus.pending => 'KYC Under Review',
    KycStatus.approved => 'KYC Verified',
    KycStatus.rejected => 'KYC Rejected',
    KycStatus.unknown => 'KYC Unknown',
  };

  bool get isVerified => this == KycStatus.approved;
}

class AccountEntity extends Equatable {
  final int id;
  final String uuid;
  final String firstName;
  final String lastName;
  final String email;
  final String phone;
  final String? profileImageUrl;
  final KycStatus kycStatus;
  final bool emailVerified;
  final bool phoneVerified;
  final int referralCode;
  final double bigoldBalance;
  final double usdtBalance;
  final WalletAddresses walletAddresses;
  final List<CryptoBalance> balances;

  const AccountEntity({
    required this.id,
    required this.uuid,
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.phone,
    this.profileImageUrl,
    required this.kycStatus,
    required this.emailVerified,
    required this.phoneVerified,
    required this.referralCode,
    required this.bigoldBalance,
    required this.usdtBalance,
    required this.walletAddresses,
    required this.balances,
  });

  String get fullName => '$firstName $lastName'.trim();

  String get initials {
    final f = firstName.isNotEmpty ? firstName[0].toUpperCase() : '';
    final l = lastName.isNotEmpty ? lastName[0].toUpperCase() : '';
    return '$f$l';
  }

  @override
  List<Object?> get props => [id, uuid, email, kycStatus];
}
