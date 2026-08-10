import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme/theme_colors.dart';
//
// class AppTextField extends StatelessWidget {
//   final String label;
//   final String? hint;
//   final TextEditingController? controller;
//   final FocusNode? focusNode;
//   final bool obscureText;
//   final TextInputType keyboardType;
//   final String? Function(String?)? validator;
//   final void Function(String)? onChanged;
//   final Widget? suffixIcon;
//   final Widget? prefixIcon;
//   final bool enabled;
//   final int? maxLines;
//   final List<TextInputFormatter>? inputFormatters;
//   final InputDecoration? decoration;
//   final TextStyle? style;
//   final TextAlign textAlign;
//   final Color? cursorColor;
//   final AutovalidateMode? autovalidateMode;
//   final bool? isRequired;
//   /// Country Picker Widget
//   final Widget? prefix;
//
//   const AppTextField({
//     super.key,
//     required this.label,
//     this.hint,
//     this.controller,
//     this.focusNode,
//     this.obscureText = false,
//     this.keyboardType = TextInputType.text,
//     this.validator,
//     this.onChanged,
//     this.suffixIcon,
//     this.prefixIcon,
//     this.enabled = true,
//     this.maxLines,
//     this.inputFormatters,
//     this.decoration,
//     this.style,
//     this.textAlign = TextAlign.start,
//     this.cursorColor,
//     this.autovalidateMode,
//     this.isRequired,
//     this.prefix,
//   });
//
//   @override
//   Widget build(BuildContext context) {
//     return Column(
//       mainAxisSize: MainAxisSize.min,
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         if (label.isNotEmpty) ...[
//           Text.rich(
//             TextSpan(
//               text: label,
//               style: const TextStyle(
//                 fontSize: 13,
//                 fontWeight: FontWeight.w500,
//                 color: ThemeColors.inkMid,
//               ),
//               children: isRequired == true
//                   ? const [
//                       TextSpan(
//                         text: ' *',
//                         style: TextStyle(color: Colors.red),
//                       ),
//                     ]
//                   : null,
//             ),
//           ),
//           const SizedBox(height: 6),
//         ],
//         TextFormField(
//           controller: controller,
//           focusNode: focusNode,
//           obscureText: obscureText,
//           keyboardType: keyboardType,
//           validator: validator,
//           onChanged: onChanged,
//           enabled: enabled,
//           inputFormatters: inputFormatters,
//           maxLines: obscureText ? 1 : maxLines,
//           decoration: InputDecoration(
//             hintText: hint,
//             hintStyle:  TextStyle(
//               fontSize: 14.sp,
//               color: ThemeColors.inkMid,
//             ),
//             suffixIcon: suffixIcon,
//             prefixIcon: prefixIcon,
//           ),
//         ),
//       ],
//     );
//   }
// }

import '../utils/responsive_utils.dart';

class AppTextField extends StatelessWidget {
  final String label;
  final String? hint;
  final TextEditingController? controller;
  final FocusNode? focusNode;
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

  /// Optional size overrides (tablet screens se pass kar sakti ho)
  final double? labelFontSize;
  final double? hintFontSize;
  final double? fieldHeight;

  const AppTextField({
    super.key,
    required this.label,
    this.hint,
    this.controller,
    this.focusNode,
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
    this.labelFontSize,
    this.hintFontSize,
    this.fieldHeight,
  });

  @override
  Widget build(BuildContext context) {
    final m = _FieldMetrics.get();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final labelSize = labelFontSize ?? m.labelFont;
    final hintSize = hintFontSize ?? m.hintFont;
    final height = fieldHeight ?? m.height;

    // ── design ke colors ──
    final fill = isDark
        ? ThemeColors.white.withValues(alpha: 0.04)
        : ThemeColors.surface;

    final border = isDark
        ? ThemeColors.white.withValues(alpha: 0.12)
        : ThemeColors.line;

    final labelColor = isDark ? ThemeColors.white : ThemeColors.ink;
    final hintColor = isDark ? ThemeColors.inkDim : ThemeColors.textGrey;
    final iconColor = isDark ? ThemeColors.inkDim : ThemeColors.textSecondary;

    OutlineInputBorder _b(Color c, [double w = 1]) => OutlineInputBorder(
      borderRadius: BorderRadius.circular(m.radius),
      borderSide: BorderSide(color: c, width: w),
    );

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (label.isNotEmpty) ...[
          Text.rich(
            TextSpan(
              text: label,
              style: TextStyle(
                fontFamily: 'Roboto',
                fontSize: labelSize,
                fontWeight: FontWeight.w600,
                color: labelColor,
              ),
              children: isRequired == true
                  ? [
                      TextSpan(
                        text: ' *',
                        style: TextStyle(
                          fontSize: labelSize,
                          color: ThemeColors.red,
                        ),
                      ),
                    ]
                  : null,
            ),
          ),
          SizedBox(height: m.labelGap),
        ],
        TextFormField(
          controller: controller,
          focusNode: focusNode,
          obscureText: obscureText,
          keyboardType: keyboardType,
          validator: validator,
          onChanged: onChanged,
          enabled: enabled,
          inputFormatters: inputFormatters,
          maxLines: obscureText ? 1 : maxLines,
          textAlign: textAlign,
          autovalidateMode: autovalidateMode,
          cursorColor: cursorColor ?? ThemeColors.blue,
          style:
              style ??
              TextStyle(
                fontFamily: 'Roboto',
                fontSize: hintSize,
                fontWeight: FontWeight.w400,
                color: isDark ? ThemeColors.white : ThemeColors.ink,
              ),
          decoration:
              decoration ??
              InputDecoration(
                hintText: hint,
                hintStyle: TextStyle(
                  fontFamily: 'Roboto',
                  fontSize: hintSize,
                  fontWeight: FontWeight.w400,
                  color: hintColor,
                ),
                filled: true,
                fillColor: enabled
                    ? fill
                    : (isDark
                          ? ThemeColors.white.withValues(alpha: 0.02)
                          : ThemeColors.surface2),

                // height control — isi se field design jitni tall hoti hai
                constraints: BoxConstraints(minHeight: height),
                contentPadding: EdgeInsets.symmetric(
                  horizontal: m.hPad,
                  vertical: m.vPad,
                ),
                isDense: false,

                prefixIcon: prefixIcon == null
                    ? prefix
                    : Padding(
                        padding: EdgeInsets.only(
                          left: m.hPad,
                          right: m.hPad * 0.6,
                        ),
                        child: IconTheme(
                          data: IconThemeData(
                            color: iconColor,
                            size: m.iconSize,
                          ),
                          child: prefixIcon!,
                        ),
                      ),
                prefixIconConstraints: BoxConstraints(
                  minWidth: 0,
                  minHeight: height,
                ),

                suffixIcon: suffixIcon == null
                    ? null
                    : Padding(
                        padding: EdgeInsets.only(right: m.hPad * 0.5),
                        child: IconButtonTheme(
                          data: IconButtonThemeData(
                            style: IconButton.styleFrom(
                              foregroundColor: iconColor,
                              iconSize: m.iconSize,
                            ),
                          ),
                          child: IconTheme(
                            data: IconThemeData(
                              color: iconColor,
                              size: m.iconSize,
                            ),
                            child: suffixIcon!,
                          ),
                        ),
                      ),
                suffixIconConstraints: BoxConstraints(
                  minWidth: 0,
                  minHeight: height,
                ),

                border: _b(border),
                enabledBorder: _b(border),
                disabledBorder: _b(border),
                focusedBorder: _b(ThemeColors.blue, 1.6),
                errorBorder: _b(ThemeColors.red),
                focusedErrorBorder: _b(ThemeColors.red, 1.6),

                errorStyle: TextStyle(
                  fontFamily: 'Roboto',
                  fontSize: m.errorFont,
                  color: ThemeColors.red,
                ),
              ),
        ),
      ],
    );
  }
}

