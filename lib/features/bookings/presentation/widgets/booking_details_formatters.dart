import 'package:intl/intl.dart';

DateTime? parseApiDate(String? value) {
  if (value == null || value.trim().isEmpty) {
    return null;
  }

  try {
    return DateTime.parse(value).toLocal();
  } catch (_) {
    return null;
  }
}

String formatTimelineDate(String value) {
  final date = parseApiDate(value);

  if (date == null) {
    return value.isNotEmpty ? value : '-';
  }

  return DateFormat(
    'dd MMM yyyy • hh:mm a',
  ).format(date);
}

String formatBookingStatus(String value) {
  if (value.trim().isEmpty) {
    return '-';
  }

  return value
      .replaceAll('_', ' ')
      .split(' ')
      .where((word) => word.isNotEmpty)
      .map(
        (word) =>
            '${word[0].toUpperCase()}${word.substring(1).toLowerCase()}',
      )
      .join(' ');
}

String capitalizeBookingWords(String value) {
  return value
      .split(' ')
      .where((word) => word.isNotEmpty)
      .map(
        (word) =>
            '${word[0].toUpperCase()}${word.substring(1).toLowerCase()}',
      )
      .join(' ');
}

String formatBookingPhone(String phone) {
  if (phone.isEmpty) {
    return '-';
  }

  if (phone.startsWith('+')) {
    return phone;
  }

  return '+91 $phone';
}

String formatBookingPrice(
  String value,
  String currency,
) {
  final amount = double.tryParse(value);

  if (amount == null) {
    return value.isEmpty ? '-' : value;
  }

  final formatted = NumberFormat(
    '#,##0.##',
  ).format(amount);

  switch (currency.toUpperCase()) {
    case 'INR':
      return '₹$formatted';

    case 'USD':
      return '\$$formatted';

    case 'EUR':
      return '€$formatted';

    case 'GBP':
      return '£$formatted';

    default:
      return '$currency $formatted';
  }
}
