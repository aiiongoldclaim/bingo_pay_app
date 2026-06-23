// import 'package:flutter/material.dart';
// import 'package:sizer/sizer.dart';
//
// import '../../../../../core/theme/theme_colors.dart';
// import '../../../../core/widgets/app_button.dart';
//
// /// Sticky bottom action bar: price summary + Add to cart + Buy now.
// class ProductBottomBar extends StatelessWidget {
//   final String price;
//   final VoidCallback onAddToCart;
//   final VoidCallback onBuyNow;
//
//   const ProductBottomBar({
//     super.key,
//     required this.price,
//     required this.onAddToCart,
//     required this.onBuyNow,
//   });
//
//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.5.h),
//       decoration: BoxDecoration(
//         color: ThemeColors.surface,
//         boxShadow: [
//           BoxShadow(
//             color: ThemeColors.ink.withOpacity(0.08),
//             blurRadius: 10,
//             offset: const Offset(0, -2),
//           ),
//         ],
//       ),
//       child: SafeArea(
//         top: false,
//         child: Row(
//           children: [
//             // Price column
//             Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               mainAxisSize: MainAxisSize.min,
//               children: [
//                 Text(
//                   'Total',
//                   style: TextStyle(
//                     fontSize: 15.sp,
//                     color: ThemeColors.inkDim,
//                     fontWeight: FontWeight.bold,
//                   ),
//                 ),
//                 Text(
//                   price,
//                   style: TextStyle(
//                     fontSize: 18.sp,
//                     fontWeight: FontWeight.w800,
//                     color: ThemeColors.ink,
//                   ),
//                 ),
//               ],
//             ),
//             SizedBox(width: 4.w),
//             // Add to cart
//             Expanded(
//               child: OutlinedButton.icon(
//                 onPressed: onAddToCart,
//                 style: OutlinedButton.styleFrom(
//                   padding: EdgeInsets.symmetric(vertical: 1.5.h),
//                   side: BorderSide(color: ThemeColors.line, width: 1.5),
//                   shape: RoundedRectangleBorder(
//                     borderRadius: BorderRadius.circular(12),
//                   ),
//                 ),
//                 icon: Icon(
//                   Icons.shopping_bag_outlined,
//                   size: 18.sp,
//                   color: ThemeColors.ink,
//                 ),
//                 label: Text(
//                   'Add to\ncart',
//                   textAlign: TextAlign.center,
//                   style: TextStyle(
//                     fontSize: 15.sp,
//                     fontWeight: FontWeight.bold,
//                     color: ThemeColors.ink,
//                     height: 1.2,
//                   ),
//                 ),
//               ),
//             ),
//             SizedBox(width: 3.w),
//             // Buy now
//             Expanded(
//               // flex: 2,
//               child: SizedBox(
//                 height: 6.h,
//                 child: AppButton(
//                   label: 'Buy now',
//                   onPressed: onBuyNow,
//                   variant: AppButtonVariant.primary,
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
