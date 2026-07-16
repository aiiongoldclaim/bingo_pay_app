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

  /// Free-text business/shop name: any character, just length-capped.
  static List<TextInputFormatter> text(int maxLength) => [
        LengthLimitingTextInputFormatter(maxLength),
      ];
}
