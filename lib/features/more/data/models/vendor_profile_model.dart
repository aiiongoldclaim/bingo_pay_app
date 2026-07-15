import 'package:json_annotation/json_annotation.dart';

part 'vendor_profile_model.g.dart';

@JsonSerializable(createToJson: false)
class VendorProfileModel {
  final VendorInfoModel vendor;
  final BingoldModel bingold;

  const VendorProfileModel({required this.vendor, required this.bingold});

  factory VendorProfileModel.fromJson(Map<String, dynamic> json) =>
      _$VendorProfileModelFromJson(json);
}

@JsonSerializable(createToJson: false)
class VendorInfoModel {
  final String uuid;
  final String shopName;
  final String shopSlug;
  final String status;
  final String? verificationStatus;
  final String? kybStatus;
  final String? businessName;
  final String? merchantCode;
  final String? email;
  final String? phone;
  final String? description;
  final String? gstNumber;
  final String? panNumber;
  final String? supportEmail;
  final String? supportPhone;

  const VendorInfoModel({
    required this.uuid,
    required this.shopName,
    required this.shopSlug,
    required this.status,
    this.verificationStatus,
    this.kybStatus,
    this.businessName,
    this.merchantCode,
    this.email,
    this.phone,
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
class BingoldModel {
  final String bingoldUuid;
  final String kycStatus;
  final String status;
  final Map<String, String> walletAddresses;
  final List<BalanceModel> balances;

  const BingoldModel({
    required this.bingoldUuid,
    required this.kycStatus,
    required this.status,
    required this.walletAddresses,
    required this.balances,
  });

  factory BingoldModel.fromJson(Map<String, dynamic> json) =>
      _$BingoldModelFromJson(json);
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
