import 'package:json_annotation/json_annotation.dart';

part 'vendor_profile_model.g.dart';

@JsonSerializable(createToJson: false)
class VendorProfileModel {
  final VendorInfoModel vendor;
  final Map<String, String> walletAddresses;
  final List<BalanceModel> balances;
  final double bigoldBalance;
  final double usdtBalance;

  const VendorProfileModel({
    required this.vendor,
    required this.walletAddresses,
    required this.balances,
    required this.bigoldBalance,
    required this.usdtBalance,
  });

  factory VendorProfileModel.fromJson(Map<String, dynamic> json) =>
      _$VendorProfileModelFromJson(json);
}

@JsonSerializable(createToJson: false)
class VendorInfoModel {
  final String uuid;
  final String shopName;
  final String shopSlug;
  final String businessName;
  final String? merchantCode;
  final String status;
  final String kycStatus;
  final String email;
  final String phone;
  final String? description;
  final String? gstNumber;
  final String? panNumber;
  final String? supportEmail;
  final String? supportPhone;

  const VendorInfoModel({
    required this.uuid,
    required this.shopName,
    required this.shopSlug,
    required this.businessName,
    this.merchantCode,
    required this.status,
    required this.kycStatus,
    required this.email,
    required this.phone,
    this.description,
    this.gstNumber,
    this.panNumber,
    this.supportEmail,
    this.supportPhone,
  });

  factory VendorInfoModel.fromJson(Map<String, dynamic> json) =>
      _$VendorInfoModelFromJson(json);
}

@JsonSerializable(createToJson: false)
class BalanceModel {
  final String coin;
  final String address;
  final double balance;
  @JsonKey(name: 'full_name')
  final String fullName;
  @JsonKey(name: 'icon_url')
  final String iconUrl;
  @JsonKey(name: 'total_balance')
  final double totalBalance;

  const BalanceModel({
    required this.coin,
    required this.address,
    required this.balance,
    required this.fullName,
    required this.iconUrl,
    required this.totalBalance,
  });

  factory BalanceModel.fromJson(Map<String, dynamic> json) =>
      _$BalanceModelFromJson(json);
}
