// import 'package:flutter/material.dart';
// import '../theme/theme_colors.dart';
// import '../utils/responsive_utils.dart';
//
// enum AppButtonVariant { primary, secondary, outlined }
//
// class AppButton extends StatelessWidget {
//   final String label;
//   final VoidCallback? onPressed;
//   final bool isLoading;
//   final AppButtonVariant variant;
//   final IconData? prefixIcon;
//   final Color? textColor;
//   final Color? iconColor;
//
//   /// Optional overrides — screen ke Metrics se pass kar sakti ho
//   final double? height;
//   final double? fontSize;
//
//   const AppButton({
//     super.key,
//     required this.label,
//     this.onPressed,
//     this.isLoading = false,
//     this.variant = AppButtonVariant.primary,
//     this.prefixIcon,
//     this.textColor,
//     this.iconColor,
//     this.height,
//     this.fontSize,
//   });
//
//   @override
//   Widget build(BuildContext context) {
//     final m = _ButtonMetrics.get();
//     final isDark = Theme.of(context).brightness == Brightness.dark;
//
//     final h = height ?? m.height;
//     final fs = fontSize ?? m.fontSize;
//
//     final shape = RoundedRectangleBorder(
//       borderRadius: BorderRadius.circular(m.radius),
//     );
//
//     // ------------------------------------------------------------
//     // LOADING
//     // ------------------------------------------------------------
//     if (isLoading) {
//       return SizedBox(
//         width: double.infinity,
//         height: h,
//         child: Container(
//           decoration: BoxDecoration(
//             gradient: ThemeColors.primaryButtonGradient,
//             borderRadius: BorderRadius.circular(m.radius),
//           ),
//           child: ElevatedButton(
//             onPressed: null,
//             style: ElevatedButton.styleFrom(
//               backgroundColor: Colors.transparent,
//               disabledBackgroundColor: Colors.transparent,
//               shadowColor: Colors.transparent,
//               surfaceTintColor: Colors.transparent,
//               elevation: 0,
//               shape: shape,
//             ),
//             child: Center(
//               child: SizedBox(
//                 width: m.loaderSize,
//                 height: m.loaderSize,
//                 child: CircularProgressIndicator(
//                   strokeWidth: m.loaderStroke,
//                   valueColor: const AlwaysStoppedAnimation(
//                     ThemeColors.white,
//                   ),
//                 ),
//               ),
//             ),
//           ),
//         ),
//       );
//     }
//
//     final isDisabled = onPressed == null;
//
//     // ------------------------------------------------------------
//     // COLORS
//     // ------------------------------------------------------------
//
//     final effectiveTextColor = isDisabled
//         ? ThemeColors.inkDim
//         : (textColor ?? _textColor(isDark));
//
//     final effectiveIconColor = isDisabled
//         ? ThemeColors.inkDim
//         : (iconColor ?? _textColor(isDark));
//
//     final disabledFill = isDark
//         ? ThemeColors.white.withValues(alpha: 0.10)
//         : ThemeColors.line;
//
//     // ------------------------------------------------------------
//     // BUTTON CONTENT
//     // ------------------------------------------------------------
//
//     Widget child = Row(
//       mainAxisAlignment: MainAxisAlignment.center,
//       mainAxisSize: MainAxisSize.min,
//       children: [
//         if (prefixIcon != null) ...[
//           Icon(
//             prefixIcon,
//             size: m.iconSize,
//             color: effectiveIconColor,
//           ),
//           SizedBox(width: m.iconGap),
//         ],
//         Flexible(
//           child: Text(
//             label,
//             style: TextStyle(
//               fontFamily: 'Inter',
//               fontSize: fs,
//               fontWeight: FontWeight.w600,
//               letterSpacing: 0.2,
//               color: effectiveTextColor,
//             ),
//             overflow: TextOverflow.ellipsis,
//           ),
//         ),
//       ],
//     );
//
//     // ============================================================
//     // PRIMARY
//     // ============================================================
//
//     switch (variant) {
//       case AppButtonVariant.primary:
//         return SizedBox(
//           width: double.infinity,
//           height: h,
//           child: Container(
//             decoration: BoxDecoration(
//               gradient: isDisabled
//                   ? null
//                   : ThemeColors.primaryButtonGradient,
//               color: isDisabled ? disabledFill : null,
//               borderRadius: BorderRadius.circular(m.radius),
//               boxShadow: isDisabled
//                   ? null
//                   : [
//                 BoxShadow(
//                   color: ThemeColors.primaryPurple.withValues(
//                     alpha: 0.28,
//                   ),
//                   blurRadius: m.shadowBlur,
//                   offset: Offset(0, m.shadowOffset),
//                 ),
//               ],
//             ),
//             child: ElevatedButton(
//               onPressed: onPressed,
//               style: ElevatedButton.styleFrom(
//                 backgroundColor: Colors.transparent,
//                 disabledBackgroundColor: Colors.transparent,
//                 shadowColor: Colors.transparent,
//                 surfaceTintColor: Colors.transparent,
//                 elevation: 0,
//                 padding: EdgeInsets.symmetric(
//                   horizontal: m.hPad,
//                 ),
//                 shape: shape,
//               ),
//               child: child,
//             ),
//           ),
//         );
//
//     // ============================================================
//     // SECONDARY
//     // ============================================================
//
//       case AppButtonVariant.secondary:
//         return SizedBox(
//           width: double.infinity,
//           height: h,
//           child: Container(
//             decoration: BoxDecoration(
//               gradient: isDisabled
//                   ? null
//                   : ThemeColors.secondaryButtonGradient,
//               color: isDisabled ? disabledFill : null,
//               borderRadius: BorderRadius.circular(m.radius),
//             ),
//             child: FilledButton(
//               onPressed: onPressed,
//               style: FilledButton.styleFrom(
//                 backgroundColor: Colors.transparent,
//                 disabledBackgroundColor: Colors.transparent,
//                 foregroundColor: effectiveTextColor,
//                 elevation: 0,
//                 padding: EdgeInsets.symmetric(
//                   horizontal: m.hPad,
//                 ),
//                 shape: shape,
//               ),
//               child: child,
//             ),
//           ),
//         );
//
//     // ============================================================
//     // OUTLINED
//     // ============================================================
//
//       case AppButtonVariant.outlined:
//         return SizedBox(
//           width: double.infinity,
//           height: h,
//           child: OutlinedButton(
//             onPressed: onPressed,
//             style: OutlinedButton.styleFrom(
//               backgroundColor: isDisabled
//                   ? disabledFill
//                   : ThemeColors.primaryPurple.withValues(
//                 alpha: 0.04,
//               ),
//               foregroundColor: effectiveTextColor,
//               side: BorderSide(
//                 color: isDisabled
//                     ? ThemeColors.line
//                     : ThemeColors.primaryPurple,
//                 width: m.borderWidth,
//               ),
//               padding: EdgeInsets.symmetric(
//                 horizontal: m.hPad,
//               ),
//               shape: shape,
//             ),
//             child: child,
//           ),
//         );
//     }
//   }
//
//   // ==============================================================
//   // TEXT COLOR
//   // ==============================================================
//
//   Color _textColor(bool isDark) {
//     switch (variant) {
//       case AppButtonVariant.primary:
//         return ThemeColors.white;
//
//       case AppButtonVariant.secondary:
//         return isDark
//             ? ThemeColors.white
//             : ThemeColors.primaryPurple;
//
//       case AppButtonVariant.outlined:
//         return isDark
//             ? ThemeColors.mediumPurple
//             : ThemeColors.primaryPurple;
//     }
//   }
// }
//
// // ==================================================================
// // BUTTON METRICS
// // ==================================================================
//
// class _ButtonMetrics {
//   const _ButtonMetrics({
//     required this.height,
//     required this.fontSize,
//     required this.iconSize,
//     required this.iconGap,
//     required this.radius,
//     required this.hPad,
//     required this.borderWidth,
//     required this.loaderSize,
//     required this.loaderStroke,
//     required this.shadowBlur,
//     required this.shadowOffset,
//   });
//
//   final double height;
//   final double fontSize;
//   final double iconSize;
//   final double iconGap;
//   final double radius;
//   final double hPad;
//   final double borderWidth;
//   final double loaderSize;
//   final double loaderStroke;
//   final double shadowBlur;
//   final double shadowOffset;
//
//   factory _ButtonMetrics.get() {
//     if (ResponsiveUtils.isTabletLandscape) {
//       return const _ButtonMetrics(
//         height: 54,
//         fontSize: 16,
//         iconSize: 19,
//         iconGap: 9,
//         radius: 12,
//         hPad: 20,
//         borderWidth: 1.4,
//         loaderSize: 22,
//         loaderStroke: 2.4,
//         shadowBlur: 16,
//         shadowOffset: 6,
//       );
//     }
//
//     if (ResponsiveUtils.isTabletPortrait) {
//       return const _ButtonMetrics(
//         height: 58,
//         fontSize: 17,
//         iconSize: 21,
//         iconGap: 10,
//         radius: 14,
//         hPad: 22,
//         borderWidth: 1.5,
//         loaderSize: 24,
//         loaderStroke: 2.6,
//         shadowBlur: 18,
//         shadowOffset: 7,
//       );
//     }
//
//     // Phone
//     return const _ButtonMetrics(
//       height: 54,
//       fontSize: 16,
//       iconSize: 18,
//       iconGap: 8,
//       radius: 14,
//       hPad: 18,
//       borderWidth: 1.4,
//       loaderSize: 22,
//       loaderStroke: 2.4,
//       shadowBlur: 16,
//       shadowOffset: 6,
//     );
//   }
// }
import 'package:flutter/material.dart';
import '../theme/app_theme_colors.dart';
import '../utils/responsive_utils.dart';

