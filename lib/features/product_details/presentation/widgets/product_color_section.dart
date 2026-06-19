import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../../../core/theme/theme_colors.dart';
import '../../../../../core/theme/app_text_styles.dart';
import '../../data/models/product_details_model.dart';

class ProductColorSection extends StatelessWidget {
  final List<ProductColorOption> colorOptions;
  final int selectedIndex;
  final void Function(int) onSelect;

  const ProductColorSection({
    super.key,
    required this.colorOptions,
    required this.selectedIndex,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    if (colorOptions.isEmpty) return const SizedBox.shrink();

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: ThemeColors.surface,
        borderRadius: BorderRadius.circular(16),
      ),

      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                'Color',
                style: AppTextStyles.titleMedium.copyWith(
                  fontSize: 15.sp,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                ' · ${colorOptions[selectedIndex].name}',
                style: TextStyle(
                  fontSize: 14.sp,
                  color: ThemeColors.inkMid,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          SizedBox(height: 1.5.h),
          Row(
            children: List.generate(
              colorOptions.length,
              (index) => ColorSwatch(
                option: colorOptions[index],
                isSelected: selectedIndex == index,
                onTap: () => onSelect(index),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class ColorSwatch extends StatelessWidget {
  final ProductColorOption option;
  final bool isSelected;
  final VoidCallback onTap;

  const ColorSwatch({
    super.key,
    required this.option,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(right: 10),
        padding: const EdgeInsets.all(3),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? const Color(0xFF2453FF) : Colors.transparent,
            width: 2,
          ),
        ),
        child: Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            color: option.color,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.shade300, width: 1),
          ),
        ),
      ),
    );
  }
}
