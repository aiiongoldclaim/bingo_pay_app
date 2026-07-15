import 'package:intl/intl.dart';

/// Single source of truth for the currency shown across the app.
///
/// Change [symbol] and every price, input prefix, and chart label in the
/// app updates. Never hardcode a currency symbol anywhere else.
class AppCurrency {
  AppCurrency._();

  static const String symbol = '\$';

  /// Prefix for price input fields, e.g. `$ `.
  static const String inputPrefix = '$symbol ';

  static final NumberFormat _whole =
      NumberFormat.currency(symbol: symbol, decimalDigits: 0);
  static final NumberFormat _precise =
      NumberFormat.currency(symbol: symbol, decimalDigits: 2);

  /// Whole-number price, e.g. `$1,234`.
  static String format(num value) => _whole.format(value);

  /// Two-decimal price, e.g. `$1,234.50`.
  static String formatPrecise(num value) => _precise.format(value);
}