enum AppButtonVariant { primary, secondary, outlined }

class AppButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final bool isLoading;
  final AppButtonVariant variant;
  final IconData? prefixIcon;
  final Color? textColor;
  final Color? iconColor;

  /// Optional overrides — screen ke Metrics se pass kar sakti ho
  final double? height;
  final double? fontSize;

  const AppButton({
    super.key,
    required this.label,
    this.onPressed,
    this.isLoading = false,
    this.variant = AppButtonVariant.primary,
    this.prefixIcon,
    this.textColor,
    this.iconColor,
    this.height,
    this.fontSize,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final metrics = _ButtonMetrics.get();

    final buttonHeight = height ?? metrics.height;
    final labelSize = fontSize ?? metrics.fontSize;

    final shape = RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(metrics.radius),
    );

    // ------------------------------------------------------------
    // LOADING
    // ------------------------------------------------------------
    if (isLoading) {
      return SizedBox(
        width: double.infinity,
        height: buttonHeight,
        child: Container(
          decoration: BoxDecoration(
            gradient: colors.buttonPrimaryGradient,
            borderRadius: BorderRadius.circular(metrics.radius),
          ),
          child: ElevatedButton(
            onPressed: null,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.transparent,
              disabledBackgroundColor: Colors.transparent,
              shadowColor: Colors.transparent,
              surfaceTintColor: Colors.transparent,
              elevation: 0,
              shape: shape,
            ),
            child: Center(
              child: SizedBox(
                width: metrics.loaderSize,
                height: metrics.loaderSize,
                child: CircularProgressIndicator(
                  strokeWidth: metrics.loaderStroke,
                  valueColor: AlwaysStoppedAnimation(colors.onBrand),
                ),
              ),
            ),
          ),
        ),
      );
    }

    final isDisabled = onPressed == null;

    // ------------------------------------------------------------
    // COLORS
    // ------------------------------------------------------------

    final effectiveTextColor = isDisabled
        ? colors.textDisabled
        : (textColor ?? _textColor(colors));

    final effectiveIconColor = isDisabled
        ? colors.textDisabled
        : (iconColor ?? _textColor(colors));

    final disabledFill = colors.buttonDisabledFill;

    // ------------------------------------------------------------
    // BUTTON CONTENT
    // ------------------------------------------------------------

    Widget child = Row(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (prefixIcon != null) ...[
          Icon(
            prefixIcon,
            size: metrics.iconSize,
            color: effectiveIconColor,
          ),
          SizedBox(width: metrics.iconGap),
        ],
        Flexible(
          child: Text(
            label,
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: labelSize,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.2,
              color: effectiveTextColor,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );

    switch (variant) {
    // ============================================================
    // PRIMARY
    // ============================================================
      case AppButtonVariant.primary:
        return SizedBox(
          width: double.infinity,
          height: buttonHeight,
          child: Container(
            decoration: BoxDecoration(
              gradient: isDisabled ? null : colors.buttonPrimaryGradient,
              color: isDisabled ? disabledFill : null,
              borderRadius: BorderRadius.circular(metrics.radius),
              boxShadow: isDisabled
                  ? null
                  : [
                BoxShadow(
                  color: colors.brand.withValues(alpha: 0.28),
                  blurRadius: metrics.shadowBlur,
                  offset: Offset(0, metrics.shadowOffset),
                ),
              ],
            ),
            child: ElevatedButton(
              onPressed: onPressed,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.transparent,
                disabledBackgroundColor: Colors.transparent,
                shadowColor: Colors.transparent,
                surfaceTintColor: Colors.transparent,
                elevation: 0,
                padding: EdgeInsets.symmetric(horizontal: metrics.hPad),
                shape: shape,
              ),
              child: child,
            ),
          ),
        );

    // ============================================================
    // SECONDARY
    // ============================================================
      case AppButtonVariant.secondary:
        return SizedBox(
          width: double.infinity,
          height: buttonHeight,
          child: Container(
            decoration: BoxDecoration(
              gradient: isDisabled ? null : colors.buttonSecondaryGradient,
              color: isDisabled ? disabledFill : null,
              borderRadius: BorderRadius.circular(metrics.radius),
            ),
            child: FilledButton(
              onPressed: onPressed,
              style: FilledButton.styleFrom(
                backgroundColor: Colors.transparent,
                disabledBackgroundColor: Colors.transparent,
                foregroundColor: effectiveTextColor,
                elevation: 0,
                padding: EdgeInsets.symmetric(horizontal: metrics.hPad),
                shape: shape,
              ),
              child: child,
            ),
          ),
        );

    // ============================================================
    // OUTLINED
    // ============================================================
      case AppButtonVariant.outlined:
        return SizedBox(
          width: double.infinity,
          height: buttonHeight,
          child: OutlinedButton(
            onPressed: onPressed,
            style: OutlinedButton.styleFrom(
              backgroundColor: isDisabled
                  ? disabledFill
                  : colors.brand.withValues(alpha: 0.04),
              foregroundColor: effectiveTextColor,
              side: BorderSide(
                color: isDisabled ? colors.border : colors.brand,
                width: metrics.borderWidth,
              ),
              padding: EdgeInsets.symmetric(horizontal: metrics.hPad),
              shape: shape,
            ),
            child: child,
          ),
        );
    }
  }

  // ==============================================================
  // TEXT COLOR
  // ==============================================================

  Color _textColor(AppThemeColors colors) {
    switch (variant) {
      case AppButtonVariant.primary:
        return colors.onBrand;

      case AppButtonVariant.secondary:
      case AppButtonVariant.outlined:
        return colors.brand;
    }
  }
}

