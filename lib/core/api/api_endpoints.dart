class ApiEndpoints {
  static const String login = '/api/v1/auth/login';
  static const String register = '/api/v1/auth/register';
  static const String verifyOtp = '/api/v1/auth/email/verify-otp';
  static const String sendOtp = '/api/v1/auth/email/send-otp';
  static const String resendOtp = '/api/v1/auth/email/resend-otp';
  static const String userExists = '/api/v1/auth/user-exists';
  static const String refresh = '/api/v1/auth/refresh';
  static const String forgotPassword = '/api/v1/auth/forgot-password';
  static const String kycDocument = '/kyc/document';
  static const String kycSelfie = '/kyc/selfie';
  static const String kycStatus = '/kyc/status';
  static const String kycPersonalDetails = '/kyc/personal-details';
  static const String me = '/auth/me';
  static const String products = '/products';
  static const String categories = '/api/v1/categories';
  static const String transactions = '/api/v1/transactions';
  static const String invoices = '/invoices';
  static const String referral = '/referral';
  static const String profile = '/api/v1/auth/bingold/profile';
  static const String logout = '/api/v1/auth/logout';
  static const String bingoldLoginOtp = '/api/v1/auth/bingold/login-otp';
  static const String bingoldVerifyLogin = '/api/v1/auth/bingold/verify-login';
  static const String setPassword = '/api/v1/auth/set-password';
  // static const String scanner = '/api/bingold/bingopay/balance/operation';
  static const String scanner = '/api/v1/customers/bingopay/balance/operation';
  static const String cart = '/api/v1/cart';
  static const String cartItems = '/api/v1/cart/items';
  static const String cartClear = '/api/v1/cart/clear';
  static const String orders = '/api/v1/orders';
  static const String checkout = '/api/v1/checkout';
  static const String bigodIntent = '/api/v1/payments/bigod/intent';
  static const String bigodConfirm = '/api/v1/payments/bigod/confirm';

  static const String membership = '/api/v1/customer/membership';
  static const String membershipPlans = '/api/v1/customer/membership/plans';
  static const String membershipSubscribe = '/api/v1/customer/membership/subscribe';

  static String membershipCancel(String uuid) =>
      '/api/v1/customer/membership/$uuid/cancel';

  static String membershipResume(String uuid) =>
      '/api/v1/customer/membership/$uuid/resume';

  static const String services = '/api/v1/services';
  static const String brands = '/api/v1/brands';
  static const String auctions = '/api/v1/auctions';
  static const String addresses = '/api/v1/addresses';
  static const String myAuctionBids = '/api/v1/auctions/me/bids';

  static String auctionDetail(String uuid) => '/api/v1/auctions/$uuid';
  static String auctionBids(String uuid) => '/api/v1/auctions/$uuid/bids';
  static String addressDetail(String id) => '/api/v1/addresses/$id';
  static String serviceDetail(String uuid) => '/api/v1/services/$uuid';
  static String serviceAvailability(String uuid) => '/api/v1/services/$uuid/availability';
}
