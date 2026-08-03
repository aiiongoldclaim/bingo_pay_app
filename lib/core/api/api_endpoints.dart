class ApiEndpoints {
  static const String registerVendor = '/api/v1/common/vendors/sso/register';
  static const String verifyVendorOtp = '/api/v1/common/vendors/sso/verify-otp';
  static const String resendVendorOtp = '/api/v1/common/vendors/sso/resend-otp';
  static const String checkUserExists = '/api/v1/common/vendors/sso/user-exists';
  static const String vendorLogin = '/api/v1/common/vendors/sso/login';
  static const String bingoldLoginOtp = '/api/v1/auth/bingold/login-otp';
  static const String bingoldVerifyLogin = '/api/v1/auth/bingold/verify-login';
  static const String setPassword = '/api/v1/auth/set-password';
  static const String refresh = '/auth/refresh';
  static const String forgotPassword = '/api/v1/auth/forgot-password';
  static const String kycStatus = '/kyc/status';
  static const String me = '/auth/me';
  static const String products = '/products';
  static const String createProduct = '/api/v1/products';
  static const String myProducts = '/api/v1/products/my-products';
  static const String categories = '/api/v1/categories';
  static const String categoryTree = '/api/v1/categories/tree';
  static const String brands = '/api/v1/brands';
  static const String categoryAttributes = '/api/v1/category-attributes';
  static const String attributeOptions = '/api/v1/attribute-options';
  static const String bulkImportTemplate = '/api/v1/products/bulk/template';
  static const String bulkImportUpload = '/api/v1/products/bulk/import';
  static const String uploads = '/api/v1/uploads';
  static const String transactions = '/transactions';
  static const String invoices = '/invoices';
  static const String referral = '/referral';
  static const String vendorDashboard = '/api/v1/vendors/dashboard';
  static const String vendorAnalytics = '/api/v1/vendor/analytics';
  static const String vendorAnalyticsInventory = '/api/v1/vendor/analytics/inventory';
  static const String vendorAnalyticsOrders = '/api/v1/vendor/analytics/orders';
  static const String vendorAnalyticsProducts = '/api/v1/vendor/analytics/products';
  static const String vendorAnalyticsRevenue = '/api/v1/vendor/analytics/revenue';
  static const String vendorAnalyticsTimeseries = '/api/v1/vendor/analytics/timeseries';
  static const String vendorOrders = '/api/v1/vendor-orders';
  static const String vendorDocuments = '/api/v1/vendor-documents';
  static String vendorOrderDetail(String uuid) => '/api/v1/vendor-orders/$uuid';
  static String vendorOrderStatus(String uuid) => '/api/v1/vendor-orders/$uuid/status';

  static String vendorProfile(String uuid) =>
      '/api/v1/common/vendors/$uuid/sso/profile';

  static String vendorKyc(String uuid) =>
      '/api/v1/common/vendors/$uuid/sso/kyc';

  static String productDetail(String uuid) => '/api/v1/products/$uuid';
  static String productAllMedia(String uuid) => '/api/v1/products/$uuid/media';
  static String productThumbnail(String uuid) => '/api/v1/products/$uuid/media/thumbnail';
  static String productThumbnailReplace(String uuid) =>
      '/api/v1/products/$uuid/media/thumbnail/replace';
  static String productGallery(String uuid) => '/api/v1/products/$uuid/media/gallery';
  static String productMedia(String id) => '/api/v1/products/media/$id';
  static String productSpecifications(String uuid) => '/api/v1/products/$uuid/specifications';
  static String categoryForm(String categoryUuid) => '/api/v1/products/category/$categoryUuid/form';
  static String productSubmit(String uuid) => '/api/v1/products/$uuid/submit';
  static String productResubmit(String uuid) => '/api/v1/products/$uuid/resubmit';
  static String productVariants(String uuid) => '/api/v1/products/$uuid/variants';
  static String variantDetail(String variantUuid) => '/api/v1/variants/$variantUuid';

  static const String notifications = '/api/v1/notifications/me';
  static const String notificationsReadAll = '/api/v1/notifications/read-all';
  static String notificationRead(String uuid) => '/api/v1/notifications/$uuid/read';
}
