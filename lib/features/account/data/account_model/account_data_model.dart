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
  final double bigoldBalance;
  final double usdtBalance;
  final List<CryptoBalance> balances;
  final WalletAddresses walletAddresses;

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
    this.bigoldBalance = 0.0,
    this.usdtBalance = 0.0,
    this.balances = const [],
    this.walletAddresses = const WalletAddresses(
      eth: '',
      usdt: '',
      busd: '',
      bnb: '',
    ),
  });

  // response.data['data']['data']; crypto balances/addresses come from the
  // nested "bingold" object (data.data.bingold.{balances,walletAddresses})
  factory AccountModel.fromJson(
    Map<String, dynamic> json, {
    List<Map<String, dynamic>> wallet = const [],
    Map<String, dynamic> walletAddresses = const {},
    String? bingoldKycStatus,
  }) {
    final balances = wallet
        .map(
          (w) => CryptoBalance(
            coin: w['coin'] as String? ?? '',
            fullName: w['full_name'] as String? ?? '',
            address: w['address'] as String? ?? '',
            balance: (w['balance'] as num?)?.toDouble() ?? 0.0,
            totalBalance: (w['total_balance'] as num?)?.toDouble() ?? 0.0,
            iconUrl: w['icon_url'] as String? ?? '',
            isWithdrawDisabled: w['is_withdraw_disabled'] == 1 ||
                w['is_withdraw_disabled'] == true,
          ),
        )
        .toList();

    double balanceForCoin(String coin) {
      for (final w in wallet) {
        if ((w['coin'] as String?)?.toLowerCase() == coin) {
          return (w['balance'] as num?)?.toDouble() ?? 0.0;
        }
      }
      return 0.0;
    }

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
      kycStatus: KycStatus.fromString(
        bingoldKycStatus ?? json['kycStatus'] as String? ?? '',
      ),
      bigoldBalance: balanceForCoin('token'),
      usdtBalance: balanceForCoin('usdt'),
      balances: balances,
      walletAddresses: WalletAddresses(
        eth: walletAddresses['eth'] as String? ?? '',
        usdt: walletAddresses['usdt'] as String? ?? '',
        busd: walletAddresses['busd'] as String? ?? '',
        bnb: walletAddresses['bnb'] as String? ?? '',
      ),
    );
  }
}
