class ApiEndpoints {
  static const String registerVendor = '/api/v1/common/vendors/sso/register';
  static const String verifyVendorOtp = '/api/v1/common/vendors/sso/verify-otp';
  static const String resendVendorOtp = '/api/v1/common/vendors/sso/resend-otp';
  static const String checkUserExists =
      '/api/bingold/bingopay/auth/user-exists';
  static const String vendorLogin = '/api/v1/common/vendors/sso/login';
  static const String refresh = '/auth/refresh';
  static const String forgotPassword = '/auth/forgot-password';
  static const String kycDocument = '/kyc/document';
  static const String kycSelfie = '/kyc/selfie';
  static const String kycStatus = '/kyc/status';
  static const String kycPersonalDetails = '/kyc/personal-details';
  static const String me = '/auth/me';
  static const String products = '/products';
  static const String myProducts = '/api/v1/products/my-products';
  static const String categories = '/api/v1/categories';
  static const String categoryTree = '/api/v1/categories/tree';
  static const String brands = '/api/v1/brands';
  static const String categoryAttributes = '/api/v1/category-attributes';
  static const String attributeOptions = '/api/v1/attribute-options';
  static const String uploads = '/api/v1/uploads';
  static const String transactions = '/transactions';
  static const String invoices = '/invoices';
  static const String referral = '/referral';

  static String vendorProfile(String uuid) =>
      '/api/v1/common/vendors/$uuid/sso/profile';

  static String productDetail(String uuid) => '/api/v1/products/$uuid';
  static String productAllMedia(String uuid) => '/api/v1/products/$uuid/media';
  static String productThumbnail(String uuid) => '/api/v1/products/$uuid/media/thumbnail';
  static String productGallery(String uuid) => '/api/v1/products/$uuid/media/gallery';
  static String productMedia(String id) => '/api/v1/products/media/$id';
  static String productSpecifications(String uuid) => '/api/v1/products/$uuid/specifications';
  static String categoryForm(String categoryUuid) => '/api/v1/products/category/$categoryUuid/form';
  static String productSubmit(String uuid) => '/api/v1/products/$uuid/submit';
  static String productVariants(String uuid) => '/api/v1/products/$uuid/variants';
  static String variantDetail(String variantUuid) => '/api/v1/variants/$variantUuid';
}
