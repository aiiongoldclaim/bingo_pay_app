class AccountModel {
  final int id;
  final String uuid;
  final String email;
  final String phone;
  final String firstName;
  final String lastName;
  final String accountType;
  final String status;
  final bool emailVerified;
  final bool phoneVerified;
  final String kycStatus; // "pending" from outer profile
  final BingoldProfileModel bingoldProfile;
  final List<CryptoBalanceModel> balances;
  final WalletAddressesModel walletAddresses;
  final double bigoldBalance;
  final double usdtBalance;

  const AccountModel({
    required this.id,
    required this.uuid,
    required this.email,
    required this.phone,
    required this.firstName,
    required this.lastName,
    required this.accountType,
    required this.status,
    required this.emailVerified,
    required this.phoneVerified,
    required this.kycStatus,
    required this.bingoldProfile,
    required this.balances,
    required this.walletAddresses,
    required this.bigoldBalance,
    required this.usdtBalance,
  });

  /// Full display name, e.g. "Nidhi Aparajita"
  String get fullName => '$firstName $lastName'.trim();
  double get displayBigoldBalance => bigoldBalance / 1e8;

  /// Avatar initials, e.g. "NP"
  String get initials {
    final f = firstName.isNotEmpty ? firstName[0].toUpperCase() : '';
    final l = lastName.isNotEmpty ? lastName[0].toUpperCase() : '';
    return '$f$l';
  }

  factory AccountModel.fromJson(Map<String, dynamic> json) {
    final profile = json['profile'] as Map<String, dynamic>;

    final bingoldJson =
        profile['bingold_profile'] as Map<String, dynamic>? ?? {};

    final balancesJson = (json['balances'] as List<dynamic>? ?? []);

    final walletJson = json['walletAddresses'] as Map<String, dynamic>? ?? {};

    return AccountModel(
      id: profile['id'] ?? 0,
      uuid: profile['uuid'] ?? '',
      email: profile['email'] ?? '',
      phone: profile['phone'] ?? '',
      firstName: profile['first_name'] ?? '',
      lastName: profile['last_name'] ?? '',
      accountType: profile['account_type'] ?? '',
      status: profile['status'] ?? '',
      emailVerified: profile['email_verified'] ?? false,
      phoneVerified: profile['phone_verified'] ?? false,
      kycStatus: profile['kyc_status'] ?? '',
      bingoldProfile: BingoldProfileModel.fromJson(bingoldJson),
      balances: balancesJson
          .map((e) => CryptoBalanceModel.fromJson(e))
          .toList(),
      walletAddresses: WalletAddressesModel.fromJson(walletJson),
      bigoldBalance: (json['bigoldBalance'] as num?)?.toDouble() ?? 0,
      usdtBalance: (json['usdtBalance'] as num?)?.toDouble() ?? 0,
    );
  }
}

// ── BingoldProfile ────────────────────────────────────────────────────────────

class BingoldProfileModel {
  final String id;
  final String email;
  final String status; // "ACTIVE"
  final String phoneNumber;
  final String? profileImage;
  final bool is2Fa;
  final String userRole;
  final String kycStatus; // "NOT_INITIATED"
  final int isCompleted;
  final int referralCode;
  final double totalReward;
  final double points;
  final UserDetail userDetail;

  const BingoldProfileModel({
    required this.id,
    required this.email,
    required this.status,
    required this.phoneNumber,
    this.profileImage,
    required this.is2Fa,
    required this.userRole,
    required this.kycStatus,
    required this.isCompleted,
    required this.referralCode,
    required this.totalReward,
    required this.points,
    required this.userDetail,
  });

  factory BingoldProfileModel.fromJson(Map<String, dynamic> json) {
    return BingoldProfileModel(
      id: json['id'] as String,
      email: json['email'] as String,
      status: json['status'] as String,
      phoneNumber: json['phoneNumber'] as String,
      profileImage: json['profileImage'] as String?,
      is2Fa: json['is2Fa'] as bool,
      userRole: json['user_role'] as String,
      kycStatus: json['kycStatus'] as String,
      isCompleted: json['isCompleted'] as int,
      referralCode: (json['referralCode'] as num).toInt(),
      totalReward: (json['totalReward'] as num).toDouble(),
      points: (json['points'] as num).toDouble(),
      userDetail: UserDetail.fromJson(
        json['userDetail'] as Map<String, dynamic>,
      ),
    );
  }
}

// ── UserDetail ────────────────────────────────────────────────────────────────

class UserDetail {
  final String? firstName;
  final String? lastName;
  final String? dob;
  final String? gender;
  final String? state;
  final String? city;
  final String? address;
  final String? postCode;
  final String? countryId;
  final String? currency;

  const UserDetail({
    this.firstName,
    this.lastName,
    this.dob,
    this.gender,
    this.state,
    this.city,
    this.address,
    this.postCode,
    this.countryId,
    this.currency,
  });

  factory UserDetail.fromJson(Map<String, dynamic> json) {
    return UserDetail(
      firstName: json['firstName'] as String?,
      lastName: json['lastName'] as String?,
      dob: json['dob'] as String?,
      gender: json['gender'] as String?,
      state: json['state'] as String?,
      city: json['city'] as String?,
      address: json['address'] as String?,
      postCode: json['postCode'] as String?,
      countryId: json['countryId'] as String?,
      currency: json['currency'] as String?,
    );
  }
}

// ── CryptoBalance ─────────────────────────────────────────────────────────────

class CryptoBalanceModel {
  final String coin;
  final String address;
  final double balance;
  final double lockedBalance;
  final bool isCrypto;
  final String iconUrl;
  final String fullName;
  final bool isWithdrawDisabled;
  final double totalBalance;

  const CryptoBalanceModel({
    required this.coin,
    required this.address,
    required this.balance,
    required this.lockedBalance,
    required this.isCrypto,
    required this.iconUrl,
    required this.fullName,
    required this.isWithdrawDisabled,
    required this.totalBalance,
  });

  factory CryptoBalanceModel.fromJson(Map<String, dynamic> json) {
    return CryptoBalanceModel(
      coin: json['coin'] ?? '',
      address: json['address'] ?? '',
      balance: (json['balance'] as num?)?.toDouble() ?? 0,
      lockedBalance: (json['locked_balance'] as num?)?.toDouble() ?? 0,
      isCrypto: (json['is_crypto'] ?? 0) == 1,
      iconUrl: json['icon_url'] ?? '',
      fullName: json['full_name'] ?? '',
      isWithdrawDisabled: (json['is_withdraw_disabled'] ?? 0) == 1,
      totalBalance: (json['total_balance'] as num?)?.toDouble() ?? 0,
    );
  }
}

// ── WalletAddresses ───────────────────────────────────────────────────────────

class WalletAddressesModel {
  final String eth;
  final String usdt;
  final String busd;
  final String bnb;

  const WalletAddressesModel({
    required this.eth,
    required this.usdt,
    required this.busd,
    required this.bnb,
  });

  factory WalletAddressesModel.fromJson(Map<String, dynamic> json) {
    return WalletAddressesModel(
      eth: json['eth'] ?? '',
      usdt: json['usdt'] ?? '',
      busd: json['busd'] ?? '',
      bnb: json['bnb'] ?? '',
    );
  }
}
