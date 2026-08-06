class CurrencyFormatter {
  static const String _defaultCurrency = '\$';

  static String getCurrencySymbol(String currencyCode) {
    // Always return USD ($) regardless of input currency
    return _defaultCurrency;
  }

  static String formatPrice(String price, String currency) {
    return '$_defaultCurrency $price';
  }
}
