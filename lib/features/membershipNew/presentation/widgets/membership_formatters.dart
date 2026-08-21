const List<String> _months = [
  'Jan',
  'Feb',
  'Mar',
  'Apr',
  'May',
  'Jun',
  'Jul',
  'Aug',
  'Sep',
  'Oct',
  'Nov',
  'Dec',
];

/// 15 Aug 2027
String formatMembershipDate(DateTime? date) {
  if (date == null) return '--';
  final day = date.day.toString().padLeft(2, '0');
  return '$day ${_months[date.month - 1]} ${date.year}';
}

/// Aug 2027
String formatMembershipMonth(DateTime? date) {
  if (date == null) return '--';
  return '${_months[date.month - 1]} ${date.year}';
}

/// 128 days left / Expires today
String formatDaysLeft(int days) {
  if (days <= 0) return 'Expires today';
  if (days == 1) return '1 day left';
  return '$days days left';
}