// ==================================================================
// BUTTON METRICS
// ==================================================================

class _ButtonMetrics {
  const _ButtonMetrics({
    required this.height,
    required this.fontSize,
    required this.iconSize,
    required this.iconGap,
    required this.radius,
    required this.hPad,
    required this.borderWidth,
    required this.loaderSize,
    required this.loaderStroke,
    required this.shadowBlur,
    required this.shadowOffset,
  });

  final double height;
  final double fontSize;
  final double iconSize;
  final double iconGap;
  final double radius;
  final double hPad;
  final double borderWidth;
  final double loaderSize;
  final double loaderStroke;
  final double shadowBlur;
  final double shadowOffset;

  factory _ButtonMetrics.get() {
    if (ResponsiveUtils.isTabletLandscape) {
      return const _ButtonMetrics(
        height: 54,
        fontSize: 16,
        iconSize: 19,
        iconGap: 9,
        radius: 12,
        hPad: 20,
        borderWidth: 1.4,
        loaderSize: 22,
        loaderStroke: 2.4,
        shadowBlur: 16,
        shadowOffset: 6,
      );
    }

    if (ResponsiveUtils.isTabletPortrait) {
      return const _ButtonMetrics(
        height: 58,
        fontSize: 17,
        iconSize: 21,
        iconGap: 10,
        radius: 14,
        hPad: 22,
        borderWidth: 1.5,
        loaderSize: 24,
        loaderStroke: 2.6,
        shadowBlur: 18,
        shadowOffset: 7,
      );
    }

    // Phone
    return const _ButtonMetrics(
      height: 54,
      fontSize: 16,
      iconSize: 18,
      iconGap: 8,
      radius: 14,
      hPad: 18,
      borderWidth: 1.4,
      loaderSize: 22,
      loaderStroke: 2.4,
      shadowBlur: 16,
      shadowOffset: 6,
    );
  }
}