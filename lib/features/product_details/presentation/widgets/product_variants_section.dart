// import 'package:flutter/material.dart';
// import 'package:sizer/sizer.dart';
//
// import '../../../../../core/theme/theme_colors.dart';
// import '../../../../../core/theme/app_text_styles.dart';
// import '../../data/models/product_details_model.dart';
//
// class ProductVariantsSection extends StatelessWidget {
//   final List<ProductVariant> variants;
//   final int selectedIndex;
//   final void Function(int) onSelect;
//
//   const ProductVariantsSection({
//     super.key,
//     required this.variants,
//     required this.selectedIndex,
//     required this.onSelect,
//   });
//
//   @override
//   Widget build(BuildContext context) {
//     if (variants.length <= 1) return const SizedBox.shrink();
//
//     return Padding(
//       padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.w),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Text(
//             'Available Options',
//             style: AppTextStyles.titleMedium.copyWith(
//               fontSize: 15.sp,
//               fontWeight: FontWeight.bold,
//             ),
//           ),
//           SizedBox(height: 2.h),
//           SizedBox(
//             height: 16.h,
//             child: ListView.builder(
//               scrollDirection: Axis.horizontal,
//               physics: const AlwaysScrollableScrollPhysics(),
//               padding: EdgeInsets.zero,
//               itemCount: variants.length,
//               itemBuilder: (context, index) => VariantCard(
//                 variant: variants[index],
//                 isSelected: selectedIndex == index,
//                 onTap: () => onSelect(index),
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
//
// class VariantCard extends StatelessWidget {
//   final ProductVariant variant;
//   final bool isSelected;
//   final VoidCallback onTap;
//
//   const VariantCard({
//     super.key,
//     required this.variant,
//     required this.isSelected,
//     required this.onTap,
//   });
//
//   @override
//   Widget build(BuildContext context) {
//     final stockStatus = variant.availableStock > 0 ? 'In Stock' : 'Out of Stock';
//     final stockColor = variant.availableStock > 0
//         ? ThemeColors.green
//         : ThemeColors.red;
//
//     return GestureDetector(
//       onTap: onTap,
//       child: Container(
//         width: 45.w,
//         margin: EdgeInsets.only(right: 2.w),
//         padding: EdgeInsets.all(3.w),
//         decoration: BoxDecoration(
//           border: Border.all(
//             color: isSelected
//                 ? const Color(0xFF2453FF)
//                 : Colors.grey.shade300,
//             width: isSelected ? 2 : 1,
//           ),
//           borderRadius: BorderRadius.circular(12),
//           color: isSelected
//               ? const Color(0xFF2453FF).withValues(alpha: 0.05)
//               : ThemeColors.white,
//         ),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           mainAxisAlignment: MainAxisAlignment.spaceBetween,
//           children: [
//             Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Row(
//                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                   children: [
//                     Expanded(
//                       child: Text(
//                         variant.variantName,
//                         style: AppTextStyles.labelLarge.copyWith(
//                           fontSize: 16.sp,
//                           fontWeight: FontWeight.bold,
//                         ),
//                         maxLines: 1,
//                         overflow: TextOverflow.ellipsis,
//                       ),
//                     ),
//                     if (isSelected)
//                       Padding(
//                         padding: EdgeInsets.only(left: 1.w),
//                         child: Container(
//                           width: 20,
//                           height: 20,
//                           decoration: BoxDecoration(
//                             color: const Color(0xFF2453FF),
//                             borderRadius: BorderRadius.circular(4),
//                           ),
//                           child: Icon(
//                             Icons.check,
//                             color: ThemeColors.white,
//                             size: 14.sp,
//                           ),
//                         ),
//                       ),
//                   ],
//                 ),
//                 SizedBox(height: 1.h),
//                 if (variant.attributes.isNotEmpty)
//                   Text(
//                     variant.attributes
//                         .map((attr) => attr.value)
//                         .join(', '),
//                     style: AppTextStyles.bodySmall.copyWith(
//                       color: ThemeColors.inkMid,
//                       fontSize: 14.sp,
//                     ),
//                     maxLines: 2,
//                     overflow: TextOverflow.ellipsis,
//                   ),
//               ],
//             ),
//             Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Row(
//                   children: [
//                     Text(
//                       '\$${_formatPrice(variant.salePrice)}',
//                       style: AppTextStyles.labelLarge.copyWith(
//                         fontWeight: FontWeight.bold,
//                         fontSize: 16.sp,
//                       ),
//                     ),
//                     if (variant.basePrice > variant.salePrice) ...[
//                       SizedBox(width: 1.w),
//                       Text(
//                         '\$${_formatPrice(variant.basePrice)}',
//                         style: AppTextStyles.bodySmall.copyWith(
//                           decoration: TextDecoration.lineThrough,
//                           color: ThemeColors.inkDim,
//                           fontSize: 14.sp,
//                         ),
//                       ),
//                     ],
//                   ],
//                 ),
//                 SizedBox(height: 1.h),
//                 Container(
//                   padding: EdgeInsets.symmetric(
//                     horizontal: 2.w,
//                     vertical: 0.3.h,
//                   ),
//                   decoration: BoxDecoration(
//                     color: stockColor.withValues(alpha: 0.12),
//                     borderRadius: BorderRadius.circular(6),
//                   ),
//                   child: Text(
//                     stockStatus,
//                     style: AppTextStyles.labelMedium.copyWith(
//                       color: stockColor,
//                       fontWeight: FontWeight.bold,
//                       fontSize: 13.sp,
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//           ],
//         ),
//       ),
//     );
//   }
//
//   String _formatPrice(double price) {
//     final s = price.truncate().toString();
//     final buf = StringBuffer();
//     for (int i = 0; i < s.length; i++) {
//       final fromEnd = s.length - i;
//       buf.write(s[i]);
//       final rem = fromEnd - 1;
//       if (rem == 3 || (rem > 3 && (rem - 3) % 2 == 0)) buf.write(',');
//     }
//     return buf.toString();
//   }
// }
import 'package:flutter/material.dart';

