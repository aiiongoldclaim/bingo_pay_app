// import 'package:bingo_pay/features/product_details/presentation/widgets/product_metrics.dart';
// import 'package:flutter/material.dart';
//
// import '../../../../core/theme/app_text_styles.dart';
// import '../../../../core/theme/app_theme_colors.dart';
//
//
// class ProductBottomBar extends StatelessWidget {
//   final ProductMetrics metrics;
//   final bool isWishlisted;
//   final bool isOutOfStock;
//   final bool isInCart;
//   final bool isAddingItem;
//   final VoidCallback onShare;
//   final VoidCallback onWishlist;
//   final VoidCallback? onAddToBag;
//
//   const ProductBottomBar({
//     super.key,
//     required this.metrics,
//     required this.isWishlisted,
//     required this.isOutOfStock,
//     required this.isInCart,
//     required this.isAddingItem,
//     required this.onShare,
//     required this.onWishlist,
//     required this.onAddToBag,
//   });
//
//   @override
//   Widget build(BuildContext context) {
//     final c = context.c;
//     final m = metrics;
//
//     final barHeight = m.isTablet ? 58.0 : m.pillHeight * 1.25;
//
//     Widget iconBtn({
//       required IconData icon,
//       required Color iconColor,
//       required VoidCallback onTap,
//     }) => SizedBox(
//       width: barHeight,
//       height: barHeight,
//       child: Material(
//         color: c.surface,
//         borderRadius: BorderRadius.circular(12),
//         clipBehavior: Clip.antiAlias,
//         child: InkWell(
//           onTap: onTap,
//           child: Container(
//             decoration: BoxDecoration(
//               borderRadius: BorderRadius.circular(12),
//               border: Border.all(color: c.brand.withValues(alpha: 0.45)),
//             ),
//             alignment: Alignment.center,
//             child: Icon(icon, size: m.rowIconSize, color: iconColor),
//           ),
//         ),
//       ),
//     );
//
//     return Container(
//       padding: EdgeInsets.fromLTRB(
//         m.pageHPad,
//         m.gapSm,
//         m.pageHPad,
//         m.gapSm * 0.5,
//       ),
//       decoration: BoxDecoration(
//         color: c.background,
//         border: Border(top: BorderSide(color: c.border, width: 1)),
//       ),
//       child: SafeArea(
//         top: false,
//         child: Row(
//           children: [
//             iconBtn(
//               icon: Icons.ios_share_rounded,
//               iconColor: c.brand,
//               onTap: onShare,
//             ),
//
//             SizedBox(width: m.gapSm),
//
//             iconBtn(
//               icon: isWishlisted
//                   ? Icons.favorite_rounded
//                   : Icons.favorite_border_rounded,
//               iconColor: c.brand,
//               onTap: onWishlist,
//             ),
//
//             SizedBox(width: m.gapSm),
//
//             Expanded(
//               child: SizedBox(
//                 height: barHeight,
//                 child: Material(
//                   color: onAddToBag == null ? c.border : c.brand,
//                   borderRadius: BorderRadius.circular(12),
//                   clipBehavior: Clip.antiAlias,
//                   child: InkWell(
//                     onTap: isAddingItem ? null : onAddToBag,
//                     child: Center(
//                       child: isAddingItem
//                           ? SizedBox(
//                         width: m.rowIconSize,
//                         height: m.rowIconSize,
//                         child: CircularProgressIndicator(
//                           strokeWidth: 2,
//                           valueColor: AlwaysStoppedAnimation(c.surface),
//                         ),
//                       )
//                           : Row(
//                         mainAxisAlignment: MainAxisAlignment.center,
//                         children: [
//                           Icon(
//                             Icons.shopping_bag_outlined,
//                             size: m.rowIconSize,
//                             color: onAddToBag == null
//                                 ? c.textMuted
//                                 : c.surface,
//                           ),
//                           SizedBox(width: m.gapSm * 0.8),
//                           Text(
//                             isOutOfStock
//                                 ? 'OUT OF STOCK'
//                                 : isInCart
//                                 ? 'GO TO CART'
//                                 : 'ADD TO BAG',
//                             style: AppTextStyles.buttonText.copyWith(
//                               color: onAddToBag == null
//                                   ? c.textMuted
//                                   : c.surface,
//                               fontFamily: 'Inter',
//                               fontWeight: FontWeight.w700,
//                               fontSize: m.sectionTitleSize,
//                               letterSpacing: 0.4,
//                             ),
//                           ),
//                         ],
//                       ),
//                     ),
//                   ),
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }