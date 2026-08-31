// import 'package:flutter/material.dart';
//
// import '../../../../core/theme/app_theme_colors.dart';
// import 'home_metrics.dart';
//
// class BenefitItemData {
//   final IconData icon;
//   final String label;
//   const BenefitItemData({required this.icon, required this.label});
// }
//
// class BenefitsStrip extends StatelessWidget {
//   const BenefitsStrip({
//     super.key,
//     required this.metrics,
//     required this.benefits,
//   });
//
//   final HomeMetrics metrics;
//   final List<BenefitItemData> benefits;
//
//   @override
//   Widget build(BuildContext context) {
//     if (benefits.isEmpty) return const SizedBox.shrink();
//     final c = context.c;
//
//     final children = <Widget>[];
//     for (var i = 0; i < benefits.length; i++) {
//       children.add(
//         Expanded(
//           child: _BenefitItem(metrics: metrics, data: benefits[i]),
//         ),
//       );
//       if (i != benefits.length - 1) {
//         children.add(
//           Container(
//             width: 1,
//             height: metrics.benefitIconSize * 1.5,
//             color: c.isDark ? c.border : Colors.white.withValues(alpha: 0.28),
//           ),
//         );
//       }
//     }
//
//     return Container(
//       padding: EdgeInsets.symmetric(vertical: metrics.pagePadding * 0.9),
//       decoration: BoxDecoration(
//         gradient: c.benefitsStrip,
//         borderRadius: BorderRadius.circular(metrics.heroRadius * 0.6),
//         border: c.isDark ? Border.all(color: c.border) : null,
//       ),
//       child: Row(children: children),
//     );
//   }
// }
//
// class _BenefitItem extends StatelessWidget {
//   const _BenefitItem({required this.metrics, required this.data});
//
//   final HomeMetrics metrics;
//   final BenefitItemData data;
//
//   @override
//   Widget build(BuildContext context) {
//     final c = context.c;
//     final iconColor = c.isDark ? c.brand : Colors.white;
//     final textColor = c.isDark ? c.textPrimary : Colors.white;
//
//     return Row(
//       mainAxisAlignment: MainAxisAlignment.center,
//       children: [
//         Icon(data.icon, size: metrics.benefitIconSize, color: iconColor),
//         SizedBox(width: metrics.pagePadding * 0.3),
//         Flexible(
//           child: Text(
//             data.label,
//             maxLines: 2,
//             overflow: TextOverflow.ellipsis,
//             style: TextStyle(
//               fontSize: metrics.benefitTextSize,
//               fontWeight: FontWeight.w600,
//               height: 1.25,
//               color: textColor,
//             ),
//           ),
//         ),
//       ],
//     );
//   }
// }