import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/theme/app_theme_colors.dart';
import '../../../../core/widgets/price_formatter.dart';
import '../../data/models/product_details_model.dart';
import 'product_metrics.dart';

class ProductVariantsSection extends StatelessWidget {
  final ProductMetrics metrics;
  final List<ProductVariant> variants;
  final int selectedIndex;
  final ValueChanged<int> onSelect;

  /// Generic variantName detect karne ke liye
  final String productName;

  const ProductVariantsSection({
    super.key,
    required this.metrics,
    required this.variants,
    required this.selectedIndex,
    required this.onSelect,
    required this.productName,
  });

  @override
  Widget build(BuildContext context) {
    if (variants.length <= 1) return const SizedBox.shrink();

    final colors = context.colors;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          'Available Options',
          style: AppTextStyles.titleMedium.copyWith(
            color: colors.textPrimary,
            fontFamily: 'Inter',
            fontWeight: FontWeight.w700,
            fontSize: metrics.sectionTitleSize,
          ),
        ),

        SizedBox(height: metrics.gapMd),

        SizedBox(
          height: metrics.variantCardHeight,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: EdgeInsets.zero,
            itemCount: variants.length,
            separatorBuilder: (_, __) => SizedBox(width: metrics.gapSm),
            itemBuilder: (context, index) => VariantCard(
              metrics: metrics,
              variant: variants[index],
              productName: productName,
              index: index,
              isSelected: selectedIndex == index,
              onTap: () => onSelect(index),
            ),
          ),
        ),
      ],
    );
  }
}

class VariantCard extends StatelessWidget {
  final ProductMetrics metrics;
  final ProductVariant variant;
  final String productName;
  final int index;
  final bool isSelected;
  final VoidCallback onTap;

