import 'package:intl/intl.dart';

// Display only: amounts arrive as 2-decimal strings and are never added up
// here, just grouped and given their currency symbol.
const _symbols = {
  'INR': '₹',
  'USD': r'$',
  'SGD': r'S$',
  'EUR': '€',
  'GBP': '£',
  'AED': 'AED ',
};

String tvsCoins(Object? amount, [Object? currency]) {
  final n = num.tryParse('${amount ?? ''}');
  if (n == null) return '—';
  final text = NumberFormat('#,##0.00').format(n);
  final cur = '${currency ?? ''}';
  return cur.isEmpty ? text : '${_symbols[cur] ?? '$cur '}$text';
}

DateTime? _parse(Object? iso) => DateTime.tryParse('${iso ?? ''}')?.toLocal();

String tvsDate(Object? iso) {
  final d = _parse(iso);
  return d == null ? '—' : DateFormat('d MMM y').format(d);
}

String tvsTime(Object? iso) {
  final d = _parse(iso);
  return d == null ? '' : DateFormat('h:mm a').format(d);
}

// A heading for a day's activity: "Today", "Yesterday", "17 Oct".
String tvsDay(Object? iso, [DateTime? now]) {
  final d = _parse(iso);
  if (d == null) return 'Earlier';
  final n = now ?? DateTime.now();
  // Calendar days, counted in UTC so a daylight-saving change can't shift them.
  final days = DateTime.utc(
    n.year,
    n.month,
    n.day,
  ).difference(DateTime.utc(d.year, d.month, d.day)).inDays;
  if (days == 0) return 'Today';
  if (days == 1) return 'Yesterday';
  return DateFormat(d.year == n.year ? 'd MMM' : 'd MMM y').format(d);
}

// "PENDING_APPROVAL" → "Pending approval".
String tvsHuman(Object? value) {
  final text = '${value ?? ''}'.replaceAll('_', ' ').trim().toLowerCase();
  return text.isEmpty ? '—' : text[0].toUpperCase() + text.substring(1);
}
