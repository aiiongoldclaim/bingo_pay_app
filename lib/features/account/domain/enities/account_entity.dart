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
  List<Object?> get props => [coin, fullName, address, balance, totalBalance, iconUrl];
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
        'NONE' => KycStatus.notInitiated,
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
  final String id;
  final String uuid;
  final String fullName;
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
    required this.fullName,
    required this.email,
    required this.phone,
    this.profileImageUrl,
    required this.kycStatus,
    required this.emailVerified,
    required this.phoneVerified,
    this.referralCode = 0,
    this.bigoldBalance = 0.0,
    this.usdtBalance = 0.0,
    this.walletAddresses =
        const WalletAddresses(eth: '', usdt: '', busd: '', bnb: ''),
    this.balances = const [],
  });

  String get initials {
    final parts = fullName.trim().split(' ');
    if (parts.isEmpty || fullName.isEmpty) return '';
    if (parts.length == 1) {
      return parts[0].isNotEmpty ? parts[0][0].toUpperCase() : '';
    }
    return '${parts.first[0]}${parts.last[0]}'.toUpperCase();
  }

  double get displayBigoldBalance => bigoldBalance / 1e8;

  @override
  List<Object?> get props => [id, uuid, email, kycStatus];
}
