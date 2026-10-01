import '../../domain/entities/public_settings_entity.dart';

Map<String, dynamic> _map(dynamic value) =>
    value is Map<String, dynamic> ? value : const {};

String? _nullableString(dynamic value) {
  final s = value?.toString().trim();
  return (s == null || s.isEmpty) ? null : s;
}

double? _toDouble(dynamic value) {
  if (value is num) return value.toDouble();
  return double.tryParse(value?.toString() ?? '');
}

int _toInt(dynamic value, int fallback) {
  if (value is num) return value.toInt();
  return int.tryParse(value?.toString() ?? '') ?? fallback;
}

bool _toBool(dynamic value) {
  if (value is bool) return value;
  return value?.toString().toLowerCase() == 'true';
}

class CompanyInfoModel {
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

  CompanyInfoModel({
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

  factory CompanyInfoModel.fromJson(Map<String, dynamic> json) {
    return CompanyInfoModel(
      name: json['name']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      phone: json['phone']?.toString() ?? '',
      website: json['website']?.toString() ?? '',
      address: json['address']?.toString() ?? '',
      city: json['city']?.toString() ?? '',
      country: json['country']?.toString() ?? '',
      logo: _nullableString(json['logo']),
      latitude: _toDouble(json['latitude']),
      longitude: _toDouble(json['longitude']),
    );
  }

  CompanyInfoEntity toEntity() => CompanyInfoEntity(
        name: name,
        email: email,
        phone: phone,
        website: website,
        address: address,
        city: city,
        country: country,
        logo: logo,
        latitude: latitude,
        longitude: longitude,
      );
}

class GeneralSettingsModel {
  final String siteName;
  final String? logo;
  final String? favicon;

  GeneralSettingsModel({
    required this.siteName,
    this.logo,
    this.favicon,
  });

  factory GeneralSettingsModel.fromJson(Map<String, dynamic> json) {
    return GeneralSettingsModel(
      siteName: json['site_name']?.toString() ?? '',
      logo: _nullableString(json['logo']),
      favicon: _nullableString(json['favicon']),
    );
  }

  GeneralSettingsEntity toEntity() => GeneralSettingsEntity(
        siteName: siteName,
        logo: logo,
        favicon: favicon,
      );
}

class OtpSettingsModel {
  final int otpDigits;
  final int otpExpiryMinutes;

  OtpSettingsModel({
    required this.otpDigits,
    required this.otpExpiryMinutes,
  });

  factory OtpSettingsModel.fromJson(Map<String, dynamic> json) {
    return OtpSettingsModel(
      otpDigits: _toInt(json['otp_digits'], 6),
      otpExpiryMinutes: _toInt(json['otp_expiry_minutes'], 5),
    );
  }

  OtpSettingsEntity toEntity() => OtpSettingsEntity(
        otpDigits: otpDigits,
        otpExpiryMinutes: otpExpiryMinutes,
      );
}

class PaymentSettingsModel {
  final bool nowPaymentsEnabled;
  final String nowPaymentsIpnCallbackUrl;
  final int nowPaymentsIntentTtlSeconds;
  final String nowPaymentsApiUrl;

  PaymentSettingsModel({
    required this.nowPaymentsEnabled,
    required this.nowPaymentsIpnCallbackUrl,
    required this.nowPaymentsIntentTtlSeconds,
    required this.nowPaymentsApiUrl,
  });

  factory PaymentSettingsModel.fromJson(Map<String, dynamic> json) {
    return PaymentSettingsModel(
      nowPaymentsEnabled: _toBool(json['nowpayments_enabled']),
      nowPaymentsIpnCallbackUrl:
          json['nowpayments_ipn_callback_url']?.toString() ?? '',
      nowPaymentsIntentTtlSeconds:
          _toInt(json['nowpayments_intent_ttl_seconds'], 3600),
      nowPaymentsApiUrl: json['nowpayments_api_url']?.toString() ?? '',
    );
  }

  PaymentSettingsEntity toEntity() => PaymentSettingsEntity(
        nowPaymentsEnabled: nowPaymentsEnabled,
        nowPaymentsIpnCallbackUrl: nowPaymentsIpnCallbackUrl,
        nowPaymentsIntentTtlSeconds: nowPaymentsIntentTtlSeconds,
        nowPaymentsApiUrl: nowPaymentsApiUrl,
      );
}

class AuctionSettingsModel {
  final bool bidFeeEnabled;
  final double bidFeePercent;
  final double bidFeeMin;
  final double bidFeeMax;

  AuctionSettingsModel({
    required this.bidFeeEnabled,
    required this.bidFeePercent,
    required this.bidFeeMin,
    required this.bidFeeMax,
  });

  factory AuctionSettingsModel.fromJson(Map<String, dynamic> json) {
    return AuctionSettingsModel(
      bidFeeEnabled: _toBool(json['bid_fee_enabled']),
      bidFeePercent: _toDouble(json['bid_fee_percent']) ?? 0,
      bidFeeMin: _toDouble(json['bid_fee_min']) ?? 0,
      bidFeeMax: _toDouble(json['bid_fee_max']) ?? 0,
    );
  }

  AuctionSettingsEntity toEntity() => AuctionSettingsEntity(
        bidFeeEnabled: bidFeeEnabled,
        bidFeePercent: bidFeePercent,
        bidFeeMin: bidFeeMin,
        bidFeeMax: bidFeeMax,
      );
}

class PublicSettingsModel {
  final CompanyInfoModel company;
  final GeneralSettingsModel general;
  final OtpSettingsModel otp;
  final PaymentSettingsModel payment;
  final AuctionSettingsModel auction;

  PublicSettingsModel({
    required this.company,
    required this.general,
    required this.otp,
    required this.payment,
    required this.auction,
  });

  factory PublicSettingsModel.fromJson(Map<String, dynamic> json) {
    return PublicSettingsModel(
      company: CompanyInfoModel.fromJson(_map(json['company'])),
      general: GeneralSettingsModel.fromJson(_map(json['general'])),
      otp: OtpSettingsModel.fromJson(_map(json['otp'])),
      payment: PaymentSettingsModel.fromJson(_map(json['payment'])),
      auction: AuctionSettingsModel.fromJson(_map(json['auction'])),
    );
  }

  PublicSettingsEntity toEntity() => PublicSettingsEntity(
        company: company.toEntity(),
        general: general.toEntity(),
        otp: otp.toEntity(),
        payment: payment.toEntity(),
        auction: auction.toEntity(),
      );
}
