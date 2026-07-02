class ApiEndpoints {
  static const String login = '/api/v1/auth/login';
  static const String register = '/api/v1/auth/register';
  static const String verifyOtp = '/api/v1/auth/email/verify-otp';
  static const String sendOtp = '/api/v1/auth/email/send-otp';
  static const String resendOtp = '/api/v1/auth/email/resend-otp';
  static const String userExists = '/api/v1/auth/user-exists';
  static const String refresh = '/api/v1/auth/refresh';
  static const String forgotPassword = '/auth/forgot-password';
  static const String kycDocument = '/kyc/document';
  static const String kycSelfie = '/kyc/selfie';
  static const String kycStatus = '/kyc/status';
  static const String kycPersonalDetails = '/kyc/personal-details';
  static const String me = '/auth/me';
  static const String products = '/products';
  static const String categories = '/api/v1/categories';
  static const String transactions = '/transactions';
  static const String invoices = '/invoices';
  static const String referral = '/referral';
  static const String profile = '/api/v1/auth/bingold/profile';
  static const String logout = '/api/v1/auth/logout';
  // static const String scanner = '/api/bingold/bingopay/balance/operation';
  static const String scanner = '/api/v1/customers/bingopay/balance/operation';
  static const String cart = '/api/v1/cart';
  static const String cartItems = '/api/v1/cart/items';
  static const String cartClear = '/api/v1/cart/clear';
  static const String orders = '/api/v1/orders';
}
