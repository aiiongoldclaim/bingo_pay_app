// What a KYC document's number must look like: the web's
// components/tvs-wallet/kycNumber.js (same rules as the backend's
// tvs-kyc-number.rules.ts, which is the authority). This copy only lets the
// user see a problem while typing.
//
// A rule is a document's `number` from GET /tvs-wallet/kyc/requirements. The
// server sends it with any preset already spelled out, so the preset table and
// `effectiveRule` are not needed here.

final _digits = RegExp(r'^[0-9]+$');

/// Spaces and hyphens are how people type numbers; they are not part of one.
String normaliseNumber(String? raw) =>
    (raw ?? '').replaceAll(RegExp(r'[\s-]'), '').toUpperCase();

/// A mask as a regular expression: A letter, 9 digit, * either.
String maskToPattern(String mask) =>
    '^${mask.split('').map((ch) => switch (ch) {
      'A' => '[A-Z]',
      '9' => '[0-9]',
      '*' => '[A-Z0-9]',
      _ => RegExp.escape(ch),
    }).join()}\$';

/// Why a number is refused, or null when it passes. [others] holds the other
/// documents' normalised numbers by code, for "must match".
String? numberProblem(
  Map<dynamic, dynamic>? rule,
  String? raw,
  String label, [
  Map<String, String> others = const {},
  Map<String, String> labels = const {},
]) {
  final value = normaliseNumber(raw);
  final r = rule ?? const {};
  String? text(String key) => switch (r[key]) {
    final String s when s.isNotEmpty => s,
    _ => null,
  };
  int? whole(String key) => (r[key] as num?)?.toInt();
  final message = text('message')?.trim() ?? '';
  String refuse(String reason) => message.isEmpty ? reason : message;

  // The general check every number passes: it is also what the server hashes.
  if (value.length < 4 ||
      value.length > 32 ||
      !RegExp(r'^[A-Z0-9]+$').hasMatch(value)) {
    return refuse('Enter a valid $label number');
  }
  if (r['chars'] == 'DIGITS' && !_digits.hasMatch(value)) {
    return refuse('The $label number has digits only');
  }
  if (r['chars'] == 'LETTERS' && !RegExp(r'^[A-Z]+$').hasMatch(value)) {
    return refuse('The $label number has letters only');
  }

  final mask = text('mask');
  final min = whole('minLength') ?? mask?.length;
  final max = whole('maxLength') ?? mask?.length;
  if (min != null && min == max) {
    if (value.length != min) {
      return refuse('The $label number has $min characters');
    }
  } else {
    if (min != null && value.length < min) {
      return refuse('The $label number has at least $min characters');
    }
    if (max != null && value.length > max) {
      return refuse('The $label number has at most $max characters');
    }
  }

  if (mask != null && !RegExp(maskToPattern(mask)).hasMatch(value)) {
    return refuse('The $label number looks like $mask');
  }
  final pattern = text('pattern');
  if (pattern != null && !(_compile(pattern)?.hasMatch(value) ?? true)) {
    return refuse('That doesn’t look like a $label number');
  }
  final checksum = text('checksum');
  if (checksum != null && !(_checks[checksum]?.call(value) ?? false)) {
    return refuse('That $label number isn’t valid. Check each character');
  }

  if (r['matches'] case final Map m) {
    final code = '${m['code']}';
    final other = others[code] ?? '';
    if (other.isNotEmpty) {
      final from = (((m['start'] as num?)?.toInt() ?? 1) - 1).clamp(
        0,
        value.length,
      );
      final to = (from + ((m['length'] as num?)?.toInt() ?? 0)).clamp(
        from,
        value.length,
      );
      // Never the custom message: this is about two documents disagreeing.
      if (value.substring(from, to) != other) {
        return 'The $label number doesn’t match your ${labels[code] ?? code}';
      }
    }
  }
  return null;
}

// An admin's pattern that does not compile is skipped, as on the web.
RegExp? _compile(String pattern) {
  try {
    return RegExp(pattern);
  } on FormatException {
    return null;
  }
}

/* ------------------------------------------------------------ check digits */

const _checks = <String, bool Function(String)>{
  'VERHOEFF': _verhoeff,
  'LUHN': _luhn,
  'GSTIN': _gstin,
  'NRIC': _nric,
};

const _verhoeffD = [
  [0, 1, 2, 3, 4, 5, 6, 7, 8, 9],
  [1, 2, 3, 4, 0, 6, 7, 8, 9, 5],
  [2, 3, 4, 0, 1, 7, 8, 9, 5, 6],
  [3, 4, 0, 1, 2, 8, 9, 5, 6, 7],
  [4, 0, 1, 2, 3, 9, 5, 6, 7, 8],
  [5, 9, 8, 7, 6, 0, 4, 3, 2, 1],
  [6, 5, 9, 8, 7, 1, 0, 4, 3, 2],
  [7, 6, 5, 9, 8, 2, 1, 0, 4, 3],
  [8, 7, 6, 5, 9, 3, 2, 1, 0, 4],
  [9, 8, 7, 6, 5, 4, 3, 2, 1, 0],
];
const _verhoeffP = [
  [0, 1, 2, 3, 4, 5, 6, 7, 8, 9],
  [1, 5, 7, 6, 2, 8, 3, 0, 9, 4],
  [5, 8, 0, 3, 7, 9, 6, 1, 4, 2],
  [8, 9, 1, 6, 0, 4, 3, 5, 2, 7],
  [9, 4, 5, 3, 1, 2, 6, 8, 7, 0],
  [4, 2, 8, 6, 5, 7, 3, 9, 0, 1],
  [2, 7, 9, 3, 8, 0, 6, 4, 1, 5],
  [7, 0, 4, 6, 9, 1, 3, 2, 5, 8],
];

bool _verhoeff(String v) {
  if (!_digits.hasMatch(v)) return false;
  var c = 0;
  for (var i = 0; i < v.length; i++) {
    c = _verhoeffD[c][_verhoeffP[i % 8][int.parse(v[v.length - 1 - i])]];
  }
  return c == 0;
}

bool _luhn(String v) {
  if (!_digits.hasMatch(v)) return false;
  var sum = 0;
  for (var i = 0; i < v.length; i++) {
    var n = int.parse(v[v.length - 1 - i]);
    if (i.isOdd) {
      n *= 2;
      if (n > 9) n -= 9;
    }
    sum += n;
  }
  return sum % 10 == 0;
}

const _base36 = '0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ';

/// GSTIN: the 15th character is a mod-36 check over the first 14.
bool _gstin(String v) {
  if (!RegExp(r'^[0-9A-Z]{15}$').hasMatch(v)) return false;
  var sum = 0;
  for (var i = 0; i < 14; i++) {
    final product = _base36.indexOf(v[i]) * (i.isEven ? 1 : 2);
    sum += product ~/ 36 + product % 36;
  }
  return _base36[(36 - sum % 36) % 36] == v[14];
}

/// NRIC / FIN. The M series uses a different table, so only its shape is checked.
bool _nric(String v) {
  if (!RegExp(r'^[STFGM][0-9]{7}[A-Z]$').hasMatch(v)) return false;
  final series = v[0];
  if (series == 'M') return true;
  const weights = [2, 7, 6, 5, 4, 3, 2];
  var sum = 0;
  for (var i = 0; i < 7; i++) {
    sum += weights[i] * int.parse(v[i + 1]);
  }
  if (series == 'T' || series == 'G') sum += 4;
  final table = series == 'S' || series == 'T' ? 'JZIHGFEDCBA' : 'XWUTRQPNMLK';
  return table[sum % 11] == v[8];
}
