class AppRoutes {
  static const String splash = '/splash';
  static const String login = '/login';
  static const String register = '/register';
  static const String registerKyc = '/register/kyc';
  static const String kycDocument = '/register/kyc/document';
  static const String kycSelfie = '/register/kyc/selfie';
  static const String forgotPassword = '/forgot-password';

  // Buyer shell
  static const String buyerHome = '/buyer/home';
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
    registerKyc,
    kycDocument,
    kycSelfie,
    forgotPassword,
  ];
}
