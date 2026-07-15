class AppRoutes {
  static const String splash = '/splash';
  static const String login = '/login';
  static const String register = '/register';
  static const String registerOtp = '/register/otp';
  static const String setPassword = '/register/set-password';
  static const String registerKyc = '/register/kyc';
  static const String forgotPassword = '/forgot-password';

  // Vendor shell
  static const String vendorHome = '/vendor/home';
  static const String vendorProducts = '/vendor/products';
  static const String vendorProductCreate = '/vendor/products/create';
  static const String vendorProductDetail = '/vendor/products/:id';
  static const String vendorProductEdit = '/vendor/products/:id/edit';
  static const String vendorTransactions = '/vendor/transactions';
  static const String vendorAnalytics = '/vendor/analytics';
  static const String vendorTransactionDetail = '/vendor/transactions/:id';
  static const String vendorOrderCreate = '/vendor/orders/create';
  static const String vendorInvoices = '/vendor/invoices';
  static const String vendorInvoiceDetail = '/vendor/invoices/:id';
  static const String vendorMore = '/vendor/more';

  static const List<String> publicRoutes = [
    splash,
    login,
    register,
    registerOtp,
    setPassword,
    registerKyc,
    forgotPassword,
  ];

  static String vendorProductDetailPath(String id) =>
      vendorProductDetail.replaceFirst(':id', id);

  static String vendorProductEditPath(String id) =>
      vendorProductEdit.replaceFirst(':id', id);

  static String vendorTransactionPath(String id) =>
      vendorTransactionDetail.replaceFirst(':id', id);

  static String vendorInvoicePath(String id) =>
      vendorInvoiceDetail.replaceFirst(':id', id);
}