  const VariantCard({
    super.key,
    required this.metrics,
    required this.variant,
    required this.productName,
    required this.index,
    required this.isSelected,
    required this.onTap,
  });

  String get _label {
    final name = variant.variantName.trim();
    if (name.isNotEmpty) return name;

    if (variant.attributes.isNotEmpty) {
      return variant.attributes.map((attribute) => attribute.value).join(' / ');
    }

    return 'Option ${index + 1}';
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    final isOutOfStock = variant.availableStock <= 0;
    final stockLabel = isOutOfStock ? 'Out of Stock' : 'In Stock';
    final stockColor = isOutOfStock ? colors.error : colors.statusSuccess;
    final stockSoft =
    isOutOfStock ? colors.error.withValues(alpha: 0.12) : colors.statusSuccessSoft;

    final hasDiscount = variant.basePrice > variant.salePrice;

    return Material(
      color: isSelected ? colors.brandSoft : colors.surface,
      borderRadius: BorderRadius.circular(metrics.cardRadius),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: isOutOfStock ? null : onTap,
        child: Container(
          width: metrics.variantCardWidth,
          padding: EdgeInsets.all(metrics.cardPad * 0.8),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(metrics.cardRadius),
            border: Border.all(
              color: isSelected ? colors.brand : colors.border,
              width: isSelected ? 1.5 : 1,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // ── Name + check ──────────────────────────────
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Text(
                      _label,
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.labelLarge.copyWith(
                        color: isOutOfStock
                            ? colors.textMuted
                            : colors.textPrimary,
                        fontFamily: 'Inter',
                        fontWeight: FontWeight.w700,
                        fontSize: metrics.rowTitleSize,
                        decoration:
                        isOutOfStock ? TextDecoration.lineThrough : null,
                      ),
                    ),
                  ),
                  if (isSelected) ...[
                    SizedBox(width: metrics.gapXs),
                    Container(
                      width: metrics.rowTitleSize * 1.3,
                      height: metrics.rowTitleSize * 1.3,
                      decoration: BoxDecoration(
                        color: colors.brand,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      alignment: Alignment.center,
                      child: Icon(
                        Icons.check_rounded,
                        color: colors.onBrand,
                        size: metrics.rowTitleSize * 0.9,
                      ),
                    ),
                  ],
                ],
              ),

              if (variant.attributes.isNotEmpty) ...[
                SizedBox(height: metrics.gapXs),
                Text(
                  variant.attributes
                      .map((attribute) => attribute.value)
                      .join(', '),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.bodySmall.copyWith(
                    color: colors.textSecondary,
                    fontFamily: 'Inter',
                    fontSize: metrics.rowSubSize,
                  ),
                ),
              ],

              const Spacer(),

              // ── Price ─────────────────────────────────────
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Flexible(
                    child: Text(
                      formatCurrency(variant.salePrice),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.labelLarge.copyWith(
                        color: isOutOfStock
                            ? colors.textMuted
                            : colors.textPrimary,
                        fontFamily: 'Inter',
                        fontWeight: FontWeight.w700,
                        fontSize: metrics.rowTitleSize,
                      ),
                    ),
                  ),
                  if (hasDiscount) ...[
                    SizedBox(width: metrics.gapXs),
                    Text(
                      formatCurrency(variant.basePrice),
                      style: AppTextStyles.bodySmall.copyWith(
                        color: colors.textMuted,
                        fontFamily: 'Inter',
                        fontSize: metrics.rowSubSize,
                        decoration: TextDecoration.lineThrough,
                        decorationColor: colors.textMuted,
                      ),
                    ),
                  ],
                ],
              ),

              SizedBox(height: metrics.gapSm),

              // ── Stock badge ───────────────────────────────
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: metrics.gapSm,
                  vertical: metrics.gapXs * 0.6,
                ),
                decoration: BoxDecoration(
                  color: stockSoft,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  stockLabel,
                  style: AppTextStyles.labelMedium.copyWith(
                    color: stockColor,
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.w700,
                    fontSize: metrics.captionSize,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}