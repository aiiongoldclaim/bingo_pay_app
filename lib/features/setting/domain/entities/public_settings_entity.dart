class CompanyInfoEntity {
  final String name;
  final String email;
  final String phone;
  final String website;
  final String address;
  final String city;
  final String country;
  final String? logo;
  final double? latitude;
  final double? longitude;

  CompanyInfoEntity({
    required this.name,
    required this.email,
    required this.phone,
    required this.website,
    required this.address,
    required this.city,
    required this.country,
    this.logo,
    this.latitude,
    this.longitude,
  });

  String get fullAddress => [address, city, country]
      .where((part) => part.trim().isNotEmpty)
      .join(', ');
}

class GeneralSettingsEntity {
  final String siteName;
  final String? logo;
  final String? favicon;

  GeneralSettingsEntity({
    required this.siteName,
    this.logo,
    this.favicon,
  });
}

class OtpSettingsEntity {
  final int otpDigits;
  final int otpExpiryMinutes;

  OtpSettingsEntity({
    required this.otpDigits,
    required this.otpExpiryMinutes,
  });
}

class PaymentSettingsEntity {
  final bool nowPaymentsEnabled;
  final String nowPaymentsIpnCallbackUrl;
  final int nowPaymentsIntentTtlSeconds;
  final String nowPaymentsApiUrl;

  PaymentSettingsEntity({
    required this.nowPaymentsEnabled,
    required this.nowPaymentsIpnCallbackUrl,
    required this.nowPaymentsIntentTtlSeconds,
    required this.nowPaymentsApiUrl,
  });
}

class AuctionSettingsEntity {
  final bool bidFeeEnabled;
  final double bidFeePercent;
  final double bidFeeMin;
  final double bidFeeMax;

  AuctionSettingsEntity({
    required this.bidFeeEnabled,
    required this.bidFeePercent,
    required this.bidFeeMin,
    required this.bidFeeMax,
  });
}

class PublicSettingsEntity {
  final CompanyInfoEntity company;
  final GeneralSettingsEntity general;
  final OtpSettingsEntity otp;
  final PaymentSettingsEntity payment;
  final AuctionSettingsEntity auction;

  PublicSettingsEntity({
    required this.company,
    required this.general,
    required this.otp,
    required this.payment,
    required this.auction,
  });
}
