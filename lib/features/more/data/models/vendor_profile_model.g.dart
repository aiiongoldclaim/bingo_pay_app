// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'vendor_profile_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

VendorProfileModel _$VendorProfileModelFromJson(Map<String, dynamic> json) =>
    VendorProfileModel(
      vendor: VendorInfoModel.fromJson(json['vendor'] as Map<String, dynamic>),
      walletAddresses: Map<String, String>.from(json['walletAddresses'] as Map),
      balances: (json['balances'] as List<dynamic>)
          .map((e) => BalanceModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      bigoldBalance: (json['bigoldBalance'] as num).toDouble(),
      usdtBalance: (json['usdtBalance'] as num).toDouble(),
    );

VendorInfoModel _$VendorInfoModelFromJson(Map<String, dynamic> json) =>
    VendorInfoModel(
      uuid: json['uuid'] as String,
      shopName: json['shopName'] as String,
      shopSlug: json['shopSlug'] as String,
      businessName: json['businessName'] as String,
      merchantCode: json['merchantCode'] as String?,
      status: json['status'] as String,
      kycStatus: json['kycStatus'] as String,
      email: json['email'] as String,
      phone: json['phone'] as String,
      description: json['description'] as String?,
      gstNumber: json['gstNumber'] as String?,
      panNumber: json['panNumber'] as String?,
      supportEmail: json['supportEmail'] as String?,
      supportPhone: json['supportPhone'] as String?,
    );

BalanceModel _$BalanceModelFromJson(Map<String, dynamic> json) => BalanceModel(
  coin: json['coin'] as String,
  address: json['address'] as String,
  balance: (json['balance'] as num).toDouble(),
  fullName: json['full_name'] as String,
  iconUrl: json['icon_url'] as String,
  totalBalance: (json['total_balance'] as num).toDouble(),
);
