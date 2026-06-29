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

  // API shape: { success, statusCode, message, data: { message, data: { ...user } } }
  factory AccountResponseModel.fromJson(Map<String, dynamic> json) {
    final outer = json['data'] as Map<String, dynamic>;
    final inner = outer['data'] as Map<String, dynamic>;
    return AccountResponseModel(
      success: json['success'] as bool? ?? false,
      message: json['message'] as String? ?? '',
      account: AccountModel.fromJson(inner),
    );
  }
}
