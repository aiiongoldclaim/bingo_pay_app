class AppRoutes {
  static const String splash = '/splash';
  static const String login = '/login';
  static const String register = '/register';
  static const String forgotPassword = '/forgot-password';

  // Buyer shell
  static const String home = '/home';
  static const String buyerHome = '/buyer/home';
  static const String buyerDashboard = '/buyer/dashboard';
  static const String buyerProfile = '/buyer/profile';
  static const String buyerSettings = '/buyer/settings';
  static const String buyerNotifications = '/buyer/notifications';
  static const String buyerWishlist = '/buyer/wishlist';
  static const String buyerAddresses = '/buyer/addresses';
  static const String buyerPayments = '/buyer/payments';
  static const String buyerCatalog = '/buyer/catalog';
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

  static const List<String> publicRoutes = [
    splash,
    login,
    register,
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
}