class _FieldMetrics {
  const _FieldMetrics({
    required this.labelFont,
    required this.hintFont,
    required this.height,
    required this.hPad,
    required this.vPad,
    required this.labelGap,
    required this.iconSize,
    required this.radius,
    required this.errorFont,
  });

  final double labelFont;
  final double hintFont;
  final double height;
  final double hPad;
  final double vPad;
  final double labelGap;
  final double iconSize;
  final double radius;
  final double errorFont;

  factory _FieldMetrics.get() {
    if (ResponsiveUtils.isTabletLandscape) {
      return const _FieldMetrics(
        labelFont: 15,
        hintFont: 15,
        height: 56,
        hPad: 14,
        vPad: 16,
        labelGap: 8,
        iconSize: 21,
        radius: 12,
        errorFont: 12,
      );
    }

    if (ResponsiveUtils.isTabletPortrait) {
      return const _FieldMetrics(
        labelFont: 16,
        hintFont: 16,
        height: 60,
        hPad: 16,
        vPad: 18,
        labelGap: 9,
        iconSize: 23,
        radius: 14,
        errorFont: 13,
      );
    }

    // phone
    return const _FieldMetrics(
      labelFont: 15,
      hintFont: 15,
      height: 56,
      hPad: 14,
      vPad: 16,
      labelGap: 8,
      iconSize: 21,
      radius: 14,
      errorFont: 12,
    );
  }
}
