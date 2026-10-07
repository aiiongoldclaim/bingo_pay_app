/// 7999 → "7,999", 7999.5 → "7,999.50"
String formatPrice(num value) {
  final parts = _splitAmount(value);
  final digits = parts.integer;
  final buffer = StringBuffer(parts.sign);

  for (int index = 0; index < digits.length; index++) {
    final fromEnd = digits.length - index;
    buffer.write(digits[index]);
    final remaining = fromEnd - 1;
    if (remaining == 3 || (remaining > 3 && (remaining - 3) % 2 == 0)) {
      buffer.write(',');
    }
  }
  buffer.write(parts.fraction);
  return buffer.toString();
}

/// 7999 → "$7,999"
String formatCurrency(num value, {String symbol = '\$'}) =>
    '$symbol${formatPrice(value)}';

/// API amount bina rounding ke: 12 → "12", 12.5 → "12.50", 18.468 → "18.468"
String formatExactAmount(num value) {
  final parts = _splitAmount(value);
  return '${parts.sign}${parts.integer}${parts.fraction}';
}

/// [formatExactAmount] + 3-digit grouping: 186628.8 → "186,628.80"
String formatGroupedAmount(num value) {
  final parts = _splitAmount(value);
  final grouped = parts.integer.replaceAllMapped(
    RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
    (m) => '${m[1]},',
  );
  return '${parts.sign}$grouped${parts.fraction}';
}

({String sign, String integer, String fraction}) _splitAmount(num value) {
  final fixed = value.abs().toStringAsFixed(8);
  final dot = fixed.indexOf('.');
  var fraction = fixed.substring(dot + 1).replaceAll(RegExp(r'0+$'), '');
  if (fraction.isNotEmpty && fraction.length < 2) fraction = fraction.padRight(2, '0');
  final integer = fixed.substring(0, dot);
  final isZero = integer == '0' && fraction.isEmpty;
  return (
    sign: value < 0 && !isZero ? '-' : '',
    integer: integer,
    fraction: fraction.isEmpty ? '' : '.$fraction',
  );
}
