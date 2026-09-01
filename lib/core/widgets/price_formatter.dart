/// 7999 → "7,999"
String formatPrice(num value) {
  final digits = value.truncate().toString();
  final buffer = StringBuffer();

  for (int index = 0; index < digits.length; index++) {
    final fromEnd = digits.length - index;
    buffer.write(digits[index]);
    final remaining = fromEnd - 1;
    if (remaining == 3 || (remaining > 3 && (remaining - 3) % 2 == 0)) {
      buffer.write(',');
    }
  }
  return buffer.toString();
}

/// 7999 → "$7,999"
String formatCurrency(num value, {String symbol = '\$'}) =>
    '$symbol${formatPrice(value)}';