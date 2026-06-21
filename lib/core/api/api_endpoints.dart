class ApiEndpoints {
  static const String registerVendor = '/api/v1/common/vendors/sso/register';
  static const String vendorLogin = '/api/v1/common/vendors/sso/login';
  static const String refresh = '/auth/refresh';
  static const String forgotPassword = '/auth/forgot-password';
  static const String kycDocument = '/kyc/document';
  static const String kycSelfie = '/kyc/selfie';
  static const String kycStatus = '/kyc/status';
  static const String kycPersonalDetails = '/kyc/personal-details';
  static const String me = '/auth/me';
  static const String products = '/products';
  static const String transactions = '/transactions';
  static const String invoices = '/invoices';
  static const String referral = '/referral';

  static String vendorProfile(String uuid) =>
      '/api/v1/common/vendors/$uuid/sso/profile';
}
