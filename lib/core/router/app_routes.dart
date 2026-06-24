class AppRoutes {
  static const String splash = '/splash';
  static const String login = '/login';
  static const String register = '/register';
  static const String registerOtp = '/register/otp';
  static const String registerKyc = '/register/kyc';
  static const String kycDocument = '/register/kyc/document';
  static const String kycSelfie = '/register/kyc/selfie';
  static const String forgotPassword = '/forgot-password';

  // Buyer shell
  static const String buyerHome = '/buyer/home';
  static const String home = '/home';
  static const String buyerDashboard = '/buyer/dashboard';
  static const String buyerProfile = '/buyer/profile';
  static const String buyerSettings = '/buyer/settings';
  static const String buyerNotifications = '/buyer/notifications';
  static const String buyerWishlist = '/buyer/wishlist';
  static const String buyerAddresses = '/buyer/addresses';
  static const String buyerPayments = '/buyer/payments';
  static const String buyerCatalog = '/buyer/catalog';
  static const String categories = '/categories';
  static const String cart = '/cart';
  static const String orderDetail = '/orders/detail';
  static const String orders = '/orders';
  static const String account = '/account';
  static const String wallet = '/wallet';
  static const String search = '/search';
  static const String scanner = '/scanner';
  static const String paymentSuccess = '/payment-Success';
  static const String reviewPayment = '/review-Payment';
  static const String productDetails = '/productDetails';
  static const String productListing = '/product-listing/:categoryName';
  static const String buyerSearch = '/buyer/search';
  static const String buyerCategory = '/buyer/categories/:slug';
  static const String buyerProductDetail = '/buyer/products/:id';
  static const String buyerCart = '/buyer/cart';
  static const String buyerCheckout = '/buyer/checkout';
  static const String buyerTransactions = '/buyer/transactions';
  static const String buyerTransactionDetail = '/buyer/transactions/:id';
  static const String buyerRefer = '/buyer/refer';
  static const String buyerInvoices = '/buyer/invoices';
  static const String buyerInvoiceDetail = '/buyer/invoices/:id';

  // Vendor shell
  static const String vendorHome = '/vendor/home';
  static const String vendorProducts = '/vendor/products';
  static const String vendorProductCreate = '/vendor/products/create';
  static const String vendorProductEdit = '/vendor/products/:id/edit';
  static const String vendorTransactions = '/vendor/transactions';
  static const String vendorTransactionDetail = '/vendor/transactions/:id';
  static const String vendorInvoices = '/vendor/invoices';
  static const String vendorInvoiceDetail = '/vendor/invoices/:id';

  static const List<String> publicRoutes = [
    splash,
    login,
    register,
    registerOtp,
    registerKyc,
    kycDocument,
    kycSelfie,
    forgotPassword,
  ];

  static String buyerCategoryPath(String slug) =>
      buyerCategory.replaceFirst(':slug', slug);

  static String buyerProductPath(String id) =>
      buyerProductDetail.replaceFirst(':id', id);

  static String buyerTransactionPath(String id) =>
      buyerTransactionDetail.replaceFirst(':id', id);

  static String buyerInvoicePath(String id) =>
      buyerInvoiceDetail.replaceFirst(':id', id);

  static String vendorProductEditPath(String id) =>
      vendorProductEdit.replaceFirst(':id', id);

  static String vendorTransactionPath(String id) =>
      vendorTransactionDetail.replaceFirst(':id', id);

  static String vendorInvoicePath(String id) =>
      vendorInvoiceDetail.replaceFirst(':id', id);
}
