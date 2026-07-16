import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class AppTextField extends StatelessWidget {
  final String label;
  final String? hint;
  final TextEditingController? controller;
  final FocusNode? focusNode;
  final FocusNode? nextFocusNode;
  final bool obscureText;
  final TextInputType keyboardType;
  final TextInputAction? textInputAction;
  final String? Function(String?)? validator;
  final void Function(String)? onChanged;
  final VoidCallback? onSubmitted;
  final Widget? suffixIcon;
  final Widget? prefixIcon;
  final bool enabled;
  final int? maxLines;
  final List<TextInputFormatter>? inputFormatters;
  final bool isRequired;
  final TextCapitalization textCapitalization;

  /// Defaults to [AutovalidateMode.onUserInteraction] so a field validates
  /// itself only after the user has interacted with it — the error shows on
  /// the field currently being edited, not on every field at once.
  final AutovalidateMode autovalidateMode;

  const AppTextField({
    super.key,
    required this.label,
    this.hint,
    this.controller,
    this.focusNode,
    this.nextFocusNode,
    this.obscureText = false,
    this.keyboardType = TextInputType.text,
    this.textInputAction,
    this.validator,
    this.onChanged,
    this.onSubmitted,
    this.suffixIcon,
    this.prefixIcon,
    this.enabled = true,
    this.maxLines,
    this.inputFormatters,
    this.isRequired = false,
    this.textCapitalization = TextCapitalization.none,
    this.autovalidateMode = AutovalidateMode.onUserInteraction,
  });

  bool get _isMultiline => maxLines != null && maxLines! > 1;

  TextInputAction get _resolvedAction {
    if (textInputAction != null) return textInputAction!;
    if (_isMultiline) return TextInputAction.newline;
    if (nextFocusNode != null) return TextInputAction.next;
    return TextInputAction.done;
  }

  TextInputType get _resolvedKeyboardType {
    if (_isMultiline && keyboardType == TextInputType.text) {
      return TextInputType.multiline;
    }
    return keyboardType;
  }

  void _handleSubmitted(BuildContext context, String _) {
    if (nextFocusNode != null) {
      nextFocusNode!.requestFocus();
    }
    onSubmitted?.call();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text.rich(
          TextSpan(
            text: label,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: theme.textTheme.bodyMedium?.color,
            ),
            children: [
              if (isRequired)
                TextSpan(
                  text: ' *',
                  style: TextStyle(color: theme.colorScheme.error),
                ),
            ],
          ),
        ),
        const SizedBox(height: 6),
        TextFormField(
          controller: controller,
          focusNode: focusNode,
          obscureText: obscureText,
          keyboardType: _resolvedKeyboardType,
          textInputAction: _resolvedAction,
          textCapitalization: textCapitalization,
          autovalidateMode: autovalidateMode,
          validator: validator,
          onChanged: onChanged,
          onFieldSubmitted: (v) => _handleSubmitted(context, v),
          enabled: enabled,
          maxLines: obscureText ? 1 : maxLines,
          inputFormatters: inputFormatters,
          decoration: InputDecoration(
            hintText: hint ?? label,
            suffixIcon: suffixIcon,
            prefixIcon: prefixIcon,
          ),
        ),
      ],
    );
  }
}
