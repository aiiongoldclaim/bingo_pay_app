// import 'package:flutter/material.dart';
// import 'package:bingo_pay/core/theme/app_theme_colors.dart';
// import 'package:bingo_pay/core/theme/theme_colors.dart';
// import 'membership_metrices.dart';
//
// /// Web ka "Vault Club is active" dialog.
// class MembershipSuccessDialog {
//   const MembershipSuccessDialog._();
//
//   static Future<void> show(
//       BuildContext context, {
//         required MembershipMetrics metrics,
//         required String planName,
//       }) {
//     final m = metrics;
//
//     return showDialog<void>(
//       context: context,
//       barrierDismissible: false,
//       builder: (dialogContext) {
//         final c = dialogContext.c;
//
//         return Dialog(
//           backgroundColor: Theme.of(dialogContext).scaffoldBackgroundColor,
//           insetPadding: EdgeInsets.symmetric(
//             horizontal: m.hPad,
//             vertical: m.sectionGap,
//           ),
//           shape: RoundedRectangleBorder(
//             borderRadius: BorderRadius.circular(m.radiusLg),
//           ),
//           child: ConstrainedBox(
//             constraints: BoxConstraints(
//               maxWidth: m.isTablet ? m.iconCircle * 9 : double.infinity,
//             ),
//             child: Padding(
//               padding: EdgeInsets.all(m.cardPad * 1.4),
//               child: Column(
//                 mainAxisSize: MainAxisSize.min,
//                 children: [
//                   Container(
//                     width: m.iconCircle * 1.3,
//                     height: m.iconCircle * 1.3,
//                     decoration: BoxDecoration(
//                       color: c.statusSuccessSoft,
//                       shape: BoxShape.circle,
//                     ),
//                     child: Icon(
//                       Icons.check_rounded,
//                       size: m.iconCircle * 0.62,
//                       color: c.statusSuccess,
//                     ),
//                   ),
//                   SizedBox(height: m.rowGap * 1.2),
//                   Text(
//                     '$planName is active',
//                     textAlign: TextAlign.center,
//                     style: TextStyle(
//                       fontSize: m.sectionTitleSize * 1.15,
//                       fontWeight: FontWeight.w700,
//                       color: c.textPrimary,
//                     ),
//                   ),
//                   SizedBox(height: m.rowGap * 0.5),
//                   Text(
//                     'Your new limits and features apply straight away.',
//                     textAlign: TextAlign.center,
//                     style: TextStyle(
//                       fontSize: m.bodySize,
//                       fontWeight: FontWeight.w400,
//                       height: 1.45,
//                       color: c.textSecondary,
//                     ),
//                   ),
//                   SizedBox(height: m.sectionGap * 0.9),
//                   SizedBox(
//                     width: m.isTablet ? m.iconCircle * 2.6 : double.infinity,
//                     height: m.buttonHeight,
//                     child: ElevatedButton(
//                       onPressed: () => Navigator.of(dialogContext).pop(),
//                       style: ElevatedButton.styleFrom(
//                         backgroundColor: c.brand,
//                         foregroundColor: ThemeColors.white,
//                         elevation: 0,
//                         minimumSize: Size.zero,
//                         shape: RoundedRectangleBorder(
//                           borderRadius: BorderRadius.circular(m.radiusMd),
//                         ),
//                       ),
//                       child: Text(
//                         'Done',
//                         style: TextStyle(
//                           fontSize: m.bodySize,
//                           fontWeight: FontWeight.w700,
//                         ),
//                       ),
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           ),
//         );
//       },
//     );
//   }
// }