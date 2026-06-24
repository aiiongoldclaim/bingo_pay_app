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

  factory AccountResponseModel.fromJson(Map<String, dynamic> json) {
    return AccountResponseModel(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      account: AccountModel.fromJson(json['data'] as Map<String, dynamic>),
    );
  }
}
