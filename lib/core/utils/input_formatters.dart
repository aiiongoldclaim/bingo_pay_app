import 'package:flutter/services.dart';

/// Reusable [TextInputFormatter] sets that block disallowed characters at
/// type-time, so the user physically cannot enter an invalid character into a
/// field (validation messages are the second line of defence).
class AppInputFormatters {
  AppInputFormatters._();

  /// Uppercases every character as it is typed.
  static final _upperCase = TextInputFormatter.withFunction(
    (oldValue, newValue) =>
        newValue.copyWith(text: newValue.text.toUpperCase()),
  );

  /// Names: letters, spaces, apostrophe, hyphen and dot only. Blocks digits
  /// and symbols. Capped at 50 characters.
  static List<TextInputFormatter> name() => [
        FilteringTextInputFormatter.allow(RegExp(r"[a-zA-Z .'-]")),
        LengthLimitingTextInputFormatter(50),
      ];

  /// Email: everything except whitespace. Capped at 100 characters.
  static List<TextInputFormatter> email() => [
        FilteringTextInputFormatter.deny(RegExp(r'\s')),
        LengthLimitingTextInputFormatter(100),
      ];

  /// Digits only, length-limited (phone numbers, OTPs, etc.).
  static List<TextInputFormatter> digits(int maxLength) => [
        FilteringTextInputFormatter.digitsOnly,
        LengthLimitingTextInputFormatter(maxLength),
      ];

  /// GST number: 15-char uppercase alphanumeric.
  static List<TextInputFormatter> gst() => [
        FilteringTextInputFormatter.allow(RegExp(r'[0-9A-Za-z]')),
        LengthLimitingTextInputFormatter(15),
        _upperCase,
      ];

  /// PAN number: 10-char uppercase alphanumeric.
  static List<TextInputFormatter> pan() => [
        FilteringTextInputFormatter.allow(RegExp(r'[0-9A-Za-z]')),
        LengthLimitingTextInputFormatter(10),
        _upperCase,
      ];

  /// Free-text field with no character restriction, just length-capped.
  /// Prefer [businessName] for shop/business name fields instead — this is
  /// for genuinely free-form text (e.g. a description).
  static List<TextInputFormatter> text(int maxLength) => [
        LengthLimitingTextInputFormatter(maxLength),
      ];

  /// Shop/business name: letters (incl. accented), digits, spaces, and the
  /// punctuation real business names actually use — apostrophe, hyphen,
  /// period, ampersand, comma (e.g. "7-Eleven", "M&S", "O'Brien's Store").
  /// Blocks everything else, including symbols with no place in a name.
  static List<TextInputFormatter> businessName(int maxLength) => [
        FilteringTextInputFormatter.allow(RegExp(r"[\p{L}\p{N} .,'&-]", unicode: true)),
        LengthLimitingTextInputFormatter(maxLength),
      ];

  /// Country picker search: letters (incl. accented, e.g. "São Tomé"),
  /// digits and "+" (dial code search, e.g. "+91"), spaces, hyphen and
  /// parentheses (e.g. "Congo (DR)", "Guinea-Bissau"). Blocks everything
  /// else, since it can never match a country name/code/dial code.
  static List<TextInputFormatter> countrySearch() => [
        FilteringTextInputFormatter.allow(RegExp(r'[\p{L}\p{N} +()-]', unicode: true)),
        LengthLimitingTextInputFormatter(50),
      ];
}
