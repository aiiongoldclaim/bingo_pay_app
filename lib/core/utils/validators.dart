class Validators {
  static String? email(String? value) {
    if (value == null || value.trim().isEmpty) return 'Email is required';
    final emailRegex = RegExp(r'^[\w.-]+@[\w.-]+\.\w{2,}$');
    if (!emailRegex.hasMatch(value.trim())) {
      return 'Please enter a valid email address';
    }
    return null;
  }

  /// Optional email field (e.g. support email): valid only if non-empty.
  static String? optionalEmail(String? value) {
    if (value == null || value.trim().isEmpty) return null;
    return email(value);
  }

  static String? password(String? value) {
    if (value == null || value.isEmpty) return 'Password is required';
    if (value.length < 8) return 'Password must be at least 8 characters';
    if (!RegExp(r'[A-Z]').hasMatch(value)) {
      return 'Password must contain an uppercase letter';
    }
    if (!RegExp(r'[a-z]').hasMatch(value)) {
      return 'Password must contain a lowercase letter';
    }
    if (!RegExp(r'[0-9]').hasMatch(value)) {
      return 'Password must contain a number';
    }
    if (!RegExp(r'[^A-Za-z0-9]').hasMatch(value)) {
      return 'Password must contain a special character';
    }
    return null;
  }

  /// Lenient check for login — existing accounts may predate the
  /// complexity rules enforced at registration.
  static String? loginPassword(String? value) {
    if (value == null || value.isEmpty) return 'Password is required';
    return null;
  }

  static String? confirmPassword(String? value, String original) {
    if (value == null || value.isEmpty) return 'Please confirm your password';
    if (value != original) return 'Passwords do not match';
    return null;
  }

  static String? required(String? value, {String fieldName = 'This field'}) {
    if (value == null || value.trim().isEmpty) return '$fieldName is required';
    return null;
  }

  static String? name(String? value, {String fieldName = 'name'}) {
    final v = value?.trim() ?? '';
    if (v.isEmpty) return '${_capitalize(fieldName)} is required';
    if (v.length < 3) return '${_capitalize(fieldName)} must be at least 3 characters';
    // Letters, spaces, apostrophe, hyphen and dot only.
    if (!RegExp(r"^[a-zA-Z][a-zA-Z .'-]*$").hasMatch(v)) {
      return 'Please enter a valid $fieldName';
    }
    return null;
  }

  static String? phone(String? value, {int? minLength, int? maxLength}) {
    final v = value?.trim() ?? '';
    if (v.isEmpty) return 'Phone number is required';
    if (!RegExp(r'^\d+$').hasMatch(v)) {
      return 'Please enter a valid phone number';
    }
    final min = minLength ?? 10;
    final max = maxLength ?? 10;
    if (v.length < min || v.length > max) {
      final range = min == max ? '$min' : '$min–$max';
      return 'Enter a valid $range-digit phone number';
    }
    return null;
  }

  /// Optional phone (e.g. support phone): valid only if non-empty.
  static String? optionalPhone(String? value, {int? minLength, int? maxLength}) {
    if (value == null || value.trim().isEmpty) return null;
    return phone(value, minLength: minLength, maxLength: maxLength);
  }

  static String _capitalize(String s) =>
      s.isEmpty ? s : '${s[0].toUpperCase()}${s.substring(1)}';

  static String? gst(String? value) {
    if (value == null || value.trim().isEmpty) return null;
    final gstRegex =
        RegExp(r'^[0-9]{2}[A-Z]{5}[0-9]{4}[A-Z]{1}[1-9A-Z]{1}Z[0-9A-Z]{1}$');
    if (!gstRegex.hasMatch(value.trim().toUpperCase())) {
      return 'Please enter a valid GST number';
    }
    return null;
  }

  static String? pan(String? value) {
    if (value == null || value.trim().isEmpty) return null;
    final panRegex = RegExp(r'^[A-Z]{5}[0-9]{4}[A-Z]{1}$');
    if (!panRegex.hasMatch(value.trim().toUpperCase())) {
      return 'Please enter a valid PAN number';
    }
    return null;
  }
}