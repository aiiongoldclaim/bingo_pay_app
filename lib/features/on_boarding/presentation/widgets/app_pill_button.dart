// import 'package:flutter/material.dart';
//
// import '../../../../core/theme/theme_colors.dart';
//
// enum AppPillButtonVariant { filled, outlined, tonal }
//
// enum AppPillIconSide { none, leading, trailing }
//
// class AppPillButton extends StatelessWidget {
//   const AppPillButton({
//     super.key,
//     required this.label,
//     this.onTap,
//     this.variant = AppPillButtonVariant.filled,
//     this.icon,
//     this.iconSide = AppPillIconSide.trailing,
//     this.height,
//     this.fontSize,
//     this.minWidth = 0,
//     this.maxWidth,
//     this.expand = false,
//     this.gradient,
//     this.backgroundColor,
//     this.foregroundColor,
//     this.horizontalPadding,
//   });
//
//   final String label;
//   final VoidCallback? onTap;
//   final AppPillButtonVariant variant;
//   final IconData? icon;
//   final AppPillIconSide iconSide;
//   final double? height;
//   final double? fontSize;
//   final double minWidth;
//   final double? maxWidth;
//   final bool expand;
//   final Gradient? gradient;
//   final Color? backgroundColor;
//   final Color? foregroundColor;
//   final double? horizontalPadding;
//
//   bool get _enabled => onTap != null;
//
//   @override
//   Widget build(BuildContext context) {
//     final isDark = Theme.of(context).brightness == Brightness.dark;
//     final h = height ?? 52;
//     final fs = fontSize ?? 16;
//     final hPad = horizontalPadding ?? h * 0.42;
//
//     final resolvedFg =
//         foregroundColor ??
//         switch (variant) {
//           AppPillButtonVariant.filled => ThemeColors.white,
//           AppPillButtonVariant.outlined =>
//             isDark ? ThemeColors.white : ThemeColors.textDark,
//           AppPillButtonVariant.tonal => ThemeColors.blue,
//         };
//
//     final resolvedBg =
//         backgroundColor ??
//         switch (variant) {
//           AppPillButtonVariant.filled => null,
//           AppPillButtonVariant.outlined => Colors.transparent,
//           AppPillButtonVariant.tonal =>
//             isDark
//                 ? ThemeColors.surface2.withValues(alpha: 0.08)
//                 : ThemeColors.blueSoft,
//         };
//
//     final resolvedGradient = variant == AppPillButtonVariant.filled
//         ? (gradient ??
//               (isDark
//                   ? ThemeColors.primaryGradient
//                   : const LinearGradient(
//                       colors: [ThemeColors.blueDeep, ThemeColors.textDark],
//                     )))
//         : null;
//
//     final border = variant == AppPillButtonVariant.outlined
//         ? Border.all(
//             color: (isDark ? ThemeColors.white : ThemeColors.ink).withValues(
//               alpha: 0.14,
//             ),
//             width: 1,
//           )
//         : null;
//
//     final iconWidget = icon == null
//         ? null
//         : Icon(icon, size: fs + 2, color: resolvedFg);
//
//     final text = Flexible(
//       child: Text(
//         label,
//         maxLines: 1,
//         overflow: TextOverflow.ellipsis,
//         softWrap: false,
//         style: TextStyle(
//           fontSize: fs,
//           fontWeight: FontWeight.w600,
//           color: resolvedFg,
//         ),
//       ),
//     );
//
//     final children = <Widget>[
//       if (iconWidget != null && iconSide == AppPillIconSide.leading) ...[
//         iconWidget,
//         SizedBox(width: fs * 0.5),
//       ],
//       text,
//       if (iconWidget != null && iconSide == AppPillIconSide.trailing) ...[
//         SizedBox(width: fs * 0.5),
//         iconWidget,
//       ],
//     ];
//
//     final content = Padding(
//       padding: EdgeInsets.symmetric(horizontal: hPad),
//       child: Row(
//         mainAxisSize: expand ? MainAxisSize.max : MainAxisSize.min,
//         mainAxisAlignment: MainAxisAlignment.center,
//         children: children,
//       ),
//     );
//
//     return Opacity(
//       opacity: _enabled ? 1 : 0.45,
//       child: ConstrainedBox(
//         constraints: BoxConstraints(
//           minWidth: minWidth,
//           maxWidth: maxWidth ?? double.infinity,
//           minHeight: h,
//           maxHeight: h,
//         ),
//         child: Material(
//           color: Colors.transparent,
//           child: InkWell(
//             onTap: onTap,
//             borderRadius: BorderRadius.circular(h),
//             child: Ink(
//               decoration: BoxDecoration(
//                 color: resolvedBg,
//                 gradient: resolvedGradient,
//                 border: border,
//                 borderRadius: BorderRadius.circular(h),
//               ),
//               child: Center(child: content),
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }
