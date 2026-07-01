import 'account_data_model.dart';

class AccountResponseModel {
  final bool success;
  final String message;
  final AccountModel account;

  const AccountResponseModel({
    required this.success,
    required this.message,
    required this.account,
  });

  // API shape: { success, statusCode, message, data: { message, data: { ...user,
  // bingold: { kycStatus, walletAddresses: {...}, balances: [...] } } }, timestamp }
  factory AccountResponseModel.fromJson(Map<String, dynamic> json) {
    final outer = json['data'] as Map<String, dynamic>? ?? const {};
    final inner = outer['data'] as Map<String, dynamic>? ?? outer;
    final bingold = inner['bingold'] as Map<String, dynamic>? ?? const {};
    final balances = (bingold['balances'] as List<dynamic>?)
            ?.whereType<Map<String, dynamic>>()
            .toList() ??
        const [];
    final walletAddresses =
        bingold['walletAddresses'] as Map<String, dynamic>? ?? const {};
    return AccountResponseModel(
      success: json['success'] as bool? ?? false,
      message: json['message'] as String? ?? '',
      account: AccountModel.fromJson(
        inner,
        wallet: balances,
        walletAddresses: walletAddresses,
        bingoldKycStatus: bingold['kycStatus'] as String?,
      ),
    );
  }
}
