import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../theme/theme_colors.dart';

class AppTextField extends StatelessWidget {
  final String label;
  final String? hint;
  final TextEditingController? controller;
  final bool obscureText;
  final TextInputType keyboardType;
  final String? Function(String?)? validator;
  final void Function(String)? onChanged;
  final Widget? suffixIcon;
  final Widget? prefixIcon;
  final bool enabled;
  final int? maxLines;
  final List<TextInputFormatter>? inputFormatters;
  final InputDecoration? decoration;
  final TextStyle? style;
  final TextAlign textAlign;
  final Color? cursorColor;
  final AutovalidateMode? autovalidateMode;
  final bool? isRequired;
  /// Country Picker Widget
  final Widget? prefix;

  const AppTextField({
    super.key,
    required this.label,
    this.hint,
    this.controller,
    this.obscureText = false,
    this.keyboardType = TextInputType.text,
    this.validator,
    this.onChanged,
    this.suffixIcon,
    this.prefixIcon,
    this.enabled = true,
    this.maxLines,
    this.inputFormatters,
    this.decoration,
    this.style,
    this.textAlign = TextAlign.start,
    this.cursorColor,
    this.autovalidateMode,
    this.isRequired,
    this.prefix,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (label.isNotEmpty) ...[
          Text.rich(
            TextSpan(
              text: label,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: ThemeColors.inkMid,
              ),
              children: isRequired == true
                  ? const [
                      TextSpan(
                        text: ' *',
                        style: TextStyle(color: Colors.red),
                      ),
                    ]
                  : null,
            ),
          ),
          const SizedBox(height: 6),
        ],
        TextFormField(
          controller: controller,
          obscureText: obscureText,
          keyboardType: keyboardType,
          validator: validator,
          onChanged: onChanged,
          enabled: enabled,
          inputFormatters: inputFormatters,
          maxLines: obscureText ? 1 : maxLines,
          decoration: InputDecoration(
            hintText: hint,
            suffixIcon: suffixIcon,
            prefixIcon: prefixIcon,
          ),
        ),
      ],
    );
  }
}
