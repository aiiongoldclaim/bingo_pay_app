class ApiEndpoints {
  static const String login = '/api/bingold/bingopay/auth/login';
  static const String register = '/api/bingold/bingopay/auth/register';
  static const String verifyOtp = '/api/bingold/bingopay/auth/verify-otp';
  static const String resendOtp = '/api/bingold/bingopay/auth/resend-otp';
  static const String userExists = '/api/bingold/bingopay/auth/user-exists';
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
  static const String profile = '/api/bingold/bingopay/auth/profile';
  static const String scanner = '/api/bingold/bingopay/balance/operation';
}
